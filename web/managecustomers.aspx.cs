using System;
using System.Collections.Generic;
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

public partial class managecustomers : System.Web.UI.Page
{
    mySqlConnection db=new mySqlConnection();
    public string settings;
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication customers = new LoginAuthentication();
        customers.userAuthentication();
        customers.checkPageAcess(1); 
        getSystemSettingsData();
    }
    /// <summary>
    /// method to get system settings and set it in javascript object
    /// </summary>
    public void getSystemSettingsData()
    {
        string qry = "select ss_default_max_credit,ss_default_max_period,ss_trn_gst_required,ss_reg_id_required," +
            "ss_phone,ss_validation_email from tbl_system_settings";
        DataTable dtSetings = db.SelectQuery(qry);
        settings = JsonConvert.SerializeObject(dtSetings, Formatting.Indented);
    }
    [WebMethod]
    public static string loadwarehouse()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string jsonResponse = "";
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select tb.branch_id as id,branch_name as name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
     //   string query = "select branch_id as id,branch_name as name from tbl_branch";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);

        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + "}";
        }
        return jsonResponse;
    }

    //Save the customer details 24-03-2017
  
    [WebMethod]
    public static string AddCustomer(string actionType, string CustomerId, string CustomerName, string CustomerType, string Address, string City, string State, string Phone, string PhoneOne, string Email, string country, string note, int creditamount, int creditperiod, int userid, int status, int userType, string trnNo, string regId, string place,string category,string sessionId)
    {
        String resultStatus;
        resultStatus = "N";
        mySqlConnection db = new mySqlConnection();
        int custId = 0;
        bool queryStatus;
        string query = "";
        try
        {
            string JoinDate = DateTime.Now.ToString("yyyy-MM-dd H:mm:ss");
            //   var cookie = HttpContext.Current.Response.Cookies["invntrystaffId"];

            db.BeginTransaction();
            // CKECKING SESSION
            string getsessionexist = "select cust_sessionid from tbl_customer where cust_sessionid='" + sessionId + "'";
            DataTable dtsession = db.SelectQueryForTransaction(getsessionexist);
            int sess_rows = dtsession.Rows.Count;

            if (sess_rows != 0)  // ALREADY SAVED CASE
            {
                db.RollBackTransaction();
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"Customer saved already\"}";
            }
            if (actionType == "insert")
            {

                ////check is unique?
                if (regId != "")
                {
                    String chk_qry = "SELECT count(*) FROM  tbl_customer WHERE (cust_reg_id = '" + regId + "')";
                    double numrows = Convert.ToInt32(db.SelectScalarForTransaction(chk_qry));
                    if (numrows > 0)
                    {
                        return "E";
                    }
                }
                //////


                query = "INSERT INTO tbl_customer (cust_id, cust_name, cust_address, cust_city, cust_state, cust_country, cust_phone,cust_phone1, cust_email, cust_amount, cust_joined_date,cust_note,user_id,cust_type,max_creditamt,max_creditperiod,new_custtype,new_creditamt,new_creditperiod,cust_approvedby,cust_requestedby,cust_status,cust_reg_id,cust_tax_reg_id,location_id,cust_cat_id,cust_last_updated_date,cust_sessionid)";
                 query = query + "VALUES (null,'" + CustomerName + "','" + Address + "','" + place + "','" + State + "','" + country + "','" + Phone + "','" + PhoneOne + "','" + Email + "','0','" + JoinDate + "','" + note + "'," + userid + "," + CustomerType + "," + creditamount + ",'" + creditperiod + "',0,0,0," + userid + "," + userid + "," + status + ",'" + regId + "','" + trnNo + "','" + City + "','" + category + "','" + JoinDate + "','" + sessionId + "');Select last_insert_id();";
                custId = Convert.ToInt32(db.SelectScalarForTransaction(query));

            }


            if (actionType == "update")
            {
                ////check is unique?
                if (regId != "")
                {
                    String chk_qry = "SELECT count(*) FROM  tbl_customer WHERE (cust_reg_id = '" + regId + "') and cust_id!='" + CustomerId + "'";
                    double numrows = Convert.ToInt32(db.SelectScalarForTransaction(chk_qry));
                    if (numrows > 0)
                    {
                        return "E";
                    }
                }
                //////

                query = "UPDATE tbl_customer SET ";
                query = query + "cust_name='" + CustomerName + "',cust_address='" + Address + "',cust_city='" + place + "',cust_state='" + State + "',cust_phone='" + Phone + "',cust_phone1='" + PhoneOne + "',cust_email='" + Email + "',cust_country='" + country + "',cust_joined_date='" + JoinDate + "',cust_note='" + note + "',cust_reg_id='" + regId + "',cust_tax_reg_id='" + trnNo + "',location_id='" + City + "',cust_cat_id='" + category + "',cust_last_updated_date='" + JoinDate + "',";
                if (userType == 1)
                {
                    query = query + "cust_type=" + CustomerType + ",max_creditamt=" + creditamount + ",max_creditperiod=" + creditperiod + ",new_custtype=0,new_creditamt=0,new_creditperiod=0,cust_approvedby=" + userid + " ";
                }
                else
                {
                    DataTable dt3 = new DataTable();
                    dt3 = db.SelectQueryForTransaction("select cust_type,IFNULL(max_creditamt,0) as credit_amt,max_creditamt,max_creditperiod from tbl_customer where cust_id=" + CustomerId + "");
                    int num = Convert.ToInt32(dt3.Rows[0]["max_creditamt"]);
                    if (dt3.Rows[0]["cust_type"].ToString() == CustomerType && Convert.ToInt32(dt3.Rows[0]["max_creditamt"]) == creditamount && Convert.ToInt32(dt3.Rows[0]["max_creditperiod"]) == creditperiod)
                    {
                        query = query + "new_custtype=0,new_creditamt=0,new_creditperiod=0,cust_requestedby=" + userid + " ";
                    }
                    else
                    {
                        query = query + "new_custtype=" + CustomerType + ",new_creditamt=" + creditamount + ",new_creditperiod=" + creditperiod + ",cust_requestedby=" + userid + " ";
                    }
                }
                query = query + "where cust_id=" + CustomerId + "";
                queryStatus = db.ExecuteQueryForTransaction(query);
                if (queryStatus)
                {

                    //String order_chk_qry = "SELECT count(*) FROM  tbl_sales_master WHERE cust_id='" + CustomerId + "'";
                    //double orderrows = Convert.ToInt32(db.SelectScalarForTransaction(order_chk_qry));
                    //if (orderrows > 0)
                    //{
                    //    db.ExecuteQueryForTransaction("update tbl_sales_master set cust_name='" + CustomerName + "' where cust_id='" + CustomerId + "'");
                    //}
                    custId = Convert.ToInt32(CustomerId);
                   
                }
            }
            if (regId == "")
            {
                regId = custId.ToString();
            }
            if(db.ExecuteQueryForTransaction("update tbl_customer set cust_reg_id='" + regId+"' where cust_id=" + custId + ""))
            {
                resultStatus = "Y";
            }

            
            
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try
            {
                resultStatus = "N";
                db.RollBackTransaction();
                LogClass log = new LogClass("managecustomer");
                log.write(ex);
                return resultStatus;
            }
            catch
            {
            }
        }
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");
        return resultStatus;
    }//end



    //edit customer data
    [WebMethod]
    public static string editcustomerdetail(string cust_id)
    {

        mySqlConnection db = new mySqlConnection();
       // string qry = "SELECT cust_id,cust_name,cust_type,cust_address,cust_city,cust_state,cust_phone,cust_phone1,cust_email,cust_amount,cust_country,cust_note,tc.branch_id,max_creditamt,max_creditperiod,cust_wallet_amt,cust_image,new_custtype,new_creditamt,new_creditperiod,concat(first_name,\" \",last_name) as name FROM tbl_customer tc inner join tbl_user_details tu on tu.user_id =tc.user_id where cust_id='" + cust_id + "' ";


        string qry = "SELECT cust_reg_id,cust_id,cust_name,cust_type,cust_address,cust_city,cust_state,cust_phone,cust_phone1,cust_email,cust_amount,cust_country,cust_note,max_creditamt,max_creditperiod,cust_image,new_custtype,new_creditamt,new_creditperiod,concat(first_name,\" \",last_name) as assignedname,cust_reg_id,cust_tax_reg_id,location_id,cust_cat_id FROM tbl_customer tc left outer join tbl_user_details tu on tu.user_id =tc.user_id where cust_id='" + cust_id + "' ";
        DataTable dt = db.SelectQuery(qry);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
       
    }

    [WebMethod]// country list show
    public static string getCountryNames()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select country_id, country_name from tbl_country";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// state list show
    public static string getstates(int country)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select state_id, state_name from tbl_state where country_id=" + country + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// state list show
    public static string getLocations(int state)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select location_id, location_name from tbl_location tl inner join tbl_district td on td.dis_id=tl.dist_id inner join tbl_state ts on ts.state_id=td.state_id where ts.state_id=" + state + "";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// country list show
    public static string getCategories()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select cust_cat_id, cust_cat_name from tbl_customer_category";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end
}