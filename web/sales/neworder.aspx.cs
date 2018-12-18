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
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using System.IO;
using iTextSharp.text;
using System.Web.Script.Services;
using MySql.Data.MySqlClient;
using System.Net.Mail;
using System.Net;
public partial class sales_neworder : System.Web.UI.Page
{
    mySqlConnection db=new mySqlConnection();
    public string settings;
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication bill = new LoginAuthentication();
        bill.userAuthentication();
        bill.checkPageAcess(7);
        getSystemSettingsData();
    }

    /// <summary>
    /// method to get system settings and set it in javascript object
    /// </summary>
    public void getSystemSettingsData()
    {
        string qry = "select ss_price_change,ss_discount_change,ss_foc_change,ss_decimal_accuracy,ss_allow_zero_stock_order from tbl_system_settings";
        DataTable dtSetings = db.SelectQuery(qry);
        settings = JsonConvert.SerializeObject(dtSetings, Formatting.Indented);
    }

    //Start: get member datas
    [WebMethod]
    public static string getCustomerDatas(string customerId)
    {

        String resultStatus;
        resultStatus = "N";
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        // Sales Tax

        string qry = "select cust_id,cust_name,cust_amount,cust_type from tbl_customer where cust_id='" + customerId + "'";
        dt = db.SelectQuery(qry);
        StringBuilder sb = new StringBuilder();
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["cust_id"] is DBNull)
                {
                    resultStatus = "N";
                }
                else
                {
                    sb.Append(dt.Rows[0]["cust_id"] + "@@##$$" + dt.Rows[0]["cust_name"] + "@@##$$" + dt.Rows[0]["cust_amount"] + "@@##$$" + dt.Rows[0]["cust_type"]);
                }
            }
            else
            {
                return resultStatus;
            }
        }


        return "Y@@##$$" + sb.ToString();
    }

    //Start: Member Search Details..
    [WebMethod]
    public static string searchOrderCustomers(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {

            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {

                if (filters.ContainsKey("cust_id"))
                {
                    query_condition += " and cust_id LIKE '%" + filters["cust_id"] + "%'";
                }
                if (filters.ContainsKey("cust_name"))
                {
                    query_condition += " and cust_name LIKE '%" + filters["cust_name"] + "%'";
                }
                if (filters.ContainsKey("cust_phone"))
                {
                    query_condition += " and cust_phone like '%" + filters["cust_phone"] + "%'";
                }
                if (filters.ContainsKey("cust_amount"))
                {
                    query_condition += " and cust_amount='" + filters["cust_amount"] + "'";
                }
                if (filters.ContainsKey("cust_type"))
                {
                    query_condition += " and cust_type='" + filters["cust_type"] + "'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_customer " + query_condition;


            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }

            // innerqry = "SELECT *, ROW_NUMBER() OVER (order by member_id) as row FROM member " + searchResult;

            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            innerqry = "SELECT cust_id,cust_name,cust_type,cust_phone,cust_email,cust_amount,max_creditamt,"
                +" max_creditperiod,new_custtype,new_creditamt,new_creditperiod from tbl_customer"
                + " cu JOIN tbl_user_locations ul ON cu.location_id=ul.location_id"
                +"" + query_condition+" AND ul.user_id='" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "' GROUP BY cu.cust_id ORDER BY cu.cust_name ASC LIMIT " + offset.ToString() + " ," + per_page;
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
    //Stop: Member Search Details..



    //start: Item Pos Search Details
    [WebMethod]
    public static string searchOrderitem(int page, Dictionary<string, string> filters, int perpage, int customertype, string cust_id)
    {
        try
        {
            string query_condition = "";
            if (filters["allowZeroStockOrder"] == "0")
            {
                query_condition = " where 1=1 and itbs_available = 1 and tis.itm_code not in ('1234567891234') and itbs_stock>0";
            }
            else
            {
               query_condition = " where 1=1 and itbs_available = 1 and tis.itm_code not in ('1234567891234')";
            }
          
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("warehouse"))
                {
                    query_condition += " and branch_id ='" + filters["warehouse"] + "'";
                }
                if (filters.ContainsKey("itemname"))
                {
                    query_condition += " and tis.itm_name  LIKE '%" + filters["itemname"] + "%'";
                }
                if (filters.ContainsKey("itemcode"))
                {
                    query_condition += " and tis.itm_code  LIKE '%" + filters["itemcode"] + "%'";
                }
                if (filters.ContainsKey("isPackage"))
                {
                    query_condition += " and itm_type=1";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            
            countQry = "SELECT count(*) FROM tbl_itembranch_stock tis inner join tbl_item_master im on im.itm_id=tis.itm_id " + query_condition;


            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT itbs_id,tis.itm_id,itbs_stock,itbs_reorder,tis.itm_code,tis.itm_name,tis.itm_brand_id,tis.itm_category_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,tib.brand_name,tic.cat_name,tp_tax_percentage,tp_cess from tbl_itembranch_stock tis left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id inner join tbl_tax_profile tp on tp.tp_tax_code=tis.tp_tax_code inner join tbl_item_master im on im.itm_id=tis.itm_id";
            innerqry = innerqry + query_condition + " ";
            innerqry = innerqry + " order by itm_rating desc LIMIT " + offset.ToString() + " ," + per_page;
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
    //stop: Item Pos Search Details

  
    [WebMethod]// 
    public static string saveToSalesMaster(Dictionary<string, string> neworder) // ,createNewCouponOrder string item_details
    {
        string result = "";
        string message = "";

        mySqlConnection db = new mySqlConnection();
        try
        {
            db.BeginTransaction();

            // FOR SALES_MASTER
            string cust_name = "";
            double sm_discount_rate = 0;
            double sm_discount_amount = 0;
            double sm_netamount = 0;
            double sm_total = 0;
            double sm_balance = 0;
            double sm_tax_excluded_amt = 0;
            double sm_tax_amount = 0;
            Int32 sm_delivery_status;

            // FOR SALES ITEMS
            string itm_code = "";
            string itm_name = "";
            double si_org_price;
            double si_total;
            double si_discount_amount;
            double si_net_amount;
            double itm_commision;
            double itm_commisionamt = 0;
            double si_item_tax;
            double si_item_cgst = 0, si_item_sgst = 0, si_item_igst = 0, si_item_utgst = 0;
            double si_item_cess;
            double si_tax_amount;
            double classType;
            int approveCheck = 0;

            //*****************************************************************************//


            // CHECKING CUSTOMER FOR VALUE CHANGES - NEW REGISTRAION - CLASS CREDIT CHANGES
            sm_delivery_status = Convert.ToInt32(neworder["sm_delivery_status"]);
            string customerDetailQry = "SELECT cust_id,cust_name,cust_type,new_custtype,new_creditamt,new_creditperiod,cust_status FROM tbl_customer where cust_id='" + neworder["cust_id"] + "'";
            DataTable dt_customerDetail = db.SelectQueryForTransaction(customerDetailQry);
            if (dt_customerDetail != null)
            {
                cust_name = Convert.ToString(dt_customerDetail.Rows[0]["cust_name"]);
                double cust_status = Convert.ToInt32(dt_customerDetail.Rows[0]["cust_status"]);
                double new_custtype = Convert.ToInt32(dt_customerDetail.Rows[0]["new_custtype"]);
                double new_creditamt = Convert.ToDouble(dt_customerDetail.Rows[0]["new_creditamt"]);
                double new_creditperiod = Convert.ToDouble(dt_customerDetail.Rows[0]["new_creditperiod"]);
                classType= Convert.ToDouble(dt_customerDetail.Rows[0]["cust_type"]);
            }
            else
            {
                db.RollBackTransaction();
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"There is no customer\"}";
            }

            //*****************************************************************************//


            int roundValue =Convert.ToInt32 (db.SelectScalarForTransaction("select ss_decimal_accuracy from tbl_system_settings"));
            // CKECKING SESSION
            string getsessionexist = "select sm_sales_sessionid from tbl_sales_master where sm_sales_sessionid='" + neworder["sessionId"] + "'";
            DataTable dtsession = db.SelectQueryForTransaction(getsessionexist);
            int sess_rows = dtsession.Rows.Count;

            if (sess_rows != 0)  // ALREADY SAVED CASE
            {
                db.RollBackTransaction();
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"Order saved already\"}";
            }
            else // EVERYTING GOES HERE
            {
                // RECIEVING ITEM DATA -> DE SERIALIZING JSON
                List<Dictionary<string, string>> item_details = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(neworder["item_details"]);
                dynamic order_data = JsonConvert.DeserializeObject(neworder["item_details"]);

                // SETTING TAX VARIABLES

                Int32 branch_tax_method = Convert.ToInt32(neworder["branch_tax_method"]);
                Int32 branch_tax_inclusive = Convert.ToInt32(neworder["branch_tax_inclusive"]);
                Int32 cust_state = 0;

                double realtotal = 0;
                double nettotal = 0;
                double discount_amt = 0;
                double tax_amount = 0;
                double commisionAmount = 0;
                double tax_included_nettotal = 0;
                double cessAmount = 0;
                int itemId = 0;
                double si_qty = 0;
                double si_price = 0;
                double si_foc = 0;
                double si_discount_rate = 0;
                int itm_type = 0;

                // ENTRY TO SALESMASTER - WITH AVAILABLE DATA

                // '" + neworder["branch"] + "'
                string branch_timezone = "";
                //start changed by deepika : 
                string branchPrefix = "";
                int branchStart = 0;
                string branchSuffix = "";
                string getTimeZone = "SELECT branch_timezone,branch_orderPrefix,branch_orderSerial,branch_orderSuffix from tbl_branch where branch_id='" + neworder["branch"] + "'";
                DataTable cTimeZone = db.SelectQueryForTransaction(getTimeZone);
                if (cTimeZone != null)
                {
                    branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
                    branchPrefix = Convert.ToString(cTimeZone.Rows[0]["branch_orderPrefix"]);
                    branchStart = Convert.ToInt32(cTimeZone.Rows[0]["branch_orderSerial"]);
                    branchSuffix = Convert.ToString(cTimeZone.Rows[0]["branch_orderSuffix"]);
                }
                else
                {
                    // no time zone recieved
                }

                // checking weather its IGST
                //end changed by deepika
                //start cod forcreate unique invoice number: done by deepika
                string suffixQry = "SELECT IFNULL(max(sm_serialNo),0) FROM tbl_sales_master where branch_id=" + neworder["branch"] + "  and sm_prefix='" + branchPrefix + "' and sm_suffix='"+branchSuffix+"'";
                int invoiceSerialNo= Convert.ToInt32(db.SelectScalarForTransaction(suffixQry));
                if (invoiceSerialNo == 0)
                {
                    if (branchStart != null)
                    {
                        invoiceSerialNo = branchStart + 1;
                    }
                }
                else
                {
                    invoiceSerialNo = Math.Max(branchStart, invoiceSerialNo);
                    invoiceSerialNo = invoiceSerialNo + 1;
                }

                //end cod forcreate unique invoice number: done by deepika


                string igst_qry = "Select tbl_branch.branch_state_id from tbl_branch join tbl_customer on tbl_branch.branch_state_id=tbl_customer.cust_state where tbl_branch.branch_id='" + neworder["branch"] + "' and tbl_customer.cust_id='" + neworder["cust_id"] + "'";
                DataTable igst_dt = db.SelectQueryForTransaction(igst_qry);
                int br_rows = igst_dt.Rows.Count;

                if (br_rows == 0)
                {
                    cust_state = 1;
                }
                else
                {
                    cust_state = 0;
                }

                TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
                DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
                string sm_date = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");

                //
                string insert_to_salsesQry = "INSERT INTO tbl_sales_master(cust_id,branch_id,sm_userid,sm_date,sm_specialnote,sm_delivery_status,sm_latitude,sm_longitude,sm_order_type,sm_payment_type,branch_tax_method,branch_tax_inclusive,sm_sales_sessionid,sm_price_class,sm_type,sm_processed_date,sm_last_updated_date) VALUES ('" + neworder["cust_id"] + "','" + neworder["branch"] + "','" + neworder["sm_userid"] + "','" + sm_date + "','" + neworder["sm_specialnote"] + "'," + sm_delivery_status + ",'" + neworder["sm_latitude"] + "','" + neworder["sm_longitude"] + "','" + neworder["sm_order_type"] + "','" + neworder["sm_payment_type"] + "','" + branch_tax_method.ToString() + "','" + branch_tax_inclusive.ToString() + "','" + neworder["sessionId"] + "'," + classType + ",1,'" + sm_date + "','"+sm_date+"');Select last_insert_id();";
                var last_id = db.SelectScalarForTransaction(insert_to_salsesQry);
                result = last_id;
                Int32 sm_id = Convert.ToInt32(last_id);

                // PROCESSING ITEMS
                Int32 row_no = 0;

                //start changed by deepika
                string insert_to_sales_items = "INSERT INTO tbl_sales_items(sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_item_tax,si_item_cgst,si_item_sgst,si_item_igst,si_item_utgst,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type) VALUES ";
                string itbsidString = "";

                foreach (var items in order_data)
                {
                    if (items.si_itm_type != 4)
                    {
                        itbsidString = itbsidString + "," + items.itbs_id;
                    }
                }

                itbsidString = itbsidString.Trim().TrimStart(',');

                // fetch item details from item_branch_stock and tbl_tax_profile
                DataTable dt_itemDetail = new DataTable();

                if (itbsidString != "")
                {
                    string item_fetch_qry = "select itm_type,itb.itm_id,itb.itbs_id,tax.tp_tax_percentage,tax.tp_cess,itb.itm_name,itb.itm_code,itb.itm_commision from tbl_itembranch_stock itb inner join tbl_item_master tim on tim.itm_id=itb.itm_id join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code where itb.itbs_id in (" + itbsidString + ")  ORDER BY FIELD(itb.itbs_id, " + itbsidString + ")";
                    dt_itemDetail = db.SelectQueryForTransaction(item_fetch_qry);
                }
                int size = item_details.Count;
                int j = 0;
                StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                StringBuilder sb_bulk_items = new StringBuilder();

                sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES ");
                for (int i = 0; i < size; i++)
                {// BASE VALUES
                    si_qty = order_data[i].si_qty;
                    si_price = order_data[i].si_price;
                    si_foc = order_data[i].si_foc;
                    si_discount_rate = order_data[i].si_discount_rate;
                    si_org_price = order_data[i].si_org_price;
                    if (order_data[i].si_itm_type == 4)
                    {
                        itm_commision = 6;
                        si_item_tax = 0.00;
                        si_item_cess = 0.00;
                        itm_name = order_data[i].itm_name;
                        itm_code = "0000000000000";
                        //if (j > 0)
                        //{
                        //    j = j - 1;
                        //}
                    }
                    else
                    {
                       
                        itm_commision = Convert.ToDouble(dt_itemDetail.Rows[j]["itm_commision"]);
                        si_item_tax = Convert.ToDouble(dt_itemDetail.Rows[j]["tp_tax_percentage"]);
                        si_item_cess = Convert.ToDouble(dt_itemDetail.Rows[j]["tp_cess"]);
                        itm_name = Convert.ToString(dt_itemDetail.Rows[j]["itm_name"]);
                        itm_code = Convert.ToString(dt_itemDetail.Rows[j]["itm_code"]);
                        itm_type= Convert.ToInt32(dt_itemDetail.Rows[j]["itm_type"]);
                        itemId= Convert.ToInt32(dt_itemDetail.Rows[j]["itm_id"]);
                        j = j + 1;
                    }
                    // CALCULATIONS
                    if (branch_tax_method == 0) // no tax
                    {
                        realtotal = si_price * si_qty; // price without discount
                        realtotal = Math.Round(realtotal, roundValue);
                        discount_amt = ((realtotal * si_discount_rate) / 100);
                        nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                        tax_included_nettotal = Math.Round(nettotal, roundValue);
                        commisionAmount = ((nettotal * itm_commision) / 100);
                        commisionAmount = Math.Round(commisionAmount, roundValue);
                        tax_amount = 0; // not tax used
                        cessAmount = 0;

                    }
                    else if (branch_tax_method == 1) // VAT CALCULATION
                    {
                        if (branch_tax_inclusive == 1)  // tax is included with the price
                        {
                            if (si_item_cess > 0)
                            {
                                double denominator = 10000 * si_price;
                                double baseval = 10000 + (100 * si_item_tax) + (si_item_tax * si_item_cess);
                                si_price = denominator / baseval;
                            }
                            else
                            {
                                double constant = (si_item_tax / 100) + 1; // equation for the dividing constant
                                si_price = si_price / constant;
                            }

                        }

                        realtotal = si_price * si_qty; // price without discount
                        discount_amt = ((realtotal * si_discount_rate) / 100);
                        nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                        commisionAmount = ((nettotal * itm_commision) / 100);
                        tax_amount = ((nettotal * si_item_tax) / 100);
                        cessAmount = ((tax_amount * si_item_cess) / 100);
                        tax_amount = cessAmount + tax_amount;
                        tax_included_nettotal = nettotal + tax_amount;

                        // VAT ENDS
                    }
                    else if (branch_tax_method == 2) // GST CALCULATION
                    {
                        if (branch_tax_inclusive == 1)  // tax is included with the price
                        {
                            if (si_item_cess > 0)
                            {
                                double denominator = 10000 * si_price;
                                double baseval = 10000 + (100 * si_item_tax) + (si_item_tax * si_item_cess);
                                si_price = denominator / baseval;
                            }
                            else
                            {
                                double constant = (si_item_tax / 100) + 1; // equation for the dividing constant
                                si_price = si_price / constant;
                                si_item_cess = 0;

                            }
                        }

                        realtotal = si_price * si_qty; // price without discount
                        discount_amt = ((realtotal * si_discount_rate) / 100);
                        nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                        commisionAmount = ((nettotal * itm_commision) / 100);
                        tax_amount = ((nettotal * si_item_tax) / 100);
                        cessAmount = ((tax_amount * si_item_cess) / 100);
                        tax_amount = cessAmount + tax_amount;
                        tax_included_nettotal = nettotal + tax_amount;

                        // CHECKING CUSTOMER STATE FOR IGST - DETERINATION

                        if (cust_state == 0)
                        { // default state , No IGST

                            double splitted_GST_rate = si_item_tax / 2;
                            splitted_GST_rate = Math.Round(splitted_GST_rate, roundValue);

                            si_item_cgst = splitted_GST_rate;
                            si_item_sgst = splitted_GST_rate;
                            si_item_igst = 0;
                            si_item_utgst = 0;
                        }
                        else
                        { // IGST PRESENT

                            si_item_cgst = 0;
                            si_item_sgst = 0;
                            si_item_igst = si_item_tax;
                            si_item_utgst = 0;

                        }
                        // GST CALCULATION ENDS
                    }
                    si_total = realtotal;
                    si_discount_amount = discount_amt;
                    si_net_amount = tax_included_nettotal;
                    itm_commisionamt = commisionAmount;
                    si_tax_amount = tax_amount;

                    // INSERTING INTO TBL_SALES_ITEMS
                    
                    insert_to_sales_items += " (" + "'" + sm_id + "','" + row_no + "', '" + order_data[i].itbs_id + "', '" + itm_code + "', '" + itm_name + "', '0', '" + si_org_price + "', '" + order_data[i].si_price + "', '" + si_qty + "', '" + si_total + "', '" + si_discount_rate + "', '" + si_discount_amount + "', '" + si_net_amount + "', '" + si_foc + "', '" + order_data[i].si_approval_status + "', '" + itm_commision + "', '" + itm_commisionamt + "', '0', '0','" + order_data[i].si_itm_type + "', '" + si_item_tax + "', '" + si_item_cgst + "', '" + si_item_sgst + "', '" + si_item_igst + "', '" + si_item_utgst + "', '" + si_item_cess + "', '" + (si_net_amount - tax_amount) + "', '" + tax_amount + "',"+itm_type+"),";

                    //  }

                    row_no++;

                    // calculation for sm - values

                    sm_tax_excluded_amt = sm_tax_excluded_amt + (si_net_amount - si_tax_amount);
                    sm_discount_amount = sm_discount_amount + si_discount_amount;
                    sm_netamount = sm_netamount + si_net_amount;
                    sm_tax_amount = sm_tax_amount + si_tax_amount;
                    sm_total = sm_total + si_total;
                    // HANDLE STOCK
                    if (order_data[i].si_itm_type != "1" && order_data[i].si_itm_type != "3" && order_data[i].si_itm_type != "4")
                    {
                        if (itm_type== 1)
                        {
                            Int32 item_total_qty = Convert.ToInt32(si_foc) + Convert.ToInt32(si_qty);

                            string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock - " + item_total_qty + ") where itbs_id='" + order_data[i].itbs_id + "'";
                            bool upstockresult = db.ExecuteQueryForTransaction(upstockQry);                      
                            sb_bulk_items.Append("('" + order_data[i].itbs_id + "','" + ((int)Constants.ActionType.SALES) + "','" + sm_id + "','" + neworder["sm_userid"] + "'");
                            sb_bulk_items.Append(",'Sold " + item_total_qty + " " + itm_name + " in order #" + sm_id + "','" + item_total_qty + "'");
                            sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + order_data[i]["itbs_id"] + "')");
                            sb_bulk_items.Append(",'" + sm_date + "')" + (i != size - 1 ? "," : ";"));

                        }
                        // code to record stock transaction end
                    }
                   

                    if (itm_type == 3)
                    {
                        DataTable couponDt = db.SelectQueryForTransaction("select cpn_qty from tbl_coupon_master where cpn_itm_id=" + itemId);
                        double totalQty = Convert.ToDouble(couponDt.Rows[0]["cpn_qty"]) * si_qty;
                        db.ExecuteQueryForTransaction("insert into tbl_customer_packages (cust_id,sm_id,itbs_id,package_total_count,package_current_count,package_date) values(" + neworder["cust_id"] + "," + sm_id + "," + order_data[i].itbs_id + "," + totalQty + "," + totalQty + ",'" + sm_date + "')");
                    }

                    //end for loop  
                }
                insert_to_sales_items = insert_to_sales_items.Remove(insert_to_sales_items.Trim().Length - 1);
                bool Itemresult = db.ExecuteQueryForTransaction(insert_to_sales_items);

                //end changed by deepika


                // bulk insert stock transactions
                if (sb_bulk_items.ToString() != "")
                {

                    sb_bulk_stkTrQry.Append(sb_bulk_items.ToString());
                    db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
                }
                // calculating discount rate
                double divider = sm_tax_excluded_amt + sm_discount_amount;
                double divident = sm_discount_amount * 100;
                sm_discount_rate = divident / divider;
                sm_discount_rate = Math.Round(sm_discount_rate, roundValue);

                // getting payment details

  
                double current_total_paymet = 0;

                if (Convert.ToDouble(neworder["sm_cash_amt"]) != 0) // if paid with cash
                {
                    
                    current_total_paymet += Convert.ToDouble(neworder["sm_cash_amt"]) ;
                }
                if (Convert.ToDouble(neworder["sm_chq_amt"]) != 0)
                {
                    
                    current_total_paymet += Convert.ToDouble(neworder["sm_chq_amt"]);
                }
                if (Convert.ToDouble(neworder["sm_card_amt"]) != 0)
                {

                    current_total_paymet += Convert.ToDouble(neworder["sm_card_amt"]);
                }
                if (Convert.ToDouble(neworder["sm_wallet_amt"]) != 0)
                {
                    
                    current_total_paymet += Convert.ToDouble(neworder["sm_wallet_amt"]);
                }

                double sm_paid = current_total_paymet;
                sm_paid = Math.Round(sm_paid, roundValue);
                sm_tax_excluded_amt = Math.Round(sm_tax_excluded_amt, roundValue);
                sm_balance = sm_netamount - sm_paid;

                // UPDATING SALES MASTER

                string update_salesmaster_qry = "UPDATE tbl_sales_master SET sm_total='" + sm_total + "',sm_discount_rate='" + sm_discount_rate + "',sm_discount_amount='" + sm_discount_amount + "',sm_netamount='" + sm_netamount + "',sm_tax_excluded_amt='" + sm_tax_excluded_amt + "',sm_tax_amount='" + sm_tax_amount + "',sm_refno='" + sm_id + "' WHERE sm_id='" + sm_id + "'";
                bool update_sales_result = db.ExecuteQueryForTransaction(update_salesmaster_qry);

                //inserts to transaction table
                //inserting order debit entry
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `session_id`, `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`,`user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                    " select @session_id, @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                cmdInsDr.Parameters.AddWithValue("@session_id", neworder["sessionId"]);
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", sm_id);
                cmdInsDr.Parameters.AddWithValue("@partner_id", neworder["cust_id"]);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", neworder["branch"]);
                cmdInsDr.Parameters.AddWithValue("@user_id", neworder["sm_userid"]);
                cmdInsDr.Parameters.AddWithValue("@narration", "Order #" + sm_id + " is placed with net amount " + sm_netamount);
                cmdInsDr.Parameters.AddWithValue("@dr", sm_netamount);
                cmdInsDr.Parameters.AddWithValue("@date", sm_date);
                db.ExecuteQueryForTransaction(cmdInsDr);

                //inserting order - when amount paid from customer wallet
                if (Convert.ToDouble(neworder["sm_wallet_amt"]) != 0)
                {

                    MySqlCommand cmdInsWallet = new MySqlCommand();
                    cmdInsWallet.CommandText = "INSERT INTO `tbl_transactions` " +
                        " ( `session_id`, `action_type`,  `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                        " select @session_id, @action_type, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                    cmdInsWallet.Parameters.AddWithValue("@session_id", neworder["sessionId"]);
                    cmdInsWallet.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.WITHDRAWAL);
                    cmdInsWallet.Parameters.AddWithValue("@partner_id", neworder["cust_id"]);
                    cmdInsWallet.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                    cmdInsWallet.Parameters.AddWithValue("@branch_id", neworder["branch"]);
                    cmdInsWallet.Parameters.AddWithValue("@user_id", neworder["sm_userid"]);
                    cmdInsWallet.Parameters.AddWithValue("@narration", "Withdrawn " + neworder["sm_wallet_amt"] + " from Wallet for clearing the Order #" + sm_id);
                    cmdInsWallet.Parameters.AddWithValue("@dr", neworder["sm_wallet_amt"]);
                    cmdInsWallet.Parameters.AddWithValue("@date", sm_date);
                    db.ExecuteQueryForTransaction(cmdInsWallet);
                }
                //check is cash paid
                if (sm_paid > 0)
                {
                    //inserting order credit entry
                    MySqlCommand cmdInsCr = new MySqlCommand();
                    cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                        " ( `session_id`, `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`,cash_amt,wallet_amt " +
                        (Convert.ToDouble(neworder["sm_chq_amt"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                        (Convert.ToDouble(neworder["sm_card_amt"]) != 0 ? ", `card_amt`, `card_no`" : "") +
                        ", `cr`, `date`,`closing_balance`)" +
                        " select @session_id, @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt,@wallet_amt" +
                        (Convert.ToDouble(neworder["sm_chq_amt"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                         (Convert.ToDouble(neworder["sm_card_amt"]) != 0 ? ", @card_amt, @card_no" : "") +
                        ", @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                    cmdInsCr.Parameters.AddWithValue("@session_id", neworder["sessionId"]);
                    cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                    cmdInsCr.Parameters.AddWithValue("@action_ref_id", sm_id);
                    cmdInsCr.Parameters.AddWithValue("@partner_id", neworder["cust_id"]);
                    cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                    cmdInsCr.Parameters.AddWithValue("@branch_id", neworder["branch"]);
                    cmdInsCr.Parameters.AddWithValue("@user_id", neworder["sm_userid"]);
                    cmdInsCr.Parameters.AddWithValue("@narration", "Paid " + sm_paid + " for Order #" + sm_id);
                    cmdInsCr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(neworder["sm_cash_amt"]));
                    cmdInsCr.Parameters.AddWithValue("@wallet_amt", Convert.ToDecimal(neworder["sm_wallet_amt"]));
                    //cmdInsDr.Parameters.AddWithValue("@card_amt", neworder["sessionId"]);
                    //cmdInsDr.Parameters.AddWithValue("@card_no", neworder["sessionId"]);
                    if (Convert.ToDouble(neworder["sm_chq_amt"]) != 0)
                    {
                        cmdInsCr.Parameters.AddWithValue("@cheque_amt", neworder["sm_chq_amt"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_no", neworder["sm_chq_no"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_date", neworder["sm_chq_date"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_bank", neworder["sm_bank"]);
                    }
                    if (Convert.ToDouble(neworder["sm_card_amt"]) != 0)
                    {
                        cmdInsCr.Parameters.AddWithValue("@card_amt", neworder["sm_card_amt"]);
                        cmdInsCr.Parameters.AddWithValue("@card_no", neworder["sm_card_no"]);
                    }
                    cmdInsCr.Parameters.AddWithValue("@cr", sm_paid);
                    cmdInsCr.Parameters.AddWithValue("@date", sm_date);
                    db.ExecuteQueryForTransaction(cmdInsCr);
                }
            
                // UPDATING CUSTOMER DETAILS

                string update_cust_qry = "UPDATE tbl_customer SET cust_last_updated_date='"+sm_date+"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + neworder["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") WHERE cust_id='" + neworder["cust_id"] + "'";
                bool upcust_result = db.ExecuteQueryForTransaction(update_cust_qry);
                if (upcust_result)
                {
                    db.ExecuteQueryForTransaction("update tbl_transactions set last_updated_date='" + sm_date + "' where action_type=1 and action_ref_id=" + sm_id + "");
                }
                dynamic approve_data = JsonConvert.DeserializeObject(neworder["acknowledgement"]);
         
                int salesId = 0;
                int accountId = 0;
                int deliveryId = 0;

                int salesStatus = 0;
                int accountStatus = 0;
                int deliveryStatus = 0;

                string salesDate = "";
                string accountDate = "";
                string deliveryDate = "";
                if (approve_data.salesTick == "0" && approve_data.accountTick == "0" && approve_data.deliveryTick=="0")
                {
                    db.ExecuteQueryForTransaction("insert into tbl_order_approve (sm_id) values(" + sm_id + ")");
                }
                else
                {
                    if (approve_data.salesTick == 1)
                    {
                        salesId = Convert.ToInt32(neworder["sm_userid"]);
                        salesStatus = 1;
                        salesDate= TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
                    }
                    if (approve_data.accountTick == 1)
                    {
                        accountId = Convert.ToInt32(neworder["sm_userid"]);
                        accountStatus = 1;
                        accountDate = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
                    }
                    if (approve_data.deliveryTick == 1)
                    {
                        deliveryId = Convert.ToInt32(neworder["sm_userid"]);
                        deliveryStatus = 1;
                        deliveryDate = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
                    }
                 //   string asdf = "insert into tbl_order_approve values(" + sm_id + "," + salesId + "," + accountId + "," + deliveryId + "," + salesStatus + "," + accountStatus + "," + deliveryStatus + ",'" + salesDate + "','" + accountDate + "','" + deliveryDate + "')";
                    db.ExecuteQueryForTransaction("insert into tbl_order_approve values(null," + sm_id + ","+salesId+","+accountId+","+deliveryId+","+salesStatus+","+accountStatus+","+deliveryStatus+",'"+salesDate+"','"+accountDate+"','"+deliveryDate+"')");

                    approveCheck = Convert.ToInt32(db.SelectScalarForTransaction("select count(*) from tbl_order_approve where oa_sales_status=1 and oa_account_status=1 and oa_delivery_status=1 and sm_id=" + sm_id));
                    //if (approveCheck == 1)
                    //{
                    //    db.ExecuteQueryForTransaction("UPDATE tbl_sales_master SET sm_delivery_status='2' , sm_approved_id='" + salesId + "',sm_approved_date='" + TimeNow.ToString("yyyy/MM/dd HH:mm:ss") + "' where sm_refno='" + sm_id + "'");
                    //}
                }
                result = last_id;

            }

            //*****************************************************************************//
            if (approveCheck != 1)
            {
                int confirmOrderCount = Convert.ToInt32(db.SelectScalarForTransaction("select count(sm_id) from tbl_sales_master where sm_delivery_status=3"));
                DataTable emailSelectionDt = db.SelectQueryForTransaction("SELECT emailid FROM `tbl_user_details` WHERE user_type in (select distinct user_type from tbl_button_permission where ub_id IN (6,7,8,3,4,5))");
                string mailId = "";
                for (int i = 0; i < emailSelectionDt.Rows.Count; i++)
                {
                    if (emailSelectionDt.Rows[i]["emailid"] != null && emailSelectionDt.Rows[i]["emailid"] != "")
                    {
                        mailId += "," + emailSelectionDt.Rows[i]["emailid"];
                    }

                }
                mailId = mailId.Trim().TrimStart(',');
                //string str = mailSending(mailId, confirmOrderCount);
                //sendPushNotification();
            }
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                db.RollBackTransaction();
                LogClass log = new LogClass("neworder");
                log.write(ex);
                return result;
            }
            catch
            {
            }

            throw ex;
        }



        return result;
    }
    //stop: Adding order Details to sales master

    #region
    //method for mail sending
    private static string mailSending(string email, int count)
    {
        try
        {
            //Create the msg object to be sent
            MailMessage msg = new MailMessage();
            //Add your email address to the recipients
            msg.To.Add(email);
            //Configure the address we are sending the mail from
            MailAddress address = new MailAddress("mail@billcrm.com");
            msg.From = address;
            msg.Subject = "You have " + count + " pending approvals";
            msg.Body = "Please check the " + count + " pending approvals for confirmation 'http://hn.billcrm.com/login.aspx'";

            SmtpClient client = new SmtpClient();
            client.Host = "relay-hosting.secureserver.net";
            client.Port = 25;


            //Setup credentials to login to our sender email address ("UserName", "Password")
            NetworkCredential credentials = new NetworkCredential("mail@billcrm.com", "b2426794");
            client.UseDefaultCredentials = true;
            client.Credentials = credentials;


            //Send the msg
            client.Send(msg);
            return "Y";
            //Display some feedback to the user to let them know it was sent
            // Response.Write("mail send");

        }
        catch (Exception ex)
        {
            LogClass log = new LogClass("Mailsending:neworder");
            log.write(ex);
            return "N";
            //Response.Write(ex.ToString());
            //If the message failed at some point, let the user know
            //lblResult.Text = ex.ToString(); //alt text "Your message failed to send, please try again."
        }
    }

    #endregion

    //edited anjana
    [WebMethod]
    public static string SearchItem(string searchName, string BranchId, string type, string cust_id)
    {
        mySqlConnection db = new mySqlConnection();
        string itemQry = "";
       
        if (type == "0")
        {
            itemQry = "SELECT itbs_id,itm_id,itbs_stock,itbs_reorder,itm_code,itm_name,itm_brand_id,itm_category_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,tib.brand_name,tic.cat_name,tp_tax_percentage,tp_cess from tbl_itembranch_stock tis left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id inner join tbl_tax_profile tp on tp.tp_tax_code=tis.tp_tax_code where itm_name = '" + searchName + "' and branch_id= '" + BranchId + "'";
           
        }
        else if (type == "1")
        {
            itemQry = "SELECT ofr_id,ofr_type,ofr_title,ofr_code,ofr_totalprice,ofr_price,ofr_discount,ofr_focqty,ofr_focnum from tbl_offer_master where ofr_title = '" + searchName + "' and branch_id= '" + BranchId + "'";
        }
        DataTable dt = db.SelectQuery(itemQry);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }
    //edited anjana
    [WebMethod]
    public static string searchCustomer(string customer_id)
    {
        mySqlConnection db = new mySqlConnection();
        string customerQry = "SELECT cust_id,cust_name,cust_type,cust_phone,cust_email,cust_amount,max_creditperiod,max_creditamt from tbl_customer where cust_id='" + customer_id + "' ";
        DataTable dt = db.SelectQuery(customerQry);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }
    //edited anjana
    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteCustData(string variable, int warehouse)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        var resultStatus = "";
        string sqlQuery = "";
        //string sqlQuery = "SELECT cust_name,cust_id from tbl_customer where 1 and branch_id=" + warehouse + " and cust_name like '%" + variable + "%' limit 0,20";
        if (variable == " ")
        {
            sqlQuery = "SELECT cust_name,cust_id from tbl_customer cu JOIN tbl_user_locations"
                + " ul ON cu.location_id=ul.location_id where 1 and ul.user_id='" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "' limit 0,20";
        }
        //string sqlQuery = "SELECT cust_name,cust_id from tbl_customer where 1 and branch_id=" + warehouse + " and cust_name like '%" + variable + "%' limit 0,20";
        else
        {
            sqlQuery = "SELECT cust_name,cust_id from tbl_customer cu JOIN tbl_user_locations ul ON cu.location_id=ul.location_id "
                + " where 1 and ul.user_id='" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "' and cust_name like '%" + variable + "%' limit 0,20";
        }
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


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }
    //edited by anjana
    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteData(string variable, string BranchId, int allowZeroStockOrder)
    {

        List<string> itemNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string queryCondition = "";
          if (allowZeroStockOrder== 0)
            {
                queryCondition = " where itm_name like '%" + variable + "%' and branch_id='" + BranchId + "' and itbs_available = 1 and tis.itm_code not in ('1234567891234') and itbs_stock>0";
            }
            else
            {
                queryCondition = " where itm_name like '%" + variable + "%' and branch_id='" + BranchId + "' and itbs_available = 1 and tis.itm_code not in ('1234567891234')";
            }
        //string queryCondition = "where itm_name like '%" + variable + "%' and branch_id='" + BranchId + "'  ";
        string sqlQuery = "select itm_id,itm_name from tbl_itembranch_stock tis left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id "+queryCondition+" ";
        DataTable dt = db.SelectQuery(sqlQuery);
        if (dt.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["itm_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["itm_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["itm_name"]) + "\"}");

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


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();
    }

    //show offered Items
    [WebMethod]
    public static string searchofferitems(int perpage, int WarehouseId, int page, string TimeZone, string ofritemcode, string ofritemname, string cust_id)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
          
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(TimeZone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy-MM-dd");
            string qry_condition = "where 1 and DATE_FORMAT(ofr_start_date,'%Y-%m-%d') <= '" + currdatetime + "' and DATE_FORMAT(ofr_end_date,'%Y-%m-%d') >= '" + currdatetime + "' and ofr_status=0 ";

            if (WarehouseId != 0)
            {
                qry_condition += " and branch_id='" + WarehouseId + "'";
            }
            if (ofritemcode != "")
            {
                qry_condition += " and ofr_code like '" + ofritemcode + "%'";
            }
            if (ofritemname != "")
            {
                qry_condition += " and ofr_title like '" + ofritemname + "%'";
            }
            qry_condition += " order by ofr_id";

            int per_page = perpage;
            int adjacents = 3;
            int offset = (page - 1) * per_page;


            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_offer_master " + qry_condition;


            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT ofr_id,ofr_type,ofr_title,ofr_code,ofr_totalprice,ofr_price,ofr_discount,ofr_focqty,ofr_focnum from tbl_offer_master ";
            innerqry = innerqry + qry_condition;
            innerqry = innerqry + " LIMIT " + offset.ToString() + " ," + per_page;
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

    [WebMethod(EnableSession = true)]
    public static string GetAutoOfferItem(string variable, string BranchId, string TimeZone)
    {

        List<string> itemNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(TimeZone);
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string currdatetime = TimeNow.ToString("yyyy-MM-dd");
        string sqlQuery = "select ofr_id,ofr_title from tbl_offer_master where ofr_title like '%" + variable + "%' and branch_id='" + BranchId + "' and DATE_FORMAT(ofr_start_date,'%Y-%m-%d') <= '" + currdatetime + "' and DATE_FORMAT(ofr_end_date,'%Y-%m-%d') >= '" + currdatetime + "' and ofr_status=0";
        DataTable dt = db.SelectQuery(sqlQuery);
        if (dt.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in dt.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["ofr_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["ofr_title"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["ofr_title"]) + "\"}");
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
    public static string changecustomerdetails(string customerid, int newclasstype, double newamount, int newperiod, int userid, int userType)
    {
        mySqlConnection db = new mySqlConnection();
        string updatequery = "";
        //if (userType == 1)
        //{
            updatequery = "update tbl_customer set ";
            if (newclasstype != 0)
            {
                updatequery += "cust_type=" + newclasstype + ",new_custtype=0, ";
            }
            else
            {
                updatequery += "new_custtype=0, ";
            }
            if (newamount != 0)
            {
                updatequery += "max_creditamt=" + newamount + ",new_creditamt=0, ";
            }
            else
            {
                updatequery += "new_creditamt=0, ";
            }
            if (newperiod != 0)
            {
                updatequery += "max_creditperiod=" + newperiod + ",new_creditperiod=0, ";
            }
            else
            {
                updatequery += "new_creditperiod=0, ";
            }
            updatequery += " cust_id=" + customerid + " where cust_id='" + customerid + "'";
            bool qrystatus = db.ExecuteQuery(updatequery);
            if (qrystatus)
            {
                HttpContext.Current.Response.StatusCode = 403;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"Customer details successfully updated, you can proceed the order... \"}";
            }
            else
            {
                return "N";
            }

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
    public static string getBranchTaxDetails(int warehouse)
    {
        mySqlConnection db = new mySqlConnection();
        string takeDataQuery = "SELECT branch_tax_method,branch_tax_inclusive from tbl_branch where branch_id='" + warehouse + "' ";
        DataTable dt = db.SelectQuery(takeDataQuery);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;
    }


    //start: Enable/Disable Buttons in  page
    [WebMethod]
    public static string showUserButtons(string userTypeId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtButtons, dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        Int32 disableButtonCount = 0;

        string btnQry = "select ub_id,ub_button_id FROM tbl_user_buttons WHERE page_id='7' ";
        dtButtons = db.SelectQuery(btnQry);
        if (dtButtons != null)
        {
            if (dtButtons.Rows.Count > 0)
            {
                if (dtButtons.Rows[0]["ub_button_id"] is DBNull)
                {
                }
                else
                {
                    for (int i = 0; i < dtButtons.Rows.Count; i++)
                    {
                        string query = "SELECT count(*) FROM tbl_button_permission WHERE user_type='" + userTypeId + "' and ub_id='" + dtButtons.Rows[i]["ub_id"] + "' and page_id='7' ";
                        Int32 qryCount = Convert.ToInt32(db.SelectScalar(query));
                        if (qryCount == 0)
                        {
                            sb.Append(dtButtons.Rows[i]["ub_button_id"] + "@#$");
                            disableButtonCount++;
                        }
                        else
                        {
                        }
                    }
                }
            }
        }

        return disableButtonCount + "@#$" + sb.ToString();
    }
    //stop: Enable/Disable Buttons in  page

}