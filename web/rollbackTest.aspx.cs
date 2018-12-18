using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using commonfunction;
using System.Data;


public partial class _rollbackTest : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        mySqlConnection obj = new mySqlConnection();
        obj.BeginTransaction();
        try
        {

            DataTable dt = obj.SelectQueryForTransaction("select * from tbl_test");

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    
                    Response.Write("id=" + Convert.ToString(dt.Rows[i]["id"]));
                    Response.Write("   nmae=" + Convert.ToString(dt.Rows[i]["name"]));
                    Response.Write("   value=" + Convert.ToString(dt.Rows[i]["value"]));
                    Response.Write("<br />");
                }
            }

            Response.Write("<br />Select Query for transaction Completed 1 <br />");
            dt.Rows.Clear();

            for(int i=0;i<2;i++){
                obj.ExecuteQueryForTransaction("insert into tbl_test(name,value) values('"+DateTime.Now+"',"+i+")");
                Response.Write("<br />Inserted "+i+" <br />");
            }
            Response.Write("<br />Inserttion Completed <br />");
            
            
            dt = obj.SelectQueryForTransaction("select * from tbl_test");
            string id = "";
            string name="";
            string value="0";
            if (dt.Rows.Count > 0) {
                id = Convert.ToString(dt.Rows[dt.Rows.Count - 1]["id"]);
                name=Convert.ToString(dt.Rows[dt.Rows.Count-1]["name"]);
                value=Convert.ToString(dt.Rows[dt.Rows.Count-1]["value"]);
            }
            Response.Write("<br />Select Query for transaction Completed 2<br />");
            name=name+DateTime.Now.ToString();
            obj.ExecuteQueryForTransaction("insert into tbl_test(name,value) values('"+name+"','2')");

            Response.Write("<br /> Insertion Completed <br />");

            id= obj.SelectScalarForTransaction("select id from tbl_test where id="+id);

            Response.Write("<br /> Select scalar for Trasaction Completed <br />");

            obj.ExecuteQueryForTransaction("Delete from tbl_test where id="+id);
            Response.Write("<br /> Delete Transaction Completed <br />");

            obj.CommitTransaction();
            Response.Write("<br /> Commit trasaction Success <br />");

            dt = obj.SelectQuery("select * from tbl_test");

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Response.Write("id=" + Convert.ToString(dt.Rows[i]["id"]));
                    Response.Write("   nmae=" + Convert.ToString(dt.Rows[i]["name"]));
                    Response.Write("   value=" + Convert.ToString(dt.Rows[i]["value"]));
                    Response.Write("<br />");
                }
            }
            dt.Rows.Clear();
            Response.Write("<br/> Normal select after Commit Transaction Completed <br />");

           

        }
        catch(Exception ex )
        {
            try
            {
                obj.RollBackTransaction();
                LogClass log = new LogClass("default");
                log.write(ex);
                DataTable dt = obj.SelectQueryForTransaction("select * from tbl_test");

                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                       
                        Response.Write("id=" + Convert.ToString(dt.Rows[i]["id"]));
                        Response.Write("   nmae=" + Convert.ToString(dt.Rows[i]["name"]));
                        Response.Write("   value=" + Convert.ToString(dt.Rows[i]["value"]));
                        Response.Write("<br />");
                    }
                }
                dt.Rows.Clear();
                Response.Write("<br />Roll back Success <br />");
            }
            catch {
                Response.Write("error in Rollback"+ex.ToString());

            }
        }

    }
}


        //using (MySqlConnection con = new MySqlConnection(ConfigurationManager.AppSettings["db_connect_mysql"]))
        //{
        //    con.Open();
        //    using (MySqlTransaction trans = con.BeginTransaction())
        //    {
        //        try
        //        {
        //            //command to executive query
        //            using (MySqlCommand cmd = new MySqlCommand("insert into tbl_test(name,value) values(@parameter1,@parameter2)", con, trans))
        //            {
        //                //cmd.Parameters.AddWithValue("@parameter1", "Name1");
        //                //cmd.Parameters.AddWithValue("@parameter2", 1);
        //                cmd.ExecuteNonQuery();
        //                cmd.Parameters.Clear();
        //            }
        //            //command to executive query
        //            using (MySqlCommand cmd = new MySqlCommand("insert into tbl_test(name,value) values(@parameter1,@parameter2)", con, trans))
        //            {
        //                cmd.Parameters.AddWithValue("@parameter1", "Name2");
        //                cmd.Parameters.AddWithValue("@parameter2", 2);
        //                cmd.ExecuteNonQuery();
        //                cmd.Parameters.Clear();
        //            }
        //            //command to execute query
        //            using (MySqlCommand cmd = new MySqlCommand("insert into tbl_test(name,value) values(@parameter1,@parameter2)", con, trans))
        //            {
        //                cmd.Parameters.AddWithValue("@parameter1", null);
        //                cmd.Parameters.AddWithValue("@parameter2", null);
        //                cmd.ExecuteNonQuery();
        //                cmd.Parameters.Clear();
        //            }
        //            trans.Commit();
        //        }
        //        catch (Exception ex)
        //        {
        //            trans.Rollback();
        //        }
        //    }
        //}


