<%@ Page Language="C#" AutoEventWireup="true" CodeFile="orders.aspx.cs" Inherits="sales_orders" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Bills  | Invoice Me</title>
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
        var BranchId;
        $(document).ready(function () {

            // console.log(JSON.parse($.cookie("search-data")));
            ////alert(history.previous);
            //if (document.referrer == previousPageURL) {
            //    alert("Its a back button click...");
            //    //Specific code here...
            //}
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
            getBranches();
            //   takeQuerystring();
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");

            //// resetFilters();

        });

        function getBranches() {
            loading();
            $.ajax({
                type: "POST",
                url: "orders.aspx/getBranches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#slBranch").html(htm);
                    showsalespersons();
                    //     $("#slBranch").val(BranchId);




                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        // Show sales person
        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "Orders.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#comboSalesPerson").html(msg.d);
                        //  alert(getQueryString("sellerId"));
                        if (getQueryString("sellerId") != undefined && getQueryString("sellerId") != "") {
                            $("#comboSalesPerson").val(getQueryString("sellerId"));
                        }
                        var event = getQueryString("event");
                        if (event == "back") {
                            console.log(JSON.parse($.cookie("search-data")));
                            var searchObject = JSON.parse($.cookie("search-data"));
                            if (searchObject.branch == undefined) {
                                $("#slBranch").val(-1);
                            } else {
                                $("#slBranch").val(searchObject.branch);
                            }
                            if (searchObject.seller_id == undefined) {
                                $("#comboSalesPerson").val(0);
                            } else {
                                $("#comboSalesPerson").val(searchObject.seller_id);
                            }
                            if (searchObject.order_status == undefined) {
                                $("#slOrderStatus").val(-1);
                            } else {
                                $("#slOrderStatus").val(searchObject.order_status);
                            }
                            if (searchObject.payment_status == undefined) {
                                $("#slPaymentStatus").val(-1);
                            } else {
                                $("#slPaymentStatus").val(searchObject.payment_status);
                            }
                            if (searchObject.search == undefined) {
                                $("#txtSearch").val("");
                            } else {
                                $("#txtSearch").val(searchObject.search);
                            }
                            if (searchObject.custSearch == undefined) {
                                $("#txtCustSearch").val("");
                            } else {
                                $("#txtCustSearch").val(searchObject.custSearch);
                            }
                            if (searchObject.to_date == undefined) {
                                $("#txtSearchToDate").val("");
                            } else {
                                $("#txtSearchToDate").val(searchObject.to_date);
                            }
                            if (searchObject.from_date == undefined) {
                                $("#txtSearchFromDate").val("");
                            } else {
                                $("#txtSearchFromDate").val(searchObject.from_date);
                            }
                            //  alert(searchObject.seller_id);
                            searchOrders(1);

                        } else {
                            takeQuerystring();

                        }

                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        function takeQuerystring() {
            var orderStatus = getQueryString("orderStatus");
            var paymentStatus = getQueryString("paymentStatus");
            var fromDate = getQueryString("fromdate");
            var toDate = getQueryString("todate");
            var customername = getQueryString("customername");
            var customerId = getQueryString("customerid");
            if (customername == undefined) {
                customername = "";
            }
            if (customerId == undefined) {
                customerId = "";
            }
            //deliverySalesstatus=0&salesId=0&fromdate=18-01-2015&todate=18-01-2017
            if (orderStatus == undefined) {
                orderStatus = -1;
            }
            if (paymentStatus == undefined) {
                paymentStatus = -1;
            }
            if (fromDate == undefined) {
                fromDate = "";
            }
            if (toDate == undefined) {
                toDate = "";
            }
            customername = customername.replace(/%20/g, " ");
            $("#txtCustSearch").val(customerId);
            $("#slBranch").val(-1);
            $("#slPaymentStatus").val(paymentStatus);
            $("#slOrderStatus").val(orderStatus);
            $("#txtSearchFromDate").val(fromDate);
            $("#txtSearchToDate").val(toDate);
            searchOrders(1);
        }

        function searchOrders(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            var branchId = $.cookie("invntrystaffBranchId");
            // alert(branchId);
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "../dashboard.aspx";
                return false;
            }
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }
            if ($("#txtCustSearch").val() != "" && $("#txtCustSearch").val() != undefined) {
                filters.custSearch = $("#txtCustSearch").val();
            }

            if ($("#slBranch").val() != undefined) {
                filters.branch = $("#slBranch").val();
            }
            else {
                //  setting branch from cookie if branches are not loaded
                filters.branch = BranchId;
            }

            if ($("#slPaymentStatus").val() != -1 && $("#slPaymentStatus").val() != undefined) {
                filters.payment_status = $("#slPaymentStatus").val();
            }
            if ($("#slOrderStatus").val() != -1 && $("#slOrderStatus").val() != undefined) {
                filters.order_status = $("#slOrderStatus").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }
            if (getQueryString("customerId") != undefined && getQueryString("customerId") != "") {
                filters.cus_id = getQueryString("customerId");
            }
            if ($("#selType").val() != -1 && $("#selType").val() != undefined) {
                filters.type = $("#selType").val();
            }
            //if($("#comboSalesPerson").val() != "0")  {
            filters.seller_id = $("#comboSalesPerson").val();

            //  alert(filters.seller_id);
            //}
            //else if (getQueryString("sellerId") != undefined && getQueryString("sellerId") != "" && getQueryString("sellerId") != "0") {

            //    filters.seller_id = getQueryString("sellerId");
            //}

            //console.log(JSON.stringify(filters));
            $.cookie("search-data", JSON.stringify(filters));
            loading();

            $.ajax({
                type: "POST",
                url: "Orders.aspx/searchOrders",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //   console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    var html = "";
                    var classType = "";
                    $('#tblOrders > tbody').html("");
                    if (obj.count == 0) {
                        //htm += "</div></div><div class='cl' style='height:5px;'></div>";
                        htm += '<td colspan="4" style="text-align:center"></div></div><div class="cl" style="height:5px;"></div><label>Empty</label></td>';
                        $("#txttotalordercount").text(0);
                    }
                    $.each(obj.data, function (i, row) {
                        $("#txttotalordercount").text(obj.count);
                        //0=New, 1=procesd, 2=deliverd, 3=to be confirm,4=cancel,5=reject
                        var status;
                        var status_class;
                        switch (row.order_status) {
                            case 0: status = "New"; status_class = "label label-warning"; break;
                            case 1: status = "Processed"; status_class = "label label-primary"; break;
                            case 2: status = "Delivered"; status_class = "label label-success"; break;
                            case 3: status = "To be confirmed"; status_class = "label label-info"; break;
                            case 4: status = "Canceled"; status_class = "label label-default"; break;
                            case 5: status = "Rejected"; status_class = "label label-default"; break;
                            case 6: status = "Pending"; status_class = "label label-default"; break;
                            default: status = "New"; status_class = "label label-warning"; break;

                        }
                        if (row.cust_type == 1) {
                            classType = "A";
                        } else if (row.cust_type == 2) {
                            classType = "B";
                        } else if (row.cust_type == 3) {
                            classType = "C";
                        }

                        htm += '<tr>';
                        htm += '<td>';
                        htm += '<div style="width:500px;">';
                        htm += '<div>';
                        htm += '<div class="fl">';
                        htm += '<span class="myorderMData fl">';

                        if (row.invoiceNum != "" && row.invoiceNum !== null) {
                            htm += '<a href="manageorders.aspx?orderId=' + row.ref_id + '"><label class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal;cursor:pointer" >#' + getHighlightedValue(filters.search, row.invoiceNum.toString()) + '(' + getHighlightedValue(filters.search, row.sm_id.toString()) + ')</label></a>';
                        } else {
                            htm += '<a href="manageorders.aspx?orderId=' + row.ref_id + '"><label class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal;cursor:pointer" ><span style="color:red">(Not billed yet)</span>(' + getHighlightedValue(filters.search, row.sm_id.toString()) + ')</label></a>';
                        }
                        htm += '<label class="fl" style="margin-bottom:0px; padding-left:5px; padding-right:5px; font-size:14px;"><a>' + getHighlightedValue(filters.search, row.cust_name) + '</a></label><span>(Class ' + classType + ')</span>';
                        htm += "<span class='status " + status_class + "'>" + status + "</span>";


                        if (row.total_balance > 0) {
                            htm += '<span class="label label-danger" style="margin-left:2px;">Outstanding</span>';
                        }
                        if (row.srm_smid != null) {
                            htm += '<span class="label label-default" style="margin-left:2px;">Returned</span>';
                        }


                        htm += '</div>';
                        htm += '</div>';
                        htm += '<div class="clear"></div>';
                        htm += '<div style="text-align: left;">';
                        htm += '<span class="myorderSData" style="color:#361efb;font-size:15px;">Ordered:  </span><label class="fa fa-calendar myicons" ></label><span class="myorderSData">' + row.orderDate + '</span>&nbsp;&nbsp;<label class="fa fa-edit myicons"></label>';
                        htm += '<span class="myorderSData">' + row.seller_name + '</span></div>';
                        if (row.invoiceNum != "" && row.invoiceNum !== null) {
                            htm += '<span class="myorderSData" style="color:#361efb;font-size:15px;"> Billed:  </span><label class="fa fa-calendar myicons" ></label><span class="myorderSData">' + row.billedDate + '</span>';

                            if (row.billedBy != null) {
                                htm += '&nbsp;&nbsp;<label class="fa fa-edit myicons"></label><span class="myorderSData">' + row.billedBy + '</span></div>';
                            }
                        }
                        htm += '</div>';
                        htm += '</td>';
                        htm += '<td style="text-align:center";>' + row.net_amount + '</td>';
                        if (row.total_balance > 0) {
                            htm += '<td style="text-align:center;color:red">' + row.total_balance + '</td>';
                        }
                        if (row.total_balance <= 0) {
                            htm += '<td style="text-align:center;color:green">' + row.total_balance + '</td>';
                        }
                        htm += '<td>';
                        htm += '<a href="manageorders.aspx?orderId=' + row.ref_id + '" class="btn btn-primary btn-xs">';
                        htm += '<li class="fa fa-eye" style="font-size:large;"></li>';
                        htm += '</a>';
                        htm += '<div class="btn btn-primary btn-xs" onclick="gotoPrintPage(' + row.branch_tax_method + ',' + row.ref_id + ')">';
                        htm += '<li class="fa fa-print" style="font-size:large;"></li>';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';


                    });
                    //  alert(htm);
                    $('#tblOrders > tbody').html(htm);
                    html += '<tr>';
                    html += '<td colspan="4">';
                    html += '<div  id="divPagination" style="text-align: center;">';
                    html += '</div>';
                    html += '</td>';
                    html += '</tr>';
                    // alert(htm);
                    $('#tblOrders > tbody').append(html);
                    //$('#tblOrders > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchOrders"));
                    console.log(JSON.parse($.cookie("search-data")));
                    //$("#paginatediv").html(paginate(obj.count, perpage, page, "searchOrders"));
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function resetFilters() {
            window.location.href = "orders.aspx";


        }

        function gotoPrintPage(taxMethod, orderId) {
            if (taxMethod == 0) {
                window.location.href = "billreceipt.aspx?orderId=" + orderId;
            } else if (taxMethod == 1) {
                window.location.href = "normalBillreceipt.aspx?orderId=" + orderId;
            } else if (taxMethod == 2) {
                window.location.href = "gstBillreceipt.aspx?orderId=" + orderId;
            }
            // alert(taxMethod);
        }
    </script>

</head>

<body class="nav-md">
    <form id="form1" runat="server" autocomplete="off">

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
                                <div class="col-md-6 col-xs-6">
                                    <label style="font-weight: bold; font-size: 16px;">Bills</label>
                                </div>
                                <div class="col-md-6 col-xs-5">



                                   <a href="neworder.aspx" target="_blank"> <div class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New Bill</div></a>
                                  
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
                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divsearchwarehouse">
                                                <select class="form-control" style="text-indent: 25px;" id="slBranch" onchange="javascript:searchOrders(1);">
                                                </select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                              <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="div1">
                                                <select class="form-control" style="text-indent: 25px;" id="selType" onchange="javascript:searchOrders(1);">
                                               <option value="-1" selected="selected">--All Orders&Bills--</option>
                                                     <option value="0">Orders Only</option>
                                                     <option value="1">Bills Only</option>
                                                     </select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="comboSalesPerson" onchange="javascript:searchOrders(1);">
                                                    <option>--Select Sales Person--</option>
                                                    <option>Sales Person1</option>
                                                    <option>Sales Person2</option>
                                                </select>
                                                <span class="fa fa-users form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="slOrderStatus" onchange="javascript:searchOrders(1);">
                                                    <option value="-1" selected="true">--Bill Status--</option>

                                                    <option value="3">To be Confirmed</option>
                                                    <option value="0">New</option>
                                                    <option value="1">Processed</option>
                                                    <option value="2">Delivered</option>
                                                    <option value="4">Canceled</option>
                                                    <option value="5">Rejected</option>
                                                </select>
                                                <span class="fa fa-file form-control-feedback left" aria-hidden="true"></span>
                                            </div>



                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="slPaymentStatus" onchange="javascript:searchOrders(1);">
                                                    <option value="-1" selected="selected">--Payment Status--</option>
                                                    <option value="1">Completed</option>
                                                    <option value="2">Outstanding</option>
                                                </select>
                                                <span class="fa fa-file-text-o form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="Bill/invoice No" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtCustSearch" placeholder="Customer ID/name" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback" id="tdresult" style="display: none;">
                                                <select class="form-control" style="text-indent: 25px;" id="txtpageno">
                                                    <option>--Result Per Page--</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                    <option value="200">200</option>
                                                </select>
                                                <span class="fa fa-archive form-control-feedback left" aria-hidden="true"></span>
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
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:searchOrders(1);">
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
                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <!--      <h2>Hover rows</h2>-->
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <label>Bills</label><span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="txttotalordercount"></span>

                                        </div>
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <ul class="nav navbar-right panel_toolbox">

                                                <li>
                                                    <select id="slPerpage" onchange="javascript:searchOrders(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
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
                                            <table id="tblOrders" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>Bill</th>
                                                        <th style="text-align: center;">Net Amt</th>
                                                        <th style="text-align: center;">Balance</th>
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
                                                        <td colspan="3">
                                                            <div class="border"></div>
                                                        </td>

                                                    </tr>

                                                </tbody>
                                            </table>


                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content">


                                                    <!--<div class="dataTables_paginate paging_simple_numbers" id="datatable_paginate">
				<div class="col-md-12 text-center">
				<ul class="pagination"><li class="paginate_button previous disabled" id="datatable_previous"><a href="#" aria-controls="datatable" data-dt-idx="0" tabindex="0">Previous</a></li><li class="paginate_button active"><a href="#" aria-controls="datatable" data-dt-idx="1" tabindex="0">1</a></li><li class="paginate_button "><a href="#" aria-controls="datatable" data-dt-idx="2" tabindex="0">2</a></li><li class="paginate_button "><a href="#" aria-controls="datatable" data-dt-idx="3" tabindex="0">3</a></li><li class="paginate_button "><a href="#" aria-controls="datatable" data-dt-idx="4" tabindex="0">4</a></li><li class="paginate_button next" id="datatable_next"><a href="#" aria-controls="datatable" data-dt-idx="7" tabindex="0">Next</a></li></ul></div></div>-->
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
