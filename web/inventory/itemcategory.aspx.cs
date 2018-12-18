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

public partial class inventory_itemcategory : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication category = new LoginAuthentication();
        category.userAuthentication();
        category.checkPageAcess(18);
    }
    //search category
    [WebMethod]
    public static string searchCategory(int page, Dictionary<string, string> filters, int perpage)
    {

        try
        {
            string query_condition = " where 1=1";
           
            if (filters.Count > 0)
            {
                
                if (filters.ContainsKey("cat_id"))
                {             
                    query_condition += " and  cat_id='" + filters["cat_id"] + "'";
                }

                if (filters.ContainsKey("cat_name"))
                {
                    // query_condition += " and  cat_name='" + filters["cat_name"] + "'";
                    query_condition += " and  cat_name  LIKE '%" + filters["cat_name"] + "%'";
                }

               /* if (filters.ContainsKey("search"))
                {
                    query_condition += " and (cat_id like '" + filters["search"] + "%' or cat_name like '%" + filters["search"] + "%')";
                }*/
            
            
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            DataTable dt = new DataTable();
            countQry = "SELECT count(*) FROM tbl_item_category " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            innerqry = "SELECT cat_id,cat_name,parent_id  from tbl_item_category";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + " order by cat_id LIMIT " + offset.ToString() + " ," + per_page;
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
        
        }catch (Exception ex)
        {
            return ex.ToString();
        }

        }//end search

    // Start edit

    [WebMethod]
    public static string editcategorydetail(string categoryid)
    {

        mySqlConnection db = new mySqlConnection();
        string qry = "SELECT  * FROM tbl_item_category where cat_id='" + categoryid + "' ";
        DataTable dt = db.SelectQuery(qry);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {

            sb.Append("" + dt.Rows[i]["cat_id"] + "@#$" + dt.Rows[i]["cat_name"] + "@#$" + dt.Rows[i]["parent_id"]);
        }

        //" '" + dt.Rows[i]["servicecode"] + "','" + dt.Rows[i]["servicedescription"] + "','" + dt.Rows[i]["servicegroup"] + "','" + dt.Rows[i]["serviceperiod"] + "','" + dt.Rows[i]["servicetype"] + "','" + dt.Rows[i]["serviceprice"] + "','" + dt.Rows[i]["servicesession"] + "','" + dt.Rows[i]["CountryId"] + "','" + dt.Rows[i]["Tax"] + "' ";

        return sb.ToString();

    }
    
    
    
    //end

    //start loading parent 
    [WebMethod]
    public static string loadparentcategory()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string jsonResponse = "";
        string selectCategoryQry = "select cat_id,cat_name from tbl_item_category";
        dt = db.SelectQuery(selectCategoryQry);
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        return jsonResponse;

    }


    //end

    [WebMethod]
    public static string AddCategory(string actionType, string categoryid, string categoryname, string parentcategoryId)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();

        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {


            string qry = "select MAX(cat_id) as id from  tbl_item_category";
            dt = db.SelectQuery(qry);
            Int32 catid = 0;
            if (dt != null)
            {
                if (dt.Rows[0][0] is DBNull)
                {
                    catid = ++catid;
                }
                else
                {
                    catid = Convert.ToInt32(dt.Rows[0][0]);
                    catid = ++catid;
                }
            }
            else
            {
                catid = ++catid;
            }

          query = "INSERT INTO tbl_item_category (cat_id,parent_id,cat_name)";
           query = query + "VALUES ('" + catid + "','" + parentcategoryId + "','" + categoryname + "')";

        }


        if (actionType == "update")
        {
            //query = "UPDATE tbl_item_category SET ";
           // query = query + "cat_name='" + categoryname + "' WHERE cat_id='" + categoryid + "' ";
            query = "UPDATE tbl_item_category SET ";
            query = query + "cat_name='" + categoryname + "' ,parent_id='" + parentcategoryId + "' WHERE cat_id='" + categoryid + "' ";
            db.ExecuteQuery("update tbl_itembranch_stock set itm_last_update_date='" + updatedDate + "' where itm_category_id =" + categoryid + "");

        }

        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");


        return resultStatus;
    }

    
     
}