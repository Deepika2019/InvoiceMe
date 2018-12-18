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

public partial class reports_PandLreport : System.Web.UI.Page
{
    public string actiontype;
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(49);
        getActionTypes();
    }


    public void getActionTypes()
    {
        //types=JsonConvert.SerializeObject(Enum.GetNames(typeof(Constants.ActionType)), new Newtonsoft.Json.Converters.StringEnumConverter());
        actiontype = "[";

        foreach (var val in Enum.GetValues(typeof(Constants.ActionType)))
        {

            var name = Enum.GetName(typeof(Constants.ActionType), val);
            var value = ((int)val).ToString();
            actiontype += "{\"name\":\"" + name + "\",";
            actiontype += " \"value\":\"" + value + "\"},";
           // ret += name + ":" + ((int)val).ToString() + ",";

        }
        actiontype = actiontype.Trim().TrimEnd(',');
        actiontype += "]";

    }

    [WebMethod]
    public static string showsalespersons()
    {

        mySqlConnection db = new mySqlConnection();
        DataTable dt = new DataTable();
        StringBuilder sb = new StringBuilder();
        string query = "select user_id,first_name,last_name  from tbl_user_details order by user_id";
        dt = db.SelectQuery(query);
        return JsonConvert.SerializeObject(dt, Formatting.Indented);

    }

    #region
    //webmethod for showing stock transcations based on search fields 
    #endregion
    [WebMethod]
    public static string showTransactions(int page, int perpage, Dictionary<string, string> filters)
    {
        mySqlConnection db = new mySqlConnection();
        string qry_condition = " where 1=1 ";
        if (filters.Count > 0)
        {
            if (filters.ContainsKey("salesmanId"))
            {
                qry_condition += " and tr.user_id  = '" + filters["salesmanId"] + "'";
            }
            if (filters.ContainsKey("from_date"))
            {
                qry_condition += " and date(date)>=STR_TO_DATE('" + filters["from_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("to_date"))
            {
                qry_condition += " and date(date)<=STR_TO_DATE('" + filters["to_date"].Replace("-", "/") + "','%d/%m/%Y')";
            }
            if (filters.ContainsKey("actionType"))
            {
                qry_condition += " and action_type  = '" + filters["actionType"] + "'";
            }
            if (filters.ContainsKey("transactnStatus"))
            {
                if (filters["transactnStatus"] == "0")
                {
                    qry_condition += " and cr!=0";
                }else
                {
                    qry_condition += " and dr!=0";
                }
               
            }

            //if (filters.ContainsKey("action_type"))
            //{
            //    qry_condition += " and str.action_type  = '" + filters["action_type"] + "'";
            //}

        }
        int per_page = perpage;
        int offset = (page - 1) * per_page;
        string countQry = "select count(*) from tbl_transactions tr "+qry_condition;
        //string countQry = "SELECT sm_id FROM tbl_sales_master " + qry_condition + ""+group_condition;

        DataTable dtcount, dt = new DataTable();
        dtcount = db.SelectQuery(countQry);
        double numrows = Convert.ToInt32(db.SelectScalar(countQry));
        if (numrows == 0)
        {
            return "{\"count\":\"" + numrows + "\",\"data\":[]}"; ;
        }

        string innerqry = "select tr.id as transId,DATE_FORMAT(`date`, '%d-%b-%Y %h:%i %p') as trans_date,action_type"
            +" ,action_ref_id,cust_name,concat(tu.first_name,\" \",tu.last_name) as user,narration,cr,dr"
            + " from tbl_transactions tr inner join tbl_user_details tu on tu.user_id=tr.user_id left join tbl_customer tc on tc.cust_id=tr.partner_id"
            + "  " + qry_condition + " order by tr.date desc LIMIT " + offset.ToString() + " ," + per_page;
        // +" order by str.id desc";
        string jsonResponse = "";
        dt = db.SelectQuery(innerqry);

        if (dt.Rows.Count > 0)
        {
            DataTable sumDt = db.SelectQuery("select sum(cr) as expense,sum(dr) as income from tbl_transactions tr inner join tbl_user_details tu on tu.user_id=tr.user_id " + qry_condition);
            string jsonData = JsonConvert.SerializeObject(dt, Formatting.Indented);
            jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + ",\"expense\":" + sumDt.Rows[0]["expense"] + ",\"income\":" + sumDt.Rows[0]["income"] + "}";
        }
        else
        {
            jsonResponse = "N";
        }

        return jsonResponse;
    }//end
}