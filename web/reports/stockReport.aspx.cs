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

public partial class reports_stockReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(46);
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
        query = query += " INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
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
        innerqry = innerqry + " INNER JOIN tbl_itembranch_stock ON tbl_sales_items.itbs_id = tbl_itembranch_stock.itbs_id";
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
    public static string showstockReport(int page, int perpage, Dictionary<string, string> filters)
    {

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string stockreport_cond = " where 1=1";
        string status_qry = "";

        if (filters.Count > 0)
        {
           
            if (filters.ContainsKey("brand"))
            {
                stockreport_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                stockreport_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
            if (filters.ContainsKey("warehouse"))
            {
                if (filters["warehouse"] == "0")
                {
                    stockreport_cond += " and (itbs.branch_id IN(select branch_id from tbl_user_branches where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "))";
                }
                else
                {
                    stockreport_cond += " and itbs.branch_id ='" + filters["warehouse"] + "'";
                }
               
            }
           if (filters.ContainsKey("searchItem"))
           {
               stockreport_cond += " and (itbs.itm_code like '%" + filters["searchItem"] + "%' or itbs.itm_name like '%" + filters["searchItem"] + "%')";
           }

            // filtering status from sales master and adding to stock

           //if (filters["undelivered"].ToString() == "1" && filters["assigned_for_delivery"].ToString() == "1") // remove status 0,1,3,4,5,6
           //{
           //    status_qry = " and sm.sm_delivery_status not in (0,1,3,4,5,6) ";
           //}
           //else if (filters["undelivered"].ToString() == "1" && filters["assigned_for_delivery"].ToString() == "0") // remove status 0,3,4,5,6
           //{
           //    status_qry = " and sm.sm_delivery_status not in (0,3,4,5,6) ";
           //}
           //else if (filters["undelivered"].ToString() == "0" && filters["assigned_for_delivery"].ToString() == "1") // remove status 1,4,5,
           //{
           //    status_qry = " and sm.sm_delivery_status not in (1,4,5) ";
           //}
           //else
           //{
           //    status_qry = " and sm.sm_delivery_status not in (0,1,2,3,4,5,6) ";
           
           //}

        }

        int per_page = perpage;
        int offset = (page - 1) * per_page;
        string stockCountQuery = @"SELECT count(*) FROM tbl_itembranch_stock itbs " + stockreport_cond;
        double numrows = Convert.ToInt32(db.SelectScalar(stockCountQuery));
        if (numrows == 0)
        {
            return "N"; ;
        }



        string stockReviewQry = @"select itbs.itbs_id,itbs.itm_code,itbs.itm_name,branch_name,brand_name,cat_name,itbs_stock as itbstock,itbs_reorder,itbs_purchase_price as itm_class_one, 
(select ifnull( sum(si1.si_qty+si1.si_foc),0) from tbl_sales_items si1 inner join tbl_sales_master sm1 on sm1.sm_id = si1.sm_id AND sm1.sm_delivery_status=1 WHERE si1.itbs_id=itbs.itbs_id) as in_van,
ifnull( sum(si.si_qty+si.si_foc),0) as sold,(itbs_stock+ifnull( sum(si.si_qty+si.si_foc),0)) as stock,sm.sm_delivery_status 
from tbl_itembranch_stock itbs 
inner join tbl_item_brand brd on brd.brand_id=itbs.itm_brand_id 
inner join tbl_item_category cat on cat.cat_id=itbs.itm_category_id 
inner join tbl_branch br on br.branch_id=itbs.branch_id 
left join tbl_sales_items si 
inner join tbl_sales_master sm on sm.sm_id = si.sm_id 
on itbs.itbs_id = si.itbs_id  and sm.sm_delivery_status in (0,3,6) " + stockreport_cond + " group by itbs.itbs_id LIMIT " + offset.ToString() + " ," + per_page + "";
        
        string jsonResponse = "";

        DataTable dt = db.SelectQuery(stockReviewQry);

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
    }

    //Start:For download service reports
    [WebMethod]
    public static string DownloadStockReport(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string stockreport_cond = " where 1=1";
        string status_qry = "";

        if (filters.Count > 0)
        {

            if (filters.ContainsKey("brand"))
            {
                stockreport_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                stockreport_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
            if (filters.ContainsKey("warehouse"))
            {
                if (filters["warehouse"] == "0")
                {
                    stockreport_cond += " and (itbs.branch_id IN(select branch_id from tbl_user_branches where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "))";
                }
                else
                {
                    stockreport_cond += " and itbs.branch_id ='" + filters["warehouse"] + "'";
                }

            }
            if (filters.ContainsKey("searchItem"))
            {
                stockreport_cond += " and (itbs.itm_code like '%" + filters["searchItem"] + "%' or itbs.itm_name like '%" + filters["searchItem"] + "%')";
            }

        }

        string stockCountQuery = @"select count(*) FROM tbl_itembranch_stock itbs " + stockreport_cond;
        double numrows = Convert.ToInt32(db.SelectScalar(stockCountQuery));
        if (numrows == 0)
        {
            return "N"; ;
        }

//        string stockReviewQry = @"select itbs.itm_code as 'ITEM CODE',itbs.itm_name as 'ITEM NAME',branch_name as 'BRANCH',brand_name as 'BRAND',cat_name as 'CATEGORY',itbs_reorder as 'RE-ORDER LEVEL',(itbs_stock+ifnull( sum(si.si_qty+si.si_foc),0)) as 'CURRENT STOCK' 
//from tbl_itembranch_stock itbs 
//inner join tbl_item_brand brd on brd.brand_id=itbs.itm_brand_id 
//inner join tbl_item_category cat on cat.cat_id=itbs.itm_category_id 
//inner join tbl_branch br on br.branch_id=itbs.branch_id 
//left join tbl_sales_items si 
//inner join tbl_sales_master sm on sm.sm_id = si.sm_id on itbs.itbs_id = si.itbs_id " + stockreport_cond + " and sm.sm_delivery_status in (0,3,6) group by itbs.itbs_id";

        string stockReviewQry = @"select itbs.itm_code as 'ITEM CODE',itbs.itm_name as 'ITEM NAME',branch_name as 'BRANCH',brand_name as 'BRAND',cat_name as 'CATEGORY',itbs_reorder as 'RE-ORDER LEVEL',(itbs_stock+ifnull( sum(si.si_qty+si.si_foc),0)) as 'CURRENT STOCK' from tbl_itembranch_stock itbs 
inner join tbl_item_brand brd on brd.brand_id=itbs.itm_brand_id 
inner join tbl_item_category cat on cat.cat_id=itbs.itm_category_id 
inner join tbl_branch br on br.branch_id=itbs.branch_id 
left join tbl_sales_items si 
inner join tbl_sales_master sm on sm.sm_id = si.sm_id 
on itbs.itbs_id = si.itbs_id  and sm.sm_delivery_status in (0,3,6) " + stockreport_cond + "  group by itbs.itbs_id ";
        

        HttpContext.Current.Session["downloadqry"] = stockReviewQry;
        return "Y";
    }
    //Stop: Download reports
}