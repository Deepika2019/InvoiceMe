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

public partial class inventory_itembrand : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication brands = new LoginAuthentication();
        brands.userAuthentication();
        brands.checkPageAcess(17);
    }
    [WebMethod]
    public static string AddNewBrand(string actionType, string typeid, string brandname)
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

            string qry = "select MAX(brand_id) as brandId from tbl_item_brand";
            dt = db.SelectQuery(qry);
            Int32 brandId = 0;
            if (dt != null)
            {
                if (dt.Rows[0][0] is DBNull)
                {
                    brandId = ++brandId;
                }
                else
                {
                    brandId = Convert.ToInt32(dt.Rows[0][0]);
                    brandId = ++brandId;
                }
            }
            else
            {
                brandId = ++brandId;
            }
            String chk_qry = "SELECT count(*) FROM  tbl_item_brand WHERE (brand_name = '" + brandname + "')";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows > 0)
            {
                return "E";
            }
            else
            {

                query = "INSERT INTO tbl_item_brand (brand_id, brand_name)";
                query = query + "VALUES ('" + brandId + "','" + brandname + "')";
            }

        }


        if (actionType == "update")
        {
            String chk_qry = "SELECT count(*) FROM  tbl_item_brand WHERE (brand_name = '" + brandname + "' and brand_id!='" + typeid + "')";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows > 0)
            {
                return "E";
            }
            else
            {
                query = "UPDATE tbl_item_brand SET ";
                query = query + "brand_name='" + brandname + "' WHERE brand_id='" + typeid + "' ";
                db.ExecuteQuery("update tbl_itembranch_stock set itm_last_update_date='" + updatedDate + "' where itm_brand_id=" + typeid + "");
            }
        }

        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
           // string up = "update tbl_itembranch_stock set itm_last_update_date='" + updatedDate + "' where itm_brand_id=" + typeid + "";
          
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");


        return resultStatus;
    }

    [WebMethod]
    public static string searchBrand(int page, Dictionary<string, string> filters, int perpage)
    {

        try
        {
            string query_condition = "";
            if (filters.Count > 0)
            {
                query_condition = " where 1=1";
                if (filters.ContainsKey("brand_id"))
                {
                    query_condition += " and brand_id LIKE  '%" + filters["brand_id"] + "%'";
                }

                if (filters.ContainsKey("brand_name"))
                {
                    query_condition += " and brand_name  LIKE '%" + filters["brand_name"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";

            countQry = "SELECT count(*) FROM tbl_item_brand " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT brand_id,brand_name from tbl_item_brand ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + "order by brand_id LIMIT " + offset.ToString() + " ," + per_page;

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

            return jsonResponse;

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    [WebMethod]
    public static string editbranddetail(string typeid)
    {

        mySqlConnection db = new mySqlConnection();
        string qry = "SELECT  * FROM tbl_item_brand  where brand_id='" + typeid + "' ";
        DataTable dt = db.SelectQuery(qry);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {

            sb.Append("" + dt.Rows[i]["brand_id"] + "@#$" + dt.Rows[i]["brand_name"]);
        }

        //" '" + dt.Rows[i]["servicecode"] + "','" + dt.Rows[i]["servicedescription"] + "','" + dt.Rows[i]["servicegroup"] + "','" + dt.Rows[i]["serviceperiod"] + "','" + dt.Rows[i]["servicetype"] + "','" + dt.Rows[i]["serviceprice"] + "','" + dt.Rows[i]["servicesession"] + "','" + dt.Rows[i]["CountryId"] + "','" + dt.Rows[i]["Tax"] + "' ";

        return sb.ToString();

    }

}