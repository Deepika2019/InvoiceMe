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

public partial class reports_stockTransferReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(48);
    }

    [WebMethod]
    public static string showStockTransferHistory(int page, Dictionary<string, string> filters, int perpage)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt, dtData = new DataTable();
        double total_pages = 0;
        string query_condition = " where 1=1 ";
        string subquery_condition = " where 1=1 ";
        if (filters.Count > 0)
        {

            if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(sh.st_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                subquery_condition += " and date(st_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(sh.st_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                subquery_condition += " and date(st_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }

        }
        int per_page = perpage;
        int offset = (page - 1) * per_page;

        string countQry = "SELECT st_id FROM tbl_stock_transfer_header " + subquery_condition + "";
        dtData = db.SelectQuery(countQry);
        double numrows = dtData.Rows.Count;
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":\"N\"}";
        }

        total_pages = Math.Ceiling(numrows / per_page);
        query_condition += " and sh.st_id IN (select * from(select st_id from tbl_stock_transfer_header " + subquery_condition + " order by st_id LIMIT " + offset.ToString() + " ," + per_page + " )sh) ";


        string innerqry = " SELECT sh.st_id, REPLACE(DATE_FORMAT(sh.st_date,'%d/%m/%Y'),'/','-') as TransferDate, ";
        innerqry += " si.sti_id,im.itm_code, im.itm_name, si.sti_quantity,concat(ud.first_name,\" \",ud.last_name) as username,CASE WHEN tb1.branch_name IS NULL THEN 'CentralWarehouse' ELSE tb1.branch_name END AS source,CASE WHEN tb2.branch_name IS NULL THEN 'CentralWarehouse' ELSE tb2.branch_name END AS Dest";
        innerqry = innerqry + " FROM tbl_stock_transfer_header sh LEFT JOIN tbl_stock_transfer_items si ON sh.st_id = si.st_id inner join tbl_item_master im on im.itm_id=si.itm_id inner join tbl_user_details ud on ud.user_id=sh.user_id left join tbl_branch tb1 on tb1.branch_id=sh.st_from_branch_id left join tbl_branch tb2 on tb2.branch_id=sh.st_to_branch_id " + query_condition + " order by st_id";




        //string innerqry = " SELECT tw.id,REPLACE(DATE_FORMAT(trans_date,'%d/%m/%Y'),'/','-') as TransferDate, description, amount, order_id,tw.cust_id,cust_name,concat(tu.first_name,' ',tu.last_name) as seller_name ";
        //innerqry = innerqry + " FROM tbl_wallet_history tw inner join tbl_customer tc ON tc.cust_id = tw.cust_id inner join tbl_user_details tu on tu.user_id=tw.user_id " + query_condition + " order by tw.id LIMIT " + offset.ToString() + " ," + per_page;



        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);

        // HttpContext.Current.Session["rp_fieldPermanent"] = filters["from_date"] + "*" + filters["to_date"] + "*" + netamount;
        // summaryRepport = showSummaryReport(numrows, BranchId, searchResults, reportfromdate, reporttodate, BranchName);
        if (dt.Rows.Count > 0)
        {

            HttpContext.Current.Session["rp_fieldvalues"] = filters["from_date"] + "*" + filters["to_date"];
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";


        }
        else
        {
            return "{\"count\":\"" + numrows + "\",\"data\":\"N\"}";
        }
        // jsonResponse = jsonResponse + summaryRepport;
        return jsonResponse;

    }

    //Start:For download service reports
    [WebMethod]
    public static string DownloadPurchaseReport(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtData = new DataTable();
        string query_condition = " where 1=1 "; ;
        if (filters.Count > 0)
        {

             if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(sh.st_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(sh.st_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }


        }

        string countQry = "SELECT st_id FROM tbl_stock_transfer_header " + query_condition + "";
        dtData = db.SelectQuery(countQry);
        double numrows = dtData.Rows.Count;
        if (numrows == 0)
        {
            return "N"; ;
        }

        // query_condition += " and pm.pm_id IN (select * from(select pm_id from tbl_purchase_master " + subquery_condition + " order by pm_id )pm) ";
        string innerqry = " SELECT pm.pm_id, pm.pm_ref_no, pm.vn_id, tv.vn_name, pm.pm_total, pm.pm_discount_rate, pm.pm_discount_amount,pm.pm_netamount, REPLACE(DATE_FORMAT(pm.pm_date,'%d/%m/%Y'),'/','-') as PurchaseDate, pm.pm_paidamount,";
        innerqry += " pm.pm_balance, pm.pm_chq_amt, pm.pm_card_amt,pm.pm_cash_amt,pm.pm_note,";
        innerqry += " concat(ud.first_name,\" \",ud.last_name) as salesname,'Item' as Item ";
        innerqry = innerqry + " FROM tbl_purchase_master pm inner join  tbl_user_details ud on ud.user_id=pm.pm_userid inner join tbl_vendor tv on tv.vn_id=pm.vn_id " + query_condition + " order by pm_id";
        HttpContext.Current.Session["downloadqry"] = innerqry;
        return "Y";
    }
    //Stop: Download reports
}