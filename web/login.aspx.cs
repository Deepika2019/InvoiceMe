using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
public partial class login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    //Start:Login
    [WebMethod]
    public static string mainLogin(string username, string password)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {
            db.BeginTransaction();

            DataTable dt = new DataTable();

            MySqlCommand checkAuthenticatedUserQry = new MySqlCommand();


            checkAuthenticatedUserQry.CommandText = "select tu.user_id,password,first_name,last_name,user_type,tb.branch_id, tb.branch_timezone,tb.branch_name,tb.branch_countryid "
            + " from tbl_user_details tu inner join tbl_user_branches tub on tub.user_id=tu.user_id inner join tbl_branch tb on tb.branch_id=tub.branch_id"
            + " where user_name=@username and password=@password ";

            checkAuthenticatedUserQry.Parameters.AddWithValue("@username", username);
            checkAuthenticatedUserQry.Parameters.AddWithValue("@password", password);
            dt = db.SelectQueryForTransaction(checkAuthenticatedUserQry);
            if (dt != null)
            {
                return JsonConvert.SerializeObject(dt, Formatting.Indented);
            }
            else
            {
                return "N";
            }
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {

                db.RollBackTransaction();
                LogClass log = new LogClass("login");
                log.write(ex);
                return "N";
            }
            catch
            {
            }

            throw ex;
        }
    }
    //Stop:Login

  

    //Start: User Forgot Password
    [WebMethod]
    public static string userForgotPassword(string useremail)
    {

        string resultStatus = "N";
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select user_id,first_name,last_name,user_name,password,emailid from user_details where emailid='" + useremail + "' ";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["user_id"] is DBNull)
                {
                    resultStatus = "A";
                }
                if (dt.Rows.Count > 1)
                {
                    EmailSending testemail = new EmailSending();
                    testemail.sendmail1("testp7741@gmail.com", "Multiple User Entry Found with this Same EmailID:" + useremail + "", "Multiple User Entry Found with Same EmailID");

                    resultStatus = "B";
                }
                else
                {
                    EmailSending testemail = new EmailSending();
                    // testemail.sendMail2(username, "testp7741@gmail.com", "Your Password Request", "Dear '"+dt.Rows[0]["client_fullname"]+"', <br><br> Your Password to Log in to 'titdo' is: '"+dt.Rows[0]["client_password"]+"'");
                    testemail.sendmail1(useremail, "Dear '" + dt.Rows[0]["first_name"] + "', <br><br> Your Account Details are <br><br> Username:&nbsp;&nbsp;  '" + dt.Rows[0]["user_name"] + "'<br> Password:&nbsp;&nbsp;  '" + dt.Rows[0]["password"] + "'", "Your Password Request");
                    resultStatus = "Y";
                }
            }
            else
            {
                resultStatus = "N";
            }
        }
        return resultStatus;
    }
    //Stop: User Forgot Password
    public void setCookieUser(string userid)
    {
        Response.Cookies["userdetails"]["userid"] = userid;
        Response.Cookies["userdetails"].Expires = DateTime.Now.AddDays(365);
    }


}