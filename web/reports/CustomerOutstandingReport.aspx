<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CustomerOutstandingReport.aspx.cs" Inherits="reports_OutstandingBillReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Customer outstanding bill report</title>
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
        var BranchId;
        var custid = 0;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#customerNames").val("");
            SearchAutoCustomer();
            //showProfileHeader(1);
            showBranches();
            ShowUTCDate();
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

        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtSearchFromDate").val(localdate);
            $("#txtSearchToDate").val(localdate);

        }//end

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];

        }//end
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

        //auto populate in vendor search
        function SearchAutoCustomer() {
            $("#customerNames").keyup(function () {
                //alert("ch");
                if ($("#customerNames").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });

            $("#customerNames").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "salesreportsadvance.aspx/GetAutoCompleteCustomerData",
                        data: "{'variable':'" + $("#customerNames").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            console.log(data.d);
                            var data1 = jQuery.parseJSON(data.d);
                            //  alert(data1);
                            console.log(data1.value);

                            response(data1);


                        },
                        error: function (data) {
                            alert("Internet Problem..!");
                        }
                    });
                },
                select: function (event, ui) {

                    custid = ui.item.id;
                    if (custid == -1) {
                        $("#customerNames").val("");
                    } else {
                        $("#customerNames").val(ui.item.label); //ui.item is your object from the array
                    }
                    // selectVendor();
                    event.preventDefault();
                },
                minLength: 1

            });
        }


        //start: show branches in Reports page
        function showBranches() {
            var loggedInBranch = $.cookie("invntrystaffBranchId");
            var userid = $.cookie("invntrystaffId");
            //alert(userid);
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--All--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#comboBranchesInReport").html(htm);
                    $("#comboBranchesInReport").val(loggedInBranch);
                    showcustomers();
                    getOutstandingBills(1);

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
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showCustomersInReports",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Customer--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cust_id + '">' + row.cust_name + '</option>';
                    });
                    $("#comboCustomersInReport").html(htm);
                    showsalespersons();

                    // Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showsalespersons",
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


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end



        //Stop:Download Daily Reports List
        function printMainReport() {
            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();



            $("#comboCustomersInReport").hide();
            $("#comboSalesInReport").hide();
            $("#txtSearchFromDate").hide();
            $("#txtSearchToDate").hide();
            $("#lblresultpage").hide();
            $("#txtpageno").hide();
            $("#btnreset").hide();
            $("#btnsearch").hide();
            $("#lblTotalRecords").hide();
            $("#lblrecords").hide();
            $("#tdSearchReportBtn").hide();
            $("#tdSelectBranch").hide();
            $("#tdDateRange").hide();
            $("#spanpageno").hide();
            // $("#lbPrintReportType").html(searchtype);
            $("#tdReportType").hide();

            $("#divfrmdte").hide();
            $("#divtodate").hide();
            $("#divshwCustmr").hide();
            $("#divshowSles").hide();
            $("#divshwBranch").hide();
            $("#divcustSearch").hide();
            $("#comboBranchesInReport").hide();
            $("#lblTotalRecords").show();
            $("#lblrecords").show();
            $("#lbResultperpage").show();
            $("#divReportContent").print();
            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
            $("#tdSearchReportBtn").show();
            $("#tdSelectBranch").show();
            $("#tdDateRange").show();
            $("#lbResultperpage").hide();
            $("#spanpageno").show();
            $("#tdReportType").show();
            $("#tdPrintReportType").hide();

            $("#divfrmdte").show();
            $("#divtodate").show();
            $("#divshwCustmr").show();
            $("#divshwBranch").show();
            $("#divshowSles").show();
            $("#divcustSearch").show();

            $("#comboCustomersInReport").show();
            $("#comboSalesInReport").show();
            $("#txtSearchFromDate").show();
            $("#txtSearchToDate").show();
            $("#lblresultpage").show();
            $("#txtpageno").show();
            $("#btnreset").show();
            $("#btnsearch").show();

            $("#comboBranchesInReport").show();

        }




        //search customers: show in popup
        function resetcustomerdata() {
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            searchcustomerdata(1);
        }

        function searchcustomerdata(page) {
            var filters = {};
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.custname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.custid = $("#searchposContent1").val();
            }

            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/searchcustomerdata",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tableCustList tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
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
                            htm += " onclick=javascript:selectOrderCustomer('" + row.cust_id + "','" + row.cust_name.replace(/\s/g, '&nbsp;') + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.custid, row.cust_id.toString()) + "</td><td>" + getHighlightedValue(filters.custname, row.cust_name) + "</td><td>" + row.cust_amount + "</td></tr>";

                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        //   alert(htm);
                        $('#tableCustList tbody').html(htm);
                        $("#popupcustomers").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchcustomerdata"));


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

        function selectOrderCustomer(id, name) {
            custid = id;
            $("#customerNames").val(name);
            popupclose('popupcustomers');
        }

        function getOutstandingBills(page) {
            var postObj = {
                page: page,
                perpage: $("#txtpageno").val(),
                filters: {
                }
            }
            if ($("#comboBranchesInReport").val() && $("#comboBranchesInReport").val() != "0" && $("#comboBranchesInReport").val() != "") {
                postObj.filters.branch_id = $("#comboBranchesInReport").val();
            }
            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.user_id = $("#comboSalesInReport").val();
            }
            if (!isNaN($("#txtCreditAmount").val())) {
                postObj.filters.credit_amount = $("#txtCreditAmount").val();
            }
            if (!isNaN($("#txtCreditPeriod").val())) {
                postObj.filters.credit_period = $("#txtCreditPeriod").val();
            }
            if (custid != 0) {
                postObj.filters.cust_id = custid;
            }
            if ($("#chkSkipLastOrder").is(":checked")) {
                postObj.filters.skipLastOrder = true;
            }
            $.ajax({
                type: "POST",
                url: "CustomerOutstandingReport.aspx/getOutstandingBills",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var response = JSON.parse(msg.d);
                    console.log("response"+response);
                    $("#lblTotalRecords").text(response.count);
                    $("#lblNetOtstanding").text(response.net_outstanding_amount);
                    $("#tblOutstandingBills tbody").html("");
                    var startIndex = (postObj.page - 1) * postObj.perpage;
                    $.each(response.customers, function (i, customer) {
                        startIndex += 1;
                        var htm = '<tr style="background-color:#f9f9f9">';
                        htm += '<td colspan="7">';
                        htm += '<div>';
                        htm += startIndex + '&nbsp&nbsp&nbsp';
                        htm += '<span><a href="/managecustomers.aspx?cusId=' + customer.cust_id + '" style="text-decoration:underline">#' + customer.cust_id + '</a> ' + customer.cust_name + '</span>';
                        htm += '<span class="pull-right">Total outstanding: ' + customer.total_outstanding + ' </span>';
                        htm += '<br/>';
                        htm += '&nbsp&nbsp&nbsp<span class="">' + customer.address + ',' + customer.city + '</span>';
                        htm += '<span class="pull-right">Salesman: ' + customer.salesman + '</span>';
                        htm += '</div>'
                        htm += '</td>';
                        htm += '</tr>';
                        $("#tblOutstandingBills tbody").append(htm);
                        $.each(customer.orders, function (j, order) {
                            htm = "<tr>";
                            htm += '<td>' + startIndex + '.' + (j + 1) + '</td>';
                            htm += '<td><a href="/sales/manageorders.aspx?orderId=' + order.sm_id + '" style="text-decoration:underline">#' + order.sm_id + '</a></td>';
                            htm += '<td>' + order.date + '</td>';
                            htm += '<td>' + order.credit_period + '</td>';
                            htm += '<td>' + order.net_amt + '</td>';
                            htm += '<td>' + order.paid_amt + '</td>';
                            htm += '<td>' + order.balance_amt + '</td>';
                            htm += "</tr>";
                            $("#tblOutstandingBills tbody").append(htm);
                        });
                    });
                    $("#paginatediv").html(paginate(response.count, postObj.perpage, postObj.page, "getOutstandingBills"));
                },
                error: function (xhr, status) {
                    //Unloading();
                    console.log(xhr);
                    console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });
        }

        function reset() {
            $("#comboBranchesInReport").val($.cookie("invntrystaffBranchId"));
            $("#comboSalesInReport").val($("#comboSalesInReport option:first").val());
            $("#txtCreditAmount").val("");
            $("#txtCreditPeriod").val("");
            custid = 0;
            $("#customerNames").val("");
            getOutstandingBills(1);
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
                            <label style="font-weight: bold; font-size: 16px;">Customer Outstanding Bill Report(Only Delivered Bills)</label>

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

                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="divshwBranch" style="display:none;">
                                                    <div id="showBranchesDiv">
                                                        <select id="comboBranchesInReport" style="text-indent: 25px;" class="form-control" onchange="javascript:getOutstandingBills(1);">
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="divshowSles">
                                                    <div id="showsalesmansInReport">
                                                        <select id="comboSalesInReport" style="text-indent: 25px;" class="form-control" onchange="javascript:getOutstandingBills(1);">
                                                            <option value="0">--Sales Person--</option>
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                                </div>

                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                                    <input type="number" placeholder="Credit period" id="txtCreditPeriod" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                    <input type="number" placeholder="Credit amount" id="txtCreditAmount" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-money form-control-feedback left"></span>
                                                </div>
                                                <div id="divcustSearch">
                                                    <div class="col-md-4 col-sm-6 col-xs-10 form-group has-feedback" style="padding-right: 0px;">
                                                        <input class="form-control has-feedback-left" placeholder="Search Customers" id="customerNames" style="padding-right: 2px;" />
                                                        <span aria-hidden="true" class="fa fa-search form-control-feedback left"></span>
                                                        
                                                    </div>
                                                    <div class="col-md-1 col-sm-6 col-xs-2 form-group has-feedback" style="padding-left: 0px; padding-right: 0px;">
                                                        <div onclick="javascript:resetcustomerdata(1);" title="Search Customers" data-toggle="modal" style="font-size: 24px; margin-left: 5px;">
                                                            <label style="cursor: pointer;" class="fa fa-user"></label>
                                                            <label style="cursor: pointer; font-size: 20px; color: #ff6a00; position: relative; margin-left: -12px;" class="fa fa-search"></label>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-4 col-sm-6 col-xs-6">
                                                    <input type="checkbox" id="chkSkipLastOrder" onchange="javascript:getOutstandingBills(1);" />
                                                    <label for="chkSkipLastOrder">Skip customer's last outstanding bill</label>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                    <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:reset();">
                                                        <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                        Reset 
                                                    </button>

                                                    <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:getOutstandingBills(1);">
                                                        <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                        Search 
                                                    </button>

                                                </div>
                                            </div>

                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding: 15px;">
                                                <div class="col-md-4 col-sm-6 col-xs-6 form-group" style="">
                                                    <label id="lblrecords" style="font-weight: bold; font-size: 11px;">Customer count:</label>
                                                    <label id="lblTotalRecords">0</label>
                                                </div>
                                                <div class="col-md-4 col-sm-6 col-xs-6 form-group" style="">
                                                    <label id="Label1" style="font-weight: bold; font-size: 11px;">Net outstanding amount:</label>
                                                    <label id="lblNetOtstanding">0</label>
                                                </div>
                                                <div class="col-sm-2 invoice-col">
                                                    <label id="lblresultpage" style="font-weight: bold; font-size: 11px;">Per Page</label>
                                                    <select class="input-sm" style="text-indent: 0; padding: 5px; height: 28px;" id="txtpageno" onchange="javascript:getOutstandingBills(1);">
                                                        <option value="10">10</option>
                                                        <option value="25">25</option>
                                                        <option value="50">50</option>
                                                        <option value="100">100</option>
                                                        <option value="500">500</option>
                                                    </select>

                                                </div>
                                                <div class="col-sm-2 invoice-col">

                                                    <div id="tdPrintBtn" class="form-group" style="" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">
                                                <div class="x_content" style="padding-left: 0px; padding-right: 0px;">
                                                    <table class="table" style="table-layout: auto;" id="tblOutstandingBills">
                                                        <thead>
                                                            <tr>
                                                                <th>Sl No.</th>
                                                                <th>Order No</th>
                                                                <th>Date</th>
                                                                <th>Credit period</th>
                                                                <th>Net.Amt</th>
                                                                <th>Paid</th>
                                                                <th>Balance</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <tr style="background-color: #f9f9f9">
                                                                <td colspan="6">
                                                                    <span>#1234 customer name</span>
                                                                    <span class="pull-right">Total outstanding: 3000 </span>
                                                                </td>
                                                            </tr>

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
                        <%--start popup for customers --%>
                        <div class="container">


                            <div class="modal fade" id="popupcustomers" role="dialog">
                                <div class="modal-dialog modal-md" style="">

                                    <!-- Modal content-->
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupcustomers');">&times;</button>
                                            <div class="col-md-5 col-sm-6 col-xs-6">
                                                <h4 class="modal-title">Customers<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords"></span></h4>
                                            </div>
                                            <div class="col-md-6 col-sm-4 col-xs-12">

                                                <div class="col-md-4 col-sm-12 col-xs-3">
                                                    <select id="txtpospageno" onchange="javascript:searchcustomerdata(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                        <option value="25">25</option>
                                                        <option value="50">50</option>
                                                        <option value="100">100</option>
                                                        <option value="200">200</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-8 col-sm-12 col-xs-12">
                                                    <div class="" onclick="javascript:searchcustomerdata(1);">
                                                        <button type="button" class="btn btn-success mybtnstyl">
                                                            <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                            Search
                                                        </button>
                                                    </div>
                                                    <div class="" onclick="javascript:resetcustomerdata();">
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

                                                <table id="tableCustList" class="table table-striped table-bordered" style="table-layout: auto;">
                                                    <thead>
                                                        <tr>
                                                            <th>Cust Id</th>
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
                        <div class="clearfix"></div>

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
