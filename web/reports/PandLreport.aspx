<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PandLreport.aspx.cs" Inherits="reports_PandLreport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Transaction Report | Invoice Me</title>
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
        var actionTypes= <%=actiontype%>;
        var actionTypeobj ="";
        // console.log(actionTypes);
        $(document).ready(function () {            
            actionTypeobj = JSON.parse(JSON.stringify(actionTypes));
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            $("#txtSearchFromDate").val('');
            $("#txtSearchToDate").val('');
            // console.log(actionTypeobj[0].name);
            ShowUTCDate();
        });

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
        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtSearchFromDate").val(localdate);
            $("#txtSearchToDate").val(localdate);
            getActiontypes();
            //showDailyReports(1);
        }//end
        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];

        }//end
        function getActiontypes(){
            var htm="";
            htm="<option value='-1'>--Action Type--</option>";
            for(i=0;i<=actionTypeobj.length-1;i++){
                htm += '<option value="' + actionTypeobj[i].value + '">' + actionTypeobj[i].name + '</option>';
            }
            //  alert(htm);
            $("#selActionType").html(htm);
            showsalespersons();

        }

        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "PandLreport.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select User--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.first_name + '&nbsp' + row.last_name + '</option>';
                    });
                    $("#comboSalesInReport").html(htm);
                    showTransactions(1);
                    //showDailyReports(1);


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        function showTransactions(page){
            var postObj = {
                page: page,
                perpage: $("#txtpageno").val(),
                filters: {
                }
            }

            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }

            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.salesmanId = $("#comboSalesInReport").val();
            }
              
            if ($("#selDebitCredit").val() && $("#selDebitCredit").val() != "-1" && $("#selDebitCredit").val() != "") {
                postObj.filters.transactnStatus = $("#selDebitCredit").val();
            }
            if ($("#selActionType").val() && $("#selActionType").val() != "-1" && $("#selActionType").val() != "") {
                postObj.filters.actionType = $("#selActionType").val();
            }
            //if($("#txtSearch").val()!=""){
            //    postObj.filters.search=$("#txtSearch").val();
            //}
            $.ajax({
                type: "POST",
                url: "PandLreport.aspx/showTransactions",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    transactionObj = JSON.parse(msg.d);
                    var htm = "";
                    var html = "";
                    var classType = "";
                    $('#tblTransactions > tbody').html("");
                    if (transactionObj.count == 0) {
                        //htm += "</div></div><div class='cl' style='height:5px;'></div>";
                        htm += '<td colspan="7" style="text-align:center"></div></div><div class="cl" style="height:5px;"></div><label>Empty</label></td>';
                        $("#txttotalordercount").text(0);
                        $("#divsumry").hide();
                    }else{
                        $.each(transactionObj.data, function (i, row) {
                            $("#txttotalordercount").text(transactionObj.count);
                            htm += '<tr>';
                            htm += '<td># ' + row.transId + '</td>';
                            htm += '<td>' + row.trans_date + '</td>';
                            if (row.action_type == 1) {
                                console.log(row.action_ref_id);
                                htm += '<td>SALES #' +row.action_ref_id+ '</td>';
                            } else if (row.action_type == 3) {
                                htm += '<td>SALES_RETURN</td>';
                            } else if (row.action_type == 5) {
                                htm += '<td>WITHDRAWAL</td>';
                            } else if (row.action_type == 6) {
                                htm += '<td>CREDIT NOTE</td>';
                            }else if (row.action_type == 2) {
                                console.log(row.action_ref_id);
                                htm += '<td>PURCHASE #' + row.action_ref_id + '</td>';
                            }else if (row.action_type == 7) {
                                htm += '<td>DEBIT NOTE</td>';
                            }else if (row.action_type == 9) {
                                htm += '<td>INCOME</td>';
                            }else if (row.action_type ==10) {
                                htm += '<td>EXPENSE</td>';
                            }
                            if(row.cust_name==null){
                                row.cust_name="";
                            }
                            htm += '<td>' + row.cust_name + '</td>';
                            htm += '<td>' + row.narration + '</td>';
                            htm += '<td>' + row.user + '</td>';
                            htm += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                          
                      
                         
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
                        $("#divsumry").hide();
                        if (postObj.filters.from_date != "" && postObj.filters.to_date != "") {
                            $("#lblSummaryFromDate").text(postObj.filters.from_date);
                            $("#lblSummaryToDate").text(postObj.filters.to_date);
                            //  showSummaryReport();
                        }
                        $("#lblIncome").text(transactionObj.income);
                        $("#lblExpense").text(transactionObj.expense);
                        var difference=parseFloat(transactionObj.income-transactionObj.expense);
                        if(difference>=0){
                            $("#lblProfit").text(difference);
                            $("#lblLoss").text(0);
                        }else{
                            $("#lblLoss").text(-1*difference);
                            $("#lblProfit").text(0);
                        }
                        $('#divPagination').html(paginate(transactionObj.count, $("#txtpageno").val(), page, "showTransactions"));}
                   
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function resetFilter(){
            ShowUTCDate();
            $("#comboSalesInReport").val(0);
            $("#selActionType").val(-1);
            $("#selDebitCredit").val(-1);
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
                            <label style="font-weight: bold; font-size: 16px;">Transaction Report </label>

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

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divtodate">
                                                    <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback" id="divshowSles">
                                                    <div id="showsalesmansInReport">
                                                        <select id="comboSalesInReport" style="text-indent: 25px; padding-right: 5px;" class="form-control" onchange="javascript:showTransactions(1);">
                                                            <option>--Sales Person--</option>
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback" id="div1">
                                                    <div id="Div2">
                                                        <select id="selActionType" style="text-indent: 25px; padding-right: 5px;" class="form-control" onchange="javascript:showTransactions(1);">
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <div id="Div3">
                                                        <select id="selDebitCredit" style="text-indent: 25px; padding-right: 5px;" class="form-control" onchange="javascript:showTransactions(1);">
                                                            <option value="-1" selected="">All</option>
                                                            <option value="0">Credit</option>
                                                            <option value="1">Debit</option>

                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-clipboard form-control-feedback left"></span>
                                                </div>
                                                <%--<div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwCustmr">
                           <div id="showcustomersInReport">
							<select id="comboCustomersInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option>--Customer--</option>
											<option>Abu Dhabi</option>
											<option>Ajman</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
							  </div>--%>




                                                <%--<div id="divcustSearch">
                                                    <div class="col-md-5 col-sm-6 col-xs-10 form-group has-feedback" style="padding-right: 0px;" >
                                                    <input class="form-control has-feedback-left" placeholder="Search Customers" id="customerNames" style="padding-right: 2px;" />
                                                    <span aria-hidden="true" class="fa fa-search form-control-feedback left"></span>
                                                </div>
                                           
                                                </div>--%>

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                    <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:resetFilter();">
                                                        <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                        Reset 
                                                    </button>

                                                    <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showTransactions(1);">
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

                                                <div class="col-sm-5 invoice-col">


                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" style="cursor: pointer;" onclick="javascript:DownloadDailyReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Report</label>
                                                    </div>


                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="cursor: pointer;" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->




                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content">
                                                    <div class="fr" style="padding-left: 0px;">
                                                        <select class="input-sm  pull-right" style="text-indent: 0; padding: 5px; height: 28px;" id="txtpageno" onchange="javascript:showTransactions(1);">
                                                            <option value="25">25</option>
                                                            <option value="50">50</option>
                                                            <option value="100">100</option>
                                                            <option value="500">500</option>
                                                        </select>
                                                    </div>
                                                    <table id="tblTransactions" class="table table-striped table-bordered" style="table-layout: auto;">
                                                        <thead>

                                                            <tr>
                                                                <th style="text-align: center">TransID</th>
                                                                <th style="text-align: center;">Date</th>
                                                                <th style="text-align: center;">Action</th>
                                                                <th style="text-align: center;">Partner</th>
                                                                <th style="text-align: center;">Narration</th>
                                                                <th style="text-align: center;">User</th>
                                                                <th style="text-align: center;">Amount</th>

                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                        </tbody>
                                                    </table>





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
