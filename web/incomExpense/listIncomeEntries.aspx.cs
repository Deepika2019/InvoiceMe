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

public partial class listIncomeEntries : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication income = new LoginAuthentication();
        income.userAuthentication();
        income.checkPageAcess(53);
    }
    [WebMethod]
    public static string searchEntries(int page, Dictionary<string, string> filters, int perpage)
    {

      
        try
        {
           
            string query_condition = " where tie.ie_type='1' ";
            if (filters.Count > 0)
            {

                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (ie_invoice_num like '%" + filters["search"] + "%' or ext_user_name like '%" + filters["search"] + "%')";
                }

                if (filters.ContainsKey("from_date"))
                {
                    query_condition += " and date(ie_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("to_date"))
                {
                    query_condition += " and date(ie_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }

            }

            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) as Count FROM tbl_incm_exps tie inner join tbl_user_details tu on tu.user_id=tie.ext_user_id " + query_condition;             //where ie_type='" + (int)Constants.ActionType.INCOME + "'";

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            innerqry = "select ie_id,ie_netamount as net_amount,ie_invoice_num,ie_cat_name as ie_category,ext_user_name as externalusername,"
                + " DATE_FORMAT(ie_date, '%d-%b-%Y') AS ieDate, sum(dr) - sum(cr) as ie_total_balance,concat(tu.first_name,tu.last_name) as enteredusername, tu.user_id as enteredUserId"
                + " from tbl_incm_exps tie inner join tbl_incm_exps_category iec on tie.ie_category=iec.ie_cat_id" 
                +" inner join tbl_user_details tu on tu.user_id=tie.user_id"
                + " inner join tbl_transactions tr on (tr.action_ref_id=tie.ie_id and tr.action_type=" + (int)Constants.ActionType.INCOME + ") " + query_condition + "";
           innerqry = innerqry + " group by action_ref_id,action_type order by ie_date desc LIMIT " + offset.ToString() + " ," + per_page;
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
}