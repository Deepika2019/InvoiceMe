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

public partial class reports_salesreports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(27);

    }

    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        //string query = "SELECT tbl_branch.branch_id,tbl_branch.branch_name,tbl_branch.branch_countryid,tbl_branch.branch_timezone FROM tbl_branch INNER JOIN tbl_user_branches ON tbl_branch.branch_id = tbl_user_branches.branch_id WHERE tbl_user_branches.user_id='" + userid + "' and tbl_user_branches.status='1' ";
        //query = query + " order by tbl_branch.branch_id";
        string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end warehouse show


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
        string summarysearchresult = searchResults;
        //string searchResults;
        double per_page = perpage;
        double offset = (page - 1) * per_page;
        string innerqry = "";
        string countQry = "";
        int numrows = 0;
        double total_pages = 0;
        string qry = "";
        string summaryRepport = "";
        countQry = "SELECT sm_id FROM tbl_sales_master " + searchResults + "";
        //  countQry = countQry + "  

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
        searchResults += " and tbl_sales_master.sm_id IN (select * from (select sm_id from tbl_sales_master " + summarysearchresult + " order by sm_id LIMIT " + offset + " ," + per_page + " ) sm) ";

        innerqry = " SELECT tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tbl_sales_master.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate, tbl_sales_master.sm_discount_amount,tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date,'%d/%m/%Y'),'/','-') as BillDate, tbl_sales_master.sm_paid, tbl_sales_master.sm_balance, tbl_sales_master.sm_chq_amt, tbl_sales_master.sm_card_amt, tbl_sales_master.sm_cash_amt,tbl_sales_master.sm_specialnote,sm_invoice_no, tbl_sales_items.si_id, tbl_sales_items.itm_code, tbl_sales_items.itm_name, tbl_sales_items.si_price, tbl_sales_items.si_qty, tbl_sales_items.si_total,tbl_sales_items.si_discount_rate, tbl_sales_items.si_discount_amount, tbl_sales_items.si_net_amount, tbl_sales_items.si_foc,tbl_user_details.first_name,tbl_user_details.last_name ";
        innerqry = innerqry + " FROM tbl_sales_master LEFT JOIN tbl_sales_items ON tbl_sales_master.sm_id = tbl_sales_items.sm_id and tbl_sales_items.si_itm_type!=2 inner join tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid  " + searchResults + " order by sm_id";
        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);
        summaryRepport = showSummaryReport(numrows, BranchId, summarysearchresult, reportfromdate, reporttodate, BranchName);
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
        string totalpaid = "0.00";
        string totaloutstand_paid = "0.00";
        string totalbalance = "0.00";
        //Decimal totalbalance = 0;
        string totalcashamt = "0.00";
        string totalcardamt = "0.00";
        string totalcheqamt = "0.00";
        string totalwalletamt = "0.00";

        // we edited
        string qry_totalnet_paid_searchResults = searchResults.Replace("WHERE", "");

        string qry_totalnetamt = "select sum(sm_netamount) as totalnetamt from tbl_sales_master where 1 and sm_parent=1 and " + qry_totalnet_paid_searchResults;

        string qry_totalpaid = "select sum(total_paid) as totalpaid from tbl_sales_master where 1 and sm_parent=1 and total_paid>0 and " + qry_totalnet_paid_searchResults;
        string qry_totalbalance = "select sum(total_balance) as total_balance from tbl_sales_master where 1 and sm_parent=1 and total_balance>0 and " + qry_totalnet_paid_searchResults;
        string qry_totaloutstand_paid = "select sum(sm_paid) as totaloutstandpaid from tbl_sales_master where sm_parent =0 and " + qry_totalnet_paid_searchResults;
        string qry_totalpaymode = "select sum(sm_cash_amt) as totalcashamt,sum(sm_card_amt) as totalcardamt,sum(sm_chq_amt) as totalcheqamt,sum(sm_wallet_amt) as totalwalletamount from tbl_sales_master " + searchResults;
        dt1 = db.SelectQuery(qry_totalnetamt);
        if (dt1 != null)
        {
            if (dt1.Rows.Count > 0)
            {
                if (dt1.Rows[0]["totalnetamt"] is DBNull || dt1.Rows[0]["totalnetamt"] is DBNull)
                {
                }
                else
                {
                    totalnetamt = dt1.Rows[0]["totalnetamt"].ToString();
                }
            }
        }
        dt2 = db.SelectQuery(qry_totaloutstand_paid);
        if (dt2 != null)
        {
            if (dt2.Rows.Count > 0)
            {
                if (dt2.Rows[0]["totaloutstandpaid"] is DBNull)
                {
                }
                else
                {
                    totaloutstand_paid = dt2.Rows[0]["totaloutstandpaid"].ToString();
                }
            }
        }

        dt3 = db.SelectQuery(qry_totalpaid);
        if (dt3 != null)
        {
            if (dt3.Rows.Count > 0)
            {
                if (dt3.Rows[0]["totalpaid"] is DBNull || dt3.Rows[0]["totalpaid"] is DBNull)
                {
                }
                else
                {
                    totalpaid = dt3.Rows[0]["totalpaid"].ToString();
                }
            }
        }

        dt5 = db.SelectQuery(qry_totalbalance);
        if (dt5 != null)
        {
            if (dt5.Rows.Count > 0)
            {
                if (dt5.Rows[0]["total_balance"] is DBNull || dt5.Rows[0]["total_balance"] is DBNull)
                {
                }
                else
                {
                    totalbalance = dt5.Rows[0]["total_balance"].ToString();
                }
            }
        }





        dt4 = db.SelectQuery(qry_totalpaymode);
        if (dt4 != null)
        {
            if (dt4.Rows.Count > 0)
            {
                if (dt4.Rows[0]["totalcashamt"] is DBNull || dt4.Rows[0]["totalcardamt"] is DBNull || dt4.Rows[0]["totalcheqamt"] is DBNull || dt4.Rows[0]["totalwalletamount"] is DBNull)
                {
                }
                else
                {
                    totalcashamt = dt4.Rows[0]["totalcashamt"].ToString();
                    totalcardamt = dt4.Rows[0]["totalcardamt"].ToString();
                    totalcheqamt = dt4.Rows[0]["totalcheqamt"].ToString();
                    totalwalletamt = dt4.Rows[0]["totalwalletamount"].ToString();
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
        //totalsales = Convert.ToDecimal(totalpaidamt) - Convert.ToDecimal(totaloutstand_paid);
        //decimal totalcollection = Convert.ToDecimal(totalpaidamt);
        HttpContext.Current.Session["rp_fieldvalues"] = reportfromdate + "*" + reporttodate + "*" + BranchName + "*" + numrows + "*" + currency + "*" + totalcashamt + "*" + totalcardamt + "*" + totalcheqamt + "*" + totalnetamt + "*" + totalpaid + "*" + totaloutstand_paid + "*" + totalbalance;
        string jsonresponse = "";
        // string jsonData = JsonConvert.SerializeObject(Formatting.Indented);
        jsonresponse = ",\"currency\":\"" + currency + "\",\"totalcashamt\":\"" + totalcashamt + "\",\"totalcardamt\":\"" + totalcardamt + "\",\"totalcheqamt\":\"" + totalcheqamt + "\",\"totalwalletamt\":\"" + totalwalletamt + "\",\"totaloutstand_paid\":\"" + totaloutstand_paid + "\",\"totalnetamt\":\"" + totalnetamt + "\",\"totalbalance\":\"" + totalbalance + "\",\"totalpaid\":\"" + totalpaid + "\"}";
        return jsonresponse;
    }
    //Stop: Show Reports in reports.aspx


    //Start:Show downloads in reports.aspx
    [WebMethod]
    public static string DownloadDailyReports(string searchResult, string reportfromdate, string reporttodate, string BranchName)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        DateTime myDateTime = DateTime.Now;

        string searchResults = searchResult.Replace("*", "'");
        string countQry = "";
        double numrows = 0;
        // string innerqry = "";
        string query = "";

        countQry = countQry = "SELECT count(*) FROM tbl_sales_master " + searchResults;
        numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N";
        }


        query = "SELECT sm_invoice_no as InvoiceNumber,tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tbl_sales_master.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate,tbl_sales_master.sm_discount_amount, tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y'), '/', '-') AS BillDate, 'Item' as Item,tbl_sales_master.sm_paid, tbl_sales_master.sm_balance, tbl_sales_master.sm_chq_amt, tbl_sales_master.sm_card_amt, tbl_sales_master.sm_cash_amt, tbl_sales_master.sm_specialnote, tbl_user_details.first_name, tbl_user_details.last_name FROM tbl_sales_master INNER JOIN tbl_user_details ON tbl_user_details.user_id = tbl_sales_master.sm_userid  " + searchResults + "order by tbl_sales_master.sm_id";


        HttpContext.Current.Session["downloadqry"] = query;
        return "Y";
    }
    //Stop: download Reports in reports.aspx



    public static DataTable dt5 { get; set; }
}