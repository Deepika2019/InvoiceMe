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

public partial class reports_downloadreport : System.Web.UI.Page
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
        string reportfromdate = "";
        string reporttodate = "";
        string rp_branchname = "";
        string rp_totalrecords = "";
        string rp_currency = "";
        string rp_cashamount = "";
        string rp_cardamount = "";
        string rp_chequeamount = "";
        string rp_netamount = "";
        string rp_paidamount = "";
        string rp_outstad_clearedamount = "";
        string rp_outstandamount = "";
       
        string rp_fieldvalues = Convert.ToString(Session["rp_fieldvalues"]);
        String[] rp_splitarray = rp_fieldvalues.Split('*');

        reportfromdate = Convert.ToString(rp_splitarray[0]);
        reporttodate = Convert.ToString(rp_splitarray[1]);
        rp_branchname =Convert.ToString( rp_splitarray[2]);
        rp_totalrecords =Convert.ToString( rp_splitarray[3]);
        rp_currency =Convert.ToString( rp_splitarray[4]);
        rp_cashamount =Convert.ToString( rp_splitarray[5]);
        rp_cardamount =Convert.ToString( rp_splitarray[6]);
        rp_chequeamount =Convert.ToString( rp_splitarray[7]);
        rp_netamount =Convert.ToString( rp_splitarray[8]);
        rp_paidamount =Convert.ToString( rp_splitarray[9]);
        rp_outstad_clearedamount =Convert.ToString( rp_splitarray[10]);
     
        

        int columlength = 0;
        columlength = tbl.Rows.Count;
        mySqlConnection db = new mySqlConnection();
        DataTable dt1 = new DataTable();

        for (int i = 0; i < tbl.Rows.Count; i++)
        {
            string itemqry = "select itm_code,itm_name,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc from tbl_sales_items where sm_id='" + tbl.Rows[i]["sm_refno"] + "' ";
                dt1 = db.SelectQuery(itemqry);

                if (dt1 != null)
                {
                    if (dt1.Rows.Count > 0)
                    {

                        string items = "";
                        for (int j = 0; j < dt1.Rows.Count; j++)
                        {
                             int a = j + 1;
                            /*
                              items = items +  a + ")" + dt1.Rows[j]["ServiceCode"].ToString() + "-" + dt1.Rows[j]["Description"].ToString() + "";
                             items = items + " ( " + dt1.Rows[j]["ServiceCost"].ToString() + "-" + dt1.Rows[j]["ServiceDiscountAmount"].ToString() + "=" + dt1.Rows[j]["ServiceNetAmount"].ToString() + " ) ";
                              items = items + " Date(" + dt1.Rows[j]["StartDate"].ToString() + "-" + dt1.Rows[j]["ExpiryDate"].ToString() + ") ,    ";
                             */

                            items = items + a +")"+ dt1.Rows[j]["itm_code"].ToString() + "-" + dt1.Rows[j]["itm_name"].ToString() + "((" + dt1.Rows[j]["si_qty"] + " * " + dt1.Rows[j]["si_price"] + ")-" + dt1.Rows[j]["si_discount_amount"] + "=" + dt1.Rows[j]["si_net_amount"] + "),   ";

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
            ExcelWorksheet ws = pck.Workbook.Worksheets.Add("SalesReport");


            DataTable tmpTable = new DataTable();
            DataColumn column;
            // DataRow row;
            column = new DataColumn();
            column.ColumnName = "Report in Warehouse: " + rp_branchname + "  Date Range:(" + reportfromdate + " to " + reporttodate + ")";
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
            column1.ColumnName = "Collection Summary Report in Warehouse:" + rp_branchname + "  Date Range:(" + reportfromdate + " to " + reporttodate + ")";
            summaytitle1.Columns.Add(column1);


            DataTable summayTable = new DataTable();

            //   summayTable.Columns.AddRange(new DataColumn[9] { new DataColumn("Total Records", typeof(string)), new DataColumn("Cash Amount", typeof(string)), new DataColumn("Card Amount", typeof(string)), new DataColumn("Cheque Amount", typeof(string)), new DataColumn("Total Net Amount", typeof(string)), new DataColumn("Total Paid Amount", typeof(string)), new DataColumn("Total Oustanding Cleared Amount", typeof(string)), new DataColumn("Total Outstanding Amount", typeof(string)), new DataColumn("Total Sales Amount", typeof(string)) });

            //    summayTable.Rows.Add(rp_totalrecords, rp_cashamount, rp_cardamount, rp_chequeamount, rp_netamount, rp_paidamount, rp_outstad_clearedamount, rp_outstandamount, rp_total_salesamount);

            summayTable.Columns.AddRange(new DataColumn[7] { new DataColumn("Total Records", typeof(string)), new DataColumn("Total Net amount", typeof(string)), new DataColumn("Total Paid", typeof(string)),new DataColumn("Cash Amount", typeof(string)), new DataColumn("Card Amount", typeof(string)), new DataColumn("Cheque Amount", typeof(string)), new DataColumn("Total Balance", typeof(string)) });

            summayTable.Rows.Add(rp_totalrecords, rp_netamount,rp_paidamount,rp_cashamount, rp_cardamount, rp_chequeamount,rp_outstad_clearedamount);

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
            string newFileName = "SalesReport";



            Session.Remove("rp_branchname");
            Session.Remove("rp_totalrecords");
            Session.Remove("rp_totalrecords");
            Session.Remove("rp_currency");
            Session.Remove("rp_cashamount");
            Session.Remove("rp_cardamount");
            Session.Remove("rp_chequeamount");
            Session.Remove("rp_netamount");
            Session.Remove("rp_paidamount");
            Session.Remove("rp_outstad_clearedamount");
    
            //Session.Remove("rp_total_salesamount");

            //Write it back to the client
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AddHeader("content-disposition", "attachment;  filename=" + newFileName + ".xlsx");
            Response.BinaryWrite(pck.GetAsByteArray());

        }
    }
}