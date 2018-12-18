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

public partial class settings : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication settings = new LoginAuthentication();
        settings.userAuthentication();
        settings.checkPageAcess(26);
    }
    [WebMethod]
    //Start:Show Country Names
    public static string showCountryList()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT country_id,country_name FROM tbl_country ORDER BY country_name ASC";
        dt = db.SelectQuery(query);
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
    public static string addCountry(string actionType, string country_id, string country_name)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        string query2 = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();

        if (actionType == "insert")
        {
            string qry = "select MAX(country_id) as id from tbl_country";
            dt = db.SelectQuery(qry);
            Int32 countryId = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["id"] is DBNull)
                    {
                        countryId = ++countryId;
                    }
                    else
                    {
                        countryId = Convert.ToInt32(dt.Rows[0]["id"]);
                        countryId = ++countryId;
                    }
                }
            }
            else
            {
                countryId = ++countryId;
            }
            query = "INSERT INTO tbl_country (country_id, country_name)";
            query = query + "VALUES ('" + countryId + "','" + country_name + "')";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }


        if (actionType == "update")
        {
            query = "UPDATE tbl_country SET ";
            query = query + "country_name='" + country_name + "' WHERE country_id='" + country_id + "' ";

            query2 = "UPDATE tbl_branch SET ";
            query2 = query2 + "CountryName='" + country_name + "' WHERE branch_countryid='" + country_id + "' ";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                //  db.ExecuteQuery(query);
                db.ExecuteQuery(query2);
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }



    [WebMethod]
    public static string removeCountry(string country_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numBranchCount = 0;
        int numCustomerCount = 0;


        string BranchQuery = "SELECT COUNT(branch_countryid) FROM tbl_branch  WHERE  branch_countryid='" + country_id + "' ";
        numBranchCount = Convert.ToInt32(db.SelectScalar(BranchQuery));

        string CustomerQuery = "SELECT COUNT(cust_country) FROM tbl_customer  WHERE  cust_country='" + country_id + "' ";
        numCustomerCount = Convert.ToInt32(db.SelectScalar(CustomerQuery));

        //string Billquery = "SELECT COUNT(CountryId) FROM billheader  WHERE  CountryId='" + country_id + "' ";
        //numBillCount = Convert.ToInt32(db.SelectScalar(Billquery));
        //string Servquery = "SELECT COUNT(CountryId) FROM service  WHERE  CountryId='" + country_id + "' ";
        //numServCount = Convert.ToInt32(db.SelectScalar(Servquery));

        if (numBranchCount == 0 && numCustomerCount==0)
        {
            query = "DELETE FROM tbl_country ";
            query = query + "WHERE country_id='" + country_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }

        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }






    [WebMethod]
    //Start:Show Currency
    public static string showCurrencyList()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT currency_id,currency_name FROM tbl_currency_details ORDER BY currency_name ASC";
        dt = db.SelectQuery(query);
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
    public static string addCurrency(string actionType, string Currency_id, string Currency_name)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();

        if (actionType == "insert")
        {
            string qry = "select MAX(currency_id) as currency_id from tbl_currency_details";
            dt = db.SelectQuery(qry);
            Int32 CurrencyId = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["currency_id"] is DBNull)
                    {
                        CurrencyId = ++CurrencyId;
                    }
                    else
                    {
                        CurrencyId = Convert.ToInt32(dt.Rows[0]["currency_id"]);
                        CurrencyId = ++CurrencyId;
                    }
                }
            }
            else
            {
                CurrencyId = ++CurrencyId;
            }
            query = "INSERT INTO tbl_currency_details (currency_id, currency_name)";
            query = query + "VALUES ('" + CurrencyId + "','" + Currency_name + "')";
        }


        if (actionType == "update")
        {
            query = "UPDATE tbl_currency_details SET ";
            query = query + "currency_name='" + Currency_name + "' WHERE currency_id='" + Currency_id + "' ";
        }

        queryStatus = db.ExecuteQuery(query);
        if (queryStatus)
        {
            resultStatus = "Y";
        }

        return resultStatus;
    }



    [WebMethod]
    public static string removeCurrency(string Currency_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numcurrencyCount = 0;

        string AreaQuery = "SELECT COUNT(branch_currency_id) FROM tbl_branch WHERE branch_currency_id='" + Currency_id + "' ";
        numcurrencyCount = Convert.ToInt32(db.SelectScalar(AreaQuery));
        if (numcurrencyCount == 0)
        {
            query = "DELETE FROM tbl_currency_details ";
            query = query + "WHERE currency_id='" + Currency_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }

        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }

    [WebMethod]
    //Start:Show UserTypes
    public static string showUserTypeList()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT usertype_id,usertype_name FROM tbl_user_type ORDER BY usertype_id ASC";
        dt = db.SelectQuery(query);
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
    public static string addUserType(string actionType, string UserType_id, string UserType_name)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        string query1 = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();

        if (actionType == "insert")
        {
            string qry = "select MAX(usertype_id) as usertype_id from tbl_user_type";
            dt = db.SelectQuery(qry);
            Int32 UserTypeId = 0;

            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["usertype_id"] is DBNull)
                    {
                        UserTypeId = ++UserTypeId;
                    }
                    else
                    {
                        UserTypeId = Convert.ToInt32(dt.Rows[0]["usertype_id"]);
                        UserTypeId = ++UserTypeId;
                    }
                }

            }
            else
            {
                UserTypeId = ++UserTypeId;
            }
            query = "INSERT INTO tbl_user_type (usertype_id, usertype_name)";
            query = query + "VALUES ('" + UserTypeId + "','" + UserType_name + "')";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }


        if (actionType == "update")
        {

            query = "UPDATE tbl_user_type SET ";
            query = query + "usertype_name='" + UserType_name + "' WHERE usertype_id='" + UserType_id + "' ";

            query1 = "UPDATE tbl_user_details SET ";
            query1 = query1 + "user_type_name='" + UserType_name + "' WHERE user_type='" + UserType_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                queryStatus = db.ExecuteQuery(query1);
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }



    [WebMethod]
    public static string removeUserType(string UserType_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numUserCount = 0;

        string BranchQuery = "SELECT COUNT(user_type) FROM tbl_user_details  WHERE  user_type='" + UserType_id + "' ";
        numUserCount = Convert.ToInt32(db.SelectScalar(BranchQuery));

        if (numUserCount == 0)
        {
            query = "DELETE FROM tbl_user_type ";
            query = query + "WHERE usertype_id='" + UserType_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }

    [WebMethod]
    //Start:Show states
    public static string showStateList(int country_id)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT state_id,state_name,country_id FROM tbl_state where country_id=" + country_id + " ORDER BY state_name ASC";
        dt = db.SelectQuery(query);
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
    public static string addState(string actionType, string State_id, string State_name, int country)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        string query2 = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {
            query = "INSERT INTO tbl_state (state_name,country_id,state_last_updated_date)";
            query = query + "VALUES ('" + State_name + "',"+country+ ",'" + updatedDate + "')";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }


        if (actionType == "update")
        {
            query = "UPDATE tbl_state SET ";
            query = query + "state_name='" + State_name + "' , country_id=" + country + " , state_last_updated_date='" + updatedDate + "' WHERE state_id='" + State_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }

    [WebMethod]// country list show
    public static string loadCountries()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select country_id, country_name from tbl_country";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]
    public static string removeState(string State_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numBranchCount = 0;
        int numCustomerBranchCount = 0;

        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        string BranchQuery = "SELECT COUNT(branch_id) FROM tbl_branch  WHERE  branch_state_id='" + State_id + "' ";
        numBranchCount = Convert.ToInt32(db.SelectScalar(BranchQuery));
        string CustomerStatequery = "SELECT COUNT(cust_id) FROM tbl_customer WHERE cust_state='" + State_id + "' ";
        numCustomerBranchCount = Convert.ToInt32(db.SelectScalar(CustomerStatequery));


        //string Billquery = "SELECT COUNT(CountryId) FROM billheader  WHERE  CountryId='" + country_id + "' ";
        //numBillCount = Convert.ToInt32(db.SelectScalar(Billquery));
        //string Servquery = "SELECT COUNT(CountryId) FROM service  WHERE  CountryId='" + country_id + "' ";
        //numServCount = Convert.ToInt32(db.SelectScalar(Servquery));

        if (numBranchCount == 0 && numCustomerBranchCount == 0)
        {
            query = "DELETE FROM tbl_state ";
            query = query + "WHERE state_id='" + State_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                query = "UPDATE tbl_state SET ";
                query = query + "state_last_updated_date='" + updatedDate + "'";
                queryStatus = db.ExecuteQuery(query);
                resultStatus = "Y";
            }

        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }

    [WebMethod]
    public static string addLocation(string actionType, string Location_id, string Location_name, int district)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {

            query = "INSERT INTO tbl_location (location_name,dist_id,loc_last_updated_date)";
            query = query + "VALUES ('" + Location_name + "',"+district+ ",'" + updatedDate + "')";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }


        if (actionType == "update")
        {
            query = "UPDATE tbl_location SET ";
            query = query + "location_name='" + Location_name + "',dist_id="+district+ ",loc_last_updated_date='"+ updatedDate + "' WHERE location_id='" + Location_id + "' ";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }

    [WebMethod]
    //Start:Show location Names
    public static string showLocationList(int dis_id)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT location_id,location_name,dist_id FROM tbl_location where dist_id=" + dis_id + " ORDER BY location_name ASC";
        dt = db.SelectQuery(query);
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
    public static string removeLocation(string Location_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numBranchCount = 0;
        int numuserCount = 0;
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");

        string checkQuery = "SELECT COUNT(cust_id) FROM tbl_customer  WHERE  location_id='" + Location_id + "' ";
        numBranchCount = Convert.ToInt32(db.SelectScalar(checkQuery));

        string usercheckQuery = "SELECT COUNT(ul_id) FROM tbl_user_locations  WHERE  location_id='" + Location_id + "' ";
        numuserCount = Convert.ToInt32(db.SelectScalar(usercheckQuery));

        //string Billquery = "SELECT COUNT(CountryId) FROM billheader  WHERE  CountryId='" + country_id + "' ";
        //numBillCount = Convert.ToInt32(db.SelectScalar(Billquery));
        //string Servquery = "SELECT COUNT(CountryId) FROM service  WHERE  CountryId='" + country_id + "' ";
        //numServCount = Convert.ToInt32(db.SelectScalar(Servquery));

        if (numBranchCount == 0 && numuserCount==0)
        {
            query = "DELETE FROM tbl_location ";
            query = query + "WHERE location_id='" + Location_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                query = "UPDATE tbl_location SET ";
                query = query + "loc_last_updated_date='" + updatedDate + "'";

                queryStatus = db.ExecuteQuery(query);
                resultStatus = "Y";
            }

        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }

    [WebMethod]
    public static string addDistrict(string actionType, string District_id, string district_name, int state)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";
        string query2 = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
    
        if (actionType == "insert")
        {
            query = "INSERT INTO tbl_district (dis_name,state_id)";
            query = query + "VALUES ('" + district_name + "'," + state + ")";

            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }


        if (actionType == "update")
        {
            query = "UPDATE tbl_district SET ";
            query = query + "dis_name='" + district_name + "' , state_id=" + state + " WHERE dis_id='" + District_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }

    [WebMethod]
    //Start:Show districts
    public static string showDistrictList(int state_id)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT dis_id,dis_name,state_id FROM tbl_district where state_id="+state_id+" ORDER BY dis_name ASC";
        dt = db.SelectQuery(query);
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
    public static string removeDistrict(string District_id)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        int numDistrictCount = 0;


        string districtQuery = "SELECT COUNT(dist_id) FROM tbl_location  WHERE dist_id='" + District_id + "' ";
        numDistrictCount = Convert.ToInt32(db.SelectScalar(districtQuery));

        if (numDistrictCount == 0)
        {
            query = "DELETE FROM tbl_district ";
            query = query + "WHERE dis_id='" + District_id + "' ";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                resultStatus = "Y";
            }

        }
        else
        {
            resultStatus = "E";
        }

        return resultStatus;
    }

    [WebMethod]// state list show
    public static string loadStates()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select state_id, state_name from tbl_state";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

    [WebMethod]// district list show
    public static string loadDistricts()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select dis_id, dis_name from tbl_district";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end
}