using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.Script.Services;
using System.Web.Services;
using System;

public partial class saveimage : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }


    [WebMethod]
    public static  string UploadImage(string imageData)
    {

        string output = "00";
        try
        {
            
            string imgURL = System.Web.Hosting.HostingEnvironment.MapPath("~/custimage/");
            string fileNameWitPath = imgURL + DateTime.Now.ToString().Replace("/", "-").Replace(" ", "- ").Replace(":", "") + ".jpg";

            using (FileStream fs = new FileStream(fileNameWitPath, FileMode.Create))
            {

                using (BinaryWriter bw = new BinaryWriter(fs))
                {

                    byte[] data = Convert.FromBase64String(imageData);

                    bw.Write(data);

                    bw.Close();
                }

            }
            output = "11";
            
          
        }
        catch (Exception ex)
        {
            output = ex.ToString();
        }
        return output;
        

    }

}





