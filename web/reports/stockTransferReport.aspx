<%@ Page Language="C#" AutoEventWireup="true" CodeFile="stockTransferReport.aspx.cs" Inherits="reports_stockTransferReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Stock Transfer history | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script src="../js/pagination.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />
   
    <script type="text/javascript">

        var BranchId;
        var vendorId = 0;
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

         
            ShowUTCDate();
            // userButtonRoles();
            //    ShowUTCDate();
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
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
            showStockTransferHistory(1);
        }
        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }//end date picker


       
        function resetReport() {
            ShowUTCDate();
            $("#lblReportFromDate").text('');
            $("#lblReportBranchName").text('');
            $("#lblReportToDate").text('');
            showStockTransferHistory(1);
        }

        //Start:Show Daily Reports List
        function showStockTransferHistory(page) {
            //alert(vendorId);
            var filters = {};
            var perpage = $("#txtpageno").val();

            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }

            loading();

            //alert(searchResult);
            // alert("{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}");
            $.ajax({
                type: "POST",
                url: "stockTransferReport.aspx/showStockTransferHistory",
                data: "{'page':'" + page + "','filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    console.log(obj.data);
                    var checkorderId = 0;
                    var slno = 0;
                    var htm = "";
                    if (obj.data == "N") {
                        $("#lblTotalRecords").text(0);
                        $('#tblstockTransfer  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");
                        $("#lblReportFromDate").text('');
                        $("#lblReportToDate").text('');

                        return false;
                    } else {
                        $("#lblReportFromDate").text(filters.from_date);
                        $("#lblReportToDate").text(filters.to_date);
                        $.each(obj.data, function (i, row) {
                            slno++;
                            if (checkorderId != row.st_id) {
                                var cnt = obj.count;
                                $("#lblTotalRecords").text(cnt);
                                //   htm += "<tr><td colspan='12' class='bordertopbottom' style='border-bottom:none;'></td></tr>";
                                htm += "<tr><td class=''>" + slno + "</a></td>";

                                htm += "<td>" + row.source + "</td>";

                                htm += "<td>" + row.Dest + "</td>";
                                htm += "<td>" + row.username + "</td>";
                                htm += "<td>" + row.TransferDate + "</td>";
                                htm += "</tr>";
                                htm += "<tr><td>Transfer Items:</td>";
                                htm += "<td colspan='5' style='font-size:12px;'>";
                                a = 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp (Quantity: (" + row.sti_quantity + ")) &nbsp&nbsp";
                                //  htm += "</td>";
                            }
                            else {
                                a = a + 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp (Quantity: (" + row.sti_quantity + ")) &nbsp&nbsp";

                            }

                            checkorderId = row.st_id;

                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });

                        $('#tblstockTransfer tbody').html(htm);
                    }
                    //alert(msg.d);

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


        //Start:Download Daily Reports List
        function DownloadTransferReport() {
            var filters = {};
            var perpage = $("#txtpageno").val();

            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }
            loading();

            //alert(searchResult);
            // alert("{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}");
            $.ajax({
                type: "POST",
                url: "stockTransferReport.aspx/DownloadTransferReport",
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
                        // location.href = "DownloadItemReport.aspx";
                        location.href = "DownloadTransferReport.aspx"
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
            $("#divFilter").hide();
            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();
            $("#spanpageno").hide();
            // $("#lbPrintReportType").html(searchtype);
            $("#tdReportType").hide();
            $("#divReportContent").print();
            $("#divFilter").show();
            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
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
                            <label style="font-weight: bold; font-size: 16px;">Stock Transfer Report</label>

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
                            <%-- <div class="title_left">
                <h3>Sales Cancel Reject Report</h3>
              </div> --%>
                        </div>

                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title">
                                        <label>Filter</label>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                        </ul>


                                        <div class="clearfix"></div>


                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="x_content">
                                        <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback" style="padding-left: 0px; padding-right: 0px;" id="divFilter">

                                            <div class="col-md-7 col-sm-6 col-xs-12 form-group has-feedback" style="padding-left: 0px;">
                                                
                                                <div class="col-md-6 col-sm-6 col-xs-6 form-group" style="padding-right: 0px;">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" style="padding-right: 5px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-6 col-sm-6 col-xs-6 form-group" style="padding-right: 0px;">
                                                    <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" style="padding-right: 5px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>

                                            </div>


                                            <%-- <div class="col-md-3 col-sm-6 col-xs-6 form-group has-feedback">

                                                <select id="comboSalesInReport" style="text-indent: 20px;" class="form-control">
                                                </select>

                                                <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                            </div>--%>

                                            <div class="col-md-3 col-sm-6 col-xs-6 form-group">
                                                <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:resetReport();">
                                                    <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                    Reset 
                                                </button>

                                                <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showStockTransferHistory(1);">
                                                    <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                    Search 
                                                </button>

                                            </div>

                                          
                                        </div>
                                        <section class="content invoice">
                                            <!-- title row -->
                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                                <div class="col-md-5 col-sm-6 col-xs-12 form-group">
                                                    <%--  <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">Branch :</label>
                                                        <label style="font-weight: normal;" id="lblReportBranchName">Abu Dhabi</label>
                                                    </div>--%>
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">From :</label>
                                                        <label style="font-weight: normal;" id="lblReportFromDate"></label>
                                                    </div>
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblReportToDate"></label>
                                                    </div>
                                                </div>
                                                <div class="col-sm-7 invoice-col">
                                                    <div class="col-md-4 col-sm-6 col-xs-6 form-group" style="padding-left: 0px; padding-right: 0px;">
                                                        <div class="col-md-5 col-sm-6 col-xs-7 form-group">
                                                            <label id="lblresultpage" style="font-weight: bold; font-size: 11px;">Per Page</label>
                                                        </div>
                                                        <div class="col-md-4 col-sm-6 col-xs-3" style="padding-left: 0px;">
                                                            <select class="" style="text-indent: 0; padding: 5px; height: 28px;" id="txtpageno" onchange="javascript:showStockTransferHistory(1);">
                                                                <option value="25">25</option>
                                                                <option value="50">50</option>
                                                                <option value="100">100</option>
                                                                <option value="1000">1000</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-6 form-group">
                                                        <label style="font-weight: bold; font-size: 11px;">Total Records:</label>
                                                        <label id="lblTotalRecords">0</label>
                                                    </div>
                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" onclick="javascript:DownloadTransferReport();" style="display:none">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Download Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" onclick="javascript:printMainReport();" style="display:none">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">
                                                <!-- Table row -->
                                                <div class="x_content" style="padding-left: 0px; padding-right: 0px;">
                                                    <table class="table table-striped" style="table-layout: auto;" id="tblstockTransfer">
                                                        <thead>
                                                            <tr>
                                                                <th>Sl No</th>
                                                                <th>Source Warehouse</th>
                                                                <th>Destination Warehouse</th>
                                                                <th>User</th>
                                                                <th>Date</th>
                                                              
                                                            </tr>
                                                        </thead>

                                                        <tbody>
                                                            <%-- <tr>
                                <td>1</td>
                                <td>Call of Duty</td>
                                <td>25-5-2016</td>
                                <td>active</td>
                                <td>145782</td>
                                <td>Ajman & Al Manama Supermarket</td>
                                  <td>452</td>
                                  <td>5</td>
                                  <td>6</td>
                                  <td>2</td>
                                  <td>200</td>
                                  <td>252</td>
                              </tr>
                                 <tr>
                                    <td colspan="12" class="tableborder">Returned By:Abanjana R<br />
<b style="font-size:11px;">Items:1). AMBER RICE DAILY / BASMATI - 38KG   ( (1 * 108)-0=108)     2). AMBER FLOURS VERMICELLI - 450GM   ( (1 * 3)-0=3)</b>    </td>
                                </tr>--%>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <div id="paginatediv" style="text-align: center;"></div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->


                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="clearfix"></div>

                        <%--<div class="row" id="divsumry">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div style="margin-bottom: 0px;" class="x_title">
                                        <label class="pull-left">Summary Report</label>

                                        <ul class="nav navbar-right panel_toolbox pull-right">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                             
                                        </ul>

                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="x_content">

                                        <section class="content invoice">
                                            <!-- title row -->
                                            <div class="row">

                                                <!-- /.col -->
                                            </div>

                                            <!-- /.row -->

                                            <!-- Table row -->


                                            <div class="row">

                                                <!-- /.col -->
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top: 10px;">
                                                    <label style="font-weight: bold; font-size: 14px;">
                                                        Purchase Summary ( Total Records:<label id="lblcountCollection"></label>
                                                        )
                                                    </label>
                                                    <div class="table-responsive" style="font-weight: bold;" id="SummaryReportDiv">
                                                        <table class="table">
                                                            <tbody>
                                                                <tr>
                                                                    <th>Total Purchased Amount</th>
                                                                    <td id="textTotalAmt">0</td>
                                                                </tr>
                                                                <tr>
                                                                    <th>Total Paid Amount</th>
                                                                    <td id="textPaidAmt">0</td>
                                                                </tr>
                                                                 <tr>
                                                                    <th>Total Balance</th>
                                                                    <td id="textBalance">0</td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan='2'></td>
                                                                </tr>
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
                                           
                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>--%>
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
    <%-- <script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
</body>
</html>

