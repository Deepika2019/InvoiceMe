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


public partial class reports_purchaseReports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(39);
    }
    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteSupplierData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT vn_name,vn_id from tbl_vendor where 1 and vn_name like '%" + variable + "%' ";
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["vn_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["vn_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["vn_name"]) + "\"}");

                //sb.Append("'name':'" + Convert.ToString(row["cust_name"]) + "'}");
                sb.Append(",");
            }
            sb.Remove(sb.Length - 1, 1);
            sb.Append("]");
        }
        else
        {
            sb.Append("N");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }

    [WebMethod]
    public static string searchvendordata(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("vendorname"))
                {
                    query_condition += " and vn_name  LIKE '%" + filters["vendorname"] + "%'";
                }
                if (filters.ContainsKey("vendorid"))
                {
                    query_condition += " and vn_id  LIKE '%" + filters["vendorid"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "SELECT count(*) FROM tbl_vendor " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT vn_id,vn_name,vn_balance from tbl_vendor ";
            innerqry = innerqry + query_condition + " order by vn_id LIMIT " + offset.ToString() + " ," + per_page;
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
            //if (numrows > per_page)
            //{
            //    Pagination pg1 = new Pagination();
            //    sb.Append(pg1.paginateGCSearch(page, total_pages, adjacents));

            //}

            //return sb.ToString();
            return jsonResponse;

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    [WebMethod]
    public static string showPurchaseReports(int page, Dictionary<string, string> filters, int perpage)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt, dtData = new DataTable();
        double total_pages = 0;
        string query_condition = " where 1=1 ";
        string subquery_condition = " where 1=1 ";
        if (filters.Count > 0)
        {

            if (filters.ContainsKey("vendorId"))
            {
                query_condition += " and pm.vn_id='" + filters["vendorId"] + "'";
                subquery_condition += " and vn_id='" + filters["vendorId"] + "'";
            }
          
            if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(pm.pm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                subquery_condition += " and date(pm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(pm.pm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                subquery_condition += " and date(pm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }

        }
        int per_page = perpage;
        int offset = (page - 1) * per_page;

        string countQry = "SELECT pm_id FROM tbl_purchase_master " + subquery_condition + "";
        dtData = db.SelectQuery(countQry);
        double numrows = dtData.Rows.Count;
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":\"N\"}"; 
        }

        total_pages = Math.Ceiling(numrows / per_page);
        query_condition += " and pm.pm_id IN (select * from(select pm_id from tbl_purchase_master " + subquery_condition + " order by pm_id LIMIT " + offset.ToString() + " ," + per_page + " )pm) ";


        string innerqry = " SELECT pm.pm_id, pm.pm_ref_no, pm.vn_id, tv.vn_name, pm.pm_total, pm.pm_discount_rate, pm.pm_discount_amount,pm.pm_netamount, REPLACE(DATE_FORMAT(pm.pm_date,'%d/%m/%Y'),'/','-') as PurchaseDate";
        innerqry += ",(pm_netamount-(sum(cr)-sum(dr))) as pm_paidamount, (sum(cr)-sum(dr)) as pm_balance, cheque_amt as pm_chq_amt, card_amt as pm_card_amt, cash_amt as pm_cash_amt";
        innerqry += ",pm.pm_note, pi.pi_id,ibs.itm_code, ibs.itm_name, pi.pi_price, pi.pi_qty,";
        innerqry += " pi.pi_total,pi.pi_discount_rate, pi.pi_discount_amt, pi.pi_netamount,concat(ud.first_name,\" \",ud.last_name) as salesname ";
        innerqry = innerqry + " FROM tbl_purchase_master pm inner join tbl_transactions tr on (tr.action_ref_id=pm.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ") LEFT JOIN tbl_purchase_items pi ON pi.pm_id = pm.pm_id inner join tbl_itembranch_stock ibs on ibs.itbs_id=pi.itbs_id inner join tbl_user_details ud on ud.user_id=pm.pm_userid inner join tbl_vendor tv on tv.vn_id=pm.vn_id " + query_condition + " group by pi_id";
        
        
        
        
        //string innerqry = " SELECT tw.id,REPLACE(DATE_FORMAT(trans_date,'%d/%m/%Y'),'/','-') as TransferDate, description, amount, order_id,tw.cust_id,cust_name,concat(tu.first_name,' ',tu.last_name) as seller_name ";
        //innerqry = innerqry + " FROM tbl_wallet_history tw inner join tbl_customer tc ON tc.cust_id = tw.cust_id inner join tbl_user_details tu on tu.user_id=tw.user_id " + query_condition + " order by tw.id LIMIT " + offset.ToString() + " ," + per_page;



        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);
       
       // HttpContext.Current.Session["rp_fieldPermanent"] = filters["from_date"] + "*" + filters["to_date"] + "*" + netamount;
        // summaryRepport = showSummaryReport(numrows, BranchId, searchResults, reportfromdate, reporttodate, BranchName);
        if (dt.Rows.Count > 0)
        {
            string summeryQryDiv = "select sum(inner_res.totalBalance) as totalBalance,sum(inner_res.netamt) as netamount from(select (sum(cr)-sum(dr)) as totalBalance,pm_netamount as netamt from tbl_transactions inner join tbl_purchase_master pm on pm.pm_id=action_ref_id  " + subquery_condition + " and action_type=" + (int)Constants.ActionType.PURCHASE + " group by action_ref_id,action_type  having 1=1 ) as inner_res";
           // string summeryQryDiv = "select sum(pm_netamount) as totalAmt, sum(pm_paidamount) as totalPaid from tbl_purchase_master  " + subquery_condition ;
            DataTable sumdt = new DataTable();
            sumdt = db.SelectQuery(summeryQryDiv);
            if (sumdt.Rows.Count>0)
            {
                double paid = Convert.ToDouble(sumdt.Rows[0]["netamount"]) - Convert.ToDouble(sumdt.Rows[0]["totalBalance"]);
                HttpContext.Current.Session["rp_fieldvalues"] = sumdt.Rows[0]["netamount"] + "*" + paid + "*" + filters["from_date"] + "*" + filters["to_date"];
                string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
                jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData +",\"summarydata\":" + JsonConvert.SerializeObject(sumdt, Formatting.Indented) + "}";
            }
         
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
        string query_condition = " where 1=1 ";;
        if (filters.Count > 0)
        {

            if (filters.ContainsKey("vendorId"))
            {
                query_condition += " and pm.vn_id='" + filters["vendorId"] + "'";
            }

            if (filters.ContainsKey("from_date"))
            {
                query_condition += " and date(pm.pm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                query_condition += " and date(pm.pm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }

        }
 
        string countQry = "SELECT pm_id FROM tbl_purchase_master pm " + query_condition + "";
        dtData = db.SelectQuery(countQry);
        double numrows = dtData.Rows.Count;
        if (numrows == 0)
        {
            return "N"; ;
        }
        string innerqry = " SELECT pm.pm_id, pm.pm_ref_no, pm.vn_id, tv.vn_name, pm.pm_total, pm.pm_discount_rate, pm.pm_discount_amount,pm.pm_netamount, REPLACE(DATE_FORMAT(pm.pm_date,'%d/%m/%Y'),'/','-') as PurchaseDate";
        innerqry += ",(pm_netamount-(sum(cr)-sum(dr))) as pm_paidamount, (sum(cr)-sum(dr)) as pm_balance, cheque_amt as pm_chq_amt, card_amt as pm_card_amt, cash_amt as pm_cash_amt";
        innerqry += ",pm.pm_note,concat(ud.first_name,\" \",ud.last_name) as salesname,'Item' as Item ";
        innerqry = innerqry + " FROM tbl_purchase_master pm inner join tbl_transactions tr on (tr.action_ref_id=pm.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ") inner join tbl_user_details ud on ud.user_id=pm.pm_userid inner join tbl_vendor tv on tv.vn_id=pm.vn_id " + query_condition + " group by pm_id";
       // query_condition += " and pm.pm_id IN (select * from(select pm_id from tbl_purchase_master " + subquery_condition + " order by pm_id )pm) ";
        HttpContext.Current.Session["downloadqry"] = innerqry;
        return "Y";
    }
    //Stop: Download reports
}