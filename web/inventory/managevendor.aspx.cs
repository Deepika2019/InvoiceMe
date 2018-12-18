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

public partial class inventory_managevendor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication vendor = new LoginAuthentication();
        vendor.userAuthentication();
        vendor.checkPageAcess(20);
    }
    //show vendor data
    [WebMethod]
    public static string showVendorDetails(string vendorid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select * from tbl_vendor where vn_id=" + vendorid + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    // update vendor details
    [WebMethod]
    public static string updateVendorDetails(string vendor_id, string Name, string mobile, string telephone, string Emailid, string Address, string City, string State, string Country,string gst)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        bool query;
        String resultStatus;
        resultStatus = "N";

        string checkuserqry = "SELECT COUNT(*) FROM tbl_vendor WHERE vn_id='" + vendor_id + "' ";
        Int32 qryCount = Convert.ToInt32(db.SelectScalar(checkuserqry));
        if (qryCount != 1)
        {
            resultStatus = "E";
        }
        else
        {
            string updateQuery = "";
            updateQuery = "UPDATE tbl_vendor  SET vn_name='" + Name + "', vn_address='" + Address + "', vn_city='" + City + "', vn_state='" + State + "',  	vn_country='" + Country + "', vn_phone1='" + mobile + "', vn_phone2='" + telephone + "', vn_email='" + Emailid + "',vn_gst='"+gst+"' ";
            updateQuery = updateQuery + " WHERE vn_id='" + vendor_id + "' ";

            query = db.ExecuteQuery(updateQuery);
            if (query)
            {
                //string noteqey = "update specialnote set username='" + Firstname + " " + Lastname + "' where user_id='" + user_id + "' ";
                //db.ExecuteQuery(noteqey);
                resultStatus = "Y";
            }
        }
        return resultStatus;
    }

    //list purchase Entries
    [WebMethod]
    public static string showpurchaseEntries(int page, string vendorid, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = " where 1=1 and tp.vn_id =" + vendorid + "";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (tp.pm_invoice_no  like '" + filters["search"] + "%' )";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            string countQry = "SELECT count(*) FROM tbl_purchase_master tp inner join tbl_user_details tud on tud.user_id =tp.pm_userid" + query_condition+" and pm_id=pm_ref_no";

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            string innerqry = "SELECT pm_id,pm_invoice_no,DATE_FORMAT(pm_date,'%d-%b-%Y') AS entryDate,pm_netamount,sum(cr)-sum(dr) as pm_balance,concat(first_name,\" \",last_name) as name from tbl_purchase_master tp";
            innerqry = innerqry + " inner join tbl_user_details tud on tud.user_id=tp.pm_userid inner join tbl_transactions tr on (tr.action_ref_id=tp.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ") ";
            innerqry = innerqry + query_condition + " and pm_id=pm_ref_no";
            innerqry = innerqry + " group by action_ref_id,action_type order by pm_date desc LIMIT " + offset.ToString() + " ," + per_page;

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