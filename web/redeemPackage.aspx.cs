using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class redeemPackage : System.Web.UI.Page
{
    public string customerId;
    public string customerName;
    protected void Page_Load(object sender, EventArgs e)
    {
        mySqlConnection db = new mySqlConnection();
        customerId = Request.QueryString["customerid"];
        if (customerId == "" || customerId==null)
        {
            Response.Redirect("customers.aspx");
        }
        DataTable custDt = db.SelectQuery("select cust_name from tbl_customer where cust_id=" + customerId);
        customerName = custDt.Rows[0]["cust_name"].ToString();
    }

    [WebMethod]
    public static string searchPackages(int page, int perpage, Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1=1 and cust_id="+ filters["custId"] + "";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("search"))
            {
                qry_condition += " and (itm_name LIKE '%" + filters["search"] + "%' or itm_code like '%" + filters["search"] + "%')";
            }
        }

        int per_page = perpage;
        int offset = (page - 1) * per_page;
        string countQry = "select count(*) from tbl_customer_packages tcp inner join tbl_itembranch_stock ibs on ibs.itbs_id=tcp.itbs_id " + qry_condition;
        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }

        string searchQuery = "select package_id,itm_code,itm_name,DATE_FORMAT(package_date ,'%d-%m-%Y') as pckgDate,sm_id,package_total_count as total,"
            + " package_current_count as currentCount from tbl_customer_packages tcp inner join tbl_itembranch_stock ibs on ibs.itbs_id=tcp.itbs_id " + qry_condition + " order by package_date desc LIMIT " + offset.ToString() + " ," + per_page;
        string jsonResponse = "";
        dt = db.SelectQuery(searchQuery);

        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;
    }//end

    [WebMethod]// users show
    public static string redeemPckage(int packageId, int count,string pkgdate,int customerId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();

        bool updateStatus = db.ExecuteQuery("update tbl_customer_packages set package_current_count=package_current_count-" + count + " where package_id=" + packageId);
       if (updateStatus)
        {
            db.ExecuteQuery("insert into tbl_redeem_history(cust_id,package_id,redeem_count,redeem_date)values("+customerId+","+packageId+","+count+",'"+pkgdate+"')");
            return "Y";
        }else
        {
            return "N";
        }
    }//end

    [WebMethod]//  shows leave type
    public static string showRedeemHistory(int packageId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select redeem_count,DATE_FORMAT(redeem_date,'%d-%m-%Y') as packageDate from tbl_redeem_history where package_id="+packageId+ " order by redeem_date desc";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end
}