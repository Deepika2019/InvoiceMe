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

public partial class opcenter_managerole : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication manageRole = new LoginAuthentication();
        manageRole.userAuthentication();
        manageRole.checkPageAcess(24);
    }

    [WebMethod]
    public static string getUsers(string userTypeid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string countQry = "SELECT count(*),usertype_name from tbl_user_type ut inner join tbl_user_details ud on ud.user_type=ut.usertype_id where usertype_id=" + userTypeid;

        double numrows = Convert.ToInt32(db.SelectScalar(countQry));

        if (numrows == 0)
        {
            DataTable nameDt = new DataTable();
            nameDt=db.SelectQuery("select usertype_name from tbl_user_type where usertype_id="+userTypeid);
            return "{\"count\":\"" + numrows + "\",\"name\":\"" + nameDt.Rows[0]["usertype_name"] + "\",\"data\":[]}"; ;
        }
        string query = "select concat(first_name,\" \",last_name) as name,user_id,usertype_name from tbl_user_type ut inner join tbl_user_details ud on ud.user_type=ut.usertype_id where usertype_id=" + userTypeid + "";
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

    [WebMethod]
    public static string showAssignPages(string userTypeid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string countQry = "SELECT count(*) from tbl_user_permissions up inner join tbl_page_links pl on pl.page_id=up.page_id where user_type=" + userTypeid;

        double numrows = Convert.ToInt32(db.SelectScalar(countQry));

        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }
        string query = "select page_name,important,pl.page_id from tbl_user_permissions up inner join tbl_page_links pl on pl.page_id=up.page_id where user_type=" + userTypeid + " order by page_category";
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

    [WebMethod]
    public static string listPages(string userTypeid)
    {
        try
        {           
            mySqlConnection db = new mySqlConnection();
            string countQry = "SELECT count(distinct pl.page_id) from tbl_page_links pl left join tbl_user_permissions up on up.page_id=pl.page_id where pl.page_id NOT IN (select page_id from tbl_user_permissions where user_type=" + userTypeid + ")";
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string query = "select distinct pl.page_id,page_name from tbl_page_links pl left join tbl_user_permissions up on up.page_id=pl.page_id where pl.page_id NOT IN (select page_id from tbl_user_permissions where user_type="+userTypeid+")";

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

    [WebMethod]//add assign pages
    public static string updateAssignPages(string userTypeid, string[] pages)
    {
        try
        {
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();
            List<int> pagearray = pages.Select(x => int.Parse(x)).ToList<int>();
            foreach (var page in pagearray)
            {
                string qry = "INSERT INTO  tbl_user_permissions(user_type, page_id, read_action, write_action) VALUES ('" + userTypeid + "','" + page + "','1','1')";
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

    [WebMethod]//add unassign pages
    public static string removeAssignPages(string userTypeid, string pageId)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            int numrows = Convert.ToInt32(db.SelectScalar("select count(up_id) from tbl_user_permissions where user_type=" + userTypeid + " and page_id=" + pageId + ""));
            if (numrows != 0)
            {
                db.ExecuteQuery("delete from tbl_user_permissions where user_type=" + userTypeid + " and page_id=" + pageId + "");
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
    public static string listButtons(string userTypeid)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            string countQry = "SELECT count(distinct ub.ub_id) from tbl_user_buttons ub left join tbl_button_permission bp on bp.ub_id=ub.ub_id where ub.ub_id NOT IN (select ub_id from tbl_button_permission where user_type=" + userTypeid + ")";
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string query = "select distinct ub.ub_id,ub_button_name,page_name from tbl_user_buttons ub inner join tbl_page_links tp on tp.page_id=ub.page_id left join tbl_button_permission bp on bp.ub_id=ub.ub_id where ub.ub_id NOT IN (select ub_id from tbl_button_permission where user_type=" + userTypeid + ")";

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

    [WebMethod]//add assign pages
    public static string updateAssignButtons(string userTypeid, string[] buttons)
    {
        try
        {
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            List<int> buttonarray = buttons.Select(x => int.Parse(x)).ToList<int>();
            foreach (var button in buttonarray)
            {
                string selPageIDqry = "select page_id from tbl_user_buttons where ub_id=" + button;
                dt = db.SelectQuery(selPageIDqry);
                string qry = "INSERT INTO  tbl_button_permission(ub_id,user_type, page_id) VALUES ('" + button + "','" + userTypeid + "'," + dt.Rows[0]["page_id"] + ")";
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
    public static string showAssignButtons(string userTypeid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string countQry = "SELECT count(*) from tbl_button_permission bp inner join tbl_user_buttons ub on ub.ub_id=bp.ub_id where user_type=" + userTypeid;

        double numrows = Convert.ToInt32(db.SelectScalar(countQry));

        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }
        string query = "select tp.page_name,ub_button_name,bp_id from tbl_button_permission bp inner join tbl_user_buttons ub on ub.ub_id=bp.ub_id inner join tbl_page_links tp on tp.page_id=ub.page_id where user_type=" + userTypeid + " order by bp.ub_id";
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
    public static string removeAssignButtons(string buttonId)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            int numrows = Convert.ToInt32(db.SelectScalar("select count(bp_id) from tbl_button_permission where bp_id=" + buttonId + ""));
            if (numrows != 0)
            {
                db.ExecuteQuery("delete from tbl_button_permission where bp_id=" + buttonId + "");
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

}