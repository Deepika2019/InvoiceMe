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

public partial class inventory_stockTransfer : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication stockTransfer = new LoginAuthentication();
        stockTransfer.userAuthentication();
        stockTransfer.checkPageAcess(14);
    }
    [WebMethod]
    public static string getBranches()
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        //string query = "SELECT Id, Name,CountryId FROM Branch ORDER BY Name ASC";
      //  string query = "select tb.branch_id,branch_name from tbl_branch tb inner join tbl_user_branches ub on ub.branch_id=tb.branch_id where user_id=" + HttpContext.Current.Request.Cookies["invntrystaffId"].Value;
        string query = "select branch_id,branch_name from tbl_branch";
      //  query = query + " order by tbl_branch.branch_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);
    }

    [WebMethod]
    public static string searchTransferitem(int page, Dictionary<string, string> filters, int perpage)
    {
        try
        {

            string query_condition = "";
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
            DataTable dtcount = new DataTable();
            string innerqry = "";
            string countQry = "";
            double numrows = 0;


            countQry = "SELECT count(itbs_id) as count,tb.branch_name as branch from tbl_itembranch_stock tis inner join tbl_branch tb on tb.branch_id=tis.branch_id where tis.branch_id=" + filters["fromWarehouse"] + "  and itm_id in (select itm_id from tbl_itembranch_stock where branch_id=" + filters["toWarehouse"] + ")  and itbs_stock!=0 " + query_condition + " ";
            dtcount = db.SelectQuery(countQry);
            numrows = Convert.ToInt32(dtcount.Rows[0]["count"]);
            if (numrows == 0)
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"There is no items/enough stocks found in " + dtcount.Rows[0]["branch"] + ", Please add item \"}";
            }
            innerqry = "SELECT itm_id as itemId,itbs_id,itm_name as itemName,itm_code as itemCode,itbs_stock as stock,0 as centralId from tbl_itembranch_stock where branch_id=" + filters["fromWarehouse"] + "  and itm_id in (select itm_id from tbl_itembranch_stock where branch_id=" + filters["toWarehouse"] + ")  and itbs_stock!=0";
            innerqry = innerqry + query_condition + "  order by itbs_id LIMIT " + offset.ToString() + " ," + per_page;


            int total_pages = Convert.ToInt32(Math.Ceiling(numrows / per_page));
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

    [WebMethod(EnableSession = true)]
    public static string GetAutoCompleteItemData(string variable, string fromWarehose, string toWarehose)
    {
        StringBuilder sb = new StringBuilder();
        //List<string> custNames = new List<string>();
        mySqlConnection db = new mySqlConnection();
        string innerqry = "";
        innerqry = "SELECT itm_id as itemId,itbs_id,itm_name as itemName,itm_code as itemCode,itbs_stock as stock from tbl_itembranch_stock where branch_id=" + fromWarehose + "  and itm_id in (select itm_id from tbl_itembranch_stock where branch_id=" + toWarehose + ")";
        innerqry = innerqry + " and itbs_stock!=0 and itm_name like '%" + variable + "%' ";


        DataTable QryTable = db.SelectQuery(innerqry);
        if (QryTable.Rows.Count > 0)
        {
            sb.Append("[");
            foreach (DataRow row in QryTable.Rows)
            {
                sb.Append("{\"id\":\"" + Convert.ToString(row["itemId"]) + "\",");
                sb.Append("\"label\":\"" + Convert.ToString(row["itemName"]) + "\",");
                sb.Append("\"value\":\"" + Convert.ToString(row["itemName"]) + "\",");
                sb.Append("\"code\":\"" + Convert.ToString(row["itemCode"]) + "\",");
                sb.Append("\"stock\":\"" + Convert.ToString(row["stock"]) + "\"}");
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
    public static string saveTransferItems(Dictionary<string, string> filters, string tableString)
    {
        string checkstatus = "N";
        mySqlConnection db = new mySqlConnection();
        try
        {
            string updateFromBranchStockQry = "";
            string Insertquery = "";
            string updateToBranchStockQry = "";
            DataTable dt = new DataTable();
            TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(filters["TimeZone"]);
            DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
            string currdatetime = TimeNow.ToString("yyyy/MM/dd HH:mm:ss");
            //  string jsonData = JsonConvert.SerializeObject(tableString);
            dynamic data = JsonConvert.DeserializeObject(tableString);
            db.BeginTransaction();

            Insertquery = "INSERT INTO  tbl_stock_transfer_header (user_id,st_from_branch_id,st_to_branch_id,st_date,st_type)";
            Insertquery = Insertquery + "VALUES ('" + filters["userId"] + "','" + filters["fromWarehouse"] + "','" + filters["toWarehouse"] + "',";
            Insertquery = Insertquery + "'" + currdatetime + "','1');Select last_insert_id();";
            int st_id = Convert.ToInt32(db.SelectScalarForTransaction(Insertquery));
            if (st_id != 0)
            {
                StringBuilder sb_bulk_stkTrQry = new StringBuilder();
                sb_bulk_stkTrQry.Append("INSERT INTO `tbl_stock_transactions` (`itbs_id`,`action_type`,`action_ref_id`,`user_id`,`narration`,`dr_qty`,`cr_qty`,`closing_stock`,`date`) VALUES ");
                foreach (var item in data)
                {
                    db.ExecuteQueryForTransaction("insert into tbl_stock_transfer_items values(null," + st_id + "," + item.itemId + "," + item.stock + ")");
                    updateFromBranchStockQry = "update tbl_itembranch_stock set itbs_stock=itbs_stock-" + item.stock + " where itm_id=" + item.itemId + " and branch_id=" + filters["fromWarehouse"] + "";
                    if (db.ExecuteQueryForTransaction(updateFromBranchStockQry))
                    {
                        sb_bulk_stkTrQry.Append("((select itbs_id from tbl_itembranch_stock where itm_id=" + item.itemId + " and branch_id=" + filters["fromWarehouse"] + "),'" + ((int)Constants.ActionType.STOCK_TRANSFER) + "','" + st_id + "','" + filters["userId"] + "'");
                        sb_bulk_stkTrQry.Append(",CONCAT('Debiting of quantity " + item.stock + "' , (select itm_name from tbl_item_master where itm_id='" + item.itemId + "'),' after the stock transfer #" + st_id + "'),'" + item.stock + "','0'");
                        sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itm_id=" + item.itemId + " and branch_id=" + filters["fromWarehouse"] + ")");
                        sb_bulk_stkTrQry.Append(",'" + currdatetime + "'),");

                        updateToBranchStockQry = "update tbl_itembranch_stock set itbs_stock=itbs_stock+" + item.stock + " where itm_id=" + item.itemId + " and branch_id=" + filters["toWarehouse"] + "";
                        if (db.ExecuteQueryForTransaction(updateToBranchStockQry))
                        {
                            sb_bulk_stkTrQry.Append("((select itbs_id from tbl_itembranch_stock where itm_id=" + item.itemId + " and branch_id=" + filters["toWarehouse"] + "),'" + ((int)Constants.ActionType.STOCK_TRANSFER) + "','" + st_id + "','" + filters["userId"] + "'");
                            sb_bulk_stkTrQry.Append(",CONCAT('Crediting of quantity " + item.stock + "' , (select itm_name from tbl_item_master where itm_id='" + item.itemId + "'),' after the stock transfer #" + st_id + "'),'0','" + item.stock + "'");
                            sb_bulk_stkTrQry.Append(",(select itbs_stock from tbl_itembranch_stock where itm_id=" + item.itemId + " and branch_id=" + filters["toWarehouse"] + ")");
                            sb_bulk_stkTrQry.Append(",'" + currdatetime + "'),");
                        }
                    }
                }
                sb_bulk_stkTrQry.Length--;
                db.ExecuteQueryForTransaction(sb_bulk_stkTrQry.ToString());
            }



            checkstatus = "Y";
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try
            {
                checkstatus = "N";
                db.RollBackTransaction();
                LogClass log = new LogClass("stockTransfer");
                log.write(ex);
            }
            catch
            {
            }
        }
        return checkstatus;


        //change code
    }
}