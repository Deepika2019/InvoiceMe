using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using commonfunction;
using System.Data;
using System.Drawing;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System.IO;

public partial class excelreding_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        //DataTable tbl1 = new DataTable();

        //tbl1 = GetDataTableFromExcel(Request.PhysicalApplicationPath+"excelreding\\Customer_list.xlsx", true);

        //insertCustomers();

        insertItems();
        insertItemStock();

        //insertOldOutstanding();



    }

    //function to insert old outstandings
    private void insertOldOutstanding()
    {
        mySqlConnection db = new mySqlConnection();
        db.BeginTransaction();
        try
        {


            
            string user_id = "";
            string customer_id = "";
            string customer_name = "";
            string branch_id = "";

            string insert_cus_base_qry = "INSERT INTO `tbl_customer` (`cust_name`, `cust_type`, `cust_address`, `cust_city`, `cust_state`, `cust_country`, `cust_phone`, `cust_phone1`, `cust_email`, `cust_amount`, `cust_jodate`, `cust_latitude`, `cust_longitude`, `cust_image`, `cust_note`, `branch_id`, `user_id`, `max_creditamt`, `max_creditperiod`, `new_custtype`, `new_creditamt`, `new_creditperiod`, `cust_approvedby`, `cust_requestedby`, `cust_status`, `cust_wallet_amt`) VALUES";

            for (int i = 10; i <= 19; i++)
            {
                user_id = i.ToString();
                DataTable dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\outstanding_bill_list\\user-" + i + ".xlsx", true);
                foreach (DataRow row in dt.Rows)
                {
                    if (!string.IsNullOrWhiteSpace(row[2].ToString().Trim()))
                    {
                        customer_name = row[2].ToString().Trim();
                        branch_id = (Convert.ToInt32(user_id) <= 16 ? "2" : "1");
                        string qry = insert_cus_base_qry + "( '" + customer_name.Replace("'", "''") + "', 2, 'Address', 'City', 'State', 2, '0000', NULL, NULL, '0.00', '2017-06-14 12:00:00', '0.000000000000000', '0.000000000000000', '0', '0', " + branch_id+ ", " + user_id + ", '5000.00', 120, 0, '0', 0, 8, 0, 0, 0.00);Select last_insert_id();";
                        customer_id=db.SelectScalarForTransaction(qry);
                        continue;
                    }
                    else if (!string.IsNullOrWhiteSpace(row[0].ToString().Trim()) && !string.IsNullOrWhiteSpace(row[1].ToString().Trim())
                        && !string.IsNullOrWhiteSpace(row[3].ToString().Trim()) && !string.IsNullOrWhiteSpace(row[4].ToString().Trim()) )
                    {
                        if(string.IsNullOrWhiteSpace(customer_name) && string.IsNullOrWhiteSpace(customer_id) && string.IsNullOrWhiteSpace(branch_id))
                        {
                            throw new Exception("invalid customer_name,cus_id,branch_id");
                        }
                        DateTime date = Convert.ToDateTime(row[0]);
                        string ref_no = row[1].ToString().Trim();
                        string net_amt = Convert.ToDouble(row[3].ToString().Trim().Replace("Dr", "").Replace("Cr", "")).ToString();
                        string balance = Convert.ToDouble(row[4].ToString().Trim().Replace("Dr", "").Replace("Cr", "")).ToString();
                        //calling ws
                        saveOldEntryToSalesMaster(customer_id, customer_name, date, ref_no, net_amt, balance, branch_id, user_id, "Entry from excel",db);
                    }
                }
            }
            db.CommitTransaction();
        }
        catch(Exception e)
        {
            db.RollBackTransaction();
            throw e;
        }

    }

    public bool saveOldEntryToSalesMaster(string customerid, string customername, DateTime date, string oldinvoiceid, string netamout, string TotalBalanceAmount,
       string BranchId, string userid, string SpecialNote, mySqlConnection db)
    {
        
        string checkstatus = "N";
        string query = "";
        try
        {
            oldinvoiceid = oldinvoiceid +"@"+customerid + "#";
            string qryOldInvoiceCheck = "SELECT SIM.sm_id FROM tbl_sales_items SIM inner join tbl_sales_master SM on SM.sm_id=SIM.sm_id WHERE  SM.branch_id=" + BranchId + " && SIM.itm_name LIKE '" + oldinvoiceid + "%'";
            string existId = db.SelectScalarForTransaction(qryOldInvoiceCheck);
            if (!string.IsNullOrWhiteSpace(existId))
            {
                throw new Exception("old invoice check "+ oldinvoiceid +" "+ (BranchId == "2" ? "Ajman" : "Abudhabi"));

                //string log_path = System.Web.HttpContext.Current.Server.MapPath("~") + "\\log\\";
                //File.AppendAllText(log_path + "log_oldInvoiceRepeat.log", "==========================" + Environment.NewLine);
                //File.AppendAllText(log_path + "log_oldInvoiceRepeat.log", Environment.NewLine + "Invoice reference- " + oldinvoiceid + Environment.NewLine);
                //File.AppendAllText(log_path + "log_oldInvoiceRepeat.log", Environment.NewLine + "Branch- " + (BranchId == "2" ? "Ajman" : "Abudhabi") + Environment.NewLine);
                //File.AppendAllText(log_path + "log_oldInvoiceRepeat.log", "==========================" + Environment.NewLine);
            }

            DataTable ddt = new DataTable();

            string currdatetime = date.ToString("yyyy/MM/dd HH:mm:ss");

            Int32 BillNo = 0;


            Decimal sm_paid = Convert.ToDecimal(netamout) - Convert.ToDecimal(TotalBalanceAmount);
            
            query = "INSERT INTO tbl_sales_master(sm_refno,cust_id,cust_name,branch_id,sm_total,sm_discount_rate,sm_discount_amount,sm_tax,sm_netamount,sm_date,";
            query = query + "sm_userid,sm_outstanding_billdate,sm_previous_amount,sm_currenttotal,sm_paid,sm_balance,sm_parent,sm_bank,sm_chq_no,sm_chq_date,sm_card_no,sm_card_type,sm_card_bank,sm_chq_amt,sm_card_amt,sm_cash_amt,sm_wallet_amt,sm_specialnote,sm_delivery_status,sm_mandatory_date,sm_exceed_date,sm_latitude,sm_longitude,total_paid,total_balance,sm_processed_id,sm_delivered_id)";
            query = query + "VALUES (" + BillNo + ",'" + customerid + "','" + customername.Replace("'", "''") + "','" + BranchId + "','" + netamout + "','0','0','0','" + netamout + "','" + currdatetime + "',";
            query = query + "'" + userid + "','0000-00-00',0,'" + netamout + "','" + sm_paid + "','" + TotalBalanceAmount + "',";
            query = query + "'1','','','0000-00-00', ";
            query = query + "'','','','',";
            query = query + "'','" + sm_paid + "','0','" + SpecialNote + "','2','0000-00-00','0000-00-00',0,0,'" + sm_paid + "','" + TotalBalanceAmount + "',0,0);Select last_insert_id()";
            
            var newsm_id = db.SelectScalarForTransaction(query);
            if(newsm_id==null || newsm_id == "")
            {
                throw new Exception("sm insertion failed");
            }
            BillNo = Convert.ToInt32(newsm_id);

            // update smref of sales
            string slmstrupdate = "UPDATE tbl_sales_master SET sm_refno='" + BillNo + "' WHERE sm_id='" + BillNo + "'";
            if (!db.ExecuteQueryForTransaction(slmstrupdate))
            {
                throw new Exception("sm updation failed");
            }


            string qry1 = "INSERT INTO tbl_sales_items (sm_id,row_no,itbs_id,itm_code,itm_name,itm_batchno,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,ofr_id,ofritm_id,si_itm_type)";
            qry1 = qry1 + "VALUES ";



            Int64 salesitemBranchId = Convert.ToInt64(db.SelectScalarForTransaction("Select itbs_id from tbl_itembranch_stock where itm_code='1234567891234' and branch_id=" + BranchId));

            string qry_main = qry1 + "('" + BillNo + "','0','" + salesitemBranchId + "', '1234567891234','" + oldinvoiceid + "OLD BILL ITEM',";
            qry_main = qry_main + "'0','" + netamout + "','" + netamout + "','1',";
            qry_main = qry_main + "'" + netamout + "',";
            qry_main = qry_main + "'0','0','" + netamout + "','0','0','0','0',0,0,3)";
            
            bool qrystatus = db.ExecuteQueryForTransaction(qry_main);
            if (qrystatus)
            {
                string updateqry = "update tbl_customer set cust_amount=cust_amount+" + TotalBalanceAmount + " where cust_id=" + customerid;
                if (!db.ExecuteQueryForTransaction(updateqry))
                {
                    throw new Exception("Customer updation failed");
                }
                checkstatus = "Y";

            }
            else
            {
                throw new Exception("Item insertion failed");
            }


            

        }
        catch (Exception ex)
        {
            throw ex;
        }
        return true;


        //change code
    }

    //function to insert customers- hari
    private void insertCustomers() {
        DataTable dt = new DataTable();

        dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\customer_list_hykon.xlsx", true);
        mySqlConnection db = new mySqlConnection();
        int i = 100;
        string qry_base = "INSERT INTO `tbl_customer` (`cust_id`, `cust_name`, `cust_type`, `cust_address`, `cust_city`, `cust_state`, `cust_country`, `cust_phone`, `cust_phone1`, `cust_email`, `cust_amount`, `cust_jodate`, `cust_latitude`, `cust_longitude`, `cust_image`, `cust_note`, `branch_id`, `user_id`, `max_creditamt`, `max_creditperiod`, `new_custtype`, `new_creditamt`, `new_creditperiod`, `cust_approvedby`, `cust_requestedby`, `cust_status`, `cust_wallet_amt`) VALUES";
        foreach (DataRow row in dt.Rows) {
            i++;
            string cus_name = row[0].ToString().Replace("'", "").Trim(), address="Address";
            if(row[0].ToString().Replace("'", "").Contains(","))
            {
                cus_name = row[0].ToString().Trim();
                address = row[2].ToString().Trim();
            }
            if (cus_name.Equals(""))
            {
                continue;
            }
            string qry=qry_base+"("+i+", '"+ cus_name + "', 2, '" + address+ "', 'City', 'State', 2, '0000', NULL, NULL, '0.00', '2017-02-24 12:00:00', '0.000000000000000', '0.000000000000000', '0', '0', 1, 9, '5000.00', 60, 2, '0', 0, 8, 0, 0, 0.00)";
            db.ExecuteQuery(qry);
        }

    }

    //function  to insert items -hari
    private void insertItems() {
        DataTable dt = new DataTable();

        
        
        dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\JupiterPricelist.xlsx", true);
        //dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\hykon_item_list.xlsx", true);
        mySqlConnection db = new mySqlConnection();
        int i = 100;
        string qry_base = "INSERT INTO `tbl_item_master` (`itm_id`, `itm_code`, `itm_name`, `itm_description`, `itm_brand_id`, `itm_category_id`, `itm_subcategory_id`, `itm_supplierid`,itm_type) VALUES";
        foreach (DataRow row in dt.Rows)
        {
            i++;
            string item_code = row[6].ToString().Trim().Equals("")?"0": row[6].ToString().Trim();
            string item_name = row[1].ToString().Trim().Replace("'","") + " " + row[2].ToString().Trim().Replace("'", "");
            string brand_id = row[10].ToString().Trim();
            string category_id = row[8].ToString().Trim();
            if (item_name.Trim().Equals("")) continue;
            string qry = qry_base + "('" + i + "', '" +item_code+ "', '"+item_name+"', NULL, '"+brand_id+"', '"+category_id+"', 0, 0,0)";
            db.ExecuteQuery(qry);
        }
    }

    //function to insert items in item branch stock
    private void insertItemStock()
    {
        DataTable dt = new DataTable();

        dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\JupiterPricelist.xlsx", true);
        //dt = GetDataTableFromExcel(Request.PhysicalApplicationPath + "excelreding\\hykon_item_list.xlsx", true);
        mySqlConnection db = new mySqlConnection();
        int i = 100;
        int s = 100;
        string selectTimezonQuery = "select ss_default_time_zone from tbl_system_settings";
        DataTable timezoneDt = new DataTable();
        timezoneDt = db.SelectQuery(selectTimezonQuery);
        TimeZoneInfo CurrentZone = TimeZoneInfo.FindSystemTimeZoneById(timezoneDt.Rows[0]["ss_default_time_zone"].ToString());
        DateTime TimeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, CurrentZone);
        string updatedDate = DateTime.Parse(TimeNow.ToString()).ToString("yyyy-MM-dd HH:mm:ss");
        //db.ExecuteQuery("truncate table tbl_itembranch_stock");
        string qry_base = "INSERT INTO `tbl_itembranch_stock` (`itbs_id`, `branch_id`, `itm_id`, `itbs_stock`, `itbs_reorder`, `itbs_available`, `itm_code`, `itm_name`, `itm_brand_id`, `itm_category_id`, `itm_subcategory_id`, `itm_mrp`, `itm_class_one`, `itm_class_two`, `itm_class_three`, `itm_commision`, `itm_target`,tp_tax_code,itbs_duration,itm_last_update_date) VALUES";
        foreach (DataRow row in dt.Rows)
        {
            i++;
            DataTable dtItem = db.SelectQuery("select itm_id,itm_code,itm_name,itm_brand_id,itm_category_id from tbl_item_master where itm_id="+i);
            if (dtItem.Rows.Count == 0) continue;
            string item_code = dtItem.Rows[0]["itm_code"].ToString();
            string item_name = dtItem.Rows[0]["itm_name"].ToString();
            string brand_id = dtItem.Rows[0]["itm_brand_id"].ToString();
            string category_id = dtItem.Rows[0]["itm_category_id"].ToString();
            string hsnCode = row[11].ToString().Trim();
            string tax = row[12].ToString().Trim();
            string existHsn = db.SelectScalar("select tp_tax_code from tbl_tax_profile where tp_tax_title='"+hsnCode+"'");
            if (existHsn == "0" || existHsn == "")
            {
               existHsn= db.SelectScalar("insert into  tbl_tax_profile(tp_tax_code,tp_parent,tp_tax_title,tp_tax_type,tp_tax_percentage)values(null,0,'" + hsnCode + "',2,'" + tax + "');Select last_insert_id();");
            }
            string price_a = Convert.ToDouble(row[3].ToString().Trim().Equals("") ? "0" : row[3].ToString().Trim()).ToString();
            string price_b = Convert.ToDouble(row[4].ToString().Trim().Equals("") ? "0" : row[4].ToString().Trim()).ToString();
            string price_c = Convert.ToDouble(row[5].ToString().Trim().Equals("") ? "0" : row[5].ToString().Trim()).ToString();
            if (item_name.Trim().Equals("")) continue;
            for (int br_id = 1; br_id <= 1; br_id++)
            {
                s++;
                string qry = qry_base + "(" + s + ", "+br_id+", " + i + ", 5000, 1000, 1, '" + item_code + "', '" + item_name + "', " + brand_id + ", " + category_id + ", 0, 0.00, " + price_a + ", " + price_b + ", " + price_c + ", 6.00, 0.00,"+existHsn+",0,'"+updatedDate+"')";
                db.ExecuteQuery(qry);
            }
        }
    }


    public void insertUsers( DataTable tbl)
    {



        foreach (DataRow dr in tbl.Rows) // search whole table
        {


            mySqlConnection db = new mySqlConnection();
            string query;
            query = "INSERT INTO tbl_item_master_test(itm_id, itm_code, itm_name,itm_brand_id, itm_category_id, itm_subcategory_id, itm_supplierid,a,b,c)";
            //query = query + "VALUES ('" + dr["itemid"].ToString() + "','" + dr["code"].ToString() + "','" + dr["Name"].ToString() + " - " + dr["qty"].ToString() + "','" + dr["brand_id"].ToString() + "','" + dr["category_id"].ToString() + "','0','0','" + dr["a"].ToString() + "','" + dr["b"].ToString() + "','" + dr["c"].ToString() + "')";

            query = query + "VALUES ('" + dr["itemid"].ToString() + "','" + dr["code"].ToString() + "','" + dr["Name"].ToString() + "','" + dr["brand_id"].ToString() + "','" + dr["category_id"].ToString() + "','0','0','" + dr["a"].ToString() + "','" + dr["b"].ToString() + "','" + dr["c"].ToString() + "')";

            bool queryStatus = db.ExecuteQuery(query);

           

        }

    }

    public void updateTablefiled()
    {

        mySqlConnection db = new mySqlConnection();
        string query;
        query = "SELECT tbl_item_master_test.itm_name, tbl_item_master_test.itm_id, tbl_item_brand.brand_name, tbl_item_category.cat_name FROM tbl_item_master_test INNER JOIN";
        query =   query + " tbl_item_brand ON tbl_item_master_test.itm_brand_id = tbl_item_brand.brand_id INNER JOIN tbl_item_category ON tbl_item_master_test.itm_category_id = tbl_item_category.cat_id";
        DataTable dt = new DataTable();
        dt = db.SelectQuery(query);

        foreach (DataRow dr in dt.Rows) // search whole table
        {

            string newtext = dr["brand_name"].ToString() + " " + dr["cat_name"].ToString() + " " + dr["itm_name"].ToString();

            mySqlConnection db1 = new mySqlConnection();
            string query1;
            query1 = "update tbl_item_master_test set itm_name = '" + newtext + "' where itm_id = '" + dr["itm_id"].ToString() + "'";
            bool queryStatus = db1.ExecuteQuery(query1);

        }
    }

    public void insertDatatableToBranchStock( DataTable dt)
    {

        foreach (DataRow dr in dt.Rows) // search whole table
        {
            mySqlConnection db = new mySqlConnection();
            string query;
            query = "INSERT INTO tbl_itembranch_stock (itbs_id, branch_id, itm_id, itbs_stock, itbs_reorder, itbs_available, itm_code, itm_name, itm_brand_id, itm_category_id, itm_class_one, itm_class_two, itm_class_three, itm_commision) ";
            query = query + "VALUES ('" + dr["itbs_id"].ToString() + "','" + dr["branch_id"].ToString() + "','" + dr["itm_id"].ToString() + "','5000','1000','1','" + dr["itm_code"].ToString() + "','" + dr["itm_name"].ToString() + "','" + dr["itm_brand_id"].ToString() + "','" + dr["itm_category_id"].ToString() + "','" + dr["a"].ToString() + "','" + dr["b"].ToString() + "','" + dr["c"].ToString() + "',0)";
            bool queryStatus = db.ExecuteQuery(query);

            /* 
              if (dr["id"].ToString() == "1")
              {
                  //dr["id"] = "1111";

                  //dr["Product_name"] = "cde"; //change the name
                  //break; break or not depending on you
              }


           DataTable dt = new DataTable();
       
             int itm_id;
             string qry = "select MAX(itm_id) as itm_id from tbl_item_master_test";
             dt = db.SelectQuery(qry);


             if (dt != null)
             {
                 if (dt.Rows.Count > 0)
                 {
                     if (dt.Rows[0]["itm_id"] is DBNull)
                     {
                         itm_id = 1;
                     }
                     else
                     {
                         itm_id = Convert.ToInt32(dt.Rows[0]["itm_id"]);
                         itm_id = ++itm_id;
                  
                     }
                 }
                 else
                 {
                     itm_id = 1;
                 }
             }
             */

        }

    }

    public void insertDatatabletotable(DataTable tbl1)
    {


        foreach (DataRow dr in tbl1.Rows) // search whole table
        {


            mySqlConnection db = new mySqlConnection();
            string query;
            query = "INSERT INTO tbl_item_master_test(itm_id, itm_code, itm_name,itm_brand_id, itm_category_id, itm_subcategory_id, itm_supplierid,a,b,c)";
            //query = query + "VALUES ('" + dr["itemid"].ToString() + "','" + dr["code"].ToString() + "','" + dr["Name"].ToString() + " - " + dr["qty"].ToString() + "','" + dr["brand_id"].ToString() + "','" + dr["category_id"].ToString() + "','0','0','" + dr["a"].ToString() + "','" + dr["b"].ToString() + "','" + dr["c"].ToString() + "')";

            query = query + "VALUES ('" + dr["itemid"].ToString() + "','" + dr["code"].ToString() + "','" + dr["Name"].ToString() + "','" + dr["brand_id"].ToString() + "','" + dr["category_id"].ToString() + "','0','0','" + dr["a"].ToString() + "','" + dr["b"].ToString() + "','" + dr["c"].ToString() + "')";
            
            bool queryStatus = db.ExecuteQuery(query);

            /* 
              if (dr["id"].ToString() == "1")
              {
                  //dr["id"] = "1111";

                  //dr["Product_name"] = "cde"; //change the name
                  //break; break or not depending on you
              }


           DataTable dt = new DataTable();
       
             int itm_id;
             string qry = "select MAX(itm_id) as itm_id from tbl_item_master";
             dt = db.SelectQuery(qry);


             if (dt != null)
             {
                 if (dt.Rows.Count > 0)
                 {
                     if (dt.Rows[0]["itm_id"] is DBNull)
                     {
                         itm_id = 1;
                     }
                     else
                     {
                         itm_id = Convert.ToInt32(dt.Rows[0]["itm_id"]);
                         itm_id = ++itm_id;
                  
                     }
                 }
                 else
                 {
                     itm_id = 1;
                 }
             }
             */

        }

    }

    public static DataTable GetDataTableFromExcel(string path, bool hasHeader = true)
    {
        using (var pck = new OfficeOpenXml.ExcelPackage())
        {
            using (var stream = File.OpenRead(path))
            {
                pck.Load(stream);
            }
            var ws = pck.Workbook.Worksheets.First();
            DataTable tbl = new DataTable();
            foreach (var firstRowCell in ws.Cells[1, 1, 1, ws.Dimension.End.Column])
            {
                tbl.Columns.Add(hasHeader ? firstRowCell.Text : string.Format("Column {0}", firstRowCell.Start.Column));
            }
            var startRow = hasHeader ? 2 : 1;
            for (int rowNum = startRow; rowNum <= ws.Dimension.End.Row; rowNum++)
            {
                var wsRow = ws.Cells[rowNum, 1, rowNum, ws.Dimension.End.Column];
                DataRow row = tbl.Rows.Add();
                foreach (var cell in wsRow)
                {
                    row[cell.Start.Column - 1] = cell.Text;
                }
            }
            return tbl;
        }
    }


}