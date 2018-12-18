<%@ Page Language="C#" AutoEventWireup="true" CodeFile="purchaseReports.aspx.cs" Inherits="reports_purchaseReports" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Purchase Report | Invoice Me</title>
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
    <%-- autosearch --%>
    <script src="../autosearch/jquery-ui.js" type="text/javascript"></script>
    <link href="../autosearch/jquery-ui.css" rel="Stylesheet" type="text/css" />
    <script src="../autosearch/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../autosearch/jquery-1.12.4.js" type="text/css"></script>
    <%-- autosearch --%>
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
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');

            // showProfileHeader(1);
            SearchAutoSupplier();
            $("#supplierNames").val("");
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
            showPurchaseReports(1);
        }
        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }//end date picker


        //auto populate in vendor search
        function SearchAutoSupplier() {
            $("#supplierNames").keyup(function () {
                //alert("ch");
                if ($("#supplierNames").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });

            $("#supplierNames").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "purchaseReports.aspx/GetAutoCompleteSupplierData",
                        data: "{'variable':'" + $("#supplierNames").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1);
                        }
                    });
                },
                select: function (event, ui) {
                    $("#supplierNames").val(ui.item.label); //ui.item is your object from the array
                    vendorId = ui.item.id;
                    // selectVendor();
                    event.preventDefault();
                },
                minLength: 1

            });
        }

        //search customers: show in popup
        function resetvendordata() {
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            searchvendordata(1);
        }
        function searchvendordata(page) {
            var filters = {};
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.vendorname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.vendorid = $("#searchposContent1").val();
            }

            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "purchaseReports.aspx/searchvendordata",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tableVendorList tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  console.log(obj);
                        $("#lblItemTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            htm += "<tr ";
                            htm += " onclick=javascript:selectVendor('" + row.vn_id + "','" + row.vn_name.replace(/\s/g, '&nbsp;') + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.vendorid, row.vn_id.toString()) + "</td><td>" + getHighlightedValue(filters.vendorname, row.vn_name) + "</td><td>" + row.vn_balance + "</td></tr>";

                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        //   alert(htm);
                        $('#tableVendorList tbody').html(htm);
                        $("#popupVendors").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchvendordata"));


                        return;
                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });

        }

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function selectVendor(id, name) {
            vendorId = id;
            $("#supplierNames").val(name);
            popupclose('popupVendors');
        }
        function resetReport() {
            ShowUTCDate();
            $("#lblReportFromDate").text('');
            $("#lblReportBranchName").text('');
            $("#lblReportToDate").text('');
            $("#supplierNames").val("");
            vendorId = 0;
            showPurchaseReports(1);
        }

        //Start:Show Daily Reports List
        function showPurchaseReports(page) {
            //alert(vendorId);
            var filters = {};
            var perpage = $("#txtpageno").val();

            if (vendorId != 0) {
                filters.vendorId = vendorId;
            }

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
                url: "purchaseReports.aspx/showPurchaseReports",
                data: "{'page':'" + page + "','filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    console.log(obj.data);
                    var checkorderId = 0;
                    var htm = "";
                    if (obj.data == "N") {
                        $("#lblTotalRecords").text(0);
                        $('#tblpurchaseadvancereport  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");
                        $("#lblcountPurchases").text('');
                        $("#lblReportFromDate").text('');
                        $("#lblReportToDate").text('');
                        $("#divsumry").hide();

                        return false;
                    } else {
                        $("#lblReportFromDate").text(filters.from_date);
                        $("#lblReportToDate").text(filters.to_date);
                        
                        $.each(obj.data, function (i, row) {
                            if (checkorderId != row.pm_id) {
                                var paymentmode = "";
                                var cnt = obj.count;
                                $("#lblTotalRecords").text(cnt);
                                $("#lblcountPurchases").text(cnt);
                                $("#lblcountCollection").text(cnt)
                                //   htm += "<tr><td colspan='12' class='bordertopbottom' style='border-bottom:none;'></td></tr>";
                                htm += "<tr><td class=''><a href='/purchase/managepurchase.aspx?purchaseId=" + row.pm_ref_no + "' style='text-decoration:none; color:#056dba;'> " + row.pm_id + "</a></td>";

                                htm += "<td>" + row.pm_ref_no + "</td>";

                                htm += "<td>" + row.PurchaseDate + "</td>";

                                if (row.pm_cash_amt > 0) {

                                    paymentmode = paymentmode + ", Cash";
                                    // alert(paymentmode);
                                }
                                if (row.pm_card_amt > 0) {
                                    paymentmode = paymentmode + ", Card";
                                }
                                if (row.pm_chq_amt > 0) {
                                    paymentmode = paymentmode + ", Cheque";
                                }
                                if (paymentmode != "") {
                                    paymentmode = paymentmode.substr(1);
                                }
                                // alert(paymentmode);

                                htm += "<td>" + paymentmode + "</td>";
                                htm += "<td><a href='/inventory/managevendor.aspx?vendorId=" + row.vn_id + "'style='text-decoration:none; color:#056dba;'>" + row.vn_id + "</a></td>";
                                htm += "<td>" + row.vn_name + "</td>";
                                if (row.pm_ref_no != row.pm_id) {
                                    htm += "<td colspan='4' style='text-align:center;color:#056dba;'>Outstanding Bill</td>";
                                    htm += "<td>" + row.pm_paidamount + "</td><td>" + row.pm_balance + "</td></tr>";
                                    return;
                                }
                                else {
                                    htm += "<td>" + row.pm_total + "</td><td>" + row.pm_discount_rate + "</td><td>" + row.pm_discount_amount + "</td><td>" + row.pm_netamount + "</td>";
                                }
                                htm += "<td>" + row.pm_paidamount + "</td><td>" + row.pm_balance + "</td></tr>";

                                htm += "<tr><td colspan='12' style='font-size:11px; font-weight:bold;'>Purchased By:" + row.salesname + "</td>";




                                // htm += "<tr><td colspan='2' style='font-size:11px; font-weight:bold;'>Sold By:" +row.salesname + "</td>";
                                //if (row.approvername != null) {
                                //    htm += "<td colspan='10'  style='font-size:11px; font-weight:bold;' >Approved By:" + row.approvername + "</td>";
                                //}
                                htm += "</tr>";
                                htm += "<tr><td>Items:</td>";
                                htm += "<td colspan='11' style='font-size:12px;'>";
                                a = 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.pi_qty + " * " + row.pi_price + ")-";

                                htm += "" + row.pi_discount_amt + "=" + row.pi_netamount + ")  &nbsp &nbsp ";
                                //  htm += "</td>";
                            }
                            else {
                                a = a + 1;
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.pi_qty + " * " + row.pi_price + ")-";
                                htm += "" + row.pi_discount_amt + "=" + row.pi_netamount + ")  &nbsp &nbsp ";

                            }

                            checkorderId = row.pm_id;

                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });
                        $("#divsumry").show();
                        $("#textTotalAmt").text(obj.summarydata[0].netamount);
                      
                        var totalPaid = obj.summarydata[0].netamount - obj.summarydata[0].totalBalance;
                        $("#textPaidAmt").text(totalPaid);
                        $("#textBalance").text(obj.summarydata[0].totalBalance);
                        $('#tblpurchaseadvancereport tbody').html(htm);
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
        function DownloadPurchaseReport() {
            var filters = {};
            var perpage = $("#txtpageno").val();

            if (vendorId != 0) {
                filters.vendorId = vendorId;
            }

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
                url: "purchaseReports.aspx/DownloadPurchaseReport",
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
                        location.href = "DownloadPurchaseReport.aspx"
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
                            <label style="font-weight: bold; font-size: 16px;">Purchase Report</label>

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
                                                <div class="col-md-5 col-sm-6 col-xs-10 form-group has-feedback" style="padding-right: 0px;">
                                                    <input class="form-control has-feedback-left" placeholder="Search Suppliers" id="supplierNames" style="padding-right: 2px;" />
                                                    <span aria-hidden="true" class="fa fa-search form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-1 col-sm-6 col-xs-2 form-group has-feedback" style="padding-left: 0px; padding-right: 0px;">
                                                    <div onclick="javascript:resetvendordata(1);" title="Search Customers" data-toggle="modal" style="font-size: 24px; margin-left: 5px;">
                                                        <label style="cursor: pointer;" class="fa fa-user"></label>
                                                        <label style="cursor: pointer; font-size: 20px; color: #ff6a00; position: relative; margin-left: -12px;" class="fa fa-search"></label>
                                                    </div>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="padding-right: 0px;">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" style="padding-right: 5px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-6 form-group" style="padding-right: 0px;">
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

                                                <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showPurchaseReports(1);">
                                                    <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                    Search 
                                                </button>

                                            </div>

                                            <%--start popup for customers --%>
                                            <div class="container">


                                                <div class="modal fade" id="popupVendors" role="dialog">
                                                    <div class="modal-dialog modal-lg" style="width:;">

                                                        <!-- Modal content-->
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <button type="button" class="close" onclick="javascript:popupclose('popupVendors');">&times;</button>
                                                                <div class="col-md-6 col-sm-6 col-xs-6">
                                                                    <h4 class="modal-title">Search Suppliers</h4>
                                                                </div>
                                                                <div class="col-md-5 col-sm-4 col-xs-12">
                                                                    <div class="col-md-4 col-sm-12 col-xs-8">
                                                                        <label>Total: </label>
                                                                        <label id="lblItemTotalrecords">20</label>
                                                                    </div>
                                                                    <div class="col-md-2 col-sm-12 col-xs-3">
                                                                        <select id="txtpospageno" onchange="javascript:searchvendordata(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                            <option value="50">50</option>
                                                                            <option value="100">100</option>
                                                                            <option value="250">250</option>
                                                                            <option value="500">500</option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="col-md-6 col-sm-12 col-xs-12">
                                                                        <div class="" onclick="javascript:searchvendordata(1);">
                                                                            <button type="button" class="btn btn-success mybtnstyl">
                                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                                Search
                                                                            </button>
                                                                        </div>
                                                                        <div class="" onclick="javascript:resetvendordata();">
                                                                            <button class="btn btn-primary mybtnstyl" type="reset">
                                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                                Reset
                                                                            </button>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                                <div class="x_content">

                                                                    <table id="tableVendorList" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Vendor Id</th>
                                                                                <th>Name</th>
                                                                                <th>Outstanding</th>


                                                                            </tr>


                                                                            <tr>
                                                                                <td>
                                                                                    <input type="text" class="form-control" id="searchposContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                                <td>
                                                                                    <input type="text" id="searchposContent2" class="form-control" /></td>
                                                                                <td></td>

                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                            <div class="clearfix"></div>
                                                        </div>

                                                    </div>
                                                </div>

                                            </div>
                                            <%-- end popup for customers --%>
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
                                                        <label style="font-weight: normal;" id="lblReportFromDate">29-03-2016</label>
                                                    </div>
                                                    <div class="col-md-4 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblReportToDate">29-03-2017</label>
                                                    </div>
                                                </div>
                                                <div class="col-sm-7 invoice-col">
                                                    <div class="col-md-4 col-sm-6 col-xs-6 form-group" style="padding-left: 0px; padding-right: 0px;">
                                                        <div class="col-md-5 col-sm-6 col-xs-7 form-group">
                                                            <label id="lblresultpage" style="font-weight: bold; font-size: 11px;">Per Page</label>
                                                        </div>
                                                        <div class="col-md-4 col-sm-6 col-xs-3" style="padding-left: 0px;">
                                                            <select class="" style="text-indent: 0; padding: 5px; height: 28px;" id="txtpageno" onchange="javascript:showPurchaseReports(1);">
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
                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" onclick="javascript:DownloadPurchaseReport();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Download Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" onclick="javascript:printMainReport();">
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
                                                    <table class="table table-striped" style="table-layout: auto;" id="tblpurchaseadvancereport">
                                                        <thead>
                                                            <tr>
                                                                <th>Purchase No</th>
                                                                <th>Ref No</th>
                                                                <th>Date</th>
                                                                <th>Mode</th>
                                                                <th>Supplier.ID</th>
                                                                <th>Supplier.Name</th>
                                                                <th>Total Amt.</th>
                                                                <th>Dis%</th>
                                                                <th>Dis.Amt </th>
                                                                <th>Net.Amt</th>
                                                                <th>Paid</th>
                                                                <th>Balance</th>
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

                        <div class="row" id="divsumry">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div style="margin-bottom: 0px;" class="x_title">
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
                                                <%--<div class="col-md-12 col-sm-12 col-xs-12" style="margin-top:10px;">
                       <label style="font-weight:bold; font-size:14px;"> Sales Summary  ( Total Records: <label id="lblcountPurchases"></label> ) </label>
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
