using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.Net;
using System.Web;
namespace commonfunction
{
    public class EmailSending
    {
        public string sendmail1(string toAddress, string message, string subject)
        {
            MailMessage Msg = new MailMessage();
            Msg.From = new MailAddress("testlp7741@gmail.com", "testlp7741");

            Msg.To.Add(toAddress);


            Msg.Subject = subject;
            Msg.Body = message;
            SmtpClient client = new SmtpClient();
            client.Host = "smtp.gmail.com";
            client.Port = 25;
            client.Credentials = new NetworkCredential("testlp7741@gmail.com", "testtestlp7741");
            client.Send(Msg);
            return "Y";

        }
    }
}
