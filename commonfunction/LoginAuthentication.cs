using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;

namespace commonfunction
{
    public class LoginAuthentication
    {
        public void userAuthentication()
        {
            mySqlConnection db = new mySqlConnection();
            if (HttpContext.Current.Request.Cookies["invntrystaffName"] != null && HttpContext.Current.Request.Cookies["invntrystaffPassword"] != null)
            {
                string username = HttpContext.Current.Request.Cookies["invntrystaffName"].Value.ToString();

                string password = HttpUtility.UrlDecode(HttpContext.Current.Request.Cookies["invntrystaffPassword"].Value.ToString());
                if (username != "" && password != "")
                {
                    string query = "SELECT COUNT(user_id) FROM tbl_user_details WHERE user_name='" + username + "' and password='" + password + "'";
                    double numrows = Convert.ToInt32(db.SelectScalar(query));
                    if (numrows == 0)
                    {
                        HttpContext.Current.Response.Redirect("~/login.aspx");
                    }
                }
            }
            else
            {
                HttpContext.Current.Response.Redirect("~/login.aspx");
            }

        }
        public void checkPageAcess(int pageid)
        {
            if (HttpContext.Current.Request.Cookies["invntrystaffId"] != null && HttpContext.Current.Request.Cookies["invntrystaffBranchId"] != null && HttpContext.Current.Request.Cookies["invntrystaffCountryId"] != null)
            {
                string userid = HttpContext.Current.Request.Cookies["invntrystaffTypeID"].Value;
                mySqlConnection db = new mySqlConnection();
                DataTable dt = new DataTable();
                string query = "SELECT COUNT(*) FROM tbl_user_permissions WHERE user_type='" + userid + "' and page_id=" + pageid + " and read_action='1' ";
                double numrows = Convert.ToInt32(db.SelectScalar(query));
                if (numrows == 0)
                {
                    HttpContext.Current.Response.Redirect("~/dashboard.aspx");
                }
            }
            else if (HttpContext.Current.Request.Cookies["invntrystaffId"] == null && HttpContext.Current.Request.Cookies["invntrystaffBranchId"] == null && HttpContext.Current.Request.Cookies["invntrystaffCountryId"] == null)
            {
                HttpContext.Current.Response.Redirect("~/dashboard.aspx");
            }
            else
            {
                HttpContext.Current.Response.Redirect("~/login.aspx");
            }
        }
    }
}
