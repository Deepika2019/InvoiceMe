<%@ WebService Language="C#" Class="sendpdfmail" %>


using System.Web.Services.Protocols;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Text;
using commonfunction;
using Newtonsoft.Json;
using System.Dynamic;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using iTextSharp.text.xml;
using iTextSharp.text.html;

using System.Net;
using System.Net.Mail;
using iTextSharp.tool.xml;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class sendpdfmail  : System.Web.Services.WebService {

    public sendpdfmail()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string sendmail(string billno, string email)
    {
        mySqlConnection db = new mySqlConnection();
        StringBuilder sb = new StringBuilder();
        try
        {
            //fetching order details
            String orderQry = "SELECT cu.cust_id,cu.cust_email, sm.sm_id,sm.sm_refno, cu.cust_name,concat(ud.first_name,' ',ud.last_name) as staff_name"
                + " ,DATE_FORMAT(sm.sm_date, '%d-%b-%Y %h:%i %p') as sm_date,sm.sm_netamount as net_amount,sm.total_paid,sm.total_balance,sm.sm_userid"
                + " ,sm.branch_id,IFNULL(cu.cust_amount,0) as outstanding_amt,cu.cust_wallet_amt as wallet_amt"
                + " FROM tbl_sales_master sm inner join tbl_customer cu on cu.cust_id=sm.cust_id "
                + "  left join tbl_user_details ud on ud.user_id=sm.sm_userid WHERE sm_id ='" + billno + "' ";
            DataTable dtOrder = db.SelectQuery(orderQry);

            if (string.IsNullOrEmpty(Convert.ToString(dtOrder.Rows[0]["cust_email"]).Trim()) && string.IsNullOrEmpty(email.Trim()))
            {
                HttpContext.Current.Response.StatusCode = 401;
                HttpContext.Current.Response.TrySkipIisCustomErrors = true;
                return "{\"message\":\"Invalid mail id\"}";
            }

            // fetching branch details
            string branchQry = "SELECT branch_id,branch_name,branch_countryid,branch_bill_disclosure,branch_bill_footer FROM tbl_branch WHERE branch_id='" + Convert.ToString(dtOrder.Rows[0]["branch_id"]) + "' ";
            DataTable dtBranches = db.SelectQuery(branchQry);

            String qryItems = "SELECT itm_code,itm_name,si_qty as qty,si_price as price "
                + " ,si_discount_rate as dis_rate,si_discount_amount as dis_amount"
                + " ,si_net_amount as net_amount,si_foc as foc "
                + " FROM tbl_sales_items WHERE sm_id='" + dtOrder.Rows[0]["sm_refno"].ToString() + "' and si_itm_type!=2";
            DataTable dtItems = db.SelectQuery(qryItems);

            //fetching payment details
            String paymentQry = "select DATE_FORMAT(sm_date, '%d-%b-%Y') as date"
                + " ,IFNULL(sm_chq_amt,0) as chk_amt,IFNULL(sm_card_amt,0) as card_amt,IFNULL(sm_cash_amt,0) as cash_amt"
                + " ,IFNULL(sm_wallet_amt,0) as wlt_amt,sm_paid as paid,sm_balance as balance "
                + " from tbl_sales_master where sm_refno='" + dtOrder.Rows[0]["sm_refno"].ToString() + "'";
            DataTable dtPay = db.SelectQuery(paymentQry);


            StringBuilder sbHtml = new StringBuilder();
            sbHtml.Append("<div id=\"divReceiptDetails\" class=\"details\" style=\"margin-top:15px; display:;\">");
            sbHtml.Append("<table style=\"width:100%;\">");
            sbHtml.Append("<tr><td><table style=\"with:100%;\">");
            sbHtml.Append("<tbody>");
            sbHtml.Append("<tr>");
            if (dtOrder.Rows.Count > 0)
            {
                sbHtml.Append("<td><strong>Customer ID : </strong><label for=\"\" id=\"lblCusId\">" + dtOrder.Rows[0]["cust_id"] + "</label></td></tr>");
                sbHtml.Append("<tr><td><strong>Customer Name : </strong><label for=\"\" id=\"lblCusName\">" + dtOrder.Rows[0]["cust_name"] + "</label></td></tr>");
                sbHtml.Append("<tr><td><strong>Wallet amt.: </strong><label for=\"\" id=\"lblWalletAmount\">" + dtOrder.Rows[0]["wallet_amt"] + "</label></td></tr>");
                sbHtml.Append("<tr><td><strong>Outstanding amt.: </strong><label for=\"\" id=\"lblOutstandingAmount\">" + dtOrder.Rows[0]["outstanding_amt"] + "</label></td></tr>");
                sbHtml.Append("</tbody>");
                sbHtml.Append("</table></td>");

                sbHtml.Append("<td><div style=\"width:100%;text-align:right;\">");
                sbHtml.Append("<div style=\"display:inline-block;margin-rght:10px;\">");
                sbHtml.Append("<span style=\"font-weight:bold;\">Order ID : </span><label for=\"\" id=\"lblOrderId\">" + dtOrder.Rows[0]["sm_refno"] + "</label><br/>");
                sbHtml.Append("<span style=\"font-weight:bold;\">Date :  </span><label for=\"\" id=\"lblOrderDate\">" + dtOrder.Rows[0]["sm_date"] + "</label><br/>");
                sbHtml.Append("<span style=\"font-weight:bold;\">Warehouse:  </span><label for=\"\" id=\"lblWarehouse\">" + dtBranches.Rows[0]["branch_name"] + "</label><br/></div>");
                sbHtml.Append("</div></td>");
            }
            sbHtml.Append("</tr></table>");

            sbHtml.Append("<table id=\"tblOrderDetails\" style=\"margin-top:8px; margin-bottom:8px;table-layout:fixed\" cellspacing=\"0\" cellpadding=\"0\" border=\"1\" width=\"100%\">");
            sbHtml.Append("<thead>");
            sbHtml.Append("<tr>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;width:30px;\">No</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold;font-size:12px;width:100px;\">Item Code</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold;font-size:12px;width:250px;\">Item Name</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold;font-size:12px;width: 30px;\">Qty</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold;font-size:12px;\">Amount</td>");

            sbHtml.Append("<td class=\"\" style=\"font-size:12px;\"><span style=\"font-weight:bold;\">Discount</span>");
            sbHtml.Append("<table cellspacing=\"0\" cellpadding=\"0\" width=\"100%\"><tbody>");
            

            sbHtml.Append("</tbody></table>");



            sbHtml.Append("</td>");

            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold;font-size:12px;\">Net.Amt</td>");
            sbHtml.Append("</tr>");

            sbHtml.Append("</thead>");
            sbHtml.Append("<tbody>");
            for (int i = 0; i < dtItems.Rows.Count; i++)
            {
                sbHtml.Append("<tr>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center;\">" + (i + 1) + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center;\">" + dtItems.Rows[i]["itm_code"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\">" + dtItems.Rows[i]["itm_name"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:right;\">" + dtItems.Rows[i]["qty"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:right;\">" + dtItems.Rows[i]["price"] + "</td>");
                sbHtml.Append("<td class=\"tablefonthead bordertopbot\" style=\"text-align:right;\">" + dtItems.Rows[i]["dis_amount"] + "</td>");
                sbHtml.Append("<td class=\"tablefonthead bodertopleft\" style=\"text-align:right;\">" + dtItems.Rows[i]["net_amount"] + "</td>");
                sbHtml.Append("</tr>");
            }
            sbHtml.Append("</tbody></table>");
            sbHtml.Append("<div style=\"width:100%;text-align:right;\">");
            sbHtml.Append("<div style=\"display:inline-block;margin-rght:10px;\">");
            sbHtml.Append("<span style=\"font-weight:bold;\">Net Amount : </span><label for=\"\" id=\"lblNetAmount\">" + dtOrder.Rows[0]["net_amount"] + "</label><br/>");
            sbHtml.Append("<span style=\"font-weight:bold;\">Paid Amount : </span><label for=\"\" id=\"lblPaidAmount\">" + dtOrder.Rows[0]["total_paid"] + "</label><br/>");
            sbHtml.Append("<span style=\"font-weight:bold;\">Balance Amount : </span><label for=\"\" id=\"lblBalanceAmount\">" + dtOrder.Rows[0]["total_balance"] + "</label><br/>");
            sbHtml.Append("</div></div>");

            sbHtml.Append("<div id=\"divPaymentDetails\" style=\"width:100%\">");
            sbHtml.Append("<div style=\"width:100%; border:1px solid #000000;\"></div>");
            sbHtml.Append("<span style=\"font-weight:bold;\">Payment details</span>");
            sbHtml.Append("<div class=\"cl\"></div>");

            sbHtml.Append("<table id=\"tblPaymentDetails\" style=\"margin-top:8px; margin-bottom:8px;\" cellspacing=\"0\" cellpadding=\"0\" border=\"1\" width=\"100%\">");
            sbHtml.Append("<thead>");
            sbHtml.Append("<tr>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Date</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Cash amt.</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Card amt.</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Cheque amt.</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Wallet amt.</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Paid amt.</td>");
            sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Balance amt.</td>");
            sbHtml.Append("</tr>");
            sbHtml.Append("</thead>");
            sbHtml.Append("<tbody>");

            for (int i = 0; i < dtPay.Rows.Count; i++)
            {
                sbHtml.Append("<tr>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["date"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["cash_amt"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["card_amt"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["chk_amt"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["wlt_amt"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["paid"] + "</td>");
                sbHtml.Append("<td class=\"tablefont\" style=\"text-align:center\">" + dtPay.Rows[0]["balance"] + "</td>");
                sbHtml.Append("</tr>");
            }
            sbHtml.Append("</tbody>");
            sbHtml.Append("</table>");
            sbHtml.Append("</div>");

            //fetching return details
            String retHeadQry = "SELECT `srm_id`, `sm_id`, DATE_FORMAT(`srm_date`, '%d-%b-%Y %h:%i %p') as date,`srm_amount` as amt "
                + " FROM `tbl_salesreturn_master` WHERE `sm_id`='" + dtOrder.Rows[0]["sm_refno"].ToString() + "'";
            DataTable dtRetHead = db.SelectQuery(retHeadQry);





            if (dtRetHead.Rows.Count > 0)
            {
                sbHtml.Append("<div id=\"divReturnDetails\" style=\"width:100%\">");
                sbHtml.Append("<div style=\"width:100%; border:1px solid #000000;\"></div>");
                sbHtml.Append("<span style=\"font-weight:bold;\">Return details</span>");
                sbHtml.Append("<div class=\"cl\"></div>");

                sbHtml.Append("<div id=\"divReturns\">");
                sbHtml.Append("<table id=\"tblReturnDetails\" style=\"margin-top:8px; margin-bottom:8px;\" cellspacing=\"0\" cellpadding=\"0\" border=\"1\" width=\"100%\">");
                sbHtml.Append("<thead>");
                sbHtml.Append("<tr>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">No</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Item Code</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Item Name</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Qty</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Price</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Discount</td>");
                sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">Total</td>");
                sbHtml.Append("</tr>");
                sbHtml.Append("</thead>");
                sbHtml.Append("<tbody>");

                for (int i = 0; i < dtRetHead.Rows.Count; i++)
                {
                    //retObj.id = dtRetHead.Rows[i]["srm_id"];
                    //retObj.date = dtRetHead.Rows[i]["date"];
                    //retObj.amount = dtRetHead.Rows[i]["amt"];
                    string qryRetItems = "SELECT `itm_code`, `itm_name`, `si_price` as price"
                        + " , `sri_qty` as qty, `sri_discount_amount` as discount, `sri_total` as total "
                        + " FROM `tbl_salesreturn_items` WHERE srm_id='" + dtRetHead.Rows[i]["srm_id"] + "'";
                    DataTable dtRetItems = db.SelectQuery(qryRetItems);
                    sbHtml.Append("<tr>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + (i + 1) + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["itm_code"] + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["itm_name+"] + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["qty"] + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["price"] + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["discount"] + "</td>");
                    sbHtml.Append("<td class=\"tablefonthead\" style=\"font-weight:bold; font-size:12px;\">" + dtRetItems.Rows[0]["total"] + "</td>");
                    sbHtml.Append("</tr>");
                }

                sbHtml.Append("<tr>");
                sbHtml.Append("<td colspan=\"7\">");
                sbHtml.Append("<div style=\"width:100%;\">");
                sbHtml.Append("<div style=\"display:inline-block;margin-left:10px;float:left\">");
                sbHtml.Append("<span style=\"font-weight:bold;\">Date : </span><label for=\"\" id=\"\">" + dtRetHead.Rows[0]["date"] + "</label><br/>");
                sbHtml.Append("</div>");
                sbHtml.Append("<div style=\"display:inline-block;margin-rght:10px;float:right\">");
                sbHtml.Append("<span style=\"font-weight:bold;\">Net Amount : </span><label for=\"\" id=\"\">" + dtRetHead.Rows[0]["amt"] + "</label><br/>");
                sbHtml.Append("</div>");
                sbHtml.Append("</div>");
                sbHtml.Append("<div class=\"space cl\"></div>");
                sbHtml.Append("</td>");
                sbHtml.Append("</tr>");


                sbHtml.Append("</tbody>");
                sbHtml.Append("</table>");
                sbHtml.Append("<div class=\"cl\"></div>");
                sbHtml.Append("</div>");
                sbHtml.Append("</div>");
            }

            sbHtml.Append("<div class=\"cl\"></div>");
            sbHtml.Append("<div style=\"width:100%; border:1px solid #000000;\"></div>");
            sbHtml.Append("<table>");
            sbHtml.Append("<tbody>");
            sbHtml.Append("<tr><td><p align=\"justify\"><label for=\"\" id=\"lblBillDisclosure\">" + dtBranches.Rows[0]["branch_bill_disclosure"] + "</label></p></td></tr>");
            sbHtml.Append("</tbody>");
            sbHtml.Append("</table>");
            sbHtml.Append("<table class=\"fl\">");
            sbHtml.Append("<tbody>");
            sbHtml.Append("<tr><td style=\"font-weight:bold\">SD:</td></tr>");
            sbHtml.Append("<tr><td style=\"font-weight:bold\">SS: <label for=\"\" id=\"lblStaffNam\">" + dtOrder.Rows[0]["staff_name"] + "</label></td></tr>");
            sbHtml.Append("</tbody>");
            sbHtml.Append("</table>");

            sbHtml.Append("<table class=\"fr\"><tbody><tr><td style=\"font-weight:bold\">Client's Signature____________</td></tr></tbody></table>");
            sbHtml.Append("<div class=\"cl\"></div><table style=\"width:100%; font-size:10px; margin-top:15px; text-align:center;\"><tbody><tr><td></td></tr></tbody></table>");
            
            sbHtml.Append("</div>");



            Document document = new Document();

            string path = System.Web.Hosting.HostingEnvironment.MapPath(HttpContext.Current.Request.ApplicationPath) + "pdf\\" + billno + ".pdf";
            PdfWriter.GetInstance(document, new FileStream(path, FileMode.Create));
            document.Open();
            WebClient wc = new WebClient();
            string htmlText = sbHtml.ToString();
            List<IElement> htmlarraylist = HTMLWorker.ParseToList(new StringReader(htmlText), null);
            for (int k = 0; k < htmlarraylist.Count; k++)
            {
                document.Add((IElement)htmlarraylist[k]);
            }
            document.Close();

            using (MailMessage mail = new MailMessage())
            {
                mail.From = new MailAddress("test@billcrm.com");

                //if (!string.IsNullOrEmpty(Convert.ToString(dtOrder.Rows[0]["cust_email"])))
                //{
                //    mail.To.Add(Convert.ToString(dtOrder.Rows[0]["cust_email"]));
                //}

               
                  //  mail.To.Add("testp7741@gmail.com");


                if (!string.IsNullOrEmpty(Convert.ToString(email)))
                {
                    //info@zoomimpex.com
                    mail.To.Add(Convert.ToString(email));
                }

                mail.Subject = "BillCRM Invoice  #"+billno;
                mail.Body = sbHtml.ToString();
                mail.IsBodyHtml = true;
                mail.Attachments.Add(new Attachment(path));
                //using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
                using (SmtpClient smtp = new SmtpClient("smtpout.secureserver.net", 80))
                {
                    smtp.Credentials = new NetworkCredential("test@billcrm.com", "12345678");
                    //smtp.EnableSsl = true;
                    //smtp.UseDefaultCredentials = true;
                    //smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                    smtp.Send(mail);
                }
            }

            try
            {
                File.Delete(path);
            }
            catch { }

            return "{\"message\":\"success\"}";



        }
        catch (Exception e)
        {
            HttpContext.Current.Response.StatusCode = 401;
            HttpContext.Current.Response.TrySkipIisCustomErrors = true;
            return "{\"message\":\"Error in sending mail "+e.StackTrace+" \"}";
        }
    }


}
