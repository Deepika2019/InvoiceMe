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

public partial class reports_salesReturnReportAdvnc : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(31);
    }


    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select branch_id,branch_name from tbl_branch";
        query = query + " order by branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end warehouse show



    [WebMethod]// start customers showing
    public static string showCustomersInReports()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select cust_id,cust_name from tbl_customer order by cust_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end customers show

    [WebMethod]
    public static string showsalespersons()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select user_id,first_name,last_name  from tbl_user_details where user_type =2 order by user_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }
    //stop: Listing salesperson in Reports page

    //Start:Show Reports in reports.aspx
    [WebMethod]
    public static string showDailyReports(double page, string searchResult, double perpage, string BranchId, string reportfromdate, string reporttodate, string BranchName)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        DataTable dt1 = new DataTable();
        StringBuilder sb = new StringBuilder();
        DateTime myDateTime = DateTime.Now;

        string searchResults = searchResult.Replace("*", "'");
        double per_page = perpage;
        double offset = (page - 1) * per_page;
        string innerqry = "";
        string countQry = "";
        int numrows = 0;
        double total_pages = 0;
        string qry = "";
        string summaryRepport = "";
        /* countQry = "SELECT  * FROM tbl_salesreturn_master LEFT JOIN tbl_salesreturn_items ON tbl_salesreturn_master.srm_id = tbl_salesreturn_items.srm_id ";
         countQry = countQry + " inner join  tbl_sales_master  on  tbl_salesreturn_master.cust_id=tbl_sales_master.cust_id " ;
         countQry = countQry + " inner join  tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid " + searchResults;*/





        countQry = "select * from tbl_salesreturn_items inner join tbl_sales_master on";
        countQry = countQry + " tbl_sales_master.sm_id=tbl_salesreturn_items.sm_id ";
        countQry = countQry + " INNER JOIN tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid";
        countQry = countQry + " INNER JOIN tbl_salesreturn_master on tbl_salesreturn_master.srm_id=tbl_salesreturn_items.srm_id " + searchResults;
        countQry = countQry + " group by tbl_salesreturn_master.srm_id ";

        DataTable dtcount = new DataTable();
        dtcount = db.SelectQuery(countQry);
        numrows = dtcount.Rows.Count;
        if (perpage == 0)
        {
            per_page = numrows;
        }
        if (numrows == 0)
        {
            return "N";
        }

        total_pages = Math.Ceiling(numrows / per_page);

        // Arun code 4-01-17

        innerqry = "select tbl_salesreturn_items.srm_id,tbl_salesreturn_items.sm_id, tbl_salesreturn_items.sri_id,tbl_salesreturn_items.itm_code,REPLACE(DATE_FORMAT(tbl_salesreturn_master.srm_date ,'%d/%m/%Y'),'/','-') as BillDate,";
        innerqry = innerqry + " tbl_salesreturn_items.itm_name ,tbl_salesreturn_items.si_price ,tbl_salesreturn_items.si_discount_rate ,tbl_salesreturn_items.sri_discount_amount ,";
        innerqry = innerqry + " tbl_salesreturn_items.sri_qty ,tbl_salesreturn_items.sri_total,tbl_salesreturn_items.sri_type,tbl_user_details.first_name,";
        innerqry = innerqry + " tbl_user_details.last_name,tbl_sales_master.cust_id ,tc.cust_name,tbl_sales_master.sm_refno ";
        innerqry = innerqry + " from tbl_salesreturn_items inner join tbl_sales_master on";
        innerqry = innerqry + " tbl_sales_master.sm_id=tbl_salesreturn_items.sm_id inner join tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id INNER JOIN ";
        innerqry = innerqry + " tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid ";
        innerqry = innerqry + " INNER JOIN tbl_salesreturn_master on tbl_salesreturn_master.srm_id=tbl_salesreturn_items.srm_id " + searchResults + " order by tbl_salesreturn_master.srm_id LIMIT " + offset.ToString() + " ," + per_page;
        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);
        summaryRepport = showSummaryReport(numrows, BranchId, searchResults, reportfromdate, reporttodate, BranchName);
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "";
        }
        else
        {
            jsonResponse = "N";
        }
        jsonResponse = jsonResponse + summaryRepport;
        return jsonResponse;
        // return "Y";
    }

    public static string showSummaryReport(double numrows, string branchid, string searchResult, string reportfromdate, string reporttodate, string BranchName)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt1, dt2, dt3, dt4 = new DataTable();
        StringBuilder sb = new StringBuilder();

        string searchResults = searchResult;
        string totalnetamt = "0.00";
        string totalpaidamt = "0.00";
        string totaloutstand_paid = "0.00";
        string totaloutstand = "0.00";
        Decimal totalsales = 0;
        string totalcashamt = "0.00";
        string totalcardamt = "0.00";
        string totalcheqamt = "0.00";

        // we edited
        string qry_totalnet_paid_searchResults = searchResults.Replace("WHERE", "");

        
        string qry_totalnet_paid = "select sum(sri_total) as totalnetamt from tbl_salesreturn_items ";
        qry_totalnet_paid = qry_totalnet_paid + " INNER JOIN tbl_sales_master on tbl_sales_master.sm_id=tbl_salesreturn_items.sm_id ";
        qry_totalnet_paid = qry_totalnet_paid + " INNER JOIN  tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid ";
        qry_totalnet_paid = qry_totalnet_paid + " INNER JOIN tbl_salesreturn_master on tbl_salesreturn_master.srm_id=tbl_salesreturn_items.srm_id  where 1 and " + qry_totalnet_paid_searchResults;
 
        dt1 = db.SelectQuery(qry_totalnet_paid);
        if (dt1 != null)
        {
            if (dt1.Rows.Count > 0)
            {
                if (dt1.Rows[0]["totalnetamt"] is DBNull)
                {
                }
                else
                {
                    totalnetamt = dt1.Rows[0]["totalnetamt"].ToString();

                }
            }
        }


        string currencyqry = "SELECT currency_name FROM tbl_currency_details INNER JOIN tbl_branch ON tbl_branch.branch_currency_id = tbl_currency_details.currency_id where tbl_branch.branch_id ='" + branchid + "'";
        DataTable ddtt = new DataTable();
        ddtt = db.SelectQuery(currencyqry);
        string currency = "";
        if (ddtt != null)
        {
            if (ddtt.Rows.Count > 0)
            {
                if (ddtt.Rows[0]["currency_name"] is DBNull)
                {
                }
                else
                {
                    currency = ddtt.Rows[0]["currency_name"].ToString();
                }
            }
        }
        totalsales = Convert.ToDecimal(totalpaidamt) - Convert.ToDecimal(totaloutstand_paid);
        decimal totalcollection = Convert.ToDecimal(totalpaidamt);
        HttpContext.Current.Session["rp_fieldPermanent"] = reportfromdate + "*" + reporttodate + "*" + BranchName + "*" + totalnetamt;
        // HttpContext.Current.Session["rp_fieldPermanent"] = reportfromdate + "*" + reporttodate + "*" + BranchName + "*" + numrows + "*" + currency + "*" + totalcashamt + "*" + totalcardamt + "*" + totalcheqamt + "*" + totalnetamt + "*" + totalpaidamt + "*" + totaloutstand_paid + "*" + totaloutstand + "*" + totalsales + "*" + totalcollection;
        string jsonresponse = "";
        // string jsonData = JsonConvert.SerializeObject(Formatting.Indented);
        jsonresponse = ",\"currency\":\"" + currency + "\",\"totalcashamt\":\"" + totalcashamt + "\",\"totalcardamt\":\"" + totalcardamt + "\",\"totalcheqamt\":\"" + totalcheqamt + "\",\"totalcollection\":\"" + totalcollection + "\",\"totalsales\":\"" + totalsales + "\",\"totaloutstand_paid\":\"" + totaloutstand_paid + "\",\"totalnetamt\":\"" + totalnetamt + "\",\"totaloutstand\":\"" + totaloutstand + "\"}";
        return jsonresponse;
    }
    //Stop: Show Reports in reports.aspx
    //Start:Show Reports in reports.aspx
    [WebMethod]
    public static string DownloadDailyReports(string searchResult, string reportfromdate, string reporttodate, string BranchName)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        DateTime myDateTime = DateTime.Now;

        string searchResults = searchResult.Replace("*", "'");
        string countQry = "";
        double numrows = 0;
        string innerqry = "";
        string query = "";
        countQry = "select count(tbl_sales_master.sm_id) from tbl_salesreturn_items inner join tbl_sales_master on";
        countQry = countQry + " tbl_sales_master.sm_id=tbl_salesreturn_items.sm_id ";
        countQry = countQry + " INNER JOIN tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid";
        countQry = countQry + " INNER JOIN tbl_salesreturn_master on tbl_salesreturn_master.srm_id=tbl_salesreturn_items.srm_id " + searchResults;
        numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N";
        }

        query = "select tbl_salesreturn_items.srm_id As Id,tbl_salesreturn_items.itm_code As Item_Code,REPLACE(DATE_FORMAT(tbl_salesreturn_master.srm_date ,'%d/%m/%Y'),'/','-') as BillDate,";
        query = query + " tbl_salesreturn_items.itm_name AS Item_Name ,tbl_salesreturn_items.si_price ,";
        query = query + " tbl_salesreturn_items.sri_qty AS Quantity,tbl_salesreturn_items.sri_total AS Total,";
        query = query + " tc.cust_name AS Customer_Name";
        query = query + " from tbl_salesreturn_items inner join tbl_sales_master on";
        query = query + " tbl_sales_master.sm_id=tbl_salesreturn_items.sm_id INNER JOIN ";
        query = query + " tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid ";
        query = query + " inner join tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id INNER JOIN tbl_salesreturn_master on tbl_salesreturn_master.srm_id=tbl_salesreturn_items.srm_id " + searchResults + " order by tbl_salesreturn_master.srm_id ";

        HttpContext.Current.Session["downloadqry"] = query;
        return "Y";
    }
    //Stop: Show Reports in reports.aspx

}