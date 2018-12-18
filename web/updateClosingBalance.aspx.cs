using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using commonfunction;
using System.Data;
public partial class updateClosingBalance : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        mySqlConnection db = new mySqlConnection();
        try
        {

            string query = "SELECT id,partner_id FROM tbl_transactions";
            DataTable dt = db.SelectQuery(query);
            db.BeginTransaction();
            string updatequery = "update tbl_transactions set closing_balance=CASE id";
            string transIdString = "";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                transIdString = transIdString + "," + dt.Rows[i]["id"];
                DataTable rowDt = db.SelectQueryForTransaction("select sum(dr)-sum(cr) as closingBalance from tbl_transactions where partner_id=" + dt.Rows[i]["partner_id"] + " and id<=" + dt.Rows[i]["id"] + " order by date");
                updatequery += " when " + dt.Rows[i]["id"] + " then " + rowDt.Rows[0]["closingBalance"] + "";
               

            }
            transIdString = transIdString.Trim().TrimStart(',');
            updatequery += " ELSE closing_balance END  WHERE id IN (" + transIdString + ")";
            if (db.ExecuteQueryForTransaction(updatequery))
            {
                HttpContext.Current.Response.Write("Updation Completed");
            }
            else
            {
                HttpContext.Current.Response.Write("Updation Failed");
            }
            db.CommitTransaction();
        }
        catch (Exception ex)
        {
            try
            {
                db.RollBackTransaction();
                LogClass log = new LogClass("updateClosingBalance");
                log.write(ex);
            }
            catch
            {
            }
        }
    }
}