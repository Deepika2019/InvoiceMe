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

public partial class reports_ReportAll : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(32);
    }
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
    }//end show itembrand
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


    //listing SalesPerson
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

    [WebMethod]
    public static string getProductOverview(Dictionary<string, string> filters)
    {

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string overview_cond = " where 1=1";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("dateFrom"))
            {
                overview_cond += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["dateFrom"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("dateTo"))
            {
                overview_cond += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["dateTo"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("brand"))
            {
                overview_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                overview_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
            if (filters.ContainsKey("salesperson"))
            {
                overview_cond += " and sm.sm_userid ='" + filters["salesperson"] + "'";
            }
        }
         //string summeryQuery = "select usr.first_name,usr.last_name,IFNULL(sum(si.si_net_amount),0) as net_sales" +
        string summeryQuery = "select IFNULL(sum(si.si_net_amount),0) as net_sales" +
             " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
             " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" + overview_cond +"and sm.sm_delivery_status not in (4,5)";
            //" inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " + overview_cond;
             //" inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " + overview_cond;
            //" inner join tbl_user_details usr on usr.user_id =sm.sm_userid " + overview_cond;
        DataTable dtSummery = db.SelectQuery(summeryQuery);
        sb.Append("{");
        sb.Append("\"net_sales\":" + dtSummery.Rows[0]["net_sales"]);
        DataTable dtBrands = new DataTable();
        string overviewQry = "select * from (" +
            "select br.brand_id,br.brand_name as brand,sum(si.si_net_amount) as tot_sales" +
        " ,ROUND((sum(si.si_net_amount)/" + dtSummery.Rows[0]["net_sales"] + ")*100,2) as sales_percentage" +
        " ,count(*) as sales_count" +
        " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
        " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" +
        " inner join tbl_user_details usr on usr.user_id =sm.sm_userid" +
        " inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " + overview_cond + " and sm.sm_delivery_status not in (4,5) group by br.brand_id" +
        " union" +
        " select brand_id as brand_id,brand_name as brand,0 as tot_sales,0 as sales_percentage,0 as sales_count " +
        " from tbl_item_brand " +
        " ) res where " + (filters.ContainsKey("brand") ? "res.brand_id=" + filters["brand"] : "1=1") +
        " group by res.brand_id order by res.tot_sales desc";
        dtBrands = db.SelectQuery(overviewQry);
        sb.Append(",\"overview\":" + JsonConvert.SerializeObject(dtBrands, Formatting.Indented));
        sb.Append("}");
        return sb.ToString();
    }

    [WebMethod]
    public static string getBrandOverview(Dictionary<string, string> filters)
    {

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string overview_cond = "where 1=1";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("dateFrom"))
            {
                overview_cond += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["dateFrom"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("dateTo"))
            {
                overview_cond += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["dateTo"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("brand"))
            {
                overview_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                overview_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
        }
        string summeryQuery = "select IFNULL(sum(si.si_net_amount),0) as net_sales,br.brand_name as brand" +
            " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
            " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" +
            " inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " +
            " " + overview_cond+ " and sm.sm_delivery_status not in (4,5)";
        DataTable dtSummery = db.SelectQuery(summeryQuery);
        sb.Append("{");
        sb.Append("\"net_sales\":" + dtSummery.Rows[0]["net_sales"]);
        sb.Append(",\"brand\":\"" + dtSummery.Rows[0]["brand"] + "\"");
        if (filters.ContainsKey("category"))
        {
            DataTable dtCategory = db.SelectQuery("select cat_name from tbl_item_category where cat_id='" + filters["category"] + "'");
            sb.Append(",\"category\":\"" + dtCategory.Rows[0]["cat_name"] + "\"");
        }
        DataTable dtBrands = new DataTable();
        string overviewQry = " select * from (" +
        " select si.itm_name as item,itbs.itm_id as id,sum(si.si_net_amount) as tot_sales" +
        " ,ROUND((sum(si.si_net_amount)/" + dtSummery.Rows[0]["net_sales"] + ")*100,2) as sales_percentage" +
        " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
        " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id " + overview_cond + " and sm.sm_delivery_status not in (4,5) group by itbs.itm_id" +
        " union " +
        " select itm_name as item,itm_id as id,0 as tot_sales,0 as sales_percentage " +
        " from tbl_item_master where itm_brand_id=" + filters["brand"] +
        (filters.ContainsKey("category") ? " and itm_category_id='" + filters["category"] + "'" : "") +
        " ) res group by res.id order by tot_sales desc";
        dtBrands = db.SelectQuery(overviewQry);
        sb.Append(",\"overview\":" + JsonConvert.SerializeObject(dtBrands, Formatting.Indented));
        sb.Append("}");
        return sb.ToString();
    }
}