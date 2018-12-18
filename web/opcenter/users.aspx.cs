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

public partial class opcenter_users : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication users = new LoginAuthentication();
        users.userAuthentication();
        users.checkPageAcess(21);
    }
    [WebMethod]// branch show
    public static string getBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
       // string query = "select branch_id,branch_name from tbl_branch";
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


    // Adding users
    [WebMethod]
    public static string addUserDetails(string Firstname, string Lastname, string Username, string Password, string Usertype, string Usertypename, string Phone, string Emailid, string Country, string Location, string Address, string UserImage, string branch_id)
    {


        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        String resultStatus;
        resultStatus = "N";
        string checkuserqry = "SELECT COUNT(*) FROM tbl_user_details WHERE user_name='" + Username + "' and password='" + Password + "' ";
        Int32 qryCount = Convert.ToInt32(db.SelectScalar(checkuserqry));
        if (qryCount == 1)
        {
            resultStatus = "E";
        }
        else
        {
            string quermaxnote = "select MAX(id) as id from tbl_user_details";
            dt = db.SelectQuery(quermaxnote);
            Int32 Id = 0;
            Int32 user_id = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["id"] is DBNull)
                    {
                        Id = 1;
                    }
                    else
                    {
                        Id = Convert.ToInt32(dt.Rows[0]["id"]);
                        Id = ++Id;
                    }

                }

            }
            else
            {
            }


            bool query;
            string brquery = "";
            var year1 = DateTime.Now.ToString("yy");
            var month1 = DateTime.Now.ToString("MM");
            var day1 = DateTime.Now.ToString("dd");
            // user_id = "Y" + year1 + "M" + month1 + "D" + day1 + "U" + Id;
            user_id = Id;

            brquery = "INSERT INTO tbl_user_details(id, user_id, first_name, last_name, user_name, password, user_type, user_type_name, phone, emailid, country, location, address, user_image) ";
            brquery = brquery + "VALUES('" + Id + "','" + user_id + "','" + Firstname + "','" + Lastname + "','" + Username + "','" + Password + "','" + Usertype + "','" + Usertypename + "','" + Phone + "','" + Emailid + "','" + Country + "','" + Location + "','" + Address + "','" + UserImage + "')";


            query = db.ExecuteQuery(brquery);
            if (query)
            {
                resultStatus = "Y";
            }

        }
        return resultStatus;
    }





    [WebMethod]//serach users
    public static string searchUsers(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = " where 1=1";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (user_id like '" + filters["search"] + "%' or first_name like '%" + filters["search"] + "%' or last_name like '%" + filters["search"] + "%' or phone like '" + filters["search"] + "%')";
                }
                //if (filters.ContainsKey("branch"))
                //{
                //    query_condition += " and branch_id='" + filters["branch"] + "'";
                //}
                if (filters.ContainsKey("user_type"))
                {
                    query_condition += " and user_type='" + filters["user_type"] + "'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) FROM tbl_user_details " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT user_id,concat(first_name,\" \",last_name) as name,user_type_name,phone,location"
                + " from tbl_user_details" + query_condition;

            innerqry = innerqry + " order by first_name asc LIMIT " + offset.ToString() + " ," + per_page;

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
}