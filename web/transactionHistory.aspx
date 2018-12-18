<%@ Page Language="C#" AutoEventWireup="true" CodeFile="transactionHistory.aspx.cs" Inherits="transactionHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Transactions  | Invoice Me</title>
    <script src="js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="js/jquery.cookie.js"></script>
    <script src="js/pagination.js" type="text/javascript"></script>
    <link rel="stylesheet" href="mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        var BranchId;
        var transactionObj;
        var customerId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }
            customerId = getQueryString("customerid");
            if (customerId == undefined || customerId == "") {
                location.href = "customers.aspx";
                return false;
            }
            getcustomerDetails();
            searchTransactions(1);
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

        });

        function getcustomerDetails() {
            $.ajax({
                type: "POST",
                url: "transactionHistory.aspx/getcustomerDetails",
                data: "{'customer':" + customerId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //   console.log(msg.d);
                    customerData = JSON.parse(msg.d);
                    //console.log(customerData);
                    //console.log(customerData.data[0].cust_amount);
                    $("#lbloutstanding").text(customerData.data[0].cust_amount);
                    if (customerData.data[0].cust_amount > 0) {
                        $("#lbloutstanding").css("color", "red");
                    } else {
                        $("#lbloutstanding").css("color", "green");
                    }
                    if (customerData.data[0].cust_type == 1) {
                        classType = "A";
                    } else if (customerData.data[0].cust_type == 2) {
                        classType = "B";
                    } else if (customerData.data[0].cust_type == 3) {
                        classType = "C";
                    }
                    $("#txtClassType").text(classType);
                    var a = document.getElementById('hrefCustomer'); //or grab it by tagname etc
                    a.href = "../managecustomers.aspx?cusId=" + customerId;
                    $("#txtMemberName").text(customerData.data[0].cust_name);
                    $("#txtMemberId").text(customerId);

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function searchTransactions(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            var branchId = $.cookie("invntrystaffBranchId");
            // alert(branchId);
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }

            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                filters.to_date = $("#txtSearchToDate").val();
            }
            if (getQueryString("customerid") != undefined && getQueryString("customerid") != "") {
                filters.cus_id = getQueryString("customerid");
            }
            if ($("#selActionType").val() != -1) {
                filters.action = $("#selActionType").val();
            }
            loading();

            $.ajax({
                type: "POST",
                url: "transactionHistory.aspx/searchTransactions",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //   console.log(msg.d);
                    transactionObj = JSON.parse(msg.d);
                    var htm = "";
                    var html = "";
                    var classType = "";
                    $('#tblTransactions > tbody').html("");
                    if (transactionObj.count == 0) {
                        //htm += "</div></div><div class='cl' style='height:5px;'></div>";
                        htm += '<td colspan="4" style="text-align:center"></div></div><div class="cl" style="height:5px;"></div><label>Empty</label></td>';
                        $("#txttotalordercount").text(0);
                    }
                    $.each(transactionObj.data, function (i, row) {
                        $("#txttotalordercount").text(transactionObj.count);
                        htm += '<tr>';
                        htm += '<td>' + row.trans_date + '</td>';
                        htm += '<td>' + getHighlightedValue(filters.search, row.narration) + '</td>';
                        htm += '<td>' + getHighlightedValue(filters.search, row.user_name) + '</td>';
                        htm += '<td>' + (row.dr != 0 ? getHighlightedValue(filters.search, row.dr) + " Dr" : (row.cr != 0 ? getHighlightedValue(filters.search, row.cr) + " Cr" : 0)) + '</td>';


                        if (row.action_type == 1) {
                            console.log(row.action_ref_id);
                            htm += '<td>SALES #' + getHighlightedValue(filters.search, row.action_ref_id) + '</td>';
                        } else if (row.action_type == 3) {
                            htm += '<td>SALES_RETURN</td>';
                        } else if (row.action_type == 5) {
                            htm += '<td>WITHDRAWAL</td>';
                        } else if (row.action_type == 6) {
                            htm += '<td>DEPOSIT</td>';
                        } else if (row.action_type == 7) {
                            htm += '<td>DEBIT</td>';
                        }
                        htm += '<td>' + row.closing_balance + '</td>';
                        htm += '<td><div onclick="showTransactionDetails(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;"></li></div></td>';
                        htm += '</tr>';


                    });
                    //  alert(htm);
                    $('#tblTransactions > tbody').html(htm);
                    html += '<tr>';
                    html += '<td colspan="7">';
                    html += '<div  id="divPagination" style="text-align: center;">';
                    html += '</div>';
                    html += '</td>';
                    html += '</tr>';
                    $('#tblTransactions > tbody').append(html);
                    $('#divPagination').html(paginate(transactionObj.count, perpage, page, "searchTransactions"));

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function resetFilters() {
            window.location.href = "transactionHistory.aspx?customerid=" + customerId;
        }

        //showing transaction details
        function showTransactionDetails(trans_id) {
            var transaction = transactionObj.data.find(x=>x.id == trans_id);
            //  console.log(transaction)
            $("#lblTransRef").text(transaction.id);
            $("#transAmount").text((transaction.dr != 0 ? transaction.dr : transaction.cr));
            $("#transDate").text(transaction.date);
            $("#transType").text((transaction.dr != 0 ? "Debit" : "Credit"));
            $("#transUserName").text(transaction.user_name);
            $("#transNarration").text(transaction.narration);
            $("#cashAmt").text(transaction.cash_amt);
            $("#walletAmt").text(transaction.wallet_amt);
            $("#chequeAmt").text(transaction.cheque_amt);
            $("#chequeNo").text(transaction.cheque_no);
            $("#chequeDate").text(transaction.cheque_date);
            $("#chequeBank").text(transaction.cheque_bank);
            $("#popupTransaction").modal('show');
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
                                <label style="font-weight: bold; font-size: 16px;">Transactions</label>

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
                                        <strong>Customer Details</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <form class="form-horizontal form-label-left input_mask">

                                            <div class="col-sm-5">
                                                <b>Customer </b>

                                                <span style="font-weight: bold;">:</span>  <a style="text-decoration: underline" href="../managecustomers.aspx?cusId=312" id="hrefCustomer" target="_blank">#<span id="txtMemberId">312</span></a>&nbsp;<label id="txtMemberName">A M A Bakery</label>(class <span id="txtClassType">C</span>) 
                                            </div>
                                            <div class="col-sm-4">
                                                <b>Account Balance:</b>
                                                <span style="font-weight: bold;">:</span>
                                                <label id="lbloutstanding" style="font-weight: bold; font-size: 12px; color: rgb(255, 0, 0);">50.05</label>
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
                                                <select id="selActionType" class="form-control" style="text-indent: 25px;" onchange="searchTransactions(1);">
                                                    <option value="-1" selected="selected">--Action Type--</option>
                                                    <option value="1">SALES</option>
                                                    <option value="3">SALES RETURN</option>
                                                    <option value="5">WITHDRAWAL</option>
                                                    <option value="6">DEPOSIT</option>


                                                </select>
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
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:searchTransactions(1);">
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
                                            <label>Transactions</label><span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="txttotalordercount"></span>

                                        </div>
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <ul class="nav navbar-right panel_toolbox">

                                                <li>
                                                    <select id="slPerpage" onchange="javascript:searchTransactions(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
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
                                            <table id="tblTransactions" class="table table-striped table-bordered" style="table-layout: auto;">
                                                <thead>
                                                    <tr>

                                                        <th style="text-align: center;">Date</th>
                                                        <th style="text-align: center;">Narration</th>
                                                        <th style="text-align: center;">User</th>
                                                        <th style="text-align: center;">Amount</th>
                                                       
                                                        <th>Action</th>
                                                          <th style="text-align: center;">Closing Balance</th>
                                                        <th></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td colspan="5" style="text-align: center">
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





                                        </div>

                                    </div>

                                </div>

                            </div>


                        </div>

                        <div class="clearfix"></div>

                        <div class="modal fade" id="popupTransaction" role="dialog">
                            <div class="modal-dialog modal-md" style="">

                                <!-- Modal content-->
                                <div class="modal-content">
                                    <div class="modal-header" style="padding-bottom: 5px;">
                                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <h4 class="modal-title">Transaction #<span id="lblTransRef"></span></h4>
                                        </div>
                                    </div>
                                    <div class="x_content">
                                        <div class="col-md-6" style="margin-bottom: 10px;"><b>Amount :</b><span id="transAmount"></span></div>
                                        <div class="col-md-6" style="margin-bottom: 10px;"><b>Date :</b><span id="transDate"></span></div>
                                        <div class="col-md-6" style="margin-bottom: 10px;"><b>Type :</b><span id="transType"></span></div>
                                        <div class="col-md-6" style="margin-bottom: 10px;"><b>User :</b><span id="transUserName"></span></div>
                                        <div class="col-md-12"><b>Narration :</b><p id="transNarration" style="text-indent: 20px;"></p>
                                        </div>
                                        <div class="col-md-6" style="margin-bottom: 10px;">
                                            <b>Cash</b><br />
                                            <div style="margin-left: 10px;">Amount :<span id="cashAmt">0</span></div>
                                            <br />
                                            <b>Wallet</b><br />
                                            <div style="margin-left: 10px;">Amount :<span id="walletAmt">0</span></div>
                                        </div>
                                        <div class="col-md-6" style="margin-bottom: 10px;">
                                            <b>Cheque</b><br />
                                            <div style="margin-left: 10px;">
                                                Amount :<span id="chequeAmt">0</span><br />
                                                number :<span id="chequeNo"></span><br />
                                                Date :<span id="chequeDate"></span><br />
                                                Bank :<span id="chequeBank"></span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="clearfix"></div>
                                    <div class="ln_solid"></div>
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

    <!-- Bootstrap -->
    <script src="js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="js/bootstrap/nprogress.js"></script>
    <!-- iCheck -->
    <script src="js/bootstrap/icheck.min.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="js/bootstrap/custom.min.js"></script>
    <script src="js/bootbox.min.js"></script>

</body>
</html>
