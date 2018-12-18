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

public partial class purchase_listPurchaseEntries : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication purchase = new LoginAuthentication();
        purchase.userAuthentication();
        purchase.checkPageAcess(4);
    }
    [WebMethod]
    public static string searchEntries(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try
        {
            //dynamic filters = JsonConvert.DeserializeObject(filter_string);
            string query_condition = " where 1=1 ";         
            if (filters.Count > 0)
            {

                if (filters.ContainsKey("search"))
                {
                    query_condition += " and (pm_id = '" + filters["search"] + "' or pm_invoice_no = '" + filters["search"] + "' or vn_name like '%" + filters["search"] + "%')";
                }
         
                if (filters.ContainsKey("from_date"))
                {
                    query_condition += " and date(pm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }
                if (filters.ContainsKey("to_date"))
                {
                    query_condition += " and date(pm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                }

            }

            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            // double numrows = 0;

            DataTable dt1 = new DataTable();
            countQry = "SELECT count(*) as Count FROM tbl_purchase_master tp inner join tbl_vendor tv on tv.vn_id=tp.vn_id " + query_condition + " and pm_id=pm_ref_no";

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));

            if (numrows == 0)
            {
                return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
            }


            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by BillDate Desc) as row FROM billheader " + searchResult;
            innerqry = "select pm_id,pm_netamount as net_amount,pm_invoice_no,pm_status"
                + ",DATE_FORMAT(pm_date,'%d-%b-%Y') AS purchaseDate,sum(cr)-sum(dr) as pm_total_balance"
                + ",vn_name as vendor_name, concat(tu.first_name,' ',tu.last_name) as user_name"
                + " from tbl_purchase_master tp "
                + " inner join tbl_vendor tv on tv.vn_id=tp.vn_id inner join tbl_user_details tu on tu.user_id=tp.pm_userid inner join tbl_transactions tr on (tr.action_ref_id=tp.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ") " + query_condition + "";
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
    }
}