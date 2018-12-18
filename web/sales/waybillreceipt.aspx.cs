using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using System.Dynamic;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using iTextSharp.text.xml;
using iTextSharp.text.html;

using System.Net;
using System.Net.Mail;
using iTextSharp.tool.xml;

public partial class sales_waybillreceipt : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string showWayBillReceipt(string billno, string headerid)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        try
        {
            sb.Append("{");
            //fetching order details
            String orderQry = "SELECT cu.cust_id, wh.sm_id, cu.cust_name,concat(ud.first_name,' ',ud.last_name) as staff_name,cu.cust_address as address,cu.cust_city as city,cu.cust_country as country,cust_reg_id as gst,cu.cust_state as state,cu.cust_phone as phone,cu.cust_email as email ,DATE_FORMAT(wh.wh_date, '%d-%b-%Y %h:%i %p') as date,wh.wh_userid,wh.branch_id,sm_invoice_no as invoiceNum,sm_refno "
           + "  FROM tbl_waying_header wh inner join tbl_customer cu on cu.cust_id=wh.cust_id left join tbl_user_details ud on ud.user_id=wh.wh_userid inner join tbl_waying_items tsi on tsi.sm_id=wh.sm_id inner join tbl_sales_master tsm on tsm.sm_id=wh.sm_id WHERE wh.sm_id ='" + billno + "' and wh.wh_id='" + headerid + "'";
            DataTable dtOrder = db.SelectQuery(orderQry);
            sb.Append("\"order\":");
            sb.Append(JsonConvert.SerializeObject(dtOrder, Formatting.Indented));
            // fetching branch details
            string branchQry = "SELECT branch_id,branch_name,branch_countryid,branch_bill_disclosure,branch_bill_footer,branch_address,branch_country_name,branch_image,branch_reg_id,branch_email,branch_declaration FROM tbl_branch WHERE branch_id='" + Convert.ToString(dtOrder.Rows[0]["branch_id"]) + "' ";
            DataTable dtBranches = db.SelectQuery(branchQry);
            sb.Append(",");
            sb.Append("\"branch\":");
            sb.Append(JsonConvert.SerializeObject(dtBranches, Formatting.Indented));
            //fetching order items
            string qryWayItems = "SELECT `itm_code`, `itm_name`, `wi_stock` as stock"
                + " , wi.itbs_id as itemid "
                + " FROM `tbl_waying_items` as wi inner join tbl_sales_items as sales on wi.sm_id=sales.sm_id and wi.itbs_id=sales.itbs_id WHERE wi.sm_id='" + billno + "' and wi.wh_id ='" + headerid + "'";
            DataTable dtWayItems = db.SelectQuery(qryWayItems);
            sb.Append(",");
            sb.Append("\"items\":");
            sb.Append(JsonConvert.SerializeObject(dtWayItems, Formatting.Indented));
            sb.Append(",");
            sb.Append("\"Vehicle\":");
            DataTable dtvehicle = db.SelectQuery("select `sm_vehicle_no`,concat(first_name,last_name)as vehicle_name from tbl_sales_master left join tbl_user_details on user_id=sm_delivery_vehicle_id where sm_id=" + billno);
            sb.Append(JsonConvert.SerializeObject(dtvehicle, Formatting.Indented));
            sb.Append("}");
            return sb.ToString();
        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "";
        }
    }
}