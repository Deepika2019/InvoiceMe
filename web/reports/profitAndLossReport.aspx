<%@ Page Language="C#" AutoEventWireup="true" CodeFile="profitAndLossReport.aspx.cs" Inherits="reports_profitAndLossReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Profit & Loss Report | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
    <script src="../js/pagination.js" type="text/javascript"></script>
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
    <%-- autosearch --%>
    <script src="../autosearch/jquery-ui.js" type="text/javascript"></script>
    <link href="../autosearch/jquery-ui.css" rel="Stylesheet" type="text/css" />
    <script src="../autosearch/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../autosearch/jquery-1.12.4.js" type="text/css"></script>
    <%-- autosearch --%>

    <script type="text/javascript">
        $(function () {
            showProfitLoss();
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

        //function for profit and loss summary
        function showProfitLoss() {
            var filters = {};
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }
            var lblDateAddstr = " For The period";
           // alert(filters.to_date);
            if (filters.from_date != undefined) {
                lblDateAddstr += " From " + filters.from_date + " ";
            }
            if (filters.to_date != undefined) {
                lblDateAddstr += " To " + filters.to_date + " ";
            }
            $("#lblDateAdd").text(lblDateAddstr);
            if (filters.from_date == undefined && filters.to_date == undefined) {
                $("#lblDateAdd").text("");
            }
            $.ajax({
                type: "POST",
                url: "profitAndLossReport.aspx/showProfitLoss",
                data: "{'filters':" + JSON.stringify(filters) + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    console.log(msg.d);
                    profitLossObj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tbodyProfitLoss').html("");
                    if (profitLossObj != "") {
                        //income
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); font-weight:bold;  text-transform: uppercase;" scope="row" colspan="3">Income</td>';
                        //htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row"></td>';
                        //htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                        htm += '</tr>';
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);" scope="row">Sales</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row"></td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row">' + profitLossObj.data[0]["totalSales"] + '</td>';
                        htm += '</tr>';
                       
                        $.each(profitLossObj.category, function (i, row) {
                            if (row.type == 1) {
                                htm += '<tr>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);" scope="row">' + row.name + '</td>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row">' + row.total + '</td>';
                                htm += '</tr>';
                            }
                        });
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); font-weight:bold;" scope="row">Total</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row"></td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%; font-weight:bold;" scope="row">' + profitLossObj.data[0]["totalIncome"] + '</td>';
                        htm += '</tr>';

                        //expense
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);font-weight:bold;  text-transform: uppercase;" scope="row" colspan="3">Expense</td>';
                        //htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row"></td>';
                        //htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                        htm += '</tr>';
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);" scope="row">Purchase</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row">' + profitLossObj.data[0]["totalPurchase"] + '</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                        htm += '</tr>';

                        $.each(profitLossObj.category, function (i, row) {
                            if (row.type == 0) {
                                htm += '<tr>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);" scope="row">' + row.name + '</td>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row">' + row.total + '</td>';
                                htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                                htm += '</tr>';
                            }
                        });
                        htm += '<tr>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); font-weight:bold;" scope="row">Total</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%; font-weight:bold;" scope="row">' + profitLossObj.data[0]["totalExpense"] + '</td>';
                        htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row"></td>';
                        htm += '</tr>';
                        var profit = (profitLossObj.data[0]["totalIncome"] - profitLossObj.data[0]["totalExpense"]).toFixed(2);
                        htm += '<tr>';
                      
                        if (profit < 0) {
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); font-weight:bold; font-size:16px; height:50px;" scope="row">Net Loss</td>';
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;font-weight:bold;font-size:15px;Color:red" scope="row">' + (-1) * profit + '</td>';
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;font-weight:bold;font-size:16px;" scope="row"></td>';
                        } else {
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); font-weight:bold; font-size:16px; height:50px;" scope="row">Net Profit</td>';
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;font-weight:bold;font-size:16px;" scope="row"></td>';
                            htm += '<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;font-weight:bold;font-size:15px;Color:green;" scope="row">' + profit + '</td>';
                        }
                       
                        htm += '</tr>';
                    }
                    $('#tbodyProfitLoss').html(htm);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }

        function resetFilter() {
            $("#txtSearchFromDate").val("");
            $("#txtSearchToDate").val("");
            $("#lblDateAdd").text("");
            showProfitLoss();
        }
    </script>


    <style media="print">
        @page {
            size: auto;
            margin: 0;
        }

        thead {
            display: table-header-group;
        }
    </style>


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
                            <label style="font-weight: bold; font-size: 16px;">Profit & Loss Report </label>

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
                <h3>Sales Advanced Report</h3>
              </div> --%>
                        </div>

                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title" style="margin-bottom: 3px;">
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

                                        <section class="content invoice">
                                            <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback">

                                                <div class="col-md-5 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-5 col-sm-6 col-xs-12 form-group" id="divtodate">
                                                    <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                              
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                    <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:resetFilter();">
                                                        <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                        Reset 
                                                    </button>

                                                    <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showProfitLoss();">
                                                        <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                        Search 
                                                    </button>

                                                </div>
                                            </div>

                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">

                                                <%--<div class="col-sm-5 invoice-col">


                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" style="cursor: pointer;" onclick="javascript:DownloadDailyReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Report</label>
                                                    </div>


                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="cursor: pointer;" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>--%>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->




                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content">
                                                    
                                                    <div id="transtable">
<table class="table table-bordered" style="color:#000;">
  <thead>
    <tr style="background: #6e99ca;">
      <th colspan="4" scope="col" style="text-align: center; color: #fff;">Profit & Loss Account <label id="lblDateAdd"></label></th>
      
    </tr>
  </thead>
  <tbody id="tbodyProfitLoss">
    
    <tr>
<td style="border-top: 1px solid rgba(255, 255, 255, .5);" scope="row">Particulars</td>
<td style="border-top: 1px solid rgba(255, 255, 255, .5);width:20%;" scope="row">Debit</td>
<td style="border-top: 1px solid rgba(255, 255, 255, .5); width:20%;" scope="row">Credit</td>
 </tr>
    
  </tbody>
</table>
                                                    </div>



                                                </div>

                                            </div>

                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="clearfix"></div>

                        <div class="row" id="divsumry" style="display:none;">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title">
                                        <label>Summary Report</label>

                                        <ul class="nav navbar-right panel_toolbox pull-right">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                        </ul>

                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="x_content">

                                        <section class="content invoice">
                                            <!-- title row -->
                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                                <div class="col-md-8 col-sm-6 col-xs-12 form-group">

                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">From :</label>
                                                        <label style="font-weight: normal;" id="lblSummaryFromDate"></label>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblSummaryToDate"></label>
                                                    </div>
                                                </div>

                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->


                                            <div class="row" id="divSummryall">

                                                <!-- /.col -->
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top: 10px;">

                                                    <div class="table-responsive" style="font-weight: bold;" id="SummaryReportDiv">
                                                        <table class="table">
                                                            <tbody>

                                                                <tr>
                                                                    <th style="width: 50%">Debit</th>
                                                                    <td id="lblIncome"></td>
                                                                </tr>
                                                                <tr>
                                                                    <th>Credit</th>
                                                                    <td id="lblExpense"></td>
                                                                </tr>
                                                                <tr>
                                                                    <th class="tableborder">Profit</th>
                                                                    <td class="tableborder" id="lblProfit"></td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="tableborder">Loss</td>
                                                                    <td class="tableborder" id="lblLoss"></td>

                                                                </tr>



                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                                <!-- /.col -->
                                                <div class="clearfix"></div>
                                                <%--<div class="col-md-12 col-sm-12 col-xs-12" style="margin-top:10px;">
                       <label style="font-weight:bold; font-size:14px;"> Sales Summary  ( Total Records: <label id="lblcountSales"></label> ) </label>
                          <div class="table-responsive" style="font-weight:bold;" id="divsalesSummary">
                            <table class="table">
                              <tbody>
                             
                              </tbody>
                            </table>
                          </div>
                        </div>--%>
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
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- iCheck -->
    <script src="../js/bootstrap/icheck.min.js"></script>
    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>