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

public partial class income : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication income = new LoginAuthentication();
        income.userAuthentication();
        income.checkPageAcess(52);
        loadWarehouse();
    }

    /// <summary>
    /// method for load warehouse
    /// </summary>
    public void loadWarehouse()
    {
        mySqlConnection db = new mySqlConnection();
        //load suppliers
        DataTable vendorDt = db.SelectQuery("select branch_id,branch_name from tbl_branch");
        selWarehouse.Items.Add(new ListItem("SELECT", "-1"));
        foreach (DataRow vendorRow in vendorDt.Rows)
        {
            selWarehouse.Items.Add(new ListItem(vendorRow["branch_name"].ToString(), vendorRow["branch_id"].ToString()));
        }
        
    }


    [WebMethod(EnableSession = true)]
    public static string GetAutoUserData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "";
        if (variable == " ")
        {
            sqlQuery = "SELECT first_name as user_name,user_id as user_id from tbl_user_details";
        }
        else
        {
            sqlQuery = "SELECT first_name as user_name,user_id as user_id from tbl_user_details where 1 and first_name like '%" + variable + "%' ";
        }
        DataTable QryTable = db.SelectQuery(sqlQuery);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["user_id"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["user_name"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["user_name"]) + "\"}");

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
    public static string saveIncomeEntry(Dictionary<string, string> filters, string tableString)
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
            //string invoiceCheckQry = "SELECT pm_id FROM tbl_purchase_master WHERE  pm_invoice_no ='" + filters["invoiceno"] + "'";
       
            db.BeginTransaction();



            MySqlCommand cmdInsAddQry = new MySqlCommand();

            cmdInsAddQry.CommandText = "INSERT INTO `tbl_incm_exps` " +
                          " ( `branch_id`, `ie_type`,`ie_category`,`ie_invoice_num`,`ie_total`,`ie_discount_rate`,`ie_discount_amt`,`ie_netamount`,`ie_date`,`user_id`,`ext_user_id`,`ext_user_name`,`ie_currenttotal`,`ie_tax`)" +
                        "values(@branch_id,@ie_type,@ie_category,@ie_invoice_num,@ie_total,@ie_discount_rate,@ie_discount_amt,@ie_netamount,@ie_date,@user_id,@ext_user_id,@ext_user_name,@ie_currenttotal,@ie_tax); SELECT last_insert_id();";

            cmdInsAddQry.Parameters.AddWithValue("@branch_id", filters["warehouse"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_type", '1');
            cmdInsAddQry.Parameters.AddWithValue("@ie_category", filters["selectedCategory"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_invoice_num", filters["invoiceno"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_total", filters["TotalAmount"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_discount_rate", filters["TotalDiscountRate"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_discount_amt", filters["TotalDiscountAmount"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_netamount", filters["TotalNetAmount"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_date", currdatetime);
            cmdInsAddQry.Parameters.AddWithValue("@user_id", filters["userid"]);
            cmdInsAddQry.Parameters.AddWithValue("@ext_user_id", filters["externalUserId"]);
            cmdInsAddQry.Parameters.AddWithValue("@ext_user_name", filters["externalUserName"]);
            cmdInsAddQry.Parameters.AddWithValue("@user_type", filters["userType"]);
            // cmdInsAddQry.Parameters.AddWithValue("@ie_currenttotal", filters["TotalAmount"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_currenttotal", filters["TotalNetAmount"]);
            cmdInsAddQry.Parameters.AddWithValue("@ie_tax", filters["totalTaxamt"]);
            //db.ExecuteQueryForTransaction(cmdInsAddQry);
            //int PurchaseNo = Convert.ToInt32(db.ExecuteQueryForTransaction(cmdInsAddQry));
            int IncomeNo = Convert.ToInt32(db.SelectScalarForTransaction(cmdInsAddQry));



            //int PurchaseNo = Convert.ToInt32(db.SelectScalarForTransaction(query));

            if (IncomeNo != 0)
            {

                MySqlCommand cmdInsDr = new MySqlCommand();

                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";

                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.INCOME);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", IncomeNo);
                cmdInsDr.Parameters.AddWithValue("@partner_id", filters["externalUserId"]);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", filters["warehouse"]);
                cmdInsDr.Parameters.AddWithValue("@user_id", filters["userid"]);
                cmdInsDr.Parameters.AddWithValue("@narration", "Income entry #" + filters["invoiceno"] + " is placed with an amount of " + filters["TotalNetAmount"]);
                cmdInsDr.Parameters.AddWithValue("@dr", filters["TotalNetAmount"]);
                cmdInsDr.Parameters.AddWithValue("@date", currdatetime);
                db.ExecuteQueryForTransaction(cmdInsDr);





                //check is cash paid
                if (Convert.ToDouble(filters["PaidAmount"]) > 0)
                {
                    //inserting order credit entry
                    MySqlCommand cmdInsCr = new MySqlCommand();
                    cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                        " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`,cash_amt " +
                        (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                        ", `cr`, `date`,`closing_balance`)" +
                        " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt " +
                        (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                        ", @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type ";
                    cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.INCOME);
                    cmdInsCr.Parameters.AddWithValue("@action_ref_id", IncomeNo);
                    cmdInsCr.Parameters.AddWithValue("@partner_id", filters["externalUserId"]);
                    cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.COMMONUSER);
                    cmdInsCr.Parameters.AddWithValue("@branch_id", filters["warehouse"]);
                    cmdInsCr.Parameters.AddWithValue("@user_id", filters["userid"]);
                    cmdInsCr.Parameters.AddWithValue("@narration", "Credited " + filters["PaidAmount"] + " of Income entry #" + filters["invoiceno"]);
                    cmdInsCr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(filters["CashAmount"]));
                    
                    if (Convert.ToDouble(filters["CashAmount"]) != 0)
                    {
                        cmdInsCr.Parameters.AddWithValue("@cheque_amt", filters["ChequeAmount"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_no", filters["ChequeNo"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_date", filters["ChequeDate"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_bank", filters["BankName"]);
                    }

                    cmdInsCr.Parameters.AddWithValue("@cr", filters["PaidAmount"]);
                    cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                    db.ExecuteQueryForTransaction(cmdInsCr);
                }

                string update_vendor_qry = "UPDATE tbl_user_details SET user_balance=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + filters["externalUserId"] + "' and partner_type=" + (int)Constants.PartnerType.COMMONUSER + ") WHERE user_id='" + filters["externalUserId"] + "'";
                bool upvndr_result = db.ExecuteQueryForTransaction(update_vendor_qry);

                checkstatus = "Y";
                db.CommitTransaction();
            }
            else
            {
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

    /// <summary>
    /// webmethod for load categories
    /// </summary>
    /// <returns>return categories json object</returns>
    [WebMethod]
    public static string loadCategories()
    {
        string querycondition = " where ie_type=1";
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select ie_cat_id,ie_cat_name,ie_type from tbl_incm_exps_category" + querycondition;
        //string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }


    [WebMethod]
    public static string searchVendors(int page, Dictionary<string, string> filters, int perpage, int ext_user)
    {
               
        try
        {
            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {
                if (filters.ContainsKey("externalUserName"))
                {
                   
                    query_condition += " and user_name  LIKE '%" + filters["externalUserName"] + "%'";
                }
                if (filters.ContainsKey("externalUserId"))
                {
                    query_condition += " and user_id  LIKE '%" + filters["externalUserId"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            //string countQry = "SELECT count(*) FROM tbl_ext_user_details" + query_condition;
            string countQry = "SELECT count(*) FROM tbl_user_details " + query_condition;
            string employeeCountQry = "SELECT count(*) FROM tbl_user_details" + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            double EmployeeNumrows = Convert.ToInt32(db.SelectScalar(employeeCountQry));
            if (numrows == 0 && EmployeeNumrows == 0)
            {
                return "N";
            }

            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT user_id as ext_user_id,first_name as ext_user_name,phone as ext_user_phone from tbl_user_details ";
            innerqry = innerqry + query_condition + " order by user_id LIMIT " + offset.ToString() + " ," + per_page;
           
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

    [WebMethod]
    public static string selectVendorData(Int32 vendorId)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string query = "select first_name as ext_user_name,phone as ext_user_phone,country as ext_user_city from tbl_user_details where user_id=" + vendorId + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    [WebMethod]// UserType show
    public static string getUserTypes()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select usertype_id,usertype_name from tbl_user_type";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    // Adding users
    [WebMethod]
    public static string addUserDetails(string Firstname, string Lastname, string Username, string Password, string Usertype, string Usertypename, string Phone, string Emailid, string Country, string Location, string Address, string UserImage, string branch_id)
    {


        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        String resultStatus;
        resultStatus = "N";
        string checkuserqry = "SELECT COUNT(*) FROM tbl_user_details WHERE user_name='" + Username + "' and password='" + Password + "' ";
        Int32 qryCount = Convert.ToInt32(db.SelectScalar(checkuserqry));
        if (qryCount == 1)
        {
            resultStatus = "E";
        }
        else
        {
            string quermaxnote = "select MAX(id) as id from tbl_user_details";
            dt = db.SelectQuery(quermaxnote);
            Int32 Id = 0;
            Int32 user_id = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["id"] is DBNull)
                    {
                        Id = 1;
                    }
                    else
                    {
                        Id = Convert.ToInt32(dt.Rows[0]["id"]);
                        Id = ++Id;
                    }

                }

            }
            else
            {
            }


            bool query;
            string brquery = "";
            var year1 = DateTime.Now.ToString("yy");
            var month1 = DateTime.Now.ToString("MM");
            var day1 = DateTime.Now.ToString("dd");
            // user_id = "Y" + year1 + "M" + month1 + "D" + day1 + "U" + Id;
            user_id = Id;

            brquery = "INSERT INTO tbl_user_details(id, user_id, first_name, last_name, user_name, password, user_type, user_type_name, phone, emailid, country, location, address, user_image) ";
            brquery = brquery + "VALUES('" + Id + "','" + user_id + "','" + Firstname + "','" + Lastname + "','" + Username + "','" + Password + "','" + Usertype + "','" + Usertypename + "','" + Phone + "','" + Emailid + "','" + Country + "','" + Location + "','" + Address + "','" + UserImage + "')";


            query = db.ExecuteQuery(brquery);
            if (query)
            {
                resultStatus = "Y";
            }

        }
        return resultStatus;
    }

    #region load users
    [WebMethod]
    public static string getExtUsers(int ext_user)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string ext_users = "select ext_user_id,ext_user_name from tbl_ext_user_details where user_type='" + ext_user + "'";
        dt = db.SelectQuery(ext_users);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }
    #endregion




}