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

public partial class manageIncome : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication income = new LoginAuthentication();
        income.userAuthentication();
        income.checkPageAcess(54);
    }



    [WebMethod]
    public static string retrieveData(string incomeId)
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
        qry = "select " + selectvar2 + " from tbl_incm_exps ie inner join tbl_incm_exps_category iec on ie.ie_category=iec.ie_cat_id where ie_id='" + incomeId + "' ";

        dtItems = db.SelectQuery(qry);

        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
        sb.Append(",");


        //Query to Push Payment Details and vendor details as Header
                                       //tu.user_name
        string previouspaidqry = "select ext_user_name as ext_user_name,tie.branch_id,ext_user_id as ext_user_id,ie_balance,ie_netamount as total_amount,sum(dr)-sum(cr) as ie_total_balance,ie_netamount-(sum(dr)-sum(cr)) as ie_total_paid,DATE_FORMAT(ie_date,'%d-%b-%Y') AS date,ie_note,ie_invoice_num from tbl_incm_exps tie"
              + " inner join tbl_user_details tu on tu.user_id=tie.user_id"
              + " inner join tbl_transactions tr on (tr.action_ref_id=tie.ie_id and tr.action_type=" + (int)Constants.ActionType.INCOME + ") where ie_id='" + incomeId + "' ";
        dtOrder = db.SelectQuery(previouspaidqry);
        sb.Append("\"entry\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));


        //fetching payment details
        String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
         + " cheque_bank,DATE_FORMAT(`cheque_date`, '%Y-%m-%d') as cheque_date,dr,cr from tbl_transactions tr "
         + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
         + " where action_ref_id='" + incomeId + "' and action_type=" + (int)Constants.ActionType.INCOME;
        DataTable dtPay = db.SelectQuery(paymentQry);
        sb.Append(",");
        sb.Append("\"transaction_details\":");
        sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }

    [WebMethod]
    public static string updateIncome(Dictionary<string, string> filters)
    {

        String resultStatus = "N";
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(filters["TimeZone"]);
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
        mySqlConnection db = new mySqlConnection();

        try
        {
            db.BeginTransaction();

            DataTable dt = new DataTable();


            //if (TotalPaidinFull == "1")
            //{

            if (filters.ContainsKey("SpecialNote"))
            {
                db.ExecuteQueryForTransaction("UPDATE tbl_incm_exps set ie_note  ='" + filters["SpecialNote"] + "' ");
            }
            //check is cash paid
            if (Convert.ToDouble(filters["currentPaidamt"]) > 0)
            {
                //inserting order credit entry
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`,cash_amt " +
                    (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                    ", `cr`, `date`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt" +
                    (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                    ", @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.INCOME);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                cmdInsDr.Parameters.AddWithValue("@partner_id", filters["externalUserId"]);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", filters["branchId"]);
                cmdInsDr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsDr.Parameters.AddWithValue("@narration", "Credited " + filters["currentPaidamt"] + " against Income entry #" + filters["invoiceNum"]);
                cmdInsDr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(filters["CashAmount"]));
                //cmdInsDr.Parameters.AddWithValue("@card_amt", neworder["sessionId"]);
                //cmdInsDr.Parameters.AddWithValue("@card_no", neworder["sessionId"]);
                if (Convert.ToDouble(filters["ChequeAmount"]) != 0)
                {
                    cmdInsDr.Parameters.AddWithValue("@cheque_amt", filters["ChequeAmount"]);
                    cmdInsDr.Parameters.AddWithValue("@cheque_no", filters["ChequeNo"]);
                    cmdInsDr.Parameters.AddWithValue("@cheque_date", filters["ChequeDate"]);
                    cmdInsDr.Parameters.AddWithValue("@cheque_bank", filters["BankName"]);
                }

                cmdInsDr.Parameters.AddWithValue("@cr", filters["currentPaidamt"]);
                cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                db.ExecuteQueryForTransaction(cmdInsDr);
            }

            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + filters["externalUserId"] + "' and partner_type=" + (int)Constants.PartnerType.COMMONUSER + ") WHERE vn_id='" + filters["externalUserId"] + "'";
            bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);
            if (upvndr_result)
            {
                resultStatus = "Y";
            }
            resultStatus = resultStatus + "@@##$$" + filters["purchaseId"];
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try
            {
                resultStatus = "N";
                db.RollBackTransaction();
                LogClass log = new LogClass("managepurchase");
                log.write(ex);
            }
            catch
            {
            }
        }
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
        string updateTransaction = "UPDATE tbl_transactions set cash_amt='" + filters["cashAmt"] + "',cheque_amt='" + filters["chequeAmt"] + "',cheque_no='" + filters["chequeNo"] + "',cheque_date='" + filters["popupChequeDate"] + "',cheque_bank='" + filters["chequeBank"] + "',cr='" + filters["totalAmt"] + "',narration='Credited "+ filters["totalAmt"]+" Against Income Entry #'" + query_condition;
        bool transaction_result = db.ExecuteQuery(updateTransaction);
        if (transaction_result)
        {
            return "Y";
        }
        else
            return "N";

    }

}