using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class opcenter_rootMapping : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
    }

 
    [WebMethod]
    public static string getSalesPersons()
    {
        mySqlConnection db = new mySqlConnection();
        string innerqry = "";



        innerqry = "SELECT user_id as id, concat(first_name,\" \",last_name) as name,user_latitude as lat,user_longitude as lng from tbl_user_details where user_type=2 ";
        innerqry = innerqry + "order by first_name";

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

    [WebMethod]
    public static string getCustomersLocations(int user_id,string from_date)
    {
        string returnJson = "";
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1 ";
        //if (from_date != null && from_date != "")
        //{
        //    qry_condition += " and DATE(rt_datetime)='" + from_date + "'";
        //}
        //if (to_date != null && to_date != "")
        //{
        //    qry_condition += " and DATE(rt_datetime)<='" + to_date + "'";
        //}
        if (user_id != 0)
        {
            qry_condition += " and tc.user_id='" + user_id + "'";
        }
        string qry = "select tc.cust_id,tc.cust_name,rt_visit_status,tc.cust_latitude,tc.cust_longitude,DATE_FORMAT(rt_datetime,'%Y-%m-%d') as assigndate"
            + " from tbl_customer tc left join (select cust_id,rt_datetime,rt_visit_status from tbl_root_tracker"
            + " where DATE(rt_datetime)='" + from_date + "' and rt_user_id="+user_id+") as tr on tr.cust_id=tc.cust_id" + qry_condition + ""
            + " order by tc.cust_id desc";
        //qry_condition += " order by sm_userid,sm_refno";
      //  string qry = "select cu.cust_id,cu.cust_name,cu.cust_latitude lat ,cu.cust_longitude lng,sm_userid as user_id,concat(ud.first_name,'',ud.last_name) as user_name,DATE_FORMAT(sm_date,'%d-%b-%Y %H:%i') AS order_date,true as is_ordered,sm.sm_refno as order_no from "
            //+ " tbl_customer cu inner join tbl_sales_master sm on cu.cust_id=sm.cust_id inner join tbl_user_details ud on sm.sm_userid=ud.user_id " + qry_condition + " and cu.cust_latitude<>0 and cu.cust_longitude<>0 "
            //+ " union "
            //+ " select cust_id,cust_name,cust_latitude lat ,cust_longitude lng,user_id as user_id,'' as user_name,'' AS order_date,false as is_ordered,0 as order_no from tbl_customer"
            //+ " where cust_id not in (select cust_id from tbl_sales_master sm " + qry_condition + ") and cust_latitude<>0 and cust_longitude<>0" + qry_condition_user_id;
        //string qry = "select tc.cust_id,tc.cust_name,tr.rt_visit_status,tc.cust_latitude,tc.cust_longitude,DATE_FORMAT(rt_datetime,'%Y-%m-%d') as assigndate"
        //    + " from tbl_customer tc left join tbl_root_tracker tr on tr.cust_id=tc.cust_id " + qry_condition +" order by tc.cust_id desc";
        DataTable dt = db.SelectQuery(qry);
        try
        {
            returnJson = JsonConvert.SerializeObject(dt, Formatting.None);
        }
        catch (Exception e)
        {

        }
        return returnJson;
    }

    //save on tbl_root tracker table
    [WebMethod]
    public static string saveAssignedData(string userId, string assign_date, string[] customers)
    {
        try
        {
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();          
            List<int> customarray = customers.Select(x => int.Parse(x)).ToList<int>();
            foreach (var customer in customarray)
            {
                string countQuery = "select count(rt_id) from tbl_root_tracker where cust_id=" + customer + " and rt_user_id=" + userId + " and DATE(rt_datetime)='" + assign_date + "'";
                double numrows = Convert.ToInt32(db.SelectScalar(countQuery));

                if (numrows == 0)
                {
                    string qry = "insert into tbl_root_tracker values(null," + userId + "," + customer + ",'" + assign_date + "',0,0,0)";
                    queryStatus = db.ExecuteQuery(qry);
                }
                else { 
                }
                
            }
            if (queryStatus)
            {
                return "Y";
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }

    //delete an entry from tbl_root tracker table
    [WebMethod]
    public static string deletefuncn(string user_id, string cust_id, string from_date)
    {
        try
        {
            bool queryStatus = false;
            mySqlConnection db = new mySqlConnection();

            string countQuery = "select count(rt_id),rt_id from tbl_root_tracker where cust_id=" + cust_id + " and rt_user_id=" + user_id + " and DATE(rt_datetime)='" + from_date + "'";
            DataTable dt = db.SelectQuery(countQuery);

            if (dt.Rows.Count > 0)
            {
                string qry = "delete from tbl_root_tracker where rt_id="+dt.Rows[0]["rt_id"]+"";
                queryStatus = db.ExecuteQuery(qry);

                if (queryStatus)
                {
                    return "Y";
                }
                else
                {
                    return "N";
                }
            }
            else
            {
                return "N";
            }

        }
        catch (Exception ex)
        {
            return ex.ToString();
        }
    }
}