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
using System.Globalization;

public partial class inventory_offers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication offer = new LoginAuthentication();
        offer.userAuthentication();
        offer.checkPageAcess(16);
    }
      [WebMethod]
    public static string searchOrderitem(string BranchId, int perpage, int page, Dictionary<string, string> filters)
    {

        try
        {
            string query_condition = "where 1=1";
            if (filters.Count > 0)
            {
                //query_condition = " where 1=1";
                if (filters.ContainsKey("itm_code"))
                {
                    query_condition += " and itm_code LIKE '%" + filters["itm_code"] + "%'";
                }
                if (filters.ContainsKey("itm_name"))
                {
                    query_condition += " and itm_name LIKE '%" + filters["itm_name"] + "%'";
                }
            }
            query_condition += " and branch_id='" + BranchId + "' and itbs_available = '1' ";

            mySqlConnection db = new mySqlConnection();
            int per_page = perpage;
            int offset = (page - 1) * per_page;
            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_itembranch_stock " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            innerqry = "SELECT itbs_id,itm_id,itbs_stock,itbs_reorder,itm_code,itm_name,itm_brand_id,itm_category_id,itm_mrp,itm_class_one,itm_class_two,itm_class_three,tib.brand_name,tic.cat_name from tbl_itembranch_stock tis left join tbl_item_brand tib on tib.brand_id=tis.itm_brand_id left join tbl_item_category tic on tic.cat_id=tis.itm_category_id ";
            innerqry = innerqry + query_condition + " and itbs_stock>0";
            innerqry = innerqry + " order by itbs_id LIMIT " + offset.ToString() + " ," + per_page;
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
      public static string addOfferItem(string offer_type, string offerTitle, string start_date, string end_date, string offer_price, string discount, string foc_Qty, string limit_foc, string item_Qty, string item_price, string actionType, string offerCode, string status, string item_id, string itbs_id, string band_price, string band_qty, string offer_id, string totalprice, string warehouseId, string ofr_commission)
    {
        
        String resultStatus;
        string itbs_ids = itbs_id.TrimEnd('#');
        string rplce= itbs_ids.Replace("#", ",");
        string[] itemidvalues = rplce.Split(',');
        for (int i = 0; i < itemidvalues.Length; i++)
        {
            itemidvalues[i] = itemidvalues[i].Trim();
        }
        int length=itemidvalues.Length;
        string band_qtys = band_qty.TrimEnd('#');
        string rplceqty = band_qtys.Replace("#", ",");
        string[] band_offerqty = rplceqty.Split(',');

        string band_prices = band_price.TrimEnd('#');
        string rplcebandprice = band_prices.Replace("#", ",");
        string[] band_offerprice = rplcebandprice.Split(',');
        
        //string[] band_warehouse=warehouseIds.Split(',');
        //int length = rplce.Length;
        resultStatus = "N";
        bool queryStatus;
        bool queryStatus1;
        bool queryStatus2;
       // bool queryStatus3;
        mySqlConnection db = new mySqlConnection();
        string query = "";
        string insQry = "";
        //string warehouseQry = "";
      // string startDate = string.Format("{0:yyyy-MM-dd}", Convert.ToDateTime(start_date));
        
    // string endDate = string.Format("{0:yyyy-MM-dd}", Convert.ToDateTime(end_date));
      // DateTime startDate = DateTime.Parse(start_date);
        //return end_date;
        //string endDate = Convert.ToDateTime(end_date).ToString("yyyy-MM-dd HH:mm:ss");
        //string startDate = Convert.ToDateTime(start_date).ToString("yyyy-MM-dd HH:mm:ss");
        
     
        //return startDate + "" + endDate;
        string startDate = DateTime.ParseExact(start_date, "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("yyyy-MM-dd HH:mm:ss");
       //return startDate.ToString();
      // DateTime endDate = DateTime.Parse(end_date);
        //string endDate = Convert.ToDateTime(end_date).ToString("yyyy-MM-dd HH:mm:ss");
       string endDate = DateTime.ParseExact(end_date, "yyyy-MM-dd", CultureInfo.InvariantCulture).ToString("yyyy-MM-dd HH:mm:ss");
        if (actionType == "insert")
        {
            string qry = "select MAX(ofr_id) as id from tbl_offer_master";
            DataTable dt = new DataTable();
            dt = db.SelectQuery(qry);
            Int32 ofr_id = 0;
            if (dt != null)
            {

                if (dt.Rows[0][0] is DBNull)
                {
                    ofr_id = ++ofr_id;
                }
                else
                {
                    ofr_id = Convert.ToInt32(dt.Rows[0][0]);
                    ofr_id = ++ofr_id;
                }
            }
            else
            {
                ofr_id = ++ofr_id;
            }

            //string wareQry = "select MAX(ofrware_id) as id from tbl_offer_warehouse";
            //DataTable dt4 = new DataTable();
            //dt4 = db.SelectQuery(qry);
            //Int32 ofrware_id = 0;
            //if (dt4 != null)
            //{

            //    if (dt4.Rows[0][0] is DBNull)
            //    {
            //        ofrware_id = ++ofrware_id;
            //    }
            //    else
            //    {
            //        ofrware_id = Convert.ToInt32(dt4.Rows[0][0]);
            //        ofrware_id = ++ofrware_id;
            //    }
            //}
            //else
            //{
            //    ofrware_id = ++ofrware_id;
            //}
            //for (int i = 0; i < band_warehouse.Length; i++)
            //{
            //    warehouseQry = "INSERT INTO tbl_offer_warehouse(ofrware_id,ofr_id,branch_id)";
            //    warehouseQry = warehouseQry + "VALUES ('" + ofrware_id + "','" + ofr_id + "','" + band_warehouse[i] + "')";
            //    queryStatus3 = db.ExecuteQuery(warehouseQry);
            //}

            query = "INSERT INTO tbl_offer_master (ofr_id,branch_id,ofr_type,ofr_title, ofr_code, ofr_start_date, ofr_end_date,ofr_totalprice,ofr_price, ofr_focqty,ofr_focnum,ofr_discount,ofr_status,ofr_commission)";
            query = query + "VALUES ('" + ofr_id + "','" + warehouseId + "','" + offer_type + "','" + offerTitle + "','" + offerCode + "','" + startDate + "','" + endDate + "','" + totalprice + "','" + offer_price + "','" + limit_foc + "','" + foc_Qty + "','" + discount + "','" + status + "','" + ofr_commission + "')";
            queryStatus = db.ExecuteQuery(query);
            if (queryStatus)
            {
                string selQry = "select itm_code,itm_name from tbl_itembranch_stock where itbs_id='" + item_id + "'";
                DataTable dt1 = db.SelectQuery(selQry);
                string item_code = "";
                string item_name = "";
                //string item_commission = "";
                 //StringBuilder sb = new StringBuilder();
                 if (dt1 != null)
                 {
                   if (dt1.Rows.Count > 0)
                   {
                        item_code=dt1.Rows[0]["itm_code"].ToString();
                        item_name = dt1.Rows[0]["itm_name"].ToString();
                        //item_commission = dt1.Rows[0]["itm_commision"].ToString();
                   }
                 }
                 if (offer_type=="2")
                 {
                     for (int i = 0; i < itemidvalues.Length; i++)
                     {
                         string subqry = "select MAX(ofritm_id) as id from tbl_offer_items";
                         DataTable dt2 = new DataTable();
                         dt2 = db.SelectQuery(subqry);
                         Int32 ofr_Itmid = 0;
                         if (dt2 != null)
                         {

                             if (dt2.Rows[0][0] is DBNull)
                             {
                                 ofr_Itmid = ++ofr_Itmid;
                             }
                             else
                             {
                                 ofr_Itmid = Convert.ToInt32(dt2.Rows[0][0]);
                                 ofr_Itmid = ++ofr_Itmid;
                             }
                         }
                         else
                         {
                             ofr_Itmid = ++ofr_Itmid;
                         }
                         string bandSelQry = "select itm_code,itm_name from tbl_itembranch_stock where itbs_id='" + itemidvalues[i] + "'";
                         DataTable dt3 = db.SelectQuery(bandSelQry);
                         if (dt3 != null)
                        {
                            if (dt3.Rows.Count > 0)
                            {
                                item_code = dt3.Rows[0]["itm_code"].ToString();
                                item_name = dt3.Rows[0]["itm_name"].ToString();
                               // item_commission = dt3.Rows[0]["itm_commision"].ToString();
                                insQry = "INSERT INTO tbl_offer_items (ofritm_id,ofr_id,itbs_id,itm_code, itm_name, itm_price, itm_qty)";
                                insQry = insQry + "VALUES ('" + ofr_Itmid + "','" + ofr_id + "','" + itemidvalues[i] + "','" + item_code + "','" + item_name + "','" + band_offerprice[i] + "','" + band_offerqty[i] + "')";
                                queryStatus1 = db.ExecuteQuery(insQry);
                            }
                        }
                     }
                 }else{
                     string subqry = "select MAX(ofritm_id) as id from tbl_offer_items";
                     DataTable dt5 = new DataTable();
                     dt5 = db.SelectQuery(subqry);
                     Int32 ofr_Itmid = 0;
                     if (dt5 != null)
                     {

                         if (dt5.Rows[0][0] is DBNull)
                         {
                             ofr_Itmid = ++ofr_Itmid;
                         }
                         else
                         {
                             ofr_Itmid = Convert.ToInt32(dt5.Rows[0][0]);
                             ofr_Itmid = ++ofr_Itmid;
                         }
                     }
                     else
                     {
                         ofr_Itmid = ++ofr_Itmid;
                     }
                     insQry = "INSERT INTO tbl_offer_items (ofritm_id,ofr_id,itbs_id,itm_code, itm_name, itm_price, itm_qty)";
                    insQry = insQry + "VALUES ('" + ofr_Itmid + "','" + ofr_id + "','" + item_id + "','" + item_code + "','" + item_name + "','" + totalprice + "','1')";
                    queryStatus1 = db.ExecuteQuery(insQry);
                 }
                 //if (queryStatus1)
                 //{
                    resultStatus = "Y";
                //}
            }
        }
        if (actionType == "Update")
        {
            
            string selQry = "select itm_code,itm_name from tbl_itembranch_stock where itbs_id='" + item_id + "'";
            
            DataTable dt1 = db.SelectQuery(selQry);
            string item_code = "";
            string item_name = "";
            //string item_commission = "";
            //StringBuilder sb = new StringBuilder();
            if (dt1 != null)
            {
                if (dt1.Rows.Count > 0)
                {
                    item_code = dt1.Rows[0]["itm_code"].ToString();
                    item_name = dt1.Rows[0]["itm_name"].ToString();
                    //item_commission = dt1.Rows[0]["itm_commision"].ToString();
                }
            }
           //string expiry = start_date.ToString("yyyy/MM/dd HH:mm:ss");
           // string formatted = start_date.ToString("yyyy-MM-dd");
            //item_id==0,1
            //itbs_is===2
            //offer_id
            string updt_qry = "";
            if (offer_type == "0")
            {
               // return "g";
                updt_qry = "update tbl_offer_master as master inner join tbl_offer_items as items on master.ofr_id=items.ofr_id set ofr_type='" + offer_type + "', branch_id='" + warehouseId + "', ofr_title='" + offerTitle + "',ofr_code='" + offerCode + "',ofr_start_date='" + startDate + "', ofr_end_date='" + endDate + "', ofr_totalprice='" + totalprice + "', ofr_price='" + offer_price + "', ofr_discount='" + discount + "', ofr_status='" + status + "', itm_name='" + item_name + "', itm_price='" + offer_price + "',itm_code='" + item_code + "',ofr_commission='" + ofr_commission + "',ofr_focqty='" + limit_foc + "',itbs_id='" + item_id + "' where master.ofr_id='" + offer_id + "'";
                queryStatus2 = db.ExecuteQuery(updt_qry);
                //return updt_qry;
                resultStatus = "Y";
            }else if(offer_type == "1"){

                updt_qry = "update tbl_offer_master as master inner join tbl_offer_items as items on master.ofr_id=items.ofr_id set ofr_type='" + offer_type + "', branch_id='" + warehouseId + "', ofr_title='" + offerTitle + "',ofr_code='" + offerCode + "',ofr_start_date='" + startDate + "', ofr_end_date='" + endDate + "', ofr_totalprice='" + totalprice + "',ofr_price='" + offer_price + "', ofr_discount='" + discount + "', ofr_status='" + status + "', itm_name='" + item_name + "', itm_price='" + offer_price + "',itm_code='" + item_code + "',ofr_commission='" + ofr_commission + "',itbs_id='" + item_id + "',ofr_focqty='" + limit_foc + "',ofr_focnum='" + foc_Qty + "' where master.ofr_id='" + offer_id + "'";
               
                queryStatus2 = db.ExecuteQuery(updt_qry);
                
               //return updt_qry;
                resultStatus = "Y";
            }
            else if (offer_type == "2")
            {
                string subqry = "select MAX(ofritm_id) as id from tbl_offer_items";
                DataTable dt7= new DataTable();
                dt7 = db.SelectQuery(subqry);
                Int32 ofr_Itmid = 0;
                if (dt7 != null)
                {

                    if (dt7.Rows[0][0] is DBNull)
                    {
                        ofr_Itmid = ++ofr_Itmid;
                    }
                    else
                    {
                        ofr_Itmid = Convert.ToInt32(dt7.Rows[0][0]);
                        ofr_Itmid = ++ofr_Itmid;
                    }
                }
                else
                {
                    ofr_Itmid = ++ofr_Itmid;
                }
                updt_qry = "update tbl_offer_master as master inner join tbl_offer_items as items on master.ofr_id=items.ofr_id set ofr_type='" + offer_type + "',branch_id='" + warehouseId + "', ofr_title='" + offerTitle + "',ofr_code='" + offerCode + "',ofr_start_date='" + startDate + "', ofr_end_date='" + endDate + "', ofr_totalprice='" + totalprice + "',ofr_price='" + offer_price + "', ofr_discount='" + discount + "', ofr_status='" + status + "',ofr_commission='" + ofr_commission + "',ofr_focqty='" + limit_foc + "' where master.ofr_id='" + offer_id + "'";
                queryStatus2 = db.ExecuteQuery(updt_qry);
                //return updt_qry;
                resultStatus = "Y";
                string delQry = "delete from tbl_offer_items where ofr_id='" + offer_id + "' ";
                bool queryStatus6 = db.ExecuteQuery(delQry);
                if (queryStatus6)
                {
                    for (int i = 0; i < itemidvalues.Length; i++)
                    {
                        string bandSelQry = "select itm_code,itm_name from tbl_itembranch_stock where itbs_id='" + itemidvalues[i] + "'";
                        DataTable dt3 = db.SelectQuery(bandSelQry);
                        if (dt3 != null)
                        {
                            if (dt3.Rows.Count > 0)
                            {
                                item_code = dt3.Rows[0]["itm_code"].ToString();
                                item_name = dt3.Rows[0]["itm_name"].ToString();
                                //item_commission = dt3.Rows[0]["itm_commision"].ToString();
                                insQry = "INSERT INTO tbl_offer_items (ofritm_id,ofr_id,itbs_id,itm_code, itm_name, itm_price, itm_qty)";
                                insQry = insQry + "VALUES ('" + ofr_Itmid + "','" + offer_id + "','" + itemidvalues[i] + "','" + item_code + "','" + item_name + "','" + band_offerprice[i] + "','" + band_offerqty[i] + "')";
                                queryStatus1 = db.ExecuteQuery(insQry);
                                //updt_qry = "update tbl_offer_master as master inner join tbl_offer_items as items on master.ofr_id=items.ofr_id set ofr_type='" + offer_type + "', ofr_title='" + offerTitle + "',ofr_code='" + offerCode + "',ofr_start_date='" + start_date + "', ofr_end_date='" + end_date + "', ofr_price='" + offer_price + "', ofr_discount='" + discount + "', ofr_status='" + status + "', itm_name='" + item_name + "', itm_price='" + band_offerprice[i] + "',itm_code='" + item_code + "',itm_commision='" + item_commission + "',itbs_id='" + itemidvalues[i] + "',itm_qty='" + band_offerqty[i] + "' where master.ofr_id='" + offer_id + "'";
                                //queryStatus2 = db.ExecuteQuery(updt_qry);
                                resultStatus = "Y";
                            }
                        }
                    }
                }
            }
        }
        return resultStatus;
    }
    [WebMethod]
    public static string showOffers(int page, int perPage, Dictionary<string, string> filters, string startdate, string enddate, string offerstatus)
    {
        try
        {
            string query_condition = " where 1=1";
            if (filters.Count > 0)
            {
                //query_condition = " where 1=1";
                if (filters.ContainsKey("ofr_title"))
                {
                    query_condition += " and ofr_title LIKE '%" + filters["ofr_title"] + "%'";
                }
                if (filters.ContainsKey("ofr_code"))
                {
                    query_condition += " and ofr_code LIKE '%" + filters["ofr_code"] + "%'";
                }
                if (filters.ContainsKey("ofr_price"))
                {
                    query_condition += " and ofr_price LIKE '" + filters["ofr_price"] + "%'";
                }
                if (filters.ContainsKey("ofr_discount"))
                {
                    query_condition += " and ofr_discount LIKE '" + filters["ofr_discount"] + "%'";
                }
                if (filters.ContainsKey("warehouseId"))
                {
                    query_condition += " and (branch_id='" + filters["warehouseId"] + "')";
                }
            }
            if (startdate != "" && enddate != "")
            {

                query_condition += " and DATE_FORMAT(ofr_start_date,'%Y/%m/%d') between '" + startdate + "' AND '" + enddate + "' and DATE_FORMAT(ofr_end_date,'%Y/%m/%d') between '" + startdate + "' AND '" + enddate + "'";
            }
            else if (startdate != "" && enddate == "")
            {
                query_condition += " and DATE_FORMAT(ofr_start_date,'%Y/%m/%d') = '" + startdate + "' ";
            }
            else if (enddate != "" && startdate == "")
            {
                query_condition += " and DATE_FORMAT(ofr_end_date,'%Y/%m/%d') = '" + enddate + "' ";
            }
            if (offerstatus != "")
            {
                query_condition += " and ofr_status=" + offerstatus + "";
            }
            mySqlConnection db = new mySqlConnection();
            int per_page = perPage;
            int offset = (page - 1) * per_page;
            string innerqry = "";
            string countQry = "";
            countQry = "SELECT count(*) FROM tbl_offer_master " + query_condition;
            double numrows = Convert.ToInt32(db.SelectScalar(countQry));
            if (numrows == 0)
            {
                return "N";
            }
            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
            innerqry = "select tbl_offer_master.ofr_id,ofr_code,ofr_type,itm_price,itm_qty,ofr_status,ofr_title,ofr_price,ofr_discount,ofr_focqty,itm_name,itm_code,itbs_id,ofr_focnum, DATE_FORMAT(ofr_start_date ,'%d-%b-%Y') AS startDate,DATE_FORMAT(ofr_end_date ,'%d-%b-%Y') AS endDate from tbl_offer_master inner join tbl_offer_items on tbl_offer_master.ofr_id=tbl_offer_items.ofr_id ";
            innerqry = innerqry + query_condition;
            innerqry = innerqry + " group by tbl_offer_master.ofr_id LIMIT " + offset.ToString() + " ," + per_page;
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
    public static string editOffers(string item_id, string offer_id)
    {
        try
        {
            mySqlConnection db = new mySqlConnection();
            string query = "";
            query = "select tbl_offer_master.ofr_id,branch_id,ofr_code,ofr_type,itm_price,itm_qty,ofr_status,ofr_title,ofr_price,ofr_totalprice,ofr_discount,ofr_focqty,itm_name,itm_code,itbs_id,ofr_focnum, DATE_FORMAT(ofr_start_date ,'%Y-%m-%d') AS startDate,DATE_FORMAT(ofr_end_date ,'%Y-%m-%d') AS endDate,ofr_commission  from tbl_offer_master inner join tbl_offer_items on tbl_offer_master.ofr_id=tbl_offer_items.ofr_id where tbl_offer_master.ofr_id='" + offer_id + "'";
            //limit '" + perPage + "'
            //where tbl_offer_master.branch_id='" + branchId + "'"
            //inner join tbl_itembranch_stock on tbl_offer_master.itbs_id=tbl_itembranch_stock.itbs_id 
             DataTable dt = db.SelectQuery(query);
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
        catch (Exception ex)
        {
            return ex.ToString();
        }   
    }


    [WebMethod]
    public static string showWarehouses()
    {



        mySqlConnection db = new mySqlConnection();


        string innerqry = "select tb.branch_id as id,branch_name as name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
      //  innerqry = "SELECT branch_id as id, branch_name as name from tbl_branch ";
      //  innerqry = innerqry + "order by branch_name";

        //  string qry = " SELECT * FROM (" + innerqry + ") a WHERE a.row >" + offset.ToString() + " and a.row <= " + (offset + per_page).ToString();
        DataTable dt = db.SelectQuery(innerqry);
        string jsonResponse = "";
        if (dt.Rows.Count > 0)
        {
            jsonResponse = JsonConvert.SerializeObject(dt, Formatting.Indented);
        }
        else
        {
            jsonResponse = "N";
        }
        return jsonResponse;

    }  
}