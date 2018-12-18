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

public partial class reports_DownloadItemReport : System.Web.UI.Page
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

    public void DumpExcel(DataTable tbl)
    {
        //******Arun
        string reportfromdate = "";
        string reporttodate = "";
        string rp_branchname = "";
        string servfromdate = "";
        string servtodate = "";
        string servbranchname = "";
        string servnetamount = "";
        string rp_totalrecords = "";
        string rp_currency = "";
        string rp_cashamount="";
        string rp_cardamount="";
        string rp_chequeamount = "";
        string rp_netamount = "";
        string rp_paidamount = "";
        string rp_outstad_clearedamount = "";
        string rp_outstandamount = "";
        string rp_total_salesamount = "";
        string rp_total_collectionamount = "";

        string permanet_field = Session["rp_fieldPermanent"].ToString();
        String[] splitarray1 = permanet_field.Split('*');

        servfromdate = splitarray1[0].ToString();
        servtodate = splitarray1[1].ToString();
        servbranchname = splitarray1[2].ToString();
        //servnetamount = splitarray[3].ToString();


        //reportfromdate = splitarray1[0].ToString();
        //reporttodate = splitarray1[1].ToString();
        //rp_branchname = splitarray1[2].ToString();
        rp_totalrecords = splitarray1[3].ToString();
        rp_currency = splitarray1[4].ToString();
        rp_cashamount =splitarray1[5].ToString();
        rp_cardamount =splitarray1[6].ToString();
        rp_chequeamount =splitarray1[7].ToString();
        servnetamount = splitarray1[8].ToString();
        rp_paidamount = splitarray1[9].ToString();
        rp_outstad_clearedamount = splitarray1[10].ToString();
        rp_outstandamount = splitarray1[11].ToString();
        rp_total_salesamount = splitarray1[12].ToString();
        rp_total_collectionamount = splitarray1[13].ToString();
        //***
        int columlength = 0;
        columlength = tbl.Rows.Count;
        using (ExcelPackage pck = new ExcelPackage())
        {
            //Create the worksheet
            ExcelWorksheet ws = pck.Workbook.Worksheets.Add("Purchase Report");


            DataTable tmpTable = new DataTable();
            DataColumn column;
            // DataRow row;
            column = new DataColumn();
            column.ColumnName = "Report in Branch: " + servbranchname + "  Date Range:(" + servfromdate + " to " + servtodate + ")";
            column.ReadOnly = true;
            column.Unique = true;
            tmpTable.Columns.Add(column);
   // for item sales report
            DataTable summaytitle2 = new DataTable();
            DataColumn column2;
            column2 = new DataColumn();
            column2.ColumnName = "Sales Item Summary Report :" + servbranchname + "  Date Range:(" + servfromdate + " to " + servtodate + ")";
            summaytitle2.Columns.Add(column2);

            DataTable summayTable1 = new DataTable();
            summayTable1.Columns.AddRange(new DataColumn[1] { new DataColumn("Total Net Amount", typeof(string)) });
            summayTable1.Rows.Add(servnetamount);

//end
            //for purchase report
            DataTable summaytitle3 = new DataTable();
            DataColumn column3;
            column3 = new DataColumn();
            column3.ColumnName = "Purchase Item Summary Report :" + servbranchname + "  Date Range:(" + servfromdate + " to " + servtodate + ")";
            summaytitle3.Columns.Add(column3);

            DataTable summayTable3 = new DataTable();
            summayTable3.Columns.AddRange(new DataColumn[1] { new DataColumn("Total Net Amount", typeof(string)) });
            summayTable3.Rows.Add(servnetamount);


            //end


            //for purchase report
            DataTable summaytitle4 = new DataTable();
            DataColumn column4;
            column4 = new DataColumn();
            column4.ColumnName = "Purchase Summary Report :" + servbranchname + "  Date Range:(" + servfromdate + " to " + servtodate + ")";
            summaytitle4.Columns.Add(column4);

            DataTable summayTable4 = new DataTable();
            summayTable4.Columns.AddRange(new DataColumn[7] { new DataColumn("Total Records", typeof(string)), new DataColumn("Cash Amount", typeof(string)), new DataColumn("Card Amount", typeof(string)), new DataColumn("Cheque Amount", typeof(string)), new DataColumn("Total Collections", typeof(string)), new DataColumn("Total Sales", typeof(string)), new DataColumn("Outstanding Received", typeof(string)) });
            summayTable4.Rows.Add(rp_totalrecords, rp_cashamount, rp_cardamount, rp_chequeamount, rp_total_collectionamount, rp_total_salesamount, rp_outstad_clearedamount);
       


            //end




            columlength = columlength + 4;
            int colnum = columlength + 1;
            int colnum1 = columlength + 4;
            int colnum2 = columlength + 5;
            //Load the datatable into the sheet, starting from cell A1. Print the column names on row 1
            ws.Cells["A1"].LoadFromDataTable(tmpTable, true);
            ws.Cells["A2"].LoadFromDataTable(tbl, true);
            ws.Cells["A" + colnum1].LoadFromDataTable(summaytitle2, true);
            ws.Cells["A" + colnum2].LoadFromDataTable(summayTable1, true);
            ws.Cells["A" + colnum1].LoadFromDataTable(summaytitle3, true);
            ws.Cells["A" + colnum2].LoadFromDataTable(summayTable3, true);
            ws.Cells["A" + colnum1].LoadFromDataTable(summaytitle4, true);
            ws.Cells["A" + colnum2].LoadFromDataTable(summayTable4, true);
            using (ExcelRange rng = ws.Cells["A2:S2"])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
                rng.Style.Font.Color.SetColor(Color.White);
            }

            //Example how to Format Column 1 as numeric 
            for (int i = 1; i <= 17; i++)
            {
                using (ExcelRange col = ws.Cells[2, i, 2 + tbl.Rows.Count, i])
                {
                    
                    col.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                }
            }
            // DateTime dttt = DateTime.UtcNow;
            string newFileName = "PurchaseReport";



            Session.Remove("servbranchname");
            Session.Remove("servfromdate");
            Session.Remove("servtodate");
            //Write it back to the client
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AddHeader("content-disposition", "attachment;  filename=" + newFileName + ".xlsx");
            Response.BinaryWrite(pck.GetAsByteArray());

        }


    }
}