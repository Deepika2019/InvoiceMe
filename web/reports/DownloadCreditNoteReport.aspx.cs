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

public partial class reports_DownloadCreditNoteReport : System.Web.UI.Page
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

        string servfromdate = "";
        string servtodate = "";
        string servnetamount = "";
        string permanet_field = Session["rp_fieldPermanent"].ToString();
        String[] splitarray = permanet_field.Split('*');
        servfromdate = splitarray[0].ToString();
        servtodate = splitarray[1].ToString();
        servnetamount = splitarray[2].ToString();

        //***
        int columlength = 0;
        columlength = tbl.Rows.Count;
        using (ExcelPackage pck = new ExcelPackage())
        {
            //Create the worksheet
            ExcelWorksheet ws = pck.Workbook.Worksheets.Add("CreditNoteReport");


            DataTable tmpTable = new DataTable();
            DataColumn column;
            // DataRow row;
            column = new DataColumn();
            column.ColumnName = "Credit Note Report:  Date Range:(" + servfromdate + " to " + servtodate + ")";
            column.ReadOnly = true;
            column.Unique = true;
            tmpTable.Columns.Add(column);
            // for item sales report
            DataTable summaytitle2 = new DataTable();
            DataColumn column2;
            column2 = new DataColumn();
            column2.ColumnName = "Credit Note Summary Report : Date Range:(" + servfromdate + " to " + servtodate + ")";
            summaytitle2.Columns.Add(column2);

            DataTable summayTable1 = new DataTable();
            summayTable1.Columns.AddRange(new DataColumn[1] { new DataColumn("Total Net Amount", typeof(string)) });
            summayTable1.Rows.Add(servnetamount);


            columlength = columlength + 4;
            int colnum = columlength + 1;
            int colnum1 = columlength + 4;
            int colnum2 = columlength + 5;
            //Load the datatable into the sheet, starting from cell A1. Print the column names on row 1
            ws.Cells["A1"].LoadFromDataTable(tmpTable, true);
            ws.Cells["A2"].LoadFromDataTable(tbl, true);
            ws.Cells["A" + colnum1].LoadFromDataTable(summaytitle2, true);
            ws.Cells["A" + colnum2].LoadFromDataTable(summayTable1, true);

            using (ExcelRange rng = ws.Cells["A2:S2"])
            {
                rng.Style.Font.Bold = true;
                rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
                rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
                rng.Style.Font.Color.SetColor(Color.White);
            }

            //Example how to Format Column 1 as numeric 
            for (int i = 1; i <= 10; i++)
            {
                using (ExcelRange col = ws.Cells[2, i, 2 + tbl.Rows.Count, i])
                {

                    col.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                }
            }
            // DateTime dttt = DateTime.UtcNow;
            string newFileName = "CreditNoteReport";

            Session.Remove("servfromdate");
            Session.Remove("servtodate");
            //Write it back to the client
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AddHeader("content-disposition", "attachment;  filename=" + newFileName + ".xlsx");
            Response.BinaryWrite(pck.GetAsByteArray());

        }


    }

}