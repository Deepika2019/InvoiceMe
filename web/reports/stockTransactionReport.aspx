<%@ Page Language="C#" AutoEventWireup="true" CodeFile="stockTransactionReport.aspx.cs" Inherits="reports_stockTransactionReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Stock Transaction Report | Invoice Me</title>
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
                url: "stockTransactionReport.aspx/showBranches",
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
                    $("#selBranch").html(htm);
                    $("#selBranch").val(branchid);
                    showStockTransactions(1);
                },
                error: function (xhr, status) {
                    // Unloading(); 
                    alert("Internet Problem..!");
                }
            });
        }//end showing warehouse

        function showStockTransactions(page) {
            var postObj = {
                page: page,
                perpage: $("#txtpageno").val(),
                filters: {
                }
            }
            if ($("#selBranch").val() && $("#selBranch").val() != "0" && $("#selBranch").val() != "") {
                postObj.filters.branch_id = $("#selBranch").val();
            }
            if ($("#selActionType").val() && $("#selActionType").val() != "-1" && $("#selActionType").val() != "") {
                postObj.filters.actionType = $("#selActionType").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }
            //if ($("#selActionType").val() && $("#selActionType").val() != "-1" && $("#selActionType").val() != "") {
            //    postObj.filters.action_type = $("#selActionType").val();
            //}
            if ($("#txtSearch").val() != "") {
                postObj.filters.search = $("#txtSearch").val();
            }
            if ($("#txtSearchPartner").val() != "") {
                postObj.filters.partnerSearch = $("#txtSearchPartner").val();
            }
            $.ajax({
                type: "POST",
                url: "stockTransactionReport.aspx/showStockTransactions",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    if (msg.d == "N" || obj.data == "") {
                        $("#lblTotalRecords").text(0);
                        $('#tblStockTransaction  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");
                        $("#paginatediv").html('');
                        return false;
                    }
                    else {
                        $.each(obj.data, function (i, row) {
                            var cnt = obj.count;
                            $("#lblTotalRecords").text(cnt);
                            htm += "<tr><td>" + row.date + "</td>";
                            htm += "<td>#" + getHighlightedValue(postObj.filters.search, row.itm_code) + " " + getHighlightedValue(postObj.filters.search, row.itm_name) + "</a></td>";
                            htm += "<td>" + getHighlightedValue(postObj.filters.search, row.branch_name) + "</td>";
                            htm += "<td>" + getHighlightedValue(postObj.filters.partnerSearch, row.partnerName) + "</td>";
                            // alert(paymentmode);
                            htm += "<td>" + row.ActionType + "</td>";
                            if (row.action_type == 1) {
                                htm += "<td><a href='/sales/manageorders.aspx?orderId=" + row.action_ref_id + "' style='text-decoration:none; color:#056dba;font-weight:bold' target='_blank'>" + "#" + row.action_ref_id + "</a></td>";
                            } else if (row.action_type == 2) {
                                htm += "<td><a href='/purchase/managepurchase.aspx?purchaseId=" + row.action_ref_id + "' style='text-decoration:none; color:#056dba;font-weight:bold' target='_blank'>" + "#" + row.action_ref_id + "</a></td>";
                            } else {
                                htm += "<td style='text-decoration:none; color:#056dba;font-weight:bold'>" + "#" + row.action_ref_id + "</td>";
                            }
                           
                            htm += "<td>" + row.narration + "</td>";
                          
                            htm += "<td>" + row.cr_qty + "</td>";
                            htm += "<td>" + row.dr_qty + "</td>";
                            htm += "<td>" + getHighlightedValue(postObj.filters.search, row.closing_stock) + "</td>";

                            htm += "<td>" + row.user + "</td>";
                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });

                        $('#tblStockTransaction tbody').html(htm);
                        $("#paginatediv").html(paginate(obj.count, $("#txtpageno").val(), page, "showStockTransactions"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

     

        //Start:Download Daily Reports List
        function DownloadstockTransReport() {
            var postObj = {
                filters: {
                }
            }
            if ($("#selBranch").val() && $("#selBranch").val() != "0" && $("#selBranch").val() != "") {
                postObj.filters.branch_id = $("#selBranch").val();
            }
            if ($("#selActionType").val() && $("#selActionType").val() != "-1" && $("#selActionType").val() != "") {
                postObj.filters.actionType = $("#selActionType").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }
            //if ($("#selActionType").val() && $("#selActionType").val() != "-1" && $("#selActionType").val() != "") {
            //    postObj.filters.action_type = $("#selActionType").val();
            //}
            if ($("#txtSearch").val() != "") {
                postObj.filters.search = $.trim($("#txtSearch").val());
            }
            if ($("#txtSearchPartner").val() != "") {
                postObj.filters.partnerSearch = $.trim($("#txtSearchPartner").val());
            }
            $.ajax({
                type: "POST",
                url: "stockTransactionReport.aspx/DownloadstockTransReport",
                data: JSON.stringify(postObj),
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
                        location.href = "DownloadstockTransReport.aspx";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }//Stop:Download stockReport 

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

        function resetFilters() {
            ShowUTCDate();
            $("#txtSearch").val("");
            $("#selBranch").val(0);
            $("#selBranch").val(0);
            $("#txtSearchPartner").val("")
            showStockTransactions(1);
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
                            <label style="font-weight: bold; font-size: 16px;">Stock Transaction Report</label>

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
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Filter</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <form class="form-horizontal form-label-left input_mask">

                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="Search" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                               <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearchPartner" placeholder="Partner Search" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" style="display:;">
                                                <select id="selActionType" class="form-control" style="text-indent: 25px;" onchange="showStockTransactions(1);">
                                                    <option value="-1" selected="selected">--Action Type--</option>
                                                    <option value="1">SALES</option>
                                                    <option value="3">SALES RETURN</option>
                                                    <option value="2">PURCAHSE</option>
                                                    <option value="4"> PURCHASE_RETURN</option>
                                                    <option value="7">STOCK_TRANSFER</option>
                                                    <option value="11">MANUAL_ITEM_EDIT</option>
                                                    

                                                </select>
                                            </div>

                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="selBranch" class="form-control" style="text-indent: 25px;" onchange="showStockTransactions(1);">
                                                </select>
                                            </div>
                                            


                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearchFromDate" placeholder="From Date" />
                                                <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearchToDate" placeholder="To Date" />
                                                <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-12">
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:showStockTransactions(1);">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </div>

                                                <div class="btn btn-primary mybtnstyl" onclick="javascript:resetFilters();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </div>
                                            </div>

                                        </form>
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
                                               
                          
                                             
                                                                      <div class="col-md-6 col-sm-6 col-xs-12 pull-right;" style="float: right;">

                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group pull-right" style="padding-right: 2px;">
                                                        <label style="font-weight: bold; font-size: 11px;">Total Records:</label>
                                                        <label id="lblTotalRecords"></label>
                                                    </div>
                                                    <div id="tdDownloadBtn" class="col-md-2 col-sm-6 col-xs-8 form-group pull-right" style="" onclick="javascript:DownloadstockTransReport();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group pull-right" style="" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                                                   <div class="col-md-2 col-sm-6 col-xs-6 form-group pull-right">
                                                <select id="txtpageno" class="" onchange="javascript:showStockTransactions(1);">
                                                    <option value="25">25</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                    <option value="1000">1000</option>
                                                </select>
                                            </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">

                                                <div class="x_content">

                                                    <table class="table table-striped table-bordered" style="table-layout: auto;" id="tblStockTransaction">
                                                        <thead>
                                                            <tr>
                                                                <th>Date</th>
                                                                <th>Particular</th>
                                                                <th>Branch</th>
                                                                <th>Partner</th>
                                                                <th>Vch Type</th>
                                                                 <th>Vch No</th>
                                                                <th>Narration</th>
                                                                <th>Inwards Qty</th>
                                                                <th>Outwards Qty</th>
                                                               <th>Closing Qty</th>
                                                                <th>User</th>
                                                            </tr>
                                                        </thead>


                                                        <tbody>
                                                            
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
