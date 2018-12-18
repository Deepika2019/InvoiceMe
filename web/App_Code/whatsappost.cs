using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Collections.Specialized;
using System.IO;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using Newtonsoft.Json;

/// <summary>
/// Summary description for whatsappost
/// </summary>
[WebService(Namespace = "https://lucidplusitsolutions.com/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class whatsappost : System.Web.Services.WebService {

    public whatsappost () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    #region whatsApp broadCastMsg
    [WebMethod]
    public static string broadCastMsg(string broadcastdata, string tokenkey)
    {
        try
        {
            dynamic sendData = JsonConvert.DeserializeObject(broadcastdata);

            //string json = "{\"phone\":\"919745302878\"," +  "\"body\":\"hello\"}";
            string jsonMessage = "";
            //var jsonObj = new JavaScriptSerializer().Deserialize<RootObj>(broadcastdata);
            if (tokenkey == "lplus123")
            {
                foreach (var obj1 in sendData)
                {
                    jsonMessage = "{\"phone\":\"" + obj1.phone + "\",\"body\":\"" + obj1.body + "\"}";
                    string sendOut = sendmessage(jsonMessage);

                }
                return "{\"status\":\"1\",\"result\":\"true\"}";

            }
            else
            {
                return "{\"status\":\"0\",\"result\":\"false\"}";
            }
        }
        catch (Exception ex)
        {
            return "{\"status\":\"0\",\"result\":\"false\"}";
        }


        //jsonResponse = "{\"count\":\"" + numrows + "\",\"data\":" + jsonData + "}";
    }
    #endregion
    public static string sendmessage(string sendMessage)
    {
        var httpWebRequest = (HttpWebRequest)WebRequest.Create("https://eu22.chat-api.com/instance16739/message?token=xvdqc0wx3bowju24");
        httpWebRequest.ContentType = "application/json";
        httpWebRequest.Method = "POST";
        using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
        {
            streamWriter.Write(sendMessage);
            streamWriter.Flush();
            streamWriter.Close();
        }

        var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
        using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
        {
            var result = streamReader.ReadToEnd();
        }

        return "{\"status\":\"1\",\"result\":\"true\"}";
    }
    
}
