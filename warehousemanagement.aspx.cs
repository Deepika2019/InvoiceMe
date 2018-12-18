using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
public partial class inventory_warehousemanagement : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.Cookies["invntrystaffId"] != null && Request.Cookies["invntrystaffBranchId"] != null && Request.Cookies["invntrystaffCountryId"] != null)
        {
            string userid = Request.Cookies["invntrystaffTypeID"].Value;
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            string query = "SELECT COUNT(*) FROM tbl_user_permissions WHERE user_type='" + userid + "' and page_id='13' and read_action='1' ";
            double numrows = Convert.ToInt32(db.SelectScalar(query));
            if (numrows == 0)
            {
                Response.Redirect("../dashboard.aspx");
            }
        }
        else if (Request.Cookies["invntrystaffId"] == null && Request.Cookies["invntrystaffBranchId"] == null && Request.Cookies["invntrystaffCountryId"] == null)
        {
            Response.Redirect("../dashboard.aspx");
        }
        else
        {
            Response.Redirect("../login.aspx");
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
                    sb.Append("<option value='0' selected='selected' taxType='-1'>--Select Warehouse--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                   // sb.Append("<select id='combobranchtype' class='form-control'  onchange=''>");
                    sb.Append("<option value='0' selected='selected' taxType='-1'>--Select Warehouse--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["branch_id"] + "' taxType=" + dt.Rows[i]["branch_tax_method"] + ">" + dt.Rows[i]["branch_name"] + "</option>");

                    }
                   // sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='0' selected='selected' taxType='-1'>--Select Warehouse--</option>");
               // sb.Append("<select id='combobranchtype'>");
                //sb.Append("</select>");
            }
        }
        return sb.ToString();
    }

    [WebMethod]
    public static string showItems(string searchText)
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT itm_id,itm_name FROM tbl_item_master where itm_name like '%" + searchText + "%'  ORDER BY itm_name ASC";
        dt = db.SelectQuery(query);
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

    //save and update item stock details
    [WebMethod]
    public static string addBranchStockDetails(string actionType, string itbsid, string branch, string item, int currentstock, string reorderlevel, string status, string itm_mrp, string pricegroup_one, string pricegroup_two, string pricegroup_three, string taxcode, string duration, int priority, string sessionId, string actual_stock, int stockChange, string stockDifr, string purchasePrice)
    {

        String resultStatus;
        resultStatus = "N";
        mySqlConnection db = new mySqlConnection();

        bool queryStatus;
        string query = "";
        // CKECKING SESSION
        string getsessionexist = "select itbs_sessionId from tbl_itembranch_stock where itbs_sessionId='" + sessionId + "'";
        DataTable dtsession = db.SelectQuery(getsessionexist);
        int sess_rows = dtsession.Rows.Count;

        if (sess_rows != 0)  // ALREADY SAVED CASE
        {
            db.RollBackTransaction();
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Item saved already\"}";
        }
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {

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
            query = "INSERT INTO tbl_itembranch_stock (itbs_id,branch_id, itm_id, itbs_stock, itbs_reorder, itbs_available, itm_code, itm_name,itm_brand_id,itm_category_id,itm_subcategory_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_target,tp_tax_code,itbs_duration,itm_last_update_date,itm_rating,itbs_sessionId,itbs_purchase_price)";
            query = query + "VALUES (null,'" + branch + "','" + item + "','" + actual_stock + "','" + reorderlevel + "','" + status + "','" + dt1.Rows[0]["itm_code"] + "','" + dt1.Rows[0]["itm_name"] + "','" + dt1.Rows[0]["itm_brand_id"] + "','" + dt1.Rows[0]["itm_category_id"] + "','" + dt1.Rows[0]["itm_subcategory_id"] + "','" + itm_mrp + "','" + pricegroup_one + "','" + pricegroup_two + "','" + pricegroup_three + "','0','0','" + taxcode + "','" + duration + "','" + updatedDate + "'," + priority + "," + sessionId + "," + purchasePrice + ")";
            queryStatus = db.ExecuteQuery(query);
            if (currentstock != 0)
            {
                string stockTransctnQry = "INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES"
                    + " ('" + branchstockid + "','" + ((int)Constants.ActionType.MANUAL_ITEM_EDIT) + "','" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "'"
                    + " ,CONCAT('Manually entered " + currentstock + "', (select itm_name from tbl_itembranch_stock where itbs_id='" + branchstockid + "')),'" + currentstock + "'"
                    + " ,(select itbs_stock from tbl_itembranch_stock where itbs_id='" + branchstockid + "'),'" + updatedDate + "')";
                db.ExecuteQuery(stockTransctnQry);
            }

        }


        if (actionType == "update")
        {
            //check is unique?
            String chk_qry = "SELECT count(*) FROM  tbl_itembranch_stock WHERE (branch_id = '" + branch + "' and itm_id  = '" + item + "') and itbs_id!='" + itbsid + "'";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows > 0)
            {
                return "E";
            }
            ////
           // DataTable dt2 = new DataTable();
           // dt2= db.SelectQuery("select itm_code,itm_name from tbl_item_master where itm_id='" + item + "'");

            string stock = db.SelectScalar("SELECT IFNULL(SUM(si.si_qty+si.si_foc),0) AS total_qty FROM tbl_sales_items si INNER JOIN tbl_sales_master sm ON sm.sm_id=si.sm_id WHERE si.itbs_id='" + itbsid + "' AND sm.sm_delivery_status IN (0,3,6)");
            Int32 up_stock = Convert.ToInt32(actual_stock) - Convert.ToInt32(stock);

            query = "UPDATE tbl_itembranch_stock SET "
            + " branch_id='" + branch + "',itm_id='" + item + "',itbs_stock=" + up_stock + ",itbs_purchase_price=" + purchasePrice + " "
            +" ,itbs_reorder='" + reorderlevel + "',itbs_available='" + status + "'"
            +" ,itm_mrp='" + itm_mrp + "',itm_class_one='" + pricegroup_one + "',itm_class_two='" + pricegroup_two + "',"
            + " itm_class_three='" + pricegroup_three + "',tp_tax_code='" + taxcode + "',itbs_duration='"+duration+ "',itm_last_update_date='" + updatedDate + "',itm_rating='" + priority + "',itm_code=(select itm_code from tbl_item_master where itm_id=" + item+"),"
            +" itm_name=(select itm_name from tbl_item_master where itm_id="+item+"),itm_brand_id=(select itm_brand_id from tbl_item_master where itm_id="+item+"),"
            +" itm_category_id=(select itm_category_id from tbl_item_master where itm_id="+item+"),"
            +" itm_subcategory_id=(select itm_subcategory_id from tbl_item_master where itm_id="+item+")";
            query = query + " where itbs_id=" + itbsid + "";
            queryStatus = db.ExecuteQuery(query);

            if (stockChange == 1)
            {
                if (Convert.ToInt32(stockDifr) >= 1)
                {
                    string stockTransctnQry = "INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`user_id`,`narration`,`cr_qty`,`closing_stock`,`date`) VALUES"
                    + " ('" + itbsid + "','" + ((int)Constants.ActionType.MANUAL_ITEM_EDIT) + "','" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "'"
                    + " ,CONCAT('Add " + stockDifr + " extra stock to ', (select itm_name from tbl_itembranch_stock where itbs_id='" + itbsid + "')),'" + stockDifr + "'"
                    + " ,(select itbs_stock from tbl_itembranch_stock where itbs_id='" + itbsid + "'),'" + updatedDate + "')";
                    db.ExecuteQuery(stockTransctnQry);
                }
                else
                {
                    int stockVal = -1 * Convert.ToInt32(stockDifr);
                    string stockTransctnQry = "INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`user_id`,`narration`,`dr_qty`,`closing_stock`,`date`) VALUES"
                   + " ('" + itbsid + "','" + ((int)Constants.ActionType.MANUAL_ITEM_EDIT) + "','" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + "'"
                   + " ,CONCAT('Reduce " + stockVal + " qty from current stock of ', (select itm_name from tbl_itembranch_stock where itbs_id='" + itbsid + "')),'" + stockVal + "'"
                   + " ,(select itbs_stock from tbl_itembranch_stock where itbs_id='" + itbsid + "'),'" + updatedDate + "')";
                    db.ExecuteQuery(stockTransctnQry);
                }
            }
            //,itm_name='" + dt2.Rows[0]["itm_name"] + "'

        }

       
            resultStatus = "Y";
        
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");
        return resultStatus;
    }

    //search branchstock table
    [WebMethod]
    public static string searchBranchStock(int page, Dictionary<string, string> filters, int perpage)
    {

        try
        {
            string query_condition = "";
            if (filters.Count > 0)
            {
                query_condition = " where 1=1 ";
               
                if (filters.ContainsKey("itemval"))
                {
                    query_condition += " and (itbs.itm_name LIKE '%" + filters["itemval"] + "%' or itbs.itm_code like '%" + filters["itemval"] + "%')";
                }
                if (filters.ContainsKey("branch"))
                {
                    if (filters["branch"] == "0")
                    {
                        query_condition += " and itbs.branch_id in (select branch_id from tbl_user_branches where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value + ")";
                    }else
                    {
                        query_condition += " and itbs.branch_id  = '" + filters["branch"] + "'";
                    }
                   
                }
                if (filters.ContainsKey("brand"))
                {
                    query_condition += " and itbs.itm_brand_id = '" + filters["brand"] + "'";
                }
                if (filters.ContainsKey("category"))
                {
                    query_condition += " and itbs.itm_category_id  = '" + filters["category"] + "'";
                }
                if (filters.ContainsKey("itmstock"))
                {
                    if (Convert.ToInt32(filters["itmstock"]) == 1)
                    {
                        query_condition += " and itbs.itbs_stock>=itbs.itbs_reorder";
                    }
                    else if (Convert.ToInt32(filters["itmstock"]) == 2)
                    {
                        query_condition += " and itbs.itbs_stock<itbs.itbs_reorder";
                    }
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;

            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            StringBuilder sb = new StringBuilder();
            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_itembranch_stock itbs" + query_condition;

            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = @"select itbs.itbs_id,itbs.itm_code,itbs.itm_name,branch_name,itbs_reorder,itbs_available,
(itbs_stock+ifnull( sum(si.si_qty+si.si_foc),0)) as itbs_stock 
from tbl_itembranch_stock itbs  
inner join tbl_branch br on br.branch_id=itbs.branch_id  
left join tbl_sales_items si 
inner join tbl_sales_master sm on sm.sm_id = si.sm_id 
on itbs.itbs_id = si.itbs_id  and sm.sm_delivery_status in (0,3,6) ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + " group by itbs.itbs_id order by itbs_id  LIMIT " + offset.ToString() + " ," + per_page;

            dt = db.SelectQuery(innerqry);
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


    //edit branch stock data
    [WebMethod]
    public static string editBranchStockdetail(string itbsid)
    {
        mySqlConnection db = new mySqlConnection();
        string qry = "SELECT  * FROM tbl_itembranch_stock where itbs_id ='" + itbsid + "' ";
        DataTable dt = db.SelectQuery(qry);

        string stock_new = db.SelectScalar("SELECT IFNULL(SUM(si.si_qty+si.si_foc),0) AS total_qty FROM tbl_sales_items si INNER JOIN tbl_sales_master sm ON sm.sm_id=si.sm_id WHERE si.itbs_id='" + itbsid + "' AND sm.sm_delivery_status IN (0,3,6)");

        string stock_processed = db.SelectScalar("SELECT IFNULL(SUM(si.si_qty+si.si_foc),0) AS total_qty FROM tbl_sales_items si INNER JOIN tbl_sales_master sm ON sm.sm_id=si.sm_id WHERE si.itbs_id='" + itbsid + "' AND sm.sm_delivery_status=1");
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {

            sb.Append("" + dt.Rows[i]["itbs_id"] + "@#$" + dt.Rows[i]["branch_id"] + "@#$" + dt.Rows[i]["itm_id"] + "@#$" + dt.Rows[i]["itbs_stock"] + "@#$" + dt.Rows[i]["itbs_reorder"] + "@#$" + dt.Rows[i]["itbs_available"] + "@#$" + dt.Rows[i]["itm_mrp"] + "@#$" + dt.Rows[i]["itm_class_one"] + "@#$" + dt.Rows[i]["itm_class_two"] + "@#$" + dt.Rows[i]["itm_class_three"] + "@#$" + dt.Rows[i]["itm_commision"] + "@#$" + dt.Rows[i]["itm_target"] + "@#$" + dt.Rows[i]["itm_name"] + "@#$" + dt.Rows[i]["tp_tax_code"] + "@#$" + dt.Rows[i]["itbs_duration"] + "@#$" + dt.Rows[i]["itm_rating"] + "@#$" + stock_new + "@#$" + stock_processed + "@#$" + dt.Rows[i]["itbs_purchase_price"]);
        }

        //" '" + dt.Rows[i]["servicecode"] + "','" + dt.Rows[i]["servicedescription"] + "','" + dt.Rows[i]["servicegroup"] + "','" + dt.Rows[i]["serviceperiod"] + "','" + dt.Rows[i]["servicetype"] + "','" + dt.Rows[i]["serviceprice"] + "','" + dt.Rows[i]["servicesession"] + "','" + dt.Rows[i]["CountryId"] + "','" + dt.Rows[i]["Tax"] + "' ";

        return sb.ToString();

    }


    //show items
    //[WebMethod]
    //public static string showsearchItems()
    //{

    //    mySqlConnection db = new mySqlConnection();
    //    DataTable dt = new DataTable();
    //    StringBuilder sb = new StringBuilder();
    //    string query = "SELECT itm_id,itm_name FROM tbl_item_master ORDER BY itm_id ASC";
    //    dt = db.SelectQuery(query);
    //    if (dt != null)
    //    {
    //        if (dt.Rows.Count > 0)
    //        {
    //            if (dt.Rows[0]["itm_id"] is DBNull)
    //            {
    //                sb.Append("<select id='combosearchitemtype' style='margin-left:5px;width:250px;' class='normaltextbg' onchange='searchBranchStockdetail(1)'>");
    //                sb.Append("<option value='0' selected='selected'>Select</option>");
    //                sb.Append("</select>");
    //            }
    //            else
    //            {
    //                sb.Append("<select id='combosearchitemtype' style='margin-left:5px;width:250px;' class='normaltextbg' onchange='searchBranchStockdetail(1)'>");
    //                sb.Append("<option value='0' selected='selected'>Select</option>");
    //                for (int i = 0; i < dt.Rows.Count; i++)
    //                {

    //                    sb.Append("<option value='" + dt.Rows[i]["itm_id"] + "'>" + dt.Rows[i]["itm_name"] + "</option>");

    //                }
    //                sb.Append("</select>");
    //            }
    //        }
    //        else
    //        {
    //            sb.Append("<select id='combosearchitemtype'>");
    //            sb.Append("</select>");
    //        }
    //    }
    //    return sb.ToString();
    //}

    //show branches
    [WebMethod]
    public static string showsearchBranches()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        //string query = "SELECT branch_id,branch_name FROM tbl_branch ORDER BY branch_id ASC";
        string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["branch_id"] is DBNull)
                {
                    // sb.Append("<select id='combosearchbranchtype' class='form-control' style='text-indent:25px;' onchange=''>");
                    sb.Append("<option value='0' selected='selected'>--All Warehouses--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                    // sb.Append("<select id='combosearchbranchtype' class='form-control' style='text-indent:25px;' onchange=''>");
                    sb.Append("<option value='0' selected='selected'>--All Warehouses--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["branch_id"] + "'>" + dt.Rows[i]["branch_name"] + "</option>");

                    }
                    //sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='0' selected>--All Warehouses--</option>");
                // sb.Append("<select id='combosearchbranchtype'>");
                // sb.Append("</select>");
            }
        }
        return sb.ToString();
    }
    [WebMethod]
    public static string loadCategory()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT cat_id, cat_name FROM tbl_item_category ORDER BY cat_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["cat_id"] is DBNull)
                {
                    // sb.Append("<select id='combosearchcategory' class='form-control' style='text-indent:25px;'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    // sb.Append("</select>");
                }
                else
                {
                    //sb.Append("<select id='combosearchcategory' class='form-control' style='text-indent:25px;'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                    //sb.Append("</select>");
                }
            }
            else
            {
                // sb.Append("<select id='combosearchcategory' class='form-control' style='text-indent:25px;'>");
                sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                //sb.Append("</select>");
            }
        }

        return sb.ToString();
    }
    [WebMethod]
    public static string loadbrands()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT brand_id, brand_name FROM tbl_item_brand ORDER BY brand_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["brand_id"] is DBNull)
                {
                    // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                    // sb.Append("</select>");
                }
                else
                {
                    // sb.Append("<select id='combobranddiv' class='form-control' style='text-indent:25px;'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["brand_id"] + "'>" + dt.Rows[i]["brand_name"] + "</option>");

                    }
                    // sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                //sb.Append("<select id='combobranddiv'>");
                //sb.Append("</select>");
            }
        }

        return sb.ToString();
    }


    //start: Item Pos Search Details
    [WebMethod]
    public static string searchItem(int page, Dictionary<string, string> Itemfilters, int perpage)
    {

        // string outputval = "okkkkkkkkkkk";
        try{
 
           // var isConditionNeed = 0;
            string query_condition = "";
            if (Itemfilters.Count > 0)
            {
                query_condition = " where 1=1 and itm_id NOT IN(select itm_id from tbl_itembranch_stock where branch_id=" + Itemfilters["warehouse"] + ")";
                if (Itemfilters.ContainsKey("item_code"))
                {
                   // isConditionNeed = 1;
                    query_condition += " and itm_code LIKE '%" + Itemfilters["item_code"] + "%'";
                }
                if (Itemfilters.ContainsKey("item_name"))
                {
                   // isConditionNeed = 1;
                    query_condition += " and itm_name LIKE '%" + Itemfilters["item_name"] + "%'";
                }
            }
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            mySqlConnection db = new mySqlConnection();
            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_item_master " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));

            innerqry = "SELECT itm_id,itm_code,itm_name FROM tbl_item_master " + query_condition;

            innerqry = innerqry + " order by itm_name LIMIT " + offset.ToString() + " ," + per_page;
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
            string query = "SELECT tp_tax_code,tp_tax_title FROM tbl_tax_profile where tp_tax_type=" + taxType+ " ORDER BY tp_tax_code ASC";
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
}
           //if (isConditionNeed == 1) {
            //    searchResult = "where " + searchResult;
            //}