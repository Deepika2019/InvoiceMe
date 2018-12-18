using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using System.IO;
public partial class sales_oldorderentry : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(36);
    }

    [WebMethod]
    public static string warehouseName(string branchid)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT branch_name FROM tbl_branch where branch_id="+branchid;
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }

    [WebMethod]
    public static string selectCustomerdata(string customerid)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string dataQry = "select cust_name,cust_type,cust_amount,max_creditamt,max_creditperiod,new_custtype,new_creditamt,new_creditperiod from tbl_customer where cust_id='" + customerid + "'";
        dt = db.SelectQuery(dataQry);
        if (dt.Rows[0]["new_custtype"].ToString() == "0" && dt.Rows[0]["new_creditamt"].ToString() == "0.00" && dt.Rows[0]["new_creditperiod"].ToString() == "0")
        {
            string jsonResponse = "";
            if (dt.Rows.Count > 0)
            {
                jsonResponse = JsonConvert.SerializeObject(dt, Formatting.Indented);
            }
            else
            {
                jsonResponse = "N";
            }
            return jsonResponse;
        }
        else
        {

            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Please contact admin to confirm customer settings\"}";
        }

    }

    [WebMethod]
    public static string saveOldEntryToSalesMaster(Dictionary<string, string> sl_mstr)
    {
        string result = "";
        string cust_amount = "";
        mySqlConnection db_order = new mySqlConnection();
        try
        {
            // checking session
            var session_chk_qry = "SELECT sm_id FROM tbl_sales_master WHERE sm_sales_sessionid='" + sl_mstr["session_id"] + "'";
            string session_exist = db_order.SelectScalar(session_chk_qry);
            if (!string.IsNullOrWhiteSpace(session_exist))
            { // existing so , skipped
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"Order saved already\"}";
                //cust_amount = db_order.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + sl_mstr["cust_id"] + "'");
              //  result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
            }
            else
            {
                var itmId = db_order.SelectScalar("Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + sl_mstr["branch"]);
                if (itmId == "")
                {
                    HttpContext.Current.Response.StatusCode = 401;
                    HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                    return "{\"message\":\"Add an old item in to cprresponding warehouse after you can add the old bill entry\"}";
                }

                string oldinvoiceid = sl_mstr["invoice_id"] + "#OLD ORDER ITEMS";
                string qryOldInvoiceCheck = "SELECT SIM.sm_id FROM tbl_sales_items SIM inner join tbl_sales_master SM on SM.sm_id=SIM.sm_id WHERE SM.branch_id=" + sl_mstr["branch"] + " && SIM.itm_name='" + oldinvoiceid + "'";
                string existId = db_order.SelectScalar(qryOldInvoiceCheck);
                if (!string.IsNullOrWhiteSpace(existId))
                { // existing so , skipped
                    HttpContext.Current.Response.StatusCode = 401;
                    HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                    return "{\"message\":\"Order having same invoice number repeated\"}";
                    //result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                }
                else
                {
                    db_order.BeginTransaction();
                    DataTable ddt = new DataTable();
                    string branchQry = "select branch_timezone from tbl_branch where branch_id='" + sl_mstr["branch"] + "'";
                    DataTable cTimeZone = db_order.SelectQueryForTransaction(branchQry);
                    string branch_timezone = "";
                    if (cTimeZone != null)
                    {
                        branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
                    }

                    TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
                    DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
                    string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
                    
                    Int32 BillNo = 0;
                    Decimal sm_paid = Convert.ToDecimal(sl_mstr["sm_netamount"]) - Convert.ToDecimal(sl_mstr["total_balance"]);

                    string branchOutPrefix = "";
                    string branchOutSuffix = "";
                    int branchOutStart = 0;
                    string BranchInvoiceQry = "SELECT branch_orderPrefix,branch_orderSerial,branch_orderSuffix from tbl_branch where branch_id='" + sl_mstr["branch"] + "'";
                    DataTable BranchInvoiceData = db_order.SelectQueryForTransaction(BranchInvoiceQry);
                    if (BranchInvoiceData != null)
                    {
                        branchOutPrefix = Convert.ToString(BranchInvoiceData.Rows[0]["branch_orderPrefix"]);
                        branchOutStart = Convert.ToInt32(BranchInvoiceData.Rows[0]["branch_orderSerial"]);
                        branchOutSuffix = Convert.ToString(BranchInvoiceData.Rows[0]["branch_orderSuffix"]);
                    }
                    string suffixQry = "SELECT IFNULL(max(sm_serialNo),0) FROM tbl_sales_master where branch_id=" + sl_mstr["branch"] + "  and sm_prefix='" + branchOutPrefix + "-OO'";
                    int invoiceOutSuffix = Convert.ToInt32(db_order.SelectScalarForTransaction(suffixQry));
                    if (invoiceOutSuffix == 0)
                    {
                        invoiceOutSuffix = branchOutStart + 1;
                    }
                    else
                    {
                        invoiceOutSuffix = Math.Max(branchOutStart, invoiceOutSuffix);
                        invoiceOutSuffix = invoiceOutSuffix + 1;
                    }

                    string query = "";
                    //end cod forcreate unique invoice number: done by deepika
                    query = "INSERT INTO tbl_sales_master(cust_id,branch_id,sm_total,sm_discount_rate,sm_discount_amount,sm_netamount,sm_date,";
                    query = query + "sm_userid,sm_specialnote,sm_delivery_status,sm_latitude,sm_longitude,sm_processed_id,sm_delivered_id,sm_prefix,sm_serialNo,sm_suffix,sm_invoice_no,sm_sales_sessionid,sm_type,sm_processed_date)";
                    query = query + "VALUES ('" + sl_mstr["cust_id"] + "','" + sl_mstr["branch"] + "','" + sl_mstr["sm_netamount"] + "','0','0','" + sl_mstr["sm_netamount"] + "','" + sl_mstr["sm_date"] + "',";
                    query = query + "'" + sl_mstr["user_id"] + "',";
                    query = query + "'" + sl_mstr["sm_specialnote"] + "','2',0,0,0,0,'" + branchOutPrefix + "-OO','" + invoiceOutSuffix + "','" + branchOutSuffix + "',concat(sm_prefix,sm_serialNo,sm_suffix),'" + sl_mstr["session_id"] + "','2','" + sl_mstr["sm_date"] + "');Select last_insert_id()";
                    BillNo = Convert.ToInt32(db_order.SelectScalarForTransaction(query));
                    string updateRefrenceQry = "update tbl_sales_master set sm_refno=" + BillNo + " where sm_id=" + BillNo + "";
                    db_order.ExecuteQueryForTransaction(updateRefrenceQry);

                    if (BillNo != 0)
                    {
                        string qry1 = "INSERT INTO tbl_sales_items (si_id,sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_tax_amount,itm_type)";
                        qry1 = qry1 + "VALUES ";
                        string qryt = "Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + sl_mstr["branch"];
                        Int64 salesitemBranchId = Convert.ToInt64(db_order.SelectScalarForTransaction("Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + sl_mstr["branch"]));

                        string qry_main = qry1 + "(null,'" + BillNo + "','0','" + salesitemBranchId + "', '1234567891234','" + oldinvoiceid + "',";
                        qry_main = qry_main + "'0','" + sl_mstr["sm_netamount"] + "','" + sl_mstr["sm_netamount"] + "','1',";
                        qry_main = qry_main + "'" + sl_mstr["sm_netamount"] + "',";
                        qry_main = qry_main + "'0','0','" + sl_mstr["sm_netamount"] + "','0','0','0','0','0','0','3','0','1')";

                        bool qrystatus = db_order.ExecuteQueryForTransaction(qry_main);
                        if (qrystatus)
                        {

                            //inserts to transaction table
                            //inserting order debit entry
                            MySqlCommand cmdInsDr = new MySqlCommand();
                            cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                                " (`session_id`,`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                                " select @session_id,@action_type, @action_ref_id, @partner_id, @partner_type, @branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                            cmdInsDr.Parameters.AddWithValue("@session_id", sl_mstr["session_id"]);
                            cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                            cmdInsDr.Parameters.AddWithValue("@action_ref_id", BillNo);
                            cmdInsDr.Parameters.AddWithValue("@partner_id", sl_mstr["cust_id"]);
                            cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                            cmdInsDr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                            cmdInsDr.Parameters.AddWithValue("@user_id", sl_mstr["user_id"]);
                            cmdInsDr.Parameters.AddWithValue("@narration", " Old order entry of invoice id :#" + sl_mstr["invoice_id"] + " and Ref ORD.ID #" + BillNo + " with net amount " + sl_mstr["sm_netamount"]);
                            cmdInsDr.Parameters.AddWithValue("@dr", sl_mstr["sm_netamount"]);
                            cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                            db_order.ExecuteQueryForTransaction(cmdInsDr);

                            //check is cash paid
                            if (sm_paid > 0)
                            {
                                //inserting order credit entry
                                MySqlCommand cmdInsCr = new MySqlCommand();
                                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                                " (`session_id`,`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`,`cash_amt`, `cr`,  `date`,`closing_balance`)" +
                                "select '" + BillNo + "',@action_type, @action_ref_id, @partner_id, @partner_type, @branch_id, @user_id, @narration,'" + sm_paid + "', @cr, @date , (ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                                cmdInsCr.Parameters.AddWithValue("@session_id", sl_mstr["session_id"]);
                                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                                cmdInsCr.Parameters.AddWithValue("@action_ref_id", BillNo);
                                cmdInsCr.Parameters.AddWithValue("@partner_id", sl_mstr["cust_id"]);
                                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                                cmdInsCr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                                cmdInsCr.Parameters.AddWithValue("@user_id", sl_mstr["user_id"]);
                                cmdInsCr.Parameters.AddWithValue("@narration", "Paid " + sm_paid + " for Order #" + BillNo);
                                cmdInsCr.Parameters.AddWithValue("@cr", sm_paid);
                                cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                                db_order.ExecuteQueryForTransaction(cmdInsCr);
                            }

                            // UPDATING CUSTOMER DETAILS

                            string update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_last_updated_date='" + currdatetime + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + sl_mstr["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id='" + sl_mstr["cust_id"] + "'; SELECT cust_amount FROM tbl_customer WHERE cust_id=" + sl_mstr["cust_id"];
                            cust_amount = db_order.SelectScalarForTransaction(update_tbl_cust_branch_amounts);
                            db_order.CommitTransaction();
                            result = "Y";
                            //result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";

                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            try
            {
                result = "N";
              //  result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                db_order.RollBackTransaction();
                LogClass log = new LogClass("outstandingpayment");
                log.write(ex);
                return result;
            }
            catch
            {
            }
        }
        return result;
        //change code
    }
    //stop: Adding Bill Details to sales master
}