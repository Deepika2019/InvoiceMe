﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="salesreports.aspx.cs" Inherits="reports_salesreports" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
    <title>Sales Reports | Invoice Me</title>

<script type="text/javascript" src="../js/common.js"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script> 
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
    <script type="text/javascript" src="../js/pagination.js"></script>
    <style type="text/css">
        @media print {
            a[href]:after {
           content: none !important;
            }
           }
    </style>
    

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
            // alert("");
           // showProfileHeader(1);
            showBranches();

            // userButtonRoles();
            ShowUTCDate();
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
        });

        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtSearchFromDate").val(localdate);
            $("#txtSearchToDate").val(localdate);
            return;
        }

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }//end date picker

        //start: show warehouse in Reports page
        function showBranches() {
            var loggedInBranch = $.cookie("invntrystaffBranchId");
            var userid = $.cookie("invntrystaffId");
            loading();
            $.ajax({
                type: "POST",
                url: "salesreports.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    console.log(htm);
                    $("#comboBranchesInReport").html(htm);
                    $("#comboBranchesInReport").val(loggedInBranch);
                    showDailyReports(1);
                   // ShowItemBrands();
                   

                },
                error: function (xhr, status) {
                    
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //stop: show warehouse in reports page

        function showDailyReport() {
            ShowUTCDate();

            
            $("#lblSummaryBranchName").text('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#comboCustomersInReport").val(0);
            $("#comboSalesInReport").val(0);
            $("#lblcountCollection").text('');
            $("#lblcountSales").text('');
            $("#lblReportBranchName").text('');

            var brnchid = $.cookie("invntrystaffBranchId");
            $("#comboBranchesInReport").val(brnchid);
            
            
            


            showDailyReports(1);
        }




        //Start:Show Daily Reports List
        function showDailyReports(page) {

            //alert("Ok");
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
                query = query + " and (DATE_FORMAT(sm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(sm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {
                //query = query + " and (CONVERT(VARCHAR(10), BillDate, 111)  = *" + fromdate + "*)";
                query = query + " and (DATE_FORMAT(sm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboBranchesInReport").val();
            var BranchName = $("#comboBranchesInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
            }




            var searchResult = query.substring(4);


            if (query == "") {
                searchResult = "WHERE sm_delivery_status IN(0,1,2) ";
            }
            else {
                searchResult = "WHERE " + searchResult + " and sm_delivery_status IN(0,1,2) ";

            }

            loading();

            //   alert(searchResult);
            //  alert("{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}");
            $.ajax({
                type: "POST",
                url: "salesreports.aspx/showDailyReports",
                data: "{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblTotalRecords").text(0);
                        $('#tblsalesreports  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");

                       // alert("Not Found..!");
                        // $('#tblsalesreports  tbody').html('');
                        $("#lblSummaryBranchName").text('');
                        $("#SummaryReportDiv").html('');

                        $("#divSummryall").hide();
                        $("#divsumry").hide();

                        $("#lblcountCollection").text('');
                        $("#lblcountSales").text('');
                        $("#lblSummaryFromDate").text('');
                        $("#lblSummaryToDate").text('');
                        $("#divsalesSummary").html('');
                        $("#lblReportBranchName").text('');
                        
                        $("#paginatediv").html('');
                        return false;
                    }
                    else {

                        var obj = JSON.parse(msg.d);
                       // alert(msg.d);
                        var htm = "";
                        var html = "";
                        var htmls = "";
                        var a;

                        var checkorderId = 0;
                        $.each(obj.data, function (i, row) {
                            if (checkorderId != row.sm_id) {
                                var paymentmode = "";
                                var cnt = obj.count;
                                $("#lblcountCollection").text(cnt);
                                $("#lblcountSales").text(cnt);
                                if (row.sm_invoice_no != "" && row.sm_invoice_no !== null) {
                                    htm += "<tr><td class=''><a href='/sales/manageorders.aspx?orderId=" + row.sm_refno + "' style='text-decoration:none; color:#056dba;' target='_blank'> #" + row.sm_invoice_no + "(" + row.sm_id + ")</a></td>";
                                } else {
                                    htm += "<tr><td class=''><a href='/sales/manageorders.aspx?orderId=" + row.sm_refno + "' style='text-decoration:none; color:#056dba;' target='_blank'>(" + row.sm_id + ")</a></td>";
                                }
                                htm += "<td>" + row.sm_refno + "</td>";

                                htm += "<td>" + row.BillDate + "</td>";

                                if (row.sm_cash_amt > 0) {

                                    paymentmode = paymentmode + ", Cash";
                                    // alert(paymentmode);
                                }
                                if (row.sm_card_amt > 0) {
                                    paymentmode = paymentmode + ", Card";
                                }
                                if (row.sm_chq_amt > 0) {
                                    paymentmode = paymentmode + ", Cheque";
                                }
                                if (paymentmode != "") {
                                    paymentmode = paymentmode.substr(1);
                                }
                                // alert(paymentmode);
                                htm += "<td>" + paymentmode + "</td>";
                                htm += "<td><a href='../managecustomers.aspx?cusId=" + row.cust_id + "'style='text-decoration:none; color:#056dba;' target='_blank'>" + row.cust_id + "</a></td>";
                                htm += "<td>" + row.cust_name + "</td>";
                                if (row.sm_refno != row.sm_id) {
                                    htm += "<td colspan='4' style='text-align:center;color:#056dba;'>Outstanding Bill</td>";
                                    htm += "<td>" + row.sm_paid + "</td><td>" + row.sm_balance + "</td></tr>";
                                    return;
                                }
                                else {
                                    htm += "<td>" + row.sm_total + "</td><td>" + row.sm_discount_rate + "</td><td>" + row.sm_discount_amount + "</td><td>" + row.sm_netamount + "</td>";
                                }
                                htm += "<td>" + row.sm_paid + "</td><td>" + row.sm_balance + "</td></tr>";
                                // htm += "<tr><td>Sold By:" + row.first_name + "&nbsp"+row.last_name+"</td></tr>"
                                htm += "<tr><td class='' >Items:</td>";
                                htm += "<td colspan='12'>";
                                a = 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += "( (" + row.si_qty + " * " + row.si_price + ")-";
                                htm += "" + row.si_discount_amount + "=" + row.si_net_amount + ")";
                                //  htm += "</td>";
                            }
                            else {
                                //  
                                //listing items
                                //  var a = 1;
                                a = a + 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.si_qty + " * " + row.si_price + ")-";
                                htm += "" + row.si_discount_amount + "=" + row.si_net_amount + ") &nbsp &nbsp ";


                            }

                            checkorderId = row.sm_id;

                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });
                        htm += "</table>";
                        html += "<table class='table'>";
                        html += "<tr><th>Cash</th><td>" + obj.totalcashamt + " " + obj.currency + "</td></tr>";
                        html += "<tr> <th>Card</th><td>" + obj.totalcardamt + " " + obj.currency + "</td> </tr>";
                        html += "<tr><th class=''>Cheque</th> <td class='' >" + obj.totalcheqamt + " " + obj.currency + "</td> </tr>";
                        html += "<tr><th class=''>Wallet</th><td class=''>" + obj.totalwalletamt + " " + obj.currency + "</td> </tr>";
                        html += "<tr> <th>Total Netamount</th><td>" + obj.totalnetamt + " " + obj.currency + "</td> </tr>";
                        html += "<tr><th>Total Paid</th><td>" + obj.totalpaid + " " + obj.currency + "</td> </tr>";
                        html += "<tr><th>Total Balance</th><td>" + obj.totalbalance + " " + obj.currency + "</td> </tr>";
                        html += "<tr> <th>Outstanding Received</th><td>" + obj.totaloutstand_paid + " " + obj.currency + "</td> </tr>";
                        html += "</table>";


                        //htmls += "<table class='table'>";
                        //htmls += "<tr><th>Gross Amount</th><td>" + obj.totalnetamt + " " + obj.currency + "</td> </tr>";
                        //htmls += "<tr><th>Outstanding Amount</th><td>" + obj.totaloutstand + " " + obj.currency + "</td> </tr>";
                        //htmls += "<tr><th>Net Amount</th><td>" + obj.totalsales + " " + obj.currency + "</td> </tr>";
                        //htmls += "<tr><td colspan='2'></td></tr>";
                        //htmls += "</table>";




                        //alert(html);
                        $('#tblsalesreports tbody').html(htm);
                        $("#divSummryall").show();
                        $("#divsumry").show();
                        $("#SummaryReportDiv").html(html);
                       // $("#divsalesSummary").html(htmls);
                        //  $("#paginatediv").show();
                        var BranchName = $("#comboBranchesInReport option:selected").text();
                        //alert(BranchName);
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
                        // alert(page);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "showDailyReports"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

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
                query = query + " and (DATE_FORMAT(sm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(sm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {
                //query = query + " and (CONVERT(VARCHAR(10), BillDate, 111)  = *" + fromdate + "*)";
                query = query + " and (DATE_FORMAT(sm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboBranchesInReport").val();
            var BranchName = $("#comboBranchesInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
            }




            var searchResult = query.substring(4);


            if (query == "") {
                searchResult = "WHERE sm_delivery_status IN(0,1,2) ";
            }
            else {
                searchResult = "WHERE " + searchResult + " and sm_delivery_status IN(0,1,2) ";

            }

            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "salesreports.aspx/DownloadDailyReports",
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
                        location.href = "downloadreport.aspx";
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
              var searchtype = "";

            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();

            $("#tdSearchReportBtn").hide();
            $("#tdSelectBranch").hide();
            $("#divTophead").hide();
            $("#spanpageno").hide();
            $("#divfrmdte").hide();
            $("#divtodate").hide();
            $("#divshwBranch").hide();

            $("#lbPrintReportType").html(searchtype);

            $("#divBtnSechReset").hide();

            $("#tdPrintReportType").show();
            $("#lbResultperpage").show();
            $("#divReportContent").print();



            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
            $("#divfrmdte").show();
            $("#divtodate").show();
            $("#divshwBranch").show();

            $("#tdSearchReportBtn").show();
            $("#tdSelectBranch").show();
            $("#divTophead").show();
            $("#lbResultperpage").hide();
            $("#spanpageno").show();
            $("#divBtnSechReset").show();
            $("#tdPrintReportType").hide();


        }


        //start:Bill print preview
        function billPrintPreview(outstandbill, orderId) {

            $.cookie('print_outstandbill', outstandbill, {
                expires: 365,
                path: '/'
            });
            $.cookie('invntrybillno', orderId, {
                expires: 365,
                path: '/'
            });
            //var win = window.open("../billreceipt.html", '_blank');
            // win.focus();
            // location.href = "billreceipt.aspx";
            var windowSizeArray = ["width=200,height=200",
                                            "width=850,height=600,scrollbars=yes"];
            var url = "/sales/billreceipt.aspx"; //$(this).attr("href");
            var windowName = "popupMemberWindow";//$(this).attr("name");
            var windowSize = windowSizeArray[1];

            var win = window.open(url, windowName, windowSize);
            win.focus();
            event.preventDefault();
            return false;
        }


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
                                <label style="font-weight: bold; font-size: 16px;">Sales Report</label>

                            </div>

                        </nav>
                    </div>
                </div>
        
        <!-- /top navigation -->
          <!-- page content -->

 <div id="divReportContent">

        <div class="right_col" role="main" id="">
          <div class="">
            <div class="page-title">
            <%--  <div class="title_left">
                <label style="font-size:18px; font-weight:normal;">Sales Report</label>
              </div>--%>  
            </div>

            <div class="clearfix"></div>

            <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
                <div class="x_panel" style="padding-left:5px; padding-right:5px;">
                  <div class="x_title" style="margin-bottom:2px; padding:0px 0px 0px;">
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
                        <div class="col-md-10 col-sm-6 col-xs-12 form-group has-feedback" id="divTophead" style="padding-left:0px; padding-right:0px;">
                      <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback"  id="divshwBranch" >
                           <div id="showBranchesDiv">
							<select id="comboBranchesInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
										
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
							  </div>
                      <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                        <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left"/>
                           <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                        </div>
                      <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divtodate">
                              <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left"/>
                                             <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                        </div>
                          </div>
                      <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divBtnSechReset">
                                <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:showDailyReport();">
						<li style="margin-right:5px;" class="fa fa-refresh"></li>Reset 
					</button>
                 
                           <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-success pull-right" type="button"  onclick="javascript:showDailyReports(1);">
						<li style="margin-right:5px;" class="fa fa-search"></li>Search 
					</button>
                        
                           </div>
                          <div class="clearfix"></div>
                      <!-- info row -->
                      <div class="row invoice-info" style="background:#f1eded; padding-top:15px; margin-top:8px;">  
                          <div class="col-md-5 col-sm-6 col-xs-12 form-group">
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
                        <div class="col-sm-7 invoice-col">
                            <div class="col-md-4 col-sm-6 col-xs-6 form-group" id="divresultpage" style="padding-left:0px; padding-right:0px;">
                            <div class="col-md-4 col-sm-6 col-xs-7 form-group" style="">
                          <label style="font-weight:bold; font-size:11px;">Per Page</label>
                                </div>
                            <div class="col-md-5 col-sm-6 col-xs-3 form-group" style="padding-left:0px;">
                               <select class="" style="text-indent:0; padding:0px; height:20px;" id="txtpageno" onchange="javascript:showDailyReports(1);">
                                   <option value="25">25</option>
                                   <option value="50">50</option>
                                   <option value="100">100</option>
                                   <option value="500">500</option>
                               </select> 
                                </div>
                                </div>
                             <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="padding-right:2px;">
                          <label style="font-weight:bold; font-size:11px;">Total Records:</label>
                                 <label id="lblTotalRecords"></label>
                                 </div>
                            <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" style="padding-right:2px;" onclick="javascript:DownloadDailyReports();">
                                <label class="fa fa-download" style="font-size:20px; color:red; cursor:pointer;"></label>
                           <label style="font-weight:bold; font-size:11px; cursor:pointer;"> Download Report</label>
                                </div>
                             <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="padding-right:2px;"  onclick="javascript:printMainReport();">
                                <label class="fa fa-print" style="font-size:20px; color:blue; cursor:pointer;"></label>
                           <label style="font-weight:bold; font-size:11px;" onclick="javascript:printMainReport();"> Print</label>
                                </div>
                        </div>
                        <!-- /.col -->
                      </div>
                      <!-- /.row -->

                      <!-- Table row -->
                        <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto; padding-left:0px; padding-right:0px;">
                      <div class="x_content" style="padding-left:0px; padding-right:0px;">
                      
                          <table class="table table-striped"  style="table-layout:auto;" id="tblsalesreports">
                            <thead>
                              <tr>
                                <th>Order No</th>
                                <th>Ref No</th>
                                <th>Date</th>
                                <th>Mode</th>
                                <th>Cust.ID</th>
                                <th>Cust.Name</th>
                                <th>Total Amt.</th>
                                  <th>Dis%</th>
                                  <th>Dis.Amt </th>
                                  <th>Net.Amt</th>
                                  <th>Paid</th>
                                  <th>Balance</th>
                              </tr>
                            </thead>
                            <tbody>
                             
                               
                            </tbody>
                          </table>
                       
                          <div id="paginatediv" style="text-align: center;"></div>
                        </div>
                        <!-- /.col -->
                    
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
                  <div style="margin-bottom:0px;" class="x_title">
                    <label>Summary Report</label>
                      
                    <ul class="nav navbar-right panel_toolbox pull-right">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                    
                     <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                    </ul>
                  </div>
                  <div class="x_content">

                    <section class="content invoice">
                      <!-- title row -->
                
                      <!-- info row -->
                      <div class="row invoice-info" style="background:#f1eded; padding-top:15px;">  
                          <div class="col-md-5 col-sm-6 col-xs-12 form-group">
                           <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">Branch :</label>
                               <label style="font-weight:normal;" id="lblSummaryBranchName">Abu Dhabi</label>  
                               </div> 
                          <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                               <label style="font-weight:bold;">From :</label>
                               <label style="font-weight:normal;" id="lblSummaryFromDate">29-03-2016</label>  
                               </div>  
                              <div class="col-md-4 col-sm-6 col-xs-12 form-group">
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
                       <label style="font-weight:bold; font-size:13px;"> Collection Summary (Total Records:<label id="lblcountCollection"></label>) </label>
                          <div class="table-responsive" style="font-weight:bold;" id="SummaryReportDiv">
                            <table class="table">
                              <tbody>
                                
                                  <tr><td colspan="2"></td></tr>
                              </tbody>
                            </table>
                          </div>
                        </div>
                        <!-- /.col -->
                             <!-- /.col -->
                          <div class="clearfix"></div>
                        <%--<div class="col-md-12 col-sm-12 col-xs-12" style="margin-top:10px;">
                       <label style="font-weight:bold; font-size:13px;"> Sales Summary (Total Records: <label id="lblcountSales"></label>) </label>
                          <div class="table-responsive" style="font-weight:bold;" id="divsalesSummary">
                            <table class="table">
                              <tbody>
                          
                              </tbody>
                            </table>
                          </div>
                        </div>--%>
                        <!-- /.col -->
                      </div>
                     
                    </section>
                  </div>
                </div>
              </div>
            </div>


            </div>
          </div>
        </div>
        <!-- /page content -->
     </div>
<!-- footer content -->
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
