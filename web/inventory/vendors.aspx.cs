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

public partial class inventory_vendors : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication vendors = new LoginAuthentication();
        vendors.userAuthentication();
        vendors.checkPageAcess(19);
    }
    [WebMethod]//serach customers
    public static string searchSuppliers(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (vn_id like '" + filters["search"] + "%' or vn_name like '%" + filters["search"] + "%')";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) FROM tbl_vendor" + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT vn_id,vn_name,vn_city,vn_phone1"
                + " ,IFNULL(vn_balance,0) as vn_balance"
                + " from  tbl_vendor" + query_condition;

            innerqry = innerqry + " order by vn_id asc LIMIT " + offset.ToString() + " ," + per_page;

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

    // Adding users
    [WebMethod]
    public static string addVendorDetails(string Name, string mobile, string telephone, string Emailid, string Address, string City, string State, string Country, string gst)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        String resultStatus = "N";
        string brquery = "INSERT INTO tbl_vendor(vn_name, vn_address, vn_city, vn_state, vn_country, vn_phone1, vn_phone2, vn_email,vn_balance,vn_gst) ";
        brquery = brquery + "VALUES('" + Name + "','" + Address + "','" + City + "','" + State + "','" + Country + "','" + mobile + "','" + telephone + "','" + Emailid + "','0','"+gst+"')";
        if (db.ExecuteQuery(brquery))
        {
            resultStatus = "Y";
        }
        else
        {
            resultStatus = "E";
        }
        return resultStatus;
    }

    //delete vendor
    [WebMethod]
    public static string deleteVendor(string vendor_id)
    {

        String resultStatus = "N";
        bool queryStatus;
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numPurchaseCount = 0;
        string CheckQuery = "SELECT COUNT(pm_id) FROM tbl_purchase_master WHERE  vn_id='" + vendor_id + "' ";
        numPurchaseCount = Convert.ToInt32(db.SelectScalar(CheckQuery));

        if (numPurchaseCount == 0)
        {
            string deleteQuery = "DELETE FROM tbl_vendor ";
            deleteQuery = deleteQuery + "WHERE vn_id='" + vendor_id + "' ";
            queryStatus = db.ExecuteQuery(deleteQuery);
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