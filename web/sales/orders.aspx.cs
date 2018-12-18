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

public partial class sales_orders : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(8);
    }
    //show Sales person
    [WebMethod]
    public static string showsalespersons()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "";
        if (HttpContext.Current.Request.Cookies["invntrystaffTypeID"].Value == "2")
        {
            query = "select user_id,first_name,last_name  from tbl_user_details where user_id =" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        }
        //  string query = "SELECT Branch.Id,Branch.Name FROM Branch INNER JOIN user_branches ON Branch.Id = user_branches.branch_id WHERE user_branches.user_id='" + userid + "' and user_branches.status='1' order by Branch.Id";
        else
        {
            query = "select user_id,first_name,last_name  from tbl_user_details where user_type =2 order by user_id";
        }
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["user_id"] is DBNull)
                {
                    sb.Append("<option value='0' >Select Sales Person</option>");
                }
                else
                {
                    sb.Append("<option value='0' >Select Sales Person</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        sb.Append("<option value='" + dt.Rows[i]["user_id"] + "'>" + dt.Rows[i]["first_name"] + "&nbsp" + dt.Rows[i]["last_name"] + "</option>");
                    }
                }
            }
            else
            {
                sb.Append("<option value='0' >Select Sales Person</option>");
            }
        }

        return sb.ToString();
    }//end


    [WebMethod]
    public static string searchOrders(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = "";
            if (HttpContext.Current.Request.Cookies["invntrystaffTypeID"].Value == "2")
            {
                query_condition = " where 1=1 and sm_userid=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
            }
            else
            {
                query_condition = " where 1=1";
            }
           
            string group_condition = " having 1=1 ";
            string salesReturnQuery = " left join (select Distinct sm_id from tbl_salesreturn_master) as srm on sm.sm_id=srm.sm_id ";
            if (filters.Count > 0)
            {

                if (filters.ContainsKey("cus_id"))
                {
                    query_condition += " and sm.cust_id='" + filters["cus_id"] + "'";
                }
                if (filters.ContainsKey("seller_id"))
                {
                    if (filters["seller_id"] != "0")
                    {
                        query_condition += " and sm.sm_userid='" + filters["seller_id"] + "'";
                    }
                }
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (sm.sm_id = '" + filters["search"] + "'  or sm.sm_invoice_no like '%" + filters["search"] + "%')";
                }
                if (filters.ContainsKey("custSearch"))
                {
                    query_condition += " and (tc.cust_name like '%" + filters["custSearch"] + "%' or sm.cust_id ='" + filters["custSearch"] + "')";
                }
                if (filters.ContainsKey("branch"))
                {
                    if (filters["branch"] == "-1")
                    {
                        query_condition += " and sm.branch_id in (select branch_id from tbl_user_branches where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + ")";
                    }
                    else
                    {
                        query_condition += " and sm.branch_id  = '" + filters["branch"] + "'";
                    }
                }
                if (filters.ContainsKey("payment_status"))
                {
                    if (Convert.ToInt32(filters["payment_status"]) == 1)
                    {
                        group_condition += " and (sum(dr)-sum(cr))<=0";
                    }
                    else if (Convert.ToInt32(filters["payment_status"]) == 2)
                    {
                        group_condition += " and (sum(dr)-sum(cr))>0";
                    }
                }
                if (filters.ContainsKey("order_status"))
                {
                    if (filters["order_status"] == "6")
                    {
                        salesReturnQuery = " inner join tbl_salesreturn_master srm on sm.sm_id=srm.sm_id";
                    }
                    else
                    {

                        query_condition += " and sm.sm_delivery_status='" + filters["order_status"] + "'";
                    }

                }
                if (filters.ContainsKey("type"))
                {
                    if (filters["type"] == "0")
                    {
                        query_condition += " and sm.sm_invoice_no is null";
                    }
                    else if (filters["type"] == "1")
                    {

                        query_condition += " and sm.sm_invoice_no is not null";
                    }

                }
                if (filters.ContainsKey("from_date"))
                {
                    if (filters.ContainsKey("type"))
                    {
                        if (filters["type"] == "1")
                        {
                            query_condition += " and date(sm.sm_processed_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                        }
                        else
                        {
                            query_condition += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                        }
                    }
                    else
                    {
                        query_condition += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                    }
                }
                if (filters.ContainsKey("to_date"))
                {
                    if (filters.ContainsKey("type"))
                    {
                        if (filters["type"] == "1")
                        {
                            query_condition += " and date(sm.sm_processed_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                        }
                        else
                        {
                            query_condition += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                        }
                    }
                    else
                    {
                        query_condition += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                    }
                }

            }

            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "select count(*)  as Count from ( " +
                "select sm.sm_id from  tbl_sales_master sm inner join tbl_customer tc on tc.cust_id=sm.cust_id inner join tbl_transactions tr on sm.sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " " +
                 salesReturnQuery + query_condition+
                " group by tr.action_ref_id,tr.action_type "+group_condition
                + ") result";

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }

             innerqry = "select sm.sm_id,sm.sm_refno as ref_id,sm.cust_id,tc.cust_name,sm.sm_netamount as net_amount,sum(dr)-sum(cr) as total_balance,sm.sm_netamount-(sum(dr)-sum(cr)) as total_paid"
                + ",DATE_FORMAT(sm.sm_date,'%d-%b-%Y %H:%i') AS orderDate,DATE_FORMAT(sm.sm_processed_date,'%d-%b-%Y %H:%i') AS billedDate,branch_tax_method"
                + ",sm.sm_delivery_status as order_status, concat(ud.first_name,' ',ud.last_name) as seller_name,concat(udone.first_name,' ',udone.last_name) as billedBy,srm.sm_id as srm_smid,cust_type,sm_invoice_no as invoiceNum"
                + " from tbl_sales_master sm "
                + " inner join tbl_user_details ud on sm.sm_userid=ud.user_id left join tbl_user_details udone on sm.sm_processed_id=udone.user_id inner join tbl_customer tc on tc.cust_id=sm.cust_id"
                + " inner join tbl_transactions tr on (tr.action_ref_id=sm.sm_id and tr.action_type=" + (int)Constants.ActionType.SALES + ")" + salesReturnQuery + query_condition;
            innerqry = innerqry + " group by action_ref_id,action_type "+group_condition+" order by sm_date desc LIMIT " + offset.ToString() + " ," + per_page;

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
    }

    [WebMethod]
    public static string getBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
      //  string query = "select branch_id,branch_name from tbl_branch";
        string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
         //   query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }
}