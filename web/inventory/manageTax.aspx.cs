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

public partial class inventory_manageTax : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication tax = new LoginAuthentication();
        tax.userAuthentication();
        tax.checkPageAcess(40);
    }
    [WebMethod]//serach users
    public static string searchTaxes(int page, int perpage,string search)
    {
        try
        {
            string query_condition = " where 1=1";
            if (search != "")
            {
                query_condition += " and (tp_tax_title like '%" + search + "%') ";
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) FROM tbl_tax_profile" + query_condition ;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT tp_tax_code, tp_tax_title as name,tp_tax_percentage as rate"
                + " from tbl_tax_profile" + query_condition;

            innerqry = innerqry + " order by tp_tax_title asc LIMIT " + offset.ToString() + " ," + per_page;

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
    public static string addTaxMethod(string taxcode, string taxtitle, string taxtype, string taxrate, string cess, string type, string updateId,string sessionId)
    {
        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        // CKECKING SESSION
        string getsessionexist = "select tp_sessionId from tp_tax_title where tp_sessionId='" + sessionId + "'";
        DataTable dtsession = db.SelectQuery(getsessionexist);
        int sess_rows = dtsession.Rows.Count;

        if (sess_rows != 0)  // ALREADY SAVED CASE
        {
            db.RollBackTransaction();
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Tax saved already\"}";
        }
        else
        {
            if (type == "0")
            {
                query = "INSERT INTO tbl_tax_profile (tp_parent,tp_tax_title,tp_tax_type,tp_tax_percentage,tp_cess,tp_sessionId)";
                query = query + "VALUES (0,'" + taxtitle + "','" + taxtype + "'," + taxrate + "," + cess + "," + sessionId + ")";
            }
            else
            {
                int numrows = Convert.ToInt32(db.SelectScalar("select count(tp_tax_code) from tbl_tax_profile where tp_tax_code=" + updateId));
                if (numrows == 0)
                {
                    resultStatus = "N";
                }
                else
                {
                    query = "update tbl_tax_profile set tp_tax_title='" + taxtitle + "',tp_tax_type='" + taxtype + "',tp_tax_percentage='" + taxrate + "',tp_cess='" + cess + "' where tp_tax_code=" + updateId;
                }
            }
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }
       

        return resultStatus;
    }

    [WebMethod]//serach users
    public static string SelectData(int id)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            DataTable dt1 = new DataTable();
           string countQry = "SELECT count(tp_tax_code) FROM tbl_tax_profile where tp_tax_code=" + id;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "N";
            }

            else
            {
                string selectQry = "select * from tbl_tax_profile where tp_tax_code=" + id;

                DataTable dt = db.SelectQuery(selectQry);

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
           

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }//end
}