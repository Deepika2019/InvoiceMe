using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using commonfunction;
using System.Data;
using System.Drawing;
using OfficeOpenXml;
using OfficeOpenXml.Style;

public partial class reports_DownloadPurchaseReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        string qry = Session["downloadqry"].ToString();
        dt = db.SelectQuery(qry);

        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {

                DumpExcel(dt);
            }

        }
    }

    //start: Creating XLSX from Data Table
    public void DumpExcel(DataTable tbl)
    {
        string rp_totalAmt = "";
        string rp_totalPaid = "";
        string fromdate = "";
        string reporttodate = "";
        double rp_balance = 0;

        string rp_fieldvalues = Convert.ToString(Session["rp_fieldvalues"]);
        String[] rp_splitarray = rp_fieldvalues.Split('*');

        rp_totalAmt = Convert.ToString(rp_splitarray[0]);
        rp_totalPaid = Convert.ToString(rp_splitarray[1]);
        rp_balance = Convert.ToDouble(rp_splitarray[0]) - Convert.ToDouble(rp_splitarray[1]);
        fromdate = Convert.ToString(rp_splitarray[2]);
        reporttodate = Convert.ToString(rp_splitarray[3]);

        int columlength = 0;
        columlength = tbl.Rows.Count;
        mySqlConnection db = new mySqlConnection();
        DataTable dt1 = new DataTable();

        for (int i = 0; i < tbl.Rows.Count; i++)
        {
            string itemqry = "select itm_code,itm_name,pi_price,pi_qty,pi_total,pi_discount_rate,pi_discount_amt,pi_netamount from tbl_purchase_items pi inner join tbl_item_master im on im.itm_id=pi.itm_id where pm_id='" + tbl.Rows[i]["pm_ref_no"] + "' ";
            dt1 = db.SelectQuery(itemqry);

            if (dt1 != null)
            {
                if (dt1.Rows.Count > 0)
                {

                    string items = "";
                    for (int j = 0; j < dt1.Rows.Count; j++)
                    {
                        //  int a = j + 1;
                        /*
                          items = items +  a + ")" + dt1.Rows[j]["ServiceCode"].ToString() + "-" + dt1.Rows[j]["Description"].ToString() + "";
                         items = items + " ( " + dt1.Rows[j]["ServiceCost"].ToString() + "-" + dt1.Rows[j]["ServiceDiscountAmount"].ToString() + "=" + dt1.Rows[j]["ServiceNetAmount"].ToString() + " ) ";
                          items = items + " Date(" + dt1.Rows[j]["StartDate"].ToString() + "-" + dt1.Rows[j]["ExpiryDate"].ToString() + ") ,    ";
                         */

                        items = items + dt1.Rows[j]["itm_code"].ToString() + "-" + dt1.Rows[j]["itm_name"].ToString() + "((" + dt1.Rows[j]["pi_qty"] + " * " + dt1.Rows[j]["pi_price"] + ")-" + dt1.Rows[j]["pi_discount_amt"] + "=" + dt1.Rows[j]["pi_netamount"] + "),";

                    }


                    items = items.Remove(items.Length - 1);


                    tbl.Rows[i]["Item"] = items;


                    //dt1.Columns[21].add
                    // row["Items"] = items;
                }

            }

        }
        //   Session.Remove("downloadqry");
        //   Session.Remove("rp_fieldvalues");
        using (ExcelPackage pck = new ExcelPackage())
        {


            //Create the worksheet
            ExcelWorksheet ws = pck.Workbook.Worksheets.Add("PurchaseReport");


            DataTable tmpTable = new DataTable();
            DataColumn column;
            // DataRow row;
            column = new DataColumn();
            column.ColumnName = "Report in Date Range:(" + fromdate + " to " + reporttodate + ")";
            column.ReadOnly = true;
            column.Unique = true;
            tmpTable.Columns.Add(column);


            /*   DataTable summaytitle1 = new DataTable();
               DataColumn column1;
               column1 = new DataColumn();
               column1.ColumnName = "Summary Report in Warehouse:" + rp_branchname + "  Date Range:(" + reportfromdate + " to " + reporttodate + ")";
               summaytitle1.Columns.Add(column1);
               */
            DataTable summaytitle1 = new DataTable();
            DataColumn column1;
            column1 = new DataColumn();
            column1.ColumnName = "Summary Report  from Date Range:(" + fromdate + " to " + reporttodate + ")";
            summaytitle1.Columns.Add(column1);


            DataTable summayTable = new DataTable();

            //   summayTable.Columns.AddRange(new DataColumn[9] { new DataColumn("Total Records", typeof(string)), new DataColumn("Cash Amount", typeof(string)), new DataColumn("Card Amount", typeof(string)), new DataColumn("Cheque Amount", typeof(string)), new DataColumn("Total Net Amount", typeof(string)), new DataColumn("Total Paid Amount", typeof(string)), new DataColumn("Total Oustanding Cleared Amount", typeof(string)), new DataColumn("Total Outstanding Amount", typeof(string)), new DataColumn("Total Sales Amount", typeof(string)) });

            //    summayTable.Rows.Add(rp_totalrecords, rp_cashamount, rp_cardamount, rp_chequeamount, rp_netamount, rp_paidamount, rp_outstad_clearedamount, rp_outstandamount, rp_total_salesamount);

            summayTable.Columns.AddRange(new DataColumn[3] { new DataColumn("Total Purchased Amount", typeof(string)), new DataColumn("Total Paid Amount", typeof(string)), new DataColumn("Total Balance", typeof(string))});

            summayTable.Rows.Add(rp_totalAmt, rp_totalPaid, rp_balance);

            //DataTable summaytitle2 = new DataTable();
            //DataColumn column2;
            //column2 = new DataColumn();
            //column2.ColumnName = "Sales Summary Report in Warehouse:" + rp_branchname + "  Date Range:(" + reportfromdate + " to " + reporttodate + ")";
            //summaytitle2.Columns.Add(column2);

            DataTable summayTable1 = new DataTable();
            //summayTable1.Columns.AddRange(new DataColumn[4] { new DataColumn("Total Records", typeof(string)), new DataColumn("Gross Amount", typeof(string)), new DataColumn("Outstanding Amount", typeof(string)), new DataColumn("Net Amount", typeof(string)) });
            //summayTable1.Rows.Add(rp_totalrecords, rp_netamount, rp_outstandamount, rp_total_salesamount);


            columlength = columlength + 4;
            int colnum = columlength + 1;
            int colnum1 = columlength + 4;
            int colnum2 = columlength + 5;
            //Load the datatable into the sheet, starting from cell A1. Print the column names on row 1
            ws.Cells["A1"].LoadFromDataTable(tmpTable, true);
            ws.Cells["A2"].LoadFromDataTable(tbl, true);
            ws.Cells["A" + columlength].LoadFromDataTable(summaytitle1, true);
            ws.Cells["A" + colnum].LoadFromDataTable(summayTable, true);
            //  ws.Cells["A" + colnum1].LoadFromDataTable(summaytitle2, true);
            //   ws.Cells["A" + colnum2].LoadFromDataTable(summayTable1, true);
            //Format the header for column 1-3
            using (ExcelRange rng = ws.Cells["A2:S2"])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
                rng.Style.Font.Color.SetColor(Color.White);
            }




            using (ExcelRange rng = ws.Cells["A1:M1"])
            {

                rng.Style.Font.Bold = true;
                rng.Style.Font.Size = 15;
                //   rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                //    rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(72,209,204));  //Set color to dark blue
                //  rng.Style.Font.Color.SetColor(Color.White);
                rng.Merge.ToString();
            }

            using (ExcelRange rng = ws.Cells["A" + columlength + ":A" + columlength])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Font.Size = 15;
                //  rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                // rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(72,209,204));  //Set color to dark blue
                //  rng.Style.Font.Color.SetColor(Color.White);
                rng.Merge.ToString();
            }


            using (ExcelRange rng = ws.Cells["A" + colnum + ":I" + colnum])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
                rng.Style.Font.Color.SetColor(Color.White);
                rng.Merge.ToString();
            }


            using (ExcelRange rng = ws.Cells["A" + colnum1 + ":A" + colnum1])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Font.Size = 15;
                // rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                // rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(72,209,204));  //Set color to dark blue
                //  rng.Style.Font.Color.SetColor(Color.White);
                rng.Merge.ToString();
            }


            using (ExcelRange rng = ws.Cells["A" + colnum2 + ":I" + colnum2])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
                rng.Style.Font.Color.SetColor(Color.White);
                rng.Merge.ToString();
            }


            //Example how to Format Column 1 as numeric 
            for (int i = 1; i <= 17; i++)
            {
                using (ExcelRange col = ws.Cells[2, i, 2 + tbl.Rows.Count, i])
                {
                    //col.Style.Numberformat.Format = "#,##0.00";
                    col.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                }
            }
            // DateTime dttt = DateTime.UtcNow;
            string newFileName = "purchaseReport";



            Session.Remove("rp_totalAmt");
            Session.Remove("rp_totalPaid");
      
            //Session.Remove("rp_total_salesamount");

            //Write it back to the client
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AddHeader("content-disposition", "attachment;  filename=" + newFileName + ".xlsx");
            Response.BinaryWrite(pck.GetAsByteArray());

        }
    }
}