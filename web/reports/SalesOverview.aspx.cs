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

public partial class reports_SalesOverview : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(45);
    }

    [WebMethod]
    public static string Get_users_and_warehouses(string user_id)
    {
        var result = "N";
        
        try
        {
            var cust_warehouse_query = @"SELECT br.branch_id,br.branch_name FROM tbl_branch br JOIN tbl_user_branches ub on br.branch_id=ub.branch_id WHERE ub.user_id='" + user_id + "' GROUP BY br.branch_id";
            DataTable dt_warehouse = new mySqlConnection().SelectQuery(cust_warehouse_query);

            string user_qry = "select ud.user_id,concat (ud.first_name,' ',ud.last_name)as name,ud.user_type from tbl_user_details ud JOIN tbl_user_branches ub ON ub.user_id=ud.user_id where ud.user_type in(2,3,1) and ub.branch_id in ( SELECT ub.branch_id FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + user_id + "') GROUP BY ud.user_id";
            DataTable dt_user = new mySqlConnection().SelectQuery(user_qry);

            result = "{\"dt_warehouse\":" + JsonConvert.SerializeObject(dt_warehouse) + ",\"dt_users\":" + JsonConvert.SerializeObject(dt_user) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_users_and_warehouses");
            log.write(ex);
            result = "ERROR";
            return result;

        }

    }

    [WebMethod]
    public static string Sales_Overview(string branch_id, string user_id, string date_from, string date_to, string seller_id, string report_type)
    {

        var seller_qry = "";
        var branch_qry = "";
        var report_type_qry = "";

        StringBuilder sb = new StringBuilder();
        try
        {
            mySqlConnection db = new mySqlConnection();
            sb.Append("{");

            // CHECK IN COUNT - 

            var user_checkin_qry = "";
            if (seller_id != "0")
            {
                user_checkin_qry = " tr.rt_user_id='" + seller_id + "' AND ";
            }

            if (report_type != "-1") {

                if (report_type == "0") { report_type_qry = " tsm.sm_invoice_no IS NULL AND "; }
                if (report_type == "1") { report_type_qry = " tsm.sm_invoice_no IS NOT NULL AND "; }
            }

            string qry_checkin = @"SELECT COUNT(tr.rt_id) as checkin_count FROM tbl_root_tracker tr JOIN tbl_customer cu ON cu.cust_id=tr.cust_id JOIN tbl_user_locations ul ON ul.location_id=cu.location_id  WHERE " + user_checkin_qry + " date(tr.rt_datetime)>='" + date_from + "' AND date(tr.rt_datetime)<='" + date_to + "' AND ul.user_id='" + user_id + "' AND tr.rt_visit_status=1";
            var dt_checkin = db.SelectQuery(qry_checkin);
            sb.Append("\"check_in\":" + JsonConvert.SerializeObject(dt_checkin, Formatting.Indented));

            // CREDIT - DEBIT - RETURN

            var old_crdrsr_branch = "";
            var old_crdrsr_user_id = "";
            if (branch_id != "0") { old_crdrsr_branch = " AND tr.branch_id='" + branch_id + "' "; }
            if (seller_id != "0") { old_crdrsr_user_id = " AND tr.user_id='" + seller_id + "' "; }

            sb.Append(",");
            string qry_credit_debit_return = @"SELECT 
IFNULL(sum( CASE WHEN tr.action_type=1 AND is_reconciliation=0 THEN tr.cash_amt ELSE 0 END),0) as tot_cash_amount ,
IFNULL(sum( CASE WHEN tr.action_type=1 AND is_reconciliation=0 THEN tr.cheque_amt ELSE 0 END),0) as tot_cheque_amount ,
IFNULL(sum( CASE WHEN tr.action_type=7 THEN 1 ELSE 0 END),0) as debit_count ,
IFNULL(sum( CASE WHEN tr.action_type=7 THEN tr.dr ELSE 0 END),0) as total_debit ,
IFNULL(sum( CASE WHEN tr.action_type=7 THEN tr.cash_amt ELSE 0 END),0) as total_debit_as_cash ,
IFNULL(sum( CASE WHEN tr.action_type=7 THEN tr.cheque_amt ELSE 0 END),0) as total_debit_as_cheque ,
IFNULL(sum( CASE WHEN tr.action_type=6 THEN 1 ELSE 0 END),0) as credit_count ,
IFNULL(sum( CASE WHEN tr.action_type=6 THEN tr.cr ELSE 0 END),0) as total_credit ,
IFNULL(sum( CASE WHEN tr.action_type=6 THEN tr.cash_amt ELSE 0 END),0) as total_credit_as_cash ,
IFNULL(sum( CASE WHEN tr.action_type=6 THEN tr.cheque_amt ELSE 0 END),0) as total_credit_as_cheque ,
IFNULL(sum( CASE WHEN tr.action_type=3 THEN 1 ELSE 0 END),0) as returned_count ,
IFNULL(sum( CASE WHEN tr.action_type=3 THEN tr.cr ELSE 0 END),0) as total_returned ,
IFNULL(sum( CASE WHEN tr.action_type=5 THEN 1 ELSE 0 END),0) as withdrawn_count,
IFNULL(sum( CASE WHEN tr.action_type=5 THEN tr.dr ELSE 0 END),0) as wallet_withdrawn 
FROM tbl_transactions tr 
JOIN tbl_customer cu ON cu.cust_id=tr.partner_id AND tr.partner_type=1 
JOIN tbl_user_branches ub ON ub.branch_id=tr.branch_id 
JOIN tbl_user_locations ul ON ul.location_id=cu.location_id 
WHERE ul.user_id='" + user_id + "' AND ub.user_id='" + user_id + "' AND date(tr.date)>='" + date_from + "' AND date(tr.date)<='" + date_to + "' " + old_crdrsr_branch + old_crdrsr_user_id + " ";
            var dt_cr_dr_rt = db.SelectQuery(qry_credit_debit_return);
            sb.Append("\"dt_cr_dr_rt\":" + JsonConvert.SerializeObject(dt_cr_dr_rt, Formatting.Indented));

            // ORDERS + COMMISION DETAILS

            var order_branch = "";
            var order_user_id = "";

            if (branch_id != "0") { order_branch = " AND tsm.branch_id='" + branch_id + "' "; }
            if (seller_id != "0") { order_user_id = " AND tsm.sm_userid='" + seller_id + "' "; }

            sb.Append(",");
            string qry_order = @"SELECT 
IFNULL(count(*),0) as order_count ,
IFNULL(sum(sm.sm_netamount),0) as total_sale ,
IFNULL(sum( CASE WHEN (sm.balance>0) THEN 1 ELSE 0 END),0) as outstanding_count  ,
IFNULL(sum( CASE WHEN (sm.balance>0) THEN sm.balance ELSE 0 END),0) as total_outstanding ,
IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),sm.sm_date)>sm.max_creditperiod and sm.balance>0) THEN 1 ELSE 0 END),0) as exceeded_outstanding_count ,
IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),sm.sm_date)>sm.max_creditperiod and sm.balance>0) THEN sm.balance ELSE 0 END),0) as exceeded_outstanding ,
IFNULL(sum(sm.paid),0) as total_receipt ,

IFNULL(SUM( CASE WHEN (sm.sm_type=2) THEN 1 ELSE 0 END),0) old_order_count,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status NOT IN (4,5)) THEN 1 ELSE 0 END),0) active_order_count,
IFNULL(sum( CASE WHEN (sm.sm_netamount>0 AND sm.sm_delivery_status NOT IN (4,5)) THEN sm.sm_netamount ELSE 0 END),0) as active_total_sale  ,
IFNULL(sum( CASE WHEN (sm.balance>0 AND sm.sm_delivery_status NOT IN (4,5)) THEN 1 ELSE 0 END),0) as active_outstanding_count  ,
IFNULL(sum( CASE WHEN (sm.balance>0 AND sm.sm_delivery_status NOT IN (4,5)) THEN sm.balance ELSE 0 END),0) as active_total_outstanding ,
IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),sm.sm_date)>sm.max_creditperiod and sm.balance>0 and sm.sm_delivery_status NOT IN (4,5)) THEN 1 ELSE 0 END),0) as active_exceeded_outstanding_count ,
IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),sm.sm_date)>sm.max_creditperiod and sm.balance>0 and sm.sm_delivery_status NOT IN (4,5)) THEN sm.balance ELSE 0 END),0) as active_exceeded_outstanding ,
IFNULL(sum( CASE WHEN (sm.paid>0 AND sm.sm_delivery_status NOT IN (4,5)) THEN sm.paid ELSE 0 END),0) as active_total_receipt  ,

IFNULL(sum( CASE WHEN (sm.sm_delivery_status not in (2,3,4,5)) THEN sm.commision ELSE 0 END),0) as sold_commision,
IFNULL(sum( CASE WHEN (sm.sm_delivery_status=2) THEN sm.commision ELSE 0 END),0) as delivered_commision,
IFNULL(sum( CASE WHEN (sm.sm_delivery_status=3) THEN sm.commision ELSE 0 END),0) as tobeconfirm_commision,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=0) THEN 1 ELSE 0 END),0) new_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=0) THEN sm.sm_netamount ELSE 0 END),0) new_order_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=0) THEN sm.paid ELSE 0 END),0) new_order_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=0) THEN sm.balance ELSE 0 END),0) new_order_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=1) THEN 1 ELSE 0 END),0) packed_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=1) THEN sm.sm_netamount ELSE 0 END),0) packed_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=1) THEN sm.paid ELSE 0 END),0) packed_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=0 AND sm.sm_packed=1) THEN sm.balance ELSE 0 END),0) packed_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=1 AND sm.sm_packed=1) THEN 1 ELSE 0 END),0) processed_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=1 AND sm.sm_packed=1) THEN sm.sm_netamount ELSE 0 END),0) processed_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=1 AND sm.sm_packed=1) THEN sm.paid ELSE 0 END),0) processed_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=1 AND sm.sm_packed=1) THEN sm.balance ELSE 0 END),0) processed_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=2) THEN 1 ELSE 0 END),0) delivered_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=2) THEN sm.sm_netamount ELSE 0 END),0) delivered_order_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=2) THEN sm.paid ELSE 0 END),0) delivered_order_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=2) THEN sm.balance ELSE 0 END),0) delivered_order_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=3) THEN 1 ELSE 0 END),0) toBeConfirmed_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=3) THEN sm.sm_netamount ELSE 0 END),0) toBeConfirmed_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=3) THEN sm.paid ELSE 0 END),0) toBeConfirmed_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=3) THEN sm.balance ELSE 0 END),0) toBeConfirmed_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=4) THEN 1 ELSE 0 END),0) cancelled_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=4) THEN sm.sm_netamount ELSE 0 END),0) cancelled_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=4) THEN sm.paid ELSE 0 END),0) cancelled_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=4) THEN sm.balance ELSE 0 END),0) cancelled_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=5) THEN 1 ELSE 0 END),0) rejected_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=5) THEN sm.sm_netamount ELSE 0 END),0) rejected_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=5) THEN sm.paid ELSE 0 END),0) rejected_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=5) THEN sm.balance ELSE 0 END),0) rejected_balance,

IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=6) THEN 1 ELSE 0 END),0) pending_order_count,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=6) THEN sm.sm_netamount ELSE 0 END),0) pending_netamt,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=6) THEN sm.paid ELSE 0 END),0) pending_paid,
IFNULL(SUM( CASE WHEN (sm.sm_delivery_status=6) THEN sm.balance ELSE 0 END),0) pending_balance

FROM (select tsm.sm_netamount,tsm.sm_type ,tsm.sm_packed,(tsm.sm_netamount-(sum(dr)-sum(cr))) as paid,(sum(dr)-sum(cr)) balance,tsm.sm_date,sm_delivery_status 
             ,cu.max_creditperiod
             ,(select sum(itm_commisionamt) from tbl_sales_items si where si.sm_id=tsm.sm_id) as commision
             from tbl_sales_master tsm  inner join tbl_customer cu on cu.cust_id=tsm.cust_id 
             inner join tbl_transactions tr on (tr.action_ref_id=tsm.sm_id and tr.action_type=1) 
				 WHERE " + report_type_qry + " date(tsm.sm_date)>='" + date_from + "' AND date(tsm.sm_date)<='" + date_to + "' " + order_branch + order_user_id + " group by tr.action_ref_id,tr.action_type ) sm";
            var dt_order = db.SelectQuery(qry_order);
            sb.Append("\"dt_order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));

            sb.Append(",");

            // getting old payments //
            var old_pay_qry_branch = "";
            var old_pay_qry_user_id = "";
            if (branch_id != "0") { old_pay_qry_branch = " AND tr.branch_id='" + branch_id + "' "; }
            if (seller_id != "0") { old_pay_qry_user_id = " AND tr.user_id='" + seller_id + "' "; }

            string qry_paid_past = @"SELECT count(id) as pre_pay_count,IFNULL(SUM(tr.cr),0) as old_payments FROM tbl_transactions tr JOIN tbl_customer cu ON tr.partner_id=cu.cust_id JOIN tbl_sales_master sm on sm.sm_id=tr.action_ref_id AND tr.action_type='1' 
            JOIN tbl_user_locations ul ON ul.location_id=cu.location_id JOIN tbl_user_branches ub ON ub.branch_id=sm.branch_id 
            WHERE ub.user_id='" + user_id + "' AND ul.user_id='" + user_id + "' AND  tr.partner_type=1 AND tr.dr=0 AND tr.is_reconciliation=0 AND date(sm.sm_date)<'" + date_from + "' AND date(tr.date)>='" + date_from + "' AND date(tr.date)<='" + date_to + "' " + old_pay_qry_branch + old_pay_qry_user_id + "";
            var dt_past_paid = db.SelectQuery(qry_paid_past);
            sb.Append("\"dt_past_paid\":" + JsonConvert.SerializeObject(dt_past_paid, Formatting.Indented));

            sb.Append(",");

            // getting customer counts //
            var cust_qry = "";
            if (seller_id != "0")
            {
                cust_qry = "cu.user_id='" + seller_id + "' AND";
            }

            string qry_new_reg = "SELECT COUNT(cust_id) as total_reg,IFNULL(SUM( CASE WHEN (cu.cust_status=1) THEN 1 ELSE 0 END),0) pending_customer,IFNULL(SUM( CASE WHEN (cu.cust_status=0) THEN 1 ELSE 0 END),0) approved_customer,IFNULL(SUM( CASE WHEN (cu.cust_status=2) THEN 1 ELSE 0 END),0) rejected_customer FROM tbl_customer cu JOIN tbl_user_locations tul ON tul.location_id=cu.location_id WHERE " + cust_qry + " tul.user_id='" + user_id + "' AND date(cu.cust_joined_date)>='" + date_from + "' AND date(cu.cust_joined_date)<='" + date_to + "' ";
            var dt_new_reg = db.SelectQuery(qry_new_reg);
            sb.Append("\"dt_new_reg\":" + JsonConvert.SerializeObject(dt_new_reg, Formatting.Indented));

            sb.Append("}");
            return sb.ToString();
        }
        catch (Exception ex)
        {
            LogClass log = new LogClass("Get_Sales_Overview");
            log.write(ex);
            return "N";
        }
    }

}