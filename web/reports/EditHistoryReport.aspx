<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EditHistoryReport.aspx.cs" Inherits="reports_EditHistoryReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Edit History Report | Invoice Me</title>

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

    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <%-- autosearch --%>
    <script src="../autosearch/jquery-ui.js" type="text/javascript"></script>
    <link href="../autosearch/jquery-ui.css" rel="Stylesheet" type="text/css" />
    <script src="../autosearch/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../autosearch/jquery-1.12.4.js" type="text/css"></script>
    <%-- autosearch --%>
    <script type="text/javascript">

        var BranchId;
        var itemId = 0;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            ShowUTCDate();
            showBranches();
            bindItemAutoComplete();
            
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
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
          
            

            //showDailyReports(1);
        }//end
        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];

        }//end
        //start: show warehouse in Reports page
        function showBranches() {
            var loggedInBranch = $.cookie("invntrystaffBranchId");
            var userid = $.cookie("invntrystaffId");
            loading();
            $.ajax({
                type: "POST",
                url: "EditHistoryReport.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">All Warehouses</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    console.log(htm);
                    $("#comboBranchesInReport").html(htm);
                    $("#comboBranchesInReport").val(loggedInBranch);
                    showUsers();


                },
                error: function (xhr, status) {

                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //stop: show warehouse in reports page

        //start: show warehouse in Reports page
        function showUsers() {
            $.ajax({
                type: "POST",
                url: "EditHistoryReport.aspx/showUsers",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">All Users</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.name + '</option>';
                    });
                    console.log(htm);
                    $("#selUsers").html(htm);
                    resetReport();
                  

                },
                error: function (xhr, status) {

                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //stop: show warehouse in reports page

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

        function resetReport() {
            $("#comboBranchesInReport").val(0);
            $("#selUsers").val(0);
            ShowUTCDate();
            itemId = 0;
            $("#txtNames").val("");
            showEditHistoryReports(1);
        }

        //Start:Show Daily Reports List
        function showEditHistoryReports(page) {
            var filters = {};
            var perpage = $("#txtpageno").val();
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            if ($("#comboBranchesInReport").val() != 0) {
                if ($("#comboBranchesInReport").val() != undefined) {
                    filters.branch = $("#comboBranchesInReport").val();
                } else {
                    filters.branch = branchId;
                }

            }
            if ($("#selUsers").val() != 0 && $("#selUsers").val() != undefined) {
                filters.user = $("#selUsers").val();
            }
            if ($("#txtSearchFromDate").val() != " ") {
                filters.fromDate = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != " ") {
                filters.toDate = $("#txtSearchToDate").val();
            }
            if (itemId != -1 && itemId!=0){
                filters.item = itemId;
            }
            $.ajax({
                type: "POST",
                url: "EditHistoryReport.aspx/showEditHistoryReports",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    // alert(obj.data);
                    if (msg.d == "N" || obj.data == "N") {
                        $("#lblTotalRecords").text(0);
                        $('#tblEditHistoryReport  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");

                        // alert("Not Found..!");
                        // $('#tblEditHistoryReport  tbody').html('');
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


                        // alert(msg.d);
                        var htm = "";
                        var html = "";
                        var htmls = "";
                        var a;

                        var checkorderId = 0;
                        $.each(obj.data, function (i, row) {
                            var cnt = obj.count;
                            $("#lblcountCollection").text(cnt);
                            $("#lblcountSales").text(cnt);

                            htm += "<tr><td class=''>" + row.itm_name + "</td>";
                            htm += "<td>" + row.total_old_qty + "</td>";
                            // alert(paymentmode);
                            htm += "<td>" + row.total_new_qty + "</td>";
                            htm += "<td>" + row.total_change_in_qty + "</td>";
                            var action = "No Change";
                            var color = "green";
                            if (row.edit_action == 2) {
                                action = "Deleted";
                                color = "red";
                            } else if (row.edit_action == 1) {
                                action = "Edited";
                            } else if (row.edit_action == 3) {
                                action = "New Item Added";
                            }
                            htm += "<td style='color:" + color + "'>" + action + "</td>";
                            htm += "<td>" + row.user + "</td>";
                            htm += "<td>" + row.branch_name + "</td>";

                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });


                        $('#tblEditHistoryReport tbody').html(htm);
                        $("#SummaryReportDiv").html(html);

                        var BranchName = $("#comboBranchesInReport option:selected").text();
                        //alert(BranchName);
                        $("#lblReportBranchName").text(BranchName);
                        $("#lblTotalRecords").text(obj.count);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "showEditHistoryReports"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        //Start:Download Daily Reports List
        function DownloadEditReports() {
            var filters = {};
            var perpage = $("#txtpageno").val();
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            if ($("#comboBranchesInReport").val() != 0) {
                if ($("#comboBranchesInReport").val() != undefined) {
                    filters.branch = $("#comboBranchesInReport").val();
                } else {
                    filters.branch = branchId;
                }

            }
            if ($("#selUsers").val() != 0 && $("#selUsers").val() != undefined) {
                filters.user = $("#selUsers").val();
            }
            if ($("#txtSearchFromDate").val() != " ") {
                filters.fromDate = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != " ") {
                filters.toDate = $("#txtSearchToDate").val();
            }
            if (itemId != -1 && itemId != 0) {
                filters.item = itemId;
            }
            $.ajax({
                type: "POST",
                url: "EditHistoryReport.aspx/DownloadEditReports",
                data: "{'filters':" + JSON.stringify(filters) + "}",
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
                        location.href = "downloadEditHistoryReport.aspx";
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

        function bindItemAutoComplete() {
            $("#txtNames").autocomplete({
                source: function (request, response) {
                    var BranchId = $.cookie("invntrystaffBranchId");
                    var TimeZone = $.cookie("invntryTimeZone");

                    var parUrl = "";
                    var parData = "";



                    parUrl = "EditHistoryReport.aspx/GetAutoCompleteData";
                    parData = "{'variable':'" + $("#txtNames").val() + "','BranchId':'" + BranchId + "'}";


                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: parUrl,
                        data: parData,
                        dataType: "json",
                        success: function (data) {
                            console.log(data.d);
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    itemId = ui.item.id;
                    //alert();
                    if (ui.item.id == -1) {
                        $("#txtNames").val("");
                    } else {
                        $("#txtNames").val(ui.item.label); //ui.item is your object from the array
                        //searchItems();
                    }
                    // Prevent value from being put in the input:

                    event.preventDefault();
                },
                minLength: 1

            });

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
                            <label style="font-weight: bold; font-size: 16px;">Edit History Report</label>

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
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title" style="margin-bottom: 2px; padding: 0px 0px 0px;">
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
                                            <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback" id="divTophead" style="padding-left: 0px; padding-right: 0px;">
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="divshwBranch">
                                                    <div id="showBranchesDiv">
                                                        <select id="comboBranchesInReport" style="text-indent: 25px;" class="form-control" onchange="javascript:showEditHistoryReports(1);">
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="div1">
                                                    <div id="Div2">
                                                        <select id="selUsers" style="text-indent: 25px;" class="form-control" onchange="javascript:showEditHistoryReports(1);">
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
                                                </div>

                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" readonly="">
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divtodate">
                                                    <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" readonly="">
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                            </div>
                                            <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback" id="div3" style="padding-left: 0px; padding-right: 0px;">
                                                <div class="col-md-10 col-sm-6 col-xs-12 form-group" id="div4">
                                                    <input type="search" class="form-control" placeholder="Search Item" id="txtNames" />

                                                </div>

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divBtnSechReset">
                                                    <button style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:resetReport();">
                                                        <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                        Reset 
                                                    </button>

                                                    <button style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showEditHistoryReports(1);">
                                                        <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                        Search 
                                                    </button>

                                                </div>
                                            </div>
                                            <div class="clearfix"></div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px; margin-top: 8px;">
                                                <div class="col-md-5 col-sm-6 col-xs-12 form-group">
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">Branch :</label>
                                                        <label style="font-weight: normal;" id="lblReportBranchName">Abu Dhabi</label>
                                                    </div>

                                                </div>
                                                <div class="col-sm-7 invoice-col">
                                                    <div class="col-md-4 col-sm-6 col-xs-6 form-group" id="divresultpage" style="padding-left: 0px; padding-right: 0px;">
                                                        <div class="col-md-4 col-sm-6 col-xs-7 form-group" style="">
                                                            <label style="font-weight: bold; font-size: 11px;">Per Page</label>
                                                        </div>
                                                        <div class="col-md-5 col-sm-6 col-xs-3 form-group" style="padding-left: 0px;">
                                                            <select class="" style="text-indent: 0; padding: 0px; height: 20px;" id="txtpageno" onchange="javascript:showEditHistoryReports(1);">
                                                                <option value="25">25</option>
                                                                <option value="50">50</option>
                                                                <option value="100">100</option>
                                                                <option value="500">500</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="padding-right: 2px;">
                                                        <label style="font-weight: bold; font-size: 11px;">Total Records:</label>
                                                        <label id="lblTotalRecords"></label>
                                                    </div>
                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" style="padding-right: 2px;" onclick="javascript:DownloadEditReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px; cursor: pointer;">Download Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="padding-right: 2px;" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;" onclick="javascript:printMainReport();">Print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">
                                                <div class="x_content" style="padding-left: 0px; padding-right: 0px;">

                                                    <table class="table table-striped" style="table-layout: auto;" id="tblEditHistoryReport">
                                                        <thead>
                                                            <tr>
                                                                <th width="40%">Item</th>
                                                                <th width="20%">Total Old Qty</th>
                                                                <th width="20%">Total New Qty</th>
                                                                <th width="40%">Total Changed Qty </th>
                                                                <th >Action</th>
                                                                <th>User</th>
                                                                <th>Branch</th>
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
