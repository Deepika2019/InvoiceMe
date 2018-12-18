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

public partial class reports_SaleOrderCancelRejectRpt : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(29);

    }
    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        //string query = "SELECT tbl_branch.branch_id,tbl_branch.branch_name,tbl_branch.branch_countryid,tbl_branch.branch_timezone FROM tbl_branch INNER JOIN tbl_user_branches ON tbl_branch.branch_id = tbl_user_branches.branch_id WHERE tbl_user_branches.user_id='" + userid + "' and tbl_user_branches.status='1' ";
        //query = query + " order by tbl_branch.branch_id";
        //dt = db.SelectQuery(query);
        string query = "SELECT branch_id,branch_name FROM tbl_branch";
        query = query + " order by branch_id";
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
        searchResults += " and sm_parent=1";
        double per_page = perpage;
        double offset = (page - 1) * per_page;
        string innerqry = "";
        string countQry = "";
        int numrows = 0;
        double total_pages = 0;
        string qry = "";
        string summaryRepport = "";
        countQry = "SELECT count(sm_id) FROM tbl_sales_master " + searchResults + "";
        //  countQry = countQry + "  

        numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (perpage == 0)
        {
            per_page = numrows;
        }
        if (numrows == 0)
        {
            return "N";
        }

        total_pages = Math.Ceiling(numrows / per_page);

        //innerqry = "SELECT sm_id, sm_refno,cust_id, cust_name, sm_total, sm_discount_rate, sm_discount_amount, sm_netamount, REPLACE(DATE_FORMAT(sm_date,'%d/%m/%Y'),'/','-') as BillDate, sm_paid, sm_balance, sm_cash_amt, sm_chq_amt, sm_card_amt";
        //innerqry = innerqry + "  FROM  tbl_sales_master " + searchResults + "LIMIT " + offset.ToString() + " ," + per_page;

        innerqry = " SELECT tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tbl_sales_master.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate, tbl_sales_master.sm_discount_amount,tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date,'%d/%m/%Y'),'/','-') as BillDate, tbl_sales_master.sm_paid, tbl_sales_master.sm_balance, tbl_sales_master.sm_chq_amt, tbl_sales_master.sm_card_amt, tbl_sales_master.sm_cash_amt,tbl_sales_master.sm_specialnote,tbl_sales_master.sm_delivery_status, tbl_sales_items.si_id, tbl_sales_items.itm_code, tbl_sales_items.itm_name, tbl_sales_items.si_price, tbl_sales_items.si_qty, tbl_sales_items.si_total,tbl_sales_items.si_discount_rate, tbl_sales_items.si_discount_amount, tbl_sales_items.si_net_amount, tbl_sales_items.si_foc,tbl_user_details.first_name,tbl_user_details.last_name ";
        innerqry = innerqry + " FROM tbl_sales_master LEFT JOIN tbl_sales_items ON tbl_sales_master.sm_id = tbl_sales_items.sm_id and tbl_sales_items.si_itm_type!=2 inner join tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid  " + searchResults + " order by tbl_sales_master.sm_id LIMIT " + offset.ToString() + " ," + per_page;
        // qry = " SELECT * FROM (select a.*,ROW_NUMBER() OVER (order by a.BillDateTime desc) as row from (" + innerqry + ")  a ) b WHERE b.row >" + offset.ToString() + " and b.row <= " + (offset + per_page).ToString();
        // innerqry="select sm_id,sm_refno,cust_id,cust_name,sm_total,sm_discount_rate"

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

    #region CommentedSummery
    public static string showSummaryReport(double numrows, string branchid, string searchResult, string reportfromdate, string reporttodate, string BranchName)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt1, dt2, dt3, dt4 = new DataTable();
        StringBuilder sb = new StringBuilder();

        string searchResults = searchResult.Replace("*", "'");
        string totalnetamt = "0.00";
        string totalpaidamt = "0.00";
        string totaloutstand_paid = "0.00";
        string totaloutstand = "0.00";
        Decimal totalsales = 0;
        string totalcashamt = "0.00";
        string totalcardamt = "0.00";
        string totalcheqamt = "0.00";
        string totalwalletamt = "0.00";

        // we edited
        string qry_totalnet_paid_searchResults = searchResults.Replace("WHERE", "");

        string qry_totalnet_paid = "select sum(sm_netamount) as totalnetamt,sum(sm_paid) as totalpaidamt from tbl_sales_master where 1 and " + qry_totalnet_paid_searchResults;
        string qry_totaloutstand_paid = "select sum(sm_paid) as totaloutstandpaid from tbl_sales_master where sm_parent =0 and " + qry_totalnet_paid_searchResults;
        string qry_totaloutstand = "select sum(b.grandbalance) as final_balance from (select a.sm_refno,MIN(a.sm_balance) as grandbalance from (SELECT sm_id,sm_refno,sm_paid,sm_balance,sm_date FROM tbl_sales_master " + searchResults + " and sm_balance>0";
        qry_totaloutstand = qry_totaloutstand + " ) a group by a.sm_refno) as b ";
        string qry_totalpaymode = "select sum(sm_cash_amt) as totalcashamt,sum(sm_card_amt) as totalcardamt,sum(sm_chq_amt) as totalcheqamt,sum(sm_wallet_amt) as totalwalletamount from tbl_sales_master " + searchResults;
        dt1 = db.SelectQuery(qry_totalnet_paid);
        if (dt1 != null)
        {
            if (dt1.Rows.Count > 0)
            {
                if (dt1.Rows[0]["totalnetamt"] is DBNull || dt1.Rows[0]["totalpaidamt"] is DBNull)
                {
                }
                else
                {
                    totalnetamt = dt1.Rows[0]["totalnetamt"].ToString();
                    totalpaidamt = dt1.Rows[0]["totalpaidamt"].ToString();
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
        dt3 = db.SelectQuery(qry_totaloutstand);
        if (dt3 != null)
        {
            if (dt3.Rows.Count > 0)
            {
                if (dt3.Rows[0]["final_balance"] is DBNull)
                {
                }
                else
                {
                    totaloutstand = dt3.Rows[0]["final_balance"].ToString();
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
        totalsales = Convert.ToDecimal(totalpaidamt) - Convert.ToDecimal(totaloutstand_paid);
        decimal totalcollection = Convert.ToDecimal(totalpaidamt);
        HttpContext.Current.Session["rp_fieldvalues"] = reportfromdate + "*" + reporttodate + "*" + BranchName + "*" + numrows + "*" + currency + "*" + totalcashamt + "*" + totalcardamt + "*" + totalcheqamt + "*" + totalnetamt + "*" + totalpaidamt + "*" + totaloutstand_paid + "*" + totaloutstand + "*" + totalsales + "*" + totalcollection;
        string jsonresponse = "";
        // string jsonData = JsonConvert.SerializeObject(Formatting.Indented);
        jsonresponse = ",\"currency\":\"" + currency + "\",\"totalcashamt\":\"" + totalcashamt + "\",\"totalcardamt\":\"" + totalcardamt + "\",\"totalcheqamt\":\"" + totalcheqamt + "\",\"totalwalletamt\":\"" + totalwalletamt + "\",\"totalcollection\":\"" + totalcollection + "\",\"totalsales\":\"" + totalsales + "\",\"totaloutstand_paid\":\"" + totaloutstand_paid + "\",\"totalnetamt\":\"" + totalnetamt + "\",\"totaloutstand\":\"" + totaloutstand + "\"}";
        return jsonresponse;
    }
    //Stop: Show Reports in reports.aspx



    //Start:Show Reports in reports.aspx
    #endregion


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
        countQry = countQry = "SELECT count(*) FROM tbl_sales_master " + searchResults;
        numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N";
        }

        query = " SELECT tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tbl_sales_master.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate, tbl_sales_master.sm_discount_amount,tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date,'%d/%m/%Y'),'/','-') as BillDate, tbl_sales_master.sm_paid, tbl_sales_master.sm_balance, tbl_sales_master.sm_chq_amt, tbl_sales_master.sm_card_amt, tbl_sales_master.sm_cash_amt,tbl_sales_master.sm_specialnote,tbl_sales_master.sm_delivery_status, tbl_sales_items.si_id, tbl_sales_items.itm_code, tbl_sales_items.itm_name, tbl_sales_items.si_price, tbl_sales_items.si_qty, tbl_sales_items.si_total,tbl_sales_items.si_discount_rate, tbl_sales_items.si_discount_amount, tbl_sales_items.si_net_amount, tbl_sales_items.si_foc,tbl_user_details.first_name,tbl_user_details.last_name ";
        query = query + " FROM tbl_sales_master LEFT JOIN tbl_sales_items ON tbl_sales_master.sm_id = tbl_sales_items.sm_id and tbl_sales_items.si_itm_type!=2 inner join tbl_user_details on tbl_user_details.user_id=tbl_sales_master.sm_userid  " + searchResults + " order by tbl_sales_master.sm_id";

        //query = "SELECT tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tbl_sales_master.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate,tbl_sales_master.sm_discount_amount, tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y'), '/', '-') AS BillDate, 'Item' as Item,tbl_sales_master.sm_paid, tbl_sales_master.sm_balance, tbl_sales_master.sm_chq_amt, tbl_sales_master.sm_card_amt, tbl_sales_master.sm_cash_amt, tbl_sales_master.sm_specialnote, tbl_user_details.first_name, tbl_user_details.last_name FROM tbl_sales_master INNER JOIN tbl_user_details ON tbl_user_details.user_id = tbl_sales_master.sm_userid  " + searchResults + "order by tbl_sales_master.sm_id";

        HttpContext.Current.Session["downloadqry"] = query;
        return "Y";
    }
    //Stop: Show Reports in reports.aspx


}