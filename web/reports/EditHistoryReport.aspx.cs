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

public partial class reports_EditHistoryReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    [WebMethod]//serach customers
    public static string showEditHistoryReports(int page, Dictionary<string, string> filters, double perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            int numrows = 0;
            double total_pages = 0;
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1 AND (eh.edit_action=2 OR (eh.new_si_qty+eh.new_si_foc)>0)";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("branch"))
                {
                    query_condition += " and sm.branch_id='" + filters["branch"] + "'";
                }

                if (filters.ContainsKey("user"))
                {
                    query_condition += " and eh.edited_by='" + filters["user"] + "'";
                }
                if (filters.ContainsKey("fromDate"))
                {
                    query_condition += " and date(edited_date)>=STR_TO_DATE('" + filters["fromDate"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("toDate"))
                {
                    query_condition += " and date(edited_date)<=STR_TO_DATE('" + filters["toDate"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("item"))
                {
                    query_condition += " and itb.itm_id='" + filters["item"] + "'";
                }
            }
            double per_page = perpage;
            double offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            string jsonResponse = "";
            // double numrows = 0;
            countQry = " SELECT eh.itbs_id FROM tbl_edit_history eh "
 + " INNER JOIN tbl_itembranch_stock itb ON itb.itbs_id=eh.itbs_id "
 + " INNER JOIN tbl_user_details ud ON ud.user_id=eh.edited_by"
 + " INNER JOIN tbl_sales_master sm ON sm.sm_id=eh.sm_id INNER JOIN tbl_branch tb ON tb.branch_id=sm.branch_id " + query_condition
 + " GROUP BY eh.edited_by,itb.itm_id ORDER BY itb.itbs_id ASC";
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
                jsonResponse = "{\"data\":\"N\"}";
            }
            DataTable dt1 = new DataTable();
            innerqry = " SELECT eh.itbs_id,itb.itm_id,itb.itm_name,itb.itm_code,"
 + " SUM(eh.si_qty+eh.si_foc) as total_old_qty,"
 + " SUM(eh.new_si_qty+eh.new_si_foc) as total_new_qty,"
 + " (SUM(eh.new_si_qty+eh.new_si_foc)-SUM(eh.si_qty+eh.si_foc)) as total_change_in_qty,"
 + " SUM(eh.si_qty) as old_qty,"
 + " SUM(eh.new_si_qty) as new_qty,"
 + " (SUM(eh.new_si_qty)-SUM(eh.si_qty)) as change_in_qty,"
 + " SUM(eh.si_foc) as old_foc,"
 + " SUM(eh.new_si_foc) as new_foc,"
 + " (SUM(eh.new_si_foc)-SUM(eh.si_foc)) as change_in_foc,"
 + " eh.edit_action,CONCAT(ud.first_name,' ',ud.last_name) as user,branch_name FROM tbl_edit_history eh "
 + " INNER JOIN tbl_itembranch_stock itb ON itb.itbs_id=eh.itbs_id "
 + " INNER JOIN tbl_user_details ud ON ud.user_id=eh.edited_by"
 + " INNER JOIN tbl_sales_master sm ON sm.sm_id=eh.sm_id INNER JOIN tbl_branch tb ON tb.branch_id=sm.branch_id " + query_condition
 + " GROUP BY eh.edited_by,itb.itm_id ORDER BY itb.itbs_id ASC LIMIT " + offset.ToString() + " ," + per_page;

            DataTable dt = db.SelectQuery(innerqry);
            total_pages = Math.Ceiling(numrows / per_page);
        
            if (dt.Rows.Count > 0)
            {
                string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
                jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";
        
            }
            else
            {
                jsonResponse = "{\"data\":\"N\"}";
            }
            return jsonResponse;

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end


    //Start:Show downloads in reports.aspx
    [WebMethod]
    public static string DownloadEditReports(Dictionary<string, string> filters)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1 AND (eh.edit_action=2 OR (eh.new_si_qty+eh.new_si_foc)>0)";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("branch"))
                {
                    query_condition += " and sm.branch_id='" + filters["branch"] + "'";
                }

                if (filters.ContainsKey("user"))
                {
                    query_condition += " and eh.edited_by='" + filters["user"] + "'";
                }
                if (filters.ContainsKey("fromDate"))
                {
                    query_condition += " and date(edited_date)>=STR_TO_DATE('" + filters["fromDate"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("toDate"))
                {
                    query_condition += " and date(edited_date)<=STR_TO_DATE('" + filters["toDate"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("item"))
                {
                    query_condition += " and itb.itm_id='" + filters["item"] + "'";
                }
            }

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            string jsonResponse = "";
            // double numrows = 0;
            countQry = " SELECT eh.itbs_id FROM tbl_edit_history eh "
 + " INNER JOIN tbl_itembranch_stock itb ON itb.itbs_id=eh.itbs_id "
 + " INNER JOIN tbl_user_details ud ON ud.user_id=eh.edited_by"
 + " INNER JOIN tbl_sales_master sm ON sm.sm_id=eh.sm_id INNER JOIN tbl_branch tb ON tb.branch_id=sm.branch_id " + query_condition
 + " GROUP BY eh.edited_by,itb.itm_id ORDER BY itb.itbs_id ASC";
            //  countQry = countQry + "  

            DataTable dtcount = new DataTable();
            dtcount = db.SelectQuery(countQry);
            int numrows = 0;
            numrows = dtcount.Rows.Count;
            if (numrows == 0)
            {
                return "N";
            }
            DataTable dt1 = new DataTable();
            innerqry = " SELECT itb.itm_name as Item,itb.itm_code as ItemCode,"
 + " SUM(eh.si_qty+eh.si_foc)  as 'Total Old Qty',"
 + " SUM(eh.new_si_qty+eh.new_si_foc)  as 'Total New Qty',"
 + " (SUM(eh.new_si_qty+eh.new_si_foc)-SUM(eh.si_qty+eh.si_foc)) as 'Total Change_in Qty',"
 + " SUM(eh.si_qty) as old_qty,"
 + " SUM(eh.new_si_qty) as new_qty,"
 + " (SUM(eh.new_si_qty)-SUM(eh.si_qty)) as change_in_qty,"
 + " SUM(eh.si_foc) as old_foc,"
 + " SUM(eh.new_si_foc) as new_foc,"
 + " (SUM(eh.new_si_foc)-SUM(eh.si_foc)) as change_in_foc,"
 + " CONCAT(ud.first_name,' ',ud.last_name) as user,branch_name as Branch FROM tbl_edit_history eh "
 + " INNER JOIN tbl_itembranch_stock itb ON itb.itbs_id=eh.itbs_id "
 + " INNER JOIN tbl_user_details ud ON ud.user_id=eh.edited_by"
 + " INNER JOIN tbl_sales_master sm ON sm.sm_id=eh.sm_id INNER JOIN tbl_branch tb ON tb.branch_id=sm.branch_id " + query_condition
 + " GROUP BY eh.edited_by,itb.itm_id ORDER BY itb.itbs_id ASC ";

            HttpContext.Current.Session["downloadqry"] = innerqry;
            return "Y";

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }

    }
    //Stop: download Reports in reports.aspx

    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT branch_id,branch_name FROM tbl_branch";
        query = query + " order by branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end warehouse show

    [WebMethod]
    public static string showUsers()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select user_id,CONCAT(first_name,' ',last_name) as name from tbl_user_details order by name";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }
    //stop: Listing salesperson in Reports page

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteData(string variable, string BranchId)
    {

        List<string> itemNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string sqlQuery = "select itm_id,TRIM(TRAILING '\r' FROM itm_name) as item from tbl_item_master tim left join tbl_item_brand tib on tib.brand_id=tim.itm_brand_id left join tbl_item_category tic on tic.cat_id=tim.itm_category_id where itm_name like '%" + variable + "%' ";
        DataTable dt = db.SelectQuery(sqlQuery);
        if (dt.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["itm_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["item"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["item"]) + "\"}");

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

}