using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class sales_editwaybill : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(42);
    }
    [WebMethod]
    public static string showEditOrderDetails(string orderid)
    {
        mySqlConnection db = new mySqlConnection();
        string orderDetailQry = "select tsm.cust_name as name,tc.cust_wallet_amt as walletamount,tc.cust_amount as outstanding,tsm.cust_id as ID,DATE_FORMAT(sm_date,'%d-%b-%Y') AS date,cust_type,sm_delivery_status as order_status,tsm.branch_id,sm_invoice_no as invoiceNum from tbl_sales_master tsm inner join tbl_customer tc on tc.cust_id=tsm.cust_id where sm_id=" + orderid + " ";
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
    public static string loadBill(string orderId, string billheaderId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtBillItems = new DataTable();
        DataTable dtOrder = new DataTable();
        StringBuilder sb = new StringBuilder();
        string qry_condition = "where 1 and si_itm_type!=2 and sm_id=" + orderId + " ";
        sb.Append("{");
        string editQry = "select sm_id,itbs_id as uniqueid,itm_code,itm_name,si_qty as totalqty,(si.si_qty-IFNULL((select sum(wi_stock) from tbl_waying_items wi where wi.sm_id=" + orderId + " and wi.itbs_id=si.itbs_id group by itbs_id),0)) as availableqty,(IFNULL((select wi_stock from tbl_waying_items wi where wi.sm_id=" + orderId + " and wi.wh_id=" + billheaderId + " and wi.itbs_id=si.itbs_id group by itbs_id),0)) as way_stock from tbl_sales_items si " + qry_condition + " having way_stock!=0";
        //string editQry = "select sm_id,itbs_id as uniqueid,itm_code,itm_name,(IFNULL((select wi_stock from tbl_waying_items wi where wi.sm_id=" + orderId + " and wi.wh_id=1 and wi.itbs_id=si.itbs_id group by itbs_id),0)) as way_stock from tbl_sales_items si ";
        //string editQry = "select sm_id,itbs_id as uniqueid,itm_code,itm_name,si_qty as mainqty,(si.si_qty-IFNULL((select sum(wi_stock) from tbl_waying_items wi where wi.sm_id=" + orderId + " and wi.itbs_id=si.itbs_id group by itbs_id having sum(wi_stock)>0),0)) as totalqty from tbl_sales_items si " + qry_condition + " having totalqty!=0";
        dtBillItems = db.SelectQuery(editQry);
        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtBillItems, Formatting.Indented));
        sb.Append(",");
        string description = "select wh_description from tbl_waying_header where sm_id='" + orderId + "' and wh_id='" + billheaderId + "'";
        dtOrder = db.SelectQuery(description);
        sb.Append("\"description\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }
    [WebMethod]
    public static string updateWayBilling(Dictionary<string, string> transfer_Editorder)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            // getting timezone from branch
            db.BeginTransaction();
            string branchQry = "select branch_timezone from tbl_branch where branch_id='" + transfer_Editorder["branchid"] + "'";
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
            string waybill_date = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            // updating TO waying header

            string waybill_update_qry = "update tbl_waying_header set wh_date ='" + waybill_date + "', wh_userid='" + transfer_Editorder["transfer_by"] + "' , wh_description='" + transfer_Editorder["description"] + "' where sm_id='" + transfer_Editorder["sm_id"] + "' and wh_id='" + transfer_Editorder["header_id"] + "'";
            //string waybill_insert_qry = "update `tbl_waying_header` (`sm_id`, `wh_date`, `wh_userid`, `wh_description`) VALUES('" + transfer_Editorder["sm_id"] + "','" + waybill_date + "','" + transfer_Editorder["transfer_by"] + "','" + transfer_Editorder["description"] + "');Select last_insert_id();";

            bool updateStatus=db.ExecuteQueryForTransaction(waybill_update_qry);

            // END OF updating TO waying header

            //delete current content
            string waybill_deleteqry = "delete from tbl_waying_items where sm_id='" + transfer_Editorder["sm_id"] + "' and wh_id='" + transfer_Editorder["header_id"] + "'";
            db.ExecuteQueryForTransaction(waybill_deleteqry);
            //end delete
            // getting transfer items

            List<Dictionary<string, string>> transfer_EditItems = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(transfer_Editorder["transfer_EditItems"]);
            dynamic transfer_Editdata = JsonConvert.DeserializeObject(transfer_Editorder["transfer_EditItems"]);
            string trans_items = "";
            for (int i = 0; i < Convert.ToInt32(transfer_Editorder["item_count"]); i++)
            {
                if (i == 0)
                {
                    trans_items = transfer_Editdata[i].itbs_id;
                }
                else
                {
                    trans_items = trans_items + "," + transfer_Editdata[i].itbs_id;
                }

            }

            string batch_insert_items_header = "INSERT INTO `tbl_waying_items` ( `wh_id`, `sm_id`, `itbs_id`, `wi_stock`) VALUES";
            string batch_insert_items = "";


            for (int i = 0; i < Convert.ToInt32(transfer_Editorder["item_count"]); i++)
            {
                if (i == 0)
                {
                    batch_insert_items = "('" + transfer_Editorder["header_id"] + "','" + transfer_Editorder["sm_id"] + "','" + transfer_Editdata[i].itbs_id + "','" + transfer_Editdata[i].si_transfer_qty + "')";

                }
                else
                {
                    batch_insert_items = batch_insert_items + "," + "('" + transfer_Editorder["header_id"] + "','" + transfer_Editorder["sm_id"] + "','" + transfer_Editdata[i].itbs_id + "','" + transfer_Editdata[i].si_transfer_qty + "')";
                }
            }

            string updateWayBillingItemsasBatch = batch_insert_items_header + batch_insert_items;
            bool batch_result = db.ExecuteQueryForTransaction(updateWayBillingItemsasBatch);
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
            result = "{\"result\":\"" + result + "\",\"headerid\":\"" + transfer_Editorder["header_id"] + "\"}";
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
}