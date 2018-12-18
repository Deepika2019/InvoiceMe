using commonfunction;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Web.Script.Services;
using MySql.Data.MySqlClient;
using System.Net.Mail;
using System.Net;
using System.Collections;

public partial class sales_editorder : System.Web.UI.Page
{
    mySqlConnection db=new mySqlConnection();
    public string settings;
    protected void Page_Load(object sender, EventArgs e)
    {
        // Check Page Permission
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(10);
        getSystemSettingsData();
    }

    /// <summary>
    /// method to get system settings and set it in javascript object
    /// </summary>
    public void getSystemSettingsData()
    {
        string qry = "select ss_decimal_accuracy from tbl_system_settings";
        DataTable dtSetings = db.SelectQuery(qry);
        settings = JsonConvert.SerializeObject(dtSetings, Formatting.Indented);
    }
    //Start: show  Bill Details...
    [WebMethod]
    public static string selectOrders(string billno)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtItems = new DataTable();
        DataTable dtOrder = new DataTable();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string selectvar2 = "";
        string bal_wal_qry = "";
        string qry = "";
        selectvar2 = selectvar2 + " row_no, itbs_id,itm_code,";
        selectvar2 = selectvar2 + " itm_name , si_qty, si_org_price,si_price, si_discount_rate, si_discount_amount, si_net_amount,si_foc,si_tax_excluded_total,si_tax_amount,si_item_cess,si_item_tax,si_total,si_itm_type,itm_type ";
        qry = "select " + selectvar2 + " from tbl_sales_items where sm_id='" + billno + "' and si_itm_type!=2 order by row_no";
        dtItems = db.SelectQuery(qry);
        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
        sb.Append(",");
        string previouspaidqry = "select tsm.cust_id,tc.cust_name,tsm.branch_id,sm_netamount as total_amount,sm_refno,sm_delivery_status as order_status,DATE_FORMAT(sm_processed_date,'%d-%b-%Y') AS date,DATE_FORMAT(sm_processed_date,'%d-%m-%Y %h:%i %p') AS processedDate,sm_specialnote,cust_amount as outstanding_amt,concat(tu.first_name,\" \",tu.last_name) as approver_name,cust_type,sm_total,sm_discount_rate,sm_discount_amount,sm_tax_excluded_amt,sm_tax_amount,branch_tax_method,branch_tax_inclusive,sm_invoice_no as invoiceNum,DATE_FORMAT(sm_last_updated_date, '%Y-%m-%d %H:%i:%s') as lastUpdatedDate from tbl_sales_master tsm inner join tbl_customer tc on tc.cust_id=tsm.cust_id left join tbl_user_details tu on tu.user_id=tsm.sm_approved_id  where sm_id='" + billno + "' ";
        dtOrder = db.SelectQuery(previouspaidqry);
        sb.Append("\"order\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
        String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
           + " cheque_bank,DATE_FORMAT(`cheque_date`, '%d-%b-%Y %h:%i %p') as cheque_date,wallet_amt,dr,cr,is_reconciliation from tbl_transactions tr "
           + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
           + " where action_ref_id='" + billno + "' and action_type=" + (int)Constants.ActionType.SALES;
        DataTable dtPay = db.SelectQuery(paymentQry);
        sb.Append(",");
        sb.Append("\"payments\":");
        sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }
    //Stop: Show Details of Selected  Bill...

    //start: Item Pos Search Details
    [WebMethod]
    public static string searchOrderitem(int page, Dictionary<string, string> filters, int perpage, int customertype, string cust_id)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 and itbs_available = 1";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("warehouse"))
                {
                    query_condition += " and branch_id ='" + filters["warehouse"] + "'";
                }
                if (filters.ContainsKey("itemname"))
                {
                    query_condition += " and tis.itm_name  LIKE '%" + filters["itemname"] + "%'";
                }
                if (filters.ContainsKey("itemcode"))
                {
                    query_condition += " and tis.itm_code  LIKE '" + filters["itemcode"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
  
            countQry = "SELECT count(*) FROM tbl_itembranch_stock tis " + query_condition;


            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT itbs_id,tis.itm_id,itbs_stock,itbs_reorder,tis.itm_code,tis.itm_name,tis.itm_brand_id,tis.itm_category_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,tib.brand_name,tic.cat_name,tp_tax_percentage,tp_cess,itm_type from tbl_itembranch_stock tis inner join tbl_item_master im on im.itm_id=tis.itm_id left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id inner join tbl_tax_profile tp on tp.tp_tax_code=tis.tp_tax_code";
            innerqry = innerqry + query_condition + "";
            innerqry = innerqry + " order by itbs_id LIMIT " + offset.ToString() + " ," + per_page;
            DataTable dt = db.SelectQuery(innerqry);
            string jsonResponse = "";
            if (dt.Rows.Count > 0)
            {
                string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
                jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";
            }
            else
            {
                jsonResponse = "N";
            }
            return jsonResponse;

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }
    //stop: Item Pos Search Details

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteData(string variable, string BranchId)
    {

        List<string> itemNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string sqlQuery = "select itm_id,itm_name from tbl_itembranch_stock tis left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id where itm_name like '%" + variable + "%' and branch_id='" + BranchId + "' and itbs_stock>0 ";
        DataTable dt = db.SelectQuery(sqlQuery);
        if (dt.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["itm_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["itm_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["itm_name"]) + "\"}");

                //sb.Append("'name':'" + Convert.ToString(row["cust_name"]) + "'}");
                sb.Append(",");
            }
            sb.Remove(sb.Length - 1, 1);
            sb.Append("]");
        }
        else
        {
            sb.Append("N");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();
    }

    [WebMethod(EnableSession = true)]
    public static string GetAutoOfferItem(string variable, string BranchId, string TimeZone)
    {

        List<string> itemNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(TimeZone);
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string currdatetime = TimeNow.ToString("yyyy-MM-dd");
        string sqlQuery = "select ofr_id,ofr_title from tbl_offer_master where ofr_title like '" + variable + "%' and branch_id='" + BranchId + "' and DATE_FORMAT(ofr_start_date,'%Y-%m-%d') <= '" + currdatetime + "' and DATE_FORMAT(ofr_end_date,'%Y-%m-%d') >= '" + currdatetime + "' and ofr_status=0";
        DataTable dt = db.SelectQuery(sqlQuery);
        if (dt.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["ofr_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["ofr_title"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["ofr_title"]) + "\"}");
                //sb.Append("'name':'" + Convert.ToString(row["cust_name"]) + "'}");
                sb.Append(",");
            }
            sb.Remove(sb.Length - 1, 1);
            sb.Append("]");
        }
        else
        {
            sb.Append("N");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();
    }

    [WebMethod]
    public static string SearchItem(string searchName, string BranchId, string type, string cust_id)
    {
        mySqlConnection db = new mySqlConnection();
        string itemQry = "";
       
        if (type == "0")
        {
            itemQry = "SELECT itbs_id,tis.itm_id,itbs_stock,itbs_reorder,tis.itm_code,tis.itm_name,tis.itm_brand_id,tis.itm_category_id,itm_mrp,itm_class_one,itm_class_two,itm_type,itm_class_three,tib.brand_name,tic.cat_name,tp_tax_percentage,tp_cess from tbl_itembranch_stock tis inner join tbl_item_master im on im.itm_id=tis.itm_id left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id inner join tbl_tax_profile tp on tp.tp_tax_code=tis.tp_tax_code where tis.itm_name = '" + searchName + "' and branch_id= '" + BranchId + "'";

        }
        else if (type == "1")
        {
            itemQry = "SELECT ofr_id,ofr_type,ofr_title,ofr_code,ofr_totalprice,ofr_price,ofr_discount,ofr_focqty,ofr_focnum from tbl_offer_master where ofr_title = '" + searchName + "' and branch_id= '" + BranchId + "'";
        }
        DataTable dt = db.SelectQuery(itemQry);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }

    [WebMethod]
    public static string updateOrderStatus(string userid, string ordid, string status, string TimeZone, string assignId, string sm_delivery_vehicle_id, string sm_vehicle_no, string ownVehicleUsed)
    {
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(TimeZone);
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string processDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        string ret = "";
        string insQry = "";

        mySqlConnection db = new mySqlConnection();
        db.BeginTransaction();

        // check for already canceled
        string checkAlreadyCancelled = "SELECT sm_delivery_status from tbl_sales_master where sm_id='" + ordid + "'";
        string status_result = db.SelectScalarForTransaction(checkAlreadyCancelled);
        if (status == "0")
        {

            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "' where sm_refno='" + ordid + "'";

        }
        if (status == "1")
        {
            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "',sm_delivered_id='" + assignId + "',sm_processed_id='" + userid + "',sm_processed_date='" + processDate + "',sm_delivery_vehicle_id='" + sm_delivery_vehicle_id + "',sm_vehicle_no='" + sm_vehicle_no + "',sm_packed='1',sm_packed_date='" + processDate + "' where sm_refno='" + ordid + "'";
            //  insQry = "UPDATE tbl_sales_master SET sm_processed_id='" + userid + "' ,sm_delivery_status='" + status + "',sm_processed_date='" + processDate + "',sm_delivered_id="+assignId+" where sm_refno='" + ordid + "'";

        }
        if (status == "2")
        {

            insQry = "UPDATE tbl_sales_master SET sm_delivered_id='" + userid + "' ,sm_delivery_status='" + status + "',sm_delivered_date='" + processDate + "' where sm_refno='" + ordid + "'";

        }

        if (status == "4")
        {

            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "',sm_cancelled_id='" + userid + "',sm_cancelled_date='" + processDate + "' where sm_refno='" + ordid + "'";

        }
        if (status == "5")
        {
            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "' , sm_approved_id='" + userid + "',sm_approved_date='" + processDate + "' where sm_refno='" + ordid + "'";
        }
        if (status == "6")
        {
            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "' where sm_refno='" + ordid + "'";
        }
        if (status == "7")
        {
            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='0' , sm_approved_id='" + userid + "',sm_approved_date='" + processDate + "' where sm_refno='" + ordid + "'";
        }
        if (status == "3")
        {

            insQry = "UPDATE tbl_sales_master SET sm_delivery_status='" + status + "' where sm_refno='" + ordid + "'";

        }
        db.ExecuteQueryForTransaction(insQry);

        if (status == "4" || status == "5") // ACTIONS FOR CANCELLATION
        {
            try
            {
                // removing old items // reducing stock

                string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_name from tbl_sales_items where sm_id='" + ordid + "' and ( si_itm_type='0' or si_itm_type='2')";
                DataTable dt = db.SelectQueryForTransaction(qry);
                int numrows = dt.Rows.Count;

                Int32 oldqty = 0;
                Int32 oldfoc = 0;
                Int32 oldtotoalqty = 0;
                string olditbs = "";

                string itbsidString = "";
                string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                
                StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`,`is_reconciliation`) VALUES ");
                foreach (DataRow row in dt.Rows)
                {
                    oldqty = Convert.ToInt32(row["si_qty"]);
                    oldfoc = Convert.ToInt32(row["si_foc"]);
                    oldtotoalqty = oldfoc + oldqty;
                    olditbs = Convert.ToString(row["itbs_id"]);
                    itbsidString = itbsidString + "," + olditbs;
                    oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";
                    // code to record stock transaction by vishnu
                    sb_bulk_stkTrQry.Append("('" + olditbs + "','" + ((int)Constants.ActionType.SALES) + "','" + ordid + "','" + userid + "'");
                    sb_bulk_stkTrQry.Append(",'Crediting " + row["itm_name"] + " of quantity " + oldtotoalqty + " back on cancel/rejection of order #" + ordid + "','" + oldtotoalqty + "'");
                    sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                    sb_bulk_stkTrQry.Append(",'" + processDate + "','1'),");

                    // code to record stock transaction end
                }
                itbsidString = itbsidString.Trim().TrimStart(',');
                oldupstockQry += " ELSE itbs_stock END  WHERE itbs_id IN (" + itbsidString + ")";
                bool oldupstockresult = db.ExecuteQueryForTransaction(oldupstockQry);

                // bulk insert stock transactions
                sb_bulk_stkTrQry.Length--;
                db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());

                string custid = "";

                double totpaidamt = 0.00;
                double sm_balance = 0.00;
                // getting old values

                string locqry = "select tbl_sales_master.sm_netamount,tbl_sales_master.total_paid,tbl_sales_master.total_balance,tbl_sales_master.cust_id,tbl_customer.cust_amount,tbl_customer.cust_wallet_amt from tbl_sales_master join tbl_customer on tbl_customer.cust_id=tbl_sales_master.cust_id  where sm_refno='" + ordid + "' and sm_parent='1'";
                DataTable dtloc = db.SelectQueryForTransaction(locqry);
                int locrows = dtloc.Rows.Count;


                if (locrows == 0)
                {
                    // if no row exists
                }
                else
                {
                    foreach (DataRow row in dtloc.Rows)
                    {

                        custid = row["cust_id"].ToString();
                        sm_balance = Convert.ToDouble(row["total_balance"].ToString());
                        totpaidamt = Convert.ToDouble(row["total_paid"].ToString());

                    }

                }
               
                string wallupdate = "UPDATE tbl_customer SET cust_last_updated_date='" + processDate + "',cust_amount=(cust_amount-'" + sm_balance + "'),cust_wallet_amt=(cust_wallet_amt + '" + totpaidamt + "') where cust_id='" + custid + "'";
                bool wallresult = db.ExecuteQueryForTransaction(wallupdate);
                ret = "Y";

            }
            catch (Exception ex)
            {
                try // IF TRANSACTION FAILES
                {

                    db.RollBackTransaction();
                    LogClass log = new LogClass("neworder");
                    log.write(ex);
                    ret = "N";

                }
                catch
                {
                }
            }

        }


        if (status_result == "4" || status_result == "5") // ACTIONS IF BACK FROM CANCELLED TO NEW / TO BE CONFIRMED
        {
            if (status == "3" || status == "0")
            {
                try
                {
                    // removing old items // reducing stock
                    // db.BeginTransaction();
                    string qry = "select itbs_id,si_qty,si_foc,si_itm_type from tbl_sales_items where sm_id='" + ordid + "' and ( si_itm_type='0' or si_itm_type='2')";
                    DataTable dt = db.SelectQueryForTransaction(qry);
                    int numrows = dt.Rows.Count;

                    Int32 oldqty = 0;
                    Int32 oldfoc = 0;
                    Int32 oldtotoalqty = 0;
                    string olditbs = "";

                    string itbsidString = "";
                    string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                    foreach (DataRow row in dt.Rows)
                    {
                        oldqty = Convert.ToInt32(row["si_qty"]);
                        oldfoc = Convert.ToInt32(row["si_foc"]);
                        oldtotoalqty = oldfoc + oldqty;
                        olditbs = Convert.ToString(row["itbs_id"]);
                        itbsidString = itbsidString + "," + olditbs;
                        oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock - " + oldtotoalqty + "";
                    }
                    itbsidString = itbsidString.Trim().TrimStart(',');
                    oldupstockQry += " ELSE itbs_stock END  WHERE itbs_id IN (" + itbsidString + ")";
                    bool oldupstockresult = db.ExecuteQueryForTransaction(oldupstockQry);

                    string custid = "";
                    double totpaidamt = 0.00;
                    double sm_netamount = 0.00;
                    // getting old values

                    string locqry = "select tbl_sales_master.sm_netamount,tbl_sales_master.total_paid,tbl_sales_master.total_balance,tbl_sales_master.cust_id,tbl_customer.cust_amount,tbl_customer.cust_wallet_amt from tbl_sales_master join tbl_customer on tbl_customer.cust_id=tbl_sales_master.cust_id  where sm_refno='" + ordid + "' and sm_parent='1'";
                    DataTable dtloc = db.SelectQueryForTransaction(locqry);
                    int locrows = dtloc.Rows.Count;


                    if (locrows == 0)
                    {
                        // if no row exists
                    }
                    else
                    {
                        foreach (DataRow row in dtloc.Rows)
                        {

                            custid = row["cust_id"].ToString();
                            sm_netamount = Convert.ToDouble(row["sm_netamount"].ToString());
                            totpaidamt = Convert.ToDouble(row["total_paid"].ToString());

                        }

                    }

                    // RESET PAYMENTS

                    string sm_salesmaster = "UPDATE tbl_sales_master SET tbl_sales_master.sm_paid=0.00,tbl_sales_master.sm_balance=0.00,tbl_sales_master.sm_bank=' ',tbl_sales_master.sm_chq_no=0,tbl_sales_master.sm_chq_date=0,tbl_sales_master.sm_wallet_amt=0,tbl_sales_master.sm_chq_amt=0,tbl_sales_master.sm_cash_amt=0,tbl_sales_master.sm_processed_id=0,tbl_sales_master.sm_delivered_id=0,tbl_sales_master.sm_delivered_date=0,tbl_sales_master.sm_delivery_vehicle_id=0,tbl_sales_master.sm_vehicle_no=0,tbl_sales_master.total_paid=0,tbl_sales_master.sm_packed=0,tbl_sales_master.sm_packed_id=0,tbl_sales_master.sm_packed_date=0,tbl_sales_master.sm_balance=tbl_sales_master.sm_netamount,tbl_sales_master.total_balance=tbl_sales_master.sm_netamount where tbl_sales_master.sm_id='" + ordid + "'";
                    db.ExecuteQueryForTransaction(sm_salesmaster);

                    string sm_delete_outstanding = "DELETE FROM tbl_sales_master WHERE sm_refno='" + ordid + "' and sm_parent=0";
                    db.ExecuteQueryForTransaction(sm_delete_outstanding);


                

                    string wallupdate = "UPDATE tbl_customer SET cust_last_updated_date='" + processDate + "', cust_amount=(cust_amount+'" + sm_netamount + "') where cust_id='" + custid + "'";
                    bool wallresult = db.ExecuteQueryForTransaction(wallupdate);
                    ret = "Y";

                }
                catch (Exception ex)
                {
                    try // IF TRANSACTION FAILES
                    {

                        db.RollBackTransaction();
                        LogClass log = new LogClass("neworder");
                        log.write(ex);
                        ret = "N";

                    }
                    catch
                    {
                    }
                }

            }
        }
        db.CommitTransaction();
        return ret;
    }

    [WebMethod]// branches show
    public static string loadBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
       // string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        string query = "select branch_id,branch_name from tbl_branch";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// users show
    public static string loadAssignPersons(string warehouse)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select user_id,concat(first_name,\" \",last_name) as name from tbl_user_details where user_type IN ('2','3')";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    //edit order
    [WebMethod]
    public static string editOrder(Dictionary<string, string> editedorder)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            // removing old items // reducing stock
            db.BeginTransaction();
            // FOR SALES_MASTER

            double sm_discount_rate = 0;
            double sm_discount_amount = 0;
            double sm_netamount = 0;
            double sm_total = 0;
            double sm_tax_excluded_amt = 0;
            double sm_tax_amount = 0;
            Int32 sm_delivery_status = Convert.ToInt32(editedorder["sm_delivery_status"]);
            string processedDateTime = editedorder["processedDate"] + " " + editedorder["processedTime"];
            // FOR SALES ITEMS
            string itm_code = "";
            string itm_name = "";
            double si_org_price;
            double si_total;
            double si_discount_amount;
            double si_net_amount;
            double itm_commision;
            double itm_commisionamt = 0;
            double si_item_tax;
            double si_item_cgst = 0, si_item_sgst = 0, si_item_igst = 0, si_item_utgst = 0;
            double si_item_cess;
            double si_tax_amount;

            // getting branch tax methods

            Int32 branch_id;
            Int32 branch_tax_method;
            Int32 branch_tax_inclusive;
            string branch_timezone = "";
            string cust_id = "";
            double old_netamount = 0.00;
            string oldorderstatus;
            string customer = "";
            string invoiceNo = "";
            string checkEntryChanged = "select count(sm_id) from tbl_sales_master where sm_last_updated_date=DATE_FORMAT('" + editedorder["lastUpdatedDate"] + "','%Y-%m-%d %H:%i:%s') and sm_id=" + editedorder["sm_id"];
            int changeCount = Convert.ToInt32(db.SelectScalarForTransaction(checkEntryChanged));
            if (changeCount == 0)
            {
                return "E";
            }
            //string branchQry = "select sm.branch_id,sm.cust_id,sm.total_balance,sm.sm_delivery_status,br.branch_tax_method,br.branch_tax_inclusive,br.branch_timezone from tbl_branch br join tbl_sales_master sm on sm.branch_id=br.branch_id where sm.sm_id='" + editedorder["sm_id"] + "' and sm.sm_parent='1'";
            string branchQry = "select sm.branch_id,sm.cust_id,tc.cust_name,sm_invoice_no,sm.sm_netamount,sm.sm_delivery_status,br.branch_tax_method,br.branch_tax_inclusive,br.branch_timezone from tbl_branch br join tbl_sales_master sm on sm.branch_id=br.branch_id join tbl_customer tc on tc.cust_id=sm.cust_id where sm.sm_id='" + editedorder["sm_id"] + "'";
            DataTable dt_branchDetail = db.SelectQueryForTransaction(branchQry);
            if (dt_branchDetail != null)
            {
                branch_id = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_id"]);
                branch_tax_method = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_tax_method"]);
                branch_tax_inclusive = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_tax_inclusive"]);
                cust_id = Convert.ToString(dt_branchDetail.Rows[0]["cust_id"]);
                old_netamount = Convert.ToDouble(dt_branchDetail.Rows[0]["sm_netamount"]);
                oldorderstatus = Convert.ToString(dt_branchDetail.Rows[0]["sm_delivery_status"]);
                branch_timezone = Convert.ToString(dt_branchDetail.Rows[0]["branch_timezone"]);
                customer = Convert.ToString(dt_branchDetail.Rows[0]["cust_name"]);
                invoiceNo = Convert.ToString(dt_branchDetail.Rows[0]["sm_invoice_no"]);
            }
            else
            {
                result = "FAILED";
                return result;
            }


            List<Dictionary<string, string>> items_after_edit = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(editedorder["items_after_edit"]);
            dynamic order_data = JsonConvert.DeserializeObject(editedorder["items_after_edit"]);

            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string edited_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_name,itm_type from tbl_sales_items where sm_id='" + editedorder["sm_id"] + "' and ( si_itm_type='0' or si_itm_type='2')";
            DataTable itemsBefrEditDt = db.SelectQueryForTransaction(qry);
            int numrows = itemsBefrEditDt.Rows.Count;

            Int32 oldqty = 0;
            Int32 oldfoc = 0;
            Int32 oldtotoalqty = 0;
            string olditbs = "";
            //start changed by deepika for bulk updation
            string itbsidString = "";
            string itbsidStockString = "";
            string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";

            foreach (DataRow row in itemsBefrEditDt.Rows)
            {
                oldqty = Convert.ToInt32(row["si_qty"]);
                oldfoc = Convert.ToInt32(row["si_foc"]);
                oldtotoalqty = oldfoc + oldqty;
                olditbs = Convert.ToString(row["itbs_id"]);
                itbsidString = itbsidString + "," + olditbs;
               
                oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";
                
            }
            itbsidString = itbsidString.Trim().TrimStart(',');
            oldupstockQry += " ELSE itbs_stock END,itm_last_update_date='" + edited_date + "'  WHERE itbs_id IN (" + itbsidString + ")";
            bool oldupstockresult = db.ExecuteQueryForTransaction(oldupstockQry);
            //end changed by deepika for bulk updation
            string delQry = "DELETE from tbl_sales_items  WHERE sm_id='" + editedorder["sm_id"] + "'";
            bool dresult = db.ExecuteQueryForTransaction(delQry);
            DataTable pkgDt = db.SelectQueryForTransaction("select package_id from tbl_customer_packages where sm_id=" + editedorder["sm_id"]);
            string delPackgQry = "DELETE from tbl_customer_packages  WHERE sm_id='" + editedorder["sm_id"] + "'";
            bool dPkgresult = db.ExecuteQueryForTransaction(delPackgQry);

            if (dPkgresult)
            {
                foreach(DataRow pkg in pkgDt.Rows)
                {
                    db.ExecuteQueryForTransaction("DELETE from tbl_redeem_history  WHERE package_id='" + pkg["package_id"].ToString() + "'");
                }
               
            }
    

            Int32 cust_state = 0;

            double realtotal = 0;
            double nettotal = 0;
            double discount_amt = 0;
            double tax_amount = 0;
            double commisionAmount = 0;
            double tax_included_nettotal = 0;
            double cessAmount = 0;

            double si_qty = 0;
            double si_price = 0;
            double si_foc = 0;
            double si_discount_rate = 0;
            int itm_type = 0;
            int itemId = 0;
            // checking weather its IGST

            string igst_qry = "Select tbl_branch.branch_state_id from tbl_branch join tbl_customer on tbl_branch.branch_state_id=tbl_customer.cust_state where tbl_branch.branch_id='" + branch_id + "' and tbl_customer.cust_id='" + cust_id + "'";
            DataTable igst_dt = db.SelectQueryForTransaction(igst_qry);
            int br_rows = igst_dt.Rows.Count;

            if (br_rows == 0)
            {
                cust_state = 1;
            }
            else
            {
                cust_state = 0;
            }



            // PROCESSING ITEMS
            Int32 row_no = 0;
            //start changed by deepika
            // fetch item details from item_branch_stock and tbl_tax_profile
            string insert_to_sales_items = "INSERT INTO tbl_sales_items(sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_item_tax,si_item_cgst,si_item_sgst,si_item_igst,si_item_utgst,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type) VALUES";
            DataTable dt_itemDetail = new DataTable();
            foreach (var items in order_data)
            {
                if (items.si_itm_type != 4)
                {
                    itbsidStockString = itbsidStockString + "," + items.itbs_id;
                }
            }

            itbsidStockString = itbsidStockString.Trim().TrimStart(',');
            if (itbsidString != "")
            {
                string item_fetch_qry = "select itb.itm_id,itm_type,itb.itbs_id,tax.tp_tax_percentage,tax.tp_cess,itb.itm_name,itb.itm_code,itb.itm_commision from tbl_itembranch_stock itb inner join tbl_item_master tim on tim.itm_id=itb.itm_id join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code where itb.itbs_id in (" + itbsidStockString + ")  ORDER BY FIELD(itb.itbs_id, " + itbsidStockString + ")"; 
                dt_itemDetail = db.SelectQueryForTransaction(item_fetch_qry);
            }
           
            int size = items_after_edit.Count;
            int j = 0;
            for (int i = 0; i < size; i++)
            {// BASE VALUES
                si_qty = order_data[i].si_qty;
                si_price = order_data[i].si_price;
                si_foc = order_data[i].si_foc;
                si_discount_rate = order_data[i].si_discount_rate;
                si_org_price = order_data[i].si_org_price;
                itm_commision = Convert.ToDouble(dt_itemDetail.Rows[i]["itm_commision"]);
                si_item_tax = Convert.ToDouble(dt_itemDetail.Rows[i]["tp_tax_percentage"]);
                si_item_cess = Convert.ToDouble(dt_itemDetail.Rows[i]["tp_cess"]);
                itm_name = Convert.ToString(dt_itemDetail.Rows[i]["itm_name"]);
                itm_code = Convert.ToString(dt_itemDetail.Rows[i]["itm_code"]);
                itm_type = Convert.ToInt32(dt_itemDetail.Rows[i]["itm_type"]);
                itemId = Convert.ToInt32(dt_itemDetail.Rows[i]["itm_id"]);
                // CALCULATIONS
                if (branch_tax_method == 0) // no tax
                {
                    realtotal = si_price * si_qty; // price without discount
                    realtotal = Math.Round(realtotal, 2);
                    discount_amt = ((realtotal * si_discount_rate) / 100);
                    nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                    tax_included_nettotal = Math.Round(nettotal, 2);
                    commisionAmount = ((nettotal * itm_commision) / 100);
                    commisionAmount = Math.Round(commisionAmount, 2);
                    tax_amount = 0; // not tax used
                    cessAmount = 0;

                }
                else if (branch_tax_method == 1) // VAT CALCULATION
                {
                    if (branch_tax_inclusive == 1)  // tax is included with the price
                    {
                        if (si_item_cess > 0)
                        {
                            double denominator = 10000 * si_price;
                            double baseval = 10000 + (100 * si_item_tax) + (si_item_tax * si_item_cess);
                            si_price = denominator / baseval;
                        }
                        else
                        {
                            double constant = (si_item_tax / 100) + 1; // equation for the dividing constant
                            si_price = si_price / constant;
                        }

                    }

                    realtotal = si_price * si_qty; // price without discount
                    discount_amt = ((realtotal * si_discount_rate) / 100);
                    nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                    commisionAmount = ((nettotal * itm_commision) / 100);
                    tax_amount = ((nettotal * si_item_tax) / 100);
                    cessAmount = ((tax_amount * si_item_cess) / 100);
                    tax_amount = cessAmount + tax_amount;
                    tax_included_nettotal = nettotal + tax_amount;

                    // VAT ENDS
                }
                else if (branch_tax_method == 2) // GST CALCULATION
                {
                    if (branch_tax_inclusive == 1)  // tax is included with the price
                    {
                        if (si_item_cess > 0)
                        {
                            double denominator = 10000 * si_price;
                            double baseval = 10000 + (100 * si_item_tax) + (si_item_tax * si_item_cess);
                            si_price = denominator / baseval;
                        }
                        else
                        {
                            double constant = (si_item_tax / 100) + 1; // equation for the dividing constant
                            si_price = si_price / constant;
                            si_item_cess = 0;

                        }
                    }

                    realtotal = si_price * si_qty; // price without discount
                    discount_amt = ((realtotal * si_discount_rate) / 100);
                    nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                    commisionAmount = ((nettotal * itm_commision) / 100);
                    tax_amount = ((nettotal * si_item_tax) / 100);
                    cessAmount = ((tax_amount * si_item_cess) / 100);
                    tax_amount = cessAmount + tax_amount;
                    tax_included_nettotal = nettotal + tax_amount;

                    // CHECKING CUSTOMER STATE FOR IGST - DETERINATION

                    if (cust_state == 0)
                    { // default state , No IGST

                        double splitted_GST_rate = si_item_tax / 2;
                        splitted_GST_rate = Math.Round(splitted_GST_rate, 2);

                        si_item_cgst = splitted_GST_rate;
                        si_item_sgst = splitted_GST_rate;
                        si_item_igst = 0;
                        si_item_utgst = 0;
                    }
                    else
                    { // IGST PRESENT

                        si_item_cgst = 0;
                        si_item_sgst = 0;
                        si_item_igst = si_item_tax;
                        si_item_utgst = 0;

                    }
                    // GST CALCULATION ENDS
                }


                else
                {
                    // if null
                    result = "FAILED";
                    return result;
                }

                si_total = realtotal;
                si_discount_amount = discount_amt;
                si_net_amount = tax_included_nettotal;
                itm_commisionamt = commisionAmount;
                si_tax_amount = tax_amount;

                // INSERTING INTO TBL_SALES_ITEMS

                if (order_data[i].si_itm_type == 0)
                { // inserting normal items

                    insert_to_sales_items += " (" + "'" + editedorder["sm_id"] + "','" + row_no + "', '" + order_data[i].itbs_id + "', '" + itm_code + "', '" + itm_name + "', '0', '" + si_org_price + "', '" + order_data[i].si_price + "', '" + si_qty + "', '" + si_total + "', '" + si_discount_rate + "', '" + si_discount_amount + "', '" + si_net_amount + "', '" + si_foc + "', '" + order_data[i].si_approval_status + "', '" + itm_commision + "', '" + itm_commisionamt + "', '0', '0','" + order_data[i].si_itm_type + "', '" + si_item_tax + "', '" + si_item_cgst + "', '" + si_item_sgst + "', '" + si_item_igst + "', '" + si_item_utgst + "', '" + si_item_cess + "', '" + (si_net_amount - tax_amount) + "', '" + tax_amount + "',"+itm_type+"),";

                }

                row_no++;

                // calculation for sm - values

                sm_tax_excluded_amt = sm_tax_excluded_amt + (si_net_amount - si_tax_amount);
                sm_discount_amount = sm_discount_amount + si_discount_amount;
                sm_netamount = sm_netamount + si_net_amount;
                sm_tax_amount = sm_tax_amount + si_tax_amount;
                sm_total = sm_total + si_total;

                // HANDLE STOCK
                if (order_data[i].si_itm_type != "1" && order_data[i].si_itm_type != "3" && order_data[i].si_itm_type != "4")
                {

                    Int32 item_total_qty = Convert.ToInt32(si_foc) + Convert.ToInt32(si_qty);

                    string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock - " + item_total_qty + ") where itbs_id='" + order_data[i].itbs_id + "'";
                    bool upstockresult = db.ExecuteQueryForTransaction(upstockQry);
                    
                }

                if (itm_type == 3)
                {
                    DataTable couponDt = db.SelectQueryForTransaction("select cpn_qty from tbl_coupon_master where cpn_itm_id=" + itemId);
                    double totalQty = Convert.ToDouble(couponDt.Rows[0]["cpn_qty"]) * si_qty;
                    db.ExecuteQueryForTransaction("insert into tbl_customer_packages (cust_id,sm_id,itbs_id,package_total_count,package_current_count,package_date) values(" + editedorder["cust_id"] + "," + editedorder["sm_id"] + "," + order_data[i].itbs_id + "," + totalQty + "," + totalQty + ",'" + edited_date + "')");
                }


            }  // ITEM for LOOP ENDS

            insert_to_sales_items = insert_to_sales_items.Remove(insert_to_sales_items.Trim().Length - 1);
            bool InsertItemresult = db.ExecuteQueryForTransaction(insert_to_sales_items);
            //end changed by deepika
            int itmType = 0;
            //start stock transaction update
            StringBuilder sb_bulk_stkTrQry = new StringBuilder();
            StringBuilder sb_bulk_items = new StringBuilder();
            sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`cr_qty`,`closing_stock`,`date`,`is_reconciliation`) VALUES ");
            foreach (DataRow row in itemsBefrEditDt.Rows)
            {
                

                oldqty = Convert.ToInt32(row["si_qty"]);
                oldfoc = Convert.ToInt32(row["si_foc"]);
                oldtotoalqty = oldfoc + oldqty;
                olditbs = Convert.ToString(row["itbs_id"]);
                itmType = Convert.ToInt32(row["itm_type"]);
                dynamic itemAftrEdit = ((IEnumerable)order_data).Cast<dynamic>().Where(a => a.itbs_id == olditbs).SingleOrDefault();
                //checking if item deleted
                if (itemAftrEdit == null)
                {
                    if (itmType == 1)
                    {
                        //crediting if deleted
                        sb_bulk_items.Append("('" + olditbs + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                        sb_bulk_items.Append(",'Crediting " + row["itm_name"] + " of quantity " + oldtotoalqty + " back on delete from order #" + editedorder["sm_id"] + "','0','" + oldtotoalqty + "'");
                        sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                        sb_bulk_items.Append(",'" + edited_date + "','1'),");
                    }
                    
                }
                else
                {
                    //recording change in quantity
                    int newTotalQty = Convert.ToInt32(itemAftrEdit.si_qty) + Convert.ToInt32(itemAftrEdit.si_foc);
                   
                    if (oldtotoalqty > newTotalQty)
                    {
                        if (itmType == 1)
                        {
                            sb_bulk_items.Append("('" + olditbs + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                            sb_bulk_items.Append(",'Crediting " + row["itm_name"] + " of quantity " + (oldtotoalqty - newTotalQty) + " back on edit of order #" + editedorder["sm_id"] + "','0','" + (oldtotoalqty - newTotalQty) + "'");
                            sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                            sb_bulk_items.Append(",'" + edited_date + "','1'),");
                        }
                    }
                    else if (oldtotoalqty < newTotalQty)
                    {
                        if (itmType == 1)
                        {
                            sb_bulk_items.Append("('" + olditbs + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                            sb_bulk_items.Append(",'Debiting " + row["itm_name"] + " of quantity " + (newTotalQty - oldtotoalqty) + " on edit of order #" + editedorder["sm_id"] + "','" + (newTotalQty - oldtotoalqty) + "','0'");
                            sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                            sb_bulk_items.Append(",'" + edited_date + "','1'),");
                        }
                    }
                    
                }
                

            }
            // crediting new items
            dynamic newItemsList = ((IEnumerable)order_data).Cast<dynamic>()
                .Where(a =>
                !itemsBefrEditDt.AsEnumerable().Any(b=>
                    b.Field<int>("itbs_id")==Convert.ToInt32(a.itbs_id))
                ).ToList();
            foreach (var item in newItemsList)
            {
                if (item.itm_type == 1)
                {
                    int newTotalQty = Convert.ToInt32(item.si_qty) + Convert.ToInt32(item.si_foc);
                    sb_bulk_items.Append("('" + item.itbs_id + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                    sb_bulk_items.Append(",CONCAT('Sold " + newTotalQty + "', (select itm_name from tbl_itembranch_stock where itbs_id='" + item.itbs_id + "'),' in order #" + editedorder["sm_id"] + "'),'" + newTotalQty + "','0'");
                    sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + item.itbs_id + "')");
                    sb_bulk_items.Append(",'" + edited_date + "','0'),");
                }
            }
            //end stock transaction update


            // bulk insert stock transactions
          
            if (sb_bulk_items.ToString() != "")
            {
                sb_bulk_items.Length--;
                sb_bulk_stkTrQry.Append(sb_bulk_items.ToString());
                db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
            }


            // UPDATING SALES MASTER

            string update_salesmaster_qry = "UPDATE tbl_sales_master SET sm_total='" + sm_total + "',sm_discount_rate='" + sm_discount_rate + "',sm_discount_amount='" + sm_discount_amount + "',sm_netamount='" + sm_netamount + "',sm_tax_excluded_amt='" + sm_tax_excluded_amt + "',sm_tax_amount='" + sm_tax_amount + "',	sm_specialnote='" + editedorder["specialNote"] + "',sm_processed_date='" + processedDateTime + "' ,sm_last_updated_date='" + editedorder["lastUpdatedDate"] + "' WHERE sm_id='" + editedorder["sm_id"] + "'";
            bool update_sales_result = db.ExecuteQueryForTransaction(update_salesmaster_qry);

      
            //start updation in transactions
            if (sm_netamount > old_netamount)
            {
                //inserting order debit entry
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`, `dr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";

                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", editedorder["sm_id"]);
                cmdInsDr.Parameters.AddWithValue("@partner_id", editedorder["cust_id"]);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", HttpContext.Current.Request.Cookies["invntrystaffBranchId"].Value);
                cmdInsDr.Parameters.AddWithValue("@user_id", editedorder["user_id"]);
                cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of Order #" + editedorder["sm_id"] + " after an edit by debiting the amount " + (sm_netamount - old_netamount));
                cmdInsDr.Parameters.AddWithValue("@dr", (sm_netamount-old_netamount));
                cmdInsDr.Parameters.AddWithValue("@date", edited_date);
                cmdInsDr.Parameters.AddWithValue("@is_reconciliation", "1");
                db.ExecuteQueryForTransaction(cmdInsDr);

            }else if(sm_netamount < old_netamount) {
                //inserting order credit entry
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";

                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", editedorder["sm_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_id", editedorder["cust_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", HttpContext.Current.Request.Cookies["invntrystaffBranchId"].Value);
                cmdInsCr.Parameters.AddWithValue("@user_id", editedorder["user_id"]);
                cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of Order #" + editedorder["sm_id"] + " after an edit by crediting the amount " + (old_netamount - sm_netamount));
                cmdInsCr.Parameters.AddWithValue("@cr", (old_netamount - sm_netamount));
                cmdInsCr.Parameters.AddWithValue("@date", edited_date);
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                db.ExecuteQueryForTransaction(cmdInsCr);
            }
            //end updation in transactions

            // UPDATING CUSTOMER DETAILS

            string update_cust_qry = "UPDATE tbl_customer SET cust_last_updated_date='" + edited_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + editedorder["cust_id"] + "') WHERE cust_id='" + editedorder["cust_id"] + "'";
            bool upcust_result = db.ExecuteQueryForTransaction(update_cust_qry);
            if (upcust_result)
            {
                db.ExecuteQueryForTransaction("update tbl_transactions set last_updated_date='" + edited_date + "' where action_type=1 and action_ref_id=" + editedorder["sm_id"] + "");
            }
            //Entering to EDIT HISTORY

            //***************************************** edit history

            if (editedorder["isEdited"] == "1")
            {
               

                List<Dictionary<string, string>> editedItems = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(editedorder["editedItems"]);
                dynamic edited_data = JsonConvert.DeserializeObject(editedorder["editedItems"]);

                foreach (var ed_items in edited_data)
                {
                    string IteminsQry = "INSERT INTO tbl_edit_history(sm_id,itbs_id,si_price,si_qty,si_discount_rate,si_net_amount,si_foc,new_si_price,new_si_qty,new_si_discount_rate,new_si_net_amount,new_si_foc,edit_action,edited_by,edited_date) VALUES ('" + editedorder["sm_id"] + "', '" + ed_items.itbs_id + "', '" + ed_items.si_price + "', '" + ed_items.si_qty + "', '" + ed_items.si_discount_rate + "', '" + ed_items.si_net_amount + "', '" + ed_items.si_foc + "', '" + ed_items.new_si_price + "', '" + ed_items.new_si_qty + "', '" + ed_items.new_si_discount_rate + "', '" + ed_items.new_si_net_amount + "', '" + ed_items.new_si_foc + "', '" + ed_items.edit_action + "', '" + ed_items.edited_by + "', '" + edited_date + "');";
                    bool Itemresult = db.ExecuteQueryForTransaction(IteminsQry);
                }
                DataTable emailSelectionDt = db.SelectQueryForTransaction("SELECT emailid FROM `tbl_user_details` WHERE user_type in (select distinct user_type from tbl_button_permission where ub_id IN (6,7,8,3,4,5))");
                string mailId = "";
                for (int i = 0; i < emailSelectionDt.Rows.Count; i++)
                {
                    if (emailSelectionDt.Rows[i]["emailid"] != null && emailSelectionDt.Rows[i]["emailid"] != "")
                    {
                        mailId += "," + emailSelectionDt.Rows[i]["emailid"];
                    }

                }
                mailId = mailId.Trim().TrimStart(',');
                //string str = mailSending(mailId, invoiceNo, customer, edited_date);
                //newid = "Y";
            }
            else
            {
                //newid = "N";
            }

            db.CommitTransaction();
            result = "SUCCESS";
            //result = "{\"result\":\"" + result + "\",\"new_netamount\":" + sm_netamount + ",\"new_custamount\":" + newcust_amount + "}";
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                LogClass log = new LogClass("neworder");
                log.write(ex);
                return result;
            }
            catch
            {
            }
        }
        return result;
    }

    #region
    //method for mail sending
    private static string mailSending(string email, string invoiceNo, string customer, string edited_date)
    {
        try
        {
            //Create the msg object to be sent
            MailMessage msg = new MailMessage();
            //Add your email address to the recipients
            msg.To.Add(email);
            //Configure the address we are sending the mail from
            MailAddress address = new MailAddress("mail@billcrm.com");
            msg.From = address;
            msg.Subject = "Order #" + invoiceNo + " of " + customer + " edited on " + edited_date;
            msg.Body = "Please check the edited order #" + invoiceNo + " of " + customer + " 'http://hn.billcrm.com/login.aspx'";

            SmtpClient client = new SmtpClient();
            client.Host = "relay-hosting.secureserver.net";
            client.Port = 25;


            //Setup credentials to login to our sender email address ("UserName", "Password")
            NetworkCredential credentials = new NetworkCredential("mail@billcrm.com", "b2426794");
            client.UseDefaultCredentials = true;
            client.Credentials = credentials;


            //Send the msg
            client.Send(msg);
            return "Y";
            //Display some feedback to the user to let them know it was sent
            // Response.Write("mail send");

        }
        catch (Exception ex)
        {
            LogClass log = new LogClass("Mailsending:neworder");
            log.write(ex);
            return "N";
            //Response.Write(ex.ToString());
            //If the message failed at some point, let the user know
            //lblResult.Text = ex.ToString(); //alt text "Your message failed to send, please try again."
        }
    }

    #endregion

    /// <summary>
    /// web service to save edit in a payment transaction
    /// </summary>
    /// <param name="trans_id">id of transaction </param>
    /// <param name="cash_amt">amount paid in cash</param>
    /// <param name="wallet_amt">amount paid from wallet</param>
    /// <param name="cheque_amt">amount paid in cheque</param>
    [WebMethod]
    public static string savePaymentEdit(int trans_id, double cash_amt, double cheque_amt, string lastUpdatedDate, int billNo)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {
            db.BeginTransaction();
            //getting date
            string checkEntryChanged = "select count(sm_id) from tbl_sales_master where sm_last_updated_date=DATE_FORMAT('" + lastUpdatedDate + "','%Y-%m-%d %H:%i:%s') and sm_id=" + billNo;
            int changeCount = Convert.ToInt32(db.SelectScalarForTransaction(checkEntryChanged));
            if (changeCount == 0)
            {
                return "E";
            }
            //getting date
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntryTimeZone"].Value));
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string edited_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            //get previous transaction details
            DataTable dt = db.SelectQueryForTransaction("select action_ref_id,sm_invoice_no,partner_id,cust_name,cash_amt,wallet_amt,cheque_amt,cr from tbl_transactions tr inner join tbl_sales_master sm on sm.sm_id=tr.action_ref_id inner join tbl_customer tc on tc.cust_id=sm.cust_id where id='" + trans_id + "'");
            if (dt.Rows.Count <= 0)
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.Write("Transaction not found");
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
               
            }
            double prev_total = Convert.ToDouble(dt.Rows[0]["cr"]);
            double prev_cash_amt = Convert.ToDouble(dt.Rows[0]["cash_amt"]);
            double prev_wallet_amt = Convert.ToDouble(dt.Rows[0]["wallet_amt"]);
            double prev_cheque_amt = Convert.ToDouble(dt.Rows[0]["cheque_amt"]);
            string customer = Convert.ToString(dt.Rows[0]["cust_name"]);
            string invoiceNo = Convert.ToString(dt.Rows[0]["sm_invoice_no"]);

            //calculating new total
            double new_total = cash_amt + prev_wallet_amt + cheque_amt;

            //checking if new total is greater than old
            if (new_total > prev_total)
            {
                //crediting amount if edited payment is greater than previous
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`, `partner_type`, `branch_id`,`user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `cr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @cr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", HttpContext.Current.Request.Cookies["invntrystaffBranchId"].Value);
                cmdInsCr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of order #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by crediting the amount " + (new_total - prev_total));
                cmdInsCr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsCr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsCr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsCr.Parameters.AddWithValue("@cr", (new_total - prev_total));
                cmdInsCr.Parameters.AddWithValue("@date", edited_date); 
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsCr);
            }
            else
            {
                //debiting if edited payment is less than previous
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `dr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @dr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", HttpContext.Current.Request.Cookies["invntrystaffBranchId"].Value);
                cmdInsDr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of order #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by debiting the amount " + (prev_total - new_total));
                cmdInsDr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsDr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsDr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsDr.Parameters.AddWithValue("@dr", (prev_total - new_total));
                cmdInsDr.Parameters.AddWithValue("@date", edited_date);
                cmdInsDr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsDr);
            }

            // UPDATING CUSTOMER DETAILS
            string update_cust_qry = "UPDATE tbl_customer SET cust_last_updated_date='" + edited_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + dt.Rows[0]["partner_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") WHERE cust_id='" + dt.Rows[0]["partner_id"].ToString() + "'";
            bool upcust_result = db.ExecuteQueryForTransaction(update_cust_qry);
            if (upcust_result)
            {
                db.ExecuteQueryForTransaction("UPDATE tbl_sales_master SET sm_last_updated_date='" + edited_date + "' where sm_id =" + billNo);
                db.ExecuteQueryForTransaction("update tbl_transactions set last_updated_date='" + edited_date + "' where action_type=1 and action_ref_id=" + billNo + "");
                DataTable emailSelectionDt = db.SelectQueryForTransaction("SELECT emailid FROM `tbl_user_details` WHERE user_type in (select distinct user_type from tbl_button_permission where ub_id IN (6,7,8,3,4,5))");
                string mailId = "";
                for (int i = 0; i < emailSelectionDt.Rows.Count; i++)
                {
                    if (emailSelectionDt.Rows[i]["emailid"] != null && emailSelectionDt.Rows[i]["emailid"] != "")
                    {
                        mailId += "," + emailSelectionDt.Rows[i]["emailid"];
                    }

                }
                mailId = mailId.Trim().TrimStart(',');
                
              //  string str = mailSending(mailId, invoiceNo, customer, edited_date);
            }
            db.CommitTransaction();
            return "SUCCESS";
        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.Write(e.ToString());
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
          
            db.RollBackTransaction();
            return "N";
        }
    }

    [WebMethod]// users show
    public static string loadVehicles()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select user_id,concat(first_name,\" \",last_name) as name from tbl_user_details where user_type IN ('6')";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end
}