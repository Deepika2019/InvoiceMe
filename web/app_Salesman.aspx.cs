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
using System.Globalization;
using MySql.Data.MySqlClient;

public partial class appSalesman : System.Web.UI.Page
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
            check_authentication = "SELECT * FROM tbl_user_details ud WHERE ud.password='"+ password +"' AND ud.user_id='"+ user_id +"'";
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
   
    public static void Send_Push_Notification(string type , string action_ref_id)
    {

        // action_ref_id - could be order id , customer id etc.
        // TYPE 1 - ORDER - to be confirmed orders - send to all admins with access in the warehouse and location.
        // TYPE 2 - RETURN - when returning items - send to corresponding warehouse person.
        // TYPE 3 - REGISTRATION - to admins with access in tha location.
        // TYPE 4 - CLASS_CREDIT - to admins with access in tha location.
        // TYPE 5 - CANCEL - to admins with access in order-branch and customer location & warehouse with orders branch.
        // TYPE 6 - COMMON - to admins with the count of all pending elements.

        try
        {
            #region ORDER

            if (type == "ORDER")
            {

                var sm_id = action_ref_id;
                var location_id = "";
                var branch_id = "";
                var invoice_id = "";
                // getting - customer location and order branch_id from salesmaster

                var order_deatil_qry = "SELECT sm.branch_id,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,cu.location_id FROM tbl_sales_master sm JOIN tbl_customer cu ON sm.cust_id=cu.cust_id WHERE sm.sm_id='" + sm_id + "'";
                DataTable dt_order = new mySqlConnection().SelectQuery(order_deatil_qry);
                if (dt_order.Rows.Count > 0)
                {
                    location_id = dt_order.Rows[0]["location_id"].ToString();
                    branch_id = dt_order.Rows[0]["branch_id"].ToString();
                    invoice_id = dt_order.Rows[0]["sm_invoice_no"].ToString();

                    var message = "An order with invoice number " + invoice_id + " (" + sm_id + ") requires your approval.";

                    // getting user_list to be sent the notification
                    var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_locations ul ON ul.user_id=ud.user_id JOIN tbl_user_branches ub ON ub.user_id=ud.user_id WHERE ul.location_id='" + location_id + "' AND ub.branch_id='" + branch_id + "' AND ud.user_type='1'";
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
            #region CANCEL

            else if (type == "CANCEL")
            {
                var sm_id = action_ref_id;
                var location_id = "";
                var branch_id = "";
                var invoice_id = "";
                // getting - customer location and order branch_id from salesmaster

                var order_deatil_qry = "SELECT sm.branch_id,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,cu.location_id,CONCAT(ud.first_name,' ',ud.last_name) as name FROM tbl_sales_master sm JOIN tbl_customer cu ON sm.cust_id=cu.cust_id JOIN tbl_user_details ud ON ud.user_id=sm.sm_cancelled_id  WHERE sm.sm_id='" + sm_id + "'";
                DataTable dt_order = new mySqlConnection().SelectQuery(order_deatil_qry);
                if (dt_order.Rows.Count > 0)
                {
                    location_id = dt_order.Rows[0]["location_id"].ToString();
                    branch_id = dt_order.Rows[0]["branch_id"].ToString();
                    invoice_id = dt_order.Rows[0]["sm_invoice_no"].ToString();

                    var message = "An order with invoice number " + invoice_id + " (" + sm_id + ") has been cancelled by " + dt_order.Rows[0]["name"].ToString() + ".";

                    // getting user_list to be sent the notification - Admin
                    var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_locations ul ON ul.user_id=ud.user_id JOIN tbl_user_branches ub ON ub.user_id=ud.user_id WHERE ul.location_id='" + location_id + "' AND ub.branch_id='" + branch_id + "' AND ud.user_type='1'";
                    DataTable dt_user_list = new mySqlConnection().SelectQuery(user_list);

                    foreach (DataRow row in dt_user_list.Rows)
                    {
                        Send_Push_Message_to_user(row["user_androidid"].ToString(), message);
                    }

                    // to warehouse
                    var user_Wlist = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_branches ub ON ub.user_id=ud.user_id WHERE ub.branch_id='" + branch_id + "' AND ud.user_type='4'";
                    DataTable dt_Wuser_list = new mySqlConnection().SelectQuery(user_Wlist);

                    foreach (DataRow rows in dt_Wuser_list.Rows)
                    {
                        Send_Push_Message_to_user(rows["user_androidid"].ToString(), message);
                    }

                }
                else
                {
                    // if no rows found
                }

            }
            #endregion
            #region RETURN

            else if (type == "RETURN")
            {
                var srm_id = action_ref_id;
                // getting - customer location and order branch_id from salesmaster

                var qry = @"SELECT sri.sm_id,srm.branch_id,srm.cust_id,cu.cust_name,CONCAT(ud.first_name,' ',ud.last_name) AS name ,br.branch_name 
FROM tbl_salesreturn_items sri
INNER JOIN tbl_salesreturn_master srm on srm.srm_id=sri.srm_id 
INNER JOIN tbl_customer cu ON cu.cust_id=srm.cust_id 
INNER JOIN tbl_user_details ud ON ud.user_id=srm.srm_userid 
INNER JOIN tbl_branch br ON br.branch_id=srm.branch_id 
WHERE sri.sri_recieved_id='0' AND srm.srm_id='" + srm_id + "'";

                DataTable dt = new mySqlConnection().SelectQuery(qry);
                int numrows = dt.Rows.Count;
                if (numrows > 0) {

                    var branch_id = dt.Rows[0]["branch_id"].ToString();
                    var branch_name = dt.Rows[0]["branch_name"].ToString();
                    var sales_name = dt.Rows[0]["name"].ToString();
                    var cust_name = dt.Rows[0]["cust_name"].ToString();

                    var message = "" + numrows + " Item(s) has been returned from customer (" + cust_name + ") by " +sales_name + " towards the warehouse "+ branch_name +".";
                    
                    var user_Wlist = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_branches ub ON ub.user_id=ud.user_id WHERE ub.branch_id='" + branch_id + "' AND ud.user_type='4'";
                    DataTable dt_Wuser_list = new mySqlConnection().SelectQuery(user_Wlist);

                    foreach (DataRow rows in dt_Wuser_list.Rows)
                    {
                        Send_Push_Message_to_user(rows["user_androidid"].ToString(), message);
                    }
                }
               
                // to warehouse
                


            }
            #endregion
            #region REGISTRATION
            else if (type == "REGISTRATION")
            {

                var cust_id = action_ref_id;
                var location_id = "";
                // getting - customer location and order branch_id from salesmaster

                var cust_deatil_qry = "SELECT cust_reg_id,cust_name,CONCAT(cust_address,',',cust_city) as loc_name,location_id FROM tbl_customer WHERE cust_id='" + cust_id + "'";
                DataTable dt_customer = new mySqlConnection().SelectQuery(cust_deatil_qry);
                if (dt_customer.Rows.Count > 0)
                {
                    location_id = dt_customer.Rows[0]["location_id"].ToString();
                    var message = "NEW CUSTOMER REGISTRAION! : " + dt_customer.Rows[0]["cust_name"].ToString() + " (" + dt_customer.Rows[0]["loc_name"].ToString() + ") .Please Review the registration.";

                    // getting user_list to be sent the notification
                    var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_locations ul ON ul.user_id=ud.user_id WHERE ul.location_id='" + location_id + "' AND ud.user_type='1'";
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
            #region CLASS_CREDIT
            else if (type == "CLASS_CREDIT")
            {

                var cust_id = action_ref_id;
                var location_id = "";
                // getting - customer location and order branch_id from salesmaster

                var cust_deatil_qry = "SELECT cust_reg_id,cust_name,CONCAT(cust_address,',',cust_city) as loc_name,location_id FROM tbl_customer WHERE cust_id='" + cust_id + "'";
                DataTable dt_customer = new mySqlConnection().SelectQuery(cust_deatil_qry);
                if (dt_customer.Rows.Count > 0)
                {
                    location_id = dt_customer.Rows[0]["location_id"].ToString();
                    var message = "CUSTOMER CLASS/CREDIT CHANGE REQUEST RECIEVED! Customer : " + dt_customer.Rows[0]["cust_name"].ToString() + " (" + dt_customer.Rows[0]["loc_name"].ToString() + ") .Please Review the Request.";

                    // getting user_list to be sent the notification
                    var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud JOIN tbl_user_locations ul ON ul.user_id=ud.user_id WHERE ul.location_id='" + location_id + "' AND ud.user_type='1'";
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
            #region COMMON FOR ADMIN - ON SYYNC
            else if (type == "COMMON")
            {
                
                var message = "";
                // getting user_list to be sent the notification
                var user_list = "SELECT ud.user_id,ud.user_androidid FROM tbl_user_details ud WHERE ud.user_type='1'";
                DataTable dt_user_list = new mySqlConnection().SelectQuery(user_list);

                foreach (DataRow row in dt_user_list.Rows)
                {
                    var user_id = row["user_id"].ToString();
                    var android_id = row["user_androidid"].ToString();
                    var pending_deatil_qry = "SELECT user_id,CONCAT(first_name,' ',last_name) as name,(SELECT COUNT(cust_id) FROM tbl_customer cu INNER JOIN tbl_user_locations ul ON cu.location_id=ul.location_id WHERE ul.user_id='" + user_id + "' AND cu.cust_status='0' AND (cu.new_custtype!='0' OR cu.new_creditamt!='0.00' OR cu.new_creditperiod!='0') AND cu.cust_requestedby = ud.user_id )  AS new_classchanges,(SELECT COUNT(cust_id) from tbl_customer cu1 INNER JOIN tbl_user_locations ul1 ON cu1.location_id=ul1.location_id WHERE ul1.user_id='" + user_id + "' AND cu1.cust_status='1' AND cu1.user_id = ud.user_id)  AS new_registrations,(SELECT COUNT(sm_id) from tbl_sales_master sm1 INNER JOIN tbl_customer cu2 on cu2.cust_id=sm1.cust_id inner join tbl_user_branches ub ON ub.branch_id= sm1.branch_id INNER JOIN tbl_user_locations ul2 ON ul2.location_id=cu2.location_id WHERE ub.user_id='" + user_id + "' AND ul2.user_id='" + user_id + "' AND sm1.sm_delivery_status='3' AND sm1.sm_userid=ud.user_id ) AS pending_orders,(SELECT COUNT(sri_id) from tbl_salesreturn_items sri1 INNER JOIN tbl_salesreturn_master srm1 ON sri1.srm_id=srm1.srm_id INNER JOIN tbl_customer cu3 ON cu3.cust_id=srm1.cust_id INNER JOIN tbl_user_locations ul3 ON ul3.location_id=cu3.location_id INNER JOIN tbl_user_branches ub2 ON ub2.branch_id=srm1.branch_id WHERE ul3.user_id='" + user_id + "' AND ub2.user_id='" + user_id + "'  AND sri1.sri_recieved_id!='0'  AND sri1.sri_type!='2' AND srm1.srm_userid=ud.user_id ) AS pending_returns FROM tbl_user_details ud WHERE (ud.user_type='2' OR ud.user_type='3')";
                    DataTable dt_pending = new mySqlConnection().SelectQuery(pending_deatil_qry);
                    if (dt_pending.Rows.Count > 0)
                    {
                        Int32 cls_credit_count = 0;
                        Int32 new_reg_count = 0;
                        Int32 pending_order = 0;
                        Int32 pending_return = 0;

                        foreach (DataRow item in dt_pending.Rows)
                        {
                            cls_credit_count = cls_credit_count + Convert.ToInt32(item["new_classchanges"]);
                            new_reg_count = new_reg_count + Convert.ToInt32(item["new_registrations"]);
                            pending_order = pending_order + Convert.ToInt32(item["pending_orders"]);
                            pending_return = pending_return + Convert.ToInt32(item["pending_returns"]);
                        }

                        var class_msg = "";
                        var newreg_msg = "";
                        var order_msg = "";
                        var return_msg = "";

                        if (cls_credit_count != 0 || new_reg_count != 0 || pending_order != 0 || pending_return != 0)
                        {
                            if (cls_credit_count > 0) { class_msg = "[ " + cls_credit_count + " Class/Credit Change requests ] "; }
                            if (new_reg_count > 0) { newreg_msg = "[ " + new_reg_count + " New Registrations ] "; }
                            if (pending_order > 0) { order_msg = "[ " + pending_order + " Orders to be Approved ] "; }
                            if (pending_return > 0) { return_msg = "[ " + pending_return + " Return to be approved ] "; }

                            message = "You have " + class_msg + newreg_msg + order_msg + return_msg + "";
                            Send_Push_Message_to_user(android_id, message);
                        }

                        
                    }
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
        catch (Exception ex) {

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
    public static string Get_Customers(string user_id, string map_type)
    {

        var result = "";
        try
        {
            if (map_type == "1")
            {
                result = "{\"data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery("SELECT cu.cust_id,cu.cust_name,cu.cust_latitude as lat,cu.cust_longitude as lng FROM tbl_customer cu WHERE cu.cust_latitude!=0 and cu.location_id in (SELECT tul.location_id FROM tbl_user_locations tul WHERE tul.user_id='" + user_id + "' )"), Formatting.Indented) + "}";
            }
            else {
                result = "{\"data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery("SELECT cu.cust_id,cu.cust_name,cu.cust_latitude as lat,cu.cust_longitude as lng FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id WHERE sm.sm_delivered_id='" + user_id + "' and sm_delivery_status='1' GROUP BY cu.cust_id"), Formatting.Indented) + "}";
            }
                return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_Customers");
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
            var dt_login_ckeck = new mySqlConnection().SelectQuery(@"select user_id,CONCAT(first_name,' ',last_name) as name,user_device_id,password from tbl_user_details where user_name='" + logindata["user_name"] + "' and password='" + logindata["user_password"] + "' and user_type='2'");
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
    public static string First_Sync(string user_id,string timezone) {

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
                                     and tub.user_id='" + user_id + "' and itbs_available=1 and itb.itm_code!='1234567891234' order by itb.branch_id asc";
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
            
            result = "{\"dt_item_branchstockData\":" + dt_item_branchstockData + ",\"dt_branchData\":" + dt_branchData + ",\"dt_locationsData\":" + dt_locationsData + ",\"dt_customersData\":" + dt_customersData + ",\"dt_customer_catData\":" + dt_customer_catData + ",\"sync_time\":" + JsonConvert.SerializeObject(sync_time,Formatting.Indented) + "}";
            return result;
        }
        catch(Exception ex)
        {
            var log = new LogClass("First_Sync");
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
            result = "{\"item_data\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT itb.itbs_id,itb.branch_id,itb.itm_code,itb.itm_name,itb.itm_brand_id,brd.brand_name,itb.itm_category_id,tic.cat_name FROM tbl_itembranch_stock itb JOIN tbl_item_brand brd ON itb.itm_brand_id=brd.brand_id JOIN tbl_item_category tic ON tic.cat_id=itb.itm_category_id AND itb.itbs_available=1 AND itb.itm_code!='1234567891234' AND itb.branch_id IN (SELECT branch_id FROM tbl_user_branches WHERE user_id='" + user_id + "') AND itb.itm_last_update_date>'" + last_update_datetime + "'"), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_Items");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string customer_Registration(Dictionary<string, string> data)
    {       
        var result = "";
        var customer_id = "";
        
        try
        {            
            var db = new mySqlConnection();
            // check for existance with session id
            if (db.SelectQuery("SELECT cust_id FROM tbl_customer WHERE cust_sessionid='" + data["cust_sessionid"] + "'").Rows.Count > 0) // exist
            {
                customer_id = db.SelectScalar("SELECT cust_id FROM tbl_customer WHERE cust_sessionid='" + data["cust_sessionid"] + "'");
                //result = "EXIST";
                return result = "{\"result\":\"EXIST\",\"customer_id\":" + customer_id + "}";
            }
            else if (db.SelectQuery("SELECT cust_id FROM tbl_customer WHERE cust_reg_id='" + data["cust_reg_id"] + "' AND cust_reg_id IS NOT NULL AND cust_reg_id!=0").Rows.Count > 0) // exist
            {               
                //result = "EXIST";
                return result = "{\"result\":\"REGID\"}";
            }
            else // new registration
            {
                var cust_reg_id = data["cust_reg_id"].ToString();
                var qry = "INSERT INTO tbl_customer(cust_name,cust_type,cust_address,cust_city,cust_state,cust_country,cust_phone,cust_phone1,cust_email,cust_amount,cust_joined_date,cust_latitude,cust_longitude,cust_image,cust_note,user_id,max_creditamt,max_creditperiod,cust_requestedby,cust_status,cust_sessionid,cust_reg_id,cust_tax_reg_id,location_id,cust_cat_id,cust_last_updated_date) VALUES ('" + data["cust_name"] + "','" + data["cust_type"] + "','" + data["cust_address"] + "','" + data["cust_city"] + "','" + data["cust_state"] + "',(SELECT country_id FROM tbl_state WHERE state_id='" + data["cust_state"] + "'),'" + data["cust_phone"] + "','" + data["cust_phone1"] + "','" + data["cust_email"] + "','0.00','" + Get_Current_Date_Time(data["timezone"]) + "','" + data["cust_latitude"] + "','" + data["cust_longitude"] + "','" + (data["cust_sessionid"].ToString() + ".jpg") + "','" + data["cust_note"] + "','" + data["user_id"] + "','" + data["max_creditamt"] + "','" + data["max_creditperiod"] + "','" + data["user_id"] + "','1','" + data["cust_sessionid"] + "','" + data["cust_reg_id"] + "','" + data["cust_tax_reg_id"] + "','" + data["location_id"] + "','" + data["cust_cat_id"] + "','" + Get_Current_Date_Time(data["timezone"]) + "');Select last_insert_id();";
                customer_id = db.SelectScalar(qry);
                if (customer_id != null)
                {
                    // process image
                    try
                    {
                        var imgURL = System.Web.Hosting.HostingEnvironment.MapPath("~/custimage/");
                        var fileName = data["cust_sessionid"].ToString() + ".jpg";

                        // --- USE IN SYNC ---
                        string fileNameWitPathOld = imgURL + fileName;
                        FileInfo fileoldimg = new FileInfo(fileNameWitPathOld);
                        if (fileoldimg.Exists)//check file exsit or not
                        {
                            fileoldimg.Delete();
                        }
                        using (FileStream fs = new FileStream(imgURL + fileName, FileMode.Create))
                        {
                            using (BinaryWriter bw = new BinaryWriter(fs))
                            {
                                bw.Write(Convert.FromBase64String(data["cust_image"]));
                                bw.Close();
                            }
                        }

                        if (cust_reg_id == "0" || cust_reg_id == null || cust_reg_id == "") {

                            var cust_reg_id_qry = "UPDATE tbl_customer SET cust_reg_id='" + customer_id + "' WHERE cust_id='" + customer_id + "'";
                            db.ExecuteQuery(cust_reg_id_qry);

                        }

                        string chk_qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values ('" + data["user_id"] + "','" + customer_id + "','" + Get_Current_Date_Time(data["timezone"]) + "','" + data["cust_latitude"] + "','" + data["cust_longitude"] + "','1')";
                        db.ExecuteQuery(chk_qry);

                        Send_Push_Notification("REGISTRATION", customer_id);
                        result = "{\"result\":\"SUCCESS\",\"customer_id\":" + customer_id + "}";
                        return result;
                    }
                    catch (Exception ex)
                    {
                        new LogClass("image_error").write(ex);
                        result = "FAILED";
                        return result;
                    }
                }
            }

        }
        catch (Exception ex)
        {
            new LogClass("customer_Registration").write(ex);
            result = "FAILED";
            return result;
        }
       
      return result;

    }
   
    [WebMethod]// get location on chekin in
    public static string checkInCustomerLocation(string timezone, string sellerid, string customerid, string latitude, string longitude)
    {
        string result = "N";
        try
        {
            mySqlConnection db = new mySqlConnection();

            string current_date = Get_Current_Date(timezone);
            string check_in_date_time = Get_Current_Date_Time(timezone);

            //checking - weather the customer in which salesman checked in is available within 300 meters.
            //--------------------------------------------------------------------------------------------
            string cust_qry = "select cust_id,cust_sessionid, (3956 * 2 * ASIN(SQRT( POWER(SIN(( " + latitude + " - cust_latitude) *  pi()/180 / 2), 2) +COS( " + latitude + " * pi()/180) * COS(cust_latitude* pi()/180) * POWER(SIN(( " + longitude + " - cust_longitude ) * pi()/180 / 2), 2) ))) as distance from tbl_customer having distance <= 0.3 and (cust_id='" + customerid + "' or cust_sessionid='" + customerid + "') order by distance LIMIT 1";
            DataTable dt = db.SelectQuery(cust_qry);
            if (dt.Rows.Count > 0)
            {
                //checking - weather the salesman has been allocated to visit customer.
                //--------------------------------------------------------------------------------------------
                string visitqry = "select rt_id from tbl_root_tracker where cust_id='" + customerid + "' and rt_user_id='" + sellerid + "' and date(rt_datetime)='" + current_date + "'";
                DataTable dt1 = db.SelectQuery(visitqry);
                int visitrows = dt1.Rows.Count;
                if (visitrows != 0)
                {
                    // if available , updates the check in time - by using tbl_root_tracker -> [rt_id] - > mark as visited
                    string rt_id = "";
                    foreach (DataRow row in dt1.Rows)
                    {
                        rt_id = row["rt_id"].ToString();
                    }
                    string updateqry = "UPDATE tbl_root_tracker SET rt_visit_status='1',rt_datetime='" + check_in_date_time + "',rt_lat=(SELECT cust_latitude from tbl_customer where cust_id='" + customerid + "'),rt_lon=(SELECT cust_longitude from tbl_customer where cust_id='" + customerid + "') WHERE rt_id='" + rt_id + "'";
                    db.ExecuteQuery(updateqry);

                }
                else
                {
                    // if the customer not allocated already -> create a new entry -> mark as visited
                    string qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values ('" + sellerid + "','" + customerid + "','" + check_in_date_time + "',(SELECT cust_latitude from tbl_customer where cust_id='" + customerid + "'),(SELECT cust_longitude from tbl_customer where cust_id='" + customerid + "'),'1')";
                    db.ExecuteQuery(qry);
                }

                result = "SUCCESS";
            }
            else // no customer found with recieved latitude and longitude - > insert a check-in - with cust_id=0 ,
            {
                string qry2 = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values('" + sellerid + "','0','" + check_in_date_time + "','" + latitude + "','" + longitude + "','1')";
                db.ExecuteQuery(qry2);
                result = "FAILURE";
            }
        }

        catch (Exception ex) {
            LogClass log = new LogClass("checkInCustomerLocation");
            log.write(ex);
            result = "ERROR";
            return result;
        }

        return result;

    }

    [WebMethod]// get location on chekin in
    public static string Check_in_Common(string timezone, string sellerid, string latitude, string longitude)
    {
        string result = "N";
        try
        {
            mySqlConnection db = new mySqlConnection();

            string current_date = Get_Current_Date(timezone);
            string check_in_date_time = Get_Current_Date_Time(timezone);

            //checking - weather the customer in which salesman checked in is available within 300 meters.
            //--------------------------------------------------------------------------------------------
            string cust_qry = "select cust_id,cust_sessionid, (3956 * 2 * ASIN(SQRT( POWER(SIN(( " + latitude + " - cust_latitude) *  pi()/180 / 2), 2) +COS( " + latitude + " * pi()/180) * COS(cust_latitude* pi()/180) * POWER(SIN(( " + longitude + " - cust_longitude ) * pi()/180 / 2), 2) ))) as distance from tbl_customer having distance <= 0.1 order by distance LIMIT 1";
            DataTable dt = db.SelectQuery(cust_qry);
            if (dt.Rows.Count > 0)
            {
                var customerid = dt.Rows[0]["cust_id"].ToString();
                //checking - weather the salesman has been allocated to visit customer.
                //--------------------------------------------------------------------------------------------
                string visitqry = "select rt_id from tbl_root_tracker where cust_id='" + customerid + "' and rt_user_id='" + sellerid + "' and date(rt_datetime)='" + current_date + "'";
                DataTable dt1 = db.SelectQuery(visitqry);
                int visitrows = dt1.Rows.Count;
                if (visitrows != 0)
                {
                    // if available , updates the check in time - by using tbl_root_tracker -> [rt_id] - > mark as visited
                    string rt_id = "";
                    foreach (DataRow row in dt1.Rows)
                    {
                        rt_id = row["rt_id"].ToString();
                    }
                    string updateqry = "UPDATE tbl_root_tracker SET rt_visit_status='1',rt_datetime='" + check_in_date_time + "',rt_lat=(SELECT cust_latitude from tbl_customer where cust_id='" + customerid + "'),rt_lon=(SELECT cust_longitude from tbl_customer where cust_id='" + customerid + "') WHERE rt_id='" + rt_id + "'";
                    db.ExecuteQuery(updateqry);

                }
                else
                {
                    // if the customer not allocated already -> create a new entry -> mark as visited
                    string qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values ('" + sellerid + "','" + customerid + "','" + check_in_date_time + "',(SELECT cust_latitude from tbl_customer where cust_id='" + customerid + "'),(SELECT cust_longitude from tbl_customer where cust_id='" + customerid + "'),'1')";
                    db.ExecuteQuery(qry);
                }

                result = "SUCCESS";
            }
            else // no customer found with recieved latitude and longitude - > insert a check-in - with cust_id=0 ,
            {
                string qry2 = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values('" + sellerid + "','0','" + check_in_date_time + "','" + latitude + "','" + longitude + "','1')";
                db.ExecuteQuery(qry2);
                result = "FAILURE";
            }
        }

        catch (Exception ex)
        {
            LogClass log = new LogClass("checkInCustomerLocation");
            log.write(ex);
            result = "ERROR";
            return result;
        }

        return result;

    }
   
    [WebMethod]
    public static string Get_Orders_with_date_range(Dictionary<string, string> filters)
    {
        var result = "";
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
            if (filters["orders_from"] != "" && filters["orders_to"] != "")
            {
                qry_Condition += " AND date(sm.sm_date)>='" + filters["orders_from"] + "' AND date(sm.sm_date)<='" + filters["orders_to"] + "' ";
            }

            var having_cond = "";
            if (filters["payment_status"] != "x")
            {
                if (filters["payment_status"] == "1"){

                    having_cond += " having sum(dr)-sum(cr) > 0 ";
                }
                if (filters["payment_status"] == "2")
                {
                    having_cond += " having (sum(dr)-sum(cr) = 0 or sum(dr)-sum(cr) < 0) ";
                }
                
            }

            if (filters["type"] == "1")
            {
                qry_Condition += " AND sm.sm_userid='"+ filters["user_id"] +"' ";
            }
                var count_qry = "SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,sm.sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id " + having_cond + " ORDER BY sm.sm_id DESC";
                var dt_count = new mySqlConnection().SelectQuery(count_qry);
                totalRows = dt_count.Rows.Count;
                result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 " + cust_condition + qry_Condition + " GROUP BY sm.sm_id " + having_cond + " ORDER BY sm.sm_id DESC LIMIT " + perPage + " OFFSET " + lowerBound + ""), Formatting.Indented) + "}";
            
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_Orders_with_date_range");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string updateCustFollowUpDay(string custid, string date,string time_zone)
    {

        mySqlConnection db = new mySqlConnection();
        string qry = "update tbl_customer set cust_followup_date='" + date + "',cust_last_updated_date='"+  Get_Current_Date_Time(time_zone) +"'  where cust_id=" + custid;
        if (db.ExecuteQuery(qry))
        {
            return "Y";
        }
        else
        {
            return "N";
        }

    }


    [WebMethod]
    public static string getCustFollowUps(Dictionary<string, string> filters)
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
        string location_qry = "";
        if (filters.Count > 0)
        {
            if (filters["location_id"] != "0")
            {
                location_qry = " and location_id='" + filters["location_id"] + "' ";
            }
            else
            {
                location_qry = " and location_id in (select location_id from tbl_user_locations where tbl_user_locations.user_id='" + filters["user_id"] + "') ";
            }

        }


        string qry = "select tbl_customer.cust_id,tbl_customer.cust_name,tbl_customer.cust_address,tbl_customer.cust_city,DATE_FORMAT(tbl_customer.cust_followup_date, '%m/%d/%Y ') as cust_followup_date from tbl_customer  where cust_followup_date!='NULL' and date(cust_followup_date) >= '" + filters["dateFrom"] + "' and date(cust_followup_date) <= '" + filters["dateTo"] + "' " + location_qry + "";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

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

    [WebMethod]
    public static string get_pending_approvals(Dictionary<string, string> filters)
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
        
        string qry = "";
        if (filters["approval_type"] == "2")
        {
            qry = "SELECT cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,DATE_FORMAT(cu.cust_joined_date ,'%Y-%M-%d %h:%i %p') AS cust_joined_date FROM tbl_customer cu WHERE cu.cust_status in (2,1) and cu.user_id='" + filters["user_id"] + "'";
        }
        else if (filters["approval_type"] == "3")
        {
            qry = "SELECT cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,cu.cust_type,cu.max_creditamt,cu.max_creditperiod,cu.new_custtype,cu.new_creditamt,cu.new_creditperiod FROM tbl_customer cu WHERE cu.cust_status=0 AND (cu.new_custtype!=0 OR cu.new_creditamt!= 0 OR cu.new_creditperiod !=0) AND cu.cust_requestedby='" + filters["user_id"] + "'";
        }
        else {

            qry = "SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE 1=1 and sm_userid='" + filters["user_id"] + "' and sm_delivery_status='3' GROUP BY sm.sm_id ORDER BY sm.sm_id DESC";
        }
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

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

    [WebMethod]
    public static string getDuePayments(Dictionary<string, string> filters)
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

        string qry = @"SELECT cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,
(sum(dr)-sum(cr)) total_balance from tbl_sales_master sm 
inner join tbl_customer cu on cu.cust_id = sm.cust_id 
inner join tbl_transactions tr on (tr.action_ref_id=sm.sm_id and tr.action_type=1) where sm_delivery_status=2  and sm.sm_userid='" + filters["user_id"] + "' and DATEDIFF(NOW(),DATE(sm.sm_processed_date))>IFNULL(cu.max_creditperiod,0) group by cu.cust_id having ( 1=1  and (sum(dr)-sum(cr)) > 0) order by sm.sm_processed_date asc";
        DataTable dt = db.SelectQuery(qry);

        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"rowsCount\":" + dt.Rows.Count + ",\"data\":" + jsonData + "}";

        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;

    }

    [WebMethod]
    public static string getProductOverview(Dictionary<string, string> filters)
    {
        string result = "";

        var auth_result = authenticate_user(filters["salesman"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string overview_cond = "where 1=1";
        string branch_qry = "";

        if (filters.Count > 0)
        {
            //if (filters["branchid"] != "0")
            //{
            //    branch_qry = " and sm.branch_id in (select br.branch_id from tbl_branch br join tbl_user_branches tub on tub.branch_id=br.branch_id and tub.user_id='" + filters["salesman"] + "')";

            //}
            //else
            //{
            //    branch_qry = "";
            //}

            if (filters.ContainsKey("dateFrom"))
            {
                overview_cond += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["dateFrom"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("dateTo"))
            {
                overview_cond += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["dateTo"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("salesman"))
            {
                overview_cond += " and sm.sm_userid='" + filters["salesman"] + "'";
            }
            if (filters.ContainsKey("brand"))
            {
                overview_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                overview_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
        }
        string summeryQuery = "select IFNULL(sum(si.si_net_amount),0) as net_sales" +
            " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
            " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" +
            " inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " + overview_cond + branch_qry + " and sm.sm_delivery_status not in (4,5)";
        DataTable dtSummery = db.SelectQuery(summeryQuery);
        sb.Append("{");
        sb.Append("\"net_sales\":" + dtSummery.Rows[0]["net_sales"]);
        DataTable dtBrands = new DataTable();
        string overviewQry = "select * from (" +
            "select br.brand_id,br.brand_name as brand,sum(si.si_net_amount) as tot_sales" +
        " ,ROUND((sum(si.si_net_amount)/" + dtSummery.Rows[0]["net_sales"] + ")*100,2) as sales_percentage" +
        " ,count(*) as sales_count" +
        " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
        " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" +
        " inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " + overview_cond + branch_qry + " and sm.sm_delivery_status not in (4,5) group by br.brand_id" +
        " union" +
        " select brand_id as brand_id,brand_name as brand,0 as tot_sales,0 as sales_percentage,0 as sales_count " +
        " from tbl_item_brand " +
        " ) res where " + (filters.ContainsKey("brand") ? "res.brand_id=" + filters["brand"] : "1=1") +
        " group by res.brand_id order by res.tot_sales desc";
        dtBrands = db.SelectQuery(overviewQry);
        sb.Append(",\"overview\":" + JsonConvert.SerializeObject(dtBrands, Formatting.Indented));
        sb.Append("}");
        return sb.ToString();
    }

    [WebMethod]
    public static string getBrandOverview(Dictionary<string, string> filters)
    {
        

        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        string overview_cond = "where 1=1";
        string branch_qry = "";
        if (filters.Count > 0)
        {
            //if (filters["branchid"] != "0")
            //{
            //    branch_qry = " and sm.branch_id in (select br.branch_id from tbl_branch br join tbl_user_branches tub on tub.branch_id=br.branch_id and tub.user_id='" + filters["salesman"] + "')";

            //}
            //else
            //{
            //    branch_qry = "";
            //}
            if (filters.ContainsKey("dateFrom"))
            {
                overview_cond += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["dateFrom"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("dateTo"))
            {
                overview_cond += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["dateTo"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("salesman"))
            {
                overview_cond += " and sm.sm_userid='" + filters["salesman"] + "'";
            }
            if (filters.ContainsKey("brand"))
            {
                overview_cond += " and itbs.itm_brand_id='" + filters["brand"] + "'";
            }
            if (filters.ContainsKey("category"))
            {
                overview_cond += " and itbs.itm_category_id='" + filters["category"] + "'";
            }
        }
        string summeryQuery = "select IFNULL(sum(si.si_net_amount),0) as net_sales,br.brand_name as brand" +
            " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
            " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id" +
            " inner join tbl_item_brand br on itbs.itm_brand_id=br.brand_id " +
            " " + overview_cond + branch_qry + " and sm.sm_delivery_status not in (4,5)";
        DataTable dtSummery = db.SelectQuery(summeryQuery);
        sb.Append("{");
        sb.Append("\"net_sales\":" + dtSummery.Rows[0]["net_sales"]);
        sb.Append(",\"brand\":\"" + dtSummery.Rows[0]["brand"] + "\"");
        if (filters.ContainsKey("category"))
        {
            DataTable dtCategory = db.SelectQuery("select cat_name from tbl_item_category where cat_id='" + filters["category"] + "'");
            sb.Append(",\"category\":\"" + dtCategory.Rows[0]["cat_name"] + "\"");
        }
        DataTable dtBrands = new DataTable();
        string overviewQry = " select * from (" +
        " select si.itm_name as item,itbs.itm_id as id,sum(si.si_net_amount) as tot_sales" +
        " ,ROUND((sum(si.si_net_amount)/" + dtSummery.Rows[0]["net_sales"] + ")*100,2) as sales_percentage" +
        " from tbl_sales_items si inner join tbl_sales_master sm on sm.sm_id=si.sm_id " +
        " inner join tbl_itembranch_stock itbs on si.itbs_id=itbs.itbs_id " + overview_cond + branch_qry + " and sm.sm_delivery_status not in (4,5) group by itbs.itm_id" +
        " union " +
        " select itm_name as item,itm_id as id,0 as tot_sales,0 as sales_percentage " +
        " from tbl_item_master where itm_brand_id=" + filters["brand"] +
        (filters.ContainsKey("category") ? " and itm_category_id='" + filters["category"] + "'" : "") +
        " ) res group by res.id order by tot_sales desc";
        dtBrands = db.SelectQuery(overviewQry);
        sb.Append(",\"overview\":" + JsonConvert.SerializeObject(dtBrands, Formatting.Indented));
        sb.Append("}");
        return sb.ToString();
    }

    [WebMethod]
    public static string getBrandsAndCategories()
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string brandQry = "select brand_id,brand_name from tbl_item_brand";
        DataTable dtBrand = db.SelectQuery(brandQry);
        sb.Append("\"brands\":" + JsonConvert.SerializeObject(dtBrand, Formatting.Indented));
        string categoryQry = "select cat_id,cat_name from tbl_item_category where parent_id='0'";
        DataTable dtCategory = db.SelectQuery(categoryQry);
        sb.Append(",\"categories\":" + JsonConvert.SerializeObject(dtCategory, Formatting.Indented));

        //string salesQry = "select user_id,first_name,last_name from tbl_user_details where user_type='2'";
        //DataTable dtSales = db.SelectQuery(salesQry);
        //sb.Append(",\"Salesman\":" + JsonConvert.SerializeObject(dtSales, Formatting.Indented));

        sb.Append("}");
        return sb.ToString();
    }

    [WebMethod]
    public static string getOverview(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        string qry_cond = "where 1=1 ";

        if (filters.Count > 0)
        {
            if (filters["branch"] != "0")
            {
                qry_cond = " and sm.branch_id='" + filters["branch"] + "'";

            }

            if (filters.ContainsKey("dateFrom"))
            {
                qry_cond += " and date(sm.sm_date)>=STR_TO_DATE('" + filters["dateFrom"] + "','%d-%m-%Y')";
            }
            if (filters.ContainsKey("dateTo"))
            {
                qry_cond += " and date(sm.sm_date)<=STR_TO_DATE('" + filters["dateTo"] + "','%d-%m-%Y')";

            }
            if (filters.ContainsKey("user"))
            {
                qry_cond += " and sm.sm_userid='" + filters["user"] + "'";
            }
            qry_cond += " and sm.sm_delivery_status not in(4,5)";


        }

        //get sellerwise overview
        string saleswiseQuery = "select IFNULL(count(*),0) as order_count ,IFNULL(sum(res.sm_netamount),0) as total_sale" +
            " ,IFNULL(sum( CASE WHEN (res.balance>0) THEN 1 ELSE 0 END),0) as outstanding_count " +
            " ,IFNULL(sum( CASE WHEN (res.balance>0) THEN res.balance ELSE 0 END),0) as total_outstanding" +
            " ,IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),res.sm_date)>res.max_creditperiod and res.balance>0) THEN 1 ELSE 0 END),0) as exceeded_outstanding_count " +
            " ,IFNULL(sum( CASE WHEN (DATEDIFF(NOW(),res.sm_date)>res.max_creditperiod and res.balance>0) THEN res.balance ELSE 0 END),0) as exceeded_outstanding " +
            " ,IFNULL(sum(res.paid),0) as total_receipt" +
            " ,IFNULL(SUM( CASE WHEN (res.sm_delivery_status=0) THEN 1 ELSE 0 END),0) new_order_count" +
            " ,IFNULL(SUM( CASE WHEN (res.sm_delivery_status=1) THEN 1 ELSE 0 END),0) processed_order_count" +
            " ,IFNULL(SUM( CASE WHEN (res.sm_delivery_status=2) THEN 1 ELSE 0 END),0) delivered_order_count" +
            " ,IFNULL(SUM( CASE WHEN (res.sm_delivery_status=3) THEN 1 ELSE 0 END),0) toBeConfirmed_order_count " +
            " ,res.seller_name,res.seller_id ,IFNULL(sum(res.commision),0) as total_commision " +
            " ,IFNULL(sum( CASE WHEN (res.sm_delivery_status=2) THEN res.commision ELSE 0 END),0) as delivered_commision " +
            " from ( select sm.sm_netamount ,(sm.sm_netamount-(sum(dr)-sum(cr))) as paid,(sum(dr)-sum(cr)) balance,sm.sm_date,sm_delivery_status " +
            " ,cu.max_creditperiod , concat(ud.first_name,' ',ud.last_name) as seller_name,ud.user_id as seller_id  " +
            " ,(select sum(itm_commisionamt) from tbl_sales_items si where si.sm_id=sm.sm_id) as commision" +
            " from tbl_sales_master sm  inner join tbl_customer cu on cu.cust_id=sm.cust_id " +
            " inner join tbl_user_details ud on sm.sm_userid=ud.user_id" +
            " inner join tbl_transactions tr on (tr.action_ref_id=sm.sm_id and tr.action_type=1) " +
            qry_cond + " group by tr.action_ref_id,tr.action_type ) res group by res.seller_id";
        DataTable dt_overview = db.SelectQuery(saleswiseQuery);
        if (!(dt_overview is DBNull))
        {
            //sb.Append(",");
            sb.Append("\"overview\":" + JsonConvert.SerializeObject(dt_overview, Formatting.Indented));
        }
        sb.Append("}");
        return sb.ToString();
    }

    [WebMethod]
    public static string Sales_Overview(string branch_id, string user_id, string date_from ,string date_to, string password , string device_id)
    {

        string result = "";

        var auth_result = authenticate_user(user_id, password, device_id);
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        StringBuilder sb = new StringBuilder();
        try
        {
            mySqlConnection db = new mySqlConnection();
            sb.Append("{");

            // CHECK IN COUNT - 
            string qry_checkin = @"SELECT COUNT(tr.rt_id) as checkin_count FROM tbl_root_tracker tr WHERE date(tr.rt_datetime)>='" + date_from + "' AND date(tr.rt_datetime)<='" + date_to + "' AND tr.rt_user_id='" + user_id + "' AND tr.rt_visit_status=1";
            var dt_checkin = db.SelectQuery(qry_checkin);
            sb.Append("\"check_in\":" + JsonConvert.SerializeObject(dt_checkin, Formatting.Indented));

            // CREDIT - DEBIT - RETURN

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
FROM tbl_transactions tr WHERE date(tr.date)>='" + date_from + "' AND date(tr.date)<='" + date_to + "' AND tr.user_id='"+ user_id +"' AND tr.branch_id='"+ branch_id +"' ";
            var dt_cr_dr_rt = db.SelectQuery(qry_credit_debit_return);
            sb.Append("\"dt_cr_dr_rt\":" + JsonConvert.SerializeObject(dt_cr_dr_rt, Formatting.Indented));

            // ORDERS + COMMISION DETAILS
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
				 WHERE date(tsm.sm_date)>='" + date_from +"' AND date(tsm.sm_date)<='"+ date_to +"' AND tsm.sm_userid='"+ user_id +"' AND tsm.branch_id='"+ branch_id +"' group by tr.action_ref_id,tr.action_type ) sm";
            var dt_order = db.SelectQuery(qry_order);
            sb.Append("\"dt_order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));

            sb.Append(",");
            string qry_paid_past = "SELECT count(id) as pre_pay_count,IFNULL(SUM(tr.cr),0) as old_payments FROM tbl_transactions tr JOIN tbl_customer cu ON tr.partner_id=cu.cust_id JOIN tbl_sales_master sm on sm.sm_id=tr.action_ref_id WHERE tr.action_type='1' AND tr.partner_type=1 AND tr.dr=0 AND tr.is_reconciliation=0 AND date(sm.sm_date)<'" + date_from + "' AND date(tr.date)>='" + date_from + "' AND date(tr.date)<='" + date_to + "' AND tr.branch_id='" + branch_id + "' AND tr.user_id='" + user_id + "'";
            var dt_past_paid = db.SelectQuery(qry_paid_past);
            sb.Append("\"dt_past_paid\":" + JsonConvert.SerializeObject(dt_past_paid, Formatting.Indented));

            sb.Append(",");
            string qry_new_reg = "SELECT COUNT(cust_id) as total_reg,IFNULL(SUM( CASE WHEN (cu.cust_status=1) THEN 1 ELSE 0 END),0) pending_customer,IFNULL(SUM( CASE WHEN (cu.cust_status=0) THEN 1 ELSE 0 END),0) approved_customer,IFNULL(SUM( CASE WHEN (cu.cust_status=2) THEN 1 ELSE 0 END),0) rejected_customer FROM tbl_customer cu WHERE cu.user_id='"+ user_id +"' AND date(cu.cust_joined_date)>='" + date_from + "' AND date(cu.cust_joined_date)<='" + date_to + "' ";
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
            WHERE tbl_sales_master.sm_id='" + order_id+"'";

            DataTable dt_order = new DataTable();
            dt_order = db.SelectQuery(qry_order);
            sb.Append("\"order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));
            sb.Append(",");
            string qry_items = "select itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type from tbl_sales_items where sm_id='" + order_id + "'";
            DataTable dt_items = db.SelectQuery(qry_items);
            sb.Append("\"items\":" + JsonConvert.SerializeObject(dt_items, Formatting.Indented));                        
            sb.Append("}");
            string a = sb.ToString();
            return sb.ToString();
        }
        catch (Exception ex)
        { return "N"; }
    }

    [WebMethod]
    public static string search_return_item(Dictionary<string, string> filters)
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
        string brand_qry = "";
        string category_qry = "";

        if (filters.Count > 0)
        {
            if (filters["brand"] != "x")
            {
                brand_qry = " and itb.itm_brand_id='" + filters["brand"] + "' ";
            }
            else
            {
                brand_qry = " ";
            }

            if (filters["category"] != "x")
            {
                category_qry = " and itb.itm_category_id='" + filters["category"] + "' ";
            }
            else
            {
                category_qry = " ";
            }
        }

        string qry = "select IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_id,si.itbs_id,si.itm_name,si.itm_code,si.si_qty,si.si_foc,(si.si_qty+si.si_foc) as total_qty,si.si_discount_rate,DATE_FORMAT(sm.sm_date, '%d %M %Y') as sm_date,sm.cust_id ,si.si_price,IFNULL(sum(CASE WHEN (sr.sri_qty) THEN sr.sri_qty ELSE 0 END),0) as returned ,(si.si_net_amount/(si.si_qty+si.si_foc)) as return_price from tbl_sales_master sm join tbl_sales_items si on si.sm_id=sm.sm_id join tbl_itembranch_stock itb on itb.itbs_id=si.itbs_id left join tbl_salesreturn_items sr on (sr.itbs_id=itb.itbs_id and sm.sm_id=sr.sm_id ) where sm.branch_id='" + filters["branch_id"] + "' and si.itm_name like '%" + filters["searchTerm"] + "%'" + brand_qry + category_qry + " and sm.sm_delivery_status=2 and si.itm_type=1 and sm.sm_type='1' and sm.cust_id='" + filters["custid"] + "' group by si.si_id having total_qty>returned order by sm.sm_date desc";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

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

    [WebMethod]
    public static string sales_return(Dictionary<string, string> return_order)
    {
        string result = "";
        string credited_amount = "";
        string new_balance = "";
        mySqlConnection db = new mySqlConnection();

        if (db.SelectQuery("SELECT srm_id FROM tbl_salesreturn_master WHERE srm_session_id='" + return_order["session_id"] + "'").Rows.Count > 0) // exist
        {
            new_balance = db.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + return_order["cust_id"] + "'");
            result = "EXIST";
            result = "{\"result\":\"" + result + "\",\"credited_amount\":" + credited_amount + ",\"new_balance\":" + new_balance + "}";
            return result;
        }

        try
        {
            // getting timezone from branch
            db.BeginTransaction();

            string branchQry = "select branch_timezone from tbl_branch where branch_id='" + return_order["branchid"] + "'";
            string branch_timezone = return_order["branch_time_zone"];

            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(branch_timezone);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string srm_date = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");

            // INSERTING TO SALES RETURN MASTER

            string srm_insert_qry = "INSERT INTO `tbl_salesreturn_master` (`sm_id`, `cust_id`, `srm_userid`, `branch_id`, `srm_date`,`srm_session_id`) VALUES('0','" + return_order["cust_id"] + "','" + return_order["user_id"] + "','" + return_order["branchid"] + "','" + srm_date + "','" + return_order["session_id"] + "');Select last_insert_id();";
            var last_id = db.SelectScalarForTransaction(srm_insert_qry);
            Int32 srm_id = Convert.ToInt32(last_id);

            // END OF INSERTING TO SALES RETURN MASTER
            // getting returned items

            List<Dictionary<string, string>> return_Items = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(return_order["return_Items"]);
            dynamic return_data = JsonConvert.DeserializeObject(return_order["return_Items"]);
            string ret_items = "";
            for (int i = 0; i < Convert.ToInt32(return_order["item_count"]); i++)
            {
                if (i == 0)
                {
                    ret_items = return_data[i].itbs_id;
                }
                else
                {
                    ret_items = ret_items + "," + return_data[i].itbs_id;
                }

            }

            string batch_insert_items_header = "INSERT INTO `tbl_salesreturn_items` (`srm_id`, `sm_id`, `row_no`, `itbs_id`, `itm_code`, `itm_name`, `si_price`, `si_discount_rate`, `sri_qty`, `sri_discount_amount`, `sri_total`, `sri_type`) VALUES";
            string batch_insert_items = "";
            decimal srm_amount = 0;

            

            for (int i = 0; i < Convert.ToInt32(return_order["item_count"]); i++)
            {
             
                if (i == 0)
                {
                    batch_insert_items = "('" + srm_id + "','" + return_data[i].sm_id + "','" + i + "','" + return_data[i].itbs_id + "','" + return_data[i].itm_code + "','" + return_data[i].itm_name + "','" + return_data[i].si_price + "','" + return_data[i].si_discount_rate + "','" + return_data[i].sri_qty + "','0','" + return_data[i].sri_total + "','" + return_data[i].sri_type + "')";

                }
                else
                {
                    batch_insert_items = batch_insert_items + "," + "('" + srm_id + "','" + return_data[i].sm_id + "','" + i + "','" + return_data[i].itbs_id + "','" + return_data[i].itm_code + "','" + return_data[i].itm_name + "','" + return_data[i].si_price + "','" + return_data[i].si_discount_rate + "','" + return_data[i].sri_qty + "','0','" + return_data[i].sri_total + "','" + return_data[i].sri_type + "')";
                }

                srm_amount = srm_amount + Convert.ToDecimal(return_data[i].sri_total);
                credited_amount = srm_amount.ToString();

                // increase stock for ready to use items
                if (return_data[i].sri_type == "2")
                {
                    string new_stockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock + " + return_data[i].sri_qty + "),itm_last_update_date='" + srm_date + "' where itbs_id='" + return_data[i].itbs_id + "'";
                    db.ExecuteQueryForTransaction(new_stockQry);

                    StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                    can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");
                    // stock transaction
                    can_sb_bulk_stkTrQry.Append("('" + Convert.ToString(return_data[i].itbs_id) + "','" + ((int)Constants.ActionType.SALES) + "','" + return_data[i].sm_id + "','" + return_order["user_id"] + "'");
                    can_sb_bulk_stkTrQry.Append(",'SALES RETURN: (stock increase) " + return_data[i].sri_qty + " qty " + Convert.ToString(return_data[i].itm_name) + " from order #" + return_data[i].sm_id + "','" + return_data[i].sri_qty + "'");
                    can_sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(return_data[i].itbs_id) + "')");
                    can_sb_bulk_stkTrQry.Append(",'" + srm_date + "');");
                    db.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                }
            }

            string saveToSalesReturnItemsasBatch = batch_insert_items_header + batch_insert_items;
            bool batch_result = db.ExecuteQueryForTransaction(saveToSalesReturnItemsasBatch);

            

            if (batch_result)
            {
                // updating sales return master
                string update_sales_return = "UPDATE tbl_salesreturn_master SET srm_amount='" + srm_amount + "' where srm_id='" + srm_id + "'";
                bool sm_result = db.ExecuteQueryForTransaction(update_sales_return);

                //inserts to transaction table
                //inserting order credit entry
                MySqlCommand cmdInsCr = new MySqlCommand();
                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                    " (`session_id`,`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`closing_balance`)" +
                    " select @session_id,@action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                cmdInsCr.Parameters.AddWithValue("@session_id", return_order["session_id"]);
                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES_RETURN);
                cmdInsCr.Parameters.AddWithValue("@action_ref_id", srm_id);
                cmdInsCr.Parameters.AddWithValue("@partner_id", return_order["cust_id"]);
                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                cmdInsCr.Parameters.AddWithValue("@branch_id", return_order["branchid"]);
                cmdInsCr.Parameters.AddWithValue("@user_id", return_order["user_id"]);
                cmdInsCr.Parameters.AddWithValue("@narration", "Return of items worth " + srm_amount);
                cmdInsCr.Parameters.AddWithValue("@cr", srm_amount);
                cmdInsCr.Parameters.AddWithValue("@date", srm_date);
                db.ExecuteQueryForTransaction(cmdInsCr);

                string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='"+srm_date+"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions  where partner_id='" + return_order["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + return_order["cust_id"] + "; SELECT cust_amount FROM tbl_customer WHERE cust_id=" + return_order["cust_id"];
                new_balance = db.SelectScalarForTransaction(update_tbl_customer);
                result = "SUCCESS";
                
            }
            else
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                return result;
            }

            db.CommitTransaction();
            Send_Push_Notification("RETURN", srm_id.ToString());
            result = "SUCCESS";            
            result = "{\"result\":\"" + result + "\",\"credited_amount\":" + credited_amount + ",\"new_balance\":" + new_balance + "}";
        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                result = "FAILED";
                result = "{\"result\":\"" + result + "\"}";
                db.RollBackTransaction();
                LogClass log = new LogClass("sales_return");
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
    public static string Get_Orders_for_delivery(Dictionary<string, string> filters)
    {
        var result = "";

        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        try
        {
            var perPage = 15;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;
            var count_qry = "SELECT sm.sm_id FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE sm.sm_delivered_id=" + filters["user_id"] + " and sm.sm_delivery_status='1' GROUP BY sm.sm_id";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;

            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE sm.sm_delivered_id=" + filters["user_id"] + " and sm.sm_delivery_status='1' GROUP BY sm.sm_id ORDER BY sm.sm_id DESC LIMIT " + perPage + " OFFSET " + lowerBound + ""), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_Orders_for_delivery");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string get_customer_transactions(Dictionary<string, string> filters)
    {
        string result = "";
        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }
        mySqlConnection db = new mySqlConnection();

        string date_qry = "";
        if (filters.Count > 0)
        {
            if (filters["dateFrom"] != "undefined-undefined-")
            {
                date_qry += " AND DATE(tr.date)>='" + filters["dateFrom"] + "' ";
            }
            if (filters["dateTo"] != "undefined-undefined-")
            {
                date_qry += " AND DATE(tr.date)<='" + filters["dateTo"] + "' ";
            }

        }

        var perPage = 15;
        var totalRows = 0;
        var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
        var upperBound = perPage + lowerBound - 1;
        var count_qry = @"SELECT tr.id,tr.cr,tr.dr,CONCAT(ud.first_name,' ',ud.last_name) as name,tr.action_type,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date 
                       FROM tbl_transactions tr 
                       JOIN tbl_user_details ud ON ud.user_id=tr.user_id 
                       WHERE tr.partner_id=" + filters["cust_id"] + " " + date_qry + " AND tr.partner_type=1 AND tr.branch_id IN (SELECT branch_id FROM tbl_user_branches WHERE user_id=" + filters["user_id"] + ") ORDER BY tr.date DESC";
        
        var dt_count = new mySqlConnection().SelectQuery(count_qry);
        totalRows = dt_count.Rows.Count;
        //double total_pages = totalRows / perPage;
        //totPages = Convert.ToInt32(Math.Ceiling(total_pages));
       

        string qry = @"SELECT tr.id,tr.cr,tr.dr,CONCAT(ud.first_name,' ',ud.last_name) as name,tr.action_type,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date 
                       FROM tbl_transactions tr 
                       JOIN tbl_user_details ud ON ud.user_id=tr.user_id 
                       WHERE tr.partner_id=" + filters["cust_id"] + " " + date_qry + " AND tr.partner_type=1 AND tr.branch_id IN (SELECT branch_id FROM tbl_user_branches WHERE user_id=" + filters["user_id"] + ") ORDER BY tr.date DESC LIMIT " + perPage + " OFFSET " + lowerBound + "";
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
    public static string upload_and_sync(Dictionary<string, string> sync_data)
    {
        var result = "";
        var auth_result = authenticate_user(sync_data["user_id"].ToString(), sync_data["password"].ToString(), sync_data["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        string JSONString = string.Empty;
        string jsonResponse = "";

        // Getting Sync Date
        TimeZoneInfo CURR_TIME_ZONE = TimeZoneInfo.FindSystemTimeZoneById(sync_data["time_zone"].ToString());
        DateTime currdate = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow,CURR_TIME_ZONE);
        string sync_date_time = DateTime.Parse(currdate.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        string sync_date = DateTime.Parse(sync_date_time).ToString("yyyy-MM-dd");
        // START SYNCING

        DataTable dt_cust_id = new DataTable();
        dt_cust_id.Clear();
        dt_cust_id.Columns.Add("cust_id");
        dt_cust_id.Columns.Add("cust_sessionid");
      
        //***********************************************************************************************************************
        // 1 . CUSTOMER REGISTRATION
        #region
        mySqlConnection db_customer = new mySqlConnection();
        // checking for the new_registration_count
        try
        {
            db_customer.BeginTransaction();
            if (sync_data["new_registration_count"] == "0")
            {
                // no new_registrations's found
            }
            else
            {
                DataTable new_registration_data = JsonConvert.DeserializeObject<DataTable>(sync_data["new_registration_data"]);
                foreach (DataRow items in new_registration_data.Rows)
                {
                    string getsessionexist = "select cust_sessionid,cust_id from tbl_customer where (cust_sessionid='" + items["cust_id"] + "' or cust_id='" + items["cust_id"] + "')";
                    DataTable dtsession = db_customer.SelectQueryForTransaction(getsessionexist);
                    
                    if (dtsession.Rows.Count != 0)  // ALREADY SAVED CUSTOMER CASE
                    {
                        string exist_id = dtsession.Rows[0]["cust_id"].ToString();
                        string ex_session_id = dtsession.Rows[0]["cust_sessionid"].ToString();
                        var fileName = "";
                        if (items["img_updated"].ToString() == "1")
                        {
                            var imgURL = System.Web.Hosting.HostingEnvironment.MapPath("~/custimage/");
                            fileName = ex_session_id + ".jpg";

                            // --- USE IN SYNC ---
                            string fileNameWitPathOld = imgURL + fileName;
                            FileInfo fileoldimg = new FileInfo(fileNameWitPathOld);
                            if (fileoldimg.Exists)//check file exsit or not
                            {
                                fileoldimg.Delete();
                            }
                            using (FileStream fs = new FileStream(imgURL + fileName, FileMode.Create))
                            {
                                using (BinaryWriter bw = new BinaryWriter(fs))
                                {
                                    bw.Write(Convert.FromBase64String(items["cust_image"].ToString()));
                                    bw.Close();
                                }
                            }

                            // update cust image
                            var cust_up_qry = "UPDATE tbl_customer SET cust_image='" + fileName + "' WHERE cust_id= '" + exist_id + "'";
                            db_customer.ExecuteQueryForTransaction(cust_up_qry);
                        }

                        // EDIT CUSTOMER DETAILS
                        string customer_update_qry = @"UPDATE tbl_customer SET cust_name='" + items["cust_name"] + "',cust_address='" + items["cust_address"] + "',cust_city='" + items["cust_city"] + "',cust_state='" + items["cust_state"] + "',cust_phone='" + items["cust_phone"] + "',cust_phone1='" + items["cust_phone1"] + "',cust_email='" + items["cust_email"] + "',cust_latitude='" + items["cust_latitude"] + "',cust_longitude='" + items["cust_longitude"] + "',cust_note='" + items["cust_note"] + "',cust_followup_date='" + items["cust_followup_date"] + "',cust_reg_id='" + items["cust_reg_id"] + "',cust_tax_reg_id='" + items["cust_tax_reg_id"] + "',location_id='" + items["location_id"] + "',cust_type='" + items["cust_type"] + "',max_creditamt='" + items["max_creditamt"] + "',max_creditperiod='" + items["max_creditperiod"] + "',new_custtype='" + items["new_custtype"] + "',new_creditamt='" + items["new_creditamt"] + "',new_creditperiod='" + items["new_creditperiod"] + "',cust_cat_id='" + items["cust_cat_id"] + "',cust_last_updated_date='" + sync_date_time + "' WHERE cust_id= '" + exist_id + "'";
                        db_customer.ExecuteQueryForTransaction(customer_update_qry);
                        dt_cust_id.Rows.Add(exist_id, items["cust_id"]);
                    }
                    else
                    {
                        // NEW REGISTRATIONS
                       
                        var imgURL = System.Web.Hosting.HostingEnvironment.MapPath("~/custimage/");
                        var fileName = items["cust_id"].ToString() + ".jpg";

                        // --- USE IN SYNC ---
                        string fileNameWitPathOld = imgURL + fileName;
                        FileInfo fileoldimg = new FileInfo(fileNameWitPathOld);
                        if (fileoldimg.Exists)//check file exsit or not
                        {
                            fileoldimg.Delete();
                        }
                        using (FileStream fs = new FileStream(imgURL + fileName, FileMode.Create))
                        {
                            using (BinaryWriter bw = new BinaryWriter(fs))
                            {
                                bw.Write(Convert.FromBase64String(items["cust_image"].ToString()));
                                bw.Close();
                            }
                        }

                        string customer_qry = @"INSERT INTO tbl_customer(cust_name,cust_address,cust_city,cust_state,cust_country,cust_phone,cust_phone1,cust_email,cust_latitude,cust_longitude,cust_image,cust_note,cust_status,cust_followup_date,cust_reg_id,cust_tax_reg_id,location_id,cust_sessionid,cust_joined_date,user_id,cust_type,max_creditamt,max_creditperiod,new_custtype,new_creditamt,new_creditperiod,cust_cat_id,cust_last_updated_date) 
                            VALUES('" + items["cust_name"] + "','" + items["cust_address"] + "','" + items["cust_city"] + "','" + items["cust_state"] + "','" + items["cust_country"] + "','" + items["cust_phone"] + "','" + items["cust_phone1"] + "','" + items["cust_email"] + "','" + items["cust_latitude"] + "','" + items["cust_longitude"] + "','" + fileName + "','" + items["cust_note"] + "','1','" + items["cust_followup_date"] + "','" + items["cust_reg_id"] + "','" + items["cust_tax_reg_id"] + "','" + items["location_id"] + "','" + items["cust_id"] + "','" + items["cust_joined_date"] + "','" + sync_data["user_id"] + "','" + items["cust_type"] + "','" + items["max_creditamt"] + "','" + items["max_creditperiod"] + "','" + items["new_custtype"] + "','" + items["new_creditamt"] + "','" + items["new_creditperiod"] + "','" + items["cust_cat_id"] + "','" + sync_date_time + "');Select last_insert_id()";

                        var cust_id = db_customer.SelectScalarForTransaction(customer_qry);

                        if (items["cust_reg_id"].ToString() == items["cust_id"])
                        {
                            var cust_reg_id_qry = "UPDATE tbl_customer SET cust_reg_id='" + cust_id + "' WHERE cust_id='" + cust_id + "'";
                            db_customer.ExecuteQueryForTransaction(cust_reg_id_qry);
                        }

                        string chk_qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values ('" + sync_data["user_id"] + "','" + cust_id + "','" + sync_date_time + "','" + items["cust_latitude"] + "','" + items["cust_longitude"] + "','1')";
                        db_customer.ExecuteQueryForTransaction(chk_qry);

                        dt_cust_id.Rows.Add(cust_id, items["cust_id"]);                       
                    }
                }
            }

            db_customer.CommitTransaction();
        }
        catch (Exception ex_customer)
        {
            try
            {
                db_customer.RollBackTransaction();
                jsonResponse = "FAILED";
                LogClass log_cust = new LogClass("customer_register_error");
                log_cust.write(ex_customer);

                string JSONString_error = string.Empty;
                JSONString_error = JsonConvert.SerializeObject(sync_data);
                log_cust.write_all_data(JSONString_error);

                return jsonResponse;
            }
            catch (Exception ex_roll_cust)
            {
                jsonResponse = "FAILED";
                LogClass log = new LogClass("cust_roll_error");
                log.write(ex_roll_cust);
                return jsonResponse;
            }
        }
        #endregion 
        //***********************************************************************************************************************
        // 2 . CHECK IN TABLE 
        #region
        //***********************************************************************************************************************

        try
        {
            mySqlConnection db_checkin = new mySqlConnection();
            // checking for the check in counts
            if (sync_data["check_in_count"] == "0")
            {
                // no check in's found
            }
            else
            {   
                // check in's found
                DataTable check_in_data = JsonConvert.DeserializeObject<DataTable>(sync_data["check_in_data"]);
                foreach (DataRow items in check_in_data.Rows)
                {
                    if (Convert.ToString(items["rt_checkin_type"]) == "0") // normal global check-in
                    {
                       
                    } // normal check-in ends
                    else if (Convert.ToString(items["rt_checkin_type"]) == "1") // customer page check-in
                    {
                       
                        mySqlConnection db = new mySqlConnection();
                        string check_in_datetime = items["rt_datetime"].ToString();
                        string check_in_date = DateTime.Parse(check_in_datetime.ToString()).ToString("yyyy-MM-dd");

                        string rt_lat = "0";
                        string rt_lon = "0";
                        string cust_id = "0";

                        // get nearest customer and customer location details from recieved location details ie: items["rt_lat"] & items["rt_lon"]
                        string cust_qry = "select cust_id,cust_latitude,cust_longitude,(3956 * 2 * ASIN(SQRT( POWER(SIN(( " + items["rt_lat"] + " - cust_latitude) *  pi()/180 / 2), 2) +COS( " + items["rt_lat"] + " * pi()/180) * COS(cust_latitude* pi()/180) * POWER(SIN(( " + items["rt_lon"] + " - cust_longitude ) * pi()/180 / 2), 2) ))) as distance from tbl_customer WHERE (cust_id='" + items["rt_cust_id"] + "' OR cust_sessionid='" + items["rt_cust_id"] + "') having distance <= 2 order by distance LIMIT 1";
                        DataTable dt = db.SelectQuery(cust_qry);

                        if (dt.Rows.Count > 0) // if a customer is found 
                        {
                            rt_lat = Convert.ToString(dt.Rows[0]["cust_latitude"]);
                            rt_lon = Convert.ToString(dt.Rows[0]["cust_longitude"]);
                            cust_id = Convert.ToString(dt.Rows[0]["cust_id"]);
                            
                            // checking for route mapping allocation for the customer on the check in date.
                            string visitqry = "select rt_id from tbl_root_tracker where cust_id='" + cust_id + "' and rt_user_id='" + sync_data["user_id"] + "' and date(rt_datetime)='" + check_in_date + "'";
                            DataTable dt1 = db.SelectQuery(visitqry);
                            
                            if (dt1.Rows.Count != 0) // if allocated for the day of check in - find-out the row i and update the row
                            {
                                string rt_id = "";
                                rt_id = Convert.ToString(dt1.Rows[0]["rt_id"]);
                                string updateqry = "UPDATE tbl_root_tracker SET rt_visit_status='1',rt_datetime='" + check_in_datetime + "',rt_lat='" + rt_lat + "',rt_lon='" + rt_lon + "' WHERE rt_id='" + rt_id + "'";
                                db.ExecuteQuery(updateqry);
                            }
                            else // if not allocated - insert as new entry
                            {
                                string qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values('" + sync_data["user_id"] + "','" + cust_id + "','" + check_in_datetime + "','" + rt_lat + "','" + rt_lon + "','1')";
                                db.ExecuteQuery(qry);
                            }
                        }
                        else // no nearby customer found
                        {
                            // entry placed - as customer id as 0 // check-in failed // will be considered as failed check in
                            string qry = "insert into tbl_root_tracker(rt_user_id,cust_id,rt_datetime,rt_lat,rt_lon,rt_visit_status) values('" + sync_data["user_id"] + "','0','" + check_in_datetime + "','" + rt_lat + "','" + rt_lon + "','1')";
                            db.ExecuteQuery(qry);
                        }                        
                    }
                }
            }
        }
        catch (Exception ex_checkin)
        {

            jsonResponse = "FAILED";
            LogClass log_cust = new LogClass("customer_checkin_error");
            log_cust.write(ex_checkin);
            string JSONString_error = string.Empty;
            JSONString_error = JsonConvert.SerializeObject(sync_data);
            log_cust.write_all_data(JSONString_error);
            return jsonResponse;
        }

        #endregion
        //***********************************************************************************************************************
        // 4 . CREDIT - DEBIT NOTES
        //***********************************************************************************************************************
        #region
        mySqlConnection db_credit = new mySqlConnection();
        try
        {
            if (sync_data["credit_debit_count"] == "0")
            {
                // no credit notes found
            }
            else
            {

                // credit notes found
                db_credit.BeginTransaction();
                DataTable credit_debit_data = JsonConvert.DeserializeObject<DataTable>(sync_data["credit_debit_data"]);
                foreach (DataRow items in credit_debit_data.Rows)
                {
                    string cust_id = "0";

                    if (items["is_new_registration"].ToString() == "1")
                    {
                        var cust_row = dt_cust_id.Select("cust_sessionid = '" + items["partner_id"] + "'");
                        cust_id = Convert.ToString(cust_row[0]["cust_id"].ToString());
                    }
                    else 
                    {
                        cust_id = Convert.ToString(items["partner_id"]);
                    }

                    string getsessionexist = "select session_id from tbl_transactions where session_id='" + items["session_id"] + "'";
                    DataTable dtsession = db_credit.SelectQueryForTransaction(getsessionexist);
                    int sess_rows = dtsession.Rows.Count;

                    if (sess_rows != 0)  // ALREADY SAVED CASE
                    {
                        // do nothing
                    }
                    else
                    {
                        string cr_or_dr = "";
                        string act_type = "";
                        if (Convert.ToString(items["action_type"]) == "5") // DEBIT NOTE
                        {
                            cr_or_dr = "+@dr";
                            act_type = "7";
                        }
                        else {
                            cr_or_dr = "-@cr";
                            act_type = "6";
                        }
                        MySqlCommand cmdInsCr = new MySqlCommand();
                        cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " (`session_id`,`action_type`,`partner_id`,`partner_type`, `branch_id`,`user_id`,`cash_amt`, `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`, `narration`, `dr`,`cr`,  `date`,`closing_balance`)" +
                            " select @session_id, @action_type, @partner_id, @partner_type,@branch_id, @user_id,@cash_amt, @cheque_amt, @cheque_no, @cheque_date, @cheque_bank, @narration, @dr, @cr, @date,(ifnull(sum(dr)-sum(cr),0)"+cr_or_dr+") from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                        cmdInsCr.Parameters.AddWithValue("@session_id", items["session_id"]);
                        
                        cmdInsCr.Parameters.AddWithValue("@partner_id", cust_id);
                        cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                        cmdInsCr.Parameters.AddWithValue("@branch_id", items["branch_id"]);
                        cmdInsCr.Parameters.AddWithValue("@user_id", items["user_id"]);
                        cmdInsCr.Parameters.AddWithValue("@cash_amt", items["cash_amt"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_amt", items["cheque_amt"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_no", items["cheque_no"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_date", items["cheque_date"]);
                        cmdInsCr.Parameters.AddWithValue("@cheque_bank", items["cheque_bank"]);
                        cmdInsCr.Parameters.AddWithValue("@narration", items["narration"]);
                        cmdInsCr.Parameters.AddWithValue("@action_type", act_type);
                        cmdInsCr.Parameters.AddWithValue("@cr", items["cr"]);
                        cmdInsCr.Parameters.AddWithValue("@dr", items["dr"]);
                        cmdInsCr.Parameters.AddWithValue("@date", items["date"]);
                        db_credit.ExecuteQueryForTransaction(cmdInsCr);

                        string update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_last_updated_date='"+ sync_date_time +"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + cust_id;
                        db_credit.ExecuteQueryForTransaction(update_tbl_cust_branch_amounts);
                    }
                }
                db_credit.CommitTransaction();
            }
        }
        catch (Exception ex_credit_debit)
        {
            try
            {
                db_credit.RollBackTransaction();
                jsonResponse = "FAILED";
                LogClass log_cust = new LogClass("credit_debit_error");
                log_cust.write(ex_credit_debit);

                string JSONString_error = string.Empty;
                JSONString_error = JsonConvert.SerializeObject(sync_data);
                log_cust.write_all_data(JSONString_error);
                
                return jsonResponse;
            }
            catch (Exception ex_roll_credit)
            {
                jsonResponse = "FAILED";
                LogClass log = new LogClass("credit_roll_error");
                log.write(ex_roll_credit);
                return jsonResponse;
            }
        }
        #endregion
        //***********************************************************************************************************************
        // 5 . SALES MASTER
        //***********************************************************************************************************************
        #region
        DataTable sls_master = JsonConvert.DeserializeObject<DataTable>(sync_data["sales_master_data"]);
        mySqlConnection db_order = new mySqlConnection();
        try
        {
            int precision = Convert.ToInt32(sync_data["ss_decimal_accuracy"]);

            if (sync_data["new_order_count"] == "0")
            {
                // no orders found
            }
            else
            {
                db_order.BeginTransaction();
                DataTable sls_items = JsonConvert.DeserializeObject<DataTable>(sync_data["sales_item_data"]);
                foreach (DataRow sl_mstr in sls_master.Rows)
                {
                    DataTable order_data = new DataTable();
                        order_data = sls_items.Clone();
                        DataRow[] rowsToCopy;
                        rowsToCopy = sls_items.Select("sm_id='" + sl_mstr["sm_id"] + "'");
                        foreach (DataRow temp in rowsToCopy)
                        {
                            order_data.ImportRow(temp);
                        }

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
                        double ofr_id;
                        double ofritm_id;
                        double si_item_tax;
                        double si_item_cgst = 0, si_item_sgst = 0, si_item_igst = 0, si_item_utgst = 0;
                        double si_item_cess;
                        double si_tax_excluded_total;
                        double si_tax_amount;

                        Int32 branch_tax_method = 0;
                        Int32 branch_tax_inclusive = 0;
                        int invoiceSuffix = 0;
                        string branch_timezone = "";
                        string branchPrefix = "";
                        string branchSuffix = "";
                        int need_to_cancel = 0;
                        sm_delivery_status = Convert.ToInt32(sl_mstr["sm_delivery_status"]);
                        if (sm_delivery_status == 4)
                        {
                            need_to_cancel = 1;
                        }
                        string getsessionexist = "select sm_sales_sessionid from tbl_sales_master where sm_sales_sessionid='" + sl_mstr["sessionId"] + "'";
                        DataTable dtsession = db_order.SelectQueryForTransaction(getsessionexist);
                        int sess_rows = dtsession.Rows.Count;
                        if (sess_rows != 0)  // ALREADY SAVED CASE
                        {
                            // do nothing
                            string edit_orderdet_qry = "select sm_delivery_status,sm_id,cust_id,sm_netamount from tbl_sales_master where sm_sales_sessionid='" + sl_mstr["sessionId"] + "'";
                            DataTable ordr_deteails = db_order.SelectQueryForTransaction(edit_orderdet_qry);
                            string cr_order_status = Convert.ToString(ordr_deteails.Rows[0]["sm_delivery_status"]);
                            var can_sm_id = Convert.ToString(ordr_deteails.Rows[0]["sm_id"]);
                            var can_cust_id = Convert.ToString(ordr_deteails.Rows[0]["cust_id"]);
                            var can_sm_netamount = Convert.ToString(ordr_deteails.Rows[0]["sm_netamount"]);
                            if (cr_order_status.ToString() != "4")
                            {
                                if (sm_delivery_status == 4)
                                {
                                    StringBuilder cancel_sb_bulk_stkTrQry = new StringBuilder();
                                    StringBuilder cancel_sb_bulk_items = new StringBuilder();
                                    cancel_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");


                                    string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_type,itm_name from tbl_sales_items where sm_id='" + can_sm_id + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
                                    DataTable dt = db_order.SelectQueryForTransaction(qry);
                                    int numrows = dt.Rows.Count;

                                    Int32 oldqty = 0;
                                    Int32 oldfoc = 0;
                                    Int32 oldtotoalqty = 0;
                                    string olditbs = "";

                                    int i_can = 0;
                                    string can_itbsidString = "";
                                    string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                                    foreach (DataRow row in dt.Rows)
                                    {
                                        oldqty = Convert.ToInt32(row["si_qty"]);
                                        oldfoc = Convert.ToInt32(row["si_foc"]);
                                        oldtotoalqty = oldfoc + oldqty;
                                        olditbs = Convert.ToString(row["itbs_id"]);
                                        can_itbsidString = can_itbsidString + "," + olditbs;
                                        oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";

                                        // stock transaction
                                        cancel_sb_bulk_items.Append("('" + Convert.ToString(row["itbs_id"]) + "','" + ((int)Constants.ActionType.SALES) + "','" + can_sm_id + "','" + sl_mstr["sm_userid"] + "'");
                                        cancel_sb_bulk_items.Append(",'Order Cancelled! " + oldtotoalqty + " " + Convert.ToString(row["itm_name"]) + " in order #" + can_sm_id + "','" + oldtotoalqty + "'");
                                        cancel_sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(row["itbs_id"]) + "')");
                                        cancel_sb_bulk_items.Append(",'" + sync_date_time + "')" + (i_can != numrows - 1 ? "," : ";"));
                                        i_can = i_can + 1;
                                    }

                                    can_itbsidString = can_itbsidString.Trim().TrimStart(',');
                                    string cancelled_date = sl_mstr["sm_date"].ToString();
                                    oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + cancelled_date + "' WHERE itbs_id IN (" + can_itbsidString + ")";
                                    bool oldupstockresult = db_order.ExecuteQueryForTransaction(oldupstockQry);

                                    if (cancel_sb_bulk_items.ToString() != "")
                                    {
                                        cancel_sb_bulk_stkTrQry.Append(cancel_sb_bulk_items.ToString());
                                        db_order.ExecuteQueryForTransaction(cancel_sb_bulk_stkTrQry.ToString());
                                    }
                                    
                                    string update_sales_return = "UPDATE tbl_sales_master SET sm_delivery_status='4',sm_cancelled_id='" + sl_mstr["sm_userid"] + "',sm_cancelled_date='" + cancelled_date + "' where sm_id='" + can_sm_id + "'";
                                    bool sm_result = db_order.ExecuteQueryForTransaction(update_sales_return);

                                    //inserts to transaction table

                                    MySqlCommand cmdInsCr = new MySqlCommand();
                                    cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                                        " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                                        " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date, @is_reconciliation ,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                                    cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                                    cmdInsCr.Parameters.AddWithValue("@action_ref_id", can_sm_id);
                                    cmdInsCr.Parameters.AddWithValue("@partner_id", can_cust_id);
                                    cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                                    cmdInsCr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                                    cmdInsCr.Parameters.AddWithValue("@user_id", sl_mstr["sm_userid"]);
                                    cmdInsCr.Parameters.AddWithValue("@narration", "Cancellation of order: Ref.Id #" + can_sm_id + " worth " + can_sm_netamount);
                                    cmdInsCr.Parameters.AddWithValue("@cr", can_sm_netamount);
                                    cmdInsCr.Parameters.AddWithValue("@date", cancelled_date);
                                    cmdInsCr.Parameters.AddWithValue("@is_reconciliation","1");
                                    db_order.ExecuteQueryForTransaction(cmdInsCr);

                                    string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + cancelled_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + can_cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + can_cust_id + "";
                                    db_order.ExecuteQueryForTransaction(update_tbl_customer);

                                }
                            }
                            else
                            {

                            }


                        }
                        else // processing items
                        {
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

                            // ENTRY TO SALESMASTER - WITH AVAILABLE DATA

                            int branchStart = 0;
                            string getTimeZone = "SELECT branch_timezone,branch_orderPrefix,branch_orderSerial,branch_orderSuffix,branch_tax_method,branch_tax_inclusive from tbl_branch where branch_id='" + sl_mstr["branch"] + "'";
                            DataTable cTimeZone = db_order.SelectQueryForTransaction(getTimeZone);
                            if (cTimeZone != null)
                            {
                                branch_timezone = Convert.ToString(cTimeZone.Rows[0]["branch_timezone"]);
                                branchPrefix = Convert.ToString(cTimeZone.Rows[0]["branch_orderPrefix"]);
                                branchStart = Convert.ToInt32(cTimeZone.Rows[0]["branch_orderSerial"]);
                                branchSuffix = Convert.ToString(cTimeZone.Rows[0]["branch_orderSuffix"]);

                                branch_tax_method = Convert.ToInt32(cTimeZone.Rows[0]["branch_tax_method"]);
                                branch_tax_inclusive = Convert.ToInt32(cTimeZone.Rows[0]["branch_tax_inclusive"]);
                            }
                            else
                            {
                                // no time zone recieved
                            }

                            string suffixQry = "SELECT IFNULL(max(sm_serialNo),0) FROM tbl_sales_master where branch_id=" + sl_mstr["branch"] + "  and sm_prefix='" + branchPrefix + "' and sm_suffix='" + branchSuffix + "'";
                            int invoiceSerialNo = Convert.ToInt32(db_order.SelectScalarForTransaction(suffixQry));
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
                            string cust_id = "";
                            if (sl_mstr["is_new_registration"].ToString() == "1")
                            {
                                var cust_row = dt_cust_id.Select("cust_sessionid = '" + sl_mstr["cust_id"] + "'");
                                cust_id = Convert.ToString(cust_row[0]["cust_id"].ToString());
                            }
                            else
                            {
                                cust_id = Convert.ToString(sl_mstr["cust_id"]);
                            }

                            string igst_qry = "Select tbl_branch.branch_state_id from tbl_branch join tbl_customer on tbl_branch.branch_state_id=tbl_customer.cust_state where tbl_branch.branch_id='" + sl_mstr["branch"] + "' and tbl_customer.cust_id='" + cust_id + "'";
                            DataTable igst_dt = db_order.SelectQueryForTransaction(igst_qry);
                            int br_rows = igst_dt.Rows.Count;

                            if (br_rows == 0)
                            {
                                cust_state = 1;
                            }
                            else
                            {
                                cust_state = 0;
                            }

                            string insert_to_salsesQry = "";
                            if (sm_delivery_status == 2) // INVOICE NUMBER GENERATION IF ORDER IS DELIVERED
                            {
                                insert_to_salsesQry = "INSERT INTO tbl_sales_master(cust_id,branch_id,sm_userid,sm_date,sm_specialnote,sm_delivery_status,sm_processed_date,sm_delivered_id,sm_delivered_date,sm_latitude,sm_longitude,sm_order_type,sm_payment_type,branch_tax_method,branch_tax_inclusive,sm_sales_sessionid,sm_prefix,sm_serialNo,sm_suffix,sm_invoice_no,sm_price_class) VALUES ('" + cust_id + "','" + sl_mstr["branch"] + "','" + sync_data["user_id"] + "','" + sl_mstr["sm_date"] + "','" + sl_mstr["sm_specialnote"] + "','" + sm_delivery_status.ToString() + "','" + sl_mstr["sm_date"] + "','" + sync_data["user_id"] + "','" + sl_mstr["sm_date"] + "','" + sl_mstr["sm_latitude"] + "','" + sl_mstr["sm_longitude"] + "','" + sl_mstr["sm_order_type"] + "','" + sl_mstr["sm_payment_type"] + "','" + branch_tax_method.ToString() + "','" + branch_tax_inclusive.ToString() + "','" + sl_mstr["sessionId"] + "','" + branchPrefix + "'," + invoiceSerialNo + ",'" + branchSuffix + "',concat(sm_prefix,sm_serialNo,sm_suffix),'" + sl_mstr["sm_price_class"] + "');Select last_insert_id();";
                            }
                            else // INVOICE NUMBER GENERATION IF ORDER IS DELIVERED
                            {
                                insert_to_salsesQry = "INSERT INTO tbl_sales_master(cust_id,branch_id,sm_userid,sm_date,sm_specialnote,sm_delivery_status,sm_processed_date,sm_latitude,sm_longitude,sm_order_type,sm_payment_type,branch_tax_method,branch_tax_inclusive,sm_sales_sessionid,sm_price_class) VALUES ('" + cust_id + "','" + sl_mstr["branch"] + "','" + sync_data["user_id"] + "','" + sl_mstr["sm_date"] + "','" + sl_mstr["sm_specialnote"] + "','" + sm_delivery_status.ToString() + "','" + sl_mstr["sm_date"] + "','" + sl_mstr["sm_latitude"] + "','" + sl_mstr["sm_longitude"] + "','" + sl_mstr["sm_order_type"] + "','" + sl_mstr["sm_payment_type"] + "','" + branch_tax_method.ToString() + "','" + branch_tax_inclusive.ToString() + "','" + sl_mstr["sessionId"] + "','" + sl_mstr["sm_price_class"] + "');Select last_insert_id();";
                            }
                            var sm_id = db_order.SelectScalarForTransaction(insert_to_salsesQry);

                            // PROCESSING ITEMS
                            Int32 row_no = 0;
                            //start changed by deepika
                            string insert_to_sales_items = "INSERT INTO tbl_sales_items(sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_item_tax,si_item_cgst,si_item_sgst,si_item_igst,si_item_utgst,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type) VALUES ";
                            string itbsidString = "";
                            //string newitemItbsIdString = "";
                            foreach (DataRow items in order_data.Rows)
                            {
                                if (items["si_itm_type"] != "4")
                                {
                                    itbsidString = itbsidString + "," + items["itbs_id"];
                                }
                            }
                            itbsidString = itbsidString.Trim().TrimStart(',');

                            DataTable dt_itemDetail = new DataTable();
                            if (itbsidString != "")
                            {
                                string item_fetch_qry = "select itb.itbs_id,tax.tp_tax_percentage,tax.tp_cess,itb.itm_name,itb.itm_code,itb.itm_commision from tbl_itembranch_stock itb join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code where itb.itbs_id in (" + itbsidString + ")  ORDER BY FIELD(itb.itbs_id," + itbsidString + ")";
                                dt_itemDetail = db_order.SelectQueryForTransaction(item_fetch_qry);
                            }
                            int size = dt_itemDetail.Rows.Count;
                            int j = 0;

                            StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                            StringBuilder sb_bulk_items = new StringBuilder();

                            sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES ");


                            for (int i = 0; i < size; i++)
                            {// BASE VALUES

                                si_qty = Convert.ToDouble(order_data.Rows[i]["si_qty"]);
                                si_price = Convert.ToDouble(order_data.Rows[i]["si_price"]);
                                si_foc = Convert.ToDouble(order_data.Rows[i]["si_foc"]);
                                si_discount_rate = Convert.ToDouble(order_data.Rows[i]["si_discount_rate"]);
                                si_org_price = Convert.ToDouble(order_data.Rows[i]["si_org_price"]);
                                if (Convert.ToInt32(order_data.Rows[i]["si_itm_type"]) == 4)
                                {
                                    itm_commision = 6;
                                    si_item_tax = 0.00;
                                    si_item_cess = 0.00;
                                    itm_name = Convert.ToString(order_data.Rows[i]["itm_name"]);
                                    itm_code = "0000000000000";
                                }
                                else
                                {
                                    itm_commision = Convert.ToDouble(dt_itemDetail.Rows[j]["itm_commision"]);
                                    si_item_tax = Convert.ToDouble(dt_itemDetail.Rows[j]["tp_tax_percentage"]);
                                    si_item_cess = Convert.ToDouble(dt_itemDetail.Rows[j]["tp_cess"]);
                                    itm_name = Convert.ToString(dt_itemDetail.Rows[j]["itm_name"]);
                                    itm_code = Convert.ToString(dt_itemDetail.Rows[j]["itm_code"]);
                                    j = j + 1;
                                }
                                // CALCULATIONS
                                if (branch_tax_method == 0) // no tax
                                {
                                    realtotal = si_price * si_qty; // price without discount
                                    realtotal = Math.Round(realtotal, 2);
                                    discount_amt = ((realtotal * si_discount_rate) / 100);
                                    nettotal = realtotal - ((realtotal * si_discount_rate) / 100);
                                    tax_included_nettotal = Math.Round(nettotal, 2);
                                    commisionAmount = ((nettotal * itm_commision) / 100);
                                    commisionAmount = Math.Round(commisionAmount, 2);
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
                                si_total = Math.Round(realtotal,precision);
                                si_discount_amount = Math.Round(discount_amt,precision);
                                si_net_amount = Math.Round(tax_included_nettotal,precision);
                                itm_commisionamt = Math.Round(commisionAmount,precision);
                                si_tax_amount = Math.Round(tax_amount,precision);

                                // INSERTING INTO TBL_SALES_ITEMS

                                insert_to_sales_items += " (" + "'" + sm_id + "','" + row_no + "', '" + order_data.Rows[i]["itbs_id"] + "', '" + itm_code + "', '" + itm_name + "', '0', '" + si_org_price + "', '" + order_data.Rows[i]["si_price"] + "', '" + si_qty + "', '" + si_total + "', '" + si_discount_rate + "', '" + si_discount_amount + "', '" + si_net_amount + "', '" + si_foc + "', '" + order_data.Rows[i]["si_approval_status"] + "', '" + itm_commision + "', '" + itm_commisionamt + "', '0', '0','" + order_data.Rows[i]["si_itm_type"] + "', '" + si_item_tax + "', '" + si_item_cgst + "', '" + si_item_sgst + "', '" + si_item_igst + "', '" + si_item_utgst + "', '" + si_item_cess + "', '" + (si_net_amount - tax_amount) + "', '" + tax_amount + "','" + order_data.Rows[i]["itm_type"] + "'),";
                                row_no++;

                                // calculation for sm - values

                                sm_tax_excluded_amt = sm_tax_excluded_amt + (si_net_amount - si_tax_amount);
                                sm_discount_amount = sm_discount_amount + si_discount_amount;
                                sm_netamount = sm_netamount + si_net_amount;
                                sm_tax_amount = sm_tax_amount + si_tax_amount;
                                sm_total = sm_total + si_total;

                                
                                // HANDLE STOCK
                                if (Convert.ToString(order_data.Rows[i]["si_itm_type"]) != "1" && Convert.ToString(order_data.Rows[i]["si_itm_type"]) != "3" && Convert.ToString(order_data.Rows[i]["si_itm_type"]) != "4")
                                {
                                    if (Convert.ToString(order_data.Rows[i]["itm_type"]) == "1")
                                    {
                                        Int32 item_total_qty = Convert.ToInt32(si_foc) + Convert.ToInt32(si_qty);
                                        string upstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=(itbs_stock - " + item_total_qty + "),itm_last_update_date='" + sync_date_time + "' where itbs_id='" + order_data.Rows[i]["itbs_id"] + "'";
                                        db_order.ExecuteQueryForTransaction(upstockQry);

                                        sb_bulk_items.Append("('" + order_data.Rows[i]["itbs_id"] + "','" + ((int)Constants.ActionType.SALES) + "','" + sm_id + "','" + sl_mstr["sm_userid"] + "'");
                                        sb_bulk_items.Append(",'Sold " + item_total_qty + " " + itm_name + " in order #" + sm_id + "','" + item_total_qty + "'");
                                        sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + order_data.Rows[i]["itbs_id"] + "')");
                                        sb_bulk_items.Append(",'" + sl_mstr["sm_date"] + "')" + (i != size - 1 ? "," : ";"));
                                    }
                                }

                                



                            }// ITEM LOOP ENDS

                            insert_to_sales_items = insert_to_sales_items.Remove(insert_to_sales_items.Trim().Length - 1);
                            db_order.ExecuteQueryForTransaction(insert_to_sales_items);

                            if (sb_bulk_items.ToString() != "")
                            {

                                sb_bulk_stkTrQry.Append(sb_bulk_items.ToString());
                                db_order.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
                            }
                            
                            // calculating discount rate
                            double divider = sm_tax_excluded_amt + sm_discount_amount;
                            double divident = sm_discount_amount * 100;
                            sm_discount_rate = divident / divider;
                            sm_discount_rate = Math.Round(sm_discount_rate, precision);

                            double sm_paid = 0;

                            if (Convert.ToDouble(sl_mstr["sm_cash_amt"]) != 0) // if paid with cash
                            {
                                sm_paid += Convert.ToDouble(sl_mstr["sm_cash_amt"]);
                            }
                            if (Convert.ToDouble(sl_mstr["sm_chq_amt"]) != 0)
                            {
                                sm_paid += Convert.ToDouble(sl_mstr["sm_chq_amt"]);
                            }
                            if (Convert.ToDouble(sl_mstr["sm_wallet_amt"]) != 0)
                            {
                                sm_paid += Convert.ToDouble(sl_mstr["sm_wallet_amt"]);
                            }

                            sm_paid = Math.Round(sm_paid, precision);
                            sm_tax_excluded_amt = Math.Round(sm_tax_excluded_amt, precision);
                            sm_balance = sm_netamount - sm_paid;

                            //inserts to transaction table
                            //inserting order debit entry
                            MySqlCommand cmdInsDr = new MySqlCommand();
                            cmdInsDr.CommandText = "INSERT INTO `tbl_transactions` " +
                                " ( `session_id`, `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`,`user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                                " select @session_id, @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                            cmdInsDr.Parameters.AddWithValue("@session_id", sl_mstr["sessionId"]);
                            cmdInsDr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                            cmdInsDr.Parameters.AddWithValue("@action_ref_id", sm_id);
                            cmdInsDr.Parameters.AddWithValue("@partner_id", cust_id);
                            cmdInsDr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                            cmdInsDr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                            cmdInsDr.Parameters.AddWithValue("@user_id", sl_mstr["sm_userid"]);
                            cmdInsDr.Parameters.AddWithValue("@narration", "Order #" + sm_id + " is placed with net amount " + sm_netamount);
                            cmdInsDr.Parameters.AddWithValue("@dr", sm_netamount);
                            cmdInsDr.Parameters.AddWithValue("@date", sl_mstr["sm_date"]);
                            db_order.ExecuteQueryForTransaction(cmdInsDr);

                            //inserting order - when amount paid from customer wallet
                            if (Convert.ToDouble(sl_mstr["sm_wallet_amt"]) != 0)
                            {

                                MySqlCommand cmdInsWallet = new MySqlCommand();
                                cmdInsWallet.CommandText = "INSERT INTO `tbl_transactions` " +
                                    " ( `session_id`, `action_type`,  `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                                    " select @session_id, @action_type, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                                cmdInsWallet.Parameters.AddWithValue("@session_id", sl_mstr["sessionId"]);
                                cmdInsWallet.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.WITHDRAWAL);
                                cmdInsWallet.Parameters.AddWithValue("@partner_id", cust_id);
                                cmdInsWallet.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                                cmdInsWallet.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                                cmdInsWallet.Parameters.AddWithValue("@user_id", sl_mstr["sm_userid"]);
                                cmdInsWallet.Parameters.AddWithValue("@narration", "Withdrawn " + sl_mstr["sm_wallet_amt"] + " from Wallet for clearing the Order #" + sm_id);
                                cmdInsWallet.Parameters.AddWithValue("@dr", sl_mstr["sm_wallet_amt"]);
                                cmdInsWallet.Parameters.AddWithValue("@date", sl_mstr["sm_date"]);
                                db_order.ExecuteQueryForTransaction(cmdInsWallet);
                            }

                            //check is cash paid
                            if (sm_paid > 0)
                            {
                                //inserting order credit entry
                                MySqlCommand cmdInsCr = new MySqlCommand();
                                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                                    " ( `session_id`, `action_type`, `action_ref_id`, `partner_id`,`partner_type`, `branch_id`,`user_id`, `narration`,cash_amt,wallet_amt " +
                                    (Convert.ToDouble(sl_mstr["sm_chq_amt"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                                    ", `cr`, `date`,`closing_balance`)" +
                                    " select @session_id, @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt,@wallet_amt" +
                                    (Convert.ToDouble(sl_mstr["sm_chq_amt"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                                    ", @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                                cmdInsCr.Parameters.AddWithValue("@session_id", sl_mstr["sessionId"]);
                                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                                cmdInsCr.Parameters.AddWithValue("@action_ref_id", sm_id);
                                cmdInsCr.Parameters.AddWithValue("@partner_id", cust_id);
                                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                                cmdInsCr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                                cmdInsCr.Parameters.AddWithValue("@user_id", sl_mstr["sm_userid"]);
                                cmdInsCr.Parameters.AddWithValue("@narration", "Paid " + sm_paid + " for Order #" + sm_id);
                                cmdInsCr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(sl_mstr["sm_cash_amt"]));
                                cmdInsCr.Parameters.AddWithValue("@wallet_amt", Convert.ToDecimal(sl_mstr["sm_wallet_amt"]));
                                //cmdInsDr.Parameters.AddWithValue("@card_amt", neworder["sessionId"]);
                                //cmdInsDr.Parameters.AddWithValue("@card_no", neworder["sessionId"]);
                                if (Convert.ToDouble(sl_mstr["sm_chq_amt"]) != 0)
                                {
                                    cmdInsCr.Parameters.AddWithValue("@cheque_amt", sl_mstr["sm_chq_amt"]);
                                    cmdInsCr.Parameters.AddWithValue("@cheque_no", sl_mstr["sm_chq_no"]);
                                    cmdInsCr.Parameters.AddWithValue("@cheque_date", sl_mstr["sm_chq_date"]);
                                    cmdInsCr.Parameters.AddWithValue("@cheque_bank", sl_mstr["sm_bank"]);
                                }

                                cmdInsCr.Parameters.AddWithValue("@cr", sm_paid);
                                cmdInsCr.Parameters.AddWithValue("@date", sl_mstr["sm_date"]);
                                db_order.ExecuteQueryForTransaction(cmdInsCr);
                            }

                            // UPDATING SALES MASTER
                            string update_salesmaster_qry = "UPDATE tbl_sales_master SET sm_total='" + sm_total + "',sm_discount_rate='" + sm_discount_rate + "',sm_discount_amount='" + sm_discount_amount + "',sm_netamount='" + sm_netamount + "',sm_tax_excluded_amt='" + sm_tax_excluded_amt + "',sm_tax_amount='" + sm_tax_amount + "',sm_refno='" + sm_id + "' WHERE sm_id='" + sm_id + "'";
                            bool update_sales_result = db_order.ExecuteQueryForTransaction(update_salesmaster_qry);

                            // UPDATING CUSTOMER DETAILS

                            string update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_last_updated_date='"+sync_date_time+"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + cust_id;
                            db_order.ExecuteQueryForTransaction(update_tbl_cust_branch_amounts);

                            if (need_to_cancel == 1)
                            {

                                string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_type from tbl_sales_items where sm_id='" + sm_id + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
                                DataTable dt = db_order.SelectQueryForTransaction(qry);
                                int numrows = dt.Rows.Count;

                                Int32 oldqty = 0;
                                Int32 oldfoc = 0;
                                Int32 oldtotoalqty = 0;
                                string olditbs = "";

                                StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                                StringBuilder can_sb_bulk_items = new StringBuilder();
                                can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");

                                string can_itbsidString = "";
                                string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                                int i = 0;
                                foreach (DataRow row in dt.Rows)
                                {
                                    oldqty = Convert.ToInt32(row["si_qty"]);
                                    oldfoc = Convert.ToInt32(row["si_foc"]);
                                    oldtotoalqty = oldfoc + oldqty;
                                    olditbs = Convert.ToString(row["itbs_id"]);
                                    can_itbsidString = can_itbsidString + "," + olditbs;
                                    oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock + " + oldtotoalqty + "";

                                    // stock transaction
                                    can_sb_bulk_items.Append("('" + Convert.ToString(row["itbs_id"]) + "','" + ((int)Constants.ActionType.SALES) + "','" + sm_id + "','" + sl_mstr["sm_userid"] + "'");
                                    can_sb_bulk_items.Append(",'Order Cancelled! " + oldtotoalqty + " " + itm_name + " in order #" + sm_id + "','" + oldtotoalqty + "'");
                                    can_sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(row["itbs_id"]) + "')");
                                    can_sb_bulk_items.Append(",'" + sl_mstr["sm_date"] + "')" + (i != numrows - 1 ? "," : ";"));
                                    i = i + 1;
                                }

                                can_itbsidString = can_itbsidString.Trim().TrimStart(',');
                                oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + sync_date_time + "' WHERE itbs_id IN (" + can_itbsidString + ")";
                                bool oldupstockresult = db_order.ExecuteQueryForTransaction(oldupstockQry);

                                if (can_sb_bulk_items.ToString() != "")
                                {
                                    can_sb_bulk_stkTrQry.Append(can_sb_bulk_items.ToString());
                                    db_order.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                                }

                                string cancelled_date = sl_mstr["sm_date"].ToString();
                                string update_sales_return = "UPDATE tbl_sales_master SET sm_delivery_status='4',sm_cancelled_id='" + sl_mstr["sm_userid"] + "',sm_cancelled_date='" + cancelled_date + "' where sm_id='" + sm_id + "'";
                                bool sm_result = db_order.ExecuteQueryForTransaction(update_sales_return);

                                //inserts to transaction table

                                MySqlCommand cmdInsCr = new MySqlCommand();
                                cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                                    " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                                    " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                                cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                                cmdInsCr.Parameters.AddWithValue("@action_ref_id", sm_id);
                                cmdInsCr.Parameters.AddWithValue("@partner_id", cust_id);
                                cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                                cmdInsCr.Parameters.AddWithValue("@branch_id", sl_mstr["branch"]);
                                cmdInsCr.Parameters.AddWithValue("@user_id", sl_mstr["sm_userid"]);
                                cmdInsCr.Parameters.AddWithValue("@narration", "Cancellation of order: Ref.Id #" + sm_id + " worth " + sm_netamount);
                                cmdInsCr.Parameters.AddWithValue("@cr", sm_netamount);
                                cmdInsCr.Parameters.AddWithValue("@date", cancelled_date);
                                cmdInsCr.Parameters.AddWithValue("@is_reconciliation","1");
                                db_order.ExecuteQueryForTransaction(cmdInsCr);

                                string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + cancelled_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + cust_id + "";
                                db_order.ExecuteQueryForTransaction(update_tbl_customer);
                            }

                        }

                        
                    
                }// foreach order ends

                

                db_order.CommitTransaction();

            }
        }
        catch (Exception ex_order)
        {
            try
            {
                db_order.RollBackTransaction();
                jsonResponse = "FAILED";
                LogClass log_cust = new LogClass("new_order_error");
                log_cust.write(ex_order);

                string JSONString_error = string.Empty;
                JSONString_error = JsonConvert.SerializeObject(sync_data);
                log_cust.write_all_data(JSONString_error);

                return jsonResponse;
            }
            catch (Exception ex_roll_order)
            {
                jsonResponse = "FAILED";
                LogClass log = new LogClass("order_roll_error");
                log.write(ex_roll_order);
                return jsonResponse;
            }
        }

        #endregion
        //***********************************************************************************************************************
        // selecting items back
        //***********************************************************************************************************************
        #region

        try
        {
            string last_device_db_updated = sync_data["last_device_db_updated"].ToString();

            try
            {
                mySqlConnection db_select = new mySqlConnection();
                
                // fetching setings
                var seting_qry = "SELECT ss_price_change,ss_discount_change,ss_foc_change,ss_class_change,ss_max_period_credit,ss_new_registration,ss_sales_return,ss_due_amount,ss_payment_type,ss_new_item,ss_location_on_order,ss_validation_email,ss_phone,ss_direct_delivery,ss_currency,ss_decimal_accuracy,ss_multidevice_block,ss_van_based_invoice_number,ss_default_time_zone,ss_default_max_period,ss_default_max_credit,ss_reg_id_required,ss_trn_gst_required,DATE_FORMAT(ss_last_updated_date, '%Y-%m-%d %H:%i:%s') as ss_last_updated_date FROM tbl_system_settings where ss_last_updated_date>'" + last_device_db_updated + "'";
                DataTable dt_system_settings = db_select.SelectQuery(seting_qry);


                // - itm_last_update_date
                var item_fetch_query = @"select itm.itm_type,brd.brand_name,cat.cat_name,itb.branch_id,tax.tp_tax_percentage,tax.tp_cess,itb.itbs_id,itb.itm_id,itb.itm_brand_id,itb.itm_category_id,itb.itm_name,itb.itbs_stock,itb.itm_code,itb.itm_mrp,itb.itm_class_one,itb.itm_class_two,itb.itm_class_three,itb.itm_commision,itb.itm_rating 
                                     from tbl_itembranch_stock itb 
                                     join tbl_tax_profile tax on itb.tp_tax_code=tax.tp_tax_code 
                                     join tbl_user_branches tub on tub.branch_id=itb.branch_id 
                                     join tbl_item_master itm on itm.itm_id=itb.itm_id 
                                     join tbl_item_brand brd on brd.brand_id=itm.itm_brand_id 
                                     join tbl_item_category cat on cat.cat_id=itm.itm_category_id 
                                     and tub.user_id='" + sync_data["user_id"] + "' and itb.itm_code!='1234567891234' and itbs_available=1 and itb.itm_last_update_date>'" + last_device_db_updated + "' order by itb.branch_id asc";
                DataTable dt_item_branchstock = db_select.SelectQuery(item_fetch_query);

                //var items_to_delete = "select itb.itbs_id from tbl_itembranch_stock where itb.itm_last_update_date>'" + last_device_db_updated + "'";


                // 4. fetching branches and tax details - branch_last_updated_date

                var branch_query = "select br.branch_id,br.branch_name,br.branch_timezone,br.branch_tax_method,br.branch_tax_inclusive from tbl_branch br join tbl_user_branches tub on tub.branch_id=br.branch_id and tub.user_id='" + sync_data["user_id"] + "' and br.branch_last_updated_date>'" + last_device_db_updated + "' order by br.branch_name asc";
                DataTable dt_branch = db_select.SelectQuery(branch_query);

                // 5. fetching customer states , district , locations - state_last_updated_date
                var cust_location_query = @"select loc.location_id,loc.location_name,tst.state_id,tst.state_name,tst.country_id from tbl_location loc join tbl_district dist on loc.dist_id=dist.dis_id 
                                       join tbl_state tst on dist.state_id=tst.state_id join tbl_user_locations tul on tul.location_id=loc.location_id and tul.user_id='" + sync_data["user_id"] + "' and loc.loc_last_updated_date>'" + last_device_db_updated + "' group by loc.location_id";
                DataTable dt_locations = db_select.SelectQuery(cust_location_query);

                

                // 6. fetching customers - cust_last_updated_date

                //var cust_to_delete = "select cu.cust_id from tbl_customer cu where cu.cust_last_updated_date>'" + last_device_db_updated + "'";

                var customer_query = @"select cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,cu.cust_state,cu.cust_country,cu.cust_phone, 
                                  cu.cust_phone1,cu.cust_email,cu.cust_amount,DATE_FORMAT(cu.cust_joined_date, '%Y-%m-%d %h:%i %p') as cust_joined_date,cu.cust_latitude,cu.cust_longitude,cu.cust_type,cu.cust_note,cu.max_creditamt,cu.max_creditperiod,cu.new_custtype,cu.new_creditamt,cu.new_creditperiod,cu.cust_image,cu.cust_status,DATE_FORMAT(cu.cust_followup_date, '%Y-%m-%d') as cust_followup_date,cu.cust_reg_id,cu.location_id,cu.cust_cat_id,cu.cust_tax_reg_id from tbl_customer cu 
                                  join tbl_user_locations tul on tul.location_id=cu.location_id and tul.user_id='" + sync_data["user_id"] + "' WHERE cu.cust_status!=2  and cu.cust_last_updated_date>'" + last_device_db_updated + "' group by cu.cust_id";
                DataTable dt_customers = db_select.SelectQuery(customer_query);

                //7. getting customer types - cat_last_updated_date

                var customer_category = "select cat.cust_cat_id,cat.cust_cat_name from tbl_customer_category cat and cat.cat_last_updated_date>'" + last_device_db_updated + "'";
                DataTable dt_customer_category = db_select.SelectQuery(customer_category);

                var dt_item_branchstockData = JsonConvert.SerializeObject(dt_item_branchstock, Formatting.Indented); //
                var dt_branchData = JsonConvert.SerializeObject(dt_branch, Formatting.Indented); //
                var dt_locationsData = JsonConvert.SerializeObject(dt_locations, Formatting.Indented); //
                var dt_customersData = JsonConvert.SerializeObject(dt_customers, Formatting.Indented);
                var dt_customer_catData = JsonConvert.SerializeObject(dt_customer_category, Formatting.Indented);
                var settings_data = JsonConvert.SerializeObject(dt_system_settings, Formatting.Indented);

                jsonResponse = "{\"settings_data\":" + settings_data + ",\"dt_item_branchstockData\":" + dt_item_branchstockData + ",\"dt_branchData\":" + dt_branchData + ",\"dt_locationsData\":" + dt_locationsData + ",\"dt_customersData\":" + dt_customersData + ",\"dt_customer_catData\":" + dt_customer_catData + ",\"sync_time\":" + JsonConvert.SerializeObject(sync_date_time, Formatting.Indented) + "}";
                Send_Push_Notification("COMMON", sync_data["user_id"].ToString());
            }
            catch (Exception ex)
            {
                var log = new LogClass("sync_read_error");
                log.write(ex);

                string JSONString_error = string.Empty;
                JSONString_error = JsonConvert.SerializeObject(sync_data);
                log.write_all_data(JSONString_error);

                jsonResponse = "ERROR";
                return jsonResponse;

            }

        #endregion

        }
        catch (Exception ex)
        {
            try // IF TRANSACTION FAILES
            {
                jsonResponse = "FAILED";
                LogClass log = new LogClass("sync_read_error");
                log.write(ex);
                string JSONString_error = string.Empty;
                JSONString_error = JsonConvert.SerializeObject(sync_data);
                //log.write_all_data(JSONString_error);
                return jsonResponse;
            }
            catch
            {
                //jsonResponse = "FAILED";
                //LogClass log = new LogClass("write_error");
                //log.write(ex);
                //return jsonResponse;
            }
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
                cmdInsCr.Parameters.AddWithValue("@is_reconciliation","1");
                db.ExecuteQueryForTransaction(cmdInsCr);

                string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + cancelled_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + dt_sm.Rows[0]["cust_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                db.ExecuteQueryForTransaction(update_tbl_customer);
                result = "SUCCESS";
                db.CommitTransaction();
                Send_Push_Notification("CANCEL", sm_id);

            }
        }
        catch(Exception ex)
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
            // checking the current status        
            string check_status_qry = "SELECT sm.sm_delivery_status,sm.cust_id,sm.sm_netamount,cu.cust_amount,sm.branch_id,sm_invoice_no FROM tbl_sales_master sm JOIN tbl_customer cu ON sm.cust_id=cu.cust_id WHERE sm.sm_id='" + order["sm_id"] + "'";
            DataTable dt_sm = db.SelectQuery(check_status_qry);

            if (dt_sm.Rows[0]["sm_delivery_status"].ToString() == order["order_status"].ToString())
            {
                result = "SUCCESS";
                result = "{\"result\":\"" + result + "\",\"cust_amount\":" + dt_sm.Rows[0]["cust_amount"].ToString() + "}";
                return result;
            }
            else
            {
                // previous status is cancelled & changing to new order or delivered
                // Increase Stock - insert to transaction - change status - update cust_amount with date
                if (dt_sm.Rows[0]["sm_delivery_status"].ToString() == "4")
                {
                    db.BeginTransaction();
                    string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_type,itm_name from tbl_sales_items where sm_id='" + order["sm_id"] + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
                    DataTable dt = db.SelectQueryForTransaction(qry);
                    int numrows = dt.Rows.Count;
                    if (numrows > 0)
                    {
                        Int32 oldqty = 0;
                        Int32 oldfoc = 0;
                        Int32 oldtotoalqty = 0;
                        string olditbs = "";

                        StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                        StringBuilder can_sb_bulk_items = new StringBuilder();
                        can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES ");

                        int i_c = 0;

                        string itbsidString = "";
                        string oldupstockQry = "UPDATE tbl_itembranch_stock SET itbs_stock=CASE itbs_id";
                        foreach (DataRow row in dt.Rows)
                        {
                            oldqty = Convert.ToInt32(row["si_qty"]);
                            oldfoc = Convert.ToInt32(row["si_foc"]);
                            oldtotoalqty = oldfoc + oldqty;
                            olditbs = Convert.ToString(row["itbs_id"]);
                            itbsidString = itbsidString + "," + olditbs;
                            oldupstockQry += " WHEN '" + olditbs + "' THEN itbs_stock - " + oldtotoalqty + "";

                            // stock transaction
                            can_sb_bulk_items.Append("('" + Convert.ToString(row["itbs_id"]) + "','" + ((int)Constants.ActionType.SALES) + "','" + order["sm_id"] + "','" + order["user_id"] + "'");
                            can_sb_bulk_items.Append(",'Order status changed from Cancelled. " + oldtotoalqty + " " + Convert.ToString(row["itm_name"]) + " in order #" + order["sm_id"] + "','" + oldtotoalqty + "'");
                            can_sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(row["itbs_id"]) + "')");
                            can_sb_bulk_items.Append(",'" + action_date + "')" + (i_c != numrows - 1 ? "," : ";"));
                            i_c = i_c + 1;

                        }

                        itbsidString = itbsidString.Trim().TrimStart(',');
                        oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + action_date + "' WHERE itbs_id IN (" + itbsidString + ")";
                        db.ExecuteQueryForTransaction(oldupstockQry);

                        if (can_sb_bulk_items.ToString() != "")
                        {
                            can_sb_bulk_stkTrQry.Append(can_sb_bulk_items.ToString());
                            db.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                        }

                    }

                    string update_sales_mstr = "";
                    string status_string = "";
                    if (order["order_status"].ToString() == "2")
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='2',sm_delivered_id='" + order["user_id"] + "',sm_delivered_date='" + action_date + "',sm_cancelled_id='0',sm_cancelled_date='0' where sm_id='" + order["sm_id"] + "'";
                        status_string = "Status change from Cancelled to Delivered.";
                        
                    }
                    else if (order["order_status"].ToString() == "0")
                    {
                        update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='0',sm_delivered_id='0',sm_delivered_date='0',sm_cancelled_id='0',sm_cancelled_date='0',sm_processed_id='0',sm_packed_id='0',sm_packed_date='0',sm_packed='0' where sm_id='" + order["sm_id"] + "'";
                        status_string = "Status change from Cancelled to New order";
                        
                    }
                    else
                    {

                    }
                    db.ExecuteQueryForTransaction(update_sales_mstr);

                    //inserts to transaction table
                    MySqlCommand cmdInsCr = new MySqlCommand();
                    cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                        " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `dr`,`date`,`is_reconciliation`,`closing_balance`)" +
                        " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                    cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                    cmdInsCr.Parameters.AddWithValue("@action_ref_id", order["sm_id"]);
                    cmdInsCr.Parameters.AddWithValue("@partner_id", dt_sm.Rows[0]["cust_id"].ToString());
                    cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                    cmdInsCr.Parameters.AddWithValue("@branch_id", dt_sm.Rows[0]["branch_id"].ToString());
                    cmdInsCr.Parameters.AddWithValue("@user_id", order["user_id"]);
                    cmdInsCr.Parameters.AddWithValue("@narration", status_string);
                    cmdInsCr.Parameters.AddWithValue("@dr", dt_sm.Rows[0]["sm_netamount"].ToString());
                    cmdInsCr.Parameters.AddWithValue("@date", action_date);
                    cmdInsCr.Parameters.AddWithValue("@is_reconciliation", "1");
                    db.ExecuteQueryForTransaction(cmdInsCr);
                             
                    string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + action_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + dt_sm.Rows[0]["cust_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + ";SELECT cust_amount FROM tbl_customer WHERE cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                    string cust_amount = db.SelectScalarForTransaction(update_tbl_customer);
                    result = "SUCCESS";
                    result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                    db.CommitTransaction();
                }
                else
                {
                    // ORDER CANCELLATION
                    if (order["order_status"].ToString() == "4") {

                        db.BeginTransaction();
                        string qry = "select itbs_id,si_qty,si_foc,si_itm_type,itm_type,itm_name from tbl_sales_items where sm_id='" + order["sm_id"] + "' and ( si_itm_type='0' or si_itm_type='2') and itm_type='1'";
                        DataTable dt = db.SelectQueryForTransaction(qry);
                        int numrows = dt.Rows.Count;
                        if (numrows > 0)
                        {
                            Int32 oldqty = 0;
                            Int32 oldfoc = 0;
                            Int32 oldtotoalqty = 0;
                            string olditbs = "";

                            StringBuilder can_sb_bulk_stkTrQry = new StringBuilder();
                            StringBuilder can_sb_bulk_items = new StringBuilder();
                            can_sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES ");

                            int i_c = 0;

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

                                // stock transaction
                                can_sb_bulk_items.Append("('" + Convert.ToString(row["itbs_id"]) + "','" + ((int)Constants.ActionType.SALES) + "','" + order["sm_id"] + "','" + order["user_id"] + "'");
                                can_sb_bulk_items.Append(",'Order cancelled! " + oldtotoalqty + " " + Convert.ToString(row["itm_name"]) + " in order #" + order["sm_id"] + "','" + oldtotoalqty + "'");
                                can_sb_bulk_items.Append(",(select itbs_stock from tbl_itembranch_stock where itbs_id='" + Convert.ToString(row["itbs_id"]) + "')");
                                can_sb_bulk_items.Append(",'" + action_date + "')" + (i_c != numrows - 1 ? "," : ";"));
                                i_c = i_c + 1;
                            }

                            itbsidString = itbsidString.Trim().TrimStart(',');
                            oldupstockQry += " ELSE itbs_stock END ,itm_last_update_date='" + action_date + "' WHERE itbs_id IN (" + itbsidString + ")";
                            db.ExecuteQueryForTransaction(oldupstockQry);

                            if (can_sb_bulk_items.ToString() != "")
                            {
                                can_sb_bulk_stkTrQry.Append(can_sb_bulk_items.ToString());
                                db.ExecuteQueryForTransaction(can_sb_bulk_stkTrQry.ToString());
                            }

                        }

                        string update_sales_mstr = "";
                        string status_string = "Cancellation of order #" + order["sm_id"].ToString() + " worth " + dt_sm.Rows[0]["sm_netamount"].ToString() + "";

                        update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='4',sm_cancelled_id='" + order["user_id"] + "',sm_cancelled_date='" + action_date + "',sm_packed='0',sm_packed_id='0',sm_packed_date='0',sm_delivered_id='0',sm_delivered_date='0',sm_processed_id='0',sm_delivery_vehicle_id='0',sm_vehicle_no='0' where sm_id='" + order["sm_id"] + "'";                        
                        db.ExecuteQueryForTransaction(update_sales_mstr);

                        //inserts to transaction table
                        MySqlCommand cmdInsCr = new MySqlCommand();
                        cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                            " (`action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`, `cr`,  `date`,`is_reconciliation`,`closing_balance`)" +
                            " select @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration, @cr, @date,@is_reconciliation,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                        cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                        cmdInsCr.Parameters.AddWithValue("@action_ref_id", order["sm_id"]);
                        cmdInsCr.Parameters.AddWithValue("@partner_id", dt_sm.Rows[0]["cust_id"].ToString());
                        cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                        cmdInsCr.Parameters.AddWithValue("@branch_id", dt_sm.Rows[0]["branch_id"].ToString());
                        cmdInsCr.Parameters.AddWithValue("@user_id", order["user_id"]);
                        cmdInsCr.Parameters.AddWithValue("@narration", status_string);
                        cmdInsCr.Parameters.AddWithValue("@cr", dt_sm.Rows[0]["sm_netamount"].ToString());
                        cmdInsCr.Parameters.AddWithValue("@date", action_date);
                        cmdInsCr.Parameters.AddWithValue("@is_reconciliation","1");
                        db.ExecuteQueryForTransaction(cmdInsCr);

                        string update_tbl_customer = "UPDATE tbl_customer SET cust_last_updated_date='" + action_date + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + dt_sm.Rows[0]["cust_id"].ToString() + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + ";SELECT cust_amount FROM tbl_customer WHERE cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                        string cust_amount = db.SelectScalarForTransaction(update_tbl_customer);
                        result = "SUCCESS";
                        result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                        
                        db.CommitTransaction();
                        Send_Push_Notification("CANCEL", order["sm_id"]);

                    }
                    else if (order["order_status"].ToString() == "2")
                    {
                        string update_sales_mstr = "";

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

                            update_sales_mstr = "UPDATE tbl_sales_master SET sm_prefix='" + branchPrefix + "',sm_serialNo=" + invoiceSerialNo + ",sm_suffix='" + branchSuffix + "',sm_invoice_no=concat(sm_prefix,sm_serialNo,sm_suffix),sm_delivery_status='2',sm_delivered_id='" + order["user_id"] + "',sm_delivered_date='" + action_date + "' where sm_id='" + order["sm_id"] + "'";

                        }
                        else
                        {

                            update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='2',sm_delivered_id='" + order["user_id"] + "',sm_delivered_date='" + action_date + "' where sm_id='" + order["sm_id"] + "'";
                        }

                        
                        db.ExecuteQueryForTransaction(update_sales_mstr);
                        string update_tbl_customer = "SELECT cust_amount FROM tbl_customer WHERE cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                        string cust_amount = db.SelectScalarForTransaction(update_tbl_customer);
                        result = "SUCCESS";
                        result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                        
                    }
                    else if (order["order_status"].ToString() == "1")
                    {
                        string update_sales_mstr = "";
                        update_sales_mstr = "UPDATE tbl_sales_master SET sm_delivery_status='1',sm_delivered_id='0',sm_delivered_date='0' where sm_id='" + order["sm_id"] + "'";
                        db.ExecuteQueryForTransaction(update_sales_mstr);
                        string update_tbl_customer = "SELECT cust_amount FROM tbl_customer WHERE cust_id=" + dt_sm.Rows[0]["cust_id"].ToString() + "";
                        string cust_amount = db.SelectScalarForTransaction(update_tbl_customer);
                        result = "SUCCESS";
                        result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                    }
                    else
                    {

                    }

                }
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
                    can_sb_bulk_items.Append(",'ORDER EDIT(increase stock) " + oldtotoalqty + " " + Convert.ToString(row["itm_name"]) + " in order #" + editedorder["sm_id"] + "','" + oldtotoalqty + "'");
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

                si_total = Math.Round(realtotal,precision);
                si_discount_amount = Math.Round(discount_amt,precision);
                si_net_amount = Math.Round(tax_included_nettotal,precision);
                itm_commisionamt = Math.Round(commisionAmount,precision);
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
                        sb_bulk_items.Append(",'ORDER EDIT(decrease stock) " + item_total_qty + " " + itm_name + " in order #" + editedorder["sm_id"] + "','" + item_total_qty + "'");
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

            string update_tbl_cust_amounts = "UPDATE tbl_customer SET cust_last_updated_date='"+ edit_time +"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + cust_id + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + cust_id + "; SELECT cust_amount from tbl_customer WHERE cust_id='" + cust_id + "'";
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
    public static string fetch_customer_sales_details_for_payment(string sm_id)
    {
        string result = "";
        mySqlConnection db = new mySqlConnection();
        string query = @"SELECT sm.sm_id,sm.sm_order_type,sm.sm_payment_type,cu.cust_name,cu.cust_amount,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed 
                         FROM tbl_sales_master sm 
                         INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id 
                         INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) 
                         WHERE sm.sm_id='" +sm_id+"' GROUP BY sm.sm_id";
        DataTable dt = db.SelectQuery(query);
        var pay_data = JsonConvert.SerializeObject(dt, Formatting.Indented);
       
        string wallet_qry = @"select cust_amount as outstanding_amt,(select sum(bill_bal) from (select (sum(dr)-sum(cr)) bill_bal from tbl_transactions where `action_type`=1 and `partner_id`=(select cust_id from tbl_sales_master where sm_id='" + sm_id + "') group by action_ref_id,action_type having sum(dr)>sum(cr)) as bal_res ) as custBal from tbl_sales_master tsm inner join tbl_customer tc on tc.cust_id=tsm.cust_id right join tbl_transactions tr on (tr.action_ref_id=tsm.sm_id and tr.action_type=1 ) left join tbl_user_details tu on tu.user_id=tsm.sm_approved_id  where sm_id='" + sm_id + "'";
        DataTable dt1 = db.SelectQuery(wallet_qry);
        var wallet_data = JsonConvert.SerializeObject(dt1, Formatting.Indented);

        result = "{\"data\":" + pay_data + ",\"order_details\":" + wallet_data + "}";
        return result;
    }

    [WebMethod] // session check pending
    public static string make_payment_online(Dictionary<string, string> filters)
    {
        string result = "";
        string cust_amount = "0";
        string currdatetime = Get_Current_Date_Time(filters["time_zone"]);
        mySqlConnection db = new mySqlConnection();

        var session_chk_qry = "SELECT id FROM tbl_transactions WHERE session_id='" + filters["sessionId"] + "'";
        string session_exist = db.SelectScalar(session_chk_qry);
                if (!string.IsNullOrWhiteSpace(session_exist))
                { // existing so , skipped
                    cust_amount = db.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + filters["cust_id"] + "'");
                    result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                }
                else
                {

                    try
                    {
                        db.BeginTransaction();
                        DataTable dt = new DataTable();

                        //inserting order - when amount paid from customer wallet
                        if (Convert.ToDouble(filters["walletamt"]) != 0)
                        {

                            MySqlCommand cmdInsWallet = new MySqlCommand();
                            cmdInsWallet.CommandText = "INSERT INTO `tbl_transactions` " +
                                " ( `session_id`, `action_type`,  `partner_id`,`partner_type`, `branch_id`, `user_id`, `narration`, `dr`,  `date`,`closing_balance`)" +
                                " select @session_id, @action_type, @partner_id,@partner_type,@branch_id, @user_id, @narration, @dr, @date,(ifnull(sum(dr)-sum(cr),0)+@dr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id  ";
                            cmdInsWallet.Parameters.AddWithValue("@session_id", filters["sessionId"]);
                            cmdInsWallet.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.WITHDRAWAL);
                            cmdInsWallet.Parameters.AddWithValue("@partner_id", filters["cust_id"]);
                            cmdInsWallet.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                            cmdInsWallet.Parameters.AddWithValue("@branch_id", filters["branch"]);
                            cmdInsWallet.Parameters.AddWithValue("@user_id", filters["userid"]);
                            cmdInsWallet.Parameters.AddWithValue("@narration", "Withdrawn " + filters["walletamt"] + " from Wallet for clearing the Order #" + filters["OrderId"]);
                            cmdInsWallet.Parameters.AddWithValue("@dr", filters["walletamt"]);
                            cmdInsWallet.Parameters.AddWithValue("@date", currdatetime);
                            db.ExecuteQueryForTransaction(cmdInsWallet);
                        }
                        //check is cash paid
                        if (Convert.ToDouble(filters["sm_paid"]) > 0)
                        {
                            //inserting order credit entry
                            MySqlCommand cmdInsCr = new MySqlCommand();
                            cmdInsCr.CommandText = "INSERT INTO `tbl_transactions` " +
                                " ( `session_id`, `action_type`, `action_ref_id`, `partner_id`,`partner_type`,`branch_id`, `user_id`, `narration`,cash_amt,wallet_amt " +
                                (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", `cheque_amt`, `cheque_no`, `cheque_date`, `cheque_bank`" : "") +
                                ", `cr`, `date`,`closing_balance`)" +
                                " select @session_id, @action_type, @action_ref_id, @partner_id,@partner_type,@branch_id, @user_id, @narration,@cash_amt,@wallet_amt" +
                                (Convert.ToDouble(filters["ChequeAmount"]) != 0 ? ", @cheque_amt, @cheque_no, @cheque_date, @cheque_bank" : "") +
                                ", @cr, @date,(ifnull(sum(dr)-sum(cr),0)-@cr) from tbl_transactions where partner_id=@partner_id and partner_type=@partner_type and branch_id=@branch_id ";
                            cmdInsCr.Parameters.AddWithValue("@session_id", filters["sessionId"]);
                            cmdInsCr.Parameters.AddWithValue("@action_type", (int)Constants.ActionType.SALES);
                            cmdInsCr.Parameters.AddWithValue("@action_ref_id", filters["OrderId"]);
                            cmdInsCr.Parameters.AddWithValue("@partner_id", filters["cust_id"]);
                            cmdInsCr.Parameters.AddWithValue("@partner_type", (int)Constants.PartnerType.CUSTOMER);
                            cmdInsCr.Parameters.AddWithValue("@branch_id", filters["branch"]);
                            if (Convert.ToDouble(filters["pay_method"]) == 2)
                            {
                                cmdInsCr.Parameters.AddWithValue("@cash_amt", "0");
                                
                            }
                            else
                            {
                                cmdInsCr.Parameters.AddWithValue("@cash_amt", Convert.ToDecimal(filters["CashAmount"]));
                            }
                            cmdInsCr.Parameters.AddWithValue("@user_id", filters["userid"]);
                            cmdInsCr.Parameters.AddWithValue("@narration", "Paid " + filters["sm_paid"] + " for Order #" + filters["OrderId"] + " Note : " + filters["note"]);
                            
                            cmdInsCr.Parameters.AddWithValue("@wallet_amt", Convert.ToDecimal(filters["walletamt"]));
                            if (Convert.ToDouble(filters["pay_method"]) == 2)
                            {
                                DateTime recieved_date = DateTime.ParseExact(filters["ChequeDate"], "dd-mm-yyyy", System.Globalization.CultureInfo.InvariantCulture);
                                string formattedDate = recieved_date.ToString("yyyy-mm-dd", CultureInfo.InvariantCulture);

                                cmdInsCr.Parameters.AddWithValue("@cheque_amt", filters["ChequeAmount"]);
                                cmdInsCr.Parameters.AddWithValue("@cheque_no", filters["ChequeNo"]);
                                cmdInsCr.Parameters.AddWithValue("@cheque_date", formattedDate);
                                cmdInsCr.Parameters.AddWithValue("@cheque_bank", filters["ChequeBank"]);
                            }
                            else
                            {                                
                                cmdInsCr.Parameters.AddWithValue("@cheque_amt", "0");
                                cmdInsCr.Parameters.AddWithValue("@cheque_no", "");
                                cmdInsCr.Parameters.AddWithValue("@cheque_date", "");
                                cmdInsCr.Parameters.AddWithValue("@cheque_bank", "");
                                
                            }

                            cmdInsCr.Parameters.AddWithValue("@cr", filters["sm_paid"]);
                            cmdInsCr.Parameters.AddWithValue("@date", currdatetime);
                            bool result_qry = db.ExecuteQueryForTransaction(cmdInsCr);
                        }

                        string update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_last_updated_date='" + currdatetime + "',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions  where partner_id='" + filters["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id=" + filters["cust_id"].ToString() + "; SELECT cust_amount FROM tbl_customer WHERE cust_id=" + filters["cust_id"].ToString() + "";
                        cust_amount = db.SelectScalarForTransaction(update_tbl_cust_branch_amounts);
                        result = "SUCCESS";
                        result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                        db.CommitTransaction();

                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            result = "FAILED";
                            result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                            db.RollBackTransaction();
                            LogClass log = new LogClass("outstandingpayment");
                            log.write(ex);
                        }
                        catch
                        {
                        }
                    }
                }

        return result;
    }

    [WebMethod]
    public static string Save_Old_outstanding_entry(Dictionary<string, string> sl_mstr)
    {
            string result = "";

            var auth_result = authenticate_user(sl_mstr["user_id"].ToString(), sl_mstr["password"].ToString(), sl_mstr["device_id"].ToString());
            if (auth_result == "0")
            {
                result = "BLOCKED";
                return result;
            }

            string cust_amount = "";
            mySqlConnection db_order = new mySqlConnection();
            try
            {
                // checking session
                var session_chk_qry = "SELECT sm_id FROM tbl_sales_master WHERE sm_sales_sessionid='" + sl_mstr["session_id"] + "'";
                string session_exist = db_order.SelectScalar(session_chk_qry);
                if (!string.IsNullOrWhiteSpace(session_exist))
                { // existing so , skipped
                    result = "EXIST";
                    cust_amount = db_order.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + sl_mstr["cust_id"] + "'");
                    result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                }
                else
                {
                    string oldinvoiceid = sl_mstr["invoice_id"] + "#OLD ORDER ITEMS";
                    string qryOldInvoiceCheck = "SELECT SIM.sm_id FROM tbl_sales_items SIM inner join tbl_sales_master SM on SM.sm_id=SIM.sm_id WHERE SM.branch_id=" + sl_mstr["branch"] + " && SIM.itm_name='" + oldinvoiceid + "'";
                    string existId = db_order.SelectScalar(qryOldInvoiceCheck);
                    if (!string.IsNullOrWhiteSpace(existId))
                    { // existing so , skipped
                        result = "REPEAT";
                        cust_amount = db_order.SelectScalar("SELECT cust_amount FROM tbl_customer WHERE cust_id='" + sl_mstr["cust_id"] + "'");
                        result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
                    }
                    else
                    {
                        db_order.BeginTransaction();
                        DataTable ddt = new DataTable();
                        string currdatetime = Get_Current_Date_Time(sl_mstr["time_zone"]);
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
                        query = "INSERT INTO tbl_sales_master(cust_id,branch_id,sm_total,sm_discount_rate,sm_discount_amount,sm_netamount,sm_date,sm_processed_date,";
                        query = query + "sm_userid,sm_specialnote,sm_delivery_status,sm_latitude,sm_longitude,sm_processed_id,sm_delivered_id,sm_prefix,sm_serialNo,sm_suffix,sm_invoice_no,sm_sales_sessionid,sm_type)";
                        query = query + "VALUES ('" + sl_mstr["cust_id"] + "','" + sl_mstr["branch"] + "','" + sl_mstr["sm_netamount"] + "','0','0','" + sl_mstr["sm_netamount"] + "','" + sl_mstr["sm_date"] + "','" + sl_mstr["sm_date"] + "',";
                        query = query + "'" + sl_mstr["user_id"] + "',";
                        query = query + "'" + sl_mstr["sm_specialnote"] + "','2',0,0,0,0,'" + branchOutPrefix + "-OO','" + invoiceOutSuffix + "','" + branchOutSuffix + "',concat(sm_prefix,sm_serialNo,sm_suffix),'" + sl_mstr["session_id"] + "','2');Select last_insert_id()";
                        BillNo = Convert.ToInt32(db_order.SelectScalarForTransaction(query));
                        string updateRefrenceQry = "update tbl_sales_master set sm_refno=" + BillNo + " where sm_id=" + BillNo + "";
                        db_order.ExecuteQueryForTransaction(updateRefrenceQry);

                        if (BillNo != 0)
                        {
                            string qry1 = "INSERT INTO tbl_sales_items (si_id,sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type,si_tax_excluded_total,si_tax_amount,itm_type)";
                            qry1 = qry1 + "VALUES ";
                            string qryt = "Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + sl_mstr["branch"];
                            Int64 salesitemBranchId = Convert.ToInt64(db_order.SelectScalarForTransaction("Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + sl_mstr["branch"]));

                            string qry_main = qry1 + "(null,'" + BillNo + "','0','" + salesitemBranchId + "', '1234567891234','" + oldinvoiceid + "',";
                            qry_main = qry_main + "'0','" + sl_mstr["sm_netamount"] + "','" + sl_mstr["sm_netamount"] + "','1',";
                            qry_main = qry_main + "'" + sl_mstr["sm_netamount"] + "',";
                            qry_main = qry_main + "'0','0','" + sl_mstr["sm_netamount"] + "','0','0','0','0','0','0','3','" + sl_mstr["sm_netamount"] + "','0','1')";

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

                                string update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_last_updated_date='"+ currdatetime +"',cust_amount=(select (sum(dr)-sum(cr)) from tbl_transactions where partner_id='" + sl_mstr["cust_id"] + "' and partner_type=" + (int)Constants.PartnerType.CUSTOMER + ") where cust_id='" + sl_mstr["cust_id"] + "'; SELECT cust_amount FROM tbl_customer WHERE cust_id=" + sl_mstr["cust_id"];
                                cust_amount = db_order.SelectScalarForTransaction(update_tbl_cust_branch_amounts);
                                db_order.CommitTransaction();
                                //Send_Push_Notification("ORDER",BillNo.ToString());
                                result = "SUCCESS";
                                result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";

                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                try
                {
                    result = "FAILED";
                    result = "{\"result\":\"" + result + "\",\"cust_amount\":" + cust_amount + "}";
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
    public static string Get_My_Activities(string user_id,string date,string password,string device_id)
    {
        string result = "";
        var auth_result = authenticate_user(user_id, password, device_id);
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        StringBuilder sb = new StringBuilder();
        try
        {
            mySqlConnection db = new mySqlConnection();
            sb.Append("{");
            // MAIN ORDERS
            string qry_main_order = @"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed FROM tbl_sales_master sm  INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id  INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE date(sm.sm_date)='" + date + "' AND sm.sm_userid='" + user_id + "' AND sm.sm_type='1' GROUP BY sm.sm_id ORDER BY sm.sm_id DESC";
            var dt_order = db.SelectQuery(qry_main_order);
            sb.Append("\"main_order\":" + JsonConvert.SerializeObject(dt_order, Formatting.Indented));

            // OLD ORDERS ENTERED ON THAT DAY
            sb.Append(",");
            string qry_old_order = "SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,DATE_FORMAT(tr.date, '%Y-%m-%d') as entry_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed  FROM tbl_sales_master sm  INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) WHERE  sm.sm_userid='" + user_id + "' AND sm.sm_type='2'  GROUP BY sm.sm_id having entry_date='" + date + "' ORDER BY tr.id ASC ";
            var dt_old_order = db.SelectQuery(qry_old_order);
            sb.Append("\"old_order\":" + JsonConvert.SerializeObject(dt_old_order, Formatting.Indented));

            // CREDIT / DEBIT NOTES / SALES RETURN
            sb.Append(",");
            string qry_credit_debit_notes = "SELECT tr.action_type,cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,tr.id,tr.cr,tr.dr,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date  FROM tbl_transactions tr JOIN tbl_customer cu ON tr.partner_id=cu.cust_id WHERE tr.action_type IN (3,6,7) AND tr.partner_type=1 AND date(tr.date)='" + date + "' AND tr.user_id='" + user_id + "' ";
            var dt_cr_dr = db.SelectQuery(qry_credit_debit_notes);
            sb.Append("\"dt_cr_dr\":" + JsonConvert.SerializeObject(dt_cr_dr, Formatting.Indented));

            // PAYMENT AGAINST CURRENT DAYS'S ORDERS
            sb.Append(",");
            string qry_paid_current = "SELECT tr.action_ref_id,sm.sm_netamount,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_delivery_status,cu.cust_id,cu.cust_name,tr.id,tr.dr,tr.cr,tr.cash_amt,tr.cheque_amt,tr.cheque_no,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date  FROM tbl_transactions tr JOIN tbl_customer cu ON tr.partner_id=cu.cust_id JOIN tbl_sales_master sm on sm.sm_id=tr.action_ref_id WHERE tr.action_type='1' AND tr.partner_type=1 AND tr.dr=0 AND tr.is_reconciliation=0 AND date(sm.sm_date)='" + date + "' AND date(tr.date)='" + date + "' AND tr.user_id='" + user_id + "'";
            var dt_curr_paid = db.SelectQuery(qry_paid_current);
            sb.Append("\"dt_curr_paid\":" + JsonConvert.SerializeObject(dt_curr_paid, Formatting.Indented));

            // PAYMENT AGAINST PAST DAYS'S ORDERS
            sb.Append(",");
            string qry_paid_past = "SELECT tr.action_ref_id,sm.sm_netamount,DATE_FORMAT(sm.sm_date, '%d %M %Y %h:%i %p') AS sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_delivery_status,cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,tr.id,tr.dr,tr.cr,tr.cash_amt,tr.cheque_amt,tr.cheque_no,tr.narration,DATE_FORMAT(tr.date, '%d %M %Y %h:%i %p') AS tr_date  FROM tbl_transactions tr JOIN tbl_customer cu ON tr.partner_id=cu.cust_id JOIN tbl_sales_master sm on sm.sm_id=tr.action_ref_id WHERE tr.action_type='1' AND tr.partner_type=1 AND tr.dr=0 AND tr.is_reconciliation=0 AND date(sm.sm_date)<'" + date + "' AND date(tr.date)='" + date + "' AND tr.user_id='" + user_id + "'";
            var dt_past_paid = db.SelectQuery(qry_paid_past);
            sb.Append("\"dt_past_paid\":" + JsonConvert.SerializeObject(dt_past_paid, Formatting.Indented));

            // NEW REGISTRATIONS
            sb.Append(",");
            string qry_new_reg = "SELECT cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,cu.cust_status,cu.cust_tax_reg_id,cu.cust_reg_id FROM tbl_customer cu WHERE cu.user_id='" + user_id + "' AND date(cu.cust_joined_date)='" + date + "' ";
            var dt_new_reg = db.SelectQuery(qry_new_reg);
            sb.Append("\"dt_new_reg\":" + JsonConvert.SerializeObject(dt_new_reg, Formatting.Indented));

            // CHECK INS
            sb.Append(",");
            string qry_checkin = "SELECT cu.cust_id,cu.cust_name,cu.cust_address,cu.cust_city,DATE_FORMAT(rt.rt_datetime, '%d %M %Y %h:%i %p') AS rt_datetime,rt.rt_visit_status,rt.rt_lat,rt.rt_lon FROM tbl_root_tracker rt JOIN tbl_customer cu ON cu.cust_id=rt.cust_id WHERE rt.rt_user_id='" + user_id + "' AND date(rt.rt_datetime)='" + date + "' ";
            var dt_checkin = db.SelectQuery(qry_checkin);
            sb.Append("\"dt_checkin\":" + JsonConvert.SerializeObject(dt_checkin, Formatting.Indented));

            sb.Append("}");            
            return sb.ToString();
        }
        catch (Exception ex)
        {
            LogClass log = new LogClass("Get_My_Activities");
            log.write(ex);
            return "N"; }
    }

    [WebMethod]
    public static string get_edited_order_list(Dictionary<string, string> filters)
    {
        var result = "";
        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        try
        {
           
            var perPage = 15;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;
            var count_qry = @"SELECT IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,ed.sm_id,sm.sm_packed,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,CONCAT(ud.first_name,' ',ud.last_name) as sold_user,sm.sm_netamount,sm.sm_delivery_status 
from tbl_edit_history ed 
INNER JOIN tbl_sales_master sm ON sm.sm_id=ed.sm_id 

INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id 
INNER JOIN tbl_user_details ud on ud.user_id=ed.edited_by 

WHERE sm.sm_userid='" + filters["user_id"] + "' AND date(ed.edited_date)>='" + filters["orders_from"] + "' AND date(ed.edited_date)<='" + filters["orders_to"] + "' and sm.sm_type='1' GROUP BY ed.sm_id";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;

            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(@"SELECT IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_packed,ed.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,CONCAT(ud.first_name,' ',ud.last_name) as sold_user,sm.sm_netamount,sm.sm_delivery_status 
from tbl_edit_history ed 
INNER JOIN tbl_sales_master sm ON sm.sm_id=ed.sm_id 
INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id 
INNER JOIN tbl_user_details ud on ud.user_id=ed.edited_by 

WHERE sm.sm_userid='" + filters["user_id"] + "' AND date(ed.edited_date)>='" + filters["orders_from"] + "' AND date(ed.edited_date)<='" + filters["orders_to"] + "' and sm.sm_type='1' GROUP BY ed.sm_id ORDER BY sm.sm_id DESC LIMIT " + perPage + " OFFSET " + lowerBound + ""), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("get_edited_order_list");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string getEditOrderHistory(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();



        string qry = "SELECT ed.sm_id, ed.itbs_id,it.itm_name,ed.si_qty, ed.si_price, ed.si_discount_rate, ed.si_foc, ed.si_net_amount,ed.new_si_qty, ed.new_si_price, ed.new_si_discount_rate, ed.new_si_foc, ed.new_si_net_amount, ed.edit_action,DATE_FORMAT(ed.edited_date, '%m/%d/%Y %h:%i %p') as edited_date,ud.first_name,ud.last_name from tbl_edit_history ed JOIN tbl_itembranch_stock it on it.itbs_id=ed.itbs_id JOIN tbl_user_details ud on ed.edited_by= ud.user_id where ed.sm_id='" + filters["orderid"] + "' order by ed.edited_date desc";

        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

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

    [WebMethod]
    public static string get_returned_item(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();

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
WHERE  sri.sm_id='" + filters["sm_id"] + "'";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;
        
        string jsonResponse = "";
        if (numrows > 0)
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

    [WebMethod]
    public static string search_order_return_item(Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();

        string qry = "select IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_id,si.itbs_id,si.itm_name,si.itm_code,si.si_qty,si.si_foc,(si.si_qty+si.si_foc) as total_qty,si.si_discount_rate,DATE_FORMAT(sm.sm_date, '%d %M %Y') as sm_date,sm.cust_id ,si.si_price,IFNULL(sum(CASE WHEN (sr.sri_qty) THEN sr.sri_qty ELSE 0 END),0) as returned ,(si.si_net_amount/(si.si_qty+si.si_foc)) as return_price from tbl_sales_master sm join tbl_sales_items si on si.sm_id=sm.sm_id join tbl_itembranch_stock itb on itb.itbs_id=si.itbs_id left join tbl_salesreturn_items sr on (sr.itbs_id=itb.itbs_id and sm.sm_id=sr.sm_id ) where si.itm_type=1 and sm.sm_type='1' and si.sm_id='" + filters["sm_id"] + "' group by si.si_id having total_qty>returned order by sm.sm_date desc";
        DataTable dt = db.SelectQuery(qry);
        int numrows = dt.Rows.Count;

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

    [WebMethod]
    public static string getCustomerswithBalance(Dictionary<string, string> filters)
    {

        var result = "";
        var auth_result = authenticate_user(filters["user_id"].ToString(), filters["password"].ToString(), filters["device_id"].ToString());
        if (auth_result == "0")
        {
            result = "BLOCKED";
            return result;
        }

        try
        {
            
            var perPage = 15;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;
            var count_qry = @"SELECT cu.cust_id,(SUM(tr.dr)-SUM(tr.cr)) AS balance_to_clear,cu.cust_amount,
(CASE 
 WHEN (SUM(tr.dr)-SUM(tr.cr)) > cu.cust_amount THEN ABS(cu.cust_amount-(SUM(tr.dr)-SUM(tr.cr))) 
 WHEN cu.cust_amount < 0  THEN ABS(cu.cust_amount) 
 ELSE 0 
 END) AS available_to_clear 
 
FROM tbl_transactions tr 
JOIN tbl_sales_master sm ON (sm.sm_id=tr.action_ref_id AND tr.action_type=1) 
JOIN tbl_customer cu ON sm.cust_id=cu.cust_id 
JOIN tbl_user_branches ubr ON ubr.branch_id=sm.branch_id 
JOIN tbl_user_locations tul ON tul.location_id=cu.location_id 
WHERE ubr.user_id='" + filters["user_id"] + "' AND tul.user_id='" + filters["user_id"] + "' AND sm.sm_delivery_status NOT IN (4,5) AND tr.partner_type=1 GROUP BY tr.partner_id HAVING balance_to_clear>0 and available_to_clear>0";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;

            var main_qry = @"SELECT cu.cust_id,cu.cust_reg_id,cu.cust_name,cu.cust_address,cu.cust_city,(SUM(tr.dr)-SUM(tr.cr)) AS balance_to_clear,cu.cust_amount,
(CASE 
 WHEN (SUM(tr.dr)-SUM(tr.cr)) > cu.cust_amount THEN ABS(cu.cust_amount-(SUM(tr.dr)-SUM(tr.cr))) 
 WHEN cu.cust_amount < 0  THEN ABS(cu.cust_amount) 
 ELSE 0 
 END) AS available_to_clear 
 
FROM tbl_transactions tr 
JOIN tbl_sales_master sm ON (sm.sm_id=tr.action_ref_id AND tr.action_type=1) 
JOIN tbl_customer cu ON sm.cust_id=cu.cust_id 
JOIN tbl_user_branches ubr ON ubr.branch_id=sm.branch_id 
JOIN tbl_user_locations tul ON tul.location_id=cu.location_id 
WHERE ubr.user_id='" + filters["user_id"] + "' AND tul.user_id='" + filters["user_id"] + "' AND sm.sm_delivery_status NOT IN (4,5) AND tr.partner_type=1 GROUP BY tr.partner_id HAVING balance_to_clear>0 and available_to_clear>0 LIMIT " + perPage + " OFFSET " + lowerBound + "";

            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"customer_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(main_qry), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("getCustomerswithBalance");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

    [WebMethod]
    public static string Get_Orders_for_payment_clearance(Dictionary<string, string> filters)
    {
        var result = "";
        try
        {
            var perPage = 15;
            var totalRows = 0;
            var lowerBound = ((Convert.ToInt32(filters["page"]) - 1) * perPage);
            var upperBound = perPage + lowerBound - 1;
            var count_qry = @"SELECT sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_id FROM tbl_sales_master sm 
INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id 
INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) 
INNER JOIN tbl_user_branches ub ON ub.branch_id=sm.branch_id 
WHERE ub.user_id='" + filters["user_id"] + "' AND cu.cust_id='" + filters["cust_id"] + "' GROUP BY sm.sm_id HAVING total_balance>0 ORDER BY sm.sm_id";
            var dt_count = new mySqlConnection().SelectQuery(count_qry);
            totalRows = dt_count.Rows.Count;

            var main_qry = @"SELECT sm.sm_id,cu.cust_name,DATE_FORMAT(sm.sm_date, '%Y-%M-%d %h:%i %p') as sm_date,IFNULL(sm.sm_invoice_no,'NIL') AS sm_invoice_no,sm.sm_netamount,sum(tr.dr)-sum(tr.cr) as total_balance,sm.sm_delivery_status,sm.sm_packed 
FROM tbl_sales_master sm 
INNER JOIN tbl_customer cu ON cu.cust_id=sm.cust_id 
INNER JOIN tbl_transactions tr ON (tr.action_ref_id=sm.sm_id AND tr.action_type=1) 
INNER JOIN tbl_user_branches ub ON ub.branch_id=sm.branch_id 
WHERE ub.user_id='" + filters["user_id"] + "' AND cu.cust_id='" + filters["cust_id"] + "' GROUP BY sm.sm_id HAVING total_balance>0 ORDER BY sm.sm_id DESC LIMIT " + perPage + " OFFSET " + lowerBound + "";

            result = "{\"totalRows\":\"" + totalRows + "\",\"perPage\":\"" + perPage + "\",\"order_list\":" + JsonConvert.SerializeObject(new mySqlConnection().SelectQuery(main_qry), Formatting.Indented) + "}";
            return result;
        }
        catch (Exception ex)
        {
            var log = new LogClass("Get_Orders_for_payment_clearance");
            log.write(ex);
            result = "ERROR";
            return result;
        }
    }

}