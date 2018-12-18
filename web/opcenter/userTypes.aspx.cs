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

public partial class opcenter_managerole : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication userType = new LoginAuthentication();
        userType.userAuthentication();
        userType.checkPageAcess(23);
    }

    [WebMethod]//serach users
    public static string searchUserTypes(int page, int perpage)
    {
        try
        {
            string query_condition = " where 1=1";
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) FROM tbl_user_type ";

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT usertype_id,usertype_name as name"
                + " from tbl_user_type" + query_condition;

            innerqry = innerqry + " order by usertype_name asc LIMIT " + offset.ToString() + " ," + per_page;

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

    [WebMethod]
    public static string addUserType(string UserType_name, string type, string userTypeId)
    {
        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        if (type == "0")
        {

            string qry = "select MAX(usertype_id) as usertype_id from tbl_user_type";
            dt = db.SelectQuery(qry);
            Int32 UserTypeId = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["usertype_id"] is DBNull)
                    {
                        UserTypeId = ++UserTypeId;
                    }
                    else
                    {
                        UserTypeId = Convert.ToInt32(dt.Rows[0]["usertype_id"]);
                        UserTypeId = ++UserTypeId;
                    }
                }

            }
            else
            {
                UserTypeId = ++UserTypeId;
            }
            query = "INSERT INTO tbl_user_type (usertype_id, usertype_name)";
            query = query + "VALUES ('" + UserTypeId + "','" + UserType_name + "')";
        }
        else
        {
            int numrows=Convert.ToInt32(db.SelectScalar("select count(usertype_id) from tbl_user_type where usertype_id=" + userTypeId));
            if (numrows == 0)
            {
                resultStatus = "N";
            }
            else
            {
                query = "update tbl_user_type set usertype_name='" + UserType_name + "' where usertype_id=" + userTypeId;
            }
        }
        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }

        return resultStatus;
    }

    [WebMethod]
    public static string removeUserType(string UserType_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numUserCount = 0;

        string BranchQuery = "SELECT COUNT(user_type) FROM tbl_user_details  WHERE  user_type='" + UserType_id + "' ";
        numUserCount = Convert.ToInt32(db.SelectScalar(BranchQuery));

        if (numUserCount == 0)
        {
            query = "DELETE FROM tbl_user_type ";
            query = query + "WHERE usertype_id='" + UserType_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }
}