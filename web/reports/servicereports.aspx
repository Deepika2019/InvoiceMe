<%@ Page Language="C#" AutoEventWireup="true" CodeFile="servicereports.aspx.cs" Inherits="reports_servicereports" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Sales Item Report | Invoice Me</title>
    <script type="text/javascript" src="../js/common.js"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
    <script type="text/javascript" src="../js/pagination.js"></script>



    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- iCheck -->
    <link href="../css/bootstrap/green.css" rel="stylesheet" />

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!-- mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />



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
            // showProfileHeader(1);
            ShowUTCDate();

            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");

        });
        //date time start
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
            showBranches();
            return;
        }

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }
        //Start:TO Replace single quotes with double quotes
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
        }
        //Stop:TO Replace single quotes with double quotes

        //start: show warehouse in Reports page

        function showBranches() {
            //  loading();
            var userid = $.cookie("invntrystaffId");
            var branchid = $.cookie("invntrystaffBranchId");
            $.ajax({
                type: "POST",
                url: "servicereports.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //  Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#comboWareHouseInReport").html(htm);
                    $("#comboWareHouseInReport").val(branchid);
                    ShowItemBrands();
                    //  Unloading();

                },
                error: function (xhr, status) {
                    // Unloading(); 
                    alert("Internet Problem..!");
                }
            });
        }//end showing warehouse

        // show brand name in report

        function ShowItemBrands() {
            //loading();
            $.ajax({
                type: "POST",
                url: "servicereports.aspx/ShowItemBrands",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--Brand Name--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.brand_id + '">' + row.brand_name + '</option>';
                    });
                    $("#ComboshoWBrandname").html(htm);
                    ShowItemCategry();
                    //  Unloading();

                },
                error: function (xhr, status) {
                    //  Unloading();
                    alert("Internet Problem..!");
                }
            });

        }// end brandname

        // show category in report

        function ShowItemCategry() {
            // loading();
            $.ajax({
                type: "POST",
                url: "servicereports.aspx/ShowItemCategry",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // Unloading();
                    //alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--Category--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cat_id + '">' + row.cat_name + '</option>';
                    });
                    $("#ComboshowCategory").html(htm);
                    showsalespersons();
                    //  Unloading();

                },
                error: function (xhr, status) {
                    // Unloading();
                    alert("Internet Problem..!");

                }
            });
        }//end category

        //show salespersons
        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "servicereports.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Salesperson--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.first_name + '&nbsp' + row.last_name + '</option>';
                    });
                    $("#comboSalesInReport").html(htm);
                    showServiceReports(1);


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


        //Start:Show Daily Reports List
        function showServiceReports(page) {
            // alert("report");
            var searchtype = "";

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

            var perpage = $("#txtpageno").val();
            var query = "";

            for (var i = 1; i <= 3; i++) {

                var searchContent = $.trim($("#searchContent" + i).val());


                if (i == 2 && searchContent != "") {
                    query = query + " and tbl_sales_items.itm_name LIKE *" + searchContent + "%*";
                }

                if (i == 3 && searchContent != "") {
                    query = query + " and si_price LIKE *" + searchContent + "%*";
                }

            }
            if (fromdate != "" && todate != "" && (fromdate != todate)) {
                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {

                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboWareHouseInReport").val();
            var BranchName = $("#comboWareHouseInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
                query = query + " and (tbl_itembranch_stock.branch_id IN(select branch_id from tbl_user_branches where user_id=*" + $.cookie("invntrystaffId") + "*)) ";
            }
            else {
                //  query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
                query = query + " and (tbl_itembranch_stock.branch_id=*" + BranchId + "*) ";

            }





            var brandId = $("#ComboshoWBrandname").val();
            var brandname = $("#ComboshoWBrandname option[value='" + brandId + "']").text();

            var categoryId = $("#ComboshowCategory").val();
            var categoryname = $("#ComboshowCategory option[value='" + categoryId + "']").text();

            // alert(brandname);
            // alert(categoryname);

            if (brandId == 0) {
            }
            else {
                query = query + " and (tbl_itembranch_stock.itm_brand_id=*" + brandId + "*) ";
            }


            if (categoryId == 0) {
            }
            else {
                query = query + " and (tbl_itembranch_stock.itm_category_id=*" + categoryId + "*) ";
            }
            var salesmanId = $("#comboSalesInReport").val();
            //   alert(customerid);
            //     var BranchName = $("#comboCustomersInReport option[value='" + BranchId + "']").text();
            if (salesmanId == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (sm_userid =*" + salesmanId + "*) ";
            }
            var searchResult = query.substring(4);

            if (query == "") {
                searchResult = "";
            }
            else {
                searchResult = " WHERE " + searchResult;
            }

            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "servicereports.aspx/showServiceReports",
                data: "{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','fromdate':'" + fromdate + "','todate':'" + todate + "','brandname':'" + brandname + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //   alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblTotalRecords").text(0);
                        $('#tableShowServiceReports1  tbody').html("<tr class=''><td colspan='6' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");
                        //alert("Not Found..!");

                        $("#divSummryall").hide();
                        $("#divsumry").hide();
                        $("#paginatediv").hide();
                        $("#lblSummaryFromDate").text('');
                        $("#lblSummaryToDate").text('');
                        $("#lblSummaryBranchName").text('');
                        $("#lblReportBranchName").text('');
                        $("#SummaryReportDiv").html('');
                        return false;

                        alert("Not Found..!");
                        return false;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        // console.log(obj);
                        var htm = "";
                        var htmlsum = "";
                        $.each(obj.data, function (i, rows) {
                            var cnt = obj.count;
                            //$("#lblcountCollection").text(cnt);
                            $("#lblcountSales").text(cnt);
                            htm += "<tr>";
                            htm += "<td style='width:300px;'>" + rows.Item_Name + "</td>"
                            htm += "<td>" + rows.Item_Cost + "</td>"
                            htm += "<td>" + rows.Quantity + "</td>"
                            htm += "<td>" + rows.TotalAmount + "</td>"
                            htm += "<td>" + rows.discount + "</td>";
                            htm += "<td>" + rows.Netamount + "</td></tr>"


                        });

                        htmlsum += "<table class='table'>";
                        htmlsum += "<tr><th>Total Net Amount</th> <td>" + obj.totalnetamt + "</td> </tr>";
                        htmlsum += "<tr> <td colspan='2'></td></tr>";
                        // alert(htmlsum);
                        htmlsum += "</table>";

                    }
                    var BranchName = $("#comboWareHouseInReport option:selected").text();
                    $("#lblTotalRecords").text(obj.count);
                    $("#lblReportBranchName").text(BranchName);
                    $("#lblSummaryBranchName").text(BranchName);
                    $('#tableShowServiceReports1  tbody').html(htm);
                    $("#divSummryall").show();
                    $("#divsumry").show();
                    $("#SummaryReportDiv").html(htmlsum);
                    $("#paginatediv").show();
                    $("#divshowSummary").show();
                    if (fromdate != "" && todate != "") {
                        $("#lblReportFromDate").text(fromdate1);
                        $("#lblReportToDate").text(todate1);
                        $("#lblSummaryFromDate").text(fromdate1);
                        $("#lblSummaryToDate").text(todate1);

                    }
                    $("#paginatediv").html(paginate(obj.count, perpage, page, "showServiceReports"));


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


        //start reset/clear
        function showServiceReport() {

            var brnchid = $.cookie("invntrystaffBranchId");
            $("#comboWareHouseInReport").val(brnchid);
            // $("#comboWareHouseInReport").val('0');
            ShowUTCDate();
            $("#lblReportFromDate").text('');
            $("#lblReportBranchName").text('');
            $("#lblReportToDate").text('');

            $("#lblReportBranchName").text('');


            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#lblSummaryBranchName").text('');
            $("#SummaryReportDiv").html('');

            for (var i = 1; i <= 12; i++) {
                $("#searchContent" + i).val('');
            }
            $("#ComboshowCategory").val(0);

            $("#ComboshoWBrandname").val(0);
            $("#SummaryReportDiv").html('');
            $("#lblcountSales").text('');
            $("#comboSalesInReport").val(0);



        }//end

        //Start:Download Daily Reports List
        function DownloadServiceReports() {
            var searchtype = "";

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

            var perpage = $("#txtpageno").val();
            var query = "";

            for (var i = 1; i <= 3; i++) {

                var searchContent = $.trim($("#searchContent" + i).val());


                if (i == 2 && searchContent != "") {
                    query = query + " and tbl_sales_items.itm_name LIKE *" + searchContent + "%*";
                }

                if (i == 3 && searchContent != "") {
                    query = query + " and si_price LIKE *" + searchContent + "%*";
                }

            }
            if (fromdate != "" && todate != "" && (fromdate != todate)) {
                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%Y/%m/%d*) between *" + fromdate + "* and *" + todate + "*) ";

            }

            if (fromdate == "" || todate == "") {
                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%d/%m/%Y*) = DATE_FORMAT(*" + today + "*,*%d/%m/%Y*)) ";
            }
            if ((fromdate == todate) && (fromdate != "" || todate != "")) {

                query = query + " and (DATE_FORMAT(tbl_sales_master.sm_date,*%Y/%m/%d*) = *" + fromdate + "*) ";
            }

            var BranchId = $("#comboWareHouseInReport").val();
            var BranchName = $("#comboWareHouseInReport option[value='" + BranchId + "']").text();
            if (BranchId == 0) {
            }
            else {
                // query = query + " and (tbl_sales_master.branch_id=*" + BranchId + "*) ";
                query = query + " and (tbl_itembranch_stock.branch_id=*" + BranchId + "*) ";
            }


            var brandId = $("#ComboshoWBrandname").val();
            var brandname = $("#ComboshoWBrandname option[value='" + brandId + "']").text();

            var categoryId = $("#ComboshowCategory").val();
            var categoryname = $("#ComboshowCategory option[value='" + categoryId + "']").text();
            if (brandId == 0) {
            }
            else {
                query = query + " and (tbl_itembranch_stock.itm_brand_id=*" + brandId + "*) ";
            }


            if (categoryId == 0) {
            }
            else {
                query = query + " and (tbl_itembranch_stock.itm_category_id=*" + categoryId + "*) ";
            }

            var salesmanId = $("#comboSalesInReport").val();
            //   alert(customerid);
            //     var BranchName = $("#comboCustomersInReport option[value='" + BranchId + "']").text();
            if (salesmanId == 0) {
            }
            else {
                //  query = query + " and BranchId = *" + BranchId + "*";
                query = query + " and (sm_userid =*" + salesmanId + "*) ";
            }

            var searchResult = query.substring(4);

            if (query == "") {
                searchResult = "";
            }
            else {
                searchResult = " WHERE " + searchResult;
            }
            loading();

            //  alert(searchResult);

            $.ajax({
                type: "POST",
                url: "servicereports.aspx/DownloadServiceReports",
                data: "{'searchResult':'" + searchResult + "','fromdate':'" + fromdate1 + "','todate':'" + todate1 + "','branch':'" + BranchName + "'}",
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
                        // location.href = "DownloadItemReport.aspx";
                        location.href = "DownloaditemITReport.aspx"
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }//Stop:Download serviceReports 

        //print report
        function printMainReport() {

            var searchtype = "";

            $("#divtopHead").hide();
            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();
            $("#showBranchesDiv").hide();
            $("#DivshoWBrandname").hide();
            $("#divshowCategory").hide();
            $("#divshwBranch").hide();
            $("#divbrnd").hide();
            $("#divCatgry").hide();
            $("#divfrmdte").hide();
            $("#divtodate").hide();
            $("#divReportContent").print();
            $("#divshwBranch").show();
            $("#divbrnd").show();
            $("#divCatgry").show();
            $("#divfrmdte").show();
            $("#divtodate").show();
            $("#divtopHead").show();
            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
            $("#showBranchesDiv").show();
            $("#DivshoWBrandname").show();
            $("#divshowCategory").show();
        }








    </script>






</head>
<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">
                    <div class="navbar nav_title" style="border: 0;">
                        <a href="../index.html" class="site_title">
                            <!--<i class="fa fa-paw"></i> -->
                            <span>Invoice Me</span></a>
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
                                <li><a href="../index.html" a><i class="fa fa-home"></i>Home <span class="fa fa-chevron-down"></span></a>
                                </li>
                                <li><a><i class="fa fa-user"></i>Customer <span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu">
                                        <li><a href="../customer/newcustomer.html">New Customer</a></li>
                                        <li><a href="../customer/customers.html">Customers</a></li>
                                        <li><a href="../customer/customerconfirmation.html">Customer Confirmation</a></li>
                                        <li><a href="../customer/assigncustomers.html">Assign Customer</a></li>
                                    </ul>
                                </li>
                                <li><a><i class="fa fa-shopping-cart"></i>Sales <span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu">
                                        <li><a href="#">New Order</a></li>
                                        <li><a href="#">Orders</a></li>
                                        <li><a href="#">Edit Order</a></li>
                                        <li><a href="#">Confirm Order</a></li>
                                    </ul>
                                </li>
                                <li><a><i class="fa fa-cubes"></i>Inventory <span class="fa fa-chevron-down"></span></a>
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
                                <li><a><i class="fa fa-wrench"></i>OP Center <span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu">
                                        <li><a href="../opcenter/manageuser.html">Manage User</a></li>
                                        <li><a href="#">Manage Role</a></li>
                                        <li><a href="#">Track Users</a></li>
                                    </ul>
                                </li>
                                <li><a><i class="fa fa-gears"></i>Settings <span class="fa fa-chevron-down"></span></a>
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
                            <label style="font-weight: bold; font-size: 16px;">Sales Item Report</label>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->
            <!-- page content -->
            <div id="divReportContent">
                <div class="right_col" role="main">
                    <div class="">
                        <div class="page-title">
                            <%--<div class="title_left">
                                <h3>Sales Item Report</h3>
                            </div>--%>
                        </div>

                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback">
                                <div class="x_panel" id="divtopHead" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title">
                                        <label>Filter</label>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                        </ul>
                                    </div>
                                    <div class="x_content">
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwBranch">
                                            <div id="showBranchesDiv">
                                                <select id="comboWareHouseInReport" style="text-indent: 25px;" class="form-control" onchange="javascript:showServiceReports(1);">
                                                    <option>--Warehouse--</option>
                                                    <option>Abu Dhabi</option>
                                                    <option>Ajman</option>
                                                </select>
                                            </div>
                                            <span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
                                        </div>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divbrnd">
                                            <div id="DivshoWBrandname">
                                                <select id="ComboshoWBrandname" style="text-indent: 25px;" class="form-control" onchange="javascript:showServiceReports(1);">
                                                    <option>--Brand Name--</option>
                                                    <option>Abu Dhabi</option>
                                                    <option>Ajman</option>
                                                </select>
                                            </div>
                                            <span aria-hidden="true" class="fa fa-briefcase form-control-feedback left"></span>
                                        </div>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divCatgry">
                                            <div id="divshowCategory">
                                                <select id="ComboshowCategory" style="text-indent: 25px;" class="form-control" onchange="javascript:showServiceReports(1);">
                                                    <option>--Category--</option>
                                                    <option>Abu Dhabi</option>
                                                    <option>Ajman</option>
                                                </select>
                                            </div>
                                            <span aria-hidden="true" class="fa fa-clone  form-control-feedback left"></span>
                                        </div>

                                        <%-- start div for salesperson combo --%>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="showsalesmansInReport">
                                            <select id="comboSalesInReport" style="text-indent: 25px;" class="form-control" onchange="javascript:showServiceReports(1);">
                                                <option value="0" selected="selected">-- Select Salesperson--</option>                                              
                                            </select>
                                        </div>
                                        <%-- end div for salesperson combo --%>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                            <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" />
                                            <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                        </div>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group" id="divtodate">
                                            <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" />
                                            <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                        </div>
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                            <div class="col-md-4 col-sm-6 col-xs-5 form-group">
                                                <label id="lblresultpage" style="font-size: 11px;">Result Per Page</label>
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-6 form-group">
                                                <select id="txtpageno" class="" onchange="javascript:showServiceReports(1);">
                                                    <option value="25">25</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                    <option value="1000">1000</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group pull-right">
                                                <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:showServiceReport();">
                                                    <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                    Reset 
                                                </button>

                                                <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showServiceReports(1);">
                                                    <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                    Search 
                                                </button>

                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12 col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title" style="margin-bottom: 2px;">
                                        <label>Details</label>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                        </ul>
                                    </div>
                                    <div class="x_content">

                                        <section class="content invoice">
                                            <!-- title row -->
                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                                <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">Branch :</label>
                                                        <label style="font-weight: normal;" id="lblReportBranchName">Abu Dhabi</label>
                                                    </div>
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">From :</label>
                                                        <label style="font-weight: normal;" id="lblReportFromDate">29-03-2016</label>
                                                    </div>
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblReportToDate">29-03-2017</label>
                                                    </div>
                                                </div>
                                                <div class="col-md-6 col-sm-6 col-xs-12 invoice-col">

                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group" style="padding-right: 2px;">
                                                        <label style="font-weight: bold; font-size: 11px;">Total Records:</label>
                                                        <label id="lblTotalRecords">1</label>
                                                    </div>
                                                    <div id="tdDownloadBtn" class="col-md-4 col-sm-6 col-xs-8 form-group" style="" onclick="javascript:DownloadServiceReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Download Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">

                                                <div class="x_content">

                                                    <table class="table table-striped table-bordered" style="table-layout: auto;" id="tableShowServiceReports1">
                                                        <thead>
                                                            <tr>
                                                                <th>Item Name </th>
                                                                <th>Item Cost 	</th>
                                                                <th>Quantity</th>
                                                                <th>Total Amount </th>
                                                                <th>Total Discount Amount </th>
                                                                <th>Total Net Amount </th>

                                                            </tr>
                                                        </thead>


                                                        <tbody>
                                                            <%--           <tr>
                                                            <td style="width: 300px;">Al Manama Supermarket</td>
                                                            <td>1</td>


                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>--%>
                                                            <%--<tr>
                                                            <td>Nesto Hypermarket</td>
                                                            <td>2</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>--%>
                                                            <%--<tr>
                                                            <td>Fathima Supermarket</td>
                                                            <td>3</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>
                                                        <tr>
                                                            <td>Makkah Supermarket</td>
                                                            <td>4</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>--%>
                                                            <%--<tr>
                                                            <td>Nesto Hypermarket</td>
                                                            <td>5</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>
                                                        <tr>
                                                            <td>Al Manama Supermarket</td>
                                                            <td>6</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>

                                                        </tr>--%>
                                                            <%--<tr>
                                                            <td>Fathima Supermarket</td>
                                                            <td>7</td>
                                                            <td>5</td>
                                                            <td>45</td>
                                                            <td>5</td>
                                                            <td>5</td>
                                                        </tr>--%>
                                                        </tbody>
                                                    </table>


                                                    <div style="text-align: center;" id="paginatediv"></div>



                                                </div>
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
                            <div class="x_panel" id="divshowSummary" style="display: none; padding-left: 5px; padding-right: 5px;">
                                <div style="margin-bottom: 0px;" class="x_title">
                                    <label>Summary Report</label>

                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">

                                    <section class="content invoice">

                                        <!-- info row -->
                                        <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                                                <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                    <label style="font-weight: bold;">Branch :</label>
                                                    <label style="font-weight: normal;" id="lblSummaryBranchName">Abu Dhabi</label>
                                                </div>
                                                <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                    <label style="font-weight: bold;">From :</label>
                                                    <label style="font-weight: normal;" id="lblSummaryFromDate">29-03-2016</label>
                                                </div>
                                                <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                    <label style="font-weight: bold;">To :</label>
                                                    <label style="font-weight: normal;" id="lblSummaryToDate">29-03-2017</label>
                                                </div>
                                            </div>

                                            <!-- /.col -->
                                        </div>
                                        <!-- /.row -->

                                        <!-- Table row -->


                                        <div class="row" id="show">


                                            <!-- /.col -->
                                            <!-- /.col -->
                                            <div class="clearfix"></div>
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top: 10px;">
                                                <label style="font-weight: bold; font-size: 14px;">Sales Summary  ( Total Records:<label id="lblcountSales"></label>) </label>
                                                <div class="table-responsive" style="font-weight: bold;" id="SummaryReportDiv">
                                                    <table class="table">
                                                        <tbody>
                                                            <tr>
                                                                <th>Total Net Amount</th>
                                                                <td>8.00 AED</td>
                                                            </tr>

                                                            <tr>
                                                                <td colspan="2"></td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
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
        </div>
        <!-- /page content -->


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
