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
public partial class inventory_sales_commission : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication commission = new LoginAuthentication();
        commission.userAuthentication();
        commission.checkPageAcess(15);
    }
    [WebMethod]
    public static string showBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select tb.branch_id,branch_name,branch_countryid from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
      //  string query = "SELECT branch_id,branch_name,branch_countryid FROM tbl_branch order by branch_id ";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["branch_id"] is DBNull)
                {
                    sb.Append("<option value='0' >--All Warehouse--</option>");
                }
                else
                {
                    sb.Append("<option value='0' >--All Warehouse--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        sb.Append("<option value='" + dt.Rows[i]["branch_id"] + "'>" + dt.Rows[i]["branch_name"] + "</option>");
                    }
                }
            }
            else
            {
                sb.Append("<option value='0' >--All Warehouse--</option>");
            }
        }

        return sb.ToString();

    }// end branch show
    [WebMethod]
    public static string showBrands()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT brand_id, brand_name FROM tbl_item_brand ORDER BY brand_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["brand_id"] is DBNull)
                {
                    //sb.Append("<select id='comboBrandtype' style='width:100px;margin-top:6px; margin-left:0px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                   // sb.Append("</select>");
                }
                else
                {
                    //sb.Append("<select id='comboBrandtype' style='width:100px;margin-top:6px; margin-left:0px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["brand_id"] + "'>" + dt.Rows[i]["brand_name"] + "</option>");

                    }
                   // sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                //sb.Append("<select id='comboBrandtype'>");
                //sb.Append("</select>");
            }
        }

        return sb.ToString();
    }
    [WebMethod]
    public static string showCategoryTypes()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT cat_id, cat_name FROM tbl_item_category ORDER BY cat_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["cat_id"] is DBNull)
                {
                    //sb.Append("<select id='combocategory' style='width:100px;margin-top:6px; margin-left:0px;' class='normaltextbg' onchange='javascript:loadsubcategory();'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                    //sb.Append("<select id='combocategory' style='width:100px;margin-top:6px; margin-left:0px;' class='normaltextbg' onchange='javascript:loadsubcategory();'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                    //sb.Append("</select>");
                }
            }
            else
            {
               // sb.Append("<select id='combocategory' style='width:100px;margin-top:6px;' class='normaltextbg' onchange='javascript:loadsubcategory();'>");
                sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                //sb.Append("</select>");
            }
        }

        return sb.ToString();
    }
    [WebMethod]
    public static string showSubCategoryTypes(string categoryVal)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT cat_id, cat_name FROM tbl_item_category where parent_id=" + categoryVal + " ORDER BY cat_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["cat_id"] is DBNull)
                {
                    sb.Append("<option value='-1' selected='selected'>--Sub Category--</option>");
                }
                else
                {
                    sb.Append("<option value='-1' selected='selected'>--Sub Category--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                }
            }
            else
            {
                sb.Append("<option value='-1' selected='selected'>--Sub Category--</option>");
            }
        }

        return sb.ToString();
    }
    [WebMethod]
    public static string searchSalescommission(int page, Dictionary<string, string> commissionfilters, int perpage)
    {
        try
        {
            string query_condition = "";
            if (commissionfilters.Count > 0)
            {
                query_condition = " where 1=1";
                if (commissionfilters.ContainsKey("itm_code"))
                {
                    query_condition += " and itm_code LIKE '" + commissionfilters["itm_code"] + "%'";
                }
                if (commissionfilters.ContainsKey("itm_name"))
                {
                    query_condition += " and itm_name LIKE '" + commissionfilters["itm_name"] + "%'";
                }
                if (commissionfilters.ContainsKey("itm_class_two"))
                {
                    query_condition += " and itm_class_two LIKE '" + commissionfilters["itm_class_two"] + "%'";
                }
                if (commissionfilters.ContainsKey("itm_class_three"))
                {
                    query_condition += " and itm_class_three LIKE '" + commissionfilters["itm_class_three"] + "%'";
                }
                if (commissionfilters.ContainsKey("itm_commision"))
                {
                    query_condition += " and itm_commision LIKE '" + commissionfilters["itm_commision"] + "%'";
                }
                if (commissionfilters.ContainsKey("itm_class_one"))
                {
                    query_condition += " and itm_class_one LIKE '" + commissionfilters["itm_class_one"] + "%'";
                }
                if (commissionfilters.ContainsKey("warehouseid"))
                {
                    query_condition += " and (branch_id='" + commissionfilters["warehouseid"] + "')";
                }
                if (commissionfilters.ContainsKey("brandid"))
                {
                    query_condition += " and (itm_brand_id='" + commissionfilters["brandid"] + "')";
                }
                if (commissionfilters.ContainsKey("categoryid"))
                {
                    query_condition += " and (itm_category_id='" + commissionfilters["categoryid"] + "')";
                }
                if (commissionfilters.ContainsKey("subcategoryid"))
                {
                    query_condition += " and (itm_subcategory_id='" + commissionfilters["subcategoryid"] + "')";
                }
            }
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            StringBuilder sb = new StringBuilder();
            double per_page = perpage;
            double offset = (page - 1) * per_page;
            string innerqry = "";
            double numrows = 0;
            string countQry = " select Count(*) ";
            countQry = countQry + " from tbl_itembranch_stock ";
            countQry = countQry + " " + query_condition;
            numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            if (perpage == 0)
            {
                per_page = numrows;
            }
            innerqry = "SELECT itbs_id,itm_code,itm_name,itm_class_one,itm_class_two,itm_class_three,itm_commision from tbl_itembranch_stock ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + "order by itbs_id  LIMIT " + offset.ToString() + " ," + per_page;
            dt = db.SelectQuery(innerqry);
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

            return jsonResponse;
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }
    [WebMethod]
    public static string updateCommission(string commission, string resultString, int rowValue)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string resultStatus = "N";
        string query = "";
        bool queryStatus;
        String[] rowsString = resultString.Split(new[] { "@#$" }, StringSplitOptions.RemoveEmptyEntries);
        int length = rowsString.Length;
        foreach (string data in rowsString)
        {
            query = "UPDATE  tbl_itembranch_stock SET itm_commision='" + commission + "' WHERE itbs_id='" + data + "'";
            queryStatus = db.ExecuteQuery(query);
        }
        resultStatus = "Y";
    
        return resultStatus.ToString();
    }
}