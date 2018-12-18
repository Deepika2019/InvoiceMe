<%@ Page Language="C#" AutoEventWireup="true" CodeFile="salesReturnReportAdvnc.aspx.cs" Inherits="reports_salesReturnReportAdvnc" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
    <title>Sales Return Report | Invoice Me</title>



   <script type="text/javascript" src="../js/common.js"></script>
     <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>
     <script type="text/javascript" src="../js/jquery.cookie.js"></script>
     <script type="text/javascript" src="../js/pagination.js"></script>
    
    <script type="text/javascript" src="../js/jQuery.print.js"></script>


      <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet"/>
    <!-- Font Awesome -->
  <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet"/>
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet"/>
    <!-- iCheck -->
    <link href="../css/bootstrap/green.css" rel="stylesheet"/>

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet"/>
    <!-- mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet"/>


             <!--date picker-->
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!--date picker-->

    <script type="text/javascript">
        var BranchId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            $("#txtSearchFromDate").val('');
            $("#txtSearchToDate").val('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#comboRtntype").val(-1);
            //showProfileHeader(1);
            ShowUTCDate();
            showBranches();
            
            // userButtonRoles();
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
        });

        // for querystring

        function getQueryString(key) {
            return queryParams[key];
        }
        function setQueryParams() {
            queryParams = {};
            var queryStringArray = location.search.replace(/[`~!@#$%^*()|+\?;:'",.<>\{\}\[\]\\\/]/gi, '').split("&");
            for (var i = 0; i < queryStringArray.length; i++) {
                queryParams[queryStringArray[i].split("=")[0]] = queryStringArray[i].split("=")[1];
            }
        }
        //  function to get highlighted text-align
        function getHighlightedValue(searchQuery, value) {
            var regex = new RegExp('(' + searchQuery + ')', 'gi');
            var highlightedtext = "<span style='color:#4A2115' >" + searchQuery + "</span>";
            return value.replace(regex, "<span style='color:#4A2115' >$1</span>");
        }
        //end query string



        $(function () {
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();

            $('#txtSearchFromDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'dd-mm-yy'
            });
            $('#txtSearchToDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'dd-mm-yy'
            });
        });//end
        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtSearchFromDate").val(localdate);
            $("#txtSearchToDate").val(localdate);

           // showDailyReports(1);
        }//end

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];

        }//end


        function sqlInjection() {
            $('input, select, textarea').each(
                function (index) {
                    var input = $(this);
                    var type = this.type ? this.type : this.nodeName.toLowerCase();
                    if (type == "text" || type == "textarea") {

                        $("#" + input.attr('id')).val(input.val().replace(/'/g, '"'));
                    }
                    else {
                    }
                }
            );
        }//end


        function showDailyReport() {

            var brnchid = $.cookie("invntrystaffBranchId");
          
            $("#txtSearchFromDate").text('');
            $("#txtSearchToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#comboBranchesInReport").val(brnchid);
            $("#comboCustomersInReport").val(0);
            $("#comboSalesInReport").val(0);          
            $("#lblSummaryBranchName").text('');
            $("#lblcountSales").text('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');


            $("#comboRtntype").val(-1);
             ShowUTCDate();
            showDailyReports(1);
        }


        //start: show branches in Reports page
        function showBranches() {
            var loggedInBranch = $.cookie("invntrystaffBranchId");
            var userid = $.cookie("invntrystaffId");
            //alert(userid);
            loading();
            $.ajax({
                type: "POST",
                url: "salesReturnReportAdvnc.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                  //  alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#comboBranchesInReport").html(htm);
                    $("#comboBranchesInReport").val(loggedInBranch);
                    showcustomers();
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //stop: show warehouse in reports page
        //start function for listing customers
        function showcustomers() {
            $.ajax({
                type: "POST",
                url: "salesReturnReportAdvnc.aspx/showCustomersInReports",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Customer--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cust_id + '">' + row.cust_name + '</option>';
                    });
                    $("#comboCustomersInReport").html(htm);
                    showsalespersons();
                    //  showDailyReports(1);

                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end
        function showsalespersons() {
            $.ajax({
                type: "POST",
                url: "salesReturnReportAdvnc.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Salesperson--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.first_name + '&nbsp' + row.last_name + '</option>';
                    });
                    $("#comboSalesInReport").html(htm);
                    showDailyReports(1);
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        //Start:Show Daily Reports List
        function showDailyReports(page) {

            $("#tblReportsContent tbody").empty();
            var sum = 0;
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            // today = yyyy + '/' + mm + '/' + dd;
            today = dd + '-' + mm + '-' + yyyy;

            //needded format 2014/02/12
            //now 24-01-2014
            var fromdate1 = $("#txtSearchFromDate").val();
            var todate1 = $("#txtSearchToDate").val();
            //alert(fromdate); alert(todate);
            if (fromdate1 != "") {
                var splitarray = fromdate1.split("-");
                var fromdate = splitarray[2] + "/" + splitarray[1] + "/" + splitarray[0];
            }
            else {
                var fromdate = fromdate1;
            }
            if (todate1 != "") {
                var splitarray1 = todate1.split("-");
                var todate = splitarray1[2] + "/" + splitarray1[1] + "/" + splitarray1[0];
            }
            else {
                var todate = todate1;
            }
            // alert(searchtype);

            var perpage = $("#txtpageno").val();
            //  alert(perpage);
            var query = "";
            // alert(sprovider);alert(client1);alert(client);alert(invoice);alert(amount);alert(date);

            if (fromdate != "" && todate != "" && (fromdate != todate)) {
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {
                //query = query + " and (CONVERT(VARCHAR(10), BillDate, 111)  = *" + fromdate + "*)";
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboBranchesInReport").val();
            var BranchName = $("#comboBranchesInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
                query = query + " and (tbl_sales_master.branch_id IN(select branch_id from tbl_user_branches where user_id=*" + $.cookie("invntrystaffId") + "*)) ";
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
            }

            var customerid = $("#comboCustomersInReport").val();
            //   alert(customerid);
            //     var BranchName = $("#comboCustomersInReport option[value='" + BranchId + "']").text();
            if (customerid == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_salesreturn_master.cust_id =*" + customerid + "*) ";
            }

            var rtntypeId = $("#comboRtntype").val();
            // alert(rtntypeId);
            var rtnType = $("#comboRtntype option[value='" + rtntypeId + "']").text();
            if (rtntypeId == -1) {
            }
            else {

                query = query + " and (tbl_salesreturn_items.sri_type  =*" + rtntypeId + "*) ";
            }

            var salespersonid = $("#comboSalesInReport").val();
            //alert(salespersonid);
            if (salespersonid == "0") {
            } else {
                query = query + " and (tbl_sales_master .sm_userid =*" + salespersonid + "*) ";
            }



            var searchResult = query.substring(4);
            searchResult = "WHERE " + searchResult;
            loading();

           // alert(searchResult);     
            $.ajax({
                type: "POST",
                url: "salesReturnReportAdvnc.aspx/showDailyReports",
                data: "{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                 //alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblTotalRecords").text(0);

                        $('#tblReportsContent  tbody').html("<tr class='overeffect'><td colspan='7' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");

                       // alert("Not Found..!");
                        $("#lblSummaryBranchName").text('');
                     
                        $("#lblReportBranchName").text('');
                        
                        $("#divSummryall").hide();
                        $("#divsumry").hide();
                        $("#SummaryReportDiv").html('');
                        return false;
                    }
                    else {

                        var obj = JSON.parse(msg.d);
                        var htm = "";
                        var html = "";
                        var htmls = "";
                        var a;
                        //htm += "<div class='repotdetails'>";
                       // htm += "<tr><td class='borderbottom tableheadfonts'>Order No</td><td class='borderbottom tableheadfonts'>Ref No</td><td class='borderbottom tableheadfonts'>Date</td><td class='borderbottom tableheadfonts'>Cust.ID</td><td class='borderbottom tableheadfonts' style='width:180px'>Cust.Name</td>";
                       // htm += "<td class='borderbottom tableheadfonts'>Total Amt.</td></tr>";

                       // $("#tblReportsContent tbody").append(htm);
                        htm = "";
                        var checkorderId = 0;

                        var ids = 0;
                        var rootId = 0;
                        var idForTotalDiv = "";
                        var divMultiitemId = "";
                        var sum = 0;
                        $.each(obj.data, function (i, row) {

                            var cnt = obj.count;
                          // alert(cnt);
                            $("#lblcountSales").text(cnt);

                            if (checkorderId != row.srm_id) {

                                htm = "";
                                sum = 0;
                                rootId = parseInt(rootId) + 1;

                                idForTotalDiv = 'totalSum' + rootId;
                                tdMultiitemId = 'divMultiitems' + rootId.toString();
                                html = "";
                                var paymentmode = "";
                                sum = parseFloat(sum) + parseFloat(row.sri_total);
                              
                                htm += "<tr><td> " + row.srm_id + "</td>";

                                htm += "<td><a href='/sales/manageorders.aspx?orderId=" + row.sm_refno + "' style='text-decoration:none; color:#056dba;'>" + row.sm_refno + "</a></td>";

                                htm += "<td>" + row.BillDate + "</td>";
                                // htm += "<td class='borderbottomdot tablefonts'>" + paymentmode + "</td>";
                                htm += "<td><a href='../managecustomers.aspx?cusId=" + row.cust_id + "' style='text-decoration:none; color:#056dba;'>" + row.cust_id + "</a></td>";

                                //htm += "<td class='borderbottomdot tablefonts'><a href=javascript:viewMember('" + row.cust_id + "'); style='text-decoration:none;'>" + row.cust_id + "</a></td>";




                                htm += "<td>" + row.cust_name + "</td>";
                                htm += "<td id='" + idForTotalDiv + "'>" + sum + " </td>";
                              //  alert(row.sri_type);
                                if (row.sri_type == "0") {
                                    status = "Damaged";
                                } else if (row.sri_type == "1") {
                                    status = "Convert To Bulk";
                                } else if (row.sri_type = "2") {
                                    status = "Ready To Use";
                                }
                                htm += "<td>" + status + "</td></tr>";
                                //htm += "<td  class='borderbottomdot tablefonts'>" + row.sri_total + "</td></tr>";
                                htm += "<tr><td id='" + tdMultiitemId + "' class='' colspan='12'>Returned By:" + row.first_name + "&nbsp" + row.last_name + "<br>"
                               // htm += "<td  colspan='12' style='padding: 5px;font-weight:bold;font-size:11px;'>";

                                htm += "<span > Items:</span>";

                                a = 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.sri_qty + " * " + row.si_price + ")-";
                                htm += "" + row.sri_discount_amount + "=" + row.sri_total + ")  &nbsp &nbsp ";
                                htm += "</td>";
                                htm += "</tr>";

                             //   htm += "<tr><td colspan='6'  style='border-bottom:none;'>";

                                htm += "</td></tr>";
                                $("#tblReportsContent tbody").append(htm);
                                htm = "";
                            }
                            else {
                                //  alert("Test");
                                htm = "";
                                a = a + 1;

                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.sri_qty + " * " + row.si_price + ")-";
                                htm += "" + row.sri_discount_amount + "=" + row.sri_total + ")  &nbsp &nbsp ";
                                sum = sum + parseFloat(row.sri_total);
                                $("#" + tdMultiitemId).append(htm);
                                $("#" + idForTotalDiv).html(sum);
                            }

                            checkorderId = row.srm_id;
                        });




                        //html += "<table cellpadding='0' cellspacing='0' style='width:500px; line-height:24px; display:;'>";
                        //html += "<tr> <td style='border-bottom:1px solid #000;' colspan='2'> <span style='font-weight:bold;font-size:14px;'>Sales Return Summary</span> ( Total Records: " + obj.count + " ) </td> </tr>";
                        //html += "<tr> <td><div class='space1'></div></td></tr>";
                        //html += "<tr> <td style='border-bottom:1px dashed #000;font-weight:bold;'>Net Amount</td> <td style='border-bottom:1px dashed #000; text-align:right; font-size:12px;font-weight:bold;'>" + obj.totalnetamt + " " + obj.currency + "</td> </tr>";
                        //html += "<tr> <td><div class='space1'></div></td></tr>";
                        //html += "</table>";

                        htmls += "<table class='table' > <tbody>";
                      //  alert(obj.totalnetamt);
                        htmls += "<tr> <th>Net Amount</th><td>" + obj.totalnetamt + " " + obj.currency + "</td> </tr>";
                        htmls += "<tr><td colspan='2'></td></tr>";
                        htmls += "</tbody></table>";



                        $("#divSummryall").show();
                        $("#divsumry").show();
                        $("#SummaryReportDiv").html(htmls);

                        var BranchName = $("#comboBranchesInReport option:selected").text();
                        $("#lblReportBranchName").text(BranchName);
                        $("#lblSummaryBranchName").text(BranchName);


                        $("#lblTotalRecords").text(obj.count);


                        if (fromdate != "" && todate != "") {
                            $("#lblReportFromDate").text(fromdate1);
                            $("#lblReportToDate").text(todate1);
                            $("#lblSummaryFromDate").text(fromdate1);
                            $("#lblSummaryToDate").text(todate1);
                            //  showSummaryReport();
                        }
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //end

        //Start:Download Daily Reports List
        function DownloadDailyReports() {

            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            // today = yyyy + '/' + mm + '/' + dd;
            today = dd + '-' + mm + '-' + yyyy;

            //needded format 2014/02/12
            //now 24-01-2014
            var fromdate1 = $("#txtSearchFromDate").val();
            var todate1 = $("#txtSearchToDate").val();
            //alert(fromdate); alert(todate);
            if (fromdate1 != "") {
                var splitarray = fromdate1.split("-");
                var fromdate = splitarray[2] + "/" + splitarray[1] + "/" + splitarray[0];
            }
            else {
                var fromdate = fromdate1;
            }
            if (todate1 != "") {
                var splitarray1 = todate1.split("-");
                var todate = splitarray1[2] + "/" + splitarray1[1] + "/" + splitarray1[0];
            }
            else {
                var todate = todate1;
            }
            // alert(searchtype);

            var perpage = $("#txtpageno").val();
            //  alert(perpage);
            var query = "";
            // alert(sprovider);alert(client1);alert(client);alert(invoice);alert(amount);alert(date);

            if (fromdate != "" && todate != "" && (fromdate != todate)) {
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {
                //query = query + " and (CONVERT(VARCHAR(10), BillDate, 111)  = *" + fromdate + "*)";
                query = query + " and (DATE_FORMAT(tbl_salesreturn_master.srm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboBranchesInReport").val();
            var BranchName = $("#comboBranchesInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
            }

            var customerid = $("#comboCustomersInReport").val();
            if (customerid == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_salesreturn_master.cust_id =*" + customerid + "*) ";
            }

            var searchResult = query.substring(4);
            searchResult = "WHERE " + searchResult;
            loading();

            // alert(searchResult);
            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "salesReturnReportAdvnc.aspx/DownloadDailyReports",
                data: "{'searchResult':'" + searchResult + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N" || msg.d == "0") {
                        alert("Not Found...!");
                        return false;
                    }
                    else {

                        location.href = "DownloaditemITReport.aspx";
                        // location.href = "DownloadItemReport.aspx";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }
        //Stop:Download Daily Reports List



        //print report
        function printMainReport() {

            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();


            $("#comboBranchesInReport").hide();
            $("#comboCustomersInReport").hide();
            $("#comboSalesInReport").hide();
            $("#txtSearchFromDate").hide();
            $("#txtSearchToDate").hide();
            $("#lblresultpage").hide();
            $("#txtpageno").hide();
            $("#btnreset").hide();
            $("#btnsearch").hide();

            $("#divtopheader").hide();
            








            $("#tdSearchReportBtn").hide();
            $("#tdSelectBranch").hide();
            $("#tdDateRange").hide();
            $("#spanpageno").hide();

            $("#rtnType").hide();
            // $("#lbPrintReportType").html(searchtype);
            $("#tdReportType").hide();

            //$("#comboRtntype").hide();

            $("#divfrmdte").hide();
            $("#divtodate").hide();
            $("#divRetrntype").hide();
            $("#divshwCustmr").hide();
            $("#divshowSles").hide();
            $("#divshwBranch").hide();


            $("#lbResultperpage").show();
            $("#divReportContent").print();
            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
            $("#tdSearchReportBtn").show();
            $("#tdSelectBranch").show();
            $("#tdDateRange").show();


            $("#divfrmdte").show();
            $("#divtodate").show();
            $("#divRetrntype").show();
            $("#divshwCustmr").show();
            $("#divshowSles").show();
            $("#divshwBranch").show();

            $("#lbResultperpage").hide();
            $("#spanpageno").show();
            $("#tdReportType").show();
            $("#tdPrintReportType").hide();



            $("#comboBranchesInReport").show();
            $("#comboCustomersInReport").show();
            $("#comboSalesInReport").show();
            $("#txtSearchFromDate").show();
            $("#txtSearchToDate").show();
            $("#lblresultpage").show();
            $("#txtpageno").show();
            $("#btnreset").show();
            $("#btnsearch").show();
            $("#divtopheader").show();





        }


        //start:Bill print preview
        function billPrintPreview(outstandbill, billno) {

            $.cookie('print_outstandbill', outstandbill, {
                expires: 365,
                path: '/'
            });
            $.cookie('billno', billno, {
                expires: 365,
                path: '/'
            });
            //var win = window.open("../billreceipt.html", '_blank');
            // win.focus();
            // location.href = "billreceipt.aspx";
            var windowSizeArray = ["width=200,height=200",
                                            "width=850,height=600,scrollbars=yes"];
            var url = "billhistory.aspx"; //$(this).attr("href");
            var windowName = "popupMemberWindow";//$(this).attr("name");
            var windowSize = windowSizeArray[1];

            var win = window.open(url, windowName, windowSize);
            win.focus();
            event.preventDefault();
            return false;
        }
        //end 



    </script>
</head>
<body class="nav-md">
    <div class="container body">
      <div class="main_container">
        <div class="col-md-3 left_col">
          <div class="left_col scroll-view">
            <div class="navbar nav_title" style="border: 0;">
              <a href="../index.html" class="site_title"><!--<i class="fa fa-paw"></i> --><span>Invoice Me</span></a>
            </div>

            <div class="clearfix"></div>

            <!-- menu profile quick info -->
            <div class="profile clearfix">
              <div class="profile_pic">
                <img src="../images/img.jpg" alt="..." class="img-circle profile_img">
              </div>
              <div class="profile_info">
                <span>Welcome,</span>
                <h2>John Doe</h2>
              </div>
            </div>
            <!-- /menu profile quick info -->

            <br />

            <!-- sidebar menu -->
            <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">
              <div class="menu_section">
                <h3>General</h3>
                <ul class="nav side-menu">
                  <li><a href="../index.html"a><i class="fa fa-home"></i> Home <span class="fa fa-chevron-down"></span></a>
                  </li>
				    <li><a><i class="fa fa-user"></i> Customer <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
					<li><a href="../customer/newcustomer.html">New Customer</a></li>
                      <li><a href="../customer/customers.html"> Customers</a></li>
                      <li><a href="../customer/customerconfirmation.html">Customer Confirmation</a></li>
                      <li><a href="../customer/assigncustomers.html">Assign Customer</a></li>
                    </ul>
                  </li>
				  <li><a><i class="fa fa-shopping-cart"></i> Sales <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="#">New Order</a></li>
                      <li><a href="#">Orders</a></li>
                           <li><a href="#">Edit Order</a></li>
						        <li><a href="#">Confirm Order</a></li>
                    </ul>
                  </li>
				  		  <li><a><i class="fa fa-cubes"></i> Inventory <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="warehouse.html">Warehouses</a></li>
                      <li><a href="itemmaster.html">Item Master</a></li>
                           <li><a href="stockmanagement.html">Stock Management</a></li>
						        <li><a href="salescommission.html">Sales Commission</a></li>
								     <li><a href="offermaster.html">Offer</a></li>
                           <li><a href="itembrand.html">Item Brand</a></li>
						        <li><a href="itemcategory.html">Item Category</a></li>
								    <li><a href="managevendor.html">Manage Vendor</a></li>
						        <li><a href="#">Purchase Entry</a></li>
								
                    </ul>
                  </li>
				  		  <li><a><i class="fa fa-wrench"></i> OP Center <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="../opcenter/manageuser.html">Manage User</a></li>
                      <li><a href="#">Manage Role</a></li>
                           <li><a href="#">Track Users</a></li>
                    </ul>
                  </li>
				  <li><a><i class="fa fa-gears"></i> Settings <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="#">Settings</a></li>
                      <li><a href="#">Export to Tally</a></li>
                    </ul>
                  </li>
				   <li><a><i class="fa fa-file-text-o"></i>Reports<span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="#">Sales Reports</a></li>
                      <li><a href="#">Sales Reports Advanced</a></li>
					   <li><a href="#">Sales Return Reports</a></li>
                      <li><a href="#">Item Report</a></li>
					   <li><a href="#">Graphical Item Report</a></li>
                      <li><a href="#">Purchase Report</a></li>
					    <li><a href="#">Purchase Report Advance</a></li>
                    </ul>
                  </li>
                </ul>
              </div>
              

            </div>
            <!-- /sidebar menu -->

            <!-- /menu footer buttons -->
            <div class="sidebar-footer hidden-small">
              <a data-toggle="tooltip" data-placement="top" title="Settings">
                <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="FullScreen">
                <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="Lock">
                <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
              </a>
              <a data-toggle="tooltip" data-placement="top" title="Logout" href="../login.html">
                <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
              </a>
            </div>
            <!-- /menu footer buttons -->
          </div>
        </div>

        <!-- top navigation -->
                <div class="top_nav">
                    <div class="nav_menu">
                        <nav>

                            <div class="navbar-header" style="width: 100%; display: flex; align-items: center">
                                <div class="nav toggle" style="padding: 5px;">
                                    <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                                </div>
                                <label style="font-weight: bold; font-size: 16px;">Sales Return Report</label>

                            </div>

                        </nav>
                    </div>
                </div>
        
        <!-- /top navigation -->
          <!-- page content -->
 <div id="divReportContent">

        <div class="right_col" role="main" ">
          <div class="">
            <div class="page-title">
              <%--<div class="title_left">
                <h3>Sales Return Report</h3>
              </div>--%>  
            </div>

            <div class="clearfix"></div>

            <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
                <div class="x_panel" style="padding-left:5px;padding-right:5px;">
                  <div class="x_title" id="divtopheader" style="margin-bottom:2px; padding:0px 0px;">
                      <label>Filter</label>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                    
                      <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                    </ul>

                      
                      <div class="clearfix"></div>
                  </div>
                  <div class="x_content">

                    <section class="content invoice">
                      <!-- title row -->
             <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback" style="padding-left:0px; padding-right:0px;">
                      
                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwBranch">
                           <div id="showBranchesDiv">
							<select id="comboBranchesInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option>--Warehouse--</option>
											<option>Abu Dhabi</option>
											<option>Ajman</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
							  </div>
                           <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwCustmr" >
                           <div id="showcustomersInReport">
							<select id="comboCustomersInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option>--Customer--</option>
											<option>Abu Dhabi</option>
											<option>Ajman</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
							  </div>
                           <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshowSles">
                           <div id="showsalesmansInReport">
							<select id="comboSalesInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option>--Sales Person--</option>
											<option>Abu Dhabi</option>
											<option>Ajman</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
							  </div>
                 
                      <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divtodate">
                        <input type="text" placeholder="From Date" id="txtSearchFromDate" style="padding-right:5px;" class="form-control has-feedback-left"/>
                           <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                        </div>
                      <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                              <input type="text" placeholder="To Date" id="txtSearchToDate" style="padding-right:5px;" class="form-control has-feedback-left"/>
                                             <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                        </div>
                 <div class="col-md-4 col-sm-6 col-xs-12 form-group" id="divRetrntype">
                              <div>
                              <select id="comboRtntype" class="form-control" style="text-indent:25px;" onchange="javascript:showDailyReports(1);">                               
                                                                <option value='-1' selected>--Select Return Type--</option>
                                                                <option value='0' selected>Damage</option>
                                                                <option value='1' selected>Convert To bulk</option>
                                                                <option value='2' selected>Ready To Use</option>

                                                         </select> </div>
                     <span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
                               </div>
                          <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                <button id="btnreset" style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:showDailyReport();">
						<li style="margin-right:5px;" class="fa fa-refresh"></li>Reset 
					</button>
                 
                           <button id="btnsearch" style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showDailyReports(1);">
						<li style="margin-right:5px;" class="fa fa-search"></li>Search 
					</button>
                        
                           </div>
                          </div>
                        <div class="clearfix"></div>
                      <!-- info row -->
                      <div class="row invoice-info" style="background:#f1eded; padding-top:15px;">  
                          <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                           <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">Branch :</label>
                               <label style="font-weight:normal;" id="lblReportBranchName">Abu Dhabi</label>  
                               </div> 
                                 
                          <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">From :</label>
                               <label style="font-weight:normal;" id="lblReportFromDate">29-03-2016</label>  
                               </div>  
                              <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">To :</label>
                               <label style="font-weight:normal;" id="lblReportToDate">29-03-2017</label>  
                               </div>    
                              </div>               
                        <div class="col-sm-6 invoice-col">
                            <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="padding-left:0px; padding-right:0px;">
                            <div class="col-md-7 col-sm-6 col-xs-7 form-group" style="">
                          <label id="lblresultpage" style="font-weight:bold; font-size:11px;">Per Page</label>
                                </div>
                            <div class="col-md-5 col-sm-6 col-xs-3 form-group" style="padding-left:0px;">
                               <select class="input-sm" style="text-indent:0; padding:3px; height:25px;" id="txtpageno" onchange="javascript:showDailyReports(1);">
                                   <option value="25">25</option>
                                   <option value="50">50</option>
                                   <option value="100">100</option>
                                   <option value="1000">1000</option>
                               </select> 
                                </div>
                                </div>
                             <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="">
                          <label style="font-weight:bold; font-size:11px;">Total Records:</label>
                                 <label id="lblTotalRecords">1</label>
                                 </div>
                            <div id="tdDownloadBtn" class="col-md-4 col-sm-6 col-xs-7 form-group" style=""  onclick="javascript:DownloadDailyReports();">
                                <label class="fa fa-download" style="font-size:20px; color:red; cursor:pointer;"></label>
                           <label style="font-weight:bold; font-size:11px; line-height:2;"> Download Report</label>
                                </div>
                             <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="" onclick="javascript:printMainReport();">
                                <label class="fa fa-print" style="font-size:20px; color:blue; cursor:pointer;"></label>
                           <label style="font-weight:bold; font-size:11px;"> print</label>
                                </div>
                        </div>
                        <!-- /.col -->
                      </div>
                      <!-- /.row -->
                        </section>

                      <!-- Table row -->
                        <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                      <div class="row" style="padding-left:0px; padding-right:0px;">
                        <div class="col-xs-12 table" style="padding-left:0px; padding-right:0px;">
                          <table class="table table-striped"  style="table-layout:auto;" id="tblReportsContent">
                            <thead>
                              <tr>
                                <th>Order No</th>
                                <th>Ref No</th>
                                <th>Date</th>
                                
                                <th>Cust.ID</th>
                                <th>Cust.Name</th>
                                <th>Total Amt.</th>
                                  <th>Status</th>
                                  
                              </tr>
                            </thead>
                            <tbody>
                              <%--<tr>
                                <td>1</td>
                                <td>Call of Duty</td>
                                <td>25-5-2016</td>
                               
                                <td>145782</td>
                                <td>Ajman & Al Manama Supermarket</td>
                                  <td>452</td>
                                  
                              </tr>--%>
                               <%-- <tr>
                                    <td colspan="6" class="tableborder">Returned By:Abanjana R<br />
<b style="font-size:11px;">Items:1). AMBER RICE DAILY / BASMATI - 38KG   ( (1 * 108)-0=108)     2). AMBER FLOURS VERMICELLI - 450GM   ( (1 * 3)-0=3)</b>    </td>
                                </tr>
                                <tr>
                                <td>2</td>
                                <td>Call of Duty</td>
                                <td>25-5-2016</td>
                                
                                <td>145782</td>
                                <td>Ajman & Al Manama Supermarket</td>
                                  <td>452</td>
                                  
                              </tr>--%>
                                 <%--<tr>
                                    <td colspan="6" class="tableborder">Returned By:Abanjana R<br />
<b style="font-size:11px;">Items:1). AMBER RICE DAILY / BASMATI - 38KG   ( (1 * 108)-0=108)     2). AMBER FLOURS VERMICELLI - 450GM   ( (1 * 3)-0=3)</b>    </td>
                                </tr>
                                <tr>
                                <td>3</td>
                                <td>Call of Duty</td>
                                <td>25-5-2016</td>                                
                                <td>145782</td>
                                <td>Ajman & Al Manama Supermarket</td>
                                  <td>452</td>                                
                              </tr>--%>
                                <%--<tr>
                                <td>4</td>
                                <td>Call of Duty</td>
                                <td>25-5-2016</td>                              
                                <td>145782</td>
                                <td>Ajman & Al Manama Supermarket</td>
                                  <td>452</td>
                                  
                              </tr>--%>
                            </tbody>
                          </table>
                        </div>
</div>
                        <!-- /.col -->
                      </div>
                            </div>
                      <!-- /.row -->


                    </section>
                  </div>
                </div>
              </div>
            </div>

              <div class="clearfix"></div>

            <div class="row" id="divsumry">
              <div class="col-md-12 col-sm-12 col-xs-12">
                <div class="x_panel" style="padding-left:5px;padding-right:5px;">
                  <div style="margin-bottom:0px; padding-bottom:0px;" class="x_title">
                    <label class="pull-left">Summary Report</label>
                      
                    <ul class="nav navbar-right panel_toolbox pull-right">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                    
                      <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                    </ul>
                  
                    <div class="clearfix"></div>
                  </div>
                  <div class="x_content">

                    <section class="content invoice">
                      <!-- title row -->
                      <div class="row" >
                        
                        <!-- /.col -->
                      </div>
                      <!-- info row -->
                      <div class="row invoice-info" style="background:#f1eded; padding-top:15px;">  
                          <div class="col-md-8 col-sm-6 col-xs-12 form-group">
                           <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">Branch :</label>
                               <label style="font-weight:normal;" id="lblSummaryBranchName">Abu Dhabi</label>  
                               </div> 
                          <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">From :</label>
                               <label style="font-weight:normal;" id="lblSummaryFromDate">29-03-2016</label>  
                               </div>  
                              <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">To :</label>
                               <label style="font-weight:normal;" id="lblSummaryToDate">29-03-2017</label>  
                               </div>    
                              </div>               
                        
                        <!-- /.col -->
                      </div>
                      <!-- /.row -->

                      <!-- Table row -->
          

                      <div class="row" id="divSummryall">
                  
                        <!-- /.col -->
                        <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top:10px;">
                       <label style="font-weight:bold; font-size:13px;"> Sales Return Summary ( Total Records:<label id="lblcountSales"></label>)</label>
                          <div class="table-responsive" style="font-weight:bold;" id="SummaryReportDiv">
                            <table class="table">
                              <tbody>
                                <%--<tr>
                                  <th>Net Amount</th>
                                  <td>1539 AED</td>
                                </tr> --%>             
                                  <tr><td colspan="2"></td></tr>
                              </tbody>
                            </table>
                          </div>
                        </div>
                        <!-- /.col -->
                             <!-- /.col -->
                          <div class="clearfix"></div>
                        
                        <!-- /.col -->
                      </div>
                      <!-- /.row -->

                      <!-- this row will not appear when printing -->
                      <%--<div class="row no-print">
                        <div class="col-xs-12">
                          <button class="btn btn-default" onClick="window.print();"><i class="fa fa-print"></i> Print</button>
                          <button class="btn btn-success pull-right"><i class="fa fa-credit-card"></i> Submit Payment</button>
                          <button class="btn btn-primary pull-right" style="margin-right: 5px;"><i class="fa fa-download"></i> Generate PDF</button>
                        </div>
                      </div>--%>
                    </section>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- /page content -->
     
        </div>
 <!<!-- footer content -->
            <footer>
                <div class="pull-right">
                      <div class="footerDiv">
                        <div class="footerDivContent">
                            Copyright 2017 ©
                        </div>
                    </div>
                </div>
                <div class="clearfix"></div>
            </footer>
            <!-- /footer content -->
      </div>
    </div>
    
    <!-- jQuery -->
    <%--<script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
     <!-- Alert Scripts -->
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
