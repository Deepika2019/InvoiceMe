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

public partial class Customers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication customers = new LoginAuthentication();
        customers.userAuthentication();
        customers.checkPageAcess(2);
    }
    [WebMethod]// branch show
    public static string getBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
      //  string query = "select branch_id,branch_name from tbl_branch";
        string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]//serach customers
    public static string searchCustomers(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1";

            if (filters.Count > 0)
            {
                if (filters.ContainsKey("seller_id"))
                {
                    query_condition += " and cu.user_id='" + filters["seller_id"] + "'";
                }
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (cu.cust_id like '" + filters["search"] + "%' or cu.cust_name like '%" + filters["search"] + "%'  or cu.cust_phone like '" + filters["search"] + "%' or cust_reg_id like '%" + filters["search"] + "%' or cust_address like '%" + filters["search"] + "%' or cust_city like '%" + filters["search"] + "%' )";
                }
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
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "SELECT cu.cust_id,cu.cust_name,cu.cust_type,cu.cust_phone,cust_address,cust_city,cust_reg_id"
                + " ,IFNULL(cu.cust_amount,0) as outstanding_amount"
                + " ,CONCAT(ud.first_name,' ',ud.last_name) as seller_name"
                + " ,( new_custtype!='0'  or new_creditamt!='0' or new_creditperiod!='0') as is_to_confirm"
                + " from tbl_customer cu "
                + " left join tbl_user_details ud on ud.user_id=cu.user_id" + query_condition;

            innerqry = innerqry + " order by cu.cust_name asc LIMIT " + offset.ToString() + " ," + per_page;

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