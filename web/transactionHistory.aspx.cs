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

public partial class transactionHistory : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string searchTransactions(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1 and partner_type="+(int)Constants.PartnerType.CUSTOMER+ " and partner_id='" + filters["cus_id"] + "'";
            if (filters.Count > 0)
            {

                
                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (action_ref_id like '%" + filters["search"] + "%' or user_name like '%" + filters["search"] + "%' or cr like '%" + filters["search"] + "%' or dr like '%" + filters["search"] + "%' or narration like '%" + filters["search"] + "%')";
                }
               
                if (filters.ContainsKey("from_date"))
                {
                    query_condition += " and date(date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("to_date"))
                {
                    query_condition += " and date(date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("action"))
                {
                    query_condition += " and action_type="+ filters["action"];
                }

            }

            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "select count(*)  as Count from tbl_transactions tr inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }
            String innerqry = "select tr.id,action_ref_id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as trans_date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
          + " cheque_bank,DATE_FORMAT(`cheque_date`, '%d-%b-%Y %h:%i %p') as cheque_date,wallet_amt,dr,cr,closing_balance,action_type from tbl_transactions tr "
          + " inner join tbl_user_details tu on tu.user_id=tr.user_id " + query_condition+ " order by date desc LIMIT " + offset.ToString() + " ," + per_page;

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
    public static string getcustomerDetails(int customer)
    {
        mySqlConnection db = new mySqlConnection();
        string jsonResponse = "";
        DataTable customerDt = db.SelectQuery("select cust_name,cust_type,cust_amount from tbl_customer where cust_id=" + customer);
        if (customerDt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(customerDt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }
}