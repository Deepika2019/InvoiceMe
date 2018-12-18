using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using commonfunction;
using System.Web.Services;
using System.Data;
using System.Text;
using Newtonsoft.Json;

public partial class dashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //string siteUrl = System.Configuration.ConfigurationManager.AppSettings["site_url"];
        //HttpCookie StudentCookies = new HttpCookie("siteurl");
        //StudentCookies.Value = siteUrl;
        //StudentCookies.Expires = DateTime.Now.AddHours(365);
        //Response.Cookies.Add(StudentCookies);
    }
    //start: Listing Branches
    [WebMethod]
    public static string showBranchesInLogin(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select tb.branch_id,branch_name,branch_timezone,branch_countryid from tbl_branch"
            + " tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id="+userid;
        dt = db.SelectQuery(query);
        if (dt.Rows.Count == 0)
        {
            return "N";
        }
        else
        {
            return JsonConvert.SerializeObject(dt, Formatting.Indented);
        }
    }
    //stop: Listing Branches 

    [WebMethod]
    public static String getNeworderAndProcessedorderCount(string branchId, string TimeZone)
    {
        string qry1 = "";
        string qry2 = "";
        string qry3 = "";
        String status = "N";
       // dbConnection db = new dbConnection();
        mySqlConnection mySqldb = new mySqlConnection();
        DataTable dt = new DataTable();

        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(TimeZone);
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string currdatetime1 = TimeNow.ToString("dd-MM-yyyy");
        string userCondition = "";
        if (HttpContext.Current.Request.Cookies["invntrystaffTypeID"].Value == "2")
        {
            userCondition = " and sm_userid=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        }
        String qry = "SELECT COUNT(*) AS new_order_count FROM  tbl_sales_master WHERE  (branch_id = " + branchId + ")  and sm_delivery_status=0" + userCondition;
        dt = mySqldb.SelectQuery(qry);
        if (dt != null)
        {

            if (dt.Rows.Count >= 0)
            {
                status = dt.Rows[0][0].ToString();
            }
        }
       
        DataTable dt1 = new DataTable();
        qry1 = "SELECT  COUNT(*) AS processed_order_count FROM  tbl_sales_master WHERE  (branch_id = " + branchId + ")  and sm_delivery_status=1" + userCondition;
        //qry1 = qry1 + " and (CONVERT(VARCHAR(10), datein, 105)  = '"+currdatetime1+"')";
      //  qry1 = qry1 + " and (DATE_FORMAT(datein, '%d-%m-%Y')  = '" + currdatetime1 + "')";
        dt1 = mySqldb.SelectQuery(qry1);
        if (dt1 != null)
        {
            if (dt1.Rows.Count >= 0)
            {
                status = status + "*" + dt1.Rows[0][0].ToString();
            }
        }
       
        DataTable dt2 = new DataTable();
        qry2 = "SELECT  COUNT(*) AS lowstockcount FROM  tbl_itembranch_stock WHERE  (branch_id = " + branchId + ")  and itbs_stock<itbs_reorder";
        //qry1 = qry1 + " and (CONVERT(VARCHAR(10), datein, 105)  = '"+currdatetime1+"')";
        //  qry1 = qry1 + " and (DATE_FORMAT(datein, '%d-%m-%Y')  = '" + currdatetime1 + "')";
        dt2 = mySqldb.SelectQuery(qry2);
        if (dt2 != null)
        {
            if (dt2.Rows.Count >= 0)
            {
                status = status + "*"+dt2.Rows[0][0].ToString();
            }
        }
       
        DataTable dt3 = new DataTable();
        qry3 = "SELECT  COUNT(*) AS disconfirm_order_count FROM  tbl_sales_master WHERE  (branch_id = " + branchId + ")  and sm_delivery_status=3" + userCondition;
        //qry1 = qry1 + " and (CONVERT(VARCHAR(10), datein, 105)  = '"+currdatetime1+"')";
        //  qry1 = qry1 + " and (DATE_FORMAT(datein, '%d-%m-%Y')  = '" + currdatetime1 + "')";
        dt3 = mySqldb.SelectQuery(qry3);
        if (dt3 != null)
        {
            if (dt3.Rows.Count >= 0)
            {
                status = status + "*" + dt3.Rows[0][0].ToString();
            }
        }
      
        DataTable dt4 = new DataTable();
        string qry4 = "SELECT  COUNT(*) AS confirm_customer_count FROM  tbl_customer WHERE ( new_custtype!='0'  or new_creditamt!='0' or new_creditperiod!='0')=1";
        //qry1 = qry1 + " and (CONVERT(VARCHAR(10), datein, 105)  = '"+currdatetime1+"')";
        //  qry1 = qry1 + " and (DATE_FORMAT(datein, '%d-%m-%Y')  = '" + currdatetime1 + "')";
        dt4 = mySqldb.SelectQuery(qry4);
        if (dt4 != null)
        {
            if (dt4.Rows.Count >= 0)
            {
                status = status + "*" + dt4.Rows[0][0].ToString();
            }
        }
       
        DataTable dt5 = new DataTable();
        string qry5 = "select count(*)  as Count from ( select sm.sm_id from  tbl_sales_master sm inner join tbl_transactions tr on sm.sm_id=tr.action_ref_id and tr.action_type=1  left join (select Distinct sm_id from tbl_salesreturn_master) as srm on sm.sm_id=srm.sm_id  where 1=1 "+userCondition+"  group by tr.action_ref_id,tr.action_type  having 1=1  and (sum(dr)-sum(cr))>0) result";
        //qry1 = qry1 + " and (CONVERT(VARCHAR(10), datein, 105)  = '"+currdatetime1+"')";
        //  qry1 = qry1 + " and (DATE_FORMAT(datein, '%d-%m-%Y')  = '" + currdatetime1 + "')";
        dt5 = mySqldb.SelectQuery(qry5);
        if (dt5 != null)
        {
            if (dt4.Rows.Count >= 0)
            {
                status = status + "*" + dt5.Rows[0][0].ToString();
            }
        }
       
        return status;

    }
}