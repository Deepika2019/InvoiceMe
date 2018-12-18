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


public partial class reports_salesreportsadvance : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(28);
    }

    [WebMethod]// start warehouse showing
    public static string showBranches(string userid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT branch_id,branch_name FROM tbl_branch";
        query = query + " order by branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end warehouse show



    [WebMethod]// start customers showing
    public static string showCustomersInReports()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select cust_id,cust_name from tbl_customer order by cust_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }// end customers show

    [WebMethod]
    public static string showsalespersons()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select user_id,first_name,last_name  from tbl_user_details order by user_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }
    //stop: Listing salesperson in Reports page

    //Start:Show Reports in reports.aspx
    [WebMethod]
    public static string showDailyReports(int page, int perpage, Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string summarysearchresult = "";
        double orderAmount = 0;
        double billAmount = 0;
        double totalnetamt = 0;
        double totalpaid = 0;
        double totalbalance = 0;
        double cash = 0;
        double card = 0;
        double cheque = 0;
        double wallet = 0;
        string currency = "";
        string branchName = "";
        double canceledCount = 0;
        double canceledNetAmt = 0;
        double canceledPaid = 0;
        double canceledBal = 0;
        string group_condition = " having 1=1 ";
        string qry_condition = " where 1=1 ";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and tbl_sales_master.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("customer"))
            {
                qry_condition += " and tbl_sales_master.cust_id  = '" + filters["customer"] + "'";
            }
            if (filters.ContainsKey("salesmanId"))
            {
                qry_condition += " and tbl_sales_master.sm_userid  = '" + filters["salesmanId"] + "'";
            }
            if (filters.ContainsKey("outstand"))
            {
                if (Convert.ToInt32(filters["outstand"]) == 1)
                {
                    group_condition += " and (sum(dr)-sum(cr))<=0";
                }
                else if (Convert.ToInt32(filters["outstand"]) == 0)
                {
                    group_condition += " and (sum(dr)-sum(cr))>0";
                }
            }
            if (filters.ContainsKey("status"))
            {
                qry_condition += " and tbl_sales_master.sm_delivery_status  = '" + filters["status"] + "'";
            }

        }
        summarysearchresult = qry_condition;
        int per_page = perpage;
        int offset = (page - 1) * per_page;
        string countQry = "select count(*)  as Count from ( " +
               "select sm_id from  tbl_sales_master inner join tbl_transactions tr on sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " "+qry_condition +
               " group by tr.action_ref_id,tr.action_type " + group_condition
               + ") result";
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }



        qry_condition += " and tbl_sales_master.sm_id IN (select * from(select sm_id from tbl_sales_master " + summarysearchresult + " order by sm_id LIMIT " + offset.ToString() + " ," + per_page + " )sm) ";
        string innerqry = " SELECT tbl_sales_master.sm_id, tbl_sales_master.sm_refno, tbl_sales_master.cust_id, tc.cust_name, tbl_sales_master.sm_total, tbl_sales_master.sm_discount_rate, tbl_sales_master.sm_discount_amount,tbl_sales_master.sm_netamount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date,'%d/%m/%Y'),'/','-') as BillDate,sm_netamount-(sum(dr)-sum(cr)) as sm_paid, (sum(dr)-sum(cr)) as sm_balance, cheque_amt, card_amt, cash_amt,tbl_sales_master.sm_specialnote,sm_invoice_no, tbl_sales_items.si_id, tbl_sales_items.itm_code, tbl_sales_items.itm_name, tbl_sales_items.si_price, tbl_sales_items.si_qty, tbl_sales_items.si_total,tbl_sales_items.si_discount_rate, tbl_sales_items.si_discount_amount, tbl_sales_items.si_net_amount, tbl_sales_items.si_foc,concat(newone.first_name,\" \",newone.last_name) as salesname,concat(newtwo.first_name,\" \",newtwo.last_name) as approvername ";
        innerqry = innerqry + " FROM tbl_sales_master inner join tbl_transactions tr on tbl_sales_master.sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " LEFT JOIN tbl_sales_items ON tbl_sales_master.sm_id = tbl_sales_items.sm_id and tbl_sales_items.si_itm_type!=2 inner join tbl_user_details as newone on newone.user_id=tbl_sales_master.sm_userid left join tbl_user_details as newtwo on newtwo.user_id=tbl_sales_master.sm_approved_id inner join tbl_customer as tc on tc.cust_id=tbl_sales_master.cust_id  " + qry_condition + " group by si_id"+group_condition;
        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);
        
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "";
        }
        else
        {
            jsonResponse = "N";
        }
        string orderDetailQry = "SELECT currency_name as currency,branch_name as branch,IFNULL(sum(sm_netamount),0) as totalSale,(select IFNULL(sum(sm_netamount),0) from tbl_sales_master sm " + summarysearchresult + " and sm_invoice_no is null and sm.sm_delivery_status not in (4,5)) as orderAmount,(select IFNULL(sum(sm_netamount),0) from tbl_sales_master sm " + summarysearchresult + " and sm_invoice_no is not null and sm.sm_delivery_status not in (4,5)) as billAmount from tbl_sales_master  inner join tbl_branch  tb on tb.branch_id=tbl_sales_master.branch_id inner join tbl_currency_details tc ON  tc.currency_id =tb.branch_currency_id  and sm_id IN(select action_ref_id from tbl_transactions where action_type=" + (int)Constants.ActionType.SALES + " group by action_ref_id " + group_condition + ")" + summarysearchresult + " and tbl_sales_master.sm_delivery_status not in (4,5)";
        DataTable orderDt = db.SelectQuery(orderDetailQry);

        if (orderDt.Rows.Count > 0)
        {

            totalnetamt = Convert.ToDouble(orderDt.Rows[0]["totalSale"]);
            orderAmount = Convert.ToDouble(orderDt.Rows[0]["orderAmount"]);
            billAmount = Convert.ToDouble(orderDt.Rows[0]["billAmount"]);
            currency = orderDt.Rows[0]["currency"].ToString();
            branchName = orderDt.Rows[0]["branch"].ToString();
        }

        //string transactionQry = "select (sum(dr)-sum(cr)) as totalBalance, sum(cash_amt) as cash, sum(card_amt) as card, sum(wallet_amt) as wallet,sum(cheque_amt) as cheque from tbl_transactions inner join tbl_sales_master on sm_id=action_ref_id " + summarysearchresult + " and action_type=" + (int)Constants.ActionType.SALES+" "+group_condition;
        string transactionQry = "select IFNULL(sum(inner_res.totalBalance),0) as totalBalance,IFNULL(sum(inner_res.cash),0) as cash, IFNULL(sum(inner_res.card),0) as card"
        + ", IFNULL(sum(inner_res.wallet),0) as wallet,IFNULL(sum(inner_res.cheque),0) as cheque from(select IFNULL((sum(dr)-sum(cr)),0) as totalBalance, IFNULL(sum(cash_amt),0) as cash, "
        + " IFNULL(sum(card_amt),0) as card, IFNULL(sum(wallet_amt),0) as wallet,IFNULL(sum(cheque_amt),0) as cheque from tbl_transactions inner join tbl_sales_master on "
        +"sm_id=action_ref_id " + summarysearchresult + " and tbl_sales_master.sm_delivery_status not in (4,5) and action_type=" + (int)Constants.ActionType.SALES + " group by action_ref_id,action_type " + group_condition+") as inner_res";
        DataTable transactionDt = db.SelectQuery(transactionQry);

        if (transactionDt.Rows.Count > 0)
        {

            totalbalance = Convert.ToDouble(transactionDt.Rows[0]["totalBalance"]);
            totalpaid = Math.Round((totalnetamt - totalbalance),2);
            cash = Convert.ToDouble(transactionDt.Rows[0]["cash"]);
            card = Convert.ToDouble(transactionDt.Rows[0]["card"]);
            wallet = Convert.ToDouble(transactionDt.Rows[0]["wallet"]);
            cheque = Convert.ToDouble(transactionDt.Rows[0]["cheque"]);
        }


        string cancelledDetailQry = @"SELECT 
IFNULL(SUM( CASE WHEN (salestbl.sm_delivery_status=4) THEN 1 ELSE 0 END),0) cancelled_order_count,
IFNULL(SUM( CASE WHEN (salestbl.sm_delivery_status=4) THEN salestbl.sm_netamount ELSE 0 END),0) cancelled_netamt,
IFNULL(SUM( CASE WHEN (salestbl.sm_delivery_status=4) THEN salestbl.paid ELSE 0 END),0) cancelled_paid,
IFNULL(SUM( CASE WHEN (salestbl.sm_delivery_status=4) THEN salestbl.balance ELSE 0 END),0) cancelled_balance
FROM (select tbl_sales_master.sm_netamount,(tbl_sales_master.sm_netamount-(sum(dr)-sum(cr))) as paid,(sum(dr)-sum(cr)) balance,sm_delivery_status 
             from tbl_sales_master 
             inner join tbl_transactions tr on (tr.action_ref_id=tbl_sales_master.sm_id and tr.action_type=1) 
              " + summarysearchresult + " group by tr.action_ref_id,tr.action_type ) salestbl";

        DataTable cancelledDt = db.SelectQuery(cancelledDetailQry);

        if (cancelledDt.Rows.Count > 0)
        {

            canceledCount = Convert.ToDouble(cancelledDt.Rows[0]["cancelled_order_count"]);
            canceledNetAmt = Convert.ToDouble(cancelledDt.Rows[0]["cancelled_netamt"]);
            canceledPaid = Convert.ToDouble(cancelledDt.Rows[0]["cancelled_paid"]);
            canceledBal = Convert.ToDouble(cancelledDt.Rows[0]["cancelled_balance"]);
        }
        HttpContext.Current.Session["rp_fieldvalues"] = filters["from_date"] + "*" + filters["to_date"] + "*" + branchName + "*" + numrows + "*" + currency + "*" + cash + "*" + card + "*" + cheque + "*" + totalnetamt + "*" + totalpaid + "*" + totalbalance;
        string summaryRepport = ",\"currency\":\"" + currency + "\",\"totalcashamt\":\"" + cash + "\",\"totalcardamt\":\"" + card + "\",\"totalcheqamt\":\"" + cheque + "\",\"totalwalletamt\":\"" + wallet + "\",\"totalnetamt\":\"" + totalnetamt + "\",\"totalbalance\":\"" + totalbalance + "\",\"totalpaid\":\"" + totalpaid + "\",\"orderAmount\":\"" + orderAmount + "\",\"billAmount\":\"" + billAmount + "\",\"canceledCount\":\"" + canceledCount + "\",\"canceledNetAmt\":\"" + canceledNetAmt + "\",\"canceledPaid\":\"" + canceledPaid + "\",\"canceledBal\":\"" + canceledBal + "\"}";
        jsonResponse = jsonResponse + summaryRepport;
        return jsonResponse;
    }//end


   

    [WebMethod]
    public static string DownloadDailyReports(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string summarysearchresult = "";
        string group_condition = " having 1=1 ";
        string qry_condition = " where 1=1 ";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and tbl_sales_master.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("customer"))
            {
                qry_condition += " and tbl_sales_master.cust_id  = '" + filters["customer"] + "'";
            }
            if (filters.ContainsKey("salesmanId"))
            {
                qry_condition += " and tbl_sales_master.sm_userid  = '" + filters["salesmanId"] + "'";
            }
            if (filters.ContainsKey("outstand"))
            {
                if (Convert.ToInt32(filters["outstand"]) == 1)
                {
                    group_condition += " and (sum(dr)-sum(cr))<=0";
                }
                else if (Convert.ToInt32(filters["outstand"]) == 0)
                {
                    group_condition += " and (sum(dr)-sum(cr))>0";
                }
            }
            if (filters.ContainsKey("status"))
            {
                qry_condition += " and tbl_sales_master.sm_delivery_status  = '" + filters["status"] + "'";
            }

        }
        summarysearchresult = qry_condition;

        string countQry = "select count(*)  as Count from ( " +
               "select sm_id from  tbl_sales_master inner join tbl_transactions tr on sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " " + qry_condition +
               " group by tr.action_ref_id,tr.action_type " + group_condition
               + ") result";
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N"; ;
        }


        string query = "SELECT sm_invoice_no as InvoiceNumber,tc.cust_name as Customer,"
        + " tbl_sales_master.sm_total as Total,tbl_sales_master.sm_discount_amount as Discount,tbl_sales_master.sm_tax_amount as Tax,"
        + "tbl_sales_master.sm_netamount as NetAmount, REPLACE(DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y'), '/', '-') AS Date, 'Item' as Item,"
        + "sm_netamount-(sum(dr)-sum(cr)) as Paid, (sum(dr)-sum(cr)) as Balance, cheque_amt, card_amt, cash_amt,"
        + " tbl_user_details.first_name as Employee,tbl_sales_master.sm_refno FROM tbl_sales_master inner join"
        + " tbl_transactions tr on tbl_sales_master.sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " INNER JOIN tbl_user_details ON "
        + " tbl_user_details.user_id = tbl_sales_master.sm_userid inner join tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id  " + qry_condition + "group by tbl_sales_master.sm_id" + group_condition;


        HttpContext.Current.Session["downloadqry"] = query;
        return "Y";
    }

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteCustomerData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT cust_name,cust_id from tbl_customer where 1 and cust_name like '%" + variable + "%' limit 0,20 ";
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["cust_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["cust_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["cust_name"]) + "\"}");

                //sb.Append("'name':'" + Convert.ToString(row["cust_name"]) + "'}");
                sb.Append(",");
            }
            sb.Remove(sb.Length - 1, 1);
            sb.Append("]");
        }
        else
        {
            sb.Append("[{\"id\":\"-1\",\"label\":\"No Data Found\",\"value\":\"No Data Found\"}]");
        }
        //{[{"id":"158","label":"Favourite bakers","value":"Favourite bakers"}]}
        
        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }


    [WebMethod]
    public static string searchcustomerdata(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("custname"))
                {
                    query_condition += " and cust_name  LIKE '%" + filters["custname"] + "%'";
                }
                if (filters.ContainsKey("custid"))
                {
                    query_condition += " and cust_id  LIKE '%" + filters["custid"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "SELECT count(*) FROM tbl_customer " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT cust_id,cust_name,cust_amount from tbl_customer ";
            innerqry = innerqry + query_condition + " order by cust_id LIMIT " + offset.ToString() + " ," + per_page;
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
    public static string DownloadTaxReports(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string summarysearchresult = "";
        string group_condition = " having 1=1 ";
        string qry_condition = " where 1=1 ";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and tbl_sales_master.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("customer"))
            {
                qry_condition += " and tbl_sales_master.cust_id  = '" + filters["customer"] + "'";
            }
            if (filters.ContainsKey("salesmanId"))
            {
                qry_condition += " and tbl_sales_master.sm_userid  = '" + filters["salesmanId"] + "'";
            }
            if (filters.ContainsKey("outstand"))
            {
                if (Convert.ToInt32(filters["outstand"]) == 1)
                {
                    group_condition += " and (sum(dr)-sum(cr))<=0";
                }
                else if (Convert.ToInt32(filters["outstand"]) == 0)
                {
                    group_condition += " and (sum(dr)-sum(cr))>0";
                }
            }
            if (filters.ContainsKey("status"))
            {
                qry_condition += " and tbl_sales_master.sm_delivery_status  = '" + filters["status"] + "'";
            }


        }
        summarysearchresult = qry_condition;

        string countQry = "select count(*)  as Count from ( " +
               "select sm_id from  tbl_sales_master inner join tbl_transactions tr on sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " " + qry_condition +
               " group by tr.action_ref_id,tr.action_type " + group_condition
               + ") result";
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N"; ;
        }
     
        string query = "SELECT DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y') AS Date, tc.cust_name as Particulars,"
        +" sm_invoice_no as 'Invoice No.', tc.cust_reg_id as 'Customer Reg No', tbl_sales_master.sm_total"
        +" as Value, tbl_sales_master.sm_discount_amount as 'Discount amount',tbl_sales_master.sm_tax_amount"
        + " as 'Tax amount',tbl_sales_master.sm_netamount as 'Net amount' FROM tbl_sales_master  inner join"
        + " tbl_transactions tr on tbl_sales_master.sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " inner join"
        + " tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id  " + qry_condition + "group by tbl_sales_master.sm_id" + group_condition;

        //query = "SELECT REPLACE(DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y'), '/', '-') AS Date, tbl_sales_master.cust_name as Particulars,'SALES GST' as 'Voucher Type', sm_invoice_no as 'Vch No.', tc.cust_reg_id as 'GSTIN/UIN', tbl_sales_master.sm_tax_excluded_amt  as Value, tbl_sales_master.sm_netamount as 'Gross Total',tbl_sales_master.sm_tax_excluded_amt  as 'SALES GST', ROUND((tbl_sales_master.sm_tax_amount)/2,2) as CGST,ROUND((tbl_sales_master.sm_tax_amount)/2,2) as SGST,  '0' as 'ROUND OFF',tbl_sales_master.sm_discount_amount as 'Discount Allowed' FROM tbl_sales_master  inner join tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id  " + searchResults + "order by tbl_sales_master.sm_id";
        HttpContext.Current.Session["downloadTaxqry"] = query;
        HttpContext.Current.Session["summarySearch"] = qry_condition;
        return "Y";
    }

    [WebMethod]
    public static string DownloadCancelTaxReports(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string summarysearchresult = "";
        string group_condition = " having 1=1 ";
        string qry_condition = " where sm_delivery_status in(4,5)";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("branch_id"))
            {
                qry_condition += " and tbl_sales_master.branch_id  = '" + filters["branch_id"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(sm_date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(sm_date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("customer"))
            {
                qry_condition += " and tbl_sales_master.cust_id  = '" + filters["customer"] + "'";
            }
            if (filters.ContainsKey("salesmanId"))
            {
                qry_condition += " and tbl_sales_master.sm_userid  = '" + filters["salesmanId"] + "'";
            }
            if (filters.ContainsKey("outstand"))
            {
                if (Convert.ToInt32(filters["outstand"]) == 1)
                {
                    group_condition += " and (sum(dr)-sum(cr))<=0";
                }
                else if (Convert.ToInt32(filters["outstand"]) == 0)
                {
                    group_condition += " and (sum(dr)-sum(cr))>0";
                }
            }
            if (filters.ContainsKey("status"))
            {
                qry_condition += " and tbl_sales_master.sm_delivery_status  = '" + filters["status"] + "'";
            }


        }
        summarysearchresult = qry_condition;

        string countQry = "select count(*)  as Count from ( " +
               "select sm_id from  tbl_sales_master inner join tbl_transactions tr on sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " " + qry_condition +
               " group by tr.action_ref_id,tr.action_type " + group_condition
               + ") result";
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "N"; ;
        }

        string query = "SELECT DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y') AS Date, tbl_sales_master.cust_name as Particulars,"
        + " 'SALES GST' as 'Voucher Type', sm_invoice_no as 'Vch No.', tc.cust_reg_id as 'GSTIN/UIN', tbl_sales_master.sm_tax_excluded_amt"
        + " as Value, concat(tbl_sales_master.sm_netamount,'Dr') as 'Gross Total',concat(tbl_sales_master.sm_tax_excluded_amt,'Cr')"
        + " as 'SALES GST', concat(ROUND((tbl_sales_master.sm_tax_amount)/2,2),' Cr') as CGST,concat(ROUND((tbl_sales_master.sm_tax_amount)/2,2),' Cr') as SGST,"
        + " '0' as 'ROUND OFF',concat(tbl_sales_master.sm_discount_amount,' Dr') as 'Discount Allowed' FROM tbl_sales_master  inner join "
        + " tbl_transactions tr on tbl_sales_master.sm_id=tr.action_ref_id and tr.action_type=" + (int)Constants.ActionType.SALES + " inner join"
        + " tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id  " + qry_condition + "group by tbl_sales_master.sm_id" + group_condition;

        //query = "SELECT REPLACE(DATE_FORMAT(tbl_sales_master.sm_date, '%d/%m/%Y'), '/', '-') AS Date, tbl_sales_master.cust_name as Particulars,'SALES GST' as 'Voucher Type', sm_invoice_no as 'Vch No.', tc.cust_reg_id as 'GSTIN/UIN', tbl_sales_master.sm_tax_excluded_amt  as Value, tbl_sales_master.sm_netamount as 'Gross Total',tbl_sales_master.sm_tax_excluded_amt  as 'SALES GST', ROUND((tbl_sales_master.sm_tax_amount)/2,2) as CGST,ROUND((tbl_sales_master.sm_tax_amount)/2,2) as SGST,  '0' as 'ROUND OFF',tbl_sales_master.sm_discount_amount as 'Discount Allowed' FROM tbl_sales_master  inner join tbl_customer tc on tc.cust_id=tbl_sales_master.cust_id  " + searchResults + "order by tbl_sales_master.sm_id";
        HttpContext.Current.Session["downloadTaxqry"] = query;
        HttpContext.Current.Session["summarySearch"] = qry_condition;
        return "Y";
    }

}