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

public partial class reports_profitAndLossReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(45);
    }
    /// <summary>
    /// webmethod for 
    /// </summary>
    /// <param name="page"></param>
    /// <param name="perpage"></param>
    /// <param name="filters"></param>
    /// <returns></returns>
    [WebMethod]
    public static string showProfitLoss(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string sales_qry_condition = " where 1=1 ";
        string purchase_qry_condition = " where 1=1 ";
        string income_qry_condition = " where 1=1 ";
        if (filters.Count > 0)
        {
           
            if (filters.ContainsKey("from_date"))
            {
                sales_qry_condition += " and date(sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                purchase_qry_condition += " and date(pm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
                income_qry_condition += " and date(ie_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                sales_qry_condition += " and date(sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                purchase_qry_condition += " and date(pm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
                income_qry_condition += " and date(ie_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
           

        }
        string profitLossQry = "select SM.totalSales, PM.totalPurchase, IC.totalOtherIncome,"
                             + " EX.totalOtherExpense,SUM(SM.totalSales + IC.totalOtherIncome) as totalIncome,"
                             + " sum(PM.totalPurchase+EX.totalOtherExpense) as totalExpense from"
                             + " (select IFNULL(sum(sm_netamount),0) as totalSales from tbl_sales_master " + sales_qry_condition + " and sm_delivery_status=2) as SM,"
                             + " (select IFNULL(sum(pm_netamount),0) as totalPurchase from tbl_purchase_master " + purchase_qry_condition + " and pm_status=1) as PM,"
                             + " (select IFNULL(sum(ie_netamount),0) as totalOtherIncome from tbl_incm_exps " + income_qry_condition + " and ie_type=1) as IC,"
                             + " (select IFNULL(sum(ie_netamount),0) as totalOtherExpense from tbl_incm_exps " + income_qry_condition + " and ie_type=0) as EX";

        string catgryQry = "SELECT ie_cat_name as name,tc.ie_type as type,sum(ie_netamount) as total FROM tbl_incm_exps_category tc inner join tbl_incm_exps ie on ie.ie_category=tc.ie_cat_id "+income_qry_condition+" group by ie_category ";
        
        string jsonResponse = "";
        DataTable profitDt = db.SelectQuery(profitLossQry);
        DataTable categoryDt = db.SelectQuery(catgryQry);
        if (profitDt.Rows.Count > 0)
        {

            string jsonData = JsonConvert.SerializeObject(profitDt, Formatting.Indented);
            string categoryData = JsonConvert.SerializeObject(categoryDt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + ",\"category\":" + categoryData + "}";
        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;
    }//end
}