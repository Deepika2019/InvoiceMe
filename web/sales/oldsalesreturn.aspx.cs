using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;

public partial class sales_oldsalesreturn : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(37);
    }
    [WebMethod]
    public static string warehouseName(string branchid)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT branch_name FROM tbl_branch where branch_id=" + branchid;
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }

    [WebMethod]
    public static string selectCustomerdata(string customerid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string dataQry = "select cust_name,cust_type,cust_amount,max_creditamt,max_creditperiod,new_custtype,new_creditamt,new_creditperiod from tbl_customer where cust_id='" + customerid + "'";
        dt = db.SelectQuery(dataQry);
        if (dt.Rows[0]["new_custtype"].ToString() == "0" && dt.Rows[0]["new_creditamt"].ToString() == "0.00" && dt.Rows[0]["new_creditperiod"].ToString() == "0")
        {
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
        else
        {

            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Please contact admin to confirm customer settings\"}";
        }

    }

    [WebMethod]    
    public static string insertWalletHistory(Dictionary<string, string> data)
    {
        string result = "";
        #region
        mySqlConnection db_credit = new mySqlConnection();
        try
        {
            // credit notes found
            db_credit.BeginTransaction();

            string getsessionexist = "select session_id from tbl_transactions where session_id='" + data["session_id"] + "'";
            DataTable dtsession = db_credit.SelectQueryForTransaction(getsessionexist);
            int sess_rows = dtsession.Rows.Count;

            if (sess_rows != 0)  // ALREADY SAVED CASE
            {
                result = "EXIST";
                return result;
            }
            else
            {
                string branchQry = "select branch_timezone from tbl_branch where branch_id='" + data["branch_id"] + "'";
                DataTable cTimeZone = db_credit.SelectQueryForTransaction(branchQry);
                string branch_timezone = "";
                if (cTimeZone != null)
                {
                    branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
                }

                TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
                DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
                string action_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
                MySqlCommand cmdInsCr = new MySqlCommand();

                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`session_id`,`action_type`,`partner_id`,`partner_type`, `branch_id`,`user_id`,`cash_amt`, `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`, `narration`, `dr`,`cr`,  `date`,`closing_balance`)" +
                    " select @session_id, @action_type, @partner_id, @partner_type,@branch_id, @user_id,@cash_amt, @cheque_amt, @cheque_no, @cheque_date, @cheque_bank, @narration, @dr, @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                cmdInsCr.Parameters.AddWithValue("@session_id", data["session_id"]);

                cmdInsCr.Parameters.AddWithValue("@partner_id", data["cust_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", data["branch_id"]);
                cmdInsCr.Parameters.AddWithValue("@user_id", data["user_id"]);
                cmdInsCr.Parameters.AddWithValue("@cash_amt", data["cash_amt"]);
                cmdInsCr.Parameters.AddWithValue("@cheque_amt", data["cheque_amt"]);
                cmdInsCr.Parameters.AddWithValue("@cheque_no", data["cheque_no"]);
                cmdInsCr.Parameters.AddWithValue("@cheque_date", data["cheque_date"]);
                cmdInsCr.Parameters.AddWithValue("@cheque_bank", data["cheque_bank"]);
                cmdInsCr.Parameters.AddWithValue("@narration", data["narration"]);
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.DEPOSIT);
                cmdInsCr.Parameters.AddWithValue("@cr", data["payment"]);
                cmdInsCr.Parameters.AddWithValue("@dr", 0);
                cmdInsCr.Parameters.AddWithValue("@date", action_date);
                db_credit.ExecuteQueryForTransaction(cmdInsCr);

                string update_tbl_cust_amount = "UPDATE tbl_customer SET cust_last_updated_date='" + action_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + data["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + data["cust_id"];
                db_credit.ExecuteQueryForTransaction(update_tbl_cust_amount);
            }
            db_credit.CommitTransaction();
            result = "SUCCESS";
        }
        catch (Exception ex_credit_debit)
        {
            try
            {
                db_credit.RollBackTransaction();
                result = "FAILED";
                LogClass log_cust = new LogClass("credit_error");
                log_cust.write(ex_credit_debit);
                //log_cust.write_all_data(JSONString);
                return result;
            }
            catch (Exception ex_roll_credit)
            {
                result = "FAILED";
                LogClass log = new LogClass("credit_roll_error");
                log.write(ex_roll_credit);
                return result;
            }
        }
        #endregion
        return result;
    }
}