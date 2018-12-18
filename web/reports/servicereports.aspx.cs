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

public partial class reports_servicereports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(30);

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


    // show item brands

    [WebMethod]
    public static string ShowItemBrands()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT brand_id,brand_name FROM tbl_item_brand order by brand_id ";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end show itemname

    // Show Category 
    [WebMethod]
    public static string ShowItemCategry()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT cat_id,cat_name FROM tbl_item_category order by cat_id ";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end category

    [WebMethod]
    // public static string showServiceReports(string searchResult)
    public static string showServiceReports(double page, string searchResult, double perpage, string fromdate, string todate, string brandname)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        DataTable dt1 = new DataTable();
        StringBuilder sb = new StringBuilder();
        DateTime myDateTime = DateTime.Now;
        string innerqry = "";
        string qry = "";
        int numrows = 0;
        string searchResults = searchResult.Replace("*", "'");
        double per_page = perpage;
        double offset = (page - 1) * per_page;
        string summaryRepport = "";
        string jsonResponse = "";

        string query = "SELECT tbl_sales_items.si_id FROM tbl_sales_items";
        query = query + " INNER JOIN tbl_sales_master ON tbl_sales_items.sm_id = tbl_sales_master.sm_id"; 
        query=query+" INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
        query = query + " INNER JOIN tbl_user_details ON tbl_user_details.user_id = tbl_sales_master.sm_userid "; 
        query = query + searchResults + " and tbl_sales_master.sm_delivery_status IN(0,1,2) and tbl_sales_items.si_itm_type<>'1'";
        query = query + " GROUP BY tbl_sales_items.itbs_id";
        dt1 = db.SelectQuery(query);
        numrows = dt1.Rows.Count;
        if (perpage == 0)
        {
            per_page = numrows;
        }
        if (numrows == 0)
        {
            return "N";
        }
        innerqry = "SELECT tbl_sales_items.itm_name AS Item_Name, tbl_sales_items.si_price AS Item_Cost, SUM( tbl_sales_items.si_qty ) AS Quantity,";
        innerqry = innerqry + " SUM( tbl_sales_items.si_discount_amount ) AS discount, SUM( tbl_sales_items.si_total ) AS TotalAmount,";
        innerqry = innerqry + " SUM( tbl_sales_items.si_net_amount ) AS Netamount,concat(tu.first_name,\" \",tu.last_name) as salesMan_name FROM tbl_sales_items";
        innerqry = innerqry + " INNER JOIN tbl_sales_master ON tbl_sales_items.sm_id = tbl_sales_master.sm_id"; 
        innerqry = innerqry + " INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
        innerqry = innerqry + " INNER JOIN tbl_user_details tu ON tu.user_id = tbl_sales_master.sm_userid ";
        innerqry = innerqry + searchResults + " and tbl_sales_master.sm_delivery_status IN(0,1,2) and tbl_sales_items.si_itm_type<>'1'";
        innerqry = innerqry + " GROUP BY tbl_sales_items.itbs_id LIMIT " + offset.ToString() + " ," + per_page;
        qry = innerqry;
        dt = db.SelectQuery(qry);

        summaryRepport = Summaryreport(searchResults, fromdate, todate, brandname);


        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "";
        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse + summaryRepport;

    }
    //Stop: Show Service Reports in serviceReports.aspx*/

    [WebMethod]
    public static string Summaryreport(string searchResult, string fromdate, string todate, string brandname)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string qry1 = "";
        string totalnetamt = "0.00";
        string jsonresponse;
        qry1 = "SELECT sum(tbl_sales_items.si_net_amount) AS Netamount FROM tbl_sales_items INNER JOIN tbl_sales_master ON tbl_sales_items.sm_id = tbl_sales_master.sm_id INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id ";
        qry1 = qry1 + searchResult + " and tbl_sales_master.sm_delivery_status!=4 and tbl_sales_master.sm_delivery_status!=5 and tbl_sales_master.sm_delivery_status!=3 and tbl_sales_items.si_itm_type<>'1'";
        dt = db.SelectQuery(qry1);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["Netamount"] is DBNull)
                {
                }
                else
                {
                    totalnetamt = dt.Rows[0]["Netamount"].ToString();

                }
            }
        }
        HttpContext.Current.Session["rp_fieldPermanent"] = fromdate + "*" + todate + "*" + brandname + "*" + totalnetamt;
        jsonresponse = ",\"totalnetamt\":\"" + totalnetamt + "\"}";
        return jsonresponse;


    }//end

    //Start:For download service reports
    [WebMethod]
    public static string DownloadServiceReports(string searchResult, string fromdate, string todate, string branch)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        DataTable dt1 = new DataTable();
        DateTime myDateTime = DateTime.Now;

        string searchResults = searchResult.Replace("*", "'");
        double numrows = 0;
        string qry1 = "";
        string qry = "";
        string innerqry = "";
        string query = "SELECT tbl_sales_items.itm_name AS Item_Name, tbl_sales_items.si_price AS Item_Cost,tbl_sales_items.si_qty AS Quantity,";
        query = query + " tbl_sales_items.si_discount_amount AS discount, tbl_sales_items.si_total AS TotalAmount,";
        query = query + "  tbl_sales_items.si_net_amount AS Netamount FROM tbl_sales_items";
        query = query + " INNER JOIN tbl_sales_master ON tbl_sales_items.sm_id = tbl_sales_master.sm_id"; 
        query = query +=" INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
        query = query + " INNER JOIN tbl_user_details tu ON tu.user_id = tbl_sales_master.sm_userid ";
        query = query + searchResults + " and tbl_sales_master.sm_delivery_status IN(0,1,2) and tbl_sales_items.si_itm_type<>'1'";
        query = query + " GROUP BY tbl_sales_items.itbs_id";
        dt1 = db.SelectQuery(query);
        numrows = dt1.Rows.Count;
        if (numrows == 0)
        {
            return "N";
        }


        innerqry = "SELECT tbl_sales_items.itm_name AS Item_Name, tbl_sales_items.si_price AS Item_Cost, SUM( tbl_sales_items.si_qty ) AS Quantity,";
        innerqry = innerqry + " SUM( tbl_sales_items.si_discount_amount ) AS discount, SUM( tbl_sales_items.si_price ) AS TotalAmount,";
        innerqry = innerqry + " SUM( tbl_sales_items.si_net_amount ) AS Netamount FROM tbl_sales_items";
        innerqry = innerqry + " INNER JOIN tbl_sales_master ON tbl_sales_items.sm_id = tbl_sales_master.sm_id"; 
        innerqry = innerqry +" INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
        innerqry = innerqry + " INNER JOIN tbl_user_details tu ON tu.user_id = tbl_sales_master.sm_userid ";
        innerqry = innerqry + searchResults + " and tbl_sales_master.sm_delivery_status!=4 and tbl_sales_master.sm_delivery_status!=5 and tbl_sales_master.sm_delivery_status!=3 and tbl_sales_items.si_itm_type<>'1'";
        innerqry = innerqry + " GROUP BY tbl_sales_items.itbs_id ";
        qry = innerqry;
        dt = db.SelectQuery(qry);


        HttpContext.Current.Session["downloadqry"] = qry;
        return "Y";
    }
    //Stop: Download reports

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

}