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

public partial class purchase_purchaseentry : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication purchase = new LoginAuthentication();
        purchase.userAuthentication();
        purchase.checkPageAcess(3);
    }

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteVendorData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT vn_name,vn_id from tbl_vendor where 1 and vn_name like '" + variable + "%' ";
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
            sb.Append("[{\"id\":\"-1\",\"label\":\"No Data Found\",\"value\":\"No Data Found\"}]");
        }


        //var a = "[{\"label\":\"Avacado Supermarket\",\"value\":\"2\"}]";
        return sb.ToString();

    }

    [WebMethod]
    public static string selectVendorData(string vendorId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select vn_name,vn_city,vn_phone1,vn_email from tbl_vendor where vn_id=" + vendorId + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
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
    public static string selectOrderItem(string itemId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select itm_code,itm_name from tbl_itembranch_stock where itbs_id=" + itemId + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
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
                if (filters.ContainsKey("itemBrand"))
                {
                    query_condition += " and tim.itm_brand_id  = " + filters["itemBrand"] + "";
                }
                if (filters.ContainsKey("itemCategory"))
                {
                    query_condition += " and tim.itm_category_id  = " + filters["itemCategory"] + "";
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

            innerqry = "SELECT tim.itm_id,brand_name,cat_name,tim.itm_code,tim.itm_name,IFNULL(itbs_stock,0) as stock,IFNULL(itbs_id,0) as itbsId from tbl_item_master tim left join tbl_itembranch_stock tis on tis.itm_id=tim.itm_id and branch_id=" + filters["warehouse"] + " inner join tbl_item_brand ib on ib.brand_id=tim.itm_brand_id inner join tbl_item_category ic on ic.cat_id=tim.itm_category_id";
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
    public static string savePurchaseEntry(Dictionary<string, string> filters,string tableString)
    {
        string checkstatus = "N";
        mySqlConnection db = new mySqlConnection();
        try
        {
            
            DataTable dt = new DataTable();
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(filters["TimeZone"]);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");          
            //  string jsonData = JsonConvert.SerializeObject(tableString);
            dynamic data = JsonConvert.DeserializeObject(tableString);
            string invoiceCheckQry = "SELECT pm_id FROM tbl_purchase_master WHERE  pm_invoice_no ='" + filters["invoiceno"] + "'";
            string existId = db.SelectScalar(invoiceCheckQry);
            if (!string.IsNullOrWhiteSpace(existId))
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\" already existing old invoice \"}";
            }
            db.BeginTransaction();
            string query = "INSERT INTO tbl_purchase_master (pm_ref_no,pm_invoice_no,vn_id,pm_userid,pm_date,pm_total,pm_discount_rate,pm_discount_amount,pm_netamount,";
            query = query + "pm_note,pm_tax_amount,branch_id,pm_status)";
            query = query + "VALUES (0,'" + filters["invoiceno"] + "','" + filters["vendorId"] + "','" + filters["userid"] + "','" + currdatetime + "','" + filters["TotalAmount"] + "','" + filters["TotalDiscountRate"] + "','" + filters["TotalDiscountAmount"] + "','" + filters["TotalNetAmount"] + "',";
            query = query + "'" + filters["note"] + "','" + filters["totalTaxamt"] + "','" + filters["warehouse"] + "',1);Select last_insert_id()";

            int PurchaseNo = Convert.ToInt32(db.SelectScalarForTransaction(query));

            if (PurchaseNo != 0)
            {
                string updateRefrenceQry = "update tbl_purchase_master set pm_ref_no=" + PurchaseNo + " where pm_id=" + PurchaseNo + "";
                db.ExecuteQueryForTransaction(updateRefrenceQry);
                string qry1 = "INSERT INTO tbl_purchase_items (pm_id,row_no,itbs_id,pi_price,pi_qty,pi_total,pi_discount_rate,pi_discount_amt,pi_netamount,pi_carton_count,pi_item_per_carton,pi_tax_amount)";
                qry1 = qry1 + "VALUES ";
                int row = 0;
                StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");
                foreach (var item in data)
                {
                    string qry_main = qry1 + "('" + PurchaseNo + "'," + row + ",'" + item.itmId + "', '" + item.purchasePrice + "', '" + item.quantity + "',";
                    qry_main = qry_main + "'" + item.amount + "','" + item.dispercent + "','" + item.disamount + "','" + item.netamount + "',0,0,'" + item.taxamt + "')";
                    bool qrystatus = db.ExecuteQueryForTransaction(qry_main);
                    string purchaseMaintainStatus = db.SelectScalarForTransaction("select itbs_purchase_status from tbl_itembranch_stock tis where itbs_id=" + item.itmId);
                    if (purchaseMaintainStatus == "1")
                    {
                        db.ExecuteQueryForTransaction("update tbl_itembranch_stock set itbs_purchase_price=" + item.purchasePrice + " where itbs_id=" + item.itmId);
                    }
                    if (qrystatus)
                    {
                        string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock + " + item.quantity + ") where itbs_id='" + item.itmId + "'";
                        bool upstockresult = db.ExecuteQueryForTransaction(upstockQry);
                        // code to record stock transaction by deepika
                        sb_bulk_stkTrQry.Append("('" + item.itmId + "','" + ((int)Constants.ActionType.PURCHASE) + "','" + PurchaseNo + "','" + filters["userid"] + "'");
                        sb_bulk_stkTrQry.Append(",CONCAT('Purchased " + item.quantity + "' , (select itm_name from tbl_itembranch_stock where itbs_id='" + item.itmId + "'), ' in purchase entry #" + PurchaseNo + "') ,'" + item.quantity + "'");
                        sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + item.itmId + "')");
                        sb_bulk_stkTrQry.Append(",'" + currdatetime + "'),");
                    }
                    else
                    {
                        break;
                    }


                    row = row + 1;
                }

                // bulk insert stock transactions
                sb_bulk_stkTrQry.Length--;
                db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
                //inserts to transaction table
                //inserting order debit entry
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`, `cr`,  `date`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration, @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", PurchaseNo);
                cmdInsCr.Parameters.AddWithValue("@partner_id", filters["vendorId"]);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                cmdInsCr.Parameters.AddWithValue("@user_id", filters["userid"]);
                cmdInsCr.Parameters.AddWithValue("@narration", "Purchase entry #" + filters["invoiceno"] + " is purchased with net amount " + filters["TotalNetAmount"]);
                cmdInsCr.Parameters.AddWithValue("@cr", filters["TotalNetAmount"]);
                cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                db.ExecuteQueryForTransaction(cmdInsCr);

                //check is cash paid
                if (Convert.ToDouble(filters["PaidAmount"]) > 0)
                {
                    //inserting order credit entry
                    MySqlCommand cmdInsDr = new MySqlCommand();
                    cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                        " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`, `user_id`, `narration`,cash_amt " +
                        (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                        ", `dr`, `date`,`closing_balance`)" +
                        " select @action_type, @action_ref_id, @partner_id,@partner_type, @user_id, @narration,@cash_amt " +
                        (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                        ", @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                    cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.PURCHASE);
                    cmdInsDr.Parameters.AddWithValue("@action_ref_id", PurchaseNo);
                    cmdInsDr.Parameters.AddWithValue("@partner_id", filters["vendorId"]);
                    cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.VENDOR);
                    cmdInsDr.Parameters.AddWithValue("@user_id", filters["userid"]);
                    cmdInsDr.Parameters.AddWithValue("@narration", "Paid " + filters["PaidAmount"] + " for Purchase entry #" + filters["invoiceno"]);
                    cmdInsDr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(filters["CashAmount"]));
                    //cmdInsDr.Parameters.AddWithValue("@card_amt", neworder["sessionId"]);
                    //cmdInsDr.Parameters.AddWithValue("@card_no", neworder["sessionId"]);
                    if (Convert.ToDouble(filters["CashAmount"]) != 0)
                    {
                        cmdInsDr.Parameters.AddWithValue("@cheque_amt", filters["ChequeAmount"]);
                        cmdInsDr.Parameters.AddWithValue("@cheque_no", filters["ChequeNo"]);
                        cmdInsDr.Parameters.AddWithValue("@cheque_date", filters["ChequeDate"]);
                        cmdInsDr.Parameters.AddWithValue("@cheque_bank", filters["BankName"]);
                    }

                    cmdInsDr.Parameters.AddWithValue("@dr", filters["PaidAmount"]);
                    cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                    db.ExecuteQueryForTransaction(cmdInsDr);
                }

                string update_vendor_qry = "UPDATE tbl_vendor SET vn_balance=(select (sum(cr)-sum(dr)) from tbl_transactions where partner_id='" + filters["vendorId"] + "' and partner_type=" + (int)Constants.PartnerType.VENDOR + ") WHERE vn_id='" + filters["vendorId"] + "'";
                bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);

                checkstatus = "Y";
                db.CommitTransaction();
            }
            else {
                checkstatus = "N";
            }
         

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
    public static string searchVendors(int page, Dictionary<string, string> filters, int perpage)
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
            string countQry = "SELECT count(*) FROM tbl_vendor" + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT vn_id,vn_name,vn_phone1 from tbl_vendor ";
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

    //show branches
    [WebMethod]
    public static string showBranches()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select tb.branch_id,branch_name,branch_tax_method from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        // string query = "SELECT branch_id,branch_name,branch_tax_method FROM tbl_branch ORDER BY branch_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["branch_id"] is DBNull)
                {
                    // sb.Append("<select id='combobranchtype' class='form-control' onchange=''>");
                    sb.Append("<option value='0' selected='selected' taxType='-1'>--Warehouse--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                    // sb.Append("<select id='combobranchtype' class='form-control'  onchange=''>");
                    sb.Append("<option value='0' selected='selected' taxType='-1'>--Warehouse--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["branch_id"] + "' taxType=" + dt.Rows[i]["branch_tax_method"] + ">" + dt.Rows[i]["branch_name"] + "</option>");

                    }
                    // sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='0' selected='selected' taxType='-1'>--Warehouse--</option>");
                // sb.Append("<select id='combobranchtype'>");
                //sb.Append("</select>");
            }
        }
        return sb.ToString();
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
            string query = "SELECT tp_tax_title,tp_tax_code FROM tbl_tax_profile where tp_tax_type=" + taxType + " ORDER BY tp_tax_code ASC";
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

                            sb.Append("<option value='" + dt.Rows[i]["tp_tax_code"] + "'>" + dt.Rows[i]["tp_tax_title"] + "</option>");

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
    public static string addBranchStockDetails(string branch, string item, string pricegroup_one, string pricegroup_two, string pricegroup_three, string taxcode, string purchasePrice)
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
            query = "INSERT INTO tbl_itembranch_stock (itbs_id,branch_id, itm_id, itbs_stock, itbs_reorder, itbs_available, itm_code, itm_name,itm_brand_id,itm_category_id,itm_subcategory_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_target,tp_tax_code,itbs_purchase_price)";
            query = query + "VALUES ('" + branchstockid + "','" + branch + "','" + item + "','0','0','1','" + dt1.Rows[0]["itm_code"] + "','" + dt1.Rows[0]["itm_name"] + "','" + dt1.Rows[0]["itm_brand_id"] + "','" + dt1.Rows[0]["itm_category_id"] + "','" + dt1.Rows[0]["itm_subcategory_id"] + "','0','" + pricegroup_one + "','" + pricegroup_two + "','" + pricegroup_three + "','0','0','" + taxcode + "','"+purchasePrice+"')";
        
        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");
        return resultStatus;
    }

    [WebMethod]
    public static string getBrands()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select brand_id,brand_name from tbl_item_brand";
        //string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    [WebMethod]
    public static string getCategories()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select cat_id,cat_name from tbl_item_category";
        //string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }
}