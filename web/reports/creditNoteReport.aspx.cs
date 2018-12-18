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


public partial class reports_creditNoteReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(33);
    }
    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteCustomerData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT cust_name,cust_id from tbl_customer where 1 and cust_name like '%" + variable + "%' limit 0,20";
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["cust_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["cust_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["cust_name"]) + "\"}");

                //sb.Append("'name':'" + Convert.ToString(row["cust_name"]) + "'}");
                sb.Append(",");
            }
            sb.Remove(sb.Length - 1, 1);
            sb.Append("]");
        }
        else
        {
            sb.Append("[{\"id\":\"-1\",\"label\":\"No Data Found\",\"value\":\"No Data Found\"}]");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }


    [WebMethod]
    public static string showsalespersons()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select user_id,first_name,last_name  from tbl_user_details where 1 order by user_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }

    [WebMethod]
    public static string showCreditNoteReports(int page, Dictionary<string, string> filters, int perpage)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt,dtData = new DataTable();
        double total_pages = 0;
        string query_condition = " where 1=1 and tr.action_type=" + (int)Constants.ActionType.DEPOSIT + "";
        if (filters.Count > 0)
        {

            if (filters.ContainsKey("custid"))
            {
                query_condition += " and tr.partner_id='" + filters["custid"] + "'";
            }
            if (filters.ContainsKey("salesPerson"))
            {
                if (filters["salesPerson"] != "0")
                {
                    query_condition += " and tr.user_id='" + filters["salesPerson"] + "'";
                }
            }
            if (filters.ContainsKey("warehouse"))
            {
                if (filters["warehouse"] != "0")
                {
                    query_condition += " and tr.branch_id='" + filters["warehouse"] + "'";
                }
            }
            if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }

        }
        int per_page = perpage;
        int offset = (page - 1) * per_page;

        string countQry = "SELECT count(tr.id) as numrows,sum(cr) as totalAmount FROM tbl_transactions tr inner join tbl_customer tc ON tc.cust_id = tr.partner_id inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition + "";
        dtData = db.SelectQuery(countQry);
        string netamount = dtData.Rows[0]["totalAmount"].ToString();
        double numrows = Convert.ToDouble(dtData.Rows[0]["numrows"]);
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }

        total_pages = Math.Ceiling(numrows / per_page);
        string innerqry = " SELECT tr.id,REPLACE(DATE_FORMAT(date,'%d/%m/%Y'),'/','-') as TransferDate, narration as description, cr as amount,tr.partner_id,cust_name,concat(tu.first_name,' ',tu.last_name) as seller_name ";
        innerqry = innerqry + " FROM tbl_transactions tr inner join tbl_customer tc ON tc.cust_id = tr.partner_id inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition + " order by tr.id LIMIT " + offset.ToString() + " ," + per_page;



        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);
        HttpContext.Current.Session["rp_fieldPermanent"] = filters["from_date"] + "*" + filters["to_date"] + "*" + netamount;
       // summaryRepport = showSummaryReport(numrows, BranchId, searchResults, reportfromdate, reporttodate, BranchName);
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"totalAmount\":\"" + netamount + "\",\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }
       // jsonResponse = jsonResponse + summaryRepport;
        return jsonResponse;

    }

    //Start:For download service reports
    [WebMethod]
    public static string downloadCreditNoteReports(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt, dtData = new DataTable();
        double total_pages = 0;
        string query_condition = " where 1=1 and tr.action_type=" + (int)Constants.ActionType.DEPOSIT + "";
        if (filters.Count > 0)
        {

            if (filters.ContainsKey("custid"))
            {
                query_condition += " and tr.partner_id='" + filters["custid"] + "'";
            }
            if (filters.ContainsKey("salesPerson"))
            {
                if (filters["salesPerson"] != "0")
                {
                    query_condition += " and tr.user_id='" + filters["salesPerson"] + "'";
                }
            }
            if (filters.ContainsKey("warehouse"))
            {
                if (filters["warehouse"] != "0")
                {
                    query_condition += " and tr.branch_id='" + filters["warehouse"] + "'";
                }
            }
            if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }

        }

        string countQry = "SELECT count(tr.id) as numrows,sum(cr) as totalAmount FROM tbl_transactions tr inner join tbl_customer tc ON tc.cust_id = tr.partner_id inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition + "";
        dtData = db.SelectQuery(countQry);
        double numrows = Convert.ToDouble(dtData.Rows[0]["numrows"]);
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }

        string innerqry = " SELECT tr.id,REPLACE(DATE_FORMAT(date,'%d/%m/%Y'),'/','-') as TransferDate, narration as description, cr as amount,tr.partner_id as cust_id,cust_name,concat(tu.first_name,' ',tu.last_name) as seller_name ";
        innerqry = innerqry + " FROM tbl_transactions tr inner join tbl_customer tc ON tc.cust_id = tr.partner_id inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition + " order by tr.id ";
        HttpContext.Current.Session["downloadqry"] = innerqry;
        return "Y";
    }
    //Stop: Download reports

    [WebMethod]
    public static string searchcustomerdata(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("custname"))
                {
                    query_condition += " and cust_name  LIKE '%" + filters["custname"] + "%'";
                }
                if (filters.ContainsKey("custid"))
                {
                    query_condition += " and cust_id  LIKE '%" + filters["custid"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "SELECT count(*) FROM tbl_customer " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT cust_id,cust_name,cust_amount from tbl_customer ";
            innerqry = innerqry + query_condition + " order by cust_id LIMIT " + offset.ToString() + " ," + per_page;
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

}