using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class sales_waybilling : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(41);

    }
    [WebMethod]
    public static string showOrderDetails(string orderid)
    {
        //sm_delivery_vehicle_id    	sm_vehicle_no
        mySqlConnection db = new mySqlConnection();
        string orderDetailQry = "select tsm.cust_name as name,tc.cust_wallet_amt as walletamount,tc.cust_amount as outstanding,tsm.cust_id as ID,`sm_delivery_vehicle_id`,`sm_vehicle_no`,concat(user .first_name,user.last_name)as vehicle_id,DATE_FORMAT(sm_date,'%d-%b-%Y') AS date,cust_type,sm_delivery_status as order_status,tsm.branch_id,sm_invoice_no as invoiceNum from tbl_sales_master tsm inner join tbl_customer tc on tc.cust_id=tsm.cust_id left join tbl_user_details as user on tsm.sm_delivery_vehicle_id=user.id where sm_id=" + orderid + " ";
        //string orderDetailQry = "select tsm.cust_name as name,tc.cust_wallet_amt as walletamount,tc.cust_amount as outstanding,tsm.cust_id as ID,DATE_FORMAT(sm_date,'%d-%b-%Y') AS date,cust_type,sm_delivery_status as order_status,tsm.branch_id,sm_invoice_no as invoiceNum from tbl_sales_master tsm inner join tbl_customer tc on tc.cust_id=tsm.cust_id where sm_id=" + orderid + " ";
        DataTable dt = new DataTable();
        dt = db.SelectQuery(orderDetailQry);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            jsonResponse = JsonConvert.SerializeObject(dt, Formatting.Indented);

        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }
    [WebMethod]
    public static string searchOrderitems(string orderid, string itemcode, string itemname)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = "where 1 and si_itm_type!=2 and sm_id=" + orderid + " ";
        if (itemcode != null || itemcode != "")
        {
            qry_condition += " and itm_code like '%" + itemcode + "%'";
        }
        if (itemname != null || itemname != "")
        {
            qry_condition += " and itm_name like '%" + itemname + "%'";
        }
        string itemQry = "select sm_id,itbs_id as uniqueid,itm_code,itm_name,si_qty as mainqty,(si.si_qty-IFNULL((select sum(wi_stock) from tbl_waying_items wi where wi.sm_id=" + orderid + " and wi.itbs_id=si.itbs_id group by itbs_id),0)) as totalqty from tbl_sales_items si " + qry_condition;
        //string itemQry = "select sm_id,itbs_id as uniqueid,itm_code,itm_name,si_qty as mainqty,(si.si_qty-IFNULL((select sum(wi_stock) from tbl_waying_items wi where wi.sm_id=" + orderid + " and wi.itbs_id=si.itbs_id group by itbs_id having sum(wi_stock)>0),0)) as totalqty from tbl_sales_items si " + qry_condition + " having totalqty!=0";


       // string itemqry = "select itbs_id as uniqueid,itm_code,itm_name,si_price,(si.si_qty-IFNULL((select sum(sri_qty) from tbl_salesreturn_items sr where sr.sm_id=" + orderid + " and sr.itbs_id=si.itbs_id),0)) as totalqty,(si_net_amount/si_qty) as price,si_net_amount from tbl_sales_items si " + qry_condition;
        DataTable dt = new DataTable();
        dt = db.SelectQuery(itemQry);
        string jsonresponse = "";
        if (dt.Rows.Count > 0)
        {
            jsonresponse = JsonConvert.SerializeObject(dt, Formatting.Indented);
        }
        else
        {
            jsonresponse = "N";
        }
        return jsonresponse;

    }

    [WebMethod]
    public static string saveWayBilling(Dictionary<string, string> transfer_order)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            // getting timezone from branch
            db.BeginTransaction();
            string branchQry = "select branch_timezone from tbl_branch where branch_id='" + transfer_order["branchid"] + "'";
            string branch_timezone;

            DataTable dt_branchDetail = db.SelectQueryForTransaction(branchQry);
            if (dt_branchDetail != null)
            {
                branch_timezone = Convert.ToString(dt_branchDetail.Rows[0]["branch_timezone"]);
            }
            else
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                return result;
            }
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string waybill_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");

            // INSERTING TO waying header

            string waybill_insert_qry = "INSERT INTO `tbl_waying_header` (`sm_id`, `wh_date`, `wh_userid`, `wh_description`,`branch_id`, `cust_id` ) VALUES('" + transfer_order["sm_id"] + "','" + waybill_date + "','" + transfer_order["transfer_by"] + "','" + transfer_order["description"] + "','" + transfer_order["branchid"] + "', '" + transfer_order["cust_id"] + "');Select last_insert_id();";
            //,'" + transfer_order["branchid"] + "'
            var last_id = db.SelectScalarForTransaction(waybill_insert_qry);
            Int32 waybill_id = Convert.ToInt32(last_id);

            // END OF INSERTING TO waying header

            // getting transfer items

            List<Dictionary<string, string>> transfer_Items = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(transfer_order["transfer_Items"]);
            dynamic transfer_data = JsonConvert.DeserializeObject(transfer_order["transfer_Items"]);
            string trans_items = "";
            for (int i = 0; i < Convert.ToInt32(transfer_order["item_count"]); i++)
            {
                if (i == 0)
                {
                    trans_items = transfer_data[i].itbs_id;
                }
                else
                {
                    trans_items = trans_items + "," + transfer_data[i].itbs_id;
                }

            }

            string batch_insert_items_header = "INSERT INTO `tbl_waying_items` ( `wh_id`, `sm_id`, `itbs_id`, `wi_stock`) VALUES";
            string batch_insert_items = "";
            

            for (int i = 0; i < Convert.ToInt32(transfer_order["item_count"]); i++)
            {
                if (i == 0)
                {
                    batch_insert_items = "('" + waybill_id + "','" + transfer_order["sm_id"] + "','" + transfer_data[i].itbs_id + "','" + transfer_data[i].si_transfer_qty + "')";

                }
                else
                {
                    batch_insert_items = batch_insert_items + "," + "('" + waybill_id + "','" + transfer_order["sm_id"] + "','" + transfer_data[i].itbs_id + "','" + transfer_data[i].si_transfer_qty + "')";
                }

            }

            string saveToWayBillingItemsasBatch = batch_insert_items_header + batch_insert_items;
            bool batch_result = db.ExecuteQueryForTransaction(saveToWayBillingItemsasBatch);
            if (batch_result)
            {
                result = "SUCCESS";
              
            }
            else
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                return result;
            }

            db.CommitTransaction();
            result = "SUCCESS";
            result = "{\"result\":\"" + result + "\",\"headerid\":\"" + waybill_id + "\"}";
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                LogClass log = new LogClass("wayBilling");
                log.write(ex);
                return result;
            }
            catch
            {
            }
        }
        return result;
    }
}