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

public partial class reports_customerDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(43);
    }
    [WebMethod]//serach customers
    public static string showCustomerReports(int page, Dictionary<string, string> filters, int perpage, string BranchName)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1";

            if (filters.Count > 0)
            {
              
                
                if (filters.ContainsKey("istoConfirm"))
                {
                    query_condition += " and ( new_custtype!='0'  or new_creditamt!='0' or new_creditperiod!='0')=1";
                }
                //if (filters.ContainsKey("branch"))
                //{
                //    query_condition += " and cu.branch_id='" + filters["branch"] + "'";
                //}
                if (filters.ContainsKey("account_status"))
                {
                    if (Convert.ToInt32(filters["account_status"]) == 0)
                    {
                        query_condition += " and cu.cust_amount=0";
                    }
                    else if (Convert.ToInt32(filters["account_status"]) == 1)
                    {
                        query_condition += " and cu.cust_amount>0";
                    }
                }
                if (filters.ContainsKey("cus_type"))
                {
                    query_condition += " and cu.cust_type='" + filters["cus_type"] + "'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*)  FROM tbl_customer cu " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; 
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT (CASE"
                + " WHEN cu.cust_type=1 THEN 'A'"
                + " WHEN cu.cust_type=2 THEN 'B'"
                 + " WHEN cu.cust_type=3 THEN 'C'"
                + " END) as cust_type, cu.cust_id,cu.cust_name,cu.cust_phone,cu.cust_address"
                + " ,IFNULL(cu.cust_amount,0) as outstanding_amount"
                + " ,CONCAT(ud.first_name,' ',ud.last_name) as seller_name"
                + " ,( new_custtype!='0'  or new_creditamt!='0' or new_creditperiod!='0') as is_to_confirm "
                + " from tbl_customer cu "
                + " left join tbl_user_details ud on ud.user_id=cu.user_id" + query_condition;

            innerqry = innerqry + " order by cu.cust_name asc LIMIT " + offset.ToString() + " ," + per_page;

            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            DataTable sumDt = db.SelectQuery("select IFNULL(sum(cust_amount),0) as total_balance from tbl_customer cu" + query_condition); 
            DataTable dt = db.SelectQuery(innerqry);

            string jsonResponse = "";
            if (dt.Rows.Count > 0)
            {
                string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
                string sumData = JsonConvert.SerializeObject(sumDt, Formatting.Indented);
                jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + ",\"sumdata\":" + sumData + "}";
                HttpContext.Current.Session["rp_fieldvalues"] = BranchName + "*" + numrows + "*" + sumDt.Rows[0]["total_balance"];
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


    //Start:Show downloads in reports.aspx
    [WebMethod]
    public static string DownloadCustomerReports(Dictionary<string, string> filters)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1";

            if (filters.Count > 0)
            {

               
                if (filters.ContainsKey("istoConfirm"))
                {
                    query_condition += " and ( new_custtype!='0'  or new_creditamt!='0' or new_creditperiod!='0')=1";
                }
                //if (filters.ContainsKey("branch"))
                //{
                //    query_condition += " and cu.branch_id='" + filters["branch"] + "'";
                //}
                if (filters.ContainsKey("account_status"))
                {
                    if (Convert.ToInt32(filters["account_status"]) == 0)
                    {
                        query_condition += " and cu.cust_amount=0";
                    }
                    else if (Convert.ToInt32(filters["account_status"]) == 1)
                    {
                        query_condition += " and cu.cust_amount>0";
                    }
                }
                if (filters.ContainsKey("cus_type"))
                {
                    query_condition += " and cu.cust_type='" + filters["cus_type"] + "'";
                }
            }

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*)  FROM tbl_customer cu " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "N";
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT cu.cust_id as Id,cu.cust_name as Name,cu.cust_phone as Phone,cu.cust_address as Address, (CASE"
                + " WHEN cu.cust_type=1 THEN 'A'"
                + " WHEN cu.cust_type=2 THEN 'B'"
                 + " WHEN cu.cust_type=3 THEN 'C'"
                + " END) as Type"
                + " ,IFNULL(cu.cust_amount,0) as outstanding_amount"
                + " ,CONCAT(ud.first_name,' ',ud.last_name) as Created_by,DATE_FORMAT(cu.cust_joined_date, '%d/%m/%Y') 'Created Date' "
                + " from tbl_customer cu  "
                + " left join tbl_user_details ud on ud.user_id=cu.user_id" + query_condition;

            innerqry = innerqry + " order by cu.cust_name asc ";
            HttpContext.Current.Session["downloadqry"] = innerqry;
            return "Y";

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
       
    }
    //Stop: download Reports in reports.aspx

}