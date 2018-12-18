using commonfunction;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class reports_OutstandingBillReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        LoginAuthentication reports = new LoginAuthentication();
        reports.userAuthentication();
        reports.checkPageAcess(44);
    }

    [WebMethod]
    public static string getOutstandingBills(int page, int perpage, Dictionary<string, string> filters)
    {
        dynamic response = new ExpandoObject();
        bool skipLastOrder = false;
        string qry_condition = " where sm.sm_id is not null and sm_delivery_status=2 ";
        string group_condition = "";
        if (filters.Count > 0)
        {
            //if (filters.ContainsKey("branch_id"))
            //{
            //    qry_condition += " and cu.branch_id  = '" + filters["branch_id"] + "'";
            //}
            if (filters.ContainsKey("cust_id"))
            {
                qry_condition += " and cu.cust_id  = '" + filters["cust_id"] + "'";
            }
            if (filters.ContainsKey("user_id"))
            {
                qry_condition += " and cu.user_id  = '" + filters["user_id"] + "'";
            }
            float tempfloat;
            int tempInt;
            if (filters.ContainsKey("credit_amount") && float.TryParse(filters["credit_amount"], out tempfloat))
            {
                group_condition += " and (sum(dr)-sum(cr)) >= '" + filters["credit_amount"] + "'";
            }
            else
            {
                group_condition += " and (sum(dr)-sum(cr)) > '0'";
            }
            if (filters.ContainsKey("credit_period") && int.TryParse(filters["credit_period"], out tempInt))
            {
                qry_condition += " and DATEDIFF(NOW(), DATE(sm.sm_processed_date)) >= '" + filters["credit_period"] + "'";
            }
            if (filters.ContainsKey("skipLastOrder"))
            {
                skipLastOrder = Boolean.Parse(filters["skipLastOrder"]);
            }
        }
        mySqlConnection db = new mySqlConnection();
        //getting count of outstanding bills
        //response.count = db.SelectScalar("Select count(*) from tbl_sales_master sm join tbl_customer cu on cu.cust_id = sm.cust_id "+qry_condition);
        //getting outstanding bills grouped by customer
        string query = "Select cu.cust_id,cu.cust_name,cu.cust_amount total_outstanding"
            + " ,cu.max_creditperiod max_credit_period,cu.max_creditamt max_credit_amt "
            + " ,cu.cust_address address,cu.cust_city city,user.user_name selesman_name "
            + " ,sm.sm_id,sm.sm_netamount net_amt,(sm.sm_netamount-(sum(dr)-sum(cr))) paid_amt,(sum(dr)-sum(cr)) balance_amt"
            + " ,DATE_FORMAT(sm.sm_processed_date, '%d/%m/%Y') date,DATEDIFF(NOW(),DATE(sm.sm_processed_date)) as credit_period "
            + " from tbl_sales_master sm "
            + " inner join tbl_customer cu on cu.cust_id = sm.cust_id "
            + " inner join tbl_user_details user on cu.user_id=user.user_id "
            + " right join tbl_transactions tr on (tr.action_ref_id=sm.sm_id and tr.action_type="+(int)Constants.ActionType.SALES+") "
            + qry_condition
            + " group by tr.action_ref_id,tr.action_type having (1=1 "+group_condition+")"
            + " order by sm.sm_date asc";
        //+ " limit " + ((page - 1) * perpage) + "," + perpage;
        var resultQuery = db.SelectQuery(query).AsEnumerable()
            .GroupBy(x => x.Field<Int32>("cust_id"))
            .Select(x => new
            {
                cust_id = x.First().Field<Int32>("cust_id"),
                cust_name = x.First().Field<string>("cust_name"),
                total_outstanding = x.First().Field<dynamic>("total_outstanding"),
                max_credit_period = x.First().Field<dynamic>("max_credit_period"),
                max_credit_amt = x.First().Field<dynamic>("max_credit_amt"),
                salesman = x.First().Field<string>("selesman_name"),
                address = x.First().Field<string>("address"),
                city = x.First().Field<string>("city"),
                orders = x.ToList().Take((skipLastOrder?x.Count()-1: x.Count())).Select(y => new
                {
                    sm_id = y.Field<dynamic>("sm_id"),
                    net_amt = y.Field<dynamic>("net_amt"),
                    paid_amt = y.Field<dynamic>("paid_amt"),
                    balance_amt = y.Field<dynamic>("balance_amt"),
                    date = y.Field<dynamic>("date"),
                    credit_period = y.Field<dynamic>("credit_period"),
                })
            });
        response.count = resultQuery.Count();
        response.net_outstanding_amount = resultQuery.SelectMany(x => x.orders).Sum(y => (float)y.balance_amt);
        response.customers = resultQuery.Skip(((page - 1) * perpage)).Take(perpage);
        return JsonConvert.SerializeObject(response, Formatting.Indented);
    }
}