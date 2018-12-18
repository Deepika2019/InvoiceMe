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

public partial class reports_stockTransactionReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(47);
    }

    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        //string query = "SELECT tbl_branch.branch_id,tbl_branch.branch_name,tbl_branch.branch_countryid,tbl_branch.branch_timezone FROM tbl_branch INNER JOIN tbl_user_branches ON tbl_branch.branch_id = tbl_user_branches.branch_id WHERE tbl_user_branches.user_id='" + userid + "' and tbl_user_branches.status='1' ";
        //query = query + " order by tbl_branch.branch_id";
        //dt = db.SelectQuery(query);
        string query = "SELECT branch_id,branch_name FROM tbl_branch";
        query = query + " order by branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end warehouse show

    #region
    //webmethod for showing stock transcations based on search fields 
    #endregion
    [WebMethod]
    public static string showStockTransactions(int page, int perpage, Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1=1 ";
        string haveCondition = " having 1";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and br.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("actionType"))
            {
                qry_condition += " and action_type  = '" + filters["actionType"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(str.date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(str.date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("search"))
            {
                qry_condition += " and (br.branch_name like '%" + filters["search"] + "%' or itbs.itm_name like '%" + filters["search"] + "%' or itbs.itm_code like '%" + filters["search"] + "%' or str.closing_stock like '%" + filters["search"] + "%')";
            }
            if (filters.ContainsKey("partnerSearch"))
            {
                haveCondition += " and (partnerName like '%" + filters["partnerSearch"] + "%')";
            }
            //if (filters.ContainsKey("action_type"))
            //{
            //    qry_condition += " and str.action_type  = '" + filters["action_type"] + "'";
            //}

        }
        int per_page = perpage;
        int offset = (page - 1) * per_page;
        string countQry = "select CASE WHEN str.action_type = 1 THEN"
                           + " (select tc.cust_name from tbl_sales_master sm inner join "
                           + " tbl_customer tc on tc.cust_id=sm.cust_id where sm_id=str.action_ref_id)"
                           + " WHEN str.action_type = 2 THEN (select tv.vn_name from tbl_purchase_master pm"
                           + " inner join tbl_vendor tv on tv.vn_id=pm.vn_id where pm_id=str.action_ref_id)"
                           + " WHEN str.action_type = 3 THEN (select tc.cust_name from tbl_salesreturn_master srm"
                           + " inner join tbl_customer tc on tc.cust_id=srm.cust_id where srm_id=str.action_ref_id)"
                           + " ELSE 'None' END AS partnerName"
                            +" FROM `tbl_stock_transactions` str inner join"
                            +" tbl_itembranch_stock itbs on itbs.`itbs_id`=str.`itbs_id` inner join"
                            +" tbl_branch br on br.branch_id = itbs.branch_id " + qry_condition+ " " + haveCondition +" order by str.id desc";

        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(dtcount.Rows.Count);
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }

        //string innerqry = "select itbs.itbs_id,itbs.itm_id,itbs.itm_code,itbs.itm_name"
        //                  + " , str.closing_stock - str_ag.tot_cr_qty + str_ag.tot_dr_qty opening_stock,str_ag.tot_dr_qty,str_ag.tot_cr_qty,str.closing_stock"
        //                  + " ,br.branch_id,br.branch_name"
        //                  + " from(select max(id) max_id, sum(dr_qty) tot_dr_qty, sum(cr_qty) tot_cr_qty from tbl_stock_transactions group by itbs_id)  str_ag"
        //                  + " inner join tbl_stock_transactions str on str.id = str_ag.max_id"
        //                  + " inner join tbl_itembranch_stock itbs on str.itbs_id = itbs.itbs_id"
        //                  + " inner join tbl_branch br on br.branch_id = itbs.branch_id" + qry_condition + " order by str.id desc LIMIT " + offset.ToString() + " ," + per_page;
        // +" order by str.id desc";

        string innerqry = "SELECT str.`itbs_id`,itm_code,itm_name,concat(tu.first_name,\" \",tu.last_name) as user,action_type,CASE WHEN str.action_type = 1 THEN 'SALES'"
                            +" WHEN str.action_type = 2 THEN 'PURCHASE'"
                            +" WHEN str.action_type = 3 THEN 'SALES RETURN'"
                            +" WHEN str.action_type = 4 THEN 'PURCHASE RETURN'"
                            +" WHEN str.action_type = 7 THEN 'STOCK_TRANSFER'"
                            + " WHEN str.action_type = 11 THEN 'MANUAL_ITEM_EDIT'"
                            +" ELSE NULL END AS ActionType,`action_ref_id`,`narration`,"
                            + " `dr_qty`,`cr_qty`,`closing_stock`,DATE_FORMAT(date,'%d/%m/%Y %h:%i %p') AS date,branch_name,CASE"
                            +" WHEN str.action_type = 1 THEN (select tc.cust_name from"
                            +" tbl_sales_master sm inner join  tbl_customer tc on"
                            +" tc.cust_id=sm.cust_id where sm_id=str.action_ref_id) WHEN"
                            +" str.action_type = 2 THEN (select tv.vn_name from tbl_purchase_master"
                            +" pm inner join tbl_vendor tv on tv.vn_id=pm.vn_id where"
                            +" pm_id=str.action_ref_id) WHEN str.action_type = 3 THEN (select"
                            +" tc.cust_name from tbl_salesreturn_master srm inner join tbl_customer"
                            +" tc on tc.cust_id=srm.cust_id where srm_id=str.action_ref_id) ELSE"
                            +" 'None' END AS partnerName"
                            +" FROM `tbl_stock_transactions` str inner join"
                            +" tbl_itembranch_stock itbs on itbs.`itbs_id`=str.`itbs_id` inner join"
                            +" tbl_branch br on br.branch_id = itbs.branch_id inner join tbl_user_details tu on tu.user_id=str.user_id " + qry_condition + " " + haveCondition + " order by str.id desc LIMIT " + offset.ToString() + " ," + per_page;
        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);

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
    }//end

    //Start:For download stock Transaction reports
    [WebMethod]
    public static string DownloadstockTransReport(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1=1 ";
        string haveCondition = " having 1";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and br.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("actionType"))
            {
                qry_condition += " and action_type  = '" + filters["actionType"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(str.date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(str.date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("search"))
            {
                qry_condition += " and (br.branch_name like '%" + filters["search"] + "%' or itbs.itm_name like '%" + filters["search"] + "%' or itbs.itm_code like '%" + filters["search"] + "%' or str.closing_stock like '%" + filters["search"] + "%')";
            }
            if (filters.ContainsKey("partnerSearch"))
            {
                haveCondition += " and (Partner like '%" + filters["partnerSearch"] + "%')";
            }
        }


        string countQry = "select CASE WHEN str.action_type = 1 THEN"
                           + " (select tc.cust_name from tbl_sales_master sm inner join "
                           + " tbl_customer tc on tc.cust_id=sm.cust_id where sm_id=str.action_ref_id)"
                           + " WHEN str.action_type = 2 THEN (select tv.vn_name from tbl_purchase_master pm"
                           + " inner join tbl_vendor tv on tv.vn_id=pm.vn_id where pm_id=str.action_ref_id)"
                           + " WHEN str.action_type = 3 THEN (select tc.cust_name from tbl_salesreturn_master srm"
                           + " inner join tbl_customer tc on tc.cust_id=srm.cust_id where srm_id=str.action_ref_id)"
                           + " ELSE 'None' END AS partnerName"
                           + " FROM `tbl_stock_transactions` str inner join"
                           + " tbl_itembranch_stock itbs on itbs.`itbs_id`=str.`itbs_id` inner join"
                           + " tbl_branch br on br.branch_id = itbs.branch_id " + qry_condition + " " + haveCondition + " order by str.id desc";
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(dtcount.Rows.Count);
        if (numrows == 0)
        {
            return "N"; ;
        }


        string stockTransQry = "SELECT DATE_FORMAT(date,'%d-%b-%Y %h:%i %p') AS Date,itm_name as Particular,branch_name as Branch,CASE"
                            +" WHEN str.action_type = 1 THEN (select tc.cust_name from"
                            +" tbl_sales_master sm inner join  tbl_customer tc on"
                            +" tc.cust_id=sm.cust_id where sm_id=str.action_ref_id) WHEN"
                            +" str.action_type = 2 THEN (select tv.vn_name from tbl_purchase_master"
                            +" pm inner join tbl_vendor tv on tv.vn_id=pm.vn_id where"
                            +" pm_id=str.action_ref_id) WHEN str.action_type = 3 THEN (select"
                            +" tc.cust_name from tbl_salesreturn_master srm inner join tbl_customer"
                            +" tc on tc.cust_id=srm.cust_id where srm_id=str.action_ref_id) ELSE"
                            + " 'None' END AS Partner,CASE WHEN str.action_type = 1 THEN 'SALES'"
                            +" WHEN str.action_type = 2 THEN 'PURCHASE'"
                            +" WHEN str.action_type = 3 THEN 'SALES RETURN'"
                            +" WHEN str.action_type = 4 THEN 'PURCHASE RETURN'"
                            +" WHEN str.action_type = 7 THEN 'STOCK_TRANSFER'"
                            +" ELSE NULL END AS 'Vch Type',`action_ref_id` as 'Vch No',"
                            + " `cr_qty` as 'Inwards Qty',`dr_qty` as 'Outwards Qty',`closing_stock` as 'Closing Qty'"
                            +" FROM `tbl_stock_transactions` str inner join"
                            +" tbl_itembranch_stock itbs on itbs.`itbs_id`=str.`itbs_id` inner join"
                            +" tbl_branch br on br.branch_id = itbs.branch_id " + qry_condition + " " + haveCondition + " order by str.id desc";
        HttpContext.Current.Session["downloadqry"] = stockTransQry;
        return "Y";
    }
    //Stop: Download reports
}