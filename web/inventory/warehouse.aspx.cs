using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Text;
using commonfunction;
using Newtonsoft.Json;

public partial class inventory_warehouse : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication warehouse = new LoginAuthentication();
        warehouse.userAuthentication();
        warehouse.checkPageAcess(11);
    }
    [WebMethod]
    //Start:Show Country Names
    public static string getCountryNames()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT country_id,country_name FROM tbl_country";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["country_id"] is DBNull)
                {
                    sb.Append("<option value='-1' selected>-Select Country-</option>");
                }
                else
                {
                    //sb.Append("<select class='selectbox' id='txtitemcountry'style='width:255px; height:24px;'>");
                    sb.Append("<option value='-1' selected>-Select Country-</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        sb.Append("<option value='" + dt.Rows[i]["country_id"] + "'>" + dt.Rows[i]["country_name"] + "</option>");

                    }
                    //sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='-1' selected>-Select Country-</option>");
            }
        }

        return sb.ToString();
    }

    // Adding Branches
    [WebMethod]
    public static string AddBranch(string Actiontype, string Branchid, string CountryId, string countryName, string Branch, string BranchEmail, string Phone1, string Phone2, string Address, string Currency, string TimeZone, string BillDisclosure, string BillFooter, string imagePath, string registerNumber, string taxMethod, string isInclusive, int state, string orderPrefix, string orderNumber, string declaration, string serialNumber)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        //check is unique?
        if (Actiontype == "insert")
        {
            String chk_qry = "SELECT COUNT(*) AS Expr1 FROM  tbl_branch WHERE  (branch_countryid = " + CountryId + ") AND (branch_name = '" + Branch + "')";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows > 0)
            {
                return "E";
            }
            String chk_Prefixqry = "SELECT count(*) FROM  tbl_branch WHERE (branch_orderPrefix = '" + orderPrefix + "') and (branch_orderPrefix != '')";
            double Prefixnumrows = Convert.ToInt32(db.SelectScalar(chk_Prefixqry));
            if (Prefixnumrows > 0)
            {
                return "P";
            }
        }
        ////
        string quermaxnote = "select MAX(branch_id) as id from tbl_branch";
        dt = db.SelectQuery(quermaxnote);
        Int32 Id = 0;

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
            Id = ++Id;
        }



        bool query;
        String resultStatus;
        resultStatus = "N";
        string brquery = "";

        if (Actiontype == "insert")
        {


            brquery = "INSERT INTO tbl_branch(branch_id,branch_name,branch_countryid,branch_phone1,branch_address,branch_country_name,branch_phone2,branch_email,branch_currency_id,branch_timezone,branch_bill_disclosure,branch_bill_footer,branch_image,branch_tax_method,branch_tax_inclusive,branch_reg_id,branch_state_id,branch_orderPrefix,branch_orderSerial,branch_orderSuffix,branch_declaration,branch_last_updated_date) VALUES('" + Id + "','" + Branch + "','" + CountryId + "','" + Phone1 + "','" + Address + "','" + countryName + "','" + Phone2 + "','" + BranchEmail + "','" + Currency + "','" + TimeZone + "',N'" + BillDisclosure + "',N'" + BillFooter + "','" + imagePath + "','" + taxMethod + "','" + isInclusive + "','" + registerNumber + "'," + state + ",'" + orderPrefix + "','" + serialNumber + "','" + orderNumber + "','" + declaration + "','" + updatedDate + "')";
            query = db.ExecuteQuery(brquery);
            if (query)
            {
                var itmId = db.SelectScalar("select itm_id from tbl_item_master where itm_code='1234567891234'");
                if (itmId == "")
                {
                    itmId = db.SelectScalar("insert into tbl_item_master values (null,'1234567891234','Old Bill Item','',0,0,-1,0,1);Select last_insert_id();");
                }
                string ary = "insert into tbl_itembranch_stock values (null," + Id + "," + itmId + ",0,0,'1234567891234','Old Bill Item',0,0,-1,0,0,0,0,0,0,2,'" + updatedDate + "',10)";
                db.ExecuteQuery("insert into tbl_itembranch_stock values (null," + Id + "," + itmId + ",0,0,0,'1234567891234','Old Bill Item',0,0,-1,0,0,0,0,0,0,2,0,'" + updatedDate + "',10)");

                resultStatus = "Y";
            }
        }
        if (Actiontype == "Update")
        {
            String updatechk_qry = "SELECT count(*) FROM  tbl_branch WHERE (branch_id!='" + Branchid + "' and (branch_orderPrefix = '" + orderPrefix + "'))";
            double checknumrows = Convert.ToInt32(db.SelectScalar(updatechk_qry));
            if (checknumrows > 0)
            {
                return "P";
            }
            brquery = "update tbl_branch set branch_countryid='" + CountryId + "', branch_country_name='" + countryName + "', branch_name='" + Branch + "',branch_email='" + BranchEmail + "',branch_phone1='" + Phone1 + "',branch_phone2='" + Phone2 + "',branch_address='" + Address + "',branch_currency_id='" + Currency + "',branch_timezone='" + TimeZone + "',branch_bill_disclosure=N'" + BillDisclosure + "',branch_bill_footer=N'" + BillFooter + "',branch_image='" + imagePath + "',branch_tax_method='" + taxMethod + "',branch_tax_inclusive='" + isInclusive + "',branch_reg_id='" + registerNumber + "',branch_state_id=" + state + ",branch_orderPrefix='" + orderPrefix + "',branch_orderSuffix='" + orderNumber + "',branch_orderSerial='" + serialNumber + "',branch_declaration='" + declaration + "' where branch_id='" + Branchid + "'";
            query = db.ExecuteQuery(brquery);
            if (query)
            {
                db.ExecuteQuery("update tbl_branch set branch_last_updated_date='" + updatedDate + "' where branch_id='" + Branchid + "'");
                //string noteqey = "update specialnote set branch_name='" + Branch + "' where branch_id='" + Branchid + "' ";
                //db.ExecuteQuery(noteqey);
                resultStatus = "Y";
            }
        }

        return resultStatus;
    }

    

    // showing search results of branches
    [WebMethod]
    public static string searchBranchMaster(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = "";
            if (filters.Count > 0)
            {
                query_condition = " where 1=1";
                
                if (filters.ContainsKey("country"))
                {
                    query_condition += " and branch_country_name  LIKE '%" + filters["country"] + "%'";
                }
                if (filters.ContainsKey("warehouse"))
                {
                    query_condition += " and branch_name LIKE '%" + filters["warehouse"] + "%'";
                }
                if (filters.ContainsKey("phone"))
                {
                    query_condition += " and branch_phone1  LIKE '%" + filters["phone"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";

            countQry = "SELECT count(*) FROM tbl_branch " + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT branch_id,branch_country_name,branch_name,branch_phone1 from tbl_branch ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + "order by branch_id LIMIT " + offset.ToString() + " ," + per_page;

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
    public static string editBranchMaster(string Id)
    {
        mySqlConnection db = new mySqlConnection();
        string qry = "SELECT * FROM tbl_branch where branch_id='" + Id + "' ";
        DataTable dt = db.SelectQuery(qry);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {

            sb.Append("" + dt.Rows[i]["branch_id"] + "*" + dt.Rows[i]["branch_name"] + "*" + dt.Rows[i]["branch_countryid"] + "*" + dt.Rows[i]["branch_phone1"] + "*" + dt.Rows[i]["branch_address"] + "*" + dt.Rows[i]["branch_country_name"] + "*" + dt.Rows[i]["branch_email"] + "*" + dt.Rows[i]["branch_phone2"] + "*" + dt.Rows[i]["branch_currency_id"] + "*" + dt.Rows[i]["branch_timezone"] + "*" + dt.Rows[i]["branch_bill_disclosure"] + "*" + dt.Rows[i]["branch_bill_footer"] + "*" + dt.Rows[i]["branch_image"] + "*" + dt.Rows[i]["branch_tax_method"] + "*" + dt.Rows[i]["branch_tax_inclusive"] + "*" + dt.Rows[i]["branch_reg_id"] + "*" + dt.Rows[i]["branch_state_id"] + "*" + dt.Rows[i]["branch_orderPrefix"] + "*" + dt.Rows[i]["branch_orderSuffix"] + "*" + dt.Rows[i]["branch_declaration"] + "*" + dt.Rows[i]["branch_orderSerial"] + "");

        }
        return sb.ToString();
    }



    [WebMethod]
    //Start:Show Currency
    public static string showCurrency()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT currency_id,currency_name FROM tbl_currency_details";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["currency_id"] is DBNull)
                {
                    sb.Append("<option value='0' selected>-Select Currency-</option>");
                }
                else
                {

                    sb.Append("<option value='0' selected>-Select Currency-</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        sb.Append("<option value='" + dt.Rows[i]["currency_id"] + "'>" + dt.Rows[i]["currency_name"] + "</option>");

                    }

                }
            }
            else
            {
                sb.Append("<option value='0' selected>-Select Currency-</option>");
            }
        }

        return sb.ToString();
    }


    [WebMethod]// state list show
    public static string getstates(int country)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
        string query = "select state_id, state_name from tbl_state where country_id="+country+"";
        //    query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }//end

}