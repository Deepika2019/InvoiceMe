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
using MySql.Data.MySqlClient;
using System.Collections;
public partial class incomExpense_editExpense : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication expense = new LoginAuthentication();
        expense.userAuthentication();
        expense.checkPageAcess(59);
    }



    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteItemData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT itm_name,itm_id from tbl_item_master where 1 and itm_name like '%" + variable + "%' ";
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
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

    [WebMethod]
    public static string retrieveData(string expenseId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtItems = new DataTable();
        DataTable dtOrder = new DataTable();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string selectvar2 = "";
        string qry = "";

        //Query to Push Expense Details to Table
        selectvar2 = selectvar2 + "ie_id,";
        selectvar2 = selectvar2 + " ie_cat_name as ie_category ,ie_total, ie_discount_rate, ie_discount_amt, ie_netamount,ie_tax ";
        qry = "select " + selectvar2 + " from tbl_incm_exps ie inner join tbl_incm_exps_category iec on ie.ie_category=iec.ie_cat_id where ie_id='" + expenseId + "' ";

        dtItems = db.SelectQuery(qry);

        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
        sb.Append(",");


        //Query to Push Payment Details and vendor details as Header
                                        //tu.user_name
        string previouspaidqry = "select ext_user_name,ext_user_id as ext_user_id,tie.branch_id,ie_balance,ie_netamount as total_amount,sum(cr)-sum(dr) as ie_total_balance,ie_netamount-(sum(dr)-sum(cr)) as ie_total_paid,DATE_FORMAT(ie_date,'%d-%b-%Y') AS date,ie_note,ie_invoice_num from tbl_incm_exps tie"
             + " inner join tbl_user_details tu on tu.user_id=tie.user_id"
             + " inner join tbl_transactions tr on (tr.action_ref_id=tie.ie_id and tr.action_type=" + (int)Constants.ActionType.EXPENSE + ") where ie_id='" + expenseId + "' ";
        dtOrder = db.SelectQuery(previouspaidqry);
        sb.Append("\"entry\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));


        //fetching payment details
        String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
         + " cheque_bank,DATE_FORMAT(`cheque_date`, '%Y-%m-%d') as cheque_date,dr,cr,is_reconciliation from tbl_transactions tr "
         + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
         + " where action_ref_id='" + expenseId + "' and action_type=" + (int)Constants.ActionType.EXPENSE;
        DataTable dtPay = db.SelectQuery(paymentQry);
        sb.Append(",");
        sb.Append("\"transaction_details\":");
        sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }


    [WebMethod]
    public static string searchOrderitems(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 and tim.itm_code not in ('1234567891234') ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("itemname"))
                {
                    query_condition += " and tim.itm_name  LIKE '%" + filters["itemname"] + "%'";
                }
                if (filters.ContainsKey("itemcode"))
                {
                    query_condition += " and tim.itm_code  LIKE '%" + filters["itemcode"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "SELECT count(*) FROM tbl_item_master tim " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT tim.itm_id,tim.itm_code,tim.itm_name,IFNULL(itbs_stock,0) as stock,IFNULL(itbs_id,0) as itbsId from tbl_item_master tim left join tbl_itembranch_stock tis on tis.itm_id=tim.itm_id and branch_id=" + filters["warehouse"] + " ";
            innerqry = innerqry + query_condition + "   order by itm_id LIMIT " + offset.ToString() + " ," + per_page;
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
            //if (numrows > per_page)
            //{
            //    Pagination pg1 = new Pagination();
            //    sb.Append(pg1.paginateGCSearch(page, total_pages, adjacents));

            //}

            //return sb.ToString();
            return jsonResponse;

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    [WebMethod]
    public static string updateExpense(Dictionary<string, string> filters)
    {
        string checkstatus = "N";
        mySqlConnection db = new mySqlConnection();
        try
        {
                                    
            DataTable itemsBefrEditDt, dt1 = new DataTable();
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(filters["TimeZone"]);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
          
            string selectPurchaseItemQuery = "select tie.user_id,ie_category,ie_netamount as old_netamount from tbl_incm_exps tie where tie.ie_id=" + filters["purchaseId"];
            itemsBefrEditDt = db.SelectQuery(selectPurchaseItemQuery);
            double old_netamount = Convert.ToDouble(itemsBefrEditDt.Rows[0]["old_netamount"]);


            db.BeginTransaction();
            Int32 oldqty = 0;
            Int32 oldtotoalqty = 0;
            string olditbs = "";
            string itbsidString = "";
            
                string updatePurchaseMasterQry = "UPDATE tbl_incm_exps set ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "user_id = '" + filters["userid"] + "',ie_date = '" + currdatetime + "',ie_total = '" + filters["TotalAmount"] + "', ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "ie_discount_rate  ='" + filters["TotalDiscountRate"] + "',ie_discount_amt  ='" + filters["TotalDiscountAmount"] + "', ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "ie_netamount  ='" + filters["TotalNetAmount"] + "',ie_tax  ='" + filters["totalTaxamt"] + "',ie_invoice_num  ='" + filters["invoicenum"] + "' ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + " WHERE ie_id= '" + filters["purchaseId"] + "' ";
                if (db.ExecuteQueryForTransaction(updatePurchaseMasterQry))
                {
                   
                    if (Convert.ToDouble(filters["TotalNetAmount"]) > old_netamount)
                    {
                        //inserting order debit entry
                        MySqlCommand cmdInsCr = new MySqlCommand();
                        cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                            " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";

                        cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.EXPENSE);
                        cmdInsCr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                        cmdInsCr.Parameters.AddWithValue("@partner_id", filters["externalUserId"]);
                        cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                        cmdInsCr.Parameters.AddWithValue("@branch_id", filters["warehouse"]);
                        cmdInsCr.Parameters.AddWithValue("@user_id", filters["userid"]);
                        cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of Expense entry #" + filters["invoicenum"] + " after an edit by crediting the amount " + (Convert.ToDouble(filters["TotalNetAmount"]) - old_netamount));
                        cmdInsCr.Parameters.AddWithValue("@cr", (Convert.ToDouble(filters["TotalNetAmount"]) - old_netamount));
                        cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                        cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                        db.ExecuteQueryForTransaction(cmdInsCr);
                        checkstatus = "Y";
                }
                    else if (Convert.ToDouble(filters["TotalNetAmount"]) < old_netamount)
                    {
                        //inserting order credit entry
                        MySqlCommand cmdInsDr = new MySqlCommand();
                        cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                            " SELECT @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";

                        cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.EXPENSE);
                        cmdInsDr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                        cmdInsDr.Parameters.AddWithValue("@partner_id", filters["externalUserId"]);
                        cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                        cmdInsDr.Parameters.AddWithValue("@branch_id", filters["warehouse"]);
                        cmdInsDr.Parameters.AddWithValue("@user_id", filters["userid"]);
                        cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of Expense entry #" + filters["invoicenum"] + " after an edit by debiting the amount " + (old_netamount - Convert.ToDouble(filters["TotalNetAmount"])));
                        cmdInsDr.Parameters.AddWithValue("@dr", (old_netamount - Convert.ToDouble(filters["TotalNetAmount"])));
                        cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                        cmdInsDr.Parameters.AddWithValue("@is_reconciliation", "1");
                        db.ExecuteQueryForTransaction(cmdInsDr);
                        checkstatus = "Y";
                }
                //end updation in transactions

                string update_vendor_qry = "UPDATE tbl_user_details SET user_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + filters["externalUserId"] + "' and partner_type=" + (int)Constants.PartnerType.COMMONUSER + ") WHERE user_id='" + filters["externalUserId"] + "'";
                bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);
                if (upvndr_result)
                {
                    checkstatus = "Y";
                }
            }
                else
                {
                    checkstatus = "N";
                }
            //}
            //else
            //{
            //    checkstatus = "N";
            //}



            db.CommitTransaction();

        }
        catch (Exception ex)
        {
            try
            {
                checkstatus = "N";
                db.RollBackTransaction();
                LogClass log = new LogClass("purchaseEntry");
                log.write(ex);
            }
            catch
            {
            }
        }
        return checkstatus;


        //change code
    }

    [WebMethod]
    public static void savePaymentEdit(int trans_id, double cash_amt, double cheque_amt)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {
            db.BeginTransaction();
            //getting date
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntryTimeZone"].Value));
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string edited_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            //get previous transaction details
            DataTable dt = db.SelectQueryForTransaction("select action_ref_id,partner_id,cash_amt,wallet_amt,cheque_amt,dr from tbl_transactions where id='" + trans_id + "'");
            if (dt.Rows.Count <= 0)
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.Write("Transaction not found");
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                db.RollBackTransaction();
                return;
            }
            double prev_total = Convert.ToDouble(dt.Rows[0]["dr"]);
            double prev_cash_amt = Convert.ToDouble(dt.Rows[0]["cash_amt"]);
            double prev_wallet_amt = Convert.ToDouble(dt.Rows[0]["wallet_amt"]);
            double prev_cheque_amt = Convert.ToDouble(dt.Rows[0]["cheque_amt"]);

            //calculating new total
            double new_total = cash_amt + prev_wallet_amt + cheque_amt;

            //checking if new total is greater than old
            if (new_total > prev_total)
            {
                //crediting amount if edited payment is greater than previous
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `dr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " SELECT @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @dr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.EXPENSE);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                cmdInsDr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of purchase entry #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by debiting the amount " + (new_total - prev_total));
                cmdInsDr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsDr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsDr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsDr.Parameters.AddWithValue("@dr", (new_total - prev_total));
                cmdInsDr.Parameters.AddWithValue("@date", edited_date);
                cmdInsDr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsDr);
            }
            else
            {
                //debiting if edited payment is less than previous
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `cr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @cr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.EXPENSE);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                cmdInsCr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of purchase entry #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by crediting the amount " + (prev_total - new_total));
                cmdInsCr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsCr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsCr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsCr.Parameters.AddWithValue("@cr", (prev_total - new_total));
                cmdInsCr.Parameters.AddWithValue("@date", edited_date);
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsCr);
            }

            // UPDATING CUSTOMER DETAILS
            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + dt.Rows[0]["partner_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.COMMONUSER + ") WHERE vn_id='" + dt.Rows[0]["partner_id"].ToString() + "'";
            bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);

            db.CommitTransaction();
        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.Write(e.ToString());
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            db.RollBackTransaction();
        }
    }

    [WebMethod]
    public static string loadTaxes(int taxType)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        if (taxType == -1)
        {
            sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
        }
        else
        {
            string query = "SELECT tp_tax_code FROM tbl_tax_profile where tp_tax_type=" + taxType + " ORDER BY tp_id ASC";
            dt = db.SelectQuery(query);
            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["tp_tax_code"] is DBNull)
                    {
                        // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                        sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
                        // sb.Append("</select>");
                    }
                    else
                    {
                        // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                        sb.Append("<option value='-1' selected='selected'>--Tax code--</option>");
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {

                            sb.Append("<option value='" + dt.Rows[i]["tp_tax_code"] + "'>" + dt.Rows[i]["tp_tax_code"] + "</option>");

                        }
                        // sb.Append("</select>");
                    }
                }
                else
                {
                    sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
                    //sb.Append("<select id='combobranddiv'>");
                    //sb.Append("</select>");
                }
            }
        }
        return sb.ToString();
    }

    [WebMethod]
    public static string addBranchStockDetails(string branch, string item, string pricegroup_one, string pricegroup_two, string pricegroup_three, string taxcode)
    {

        String resultStatus;
        resultStatus = "N";
        mySqlConnection db = new mySqlConnection();

        bool queryStatus;
        string query = "";


        //check is unique?
        String chk_qry = "SELECT count(*) FROM  tbl_itembranch_stock WHERE (branch_id = '" + branch + "' and itm_id  = '" + item + "')";
        double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
        if (numrows > 0)
        {
            return "E";
        }
        ////

        string qry = "select MAX(itbs_id) as id from tbl_itembranch_stock";
        DataTable dt = new DataTable();
        dt = db.SelectQuery(qry);
        Int32 branchstockid = 0;
        if (dt != null)
        {

            if (dt.Rows[0][0] is DBNull)
            {
                branchstockid = ++branchstockid;
            }
            else
            {
                branchstockid = Convert.ToInt32(dt.Rows[0][0]);
                branchstockid = ++branchstockid;
            }


        }
        else
        {
            branchstockid = ++branchstockid;
        }
        DataTable dt1 = new DataTable();
        dt1 = db.SelectQuery("select itm_code,itm_name,itm_brand_id,itm_category_id,itm_subcategory_id from tbl_item_master where itm_id='" + item + "'");
        query = "INSERT INTO tbl_itembranch_stock (itbs_id,branch_id, itm_id, itbs_stock, itbs_reorder, itbs_available, itm_code, itm_name,itm_brand_id,itm_category_id,itm_subcategory_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_target,tp_tax_code)";
        query = query + "VALUES ('" + branchstockid + "','" + branch + "','" + item + "','0','0','1','" + dt1.Rows[0]["itm_code"] + "','" + dt1.Rows[0]["itm_name"] + "','" + dt1.Rows[0]["itm_brand_id"] + "','" + dt1.Rows[0]["itm_category_id"] + "','" + dt1.Rows[0]["itm_subcategory_id"] + "','0','" + pricegroup_one + "','" + pricegroup_two + "','" + pricegroup_three + "','0','0','" + taxcode + "')";

        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");
        return resultStatus;
    }



    [WebMethod]
    public static string updateTransaction(Dictionary<string, string> filters)
    {
        
        mySqlConnection db = new mySqlConnection();
        //DataTable dtItems = new DataTable();
        //DataTable dtOrder = new DataTable();
        //StringBuilder sb = new StringBuilder();
        string query_condition = " WHERE id='" + filters["transId"] + "'";
        string updateTransaction = "UPDATE tbl_transactions set cash_amt='" + filters["cashAmt"] + "',cheque_amt='" + filters["chequeAmt"] + "',cheque_no='" + filters["chequeNo"] + "',cheque_date='" + filters["popupChequeDate"] + "',cheque_bank='" + filters["chequeBank"] + "',dr='" + filters["totalAmt"] + "',narration='Debited " + filters["totalAmt"] + " Against Expense Entry #"+ filters["invoiceNum"] + "'" + query_condition;
        bool transaction_result = db.ExecuteQuery(updateTransaction);
        if (transaction_result)
        {
            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + filters["externalUserId"] + "' and partner_type=" + (int)Constants.PartnerType.COMMONUSER + ") WHERE vn_id='" + filters["externalUserId"] + "'";
            bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);
            if (upvndr_result)
            {
                return "Y";
            }
            return "Y";
        }
        else
            return "N";

    }
}

