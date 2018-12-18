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

public partial class purchase_managepurchase : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication purchase = new LoginAuthentication();
        purchase.userAuthentication();
        purchase.checkPageAcess(5);
    }
  
 

    [WebMethod]
    public static string retrieveData(string purchaseId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtItems = new DataTable();
        DataTable dtOrder = new DataTable();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string selectvar2 = "";
        string qry = "";
        selectvar2 = selectvar2 + " row_no, ibs.itm_code,";
        selectvar2 = selectvar2 + " ibs.itm_name , pi_qty, pi_price,pi_total, pi_discount_rate, pi_discount_amt, pi_netamount,pi_tax_amount ";
        qry = "select " + selectvar2 + " from tbl_purchase_items pi inner join tbl_itembranch_stock ibs on ibs.itbs_id=pi.itbs_id  where pm_id='" + purchaseId + "' order by row_no";
        dtItems = db.SelectQuery(qry);
        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
        sb.Append(",");
        string previouspaidqry = "select tv.vn_name,pm.vn_id,vn_balance,pm_netamount as total_amount,sum(cr)-sum(dr) as pm_total_balance,pm_netamount-(sum(cr)-sum(dr)) as pm_total_paid,DATE_FORMAT(pm_date,'%d-%b-%Y') AS date,pm_note,pm_invoice_no,pm_status as status from tbl_purchase_master pm inner join tbl_vendor tv on tv.vn_id=pm.vn_id inner join tbl_transactions tr on (tr.action_ref_id=pm.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ")  where pm_id='" + purchaseId + "' ";
        dtOrder = db.SelectQuery(previouspaidqry);
        sb.Append("\"entry\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
        //fetching payment details
        String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
         + " cheque_bank,DATE_FORMAT(`cheque_date`, '%d-%b-%Y %h:%i %p') as cheque_date,dr,cr from tbl_transactions tr "
         + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
         + " where action_ref_id='" + purchaseId + "' and action_type=" + (int)Constants.ActionType.PURCHASE;
        DataTable dtPay = db.SelectQuery(paymentQry);
        sb.Append(",");
        sb.Append("\"transaction_details\":");
        sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }

    [WebMethod]
    public static string saveToPurchaseMaster(Dictionary<string, string> filters)
    {

        String resultStatus="N";
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
                db.ExecuteQueryForTransaction("UPDATE tbl_purchase_master set pm_note  ='" + filters["SpecialNote"] + "' ");
            }
            //check is cash paid
            if (Convert.ToDouble(filters["currentPaidamt"]) > 0)
            {
                //inserting order credit entry
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt " +
                    (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                    ", `dr`, `date`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt" +
                    (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                    ", @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                cmdInsDr.Parameters.AddWithValue("@partner_id", filters["vendorId"]);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                cmdInsDr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsDr.Parameters.AddWithValue("@narration", "Paid " + filters["currentPaidamt"] + " for Purchase entry #" + filters["invoiceNum"]);
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

                cmdInsDr.Parameters.AddWithValue("@dr", filters["currentPaidamt"]);
                cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                db.ExecuteQueryForTransaction(cmdInsDr);
            }

            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + filters["vendorId"] + "' and partner_type=" + (int)Constants.PartnerType.VENDOR + ") WHERE vn_id='" + filters["vendorId"] + "'";
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
}