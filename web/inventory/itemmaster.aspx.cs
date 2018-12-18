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

public partial class inventory_itemmaster : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication itemMaster = new LoginAuthentication();
        itemMaster.userAuthentication();
        itemMaster.checkPageAcess(12);
    }
    ////loading brand
    [WebMethod]
    public static string showBrands()
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
                    //sb.Append("<select id='comboBrandtype' style='width:200px;margin-top:6px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                    //sb.Append("<select id='comboBrandtype' style='width:255px; height:24px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["brand_id"] + "'>" + dt.Rows[i]["brand_name"] + "</option>");

                    }
                    //sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                //sb.Append("<select id='comboBrandtype'>");
               // sb.Append("</select>");
            }
        }

        return sb.ToString();
    }

    ////loading supplier list
    [WebMethod]
    public static string showsupplierlist()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT vendor_id, name FROM tbl_vendor ORDER BY vendor_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["vendor_id"] is DBNull)
                {
                    sb.Append("<select id='combovendorlist' style='width:255px; height:24px; margin-left:10px;' class='normaltextbg'>");
                    sb.Append("<option value='0' selected='selected'>Select</option>");
                    sb.Append("</select>");
                }
                else
                {
                    sb.Append("<select id='combovendorlist' style='width:255px; height:24px;margin-left:10px;' class='normaltextbg'>");
                    sb.Append("<option value='0' selected='selected'>Select</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["vendor_id"] + "'>" + dt.Rows[i]["name"] + "</option>");

                    }
                    sb.Append("</select>");
                }
            }
            else
            {
                sb.Append("<select id='combovendorlist' style='width:200px;margin-top:6px;margin-left:10px;' class='normaltextbg'>");
                sb.Append("</select>");
            }
        }


        return sb.ToString();
    }

    ////loading categorytypes
    [WebMethod]
    public static string showCategoryTypes()
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
                    //sb.Append("<select id='combocategory' style='width:255px; height:24px;' class='normaltextbg' onchange='javascript:loadsubcategory(0);'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                   // sb.Append("</select>");
                }
                else
                {
                    //sb.Append("<select id='combocategory' style='width:255px; height:24px;' class='normaltextbg' onchange='javascript:loadsubcategory(0);'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                   // sb.Append("</select>");
                }
            }
            else
            {
               // sb.Append("<select id='combocategory' style='width:200px;margin-top:6px;' class='normaltextbg' onchange='javascript:loadsubcategory(0);'>");
                sb.Append("<option value='-1' selected='selected'>--Category--</option>");
               // sb.Append("</select>");
            }
        }

        return sb.ToString();
    }

    //save and update itemdetails
    [WebMethod]
    public static string Additemmasters(string actionType, string itemid, string itemcode, string itemname, string itemdesc, string itmbrand, string itmcatgry, string itmsubcategory, string supplier, int itemType, int couponItemId, int quantity)
    {

        String resultStatus;
        resultStatus = "N";
        bool queryStatus;
        string query = "";

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        Int32 itemId1 = 0;

        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {



            string qry = "select MAX(itm_id) as itm_id from tbl_item_master";
            dt = db.SelectQuery(qry);

            if (dt != null)
            {
                if (dt.Rows[0][0] is DBNull)
                {
                    itemId1 = ++itemId1;
                }
                else
                {
                    itemId1 = Convert.ToInt32(dt.Rows[0][0]);
                    itemId1 = ++itemId1;
                }
            }
            else
            {
                itemId1 = ++itemId1;
            }

            //check is unique?
            // String chk_qry = "SELECT count(*) FROM  item_tbl WHERE (item_code = '" + itemcode + "')";

            String chk_qry = "SELECT count(*) FROM  tbl_item_master WHERE (itm_code = '" + itemcode + "' OR itm_name = '" + itemname + "')";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows > 0)
            {
                return "E";
            }
            else
            {
                query = "INSERT INTO tbl_item_master (itm_id, itm_code, itm_name, itm_description, itm_brand_id, itm_category_id,itm_subcategory_id,itm_supplierid,itm_type)";
                query = query + "VALUES (null,'" + itemcode + "','" + itemname + "','" + itemdesc + "','" + itmbrand + "','" + itmcatgry + "','" + itmsubcategory + "','" + supplier + "'," + itemType + ")";
                if (db.ExecuteQuery(query))
                {
                    if (itemType == 1)
                    {
                        if ((db.ExecuteQuery("INSERT INTO tbl_coupon_master(cpn_id,cpn_itm_id,cpn_qty,itm_id) VALUES(NULL," + itemId1 + "," + quantity + "," + couponItemId + ")") == true))
                        {
                            resultStatus = "Y";
                        }
                        else
                        {
                            return "E";
                        }
                    }
                    resultStatus = "Y";
                }
              
            }

        }


        if (actionType == "update")
        {
            String chk_qry = "SELECT count(*) FROM  tbl_item_master WHERE itm_id = '" + itemid + "'";
            double numrows = Convert.ToInt32(db.SelectScalar(chk_qry));
            if (numrows < 0)
            {
                return "E";
            }
            else
            {
                String updatechk_qry = "SELECT count(*) FROM  tbl_item_master WHERE (itm_id!='" + itemid + "' and (itm_code = '" + itemcode + "' OR itm_name = '" + itemname + "' ))";
                double checknumrows = Convert.ToInt32(db.SelectScalar(updatechk_qry));
                if (checknumrows > 0)
                {
                    return "E";
                }
                query = "UPDATE tbl_item_master SET ";
                query = query + "itm_code='" + itemcode + "',itm_name='" + itemname + "',itm_description='" + itemdesc + "',itm_brand_id='" + itmbrand + "',itm_category_id='" + itmcatgry + "',itm_subcategory_id='" + itmsubcategory + "',itm_supplierid='" + supplier + "',itm_type=" + itemType + " WHERE itm_id='" + itemid + "' ";
                queryStatus = db.ExecuteQuery(query);
                if (queryStatus)
                {
                    db.ExecuteQuery("update tbl_itembranch_stock set itm_last_update_date='" + updatedDate + "' where itm_id=" + itemid + "");
                    db.ExecuteQuery("UPDATE tbl_itembranch_stock SET itm_code='" + itemcode + "',itm_name='" + itemname + "',itm_brand_id='" + itmbrand + "',itm_category_id='" + itmcatgry + "' WHERE itm_id='" + itemid + "' ");
                    if (itemType == 1)
                    {

                        if ((db.ExecuteQuery("UPDATE tbl_coupon_master SET itm_id='" + couponItemId + "',cpn_qty='" + quantity + "' WHERE cpn_itm_id='" + itemid + "'") == true))
                        {
                            resultStatus = "Y";
                        }
                        else
                        {
                            return "E";
                        }
                    }
                    //return "y";
                    resultStatus = "Y";
                }
            }
        }

     
       
        // Response.Redirect("~/ManagePatientsAlertAndSurvey.aspx?id="+ViewState["patientId"].ToString()+"");


        return resultStatus;
    }



    //search function and itemlisting
    [WebMethod]
    public static string searchItemList(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = "";
            if (filters.Count > 0)
            {
                query_condition = " where 1=1";
                if (filters.ContainsKey("search"))
                {
                    query_condition += "  and (itm_name LIKE '%" + filters["search"] + "%' or itm_code like '%" + filters["search"] + "%')";
                }
              
                if (filters.ContainsKey("brandid"))
                {
                    query_condition += " and (itm_brand_id='" + filters["brandid"] + "')";
                }
                if (filters.ContainsKey("categoryid"))
                {
                    query_condition += " and (itm_category_id='"  + filters["categoryid"] + "')";
                }
                if (filters.ContainsKey("itemType"))
                {
                    query_condition += " and (itm_type='" + filters["itemType"] + "')";
                }
            }
            mySqlConnection db = new mySqlConnection();
            DataTable dt = new DataTable();
            StringBuilder sb = new StringBuilder();
            double per_page = perpage;
            double offset = (page - 1) * per_page;
            string innerqry = "";
            double numrows = 0;
            string countQry = " select Count(*) ";
            countQry = countQry + " from tbl_item_master ";
            countQry = countQry + " " + query_condition;
            numrows = Convert.ToInt32(db.SelectScalar(countQry));
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            if (perpage == 0)
            {
                per_page = numrows;
            }
            if (numrows == 0)
            {
                return "N";
            }
            innerqry = "SELECT itm_id,itm_code,itm_name,itm_brand_id,itm_category_id,c.brand_name,cs.cat_name from tbl_item_master im inner join tbl_item_brand c on c.brand_id=im.itm_brand_id inner join tbl_item_category cs on cs.cat_id=im.itm_category_id";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + " order by itm_id LIMIT " + offset.ToString() + " ," + per_page;
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

    //edit item details
    [WebMethod]
    public static string editItemDetails(string itmid)
    {
        
        mySqlConnection db = new mySqlConnection();
        string qry = "SELECT im.itm_id,im.itm_code,im.itm_name,im.itm_description,im.itm_category_id,im.itm_supplierid,im.itm_brand_id,im.itm_subcategory_id,cm.itm_id as couponItemId,cm.cpn_qty as quantity,t2.itm_name as copnItem,im.itm_type FROM `tbl_item_master` im left join  tbl_coupon_master cm on cm.cpn_itm_id=im.itm_id left join tbl_item_master t2 on t2.itm_id = cm.itm_id where im.itm_id='" + itmid + "'";
        DataTable dt = db.SelectQuery(qry);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    //load brands for search
    [WebMethod]
    public static string showsearchbrands()
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
                    //sb.Append("<select id='combobranddiv' style='width:200px;margin-top:0px; margin-left:2px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Brand--</option>");
                   // sb.Append("</select>");
                }
                else
                {
                   // sb.Append("<select id='combobranddiv' style='width:200px;margin-top:0px; margin-left:2px;' class='normaltextbg'>");
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
               // sb.Append("</select>");
            }
        }

        return sb.ToString();
    }


    ////loading serach categorytypes
    [WebMethod]
    public static string loadsearchcategory()
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
                    //sb.Append("<select id='combosearchcategory' style='width:200px;margin-top:0px; margin-left:2px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    //sb.Append("</select>");
                }
                else
                {
                   // sb.Append("<select id='combosearchcategory' style='width:200px;margin-top:0px; margin-left:2px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                   // sb.Append("</select>");
                }
            }
            else
            {
                //sb.Append("<select id='combosearchcategory' style='width:110px;margin-top:0px;' class='normaltextbg'>");
                sb.Append("<option value='-1' selected='selected'>--Category--</option>");
                //sb.Append("</select>");
            }
        }

        return sb.ToString();
    }



    ////loading subcategorytypes
    [WebMethod]
    public static string showSubCategoryTypes(string categoryVal)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "SELECT cat_id, cat_name FROM tbl_item_category where parent_id=" + categoryVal + " ORDER BY cat_id ASC";
        dt = db.SelectQuery(query);
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["cat_id"] is DBNull)
                {
                    //sb.Append("<select id='combosubcategory' style='width:200px;margin-top:6px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Subcategory--</option>");
                    //  sb.Append("</select>");
                }
                else
                {
                    // sb.Append("<select id='combosubcategory' style='width:200px;margin-top:6px;' class='normaltextbg'>");
                    sb.Append("<option value='-1' selected='selected'>--Subcategory--</option>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {

                        sb.Append("<option value='" + dt.Rows[i]["cat_id"] + "'>" + dt.Rows[i]["cat_name"] + "</option>");

                    }
                    // sb.Append("</select>");
                }
            }
            else
            {
                // sb.Append("<select id='combosubcategory' style='width:200px;margin-top:6px;' class='normaltextbg'>");
                sb.Append("<option value='-1' selected='selected'>--Subcategory--</option>");
                //  sb.Append("</select>");
            }
        }

        return sb.ToString();
    }


    //start: Item Pos Search Details
    [WebMethod]
    public static string searchOrderitem(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {
            string query_condition = " where 1=1 ";
            if (filters.Count > 0)
            {
                
                if (filters.ContainsKey("itemname"))
                {
                    query_condition += " and itm_name  LIKE '%" + filters["itemname"] + "%'";
                }
                if (filters.ContainsKey("itemcode"))
                {
                    query_condition += " and itm_code  LIKE '%" + filters["itemcode"] + "%'";
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

            innerqry = "SELECT itm_id,itm_code,itm_name from tbl_item_master";
            innerqry = innerqry + query_condition + " ";
            innerqry = innerqry + " order by itm_id LIMIT " + offset.ToString() + " ," + per_page;
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
    //stop: Item Pos Search Details

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteItemData(string variable)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string sqlQuery = "SELECT itm_name,itm_id from tbl_item_master where 1  and itm_name like '%" + variable + "%' limit 0,20";
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

}