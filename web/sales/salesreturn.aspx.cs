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
using MySql.Data.MySqlClient;
using System.Text;

public partial class sales_salesreturn : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(38);
    }

    [WebMethod]
    public static string showCustomerDetails(string custId)
    {
        mySqlConnection db = new mySqlConnection();
        string custDetailQry = "select tc.cust_name as name,tc.cust_amount as outstanding from tbl_customer tc where cust_id=" + custId + " ";
        DataTable dt = new DataTable();
        dt = db.SelectQuery(custDetailQry);
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
    public static string searchOrderitems(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1 and sm.branch_id='" + filters["branch_id"] + "' and sm.sm_type=1 and si.itm_type=1 ";
        if (filters.Count > 0)
        {
            if (filters["brand"] != "-1")
            {
                qry_condition += " and itb.itm_brand_id='" + filters["brand"] + "' ";
            }
            if (filters["category"] != "-1")
            {
                qry_condition += " and itb.itm_category_id='" + filters["category"] + "' ";
            }
            if (filters["searchCod"]!="")
            {
                qry_condition += " and itm_code like '%" + filters["searchCod"] + "%'";
            }
            if (filters["searchName"] != "")
            {
                qry_condition += " and itm_name like '%" + filters["searchName"] + "%'";
            }
        }
        string itemqry = "select sm.sm_invoice_no,sm.sm_id,si.itbs_id as uniqueid,si.itm_name,"
            + " si.itm_code,si.si_qty,si.si_foc,(si.si_qty+si.si_foc) as total_qty,"
            +" si.si_discount_rate,DATE_FORMAT(sm.sm_date, '%d %M %Y') as sm_date,"
            +" sm.cust_id ,si.si_price,IFNULL(sum(CASE WHEN (sr.sri_qty) "
            +" THEN sr.sri_qty ELSE 0 END),0) as returned ,"
            +" (si.si_net_amount/(si.si_qty+si.si_foc)) as return_price"
            +" from tbl_sales_master sm join tbl_sales_items si on si.sm_id=sm.sm_id"
            +" join tbl_itembranch_stock itb on itb.itbs_id=si.itbs_id "
            +" left join tbl_salesreturn_items sr on (sr.itbs_id=itb.itbs_id and sm.sm_id=sr.sm_id ) "
            +" " + qry_condition + ""
            +" and sm.sm_delivery_status=2 and sm.cust_id='" + filters["custid"] + "' "
            +" group by si_id having total_qty>returned order by sm.sm_date desc";
       // string itemqry = "select itbs_id as uniqueid,itm_code,itm_name,si_price,(si.si_qty-IFNULL((select sum(sri_qty) from tbl_salesreturn_items sr where sr.sm_id=" + orderid + " and sr.itbs_id=si.itbs_id),0)) as totalqty,(si_net_amount/si_qty) as price,si_net_amount from tbl_sales_items si " + qry_condition;
        DataTable dt = new DataTable();
        dt = db.SelectQuery(itemqry);
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
    public static string sales_return(Dictionary<string, string> return_order)
    {
        string result = "";
        string credited_amount = "";
        string new_balance = "";
        mySqlConnection db = new mySqlConnection();

        if (db.SelectQuery("SELECT srm_id FROM tbl_salesreturn_master WHERE srm_session_id='" + return_order["session_id"] + "'").Rows.Count > 0) // exist
        {
            //new_balance = db.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + return_order["cust_id"] + "'");
            result = "FAILED";
            // result = "{\"result\":\"" + result + "\",\"credited_amount\":" + credited_amount + ",\"new_balance\":" + new_balance + "}";
            return result;
        }

        try
        {
            // getting timezone from branch
            db.BeginTransaction();

            string branchQry = "select branch_timezone from tbl_branch where branch_id='" + return_order["branchid"] + "'";
            DataTable cTimeZone = db.SelectQueryForTransaction(branchQry);
            string branch_timezone = "";
            if (cTimeZone != null)
            {
                branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
            }

            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string srm_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");

            // INSERTING TO SALES RETURN MASTER

            string srm_insert_qry = "INSERT INTO `tbl_salesreturn_master` (`sm_id`, `cust_id`, `srm_userid`, `branch_id`, `srm_date`,`srm_session_id`) VALUES('0','" + return_order["cust_id"] + "','" + return_order["user_id"] + "','" + return_order["branchid"] + "','" + srm_date + "','" + return_order["session_id"] + "');Select last_insert_id();";
            var last_id = db.SelectScalarForTransaction(srm_insert_qry);
            Int32 srm_id = Convert.ToInt32(last_id);

            // END OF INSERTING TO SALES RETURN MASTER
            // getting returned items

            List<Dictionary<string, string>> return_Items = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(return_order["return_Items"]);
            dynamic return_data = JsonConvert.DeserializeObject(return_order["return_Items"]);
            string ret_items = "";
            for (int i = 0; i < Convert.ToInt32(return_order["item_count"]); i++)
            {
                if (i == 0)
                {
                    ret_items = return_data[i].itbs_id;
                }
                else
                {
                    ret_items = ret_items + "," + return_data[i].itbs_id;
                }

            }

            string batch_insert_items_header = "INSERT INTO `tbl_salesreturn_items` (`srm_id`, `sm_id`, `row_no`, `itbs_id`, `itm_code`, `itm_name`, `si_price`, `si_discount_rate`, `sri_qty`, `sri_discount_amount`, `sri_total`, `sri_type`) VALUES";
            string batch_insert_items = "";
            decimal srm_amount = 0;



            for (int i = 0; i < Convert.ToInt32(return_order["item_count"]); i++)
            {

                if (i == 0)
                {
                    batch_insert_items = "('" + srm_id + "','" + return_data[i].sm_id + "','" + i + "','" + return_data[i].itbs_id + "','" + return_data[i].itm_code + "','" + return_data[i].itm_name + "','" + return_data[i].si_price + "','" + return_data[i].si_discount_rate + "','" + return_data[i].sri_qty + "','0','" + return_data[i].sri_total + "','" + return_data[i].sri_type + "')";

                }
                else
                {
                    batch_insert_items = batch_insert_items + "," + "('" + srm_id + "','" + return_data[i].sm_id + "','" + i + "','" + return_data[i].itbs_id + "','" + return_data[i].itm_code + "','" + return_data[i].itm_name + "','" + return_data[i].si_price + "','" + return_data[i].si_discount_rate + "','" + return_data[i].sri_qty + "','0','" + return_data[i].sri_total + "','" + return_data[i].sri_type + "')";
                }

                srm_amount = srm_amount + Convert.ToDecimal(return_data[i].sri_total);
                credited_amount = srm_amount.ToString();

                // increase stock for ready to use items
                if (return_data[i].sri_type == "2")
                {
                    string new_stockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock + " + return_data[i].sri_qty + "),itm_last_update_date='" + srm_date + "' where itbs_id='" + return_data[i].itbs_id + "'";
                    db.ExecuteQueryForTransaction(new_stockQry);

                    StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                    can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");
                    // stock transaction
                    can_sb_bulk_stkTrQry.Append("('" + Convert.ToString(return_data[i].itbs_id) + "','" + ((int)Constants.ActionType.SALES) + "','" + return_data[i].sm_id + "','" + return_order["user_id"] + "'");
                    can_sb_bulk_stkTrQry.Append(",'SALES RETURN: (stock increase) " + return_data[i].sri_qty + " qty " + Convert.ToString(return_data[i].itm_name) + " from order #" + return_data[i].sm_id + "','" + return_data[i].sri_qty + "'");
                    can_sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(return_data[i].itbs_id) + "')");
                    can_sb_bulk_stkTrQry.Append(",'" + srm_date + "');");
                    db.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                }
            }

            string saveToSalesReturnItemsasBatch = batch_insert_items_header + batch_insert_items;
            bool batch_result = db.ExecuteQueryForTransaction(saveToSalesReturnItemsasBatch);



            if (batch_result)
            {
                // updating sales return master
                string update_sales_return = "UPDATE tbl_salesreturn_master SET srm_amount='" + srm_amount + "' where srm_id='" + srm_id + "'";
                bool sm_result = db.ExecuteQueryForTransaction(update_sales_return);

                //inserts to transaction table
                //inserting order credit entry
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`session_id`,`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`closing_balance`)" +
                    " select @session_id,@action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                cmdInsCr.Parameters.AddWithValue("@session_id", return_order["session_id"]);
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES_RETURN);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", srm_id);
                cmdInsCr.Parameters.AddWithValue("@partner_id", return_order["cust_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", return_order["branchid"]);
                cmdInsCr.Parameters.AddWithValue("@user_id", return_order["user_id"]);
                cmdInsCr.Parameters.AddWithValue("@narration", "Return of items worth " + srm_amount);
                cmdInsCr.Parameters.AddWithValue("@cr", srm_amount);
                cmdInsCr.Parameters.AddWithValue("@date", srm_date);
                db.ExecuteQueryForTransaction(cmdInsCr);

                string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + srm_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions  where partner_id='" + return_order["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + return_order["cust_id"] + "; SELECT cust_amount FROM tbl_customer WHERE cust_id=" + return_order["cust_id"];
                new_balance = db.SelectScalarForTransaction(update_tbl_customer);
                result = "SUCCESS";

            }
            else
            {
                result = "FAILED";
                db.RollBackTransaction();
                return result;
            }

            db.CommitTransaction();
            result = "SUCCESS";
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                // result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                LogClass log = new LogClass("sales_return");
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
    public static string getBrands()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select brand_id,brand_name from tbl_item_brand";
     
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    [WebMethod]
    public static string getCategories()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select cat_id,cat_name from tbl_item_category";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }
}