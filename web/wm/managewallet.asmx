<%@ WebService Language="C#" Class="managewallet" %>


using System.Web.Services.Protocols;
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

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class managewallet  : System.Web.Services.WebService {

   [WebMethod]
    public string insertWallerHistory(string cust_id,string user_id,string timezone,string is_debit,string description,string amount,string order_id,string wallet_action)
    {
       
        string query = "";
        mySqlConnection db = new mySqlConnection();
        try
        {

            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");

            string qry = "insert into tbl_wallet_history(cust_id,user_id,trans_date,is_debit,description,amount,order_id,wallet_action) values('" + cust_id + "','" + user_id + "','" + currdatetime + "','" + is_debit + "','" + description + "','" + amount + "','" + order_id + "','" + wallet_action + "')";
            db.ExecuteQuery(qry);

            return "{\"message\":\"Success \"}";          

        }
        catch (Exception ex)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Error Occured in Wallet History \"}";
        }
        

        //change code
    }
    //stop: Adding Bill Details to sales master
}
    

