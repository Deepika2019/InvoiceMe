using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using System.Dynamic;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using iTextSharp.text.xml;
using iTextSharp.text.html;

using System.Net;
using System.Net.Mail;
using iTextSharp.tool.xml;

public partial class sales_gstBillreceipt : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    [WebMethod]
    public static string showBillReceipt(string billno)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        try
        {
            sb.Append("{");
            //fetching order details
            String orderQry = "SELECT cu.cust_id, sm.sm_id,sm.sm_refno, cu.cust_name,concat(ud.first_name,' ',ud.last_name) as staff_name,cu.cust_address as address,cu.cust_city as city,cu.cust_country as country,cust_tax_reg_id as gst,cu.cust_state as state,cu.cust_phone as phone,cu.cust_email as email "
                + " ,DATE_FORMAT(sm.sm_processed_date, '%d-%b-%Y %h:%i %p') as sm_date,sm.sm_netamount as net_amount,sm_total as total,sm_tax_amount as tax,sm_discount_amount as discAmt,sm_tax_excluded_amt as taxExcluded,sm_netamount-(sum(dr)-sum(cr)) as total_paid,sum(dr)-sum(cr) as total_balance,sm.sm_userid,sm_payment_type"
                + " ,sm.branch_id,IFNULL(cu.cust_amount,0) as outstanding_amt,sum(si_item_cgst) as totalCgst,sum(si_item_sgst) as totalSgst,sum(si_item_igst) as totalIgst,sm_invoice_no as invoiceNum,state_name "
                + " FROM tbl_sales_master sm inner join tbl_customer cu on cu.cust_id=sm.cust_id right join tbl_transactions tr on (tr.action_ref_id=sm.sm_id and tr.action_type=" + (int)Constants.ActionType.SALES + " ) inner join tbl_state on tbl_state.state_id=cu.cust_state"
                + "  left join tbl_user_details ud on ud.user_id=sm.sm_userid inner join tbl_sales_items tsi on tsi.sm_id=sm.sm_id WHERE sm.sm_id ='" + billno + "' ";
            DataTable dtOrder = db.SelectQuery(orderQry);
            sb.Append("\"order\":");
            sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
            // fetching branch details
            string branchQry = "SELECT branch_id,branch_name,branch_countryid,branch_bill_disclosure,branch_bill_footer,branch_address,branch_country_name,branch_image,branch_reg_id,branch_email,branch_declaration FROM tbl_branch WHERE branch_id='" + Convert.ToString(dtOrder.Rows[0]["branch_id"]) + "' ";
            DataTable dtBranches = db.SelectQuery(branchQry);
            sb.Append(",");
            sb.Append("\"branch\":");
            sb.Append(JsonConvert.SerializeObject(dtBranches, Formatting.Indented));
            //fetching order items
            String qryItems = "SELECT tsi.itm_code,tsi.itm_name,si_qty as qty,si_foc as foc,si_price as price "
                + " ,si_total,si_discount_rate as dis_rate,si_discount_amount as dis_amount"
                + " ,si_tax_excluded_total as taxableValue,si_net_amount as net_amount,tp_tax_title as tp_tax_code,si_item_cgst as cgst,si_item_sgst as sgst,si_item_igst as igst "
                + " FROM tbl_sales_items tsi inner join tbl_itembranch_stock tis on tis.itbs_id=tsi.itbs_id inner join tbl_tax_profile tp on tp.tp_tax_code=tis.tp_tax_code WHERE sm_id='" + dtOrder.Rows[0]["sm_refno"].ToString() + "' and si_itm_type!=2";
            DataTable dtItems = db.SelectQuery(qryItems);
            sb.Append(",");
            sb.Append("\"items\":");
            sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
            //fetching payment details
            String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
           + " cheque_bank,DATE_FORMAT(`cheque_date`, '%d-%b-%Y %h:%i %p') as cheque_date,wallet_amt,dr,cr,closing_balance from tbl_transactions tr "
           + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
           + " where action_ref_id='" + billno + "' and action_type=" + (int)Constants.ActionType.SALES;
            DataTable dtPay = db.SelectQuery(paymentQry);
            sb.Append(",");
            sb.Append("\"payment_details\":");
            sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
            //fetching return details
            String retHeadQry = "SELECT `srm_id`, `sm_id`, DATE_FORMAT(`srm_date`, '%d-%b-%Y %h:%i %p') as date,`srm_amount` as amt "
                + " FROM `tbl_salesreturn_master` WHERE `sm_id`='" + dtOrder.Rows[0]["sm_refno"].ToString() + "'";
            DataTable dtRetHead = db.SelectQuery(retHeadQry);
            List<dynamic> lstReturn = new List<dynamic>();
            for (int i = 0; i < dtRetHead.Rows.Count; i++)
            {
                dynamic retObj = new ExpandoObject();
                retObj.id = dtRetHead.Rows[i]["srm_id"];
                retObj.date = dtRetHead.Rows[i]["date"];
                retObj.amount = dtRetHead.Rows[i]["amt"];
                string qryRetItems = "SELECT `itm_code`, `itm_name`, `si_price` as price"
                    + " , `sri_qty` as qty, `sri_discount_amount` as discount, `sri_total` as total "
                    + " FROM `tbl_salesreturn_items` WHERE srm_id='" + dtRetHead.Rows[i]["srm_id"] + "'";
                DataTable dtRetItems = db.SelectQuery(qryRetItems);
                retObj.items = dtRetItems;
                lstReturn.Add(retObj);
            }
            sb.Append(",");
            sb.Append("\"return_details\":");
            sb.Append(JsonConvert.SerializeObject(lstReturn, Formatting.Indented));
            sb.Append("}");
            return sb.ToString();
        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "";
        }
    }


}