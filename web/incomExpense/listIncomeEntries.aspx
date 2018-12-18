<%@ Page Language="C#" AutoEventWireup="true" CodeFile="listIncomeEntries.aspx.cs" Inherits="listIncomeEntries" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Purchase Entries  | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script src="../js/pagination.js" type="text/javascript"></script>

    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- bootstrap-daterangepicker -->
    <link href="../css/bootstrap/daterangepicker.css" rel="stylesheet" />

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Styles-->
    <link href="../css/bootstrap/mystyle.css" type="text/css" rel="stylesheet" />
    <!--date picker-->
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!--date picker-->

    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }

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
                // dateFormat: 'dd-MM-yy'
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
                //dateFormat: 'dd-MM-yy'
            });

            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
            resetFilters();
            //// resetFilters();

        });


        function searchEntries(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();

            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }

            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }
           
            console.log(JSON.stringify(filters));

            loading();

            $.ajax({
                type: "POST",
                url: "listIncomeEntries.aspx/searchEntries",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    var html = "";
                    $('#tblEntries > tbody').html("");
                    
                    if (obj.count == 0) {
                                                
                        htm += '<td colspan="4" style="text-align:center"></div></div><div class="cl" style="height:5px;"></div><label>Empty</label></td>';
                        $("#txttotalordercount").text(0);
                    }
                    $.each(obj.data, function (i, row) {
                        $("#txttotalordercount").text(obj.count);
                        htm += '<tr>';
                        htm += '<td>';
                        htm += '<div style="width:300px;">';
                        htm += '<div>';
                        htm += '<div class="fl">';
                        htm += '<span class="myorderMData fl">';
                        htm += '<a class="fl" style="color: inherit; margin-bottom:0px;" href="manageIncome.aspx?purchaseId=' + row.ie_id + '">#' + getHighlightedValue(filters.search, row.ie_invoice_num.toString()) + '</a>';
                        htm += '<label class="fl" style="margin-bottom:0px; padding-left:5px; padding-right:5px; font-size:14px;"><a>' + getHighlightedValue(filters.search, row.externalusername) + '(' + (filters.search, '<span style="font-size: 10px;color:blue">' + row.ie_category + '</span>') + ')' + '</a></label>';

                        if (row.pm_total_balance > 0) {
                            htm += '<span class="label label-danger" style="margin-left:2px;">Outstanding</span>';
                        }
                        
                        htm += '</div>';
                        htm += '</div>';
                        htm += '<div class="clear"></div>';
                        htm += '<div style="text-align: left;">';
                        htm += '<span class="myorderSData"></span><span class="fa fa-calendar myicons" ></span><span class="myorderSData">' + row.ieDate + '</span>&nbsp;&nbsp;<span class="fa fa-edit myicons"></span>';
                        htm += '<span class="myorderSData">' + row.enteredusername + '</span></div>';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '<td style="text-align:center";>' + row.net_amount + '</td>';
                        htm += '<td style="text-align:center">' + row.ie_total_balance + '</td>';
                        htm += '<td>';
                        htm += '<a href="manageIncome.aspx?purchaseId=' + row.ie_id + '" class="btn btn-primary btn-xs" title="view">';
                        htm += '<li class="fa fa-eye" style="font-size:large;"></li>';
                        htm += '</a>';
                        
                        htm += '</td>';
                        htm += '</tr>';

                    });
                    
                    $('#tblEntries > tbody').html(htm);
                    html += '<tr>';
                    html += '<td colspan="4">';
                    html += '<div  id="divPagination" style="text-align: center;">';
                    html += '</div>';
                    html += '</td>';
                    html += '</tr>';
                    $('#tblEntries > tbody').append(html);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchEntries"));

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function resetFilters() {
            $("#txtSearch").val("");
            $("#txtSearchToDate").val("");
            $("#txtSearchFromDate").val("");
            searchEntries(1);
        }


        function addNewIncome() {
            window.location.href = "income.aspx";
        }


    </script>

</head>

<body class="nav-md">
    <form id="form1" runat="server">

        <div class="container body">
            <div class="main_container">
                <!-- Start div For loading image-->
                <div id="loading" style="background-repeat: no-repeat; margin: auto; height: 100%; display: none">
                    <div align="center" style="margin: auto">
                        <img id="loading-image" src="../images/loader.gif" alt="Loading..." />
                    </div>
                </div>
                <!-- End  div For loading image-->
                <div class="col-md-3 left_col">
                    <div class="left_col scroll-view">
                        <div class="navbar nav_title" style="border: 0;">
                            <a href="#" class="site_title">
                                <!--<i class="fa fa-paw"></i>-->
                                <span>Invoice</span></a>
                        </div>

                        <div class="clearfix"></div>

                        <!-- menu profile quick info -->
                        <div class="profile clearfix">
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
                                <label style="font-weight: bold; font-size: 16px;">Incomes</label>
                                 <div class="col-md-10 col-xs-6" data-toggle="modal" data-target="#popupVendor" onclick="addNewIncome();">
                                <div class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>Add New</div>
                                      </div>

                            </div>

                        </nav>
                    </div>
                </div>
                <!-- /top navigation -->

                <!-- page content -->
                <div class="right_col" role="main">
                    <div class="">

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

                                           

                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearchFromDate" placeholder="From Date" />
                                                <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearchToDate" placeholder="To Date" />
                                                <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                             <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="Invoice no./User name" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <div class="btn btn-primary mybtnstyl pull-right" onclick="javascript:resetFilters();">
                                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                        Reset
                                                    </div>
                                                    <div class="btn btn-success mybtnstyl pull-right" onclick="javascript:searchEntries(1);">
                                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                        Search
                                                    </div>

                                                    
                                                </div>
                                            <div class="clearfix"></div>
                                            <div class="ln_solid"></div>
                                            <div class="form-group">


                                            </div>

                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <!--      <h2>Hover rows</h2>-->
                                        <div class="col-md-6 col-sm-12 col-xs-12">

                                            <label>Incomes</label><span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="txttotalordercount">0</span>

                                        </div>
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <ul class="nav navbar-right panel_toolbox">

                                                <li>
                                                    <select id="slPerpage" onchange="javascript:searchEntries(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                        <option value="50">50</option>
                                                        <option value="100">100</option>
                                                        <option value="250">250</option>
                                                        <option value="500">500</option>
                                                    </select></li>


                                                <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                            </ul>
                                        </div>

                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                        <div class="x_content">
                                            <table id="tblEntries" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>Entry</th>
                                                        <th style="text-align: center;">Net Amount</th>
                                                        <th style="text-align: center;">Balance To Get</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td colspan="4" style="text-align: center">
                                                            <label>Empty</label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="4">
                                                            <div class="border"></div>
                                                        </td>

                                                    </tr>

                                                </tbody>
                                            </table>


                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content">

                                         </div>


                                            </div>

                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                        <!-- /page content -->


                    </div>


                </div>
                <!-- footer content -->
                <footer>
                    <div class="pull-right">
                        <div class="footerDiv">
                            <div class="footerDivContent">
                                Copyright 2014 ©
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                </footer>
                <!-- /footer content -->
            </div>
        </div>
    </form>

    <!-- jQuery -->
    <%--<script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- jQuery -->
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
