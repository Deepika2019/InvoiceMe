<%@ WebHandler Language="C#" Class="UploadHandler" %>
using System.Collections.Generic;
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Web;
using System.IO;



public class UploadHandler : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
       String RelativePath = context.Request.PhysicalApplicationPath;
            //Uploaded File Deletion
            if (context.Request.QueryString.Count > 0)
            {
                
              //  string filePath = HttpContext.Current.Server.MapPath("DownloadedFiles") + "//" + context.Request.QueryString[0].ToString();
               // string filePath = "G:\\PleskVhosts\\lucidplusitsolutions.com\\lifelinecrm.org\\DownloadedFiles" + "//" + context.Request.QueryString[0].ToString();
                string filePath = RelativePath + "logoImage" + "//" + context.Request.QueryString[0].ToString();
               
                if (File.Exists(filePath))
                    File.Delete(filePath);
            }
            //File Upload
            else
            {
                  string ext = System.IO.Path.GetExtension(context.Request.Files[0].FileName);
                  //var fileName = Path.GetFileName( context.Request.Files[0].FileName);
                  String fileName = DateTime.Now.Day.ToString() + DateTime.Now.Month.ToString() + DateTime.Now.Year.ToString() + (DateTime.Now.TimeOfDay.ToString().Replace(":","")).Replace(".","");
                  //var fileName=   Path.GetRandomFileName();

                 // string fileName = Path.GetFileName(context.Request.Files[0].FileName);
                  string path = RelativePath + "logoImage";
                  //string result;

                  fileName = Path.GetFileNameWithoutExtension(fileName);
                  

                  fileName = Path.GetFileName(fileName);
                
                
                
                
                   if (context.Request.Files[0].FileName.LastIndexOf("\\") != -1)
                    {
                        //fileName = context.Request.Files[0].FileName.Remove(0, context.Request.Files[0].FileName.LastIndexOf("\\")).ToLower();                        
                        fileName =DateTime.Now.ToString();
                    }
                   fileName = GetUniqueFileName(fileName, RelativePath + "logoImage/", ext).ToLower();

                   string location = RelativePath + "logoImage/" + fileName + ext;
                
                    byte[] fileData = null;
                    using (var binaryReader = new BinaryReader(context.Request.Files[0].InputStream))
                    {
                        fileData = binaryReader.ReadBytes(context.Request.Files[0].ContentLength);
                    }
                 
                    
                    Image getimage = ByteArrayToImagebyMemoryStream(fileData);  //converts to image from ByteArray

                    Size newSize = new Size(150, 140);
                    Image ResizedImage = resizeImage(getimage, newSize);    //Resizing image w.r.t newSize
                
                    ResizedImage.Save(location);    //saving image
              //  context.Request.Files[0].SaveAs(location);
                context.Response.Write(fileName + ext);
                context.Response.End();
            } 
     
       
    }

    public static Image ByteArrayToImagebyMemoryStream(byte[] imageByte)
    {
        MemoryStream ms = new MemoryStream(imageByte);
        Image image = Image.FromStream(ms);
        return image;
    }
    
    private static Image resizeImage(Image imgToResize, Size size)
    {
        int sourceWidth = imgToResize.Width;
        int sourceHeight = imgToResize.Height;

        float nPercent = 0;
        float nPercentW = 0;
        float nPercentH = 0;

        nPercentW = ((float)size.Width / (float)sourceWidth);
        nPercentH = ((float)size.Height / (float)sourceHeight);

        if (nPercentH < nPercentW)
            nPercent = nPercentH;
        else
            nPercent = nPercentW;

        int destWidth = (int)(sourceWidth * nPercent);
        int destHeight = (int)(sourceHeight * nPercent);

        Bitmap b = new Bitmap(destWidth, destHeight);
        Graphics g = Graphics.FromImage((Image)b);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;

        g.DrawImage(imgToResize, 0, 0, destWidth, destHeight);
        g.Dispose();

        return (Image)b;
    }
    
    public static string GetUniqueFileName(string name, string savePath, string ext)
    {
        name = name.Replace(ext, "").Replace(" ", "_");
        name = System.Text.RegularExpressions.Regex.Replace(name, @"[^\w\s]", "");

        var newName = name;
        var i = 0;
        if (System.IO.File.Exists(savePath + newName + ext))
        {

            do
            {
                i++;
                newName = name + "_" + i;

            }
            while (System.IO.File.Exists(savePath + newName + ext));

        }

        return newName;


    }
    
   
    
    public bool IsReusable {
        get {
            return false;
        }
    }
    
  
 }   