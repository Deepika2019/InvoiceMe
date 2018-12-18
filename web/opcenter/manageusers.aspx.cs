using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Web.Services;
using System.Data;
using commonfunction;
using Newtonsoft.Json;

public partial class opcenter_manageusers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication users = new LoginAuthentication();
        users.userAuthentication();
        users.checkPageAcess(22);
    }
  
    //show user data
    [WebMethod]
    public static string showUserDetails(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select first_name,last_name,concat(first_name,\" \",last_name) as name,emailid,user_type_name,tu.phone,tu.user_name,tu.password,tu.address,tu.location,tu.country,user_type from  tbl_user_details tu where user_id=" + userid + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    //show user data
    [WebMethod]
    public static string showCustomerlist(int page,string userid,Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = " where 1=1 and tc.user_id="+userid+"";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (tc.cust_id like '" + filters["search"] + "%' or tc.cust_name like '%" + filters["search"] + "%' or tc.cust_phone like '" + filters["search"] + "%')";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            string countQry = "SELECT count(*) FROM tbl_customer tc inner join tbl_user_details tud on tud.user_id=tc.user_id " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string innerqry = "SELECT cust_id,cust_name,cust_amount,cust_phone from tbl_customer tc";
            innerqry = innerqry + " inner join tbl_user_details tud on tud.user_id=tc.user_id ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + " order by cust_id asc LIMIT " + offset.ToString() + " ," + per_page;

            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));


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
    }//end

    [WebMethod]// branch show
    public static string getBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select branch_id,branch_name from tbl_branch";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// UserType show
    public static string getUserTypes()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select usertype_id,usertype_name from tbl_user_type";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    // update user details
    [WebMethod]
    public static string updateUserDetails(string user_id, string Firstname, string Lastname, string Username, string Password, string Usertype, string Usertypename, string Phone, string Emailid, string Country, string Location, string Address,string branch_id)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        bool query;
        String resultStatus;
        resultStatus = "N";

        string checkuserqry = "SELECT COUNT(*) FROM tbl_user_details WHERE user_name='" + Username + "' and password='" + Password + "' and user_id!='" + user_id + "' ";
        Int32 qryCount = Convert.ToInt32(db.SelectScalar(checkuserqry));
        if (qryCount == 1)
        {
            resultStatus = "E";
        }
        else
        {
            string brquery = "";
            brquery = "UPDATE tbl_user_details  SET first_name='" + Firstname + "', last_name='" + Lastname + "', user_name='" + Username + "', password='" + Password + "', user_type='" + Usertype + "', user_type_name='" + Usertypename + "', phone='" + Phone + "', emailid='" + Emailid + "', country='" + Country + "', location='" + Location + "', address='" + Address + "' ";
            brquery = brquery + " WHERE user_id='" + user_id + "' ";

            query = db.ExecuteQuery(brquery);
            if (query)
            {
                //string noteqey = "update specialnote set username='" + Firstname + " " + Lastname + "' where user_id='" + user_id + "' ";
                //db.ExecuteQuery(noteqey);
                resultStatus = "Y";
            }
        }
        return resultStatus;
    }

    [WebMethod]//add assign customers
    public static string addAssignCustomer(string userid, int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = " where 1=1 and tc.user_id!=" + userid + "";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (tc.cust_id like '" + filters["search"] + "%' or tc.cust_name like '%" + filters["search"] + "%' or tu.first_name like '%" + filters["search"] + "%' or tu.last_name like '" + filters["search"] + "%')";
                }       
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) FROM tbl_customer tc inner join tbl_user_details tu on tu.user_id=tc.user_id " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT tc.cust_id,tc.cust_name,concat(tu.first_name,\" \",tu.last_name) as name FROM tbl_customer"
                + "  tc inner join tbl_user_details tu on tu.user_id=tc.user_id" + query_condition;

            innerqry = innerqry + " order by tc.cust_name asc LIMIT " + offset.ToString() + " ," + per_page;

            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));


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
    }//end

    [WebMethod]//add assign customers
    public static string updateAssignCustomer(string userid, string[] customers)
    {
        try
        {
            bool  queryStatus=false;
            mySqlConnection db = new mySqlConnection();
            List<int> customarray = customers.Select(x => int.Parse(x)).ToList<int>();
            foreach (var customer in customarray)
            {
                string qry = "update tbl_customer set user_id="+userid+" WHERE cust_id ='" + customer + "'";
                queryStatus = db.ExecuteQuery(qry);
            }
            if (queryStatus)
            {
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end


    [WebMethod]
    public static string listWarehouses(string userid)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();

            string countQry = "SELECT count(distinct tb.branch_id) from tbl_branch tb left join tbl_user_branches ub on ub.branch_id=tb.branch_id where tb.branch_id NOT IN (select branch_id from tbl_user_branches where user_id=" + userid+")";
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string query = "SELECT distinct tb.branch_id,branch_name from tbl_branch tb left join tbl_user_branches ub on ub.branch_id=tb.branch_id where tb.branch_id NOT IN (select branch_id from tbl_user_branches where user_id=" + userid + ")";

            DataTable dt = db.SelectQuery(query);

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


    [WebMethod]//add assign warehouses
    public static string updateAssignWarehouses(string userid, string[] warehouses)
    {
        try
        {
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntryTimeZone"].Value));
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string updated_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            List<int> warehousearray = warehouses.Select(x => int.Parse(x)).ToList<int>();
            foreach (var warehouse in warehousearray)
            {
                db.ExecuteQuery("update tbl_itembranch_stock SET itm_last_update_date='" + updated_date + "' where branch_id=" + warehouse + "");
                string qry = "INSERT INTO  tbl_user_branches(user_id, branch_id) VALUES ('" + userid + "'," + warehouse + ")";
                queryStatus = db.ExecuteQuery(qry);
            }
            if (queryStatus)
            {
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end

    [WebMethod]
    public static string showAssignWarehouses(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string countQry = "SELECT count(*) from tbl_user_branches ub inner join tbl_branch tb on tb.branch_id=ub.branch_id where user_id=" + userid;

        double numrows = Convert.ToInt32(db.SelectScalar(countQry));

        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }
        string query = "select tb.branch_name,ub_id from tbl_user_branches ub inner join tbl_branch tb on tb.branch_id=ub.branch_id where user_id=" + userid;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
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

    [WebMethod]//add unassign buttons
    public static string removeAssignWarehouse(string ubId)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            int numrows = Convert.ToInt32(db.SelectScalar("select count(ub_id) from tbl_user_branches where ub_id=" + ubId + ""));
            if (numrows != 0)
            {
                db.ExecuteQuery("delete from tbl_user_branches where ub_id=" + ubId + "");
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end

    [WebMethod]
    public static string removeAssignLocation(string ulId)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            int numrows = Convert.ToInt32(db.SelectScalar("select count(ul_id) from tbl_user_locations where ul_id=" + ulId + ""));
            if (numrows != 0)
            {
                db.ExecuteQuery("delete from tbl_user_locations where ul_id=" + ulId + "");
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end

    [WebMethod]
    public static string showAssignLocations(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string countQry = "SELECT count(*) from tbl_user_locations ul inner join tbl_location tl on tl.location_id=ul.location_id where user_id=" + userid;

        double numrows = Convert.ToInt32(db.SelectScalar(countQry));

        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }
        string query = "select tl.location_name,ul_id from tbl_user_locations ul inner join tbl_location tl on tl.location_id=ul.location_id where user_id=" + userid;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
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

    [WebMethod]//add assign locations
    public static string updateAssignLocations(string userid, string[] locations)
    {
        try
        {
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntryTimeZone"].Value));
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string updated_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            List<int> locationarray = locations.Select(x => int.Parse(x)).ToList<int>();
            foreach (var location in locationarray)
            {
                db.ExecuteQuery("update tbl_customer SET cust_last_updated_date='" + updated_date + "' where location_id="+location+"");
                string qry = "INSERT INTO  tbl_user_locations(user_id, location_id) VALUES ('" + userid + "'," + location + ")";
                queryStatus = db.ExecuteQuery(qry);
            }
            if (queryStatus)
            {
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end

    [WebMethod]
    public static string listLocations(string userid, int dis_id)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            string condition = "";
            if (dis_id == -1)
            {
                condition = "";
            }
            else
            {
                condition = " and dist_id=" + dis_id + "";
            }
            string countQry = "SELECT count(distinct tl.location_id) from tbl_location tl left join tbl_user_locations ul on ul.location_id=tl.location_id where tl.location_id NOT IN (select location_id from tbl_user_locations where 1  and user_id=" + userid + " )" + condition + "";
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string query = "SELECT distinct tl.location_id,location_name from tbl_location tl left join tbl_user_locations ul on ul.location_id=tl.location_id where tl.location_id NOT IN (select location_id from tbl_user_locations where 1  and user_id=" + userid + ") " + condition + "";

            DataTable dt = db.SelectQuery(query);

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
    [WebMethod]// district list show
    public static string loadDistricts()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select dis_id, dis_name from tbl_district";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end
}