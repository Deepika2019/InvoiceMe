using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using commonfunction;
using Newtonsoft.Json;
using System.Net;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;
using System.Net.Mail;
using MySql.Data.MySqlClient;

public partial class app_Warehouse : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    public static string authenticate_user(string user_id, string password, string device_id)
    {
        string status = "";
        string is_multi_device_blocking_allowed = "";
        is_multi_device_blocking_allowed = new mySqlConnection().SelectScalar("SELECT ss.ss_multidevice_block FROM tbl_system_settings ss");
        var check_authentication = "";
        if (is_multi_device_blocking_allowed == "0") //no device blocking exisits
        {
            check_authentication = "SELECT * FROM tbl_user_details ud WHERE ud.password='" + password + "' AND ud.user_id='" + user_id + "'";
        }
        else //multi device blocking activated
        {
            check_authentication = "SELECT * FROM tbl_user_details ud WHERE ud.password='" + password + "' AND ud.user_device_id='" + device_id + "' AND ud.user_id='" + user_id + "'";
        }

        var dt_result = new mySqlConnection().SelectQuery(check_authentication);
        if (dt_result.Rows.Count > 0) { status = "1"; } else { status = "0"; }

        return status;
    }

    public static bool ValidateServerCertificate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
    {

        return true;

    }

    public static void Send_Push_Notification(string type, string action_ref_id,string w_id)
    {
        try
        {
            #region EDIT

            if (type == "EDIT")
            {
                var sm_id = action_ref_id;
                var invoice_id = "";
                var sm_userid = "";
                // getting - customer location and order branch_id from salesmaster

                var order_deatil_qry = "SELECT sm.sm_userid,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no FROM tbl_sales_master sm WHERE sm.sm_id='" + sm_id + "'";
                DataTable dt_order = new mySqlConnection().SelectQuery(order_deatil_qry);
                if (dt_order.Rows.Count > 0)
                {
                    sm_userid = dt_order.Rows[0]["sm_userid"].ToString();
                    invoice_id = dt_order.Rows[0]["sm_invoice_no"].ToString();

                    var person_name = new mySqlConnection().SelectScalar("SELECT CONCAT(first_name,' ',last_name) as name FROM tbl_user_details WHERE user_id='" + w_id + "'");
                    var message = "Your order with invoice number " + invoice_id + " (" + sm_id + ") has been edited by " + person_name + ".";

                    // getting user_list to be sent the notification - salesman
                    var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud WHERE ud.user_id='" + sm_userid + "'";
                    DataTable dt_user_list = new mySqlConnection().SelectQuery(user_list);

                    foreach (DataRow row in dt_user_list.Rows)
                    {
                        Send_Push_Message_to_user(row["user_androidid"].ToString(), message);
                    }


                }
                else
                {
                    // if no rows found
                }

            }
            #endregion

            else
            {
            }
        }
        catch (Exception ex)
        {

            var log = new LogClass("push_notify_error");
            log.write(ex);
        }

    }

    public static string Send_Push_Message_to_user(string android_id, string message)
    {
        var ret = "0";

        try
        {

            // your RegistrationID paste here which is received from GCM server.
            //regId ="eLXXrZwPUgQ:APA91bHoIMW7ohapVRjhWSsGEnc6MUXJVpyL6vKQUZs_v4vJ4AX1i8fP-rtpzxlNKnULsqexrTYwQA-Cwb5DI5sFHS_lM4rE8jEn5xsXbD2jeAwEIA9bOc94uVffxY8i3o1l_N4sNdyv";
            // applicationID means google Api key

            var applicationID = "AAAA54Cc5T8:APA91bHxlzz-otsbxFeoPOU_TqTf9IxLYETHmI2inJ1noJxevGNgoj8w61Dikf7U-xDeW1mUvN1tyTf30GLrvKMK1Zoz2CYfivkQbPF-SLjPmEXOUn3dOHqLt8rRPlIGdf5hXkQQcOQ1qAw3LOND7-biyDyIVr8dGQ";
            // SENDER_ID is nothing but your ProjectID (from API Console-google code)//
            var SENDER_ID = "994295211327";

            WebRequest tRequest;

            tRequest = WebRequest.Create("https://android.googleapis.com/gcm/send");
            tRequest.Method = "post";
            tRequest.UseDefaultCredentials = true;
            tRequest.PreAuthenticate = true;
            tRequest.ContentType = "application/x-www-form-urlencoded;charset=UTF-8";
            tRequest.Headers.Add(string.Format("Authorization: key={0}", applicationID));
            tRequest.Headers.Add(string.Format("Sender: id={0}", SENDER_ID));

            //Data post to server
            string postData = "collapse_key=score_update&time_to_live=108&delay_while_idle=1&data.message=" + message + "&data.time=" + System.DateTime.Now.ToString() + "&registration_id=" + android_id + "";

            Byte[] byteArray = Encoding.UTF8.GetBytes(postData);
            tRequest.ContentLength = byteArray.Length;
            Stream dataStream = tRequest.GetRequestStream();
            dataStream.Write(byteArray, 0, byteArray.Length);
            dataStream.Close();
            WebResponse tResponse = tRequest.GetResponse();
            dataStream = tResponse.GetResponseStream();
            StreamReader tReader = new StreamReader(dataStream);
            String sResponseFromServer = tReader.ReadToEnd();

            //Getresponse from GCM server.
            //Label1.Text = sResponseFromServer;      
            //Assigning GCMresponse to Label text

            tReader.Close();
            dataStream.Close();
            tResponse.Close();
        }
        catch (Exception ex)
        {

            var log = new LogClass("Send_Push_Message_to_user_error");
            log.write(ex);

        }
        return ret;

    }
    
    public static void MailSending(string email, string count)
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
            msg.Subject = " " + count + " Error occured on sales Edit";
            msg.Body = " PLS CHECK ";

            SmtpClient client = new SmtpClient();
            client.Host = "relay-hosting.secureserver.net";
            client.Port = 25;


            //Setup credentials to login to our sender email address ("UserName", "Password")
            NetworkCredential credentials = new NetworkCredential("mail@billcrm.com", "b2426794");
            client.UseDefaultCredentials = true;
            client.Credentials = credentials;


            //Send the msg
            client.Send(msg);
            //return "Y";
            //Display some feedback to the user to let them know it was sent
            // Response.Write("mail send");

        }
        catch (Exception ex)
        {
            LogClass log = new LogClass("mailerror");
            log.write(ex);
        }
    }

    public static string Get_Current_Date_Time(string TimeZoneName)
    {
        var CURR_TIME_ZONE = TimeZoneInfo.FindSystemTimeZoneById(TimeZoneName);
        var TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CURR_TIME_ZONE);
        var date_time_now = TimeNow.ToString("yyyy-MM-dd HH:mm:ss");
        return date_time_now;
    }

    public static string Get_Current_Date(string TimeZoneName)
    {
        var CURR_TIME_ZONE = TimeZoneInfo.FindSystemTimeZoneById(TimeZoneName);
        var TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CURR_TIME_ZONE);
        var date_time_now = TimeNow.ToString("yyyy-MM-dd");
        return date_time_now;
    }

    [WebMethod]
    public static string Get_Customers(string user_id)
    {

        var result = "";
        try
        {
            result = "{\"data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery("SELECT cu.cust_id,cu.cust_name,cu.cust_latitude as lat,cu.cust_longitude as lng FROM tbl_customer cu WHERE cu.cust_latitude!=0 and cu.location_id in (SELECT tul.location_id FROM tbl_user_locations tul WHERE tul.user_id='" + user_id + "' )"), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("customer_read_error");
            log.write(ex);
            result = "ERROR";
            return result;

        }

    }

    [WebMethod]
    public static string Login_user(Dictionary<string, string> logindata)
    {
        var result = "";
        
        try
        {

            var dt_login_ckeck = new mySqlConnection().SelectQuery(@"select user_id,CONCAT(first_name,' ',last_name) as name,user_device_id,password,new_device_id from tbl_user_details where user_name='" + logindata["user_name"] + "' and password='" + logindata["user_password"] + "' and user_type='4'");
            if (dt_login_ckeck.Rows.Count > 0)
            {
                // checking for device change - 

                string is_multi_device_blocking_allowed = "";
                is_multi_device_blocking_allowed = new mySqlConnection().SelectScalar("SELECT ss.ss_multidevice_block FROM tbl_system_settings ss");
                var check_authentication = "";
                if (is_multi_device_blocking_allowed == "1") //no device blocking exisits
                {
                    check_authentication = "SELECT ud.user_device_id FROM tbl_user_details ud WHERE (ud.user_device_id='" + logindata["device_id"] + "' OR ud.user_device_id='0') AND ud.user_id='" + dt_login_ckeck.Rows[0]["user_id"].ToString() + "'";


                    var dt_result = new mySqlConnection().SelectQuery(check_authentication);
                    if (dt_result.Rows.Count <= 0)
                    {
                        result = "BLOCKED";
                        // updates new device id 
                        var update_device_details = "UPDATE tbl_user_details SET new_device_id='" + logindata["device_id"] + "' WHERE user_id='" + dt_login_ckeck.Rows[0]["user_id"] + "'";
                        new mySqlConnection().ExecuteQuery(update_device_details);
                        return result;
                    }
                    else
                    {
                        var update_user_details = "UPDATE tbl_user_details SET user_device_id='" + logindata["device_id"] + "',user_androidid='" + logindata["android_id"] + "' WHERE user_id='" + dt_login_ckeck.Rows[0]["user_id"] + "'";
                        new mySqlConnection().ExecuteQuery(update_user_details);
                    }
                }
                else
                {
                    
                    // UPDATE table with device id & android id - dt_login_ckeck.Rows[0]["user_id"]
                    var update_user_details = "UPDATE tbl_user_details SET user_device_id='" + logindata["device_id"] + "',user_androidid='" + logindata["android_id"] + "' WHERE user_id='" + dt_login_ckeck.Rows[0]["user_id"] + "'";
                    new mySqlConnection().ExecuteQuery(update_user_details);
                }
                result = "{\"login_data\":" + JsonConvert.SerializeObject(dt_login_ckeck, Formatting.Indented) + ",\"settings_data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery("SELECT ss_price_change,ss_discount_change,ss_foc_change,ss_class_change,ss_max_period_credit,ss_new_registration,ss_sales_return,ss_due_amount,ss_payment_type,ss_new_item,ss_location_on_order,ss_validation_email,ss_phone,ss_direct_delivery,ss_currency,ss_decimal_accuracy,ss_multidevice_block,ss_van_based_invoice_number,ss_default_time_zone,ss_default_max_period,ss_default_max_credit,ss_reg_id_required,ss_trn_gst_required,DATE_FORMAT(ss_last_updated_date, '%Y-%m-%d %H:%i:%s') as ss_last_updated_date FROM tbl_system_settings "), Formatting.Indented) + "}";
            }
            else { result = "NOTEXIST"; }
        }
        catch (Exception ex)
        {
            var log = new LogClass("login_error");
            log.write(ex);
            return result;
        }
        finally
        {

        }

        return result;
    }

    [WebMethod]
    public static string Get_Salesman_with_order_counts(string user_id, string branch_id , string password , string device_id) {

        string result = "";

        var auth_result = authenticate_user(user_id, password, device_id);
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        mySqlConnection db =new mySqlConnection();        
        string branch_qry = "";
        if (branch_id != "0")
        {
            branch_qry = " and sm.branch_id='" + branch_id + "'";
        }
        else
        {
            branch_qry = " and sm.branch_id IN( SELECT ub.branch_id FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + user_id + "') ";
        }

        DataTable dt_sl, dt_br;
        string process_qry = @"select user_id,concat (first_name,' ',last_name)as name,
(select COUNT(sm_id) from tbl_sales_master sm1 where sm1.sm_delivery_status=0 and sm1.sm_packed=0 and sm1.sm_userid=ud.user_id )as new_orders,
(select COUNT(sm_id) from tbl_sales_master sm1 where sm1.sm_delivery_status=0 and sm1.sm_packed=1 and sm1.sm_userid=ud.user_id )as packed_orders,
(select COUNT(sm_id) from tbl_sales_master sm1 where sm1.sm_delivery_status=1 and sm1.sm_userid=ud.user_id )as processed_orders,
(select COUNT(sm_id) from tbl_sales_master sm1 where sm1.sm_delivery_status=6 and sm1.sm_userid=ud.user_id )as pending_orders
from tbl_user_details ud JOIN tbl_sales_master sm ON sm.sm_userid=ud.user_id where ud.user_type in(1,2,3,4)" + branch_qry + " GROUP BY ud.user_id";

        dt_sl = db.SelectQuery(process_qry);

        string branch_select_qry = "SELECT ub.branch_id,tb.branch_name FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='"+ user_id +"'";
        dt_br = db.SelectQuery(branch_select_qry);

        result = "{\"data\":" + JsonConvert.SerializeObject(dt_sl, Formatting.Indented) + ",\"branch_data\":" + JsonConvert.SerializeObject(dt_br, Formatting.Indented) + "}";
        
        return result;
    }

    [WebMethod]
    public static string First_Sync(string user_id, string timezone)
    {

        var result = "";
        var sync_time = Get_Current_Date_Time(timezone);
        try
        {
            mySqlConnection db_select = new mySqlConnection();


            var item_fetch_query = @"select itm.itm_type,brd.brand_name,cat.cat_name,itb.branch_id,tax.tp_tax_percentage,tax.tp_cess,itb.itbs_id,itb.itm_id,itb.itm_brand_id,itb.itm_category_id,itb.itm_name,itb.itbs_stock,itb.itm_code,itb.itm_mrp,itb.itm_class_one,itb.itm_class_two,itb.itm_class_three,itb.itm_commision,itb.itm_rating 
                                     from tbl_itembranch_stock itb 
                                     join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code 
                                     join tbl_user_branches tub on tub.branch_id=itb.branch_id 
                                     join tbl_item_master itm on itm.itm_id=itb.itm_id 
                                     join tbl_item_brand brd on brd.brand_id=itm.itm_brand_id 
                                     join tbl_item_category cat on cat.cat_id=itm.itm_category_id 
                                     and tub.user_id='" + user_id + "' order by itb.branch_id asc";
            DataTable dt_item_branchstock = db_select.SelectQuery(item_fetch_query);

            // 4. fetching branches and tax details

            var branch_query = "select br.branch_id,br.branch_name,br.branch_timezone,br.branch_tax_method,br.branch_tax_inclusive from tbl_branch br join tbl_user_branches tub on tub.branch_id=br.branch_id and tub.user_id='" + user_id + "' order by br.branch_name asc";
            DataTable dt_branch = db_select.SelectQuery(branch_query);

            // 5. fetching customer states , district , locations
            var cust_location_query = @"select loc.location_id,loc.location_name,tst.state_id,tst.state_name,tst.country_id from tbl_location loc join tbl_district dist on loc.dist_id=dist.dis_id 
                                       join tbl_state tst on dist.state_id=tst.state_id join tbl_user_locations tul on tul.location_id=loc.location_id and tul.user_id='" + user_id + "' group by loc.location_id";
            DataTable dt_locations = db_select.SelectQuery(cust_location_query);

            // 6. fetching customers

            var customer_query = @"select cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,cu.cust_state,cu.cust_country,cu.cust_phone, 
                                  cu.cust_phone1,cu.cust_email,cu.cust_amount,DATE_FORMAT(cu.cust_joined_date, '%Y-%m-%d %h:%i %p') as cust_joined_date,cu.cust_latitude,cu.cust_longitude,cu.cust_type,cu.cust_note,cu.max_creditamt,cu.max_creditperiod,cu.new_custtype,cu.new_creditamt,cu.new_creditperiod,cu.cust_image,cu.cust_status,DATE_FORMAT(cu.cust_followup_date, '%Y-%m-%d') as cust_followup_date,cu.cust_reg_id,cu.location_id,cu.cust_cat_id,cu.cust_tax_reg_id from tbl_customer cu 
                                  join tbl_user_locations tul on tul.location_id=cu.location_id and tul.user_id='" + user_id + "' WHERE cu.cust_status!=2 group by cu.cust_id";
            DataTable dt_customers = db_select.SelectQuery(customer_query);

            //7. getting customer types

            var customer_category = "select cat.cust_cat_id,cat.cust_cat_name from tbl_customer_category cat";
            DataTable dt_customer_category = db_select.SelectQuery(customer_category);

            var dt_item_branchstockData = JsonConvert.SerializeObject(dt_item_branchstock, Formatting.Indented); //
            var dt_branchData = JsonConvert.SerializeObject(dt_branch, Formatting.Indented); //
            var dt_locationsData = JsonConvert.SerializeObject(dt_locations, Formatting.Indented); //
            var dt_customersData = JsonConvert.SerializeObject(dt_customers, Formatting.Indented);
            var dt_customer_catData = JsonConvert.SerializeObject(dt_customer_category, Formatting.Indented);

            result = "{\"dt_item_branchstockData\":" + dt_item_branchstockData + ",\"dt_branchData\":" + dt_branchData + ",\"dt_locationsData\":" + dt_locationsData + ",\"dt_customersData\":" + dt_customersData + ",\"dt_customer_catData\":" + dt_customer_catData + ",\"sync_time\":" + JsonConvert.SerializeObject(sync_time, Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("customer_read_error");
            log.write(ex);
            result = "ERROR";
            return result;

        }

    }

    [WebMethod]
    public static string Get_Items(string user_id, string last_update_datetime)
    {
        var result = "";
        try
        {
            last_update_datetime = "2018-03-28 14:54:05";
            result = "{\"item_data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT itb.itbs_id,itb.branch_id,itb.itm_code,itb.itm_name,itb.itm_brand_id,brd.brand_name,itb.itm_category_id,tic.cat_name FROM tbl_itembranch_stock itb JOIN tbl_item_brand brd ON itb.itm_brand_id=brd.brand_id JOIN tbl_item_category tic ON tic.cat_id=itb.itm_category_id AND itb.itbs_available=1 AND itb.branch_id IN (SELECT branch_id FROM tbl_user_branches WHERE user_id='" + user_id + "') AND itb.itm_last_update_date>'" + last_update_datetime + "'"), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("customer_read_error");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }
   
    [WebMethod]
    public static string Get_Orders_with_date_range(Dictionary<string, string> filters)
    {
        string result = "";

        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        try
        {

            var perPage = 10;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;

            var cust_condition = "";
            if (filters["customer_id"] != "0")
            {
                cust_condition += " AND sm.cust_id='" + filters["customer_id"] + "' ";
            }

            var qry_Condition = "";
            if (filters["order_status"] != "x")
            {
                qry_Condition += " AND sm.sm_delivery_status='" + filters["order_status"] + "' ";
            }
            else
            {
                qry_Condition += " AND sm.sm_delivery_status not in (3,5) ";
            }

            if (filters["orders_from"] != "" && filters["orders_to"] != "")
            {
                qry_Condition += " AND date(sm.sm_date)>='" + filters["orders_from"] + "' AND date(sm.sm_date)<='" + filters["orders_to"] + "' ";
            }

            var having_cond = "";
            if (filters["payment_status"] != "x")
            {
                if (filters["payment_status"] == "1")
                {

                    having_cond += " having sum(dr)-sum(cr) > 0 ";
                }
                if (filters["payment_status"] == "2")
                {
                    having_cond += " having (sum(dr)-sum(cr) = 0 or sum(dr)-sum(cr) < 0) ";
                }

            }

            if (filters["branch_id"] != "0")
            {
                qry_Condition += " AND sm.branch_id='" + filters["branch_id"] + "' ";
            }
            else {

                qry_Condition += " AND sm.branch_id IN( SELECT ub.branch_id FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + filters["user_id"] + "') ";
            }

            string branch_select_qry = "SELECT ub.branch_id,tb.branch_name FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + filters["user_id"] + "'";
            DataTable dt_br = new mySqlConnection().SelectQuery(branch_select_qry);

            var count_qry = "SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,sm.sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id " + having_cond + " ORDER BY sm.sm_id DESC";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;
            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id " + having_cond + " ORDER BY sm.sm_id DESC LIMIT " + perPage + " OFFSET " + lowerBound + ""), Formatting.Indented) + ",\"branch_data\":" + JsonConvert.SerializeObject(dt_br, Formatting.Indented) + "}";

            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("customer_read_error");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string fetch_full_order_details(string order_id)
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            mySqlConnection db = new mySqlConnection();
            sb.Append("{");
            string qry_order = @"
	        
	 SELECT  app.first_name AS app_first_name, app.last_name AS app_last_name, 
				del.first_name AS del_first_name, del.last_name AS del_last_name,
				canc.first_name AS canc_first_name, 
            canc.last_name AS canc_last_name, 
				sel.first_name AS sel_first_name, 
				sel.last_name AS sel_last_name, 
				pro.first_name AS pro_first_name, 
            pro.last_name AS pro_last_name, 
            pak.first_name AS pak_first_name, 
            pak.last_name AS pak_last_name, 
            veh.first_name AS veh_first_name, 
            veh.last_name AS veh_last_name,
            cust.cust_id,
				cust.cust_name,
				cust.cust_city,
				cust.cust_address,
				cust.max_creditamt, 
				cust.max_creditperiod,
            cust.new_creditamt, 
				cust.new_creditperiod, 
            cust.cust_type, 
				cust.new_custtype,
            cust.cust_amount,  
            cust.cust_status,           
				IFNULL(tbl_sales_master.sm_invoice_no,'NIL') AS sm_invoice_no,
				tbl_sales_master.sm_order_type,
				tbl_sales_master.sm_id,
				tbl_sales_master.sm_netamount,
				tbl_sales_master.sm_tax_amount,
				tbl_sales_master.sm_tax_excluded_amt,
				SUM(tr.dr)-SUM(tr.cr) AS total_balance,
				tbl_sales_master.sm_netamount-(sum(dr)-sum(cr)) as total_paid,
				tbl_sales_master.sm_delivery_status,
				tbl_sales_master.sm_packed,
				tbl_sales_master.sm_order_type,
				tbl_sales_master.sm_payment_type,
				tbl_sales_master.sm_specialnote,
				tbl_sales_master.sm_vehicle_no,
                tbl_sales_master.sm_delivery_vehicle_id,
                tbl_sales_master.sm_delivered_id,
				tbl_sales_master.sm_payment_type,
				tbl_sales_master.branch_tax_method,
				tbl_sales_master.branch_tax_inclusive,
				tbl_sales_master.branch_id,
                tbl_sales_master.sm_price_class,
                tbl_sales_master.sm_type,
		      DATE_FORMAT(tbl_sales_master.sm_date, '%d %M %Y %h:%i %p') AS sm_date, 
            DATE_FORMAT(tbl_sales_master.sm_packed_date, '%d %M %Y %h:%i %p') AS sm_packed_date,
            DATE_FORMAT(tbl_sales_master.sm_processed_date, '%d %M %Y %h:%i %p') AS sm_processed_date,
            DATE_FORMAT(tbl_sales_master.sm_delivered_date, '%d %M %Y %h:%i %p') AS sm_delivered_date, 
            DATE_FORMAT(tbl_sales_master.sm_cancelled_date, '%d %M %Y %h:%i %p') AS sm_cancelled_date,
            DATE_FORMAT(tbl_sales_master.sm_approved_date, '%d %M %Y %h:%i %p')   sm_approved_date
		      FROM  tbl_sales_master 
		      LEFT OUTER JOIN tbl_transactions tr ON (tr.action_ref_id=tbl_sales_master.sm_id AND tr.action_type=1) 
				LEFT OUTER JOIN tbl_user_details app ON tbl_sales_master.sm_approved_id = app.user_id 
				LEFT OUTER JOIN tbl_user_details AS del ON tbl_sales_master.sm_delivered_id = del.user_id 
				LEFT OUTER JOIN tbl_user_details AS canc ON tbl_sales_master.sm_cancelled_id = canc.user_id 
				LEFT OUTER JOIN tbl_user_details AS pak ON tbl_sales_master.sm_packed_id = pak.user_id 
				LEFT OUTER JOIN tbl_user_details AS pro ON tbl_sales_master.sm_processed_id = pro.user_id 
            LEFT OUTER JOIN tbl_user_details AS veh ON tbl_sales_master.sm_delivery_vehicle_id = veh.user_id 
				LEFT OUTER JOIN tbl_user_details AS sel ON tbl_sales_master.sm_userid = sel.user_id 
				LEFT OUTER JOIN tbl_customer AS cust ON tbl_sales_master.cust_id = cust.cust_id 
            WHERE tbl_sales_master.sm_id='" + order_id + "'";

            DataTable dt_order = new DataTable();
            dt_order = db.SelectQuery(qry_order);
            sb.Append("\"order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));
            sb.Append(",");
            string qry_items = "select itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type from tbl_sales_items where sm_id='" + order_id + "'";
            DataTable dt_items = db.SelectQuery(qry_items);
            sb.Append("\"items\":" + JsonConvert.SerializeObject(dt_items, Formatting.Indented));
            sb.Append(",");
            string delivery_qry = "select ud.user_id,concat (ud.first_name,' ',ud.last_name)as name,ud.user_type from tbl_user_details ud JOIN tbl_user_branches ub ON ub.user_id=ud.user_id  where ud.user_type in(2,3,6) and ub.branch_id=(SELECT branch_id FROM tbl_sales_master WHERE sm_id='" + order_id + "') GROUP BY ud.user_id";
            DataTable dt_person = db.SelectQuery(delivery_qry);
            sb.Append("\"del_data\":" + JsonConvert.SerializeObject(dt_person, Formatting.Indented));

            sb.Append("}");
            string a = sb.ToString();
            return sb.ToString();
        }
        catch (Exception ex)
        { return "N"; }
    }
  
    [WebMethod]
    public static string get_order_transactions(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();

        var perPage = 15;
        var totalRows = 0;
        var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
        var upperBound = perPage + lowerBound - 1;
        var count_qry = @"SELECT tr.id,tr.cr,tr.dr,CONCAT(ud.first_name,' ',ud.last_name) as name,tr.action_type,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date 
                       FROM tbl_transactions tr 
                       JOIN tbl_user_details ud ON ud.user_id=tr.user_id 
                       WHERE tr.action_ref_id=" + filters["sm_id"] + " AND tr.action_type=1  ORDER BY tr.date DESC";

        var dt_count = new mySqlConnection().SelectQuery(count_qry);
        totalRows = dt_count.Rows.Count;

        string qry = @"SELECT tr.id,tr.cr,tr.dr,CONCAT(ud.first_name,' ',ud.last_name) as name,tr.action_type,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date 
                       FROM tbl_transactions tr 
                       JOIN tbl_user_details ud ON ud.user_id=tr.user_id 
                       WHERE tr.action_ref_id=" + filters["sm_id"] + " AND tr.action_type=1 ORDER BY tr.date DESC LIMIT " + perPage + " OFFSET " + lowerBound + "";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"data\":" + jsonData + "}";
        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;

    }
   
    [WebMethod]
    public static string cancel_order(string sm_id, string user_id, string time_zone)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            // checking the current status        
            string check_status_qry = "SELECT sm_delivery_status,cust_id,sm_netamount FROM tbl_sales_master WHERE sm_id='" + sm_id + "'";
            DataTable dt_sm = db.SelectQuery(check_status_qry);
            if (dt_sm.Rows[0]["sm_delivery_status"].ToString() == "4") { result = "ALREADY"; }
            else if (dt_sm.Rows[0]["sm_delivery_status"].ToString() == "5") { result = "REJECTED"; }
            else
            {
                db.BeginTransaction();
                string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_type from tbl_sales_items where sm_id='" + sm_id + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
                DataTable dt = db.SelectQueryForTransaction(qry);
                int numrows = dt.Rows.Count;

                Int32 oldqty = 0;
                Int32 oldfoc = 0;
                Int32 oldtotoalqty = 0;
                string olditbs = "";

                string itbsidString = "";
                string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                foreach (DataRow row in dt.Rows)
                {
                    oldqty = Convert.ToInt32(row["si_qty"]);
                    oldfoc = Convert.ToInt32(row["si_foc"]);
                    oldtotoalqty = oldfoc + oldqty;
                    olditbs = Convert.ToString(row["itbs_id"]);
                    itbsidString = itbsidString + "," + olditbs;
                    oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";
                }

                itbsidString = itbsidString.Trim().TrimStart(',');
                string cancelled_date = Get_Current_Date_Time(time_zone);

                oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + cancelled_date + "' WHERE itbs_id IN (" + itbsidString + ")";
                bool oldupstockresult = db.ExecuteQueryForTransaction(oldupstockQry);

                
                string update_sales_return = "UPDATE tbl_sales_master SET sm_delivery_status='4',sm_cancelled_id='" + user_id + "',sm_cancelled_date='" + cancelled_date + "' where sm_id='" + sm_id + "'";
                bool sm_result = db.ExecuteQueryForTransaction(update_sales_return);

                //inserts to transaction table

                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`, `is_reconciliation` ,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date, @is_reconciliation ,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", sm_id);
                cmdInsCr.Parameters.AddWithValue("@partner_id", dt_sm.Rows[0]["cust_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", dt_sm.Rows[0]["branch_id"].ToString());
                cmdInsCr.Parameters.AddWithValue("@user_id", user_id);
                cmdInsCr.Parameters.AddWithValue("@narration", "Cancellation of order: Ref.Id #" + sm_id + " worth " + dt_sm.Rows[0]["sm_netamount"].ToString());
                cmdInsCr.Parameters.AddWithValue("@cr", dt_sm.Rows[0]["sm_netamount"].ToString());
                cmdInsCr.Parameters.AddWithValue("@date", cancelled_date);
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                db.ExecuteQueryForTransaction(cmdInsCr);

                string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + cancelled_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + dt_sm.Rows[0]["cust_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                db.ExecuteQueryForTransaction(update_tbl_customer);
                result = "SUCCESS";
                db.CommitTransaction();

            }
        }
        catch (Exception ex)
        {
            db.RollBackTransaction();
            result = "FAILED";
            LogClass log_cust = new LogClass("order_cancellation_error");
            log_cust.write(ex);
            return result;

        }

        return result;

    }

    [WebMethod]
    public static string update_order_status_online(Dictionary<string, string> order)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {

            string action_date = Get_Current_Date_Time(order["time_zone"]);

            // packing only
            if (order["order_status"].ToString() == "10")
            {
                string update_sales_mstr = "";
                update_sales_mstr = "UPDATE tbl_sales_master SET sm_packed='1',sm_delivery_status='0',sm_processed_id='0',sm_packed_id='" + order["user_id"] + "',sm_packed_date='" + action_date + "' where sm_id='" + order["sm_id"] + "'";
                db.ExecuteQueryForTransaction(update_sales_mstr);               
                result = "SUCCESS";
                return result;

            }
            // new order
            else if (order["order_status"].ToString() == "0")
            {
                string update_sales_mstr = "";
                update_sales_mstr = "UPDATE tbl_sales_master SET sm_packed='0',sm_packed_id='0',sm_packed_date='0',sm_processed_id='0',sm_delivery_status='0',sm_delivered_id='0',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                db.ExecuteQueryForTransaction(update_sales_mstr);
                result = "SUCCESS";
                return result;
            }
            // process order
            else if (order["order_status"].ToString() == "1")
            {


                string vehicle_qry = "";
                if (order["vehicle_type"].ToString() == "1")
                {
                    vehicle_qry = "sm_delivery_vehicle_id='" + order["vehicle_id"] + "'";
                }
                else
                {
                    vehicle_qry = "sm_vehicle_no='" + order["vehicle_no"] + "'";
                }

                string update_sales_mstr = "";
                string check_status_qry = "SELECT sm.sm_delivery_status,sm.cust_id,sm.sm_netamount,cu.cust_amount,sm.branch_id,sm.sm_invoice_no FROM tbl_sales_master sm JOIN tbl_customer cu ON sm.cust_id=cu.cust_id WHERE sm.sm_id='" + order["sm_id"] + "'";
                DataTable dt_sm = db.SelectQuery(check_status_qry);

                if (dt_sm.Rows[0]["sm_invoice_no"].ToString() == "")
                {
                    
                    string branchPrefix = "";
                    string branchSuffix = "";

                    // generate new invoice id
                    int branchStart = 0;
                    string getTimeZone = "SELECT branch_timezone,branch_orderPrefix,branch_orderSerial,branch_orderSuffix,branch_tax_method,branch_tax_inclusive from tbl_branch where branch_id='" + dt_sm.Rows[0]["branch_id"].ToString() + "'";
                    DataTable cTimeZone = db.SelectQueryForTransaction(getTimeZone);
                    if (cTimeZone != null)
                    {
                        branchPrefix = Convert.ToString(cTimeZone.Rows[0]["branch_orderPrefix"]);
                        branchStart = Convert.ToInt32(cTimeZone.Rows[0]["branch_orderSerial"]);
                        branchSuffix = Convert.ToString(cTimeZone.Rows[0]["branch_orderSuffix"]);
                    }
                    else
                    { }

                    int invoiceSerialNo = 0;

                    string suffixQry = "SELECT IFNULL(max(sm_serialNo),0) FROM tbl_sales_master where branch_id=" + dt_sm.Rows[0]["branch_id"].ToString() + "  and sm_prefix='" + branchPrefix + "' and sm_suffix='" + branchSuffix + "'";
                    invoiceSerialNo = Convert.ToInt32(db.SelectScalarForTransaction(suffixQry));
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

                    if (order["current_packing_status"].ToString() == "1")
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET " + vehicle_qry + ",sm_prefix='" + branchPrefix + "',sm_serialNo=" + invoiceSerialNo + ",sm_suffix='" + branchSuffix + "',sm_invoice_no=concat(sm_prefix,sm_serialNo,sm_suffix),sm_processed_id='" + order["user_id"] + "',sm_processed_date='" + action_date + "',sm_delivery_status='1',sm_delivered_id='" + order["delivery_man"] + "',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                    }
                    else
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET " + vehicle_qry + ",sm_prefix='" + branchPrefix + "',sm_serialNo=" + invoiceSerialNo + ",sm_suffix='" + branchSuffix + "',sm_invoice_no=concat(sm_prefix,sm_serialNo,sm_suffix),sm_packed='1',sm_packed_id='" + order["user_id"] + "',sm_packed_date='" + action_date + "',sm_processed_id='" + order["user_id"] + "',sm_processed_date='" + action_date + "',sm_delivery_status='1',sm_delivered_id='" + order["delivery_man"] + "',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                    }
                }
                else
                {

                    if (order["current_packing_status"].ToString() == "1")
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET " + vehicle_qry + ",sm_processed_id='" + order["user_id"] + "',sm_processed_date='" + action_date + "',sm_delivery_status='1',sm_delivered_id='" + order["delivery_man"] + "',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                    }
                    else
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET " + vehicle_qry + ",sm_packed='1',sm_packed_id='" + order["user_id"] + "',sm_packed_date='" + action_date + "',sm_processed_id='" + order["user_id"] + "',sm_processed_date='" + action_date + "',sm_delivery_status='1',sm_delivered_id='" + order["delivery_man"] + "',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                    }
                }

                
                db.ExecuteQueryForTransaction(update_sales_mstr);
                result = "SUCCESS";
                return result;
            }
            // pending order
            else if (order["order_status"].ToString() == "6")
            {
                string update_sales_mstr = "";
                update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='6',sm_processed_id='" + order["user_id"] + "',sm_processed_date='" + action_date + "' where sm_id='" + order["sm_id"] + "'";
                db.ExecuteQueryForTransaction(update_sales_mstr);
                result = "SUCCESS";
                return result;
            }

            else
            {

            }

        }
        catch (Exception ex)
        {
            db.RollBackTransaction();
            result = "FAILED";
            result = "{\"result\":\"" + result + "\"}";
            LogClass log_cust = new LogClass("order_cancellation_error");
            log_cust.write(ex);
            return result;

        }

        return result;

    }

    [WebMethod]
    public static string editOrder(Dictionary<string, string> editedorder)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            int precision = Convert.ToInt32(editedorder["ss_decimal_accuracy"]);
            string edit_time = Get_Current_Date_Time(editedorder["time_zone"]);
            // removing old items // reducing stock

            db.BeginTransaction();

            string qry_b4edit = "select itbs_id,si_qty,si_foc,si_price,si_discount_rate,si_net_amount from tbl_sales_items where sm_id='" + editedorder["sm_id"] + "'";
            DataTable item_b4_edit = db.SelectQueryForTransaction(qry_b4edit);

            string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_name from tbl_sales_items where sm_id='" + editedorder["sm_id"] + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
            DataTable dt = db.SelectQueryForTransaction(qry);

            int numrows = dt.Rows.Count;
            string itbsidString = "";
            string itbsidStockString = "";

            if (dt.Rows.Count > 0)
            {
                Int32 oldqty = 0;
                Int32 oldfoc = 0;
                Int32 oldtotoalqty = 0;
                string olditbs = "";

                StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                StringBuilder can_sb_bulk_items = new StringBuilder();
                can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");

                int i_c = 0;
                string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                foreach (DataRow row in dt.Rows)
                {
                    oldqty = Convert.ToInt32(row["si_qty"]);
                    oldfoc = Convert.ToInt32(row["si_foc"]);
                    oldtotoalqty = oldfoc + oldqty;
                    olditbs = Convert.ToString(row["itbs_id"]);
                    itbsidString = itbsidString + "," + olditbs;
                    oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";

                    // stock transaction
                    can_sb_bulk_items.Append("('" + Convert.ToString(row["itbs_id"]) + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                    can_sb_bulk_items.Append(",'ORDER EDIT(stock increase) " + oldtotoalqty + " " + Convert.ToString(row["itm_name"]) + " in order #" + editedorder["sm_id"] + "','" + oldtotoalqty + "'");
                    can_sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(row["itbs_id"]) + "')");
                    can_sb_bulk_items.Append(",'" + edit_time + "')" + (i_c != numrows - 1 ? "," : ";"));
                    i_c = i_c + 1;
                }
                itbsidString = itbsidString.Trim().TrimStart(',');
                oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + edit_time + "' WHERE itbs_id IN (" + itbsidString + ")";
                db.ExecuteQueryForTransaction(oldupstockQry);

                if (can_sb_bulk_items.ToString() != "")
                {
                    can_sb_bulk_stkTrQry.Append(can_sb_bulk_items.ToString());
                    db.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                }
            }

            string delQry = "DELETE from tbl_sales_items  WHERE sm_id='" + editedorder["sm_id"] + "'";
            db.ExecuteQueryForTransaction(delQry);

            // adding the items & calculating tax etc

            // FOR SALES_MASTER

            double sm_discount_rate = 0;
            double sm_discount_amount = 0;
            double sm_netamount = 0;
            double sm_total = 0;
            double sm_balance = 0;
            double sm_tax_excluded_amt = 0;
            double sm_tax_amount = 0;
            Int32 sm_delivery_status = Convert.ToInt32(editedorder["sm_delivery_status"]);

            // FOR SALES ITEMS
            string itm_code = "";
            string itm_name = "";
            double si_org_price;
            double si_total;
            double si_discount_amount;
            double si_net_amount;
            double itm_commision;
            double itm_commisionamt = 0;
            double ofr_id;
            double ofritm_id;
            double si_item_tax;
            double si_item_cgst = 0, si_item_sgst = 0, si_item_igst = 0, si_item_utgst = 0;
            double si_item_cess;
            double si_tax_excluded_total;
            double si_tax_amount;

            // getting branch tax methods

            Int32 branch_id;
            Int32 branch_tax_method;
            Int32 branch_tax_inclusive;
            string branch_timezone = "";
            string cust_id = "";
            double old_netamount = 0.00;
            string oldorderstatus;

            string branchQry = "select sm.branch_id,sm.cust_id,sm.sm_netamount,sm.sm_delivery_status,br.branch_tax_method,br.branch_tax_inclusive,br.branch_timezone from tbl_branch br join tbl_sales_master sm on sm.branch_id=br.branch_id where sm.sm_id='" + editedorder["sm_id"] + "'";
            DataTable dt_branchDetail = db.SelectQueryForTransaction(branchQry);
            if (dt_branchDetail != null)
            {
                branch_id = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_id"]);
                branch_tax_method = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_tax_method"]);
                branch_tax_inclusive = Convert.ToInt32(dt_branchDetail.Rows[0]["branch_tax_inclusive"]);
                cust_id = Convert.ToString(dt_branchDetail.Rows[0]["cust_id"]);
                old_netamount = Convert.ToDouble(dt_branchDetail.Rows[0]["sm_netamount"]);
                oldorderstatus = Convert.ToString(dt_branchDetail.Rows[0]["sm_delivery_status"]);
                branch_timezone = Convert.ToString(dt_branchDetail.Rows[0]["branch_timezone"]);
            }
            else
            {
                result = "FAILED";
                return result;
            }


            Int32 cust_state = 0;

            double realtotal = 0;
            double nettotal = 0;
            double discount_amt = 0;
            double tax_amount = 0;
            double tax_exclusive_price = 0;
            double tax_exclusive_total = 0;
            double commisionAmount = 0;
            double tax_included_nettotal = 0;
            double cessAmount = 0;

            double si_qty = 0;
            double si_price = 0;
            double si_foc = 0;
            double si_discount_rate = 0;

            // checking weather its IGST

            string igst_qry = "Select tbl_branch.branch_state_id from tbl_branch join tbl_customer on tbl_branch.branch_state_id=tbl_customer.cust_state where tbl_branch.branch_id='" + branch_id + "' and tbl_customer.cust_id='" + cust_id + "'";
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


            List<Dictionary<string, string>> items_after_edit = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(editedorder["items_after_edit"]);
            dynamic order_data = JsonConvert.DeserializeObject(editedorder["items_after_edit"]);

            // PROCESSING ITEMS
            Int32 row_no = 0;
            //start changed by deepika
            // fetch item details from item_branch_stock and tbl_tax_profile
            string insert_to_sales_items = "INSERT INTO tbl_sales_items(sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_item_tax,si_item_cgst,si_item_sgst,si_item_igst,si_item_utgst,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type) VALUES";
            DataTable dt_itemDetail = new DataTable();
            foreach (var items in order_data)
            {
                if (items.si_itm_type != 4)
                {
                    itbsidStockString = itbsidStockString + "," + items.itbs_id;
                }
            }

            itbsidStockString = itbsidStockString.Trim().TrimStart(',');
            if (itbsidStockString != "")
            {
                string item_fetch_qry = "select itb.itbs_id,tax.tp_tax_percentage,tax.tp_cess,itb.itm_name,itb.itm_code,itb.itm_commision from tbl_itembranch_stock itb join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code where itb.itbs_id in (" + itbsidStockString + ")  ORDER BY FIELD(itb.itbs_id," + itbsidStockString + ")";
                dt_itemDetail = db.SelectQueryForTransaction(item_fetch_qry);
            }

            StringBuilder sb_bulk_stkTrQry = new StringBuilder();
            StringBuilder sb_bulk_items = new StringBuilder();

            sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES ");


            int size = items_after_edit.Count;
            for (int i = 0; i < size; i++)
            {// BASE VALUES
                si_qty = order_data[i].si_qty;
                si_price = order_data[i].si_price;
                si_foc = order_data[i].si_foc;
                si_discount_rate = order_data[i].si_discount_rate;
                si_org_price = order_data[i].si_org_price;
                itm_commision = Convert.ToDouble(dt_itemDetail.Rows[i]["itm_commision"]);
                si_item_tax = Convert.ToDouble(dt_itemDetail.Rows[i]["tp_tax_percentage"]);
                si_item_cess = Convert.ToDouble(dt_itemDetail.Rows[i]["tp_cess"]);
                itm_name = Convert.ToString(dt_itemDetail.Rows[i]["itm_name"]);
                itm_code = Convert.ToString(dt_itemDetail.Rows[i]["itm_code"]);

                // CALCULATIONS
                if (branch_tax_method == 0) // no tax
                {
                    realtotal = si_price * si_qty; // price without discount
                    realtotal = Math.Round(realtotal, precision);
                    discount_amt = ((realtotal * si_discount_rate) / 100);
                    nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                    tax_included_nettotal = Math.Round(nettotal, precision);
                    commisionAmount = ((nettotal * itm_commision) / 100);
                    commisionAmount = Math.Round(commisionAmount, precision);
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
                        splitted_GST_rate = Math.Round(splitted_GST_rate, precision);

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


                else
                {
                    // if null
                    result = "FAILED";
                    return result;
                }

                si_total = Math.Round(realtotal, precision);
                si_discount_amount = Math.Round(discount_amt, precision);
                si_net_amount = Math.Round(tax_included_nettotal, precision);
                itm_commisionamt = Math.Round(commisionAmount, precision);
                si_tax_amount = Math.Round(tax_amount, precision);

                // INSERTING INTO TBL_SALES_ITEMS

                if (order_data[i].si_itm_type == 0)
                { // inserting normal items

                    insert_to_sales_items += " (" + "'" + editedorder["sm_id"] + "','" + row_no + "', '" + order_data[i].itbs_id + "', '" + itm_code + "', '" + itm_name + "', '0', '" + si_org_price + "', '" + order_data[i].si_price + "', '" + si_qty + "', '" + si_total + "', '" + si_discount_rate + "', '" + si_discount_amount + "', '" + si_net_amount + "', '" + si_foc + "', '" + order_data[i].si_approval_status + "', '" + itm_commision + "', '" + itm_commisionamt + "', '0', '0','" + order_data[i].si_itm_type + "', '" + si_item_tax + "', '" + si_item_cgst + "', '" + si_item_sgst + "', '" + si_item_igst + "', '" + si_item_utgst + "', '" + si_item_cess + "', '" + (si_net_amount - tax_amount) + "', '" + tax_amount + "','" + order_data[i].itm_type + "'),";

                }

                row_no++;

                // calculation for sm - values

                //sm_tax_excluded_amt = sm_tax_excluded_amt + (si_net_amount - si_tax_amount);
                //sm_discount_amount = sm_discount_amount + si_discount_amount;
                //sm_netamount = sm_netamount + si_net_amount;
                //sm_tax_amount = sm_tax_amount + si_tax_amount;
                //sm_total = sm_total + si_total;

                sm_tax_excluded_amt = sm_tax_excluded_amt + (si_net_amount - si_tax_amount);
                sm_tax_excluded_amt = Math.Round(sm_tax_excluded_amt, precision);

                sm_discount_amount = sm_discount_amount + si_discount_amount;
                sm_discount_amount = Math.Round(sm_discount_amount, precision);

                sm_netamount = sm_netamount + si_net_amount;
                sm_netamount = Math.Round(sm_netamount, precision);

                sm_tax_amount = sm_tax_amount + si_tax_amount;
                sm_tax_amount = Math.Round(sm_tax_amount, precision);

                sm_total = sm_total + si_total;
                sm_total = Math.Round(sm_total, precision);

                // HANDLE STOCK
                if (order_data[i].si_itm_type != "1" && order_data[i].si_itm_type != "3" && order_data[i].si_itm_type != "4")
                {
                    if (order_data[i].itm_type == 1)
                    {
                        Int32 item_total_qty = Convert.ToInt32(si_foc) + Convert.ToInt32(si_qty);
                        string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock - " + item_total_qty + "),itm_last_update_date='" + edit_time + "' where itbs_id='" + order_data[i].itbs_id + "'";
                        db.ExecuteQueryForTransaction(upstockQry);

                        sb_bulk_items.Append("('" + order_data[i].itbs_id + "','" + ((int)Constants.ActionType.SALES) + "','" + editedorder["sm_id"] + "','" + editedorder["user_id"] + "'");
                        sb_bulk_items.Append(",'ORDER EDIT (Stock decrease) " + item_total_qty + " " + itm_name + " in order #" + editedorder["sm_id"] + "','" + item_total_qty + "'");
                        sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + order_data[i].itbs_id + "')");
                        sb_bulk_items.Append(",'" + edit_time + "')" + (i != size - 1 ? "," : ";"));
                    }
                }


            }  // ITEM for LOOP ENDS

            insert_to_sales_items = insert_to_sales_items.Remove(insert_to_sales_items.Trim().Length - 1);
            bool InsertItemresult = db.ExecuteQueryForTransaction(insert_to_sales_items);

            if (sb_bulk_items.ToString() != "")
            {

                sb_bulk_stkTrQry.Append(sb_bulk_items.ToString());
                db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
            }
            //end changed by deepika
            // UPDATING SALES MASTER

            string update_salesmaster_qry = "UPDATE tbl_sales_master SET sm_total='" + sm_total + "',sm_discount_rate='" + sm_discount_rate + "',sm_discount_amount='" + sm_discount_amount + "',sm_netamount='" + sm_netamount + "',sm_tax_excluded_amt='" + sm_tax_excluded_amt + "',sm_tax_amount='" + sm_tax_amount + "',sm_delivery_status='" + sm_delivery_status + "' WHERE sm_id='" + editedorder["sm_id"] + "'";
            bool update_sales_result = db.ExecuteQueryForTransaction(update_salesmaster_qry);

            string edited_date = Get_Current_Date_Time(editedorder["time_zone"]);
            //start updation in transactions
            if (sm_netamount > old_netamount)
            {
                //inserting order debit entry
                MySqlCommand cmdInsDr = new MySqlCommand();
                cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";

                cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsDr.Parameters.AddWithValue("@action_ref_id", editedorder["sm_id"]);
                cmdInsDr.Parameters.AddWithValue("@partner_id", cust_id);
                cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsDr.Parameters.AddWithValue("@branch_id", branch_id);
                cmdInsDr.Parameters.AddWithValue("@user_id", editedorder["user_id"]);
                cmdInsDr.Parameters.AddWithValue("@narration", "Reconciliation of Order #" + editedorder["sm_id"] + " after an edit by debiting the amount " + Math.Round((sm_netamount - old_netamount), precision));
                cmdInsDr.Parameters.AddWithValue("@dr", (sm_netamount - old_netamount));
                cmdInsDr.Parameters.AddWithValue("@date", edited_date);
                cmdInsDr.Parameters.AddWithValue("@is_reconciliation", "1");
                db.ExecuteQueryForTransaction(cmdInsDr);

            }
            else if (sm_netamount < old_netamount)
            {
                //inserting order credit entry
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " ( `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date, @is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";

                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", editedorder["sm_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_id", cust_id);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", branch_id);
                cmdInsCr.Parameters.AddWithValue("@user_id", editedorder["user_id"]);
                cmdInsCr.Parameters.AddWithValue("@narration", "Reconciliation of Order #" + editedorder["sm_id"] + " after an edit by crediting the amount " + Math.Round((old_netamount - sm_netamount), precision));
                cmdInsCr.Parameters.AddWithValue("@cr", (old_netamount - sm_netamount));
                cmdInsCr.Parameters.AddWithValue("@date", edited_date);
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                db.ExecuteQueryForTransaction(cmdInsCr);
            }
            //end updation in transactions

            string update_tbl_cust_amounts = "UPDATE tbl_customer SET cust_last_updated_date='" + edit_time + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + cust_id + "; SELECT cust_amount from tbl_customer WHERE cust_id='" + cust_id + "'";
            string newcust_amount = db.SelectScalarForTransaction(update_tbl_cust_amounts);

            //Entering to EDIT HISTORY
            #region EditHistory
            //***************************************** edit history starts

            // DataTable item_b4_edit - having items before edit

            string qry_aftredit = "select itbs_id,si_qty,si_foc,si_price,si_discount_rate,si_net_amount from tbl_sales_items where sm_id='" + editedorder["sm_id"] + "'";
            DataTable item_aftr_edit = db.SelectQueryForTransaction(qry_aftredit);

            string edit_history_string = "INSERT INTO `tbl_edit_history` (`sm_id`, `itbs_id`, `si_qty`, `si_price`, `si_discount_rate`, `si_foc`, `si_net_amount`, `new_si_qty`, `new_si_price`, `new_si_discount_rate`, `new_si_foc`, `new_si_net_amount`, `edit_action`, `edited_by`, `edited_date`) VALUES ";
            string edited_item_string = "";
            for (int m = 0; m < item_b4_edit.Rows.Count; m++)
            {
                var edit_si_qty = 0;
                var edit_si_price = 0.00;
                var edit_si_foc = 0;
                var edit_si_discount = 0.00;
                var edit_si_net_amount = 0.00;

                var edit_new_si_qty = 0;
                var edit_new_si_price = 0.00;
                var edit_new_si_foc = 0;
                var edit_new_si_discount = 0.00;
                var edit_new_si_net_amount = 0.00;

                DataRow[] i_rows = item_aftr_edit.Select("itbs_id='" + item_b4_edit.Rows[m]["itbs_id"] + "'");
                if (i_rows.Length > 0)
                {
                    // item still exist & hence compare with other values (foc,qty,price,discount)

                    edit_si_qty = Convert.ToInt32(item_b4_edit.Rows[m]["si_qty"]);
                    edit_si_price = Convert.ToDouble(item_b4_edit.Rows[m]["si_price"]);
                    edit_si_foc = Convert.ToInt32(item_b4_edit.Rows[m]["si_foc"]);
                    edit_si_discount = Convert.ToDouble(item_b4_edit.Rows[m]["si_discount_rate"]);
                    edit_si_net_amount = Convert.ToDouble(item_b4_edit.Rows[m]["si_net_amount"]);

                    edit_new_si_qty = Convert.ToInt32(i_rows[0]["si_qty"]);
                    edit_new_si_price = Convert.ToDouble(i_rows[0]["si_price"]);
                    edit_new_si_foc = Convert.ToInt32(i_rows[0]["si_foc"]);
                    edit_new_si_discount = Convert.ToDouble(i_rows[0]["si_discount_rate"]);
                    edit_new_si_net_amount = Convert.ToDouble(i_rows[0]["si_net_amount"]);

                    // remove row from item_aftr_edit (datatable)
                    if (edit_si_qty != edit_new_si_qty || edit_si_price != edit_new_si_price || edit_si_foc != edit_new_si_foc || edit_si_discount != edit_new_si_discount)
                    {
                        edited_item_string = edited_item_string + "('" + editedorder["sm_id"] + "', '" + item_b4_edit.Rows[m]["itbs_id"] + "', '" + edit_si_qty + "', '" + edit_si_price + "', '" + edit_si_discount + "', '" + edit_si_foc + "', '" + edit_si_net_amount + "', '" + edit_new_si_qty + "', '" + edit_new_si_price + "', '" + edit_new_si_discount + "', '" + edit_new_si_foc + "', '" + edit_new_si_net_amount + "', '1', '" + editedorder["user_id"] + "', '" + edited_date + "'),";
                    }
                    i_rows[0].Delete();
                    item_aftr_edit.AcceptChanges();

                }
                else
                {
                    // item removed -> fetch values and inserts with type 2
                    edit_si_qty = Convert.ToInt32(item_b4_edit.Rows[m]["si_qty"]);
                    edit_si_price = Convert.ToDouble(item_b4_edit.Rows[m]["si_price"]);
                    edit_si_foc = Convert.ToInt32(item_b4_edit.Rows[m]["si_foc"]);
                    edit_si_discount = Convert.ToDouble(item_b4_edit.Rows[m]["si_discount_rate"]);
                    edit_si_net_amount = Convert.ToDouble(item_b4_edit.Rows[m]["si_net_amount"]);

                    edited_item_string = edited_item_string + "('" + editedorder["sm_id"] + "', '" + item_b4_edit.Rows[m]["itbs_id"] + "', '" + edit_si_qty + "', '" + edit_si_price + "', '" + edit_si_discount + "', '" + edit_si_foc + "', '" + edit_si_net_amount + "', '" + edit_si_qty + "', '" + edit_si_price + "', '" + edit_si_discount + "', '" + edit_si_foc + "', '" + edit_si_net_amount + "', '2', '" + editedorder["user_id"] + "', '" + edited_date + "'),";

                }

            }

            // check for items in the item_aftr_edit (datatable) - if rows exist - new items should present in the order after editing
            // loop and insert - based on count item_aftr_edit

            for (int p = 0; p < item_aftr_edit.Rows.Count; p++)
            {
                var edit_si_qty = Convert.ToInt32(item_aftr_edit.Rows[p]["si_qty"]);
                var edit_si_price = Convert.ToDouble(item_aftr_edit.Rows[p]["si_price"]);
                var edit_si_foc = Convert.ToInt32(item_aftr_edit.Rows[p]["si_foc"]);
                var edit_si_discount = Convert.ToDouble(item_aftr_edit.Rows[p]["si_discount_rate"]);
                var edit_si_net_amount = Convert.ToDouble(item_aftr_edit.Rows[p]["si_net_amount"]);

                edited_item_string = edited_item_string + "('" + editedorder["sm_id"] + "', '" + item_aftr_edit.Rows[p]["itbs_id"] + "', '" + edit_si_qty + "', '" + edit_si_price + "', '" + edit_si_discount + "', '" + edit_si_foc + "', '" + edit_si_net_amount + "', '" + edit_si_qty + "', '" + edit_si_price + "', '" + edit_si_discount + "', '" + edit_si_foc + "', '" + edit_si_net_amount + "', '3', '" + editedorder["user_id"] + "', '" + edited_date + "'),";

            }

            // remove last comma from string -edit_history_string
            if (edited_item_string != "")
            {
                //edited_item_string = edited_item_string.Remove(edited_item_string.Trim().Length - 1);
                edited_item_string = edited_item_string.Trim().TrimEnd(',');
                edit_history_string = edit_history_string + edited_item_string;
                db.ExecuteQueryForTransaction(edit_history_string);
                Send_Push_Notification("EDIT", editedorder["sm_id"].ToString(), editedorder["user_id"].ToString());
            }
            #endregion
            //***************************************** edit history ends

            db.CommitTransaction();
            result = "SUCCESS";
            result = "{\"result\":\"" + result + "\",\"new_netamount\":" + sm_netamount + ",\"new_custamount\":" + newcust_amount + ",\"sm_delivery_status\":" + sm_delivery_status + "}";

        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                LogClass log = new LogClass("neworder");
                log.write(ex);
                return result;
            }
            catch
            {
            }
        }

        return result;
    }

    [WebMethod]
    public static string get_individual_orders(string page, string user_id, string branch_id)
    {
        var result = "";
        try
        {
            var perPage = 10;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(page) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;

            var cust_condition = " AND sm.sm_userid='" + user_id + "' ";
            var qry_Condition = " AND sm.sm_delivery_status IN (0,1,6) ";

            var count_qry = "SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id ORDER BY sm.sm_id DESC";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;
            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id ORDER BY FIELD(sm.sm_delivery_status,'0','6','1'),sm.sm_packed ASC LIMIT " + perPage + " OFFSET " + lowerBound + ""), Formatting.Indented) + "}";

            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("customer_read_error");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string get_print_details(string order_id)
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            mySqlConnection db = new mySqlConnection();
            sb.Append("{");
            string qry_order = @"SELECT sm.sm_id,br.branch_name,cu.cust_id,cu.cust_name,sm.sm_netamount,sm.sm_tax_excluded_amt,sm.sm_tax_amount,cu.cust_address,cu.cust_city,cu.cust_phone,cu.cust_reg_id,cu.cust_tax_reg_id,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,DATE_FORMAT(sm.sm_date,'%Y-%M-%d %h:%i %p') as sm_date,CONCAT(ud.first_name,' ',ud.last_name) as name,ud.phone FROM tbl_sales_master sm JOIN tbl_customer cu ON cu.cust_id=sm.cust_id JOIN tbl_user_details ud ON ud.user_id=sm.sm_userid JOIN tbl_branch br ON br.branch_id=sm.branch_id WHERE sm.sm_id='" + order_id + "'";            
            var dt_order = db.SelectQuery(qry_order);
            sb.Append("\"order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));

            sb.Append(",");
            string qry_items = "SELECT si.row_no,si.itm_code,si.itm_name,si.si_price,si.si_qty,si.si_discount_rate,si.si_foc,si.si_net_amount,si.si_tax_excluded_total,si.si_tax_amount FROM tbl_sales_items si WHERE si.sm_id='" + order_id + "'";
            var dt_items = db.SelectQuery(qry_items);
            sb.Append("\"items\":" + JsonConvert.SerializeObject(dt_items, Formatting.Indented));
            
            sb.Append("}");
            string a = sb.ToString();
            return sb.ToString();
        }
        catch (Exception ex)
        { return "N"; }
    }

    [WebMethod]
    public static string get_returned_item(Dictionary<string, string> filters)
    {
        string result = "";

        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string sl_qry = "";
        string action_qry = "";

        if (filters.Count > 0)
        {
            if (filters["srm_userid"] != "0")
            {
                sl_qry = " AND srm.srm_userid='" + filters["srm_userid"] + "' ";
            }
            else
            {
                sl_qry = " ";
            }

            if (filters["sr_action"] == "0")
            {
                action_qry = " AND sri.sri_recieved_id='0' ";
            }
            else if (filters["sr_action"] == "1")
            {
                action_qry = " AND sri.sri_recieved_id!='0' AND sri.sri_approved_id='0'";
            }
            else if (filters["sr_action"] == "2")
            {
                action_qry = " AND sri.sri_approved_id!='0'";
            }
        }

        string qry = @"SELECT sri.sm_id,sri.sri_id,sri.sri_type,sri.itbs_id,sri.itm_code,sri.sri_qty,sri.itm_name,sri.sri_total,srm.srm_id,srm.cust_id,cu.cust_name,srm.srm_amount,srm.srm_userid,CONCAT(ud.first_name,' ',ud.last_name) AS name,DATE_FORMAT(srm.srm_date,'%Y-%M-%d %h:%i %p') as srm_date,sri.sri_recieved_id,sri.sri_approved_id,DATE_FORMAT(sri.sri_approved_date,'%Y-%M-%d %h:%i %p') as sri_approved_date,DATE_FORMAT(sri.sri_recieved_date,'%Y-%M-%d %h:%i %p') as sri_recieved_date,
CONCAT(ad.first_name,' ',ad.last_name) AS adm_name,
CONCAT(rr.first_name,' ',rr.last_name) AS rr_name 
FROM tbl_salesreturn_items sri
INNER JOIN tbl_salesreturn_master srm on srm.srm_id=sri.srm_id 
INNER JOIN tbl_customer cu ON cu.cust_id=srm.cust_id 
INNER JOIN tbl_user_details ud ON ud.user_id=srm.srm_userid 
LEFT OUTER JOIN tbl_user_details AS ad ON ad.user_id=sri.sri_approved_id 
LEFT OUTER JOIN tbl_user_details AS rr ON rr.user_id=sri.sri_recieved_id 
INNER JOIN tbl_branch br ON br.branch_id=srm.branch_id 
WHERE srm.branch_id IN ( SELECT ub.branch_id FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + filters["user_id"] + "') " + sl_qry + action_qry + "";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

        string user_qry = "select ud.user_id,concat (ud.first_name,' ',ud.last_name)as name from tbl_user_details ud JOIN tbl_user_branches ub ON ub.user_id=ud.user_id where ud.user_type in(2,3) and ub.branch_id in ( SELECT ub.branch_id FROM tbl_user_branches ub JOIN tbl_branch tb ON tb.branch_id=ub.branch_id WHERE ub.user_id='" + filters["user_id"] + "') GROUP BY ud.user_id";
        DataTable dt_user = db.SelectQuery(user_qry);

        string jsonResponse = "";
        if (dt_user.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            string user_data = JsonConvert.SerializeObject(dt_user, Formatting.Indented);
            jsonResponse = "{\"data\":" + jsonData + ",\"user_data\":" + user_data + "}";

        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;

    }

    [WebMethod]
    public static string update_return_status(Dictionary<string, string> item)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        try
        {
            string action_date = Get_Current_Date_Time(item["time_zone"]);
            // packing only
             string update_sri = "";
             string reception_id = "";
             if (item["recep_status"].ToString() == "0")
             {
                 action_date = "0";
                 reception_id = "0";

             }
             else 
             { 
                 reception_id = item["user_id"].ToString();
             }
             
             update_sri = "UPDATE tbl_salesreturn_items SET sri_type='" + item["item_cond"] + "',sri_recieved_id='" + reception_id + "',sri_recieved_date='" + action_date + "' WHERE sri_id='" + item["sri_id"] + "';";
             db.ExecuteQueryForTransaction(update_sri);
             result = "SUCCESS";
             return result;                     
        }
        catch (Exception ex)
        {
            db.RollBackTransaction();
            result = "FAILED";
            result = "{\"result\":\"" + result + "\"}";
            LogClass log_cust = new LogClass("order_cancellation_error");
            log_cust.write(ex);
            return result;

        }

        return result;

    }

   
}