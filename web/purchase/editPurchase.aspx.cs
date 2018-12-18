using commonfunction;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using System.Collections;
public partial class purchase_editPurchase : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication purchase = new LoginAuthentication();
        purchase.userAuthentication();
        purchase.checkPageAcess(6);
    }

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteItemData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT itm_name,itm_id from tbl_item_master where 1 and itm_name like '%" + variable + "%' ";
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
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
            sb.Append("N");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }

    [WebMethod]
    public static string retrieveData(string purchaseId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dtItems = new DataTable();
        DataTable dtOrder = new DataTable();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string selectvar2 = "";
        string qry = "";
        selectvar2 = selectvar2 + " row_no, ibs.itm_code,";
        selectvar2 = selectvar2 + " ibs.itm_name ,pi.itbs_id as itm_id, pi_qty, pi_price,pi_total, pi_discount_rate, pi_discount_amt, pi_netamount,pi_tax_amount,pi_id ";
        qry = "select " + selectvar2 + " from tbl_purchase_items pi inner join tbl_itembranch_stock ibs on ibs.itbs_id=pi.itbs_id  where pm_id='" + purchaseId + "' order by row_no";
        dtItems = db.SelectQuery(qry);
        sb.Append("\"items\":");
        sb.Append(JsonConvert.SerializeObject(dtItems, Formatting.Indented));
        sb.Append(",");
        string previouspaidqry = "select tv.vn_name,pm.vn_id,vn_balance,branch_name,pm_invoice_no,concat(tu.first_name,' ',tu.last_name) as user,"
        +" pm_netamount as net_amount,sum(cr)-sum(dr) as pm_balance,pm_netamount-(sum(cr)-sum(dr)) as pm_paidamount,"
        +" pm_tax_amount as tax_amount,pm_ref_no,DATE_FORMAT(pm_date,'%d-%b-%Y') AS date,pm_note,"
        +" pm_total,pm_discount_rate,pm_discount_amount,pm.branch_id,branch_tax_method"
        +" from tbl_purchase_master pm inner join tbl_vendor tv on tv.vn_id=pm.vn_id"
        + " inner join tbl_user_details tu on tu.user_id=pm.pm_userid"
        +" inner join tbl_branch tb on tb.branch_id=pm.branch_id inner join tbl_transactions tr"
        +" on (tr.action_ref_id=pm.pm_id and tr.action_type=" + (int)Constants.ActionType.PURCHASE + ")"
        +" where pm_id='" + purchaseId + "' ";
        dtOrder = db.SelectQuery(previouspaidqry);
        sb.Append("\"entry\":");
        sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
        String paymentQry = "select tr.id,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as date,narration,concat(tu.first_name,' ',tu.last_name) as user_name,cash_amt,card_amt,card_no,cheque_amt,cheque_no,"
        + " cheque_bank,DATE_FORMAT(`cheque_date`, '%d-%b-%Y %h:%i %p') as cheque_date,wallet_amt,dr,cr,is_reconciliation from tbl_transactions tr "
        + " inner join tbl_user_details tu on tu.user_id=tr.user_id "
        + " where action_ref_id='" + purchaseId + "' and action_type=" + (int)Constants.ActionType.PURCHASE;

        DataTable dtPay = db.SelectQuery(paymentQry);
        sb.Append(",");
        sb.Append("\"transaction_details\":");
        sb.Append(JsonConvert.SerializeObject(dtPay, Formatting.Indented));
        sb.Append("}");

        return sb.ToString();
    }


    [WebMethod]
    public static string searchOrderitems(int page, Dictionary<string, string> filters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";


        try
        {

            string query_condition = " where 1=1 and tim.itm_code not in ('1234567891234') ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("itemname"))
                {
                    query_condition += " and tim.itm_name  LIKE '%" + filters["itemname"] + "%'";
                }
                if (filters.ContainsKey("itemcode"))
                {
                    query_condition += " and tim.itm_code  LIKE '%" + filters["itemcode"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "SELECT count(*) FROM tbl_item_master tim " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT tim.itm_id,tim.itm_code,tim.itm_name,IFNULL(itbs_stock,0) as stock,IFNULL(itbs_id,0) as itbsId from tbl_item_master tim left join tbl_itembranch_stock tis on tis.itm_id=tim.itm_id and branch_id=" + filters["warehouse"] + " ";
            innerqry = innerqry + query_condition + "   order by itm_id LIMIT " + offset.ToString() + " ," + per_page;
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
    public static string updatePurchaseEntry(Dictionary<string, string> filters, string tableString)
    {
        string checkstatus = "N";
        mySqlConnection db = new mySqlConnection();
        try
        {

            DataTable itemsBefrEditDt, dt1 = new DataTable();
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(filters["TimeZone"]);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            //  string jsonData = JsonConvert.SerializeObject(tableString);
            dynamic Itemsdata = JsonConvert.DeserializeObject(tableString);

            //store old purchased items data to itemsbefrEditDt
            string selectPurchaseItemQuery = "select pi.itbs_id,pi_qty,itm_name,pm_netamount as old_netamount,pi_id as purchaseItemId from tbl_purchase_items pi inner join tbl_purchase_master pm on pm.pm_id=pi.pm_id inner join tbl_itembranch_stock ibs on ibs.itbs_id=pi.itbs_id where pi.pm_id=" + filters["purchaseId"];
            itemsBefrEditDt = db.SelectQuery(selectPurchaseItemQuery);
            double old_netamount = Convert.ToDouble(itemsBefrEditDt.Rows[0]["old_netamount"]);
            

            db.BeginTransaction();
            Int32 oldqty = 0;
            Int32 oldtotoalqty = 0;
            string olditbs = "";
            string oldUniqueItemId = "";
            string itbsidString = "";
           

            foreach (DataRow row in itemsBefrEditDt.Rows)
            {
                oldqty = Convert.ToInt32(row["pi_qty"]);
                olditbs = Convert.ToString(row["itbs_id"]);
                itbsidString = itbsidString + "," + olditbs;
                oldUniqueItemId = Convert.ToString(row["purchaseItemId"]);
                db.ExecuteQueryForTransaction("UPDATE tbl_itembranch_stock SET itbs_stock=itbs_stock - " + oldqty + " where itbs_id=" + olditbs);
               
            }
 

            string deleteItemsQry = "delete from tbl_purchase_items where pm_id=" + filters["purchaseId"];
            if (db.ExecuteQueryForTransaction(deleteItemsQry))
            {
                string updatePurchaseMasterQry = "UPDATE tbl_purchase_master set ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "pm_userid = '" + filters["userid"] + "',pm_date = '" + currdatetime + "',pm_total = '" + filters["TotalAmount"] + "',pm_invoice_no = '" + filters["invoicenum"] + "', ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "pm_discount_rate  ='" + filters["TotalDiscountRate"] + "',pm_discount_amount  ='" + filters["TotalDiscountAmount"] + "', ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + "pm_netamount  ='" + filters["TotalNetAmount"] + "',pm_tax_amount  ='" + filters["totalTaxamt"] + "' ";
                updatePurchaseMasterQry = updatePurchaseMasterQry + " WHERE pm_id= '" + filters["purchaseId"] + "' ";
                if (db.ExecuteQueryForTransaction(updatePurchaseMasterQry))
                {
                    string qry1 = "INSERT INTO tbl_purchase_items (pm_id,row_no,itbs_id,pi_price,pi_qty,pi_total,pi_discount_rate,pi_discount_amt,pi_netamount,pi_carton_count,pi_item_per_carton,pi_tax_amount)";
                    qry1 = qry1 + "VALUES ";
                    int row = 0;
                    foreach (var item in Itemsdata)
                    {
                        string qry_main = qry1 + "('" + filters["purchaseId"] + "'," + row + ",'" + item.itbs_id + "', '" + item.purchasePrice + "', '" + item.quantity + "',";
                        qry_main = qry_main + "'" + item.amount + "','" + item.dispercent + "','" + item.disamount + "','" + item.netamount + "',0,0,'" + item.taxamt + "')";
                       if( db.ExecuteQueryForTransaction(qry_main)){
                           string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock + " + item.quantity + ") where itbs_id='" + item.itbs_id + "'";
                    bool upstockresult = db.ExecuteQueryForTransaction(upstockQry);
                       }

                        row = row + 1;
                    }

                    //start stock transaction update
                    StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                    bool isStockChanged = false;
                    sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`cr_qty`,`closing_stock`,`date`,`is_reconciliation`) VALUES ");
                    foreach (DataRow itemrow in itemsBefrEditDt.Rows)
                    {
                        oldqty = Convert.ToInt32(itemrow["pi_qty"]);
                        olditbs = Convert.ToString(itemrow["itbs_id"]);
                        oldUniqueItemId = Convert.ToString(itemrow["purchaseItemId"]);

                        dynamic itemAftrEdit = ((IEnumerable)Itemsdata).Cast<dynamic>().Where(a => a.purchaseItemId == oldUniqueItemId).FirstOrDefault();
                        //checking if item deleted

                        if (itemAftrEdit == null)
                        {
                            //crediting if deleted
                            sb_bulk_stkTrQry.Append("('" + olditbs + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + filters["purchaseId"] + "','" + filters["userid"] + "'");
                            sb_bulk_stkTrQry.Append(",'Debiting " + itemrow["itm_name"] + " of quantity " + oldqty + " back on delete from purchase entry #" + filters["purchaseId"] + "','" + oldqty + "','0'");
                            sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                            sb_bulk_stkTrQry.Append(",'" + currdatetime + "','1'),");
                            isStockChanged = true;
                        }
                        else
                        {
                            //recording change in quantity
                            int newTotalQty = Convert.ToInt32(itemAftrEdit.quantity);
                           
                            if (oldqty > newTotalQty)
                            {
                                sb_bulk_stkTrQry.Append("('" + olditbs + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + filters["purchaseId"] + "','" + filters["userid"] + "'");
                                sb_bulk_stkTrQry.Append(",'Debiting " + itemrow["itm_name"] + " of quantity " + (oldqty - newTotalQty) + " back on edit of entry #" + filters["purchaseId"] + "','" + (oldqty - newTotalQty) + "','0'");
                                sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                                sb_bulk_stkTrQry.Append(",'" + currdatetime + "','1'),");
                                isStockChanged = true;
                            }
                            else if (oldqty < newTotalQty)
                            {
                                sb_bulk_stkTrQry.Append("('" + olditbs + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + filters["purchaseId"] + "','" + filters["userid"] + "'");
                                sb_bulk_stkTrQry.Append(",'Crediting " + itemrow["itm_name"] + " of quantity " + (newTotalQty - oldqty) + " on edit of order #" + filters["purchaseId"] + "','0','" + (newTotalQty - oldqty) + "'");
                                sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                                sb_bulk_stkTrQry.Append(",'" + currdatetime + "','1'),");
                                isStockChanged = true;
                            }

                        }


                    }
                    // crediting new items
                    dynamic newItemsList = ((IEnumerable)Itemsdata).Cast<dynamic>()
                        .Where(a =>
                        !itemsBefrEditDt.AsEnumerable().Any(b =>
                            b.Field<int>("itbs_id") == Convert.ToInt32(a.itbs_id))
                        ).ToList();
                    foreach (var item in newItemsList)
                    {
                        int newTotalQty = Convert.ToInt32(item.quantity);
                        sb_bulk_stkTrQry.Append("('" + item.itbs_id + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + filters["purchaseId"] + "','" + filters["userid"] + "'");
                        sb_bulk_stkTrQry.Append(",CONCAT('Purchased " + newTotalQty + "', (select itm_name from tbl_itembranch_stock where itbs_id='" + item.itbs_id + "'),' in entry #" + filters["purchaseId"] + "'),'0','" + newTotalQty + "'");
                        sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + item.itbs_id + "')");
                        sb_bulk_stkTrQry.Append(",'" + currdatetime + "','0'),");
                        isStockChanged = true; 
                    }
                    //end stock transaction update


                    // bulk insert stock transactions
                    if (isStockChanged)
                    {
                        sb_bulk_stkTrQry.Length--;
                        db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());

                    }



                    //start updation in transactions
                    if (Convert.ToDouble(filters["TotalNetAmount"]) > old_netamount)
                    {
                        //inserting order debit entry
                        MySqlCommand cmdInsCr = new MySqlCommand();
                        cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                            " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration, @cr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";

                        cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                        cmdInsCr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                        cmdInsCr.Parameters.AddWithValue("@partner_id", filters["vendorId"]);
                        cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                        cmdInsCr.Parameters.AddWithValue("@user_id", filters["userid"]);
                        cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of Purchase entry #" + filters["invoicenum"] + " after an edit by crediting the amount " + (Convert.ToDouble(filters["TotalNetAmount"]) - old_netamount));
                        cmdInsCr.Parameters.AddWithValue("@cr", (Convert.ToDouble(filters["TotalNetAmount"]) - old_netamount));
                        cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                        cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                        db.ExecuteQueryForTransaction(cmdInsCr);

                    }
                    else if (Convert.ToDouble(filters["TotalNetAmount"]) < old_netamount)
                    {
                        //inserting order credit entry
                        MySqlCommand cmdInsDr = new MySqlCommand();
                        cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`, `dr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                            " SELECT @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration, @dr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";

                        cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                        cmdInsDr.Parameters.AddWithValue("@action_ref_id", filters["purchaseId"]);
                        cmdInsDr.Parameters.AddWithValue("@partner_id", filters["vendorId"]);
                        cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                        cmdInsDr.Parameters.AddWithValue("@user_id", filters["userid"]);
                        cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of Purchase entry #" + filters["invoicenum"] + " after an edit by debiting the amount " + (old_netamount - Convert.ToDouble(filters["TotalNetAmount"])));
                        cmdInsDr.Parameters.AddWithValue("@dr", (old_netamount - Convert.ToDouble(filters["TotalNetAmount"])));
                        cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                        cmdInsDr.Parameters.AddWithValue("@is_reconciliation", "1");
                        db.ExecuteQueryForTransaction(cmdInsDr);
                    }
                    //end updation in transactions
                    string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + filters["vendorId"] + "' and partner_type="+ (int)Constants.PartnerType.VENDOR + ") WHERE vn_id='" + filters["vendorId"] + "'";
                    bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);
                    if (upvndr_result)
                    {
                        checkstatus = "Y";
                    }
                }
                else
                {
                    checkstatus = "N";
                }
            }
            else
            {
                checkstatus = "N";
            }


           
            db.CommitTransaction();

        }
        catch (Exception ex)
        {
            try
            {
                checkstatus = "N";
                db.RollBackTransaction();
                LogClass log = new LogClass("purchaseEntry");
                log.write(ex);
            }
            catch
            {
            }
        }
        return checkstatus;


        //change code
    }

    [WebMethod]
    public static void savePaymentEdit(int trans_id, double cash_amt, double cheque_amt)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {
            db.BeginTransaction();
            //getting date
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntryTimeZone"].Value));
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string edited_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            //get previous transaction details
            DataTable dt = db.SelectQueryForTransaction("select action_ref_id,partner_id,cash_amt,wallet_amt,cheque_amt,dr from tbl_transactions where id='" + trans_id + "'");
            if (dt.Rows.Count <= 0)
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.Write("Transaction not found");
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                db.RollBackTransaction();
                return;
            }
            double prev_total = Convert.ToDouble(dt.Rows[0]["dr"]);
            double prev_cash_amt = Convert.ToDouble(dt.Rows[0]["cash_amt"]);
            double prev_wallet_amt = Convert.ToDouble(dt.Rows[0]["wallet_amt"]);
            double prev_cheque_amt = Convert.ToDouble(dt.Rows[0]["cheque_amt"]);

            //calculating new total
            double new_total = cash_amt + prev_wallet_amt + cheque_amt;

            //checking if new total is greater than old
            if (new_total > prev_total)
            {
                //crediting amount if edited payment is greater than previous
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `dr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " SELECT @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @dr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type "; 
                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                cmdInsDr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of purchase entry #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by debiting the amount " + (new_total - prev_total));
                cmdInsDr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsDr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsDr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsDr.Parameters.AddWithValue("@dr", (new_total - prev_total));
                cmdInsDr.Parameters.AddWithValue("@date", edited_date);
                cmdInsDr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsDr);
            }
            else
            {
                //debiting if edited payment is less than previous
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt,wallet_amt " +
                    ",cheque_amt, `cr`, `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt,@wallet_amt" +
                    ",@cheque_amt, @cr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", dt.Rows[0]["action_ref_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_id", dt.Rows[0]["partner_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                cmdInsCr.Parameters.AddWithValue("@user_id", HttpContext.Current.Request.Cookies["invntrystaffId"].Value);
                cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of payment #" + trans_id + " of purchase entry #" + dt.Rows[0]["action_ref_id"].ToString() + " after edit by crediting the amount " + (prev_total - new_total));
                cmdInsCr.Parameters.AddWithValue("@cash_amt", (cash_amt - prev_cash_amt));
                cmdInsCr.Parameters.AddWithValue("@wallet_amt", 0);
                cmdInsCr.Parameters.AddWithValue("@cheque_amt", (cheque_amt - prev_cheque_amt));
                cmdInsCr.Parameters.AddWithValue("@cr", (prev_total - new_total));
                cmdInsCr.Parameters.AddWithValue("@date", edited_date);
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", 1);
                db.ExecuteQueryForTransaction(cmdInsCr);
            }

            // UPDATING CUSTOMER DETAILS
            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + dt.Rows[0]["partner_id"].ToString() + "' and partner_type="+ (int)Constants.PartnerType.VENDOR + ") WHERE vn_id='" + dt.Rows[0]["partner_id"].ToString() + "'";
            bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);

            db.CommitTransaction();
        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.Write(e.ToString());
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            db.RollBackTransaction();
        }
    }

    [WebMethod]
    public static string loadTaxes(int taxType)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        if (taxType == -1)
        {
            sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
        }
        else
        {
            string query = "SELECT tp_tax_code FROM tbl_tax_profile where tp_tax_type=" + taxType + " ORDER BY tp_id ASC";
            dt = db.SelectQuery(query);
            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["tp_tax_code"] is DBNull)
                    {
                        // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                        sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
                        // sb.Append("</select>");
                    }
                    else
                    {
                        // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                        sb.Append("<option value='-1' selected='selected'>--Tax code--</option>");
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {

                            sb.Append("<option value='" + dt.Rows[i]["tp_tax_code"] + "'>" + dt.Rows[i]["tp_tax_code"] + "</option>");

                        }
                        // sb.Append("</select>");
                    }
                }
                else
                {
                    sb.Append("<option value='-1' selected='selected'>--Tax Code--</option>");
                    //sb.Append("<select id='combobranddiv'>");
                    //sb.Append("</select>");
                }
            }
        }
        return sb.ToString();
    }

    [WebMethod]
    public static string addBranchStockDetails(string branch, string item, string pricegroup_one, string pricegroup_two, string pricegroup_three, string taxcode)
    {

        String resultStatus;
        resultStatus = "N";
        mySqlConnection db = new mySqlConnection();

        bool queryStatus;
        string query = "";


        //check is unique?
        String chk_qry = "SELECT count(*) FROM  tbl_itembranch_stock WHERE (branch_id = '" + branch + "' and itm_id  = '" + item + "')";
        double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
        if (numrows > 0)
        {
            return "E";
        }
        ////

        string qry = "select MAX(itbs_id) as id from tbl_itembranch_stock";
        DataTable dt = new DataTable();
        dt = db.SelectQuery(qry);
        Int32 branchstockid = 0;
        if (dt != null)
        {

            if (dt.Rows[0][0] is DBNull)
            {
                branchstockid = ++branchstockid;
            }
            else
            {
                branchstockid = Convert.ToInt32(dt.Rows[0][0]);
                branchstockid = ++branchstockid;
            }


        }
        else
        {
            branchstockid = ++branchstockid;
        }
        DataTable dt1 = new DataTable();
        dt1 = db.SelectQuery("select itm_code,itm_name,itm_brand_id,itm_category_id,itm_subcategory_id from tbl_item_master where itm_id='" + item + "'");
        query = "INSERT INTO tbl_itembranch_stock (itbs_id,branch_id, itm_id, itbs_stock, itbs_reorder, itbs_available, itm_code, itm_name,itm_brand_id,itm_category_id,itm_subcategory_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_target,tp_tax_code)";
        query = query + "VALUES ('" + branchstockid + "','" + branch + "','" + item + "','0','0','1','" + dt1.Rows[0]["itm_code"] + "','" + dt1.Rows[0]["itm_name"] + "','" + dt1.Rows[0]["itm_brand_id"] + "','" + dt1.Rows[0]["itm_category_id"] + "','" + dt1.Rows[0]["itm_subcategory_id"] + "','0','" + pricegroup_one + "','" + pricegroup_two + "','" + pricegroup_three + "','0','0','" + taxcode + "')";

        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");
        return resultStatus;
    }

    [WebMethod]
    public static void cancelFunctn(int userId,int purchaseId)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {
            var branch_timezone = "";
            db.BeginTransaction();
            string purchaseDetailQry = "SELECT vn_id,pm_netamount as currentAmt,branch_id from tbl_purchase_master where pm_id='" + purchaseId + "'";
            DataTable dtPurchaseData = db.SelectQueryForTransaction(purchaseDetailQry);
            string getTimeZone = "SELECT branch_timezone from tbl_branch where branch_id='" + dtPurchaseData.Rows[0]["branch_id"] + "'";
            DataTable cTimeZone = db.SelectQueryForTransaction(getTimeZone);
            if (cTimeZone != null)
            {
                branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
            
            }
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currentdate = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            db.ExecuteQueryForTransaction("UPDATE tbl_purchase_master SET pm_status='" + ((int)Constants.PurchaseStatus.Cancel) + "',pm_userid='" + userId + "',pm_cancelled_date='" + currentdate + "' where pm_id='" + purchaseId + "'");

            string qry = "select pi.itbs_id,pi_qty,itm_name from tbl_purchase_items pi left join tbl_itembranch_stock tis on tis.itbs_id=pi.itbs_id where pm_id='" + purchaseId + "'";
            DataTable dt = db.SelectQueryForTransaction(qry);
            int numrows = dt.Rows.Count;

            Int32 oldqty = 0;
            Int32 oldtotoalqty = 0;
            string olditbs = "";
            StringBuilder sb_bulk_stkTrQry = new StringBuilder();
            sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES ");

            foreach (DataRow row in dt.Rows)
            {
                oldqty = Convert.ToInt32(row["pi_qty"]);
                oldtotoalqty = oldqty;
                olditbs = Convert.ToString(row["itbs_id"]);
                db.ExecuteQueryForTransaction("UPDATE tbl_itembranch_stock SET itbs_stock=itbs_stock - " + oldqty + " where itbs_id=" + olditbs);
                // code to record stock transaction by deepika
                sb_bulk_stkTrQry.Append("('" + olditbs + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + purchaseId + "','" + userId + "'");
                sb_bulk_stkTrQry.Append(",'Debited " + oldtotoalqty + " " + row["itm_name"] + " in canceled purchase #" + purchaseId + "','" + oldtotoalqty + "'");
                sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + olditbs + "')");
                sb_bulk_stkTrQry.Append(",'" + currentdate + "'),");

                // code to record stock transaction end
            }

            // bulk insert stock transactions
            sb_bulk_stkTrQry.Length--;
            db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());

            MySqlCommand cmdInsCr = new MySqlCommand();
            cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`, `dr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration, @dr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
            cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
            cmdInsCr.Parameters.AddWithValue("@action_ref_id", purchaseId);
            cmdInsCr.Parameters.AddWithValue("@partner_id", dtPurchaseData.Rows[0]["vn_id"]);
            cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
            cmdInsCr.Parameters.AddWithValue("@user_id",userId);
            cmdInsCr.Parameters.AddWithValue("@narration", "Cancellation of Order #" + purchaseId + " with net amount " + dtPurchaseData.Rows[0]["currentAmt"]);
            cmdInsCr.Parameters.AddWithValue("@dr", dtPurchaseData.Rows[0]["currentAmt"]);
            cmdInsCr.Parameters.AddWithValue("@date", currentdate);
            cmdInsCr.Parameters.AddWithValue("@is_reconciliation", 1);
            db.ExecuteQueryForTransaction(cmdInsCr);
            // UPDATING CUSTOMER DETAILS

            string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + dtPurchaseData.Rows[0]["vn_id"] + "' and partner_type=" + (int)Constants.PartnerType.VENDOR + ") WHERE vn_id='" + dtPurchaseData.Rows[0]["vn_id"] + "'";
            bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try
            {
                db.RollBackTransaction();
                LogClass log = new LogClass("editpurchase");
                log.write(ex);
            }
            catch
            {
            }
        }
    }
}