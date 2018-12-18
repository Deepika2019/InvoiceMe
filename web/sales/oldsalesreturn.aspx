<%@ Page Language="C#" AutoEventWireup="true" CodeFile="oldsalesreturn.aspx.cs" Inherits="sales_oldsalesreturn" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Credit Note | Invoice Me</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery.js"></script>
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



    <script type="text/javascript" src="../js/jquery.corner.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <%--    <!--date picker-->
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />--%>



    <script type="text/javascript">
        var sessionId = 0;
        $(document).ready(function () {
            sessionId = getSessionID();
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            if (!CountryId) {
                location.href = "../dashboard.aspx";
                return false;
            }

            // showProfileHeader(1);
            clearform();
            showWarehouses();
            var customerid = getQueryString("customerid");
            if (getQueryString("customerid") != undefined && getQueryString("customerid") != "") {
                selectCustomer(customerid);
            }

            else {
                window.location.href = "../Customers.aspx";
            }
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#txtChequeDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'yy-mm-dd'
                // dateFormat: 'dd-MM-yy'
            });

            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");


        });

        //start create session Id
        function getSessionID() {

            var now = new Date();
            var year = now.getFullYear();
            var month = now.getMonth() + 1;
            var day = now.getDate();
            var hour = now.getHours();
            var minute = now.getMinutes();
            var second = now.getSeconds();
            if (month.toString().length == 1) {
                var month = '0' + month;
            }
            if (day.toString().length == 1) {
                var day = '0' + day;
            }
            if (hour.toString().length == 1) {
                var hour = '0' + hour;
            }
            if (minute.toString().length == 1) {
                var minute = '0' + minute;
            }
            if (second.toString().length == 1) {
                var second = '0' + second;
            }

            var salesman_id = $.cookie("invntrystaffBranchId");

            sessionId = String(year) + String(month) + String(day) + String(hour) + String(minute) + String(second) + String(salesman_id);
            return sessionId;
            //alert(sessionId);
        }
        //end create session Id
        function showWarehouses() {
            loading();
            $.ajax({
                type: "POST",
                url: "oldsalesreturn.aspx/warehouseName",
                data: "{'branchid':'" + $.cookie("invntrystaffBranchId") + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj[0]["branch_name"]);
                    $("#lblbranchname").text(obj[0]["branch_name"]);

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function selectCustomer(customerId) {
            console.log(customerId);
            loading();

            $.ajax({
                type: "POST",
                url: "oldsalesreturn.aspx/selectCustomerdata",
                data: "{'customerid':" + customerId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);
                        console.log(obj[0].cust_name);
                        $("#dupMemberId").text(customerId);
                        $("#txtMemberId").text(customerId);
                        $("#txtMemberName").text(obj[0].cust_name);

                        $("#customerType").val(obj[0].cust_type);
                        console.log(obj[0].cust_amount);
                   
                        if (obj[0].cust_amount == null || obj[0].cust_amount == "") {
                            obj[0].cust_amount = 0;
                        }
                        $("#txtoutstanding").text(obj[0].cust_amount);
                        if (obj[0].cust_amount > 0) {
                            $("#txtoutstanding").css("color", "red");
                            exactwalletamt = 0;
                        } else {
                            $("#txtoutstanding").css("color", "green");
                        }

                        $("#selcustomertype").val(obj[0].new_custtype);
                        if (obj[0].cust_type == 1) {
                            $("#txtcustomertype").text("A");
                        } else if (obj[0].cust_type == 2) {
                            $("#txtcustomertype").text("B");
                        } else if (obj[0].cust_type == 3) {
                            $("#txtcustomertype").text("C");
                        }
                        $("#txtcreditamount").text(obj[0].max_creditamt);
                        $("#txtcreditperiod").text(obj[0].max_creditperiod);
                       
                        $("#txtnewcreditamt").val(obj[0].new_creditamt);
                        $("#txtnewcreditperiod").val(obj[0].new_creditperiod);
                    } else {
                        alert("No data found");
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

        function saveOldReturnDetails() {
            var cash_amount = "";
            var chequeamount = "";
            var cheque_bank = "";
            var cheque_number = "";
            var cheque_date = "";
            var payment = 0;
            if ($("#txtreturnamt").val() == "") {
                alert("Enter Return Amount");
                $("#txtreturnamt").focus();
                return false;
            }
            if (isNaN($("#txtreturnamt").val())) {
                alert("Return amount should be in number only...!");
                return false;
            }
            //start cheque section validation
            if ($("#selPaymentType").val() == 2) {
                if ($('#txtChequeNo').val() == "") {
                    alert("Enter Cheque No");
                    return;
                }
                else if ($('#txtChequeDate').val() == "") {
                    alert("Enter Cheque Date");
                    return;
                }
                else if ($('#txtChequeBank').val() == "") {
                    alert("Enter Bank Name");
                    return;
                }
            }
            //end cheque section validation

            if ($("#selPaymentType").val() == "1") {

                cash_amount = parseFloat($("#txtreturnamt").val());
                chequeamount = 0;
                cheque_bank = 0;
                cheque_number = 0;
                cheque_date = 0;
            }
            else if ($("#selPaymentType").val() == "2") {

                cash_amount = 0;
                chequeamount = parseFloat($("#txtreturnamt").val());
                cheque_bank = $("#txtChequeBank").val();
                cheque_number = $("#txtChequeNo").val();
                cheque_date = $("#txtChequeDate").val();

            }
            if ($("#txtspecialnote").val() == "") {
                alert("Enter Remarks");
                $("#txtspecialnote").focus();
                return false;
            }

            payment = cash_amount + chequeamount;
            var narration = "" + $("#txtreturnamt").val() + " given to customer : Note:" + $("#txtspecialnote").val();
            var postObj = {

                data: {

                    cust_id: $("#txtMemberId").text(),
                    user_id: $.cookie("invntrystaffId"),
                    branch_id: $.cookie("invntrystaffBranchId"),
                    cash_amt: cash_amount,
                    cheque_amt: chequeamount,
                    cheque_no: cheque_number,
                    cheque_date: cheque_date,
                    cheque_bank: cheque_bank,
                    narration: $("#txtspecialnote").val(),
                    time_zone: $.cookie("invntryTimeZone"),
                    payment: payment,
                    session_id: sessionId,
                }
            };
            //alert("1");
            //alert({ 'cust_id': '" + $("#txtMemberId").text() + "', amount: '" + $("#txtreturnamt").val() + "', description: '" + $("#txtspecialnote").val() + "', user_id: '" + userid + "', timezone: '" + TimeZone + "', order_id: '" + order_id + "', is_debit: '" + is_debit + "', wallet_action: '" + wallet_action + "' })
            //     var specialnote = $("#txtspecialnote").val();
            $.ajax({
                type: "POST",
                url: "oldsalesreturn.aspx/insertWalletHistory",
                data: JSON.stringify(postObj),
                //data: "{'cust_id':'" + $("#txtMemberId").text() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //  alert(msg.d);
                    if (msg.d == "N") {
                        alert("error");
                        //alert("No search Results");
                        // $("#searchTitle").show();
                    } else {
                        alert("Saved successfully");
                        window.location.href = "../managecustomers.aspx?cusId=" + $("#txtMemberId").text();
                        clearform();
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
            //alert("");
        }

        function clearform() {
            $("#selPaymentType").val(1);
            $("#divChequeDetails").hide();
            $("#txtreturnamt").val("");
            $("#txtspecialnote").val("");
        }

        function fnChangeType() {
            if ($("#selPaymentType").val() == 1) {
                $("#divChequeDetails").hide();
            } else {
                $("#divChequeDetails").show();
            }
        }
    </script>

    <%-- <style type="text/css">
        /*for pagination start here*/

        #loading1 {
            width: 100%;
            height: 100%;
            top: 0px;
            left: 0px;
            position: fixed;
            display: block;
            opacity: 0.7;
            background-color: #fff;
            z-index: 99;
            text-align: center;
        }

        #loading-image1 {
            margin-top: 230px;
        }
    </style>
    <style type="text/css">
        .headbtn {
            background: url(../images/headbtn.png);
            border: 1px solid #707070;
            width: 140px;
            height: 20px;
            /*position:absolute; */
            margin-top: -20px;
        }

        .headbtnfont {
            width: 140px;
            height: 27px;
            text-align: center;
            color: #252525;
            line-height: 18px;
            font-size: 12px;
            font-weight: bold;
        }

        .blink {
            animation: blink-animation 1s steps(5, start) infinite;
            -webkit-animation: blink-animation 1s steps(5, start) infinite;
        }

        @keyframes blink-animation {
            to {
                visibility: hidden;
            }
        }

        @-webkit-keyframes blink-animation {
            to {
                visibility: hidden;
            }
        }

        .error {
            border: solid 2px #FF0000;
        }

        input[type=search] {
            background: none;
            font-weight: bold;
            border-color: #aaaaaa;
            border-style: solid;
            border-width: 1px;
            outline: none;
            padding: 1px 2px 1px 2px;
            width: 50px;
        }

        /*ul.ui-autocomplete {
            color: black !important;
            -moz-border-radius: 15px;
            border-radius: 15px;
        }*/

        /*tooltip style*/
        .autoSugest {
            background: #fffdef;
            border: 1px solid #cac6ad;
            -webkit-border-radius: 4px;
            -moz-border-radius: 4px;
            border-radius: 4px;
            color: #7f7943;
            display: none;
            font-size: 12px;
            padding: 7px 15px;
            position: absolute;
            min-width: 100px;
            -o-box-sizing: border-box;
            -ms-box-sizing: border-box;
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box;
        }

            .autoSugest:after {
                content: "";
                border-left: solid 10px transparent;
                border-right: solid 10px transparent;
                border-bottom: solid 10px #cac6ad;
                position: absolute;
                top: -11px;
                left: 12px;
            }
    </style>--%>
</head>

<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">

                    <div class="navbar nav_title" style="border: 0;">
                        <a href="../index.html" class="site_title"><i class="fa fa-file-text"></i><span>Invoice Me</span></a>
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
                            <label style="font-weight: bold; font-size: 16px;">Credit Note</label>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">

                <div class="page-title">

                    <%--<div class="title_left">
                        <label style="font-size: 16px; font-weight: bold;">Old Sales Return</label>
                    </div>--%>
                    <div class="title_right" style="text-align: right; float: right">
                        <label>Warehouse:</label>
                        <label id="lblbranchname">Kerala</label>
                    </div>

                </div>
                <div class="clearfix"></div>

                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">
                        <div class="x_panel">
                            <div class="x_title" style="margin-bottom: 0px;">
                                <label class="pull-left">Customer Details </label>

                                <%--<ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>

                                        </li>
                                        <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>
                                    </ul>--%>

                                <div class="clearfix"></div>
                            </div>
                            <div class="x_content">
                                <!-- info row -->
                                <div class="row invoice-info">
                                    <div class="col-sm-4 invoice-col">
                                        <b>ID:
                                                <label id="dupMemberId" style="display: none;"></label>
                                            <label id="txtMemberId">#007612</label>
                                        </b>
                                        <br />
                                        <b>Name:</b><label id="txtMemberName">Istanbul Supermarket Ajman</label>

                                    </div>
                                    <!-- /.col -->
                                    <div class="col-sm-2 invoice-col">
                                        <b>Credit Amount</b>
                                        <label id="txtcreditamount">1000</label>
                                        <br />
                                        <%--<b>Wallet Amount:</b><label id="lblwalletamt" style="color: #40c863;">0</label>--%>
                                    </div>
                                    <!-- /.col -->

                                    <div class="col-sm-2 invoice-col">
                                        <b>Credit Period:</b>
                                        <label id="txtcreditperiod">50 Days</label>
                                        <br />
                                        <b>Account Balance:</b><label id="txtoutstanding" style="color: #432727; font-size: 14px; font-weight: bold; color: red;">0</label>
                                    </div>
                                    <!-- /.col -->
                                    <div class="col-sm-2 invoice-col">
                                        <b>Class:</b><label id="txtcustomertype"></label>

                                    </div>


                                    <!-- /.col -->
                                </div>
                                <!-- /.row -->
                            </div>
                            <div class="clear"></div>

                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="col-md-12 col-sm-12 col-xs-12">
                        <div class="x_panel">
                            <div class="x_title">
                                <label>Credit Details</label>
                                <ul class="nav navbar-right panel_toolbox">
                                    <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                    </li>
                                    <%--<li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>

                                        </li>--%>
                                    <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                </ul>
                                <div class="clearfix"></div>

                            </div>
                            <div class="x_content">
                                <form id="Form2" data-parsley-validate class="form-horizontal form-label-left">


                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Credit Amount <span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="text" id="txtreturnamt" required="required" class="form-control col-md-7 col-xs-12" />
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Payment Type <span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <select id="selPaymentType" class="form-control" style="padding-right: 2px;" onchange="fnChangeType()">
                                                <option value="1" selected="selected">Cash</option>
                                                <option value="2" selected="selected">Cheque</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div id="divChequeDetails" style="display:none;">
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Cheque No <span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtChequeNo" required="required" class="form-control col-md-7 col-xs-12" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Cheque Date <span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtChequeDate" required="required" class="form-control col-md-7 col-xs-12" />
                                            </div>
                                        </div>
                                         <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Cheque Bank <span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtChequeBank" required="required" class="form-control col-md-7 col-xs-12" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Special Note <span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <textarea id="txtspecialnote" class="form-control" rows="3" placeholder="" style="resize: none; margin: 0px -0.375px 0px 0px; width: 100%; height: 109px;"></textarea>
                                        </div>
                                    </div>
                                    <div class="col-md-8 col-sm-12 col-xs-12"></div>
                                    <div class="col-md-1 col-sm-12 col-xs-12">
                                        <button type="button" class="btn btn-primary mybtnstyl" onclick="saveOldReturnDetails();">
                                            Save
                                        </button>
                                    </div>
                                    <div class="col-md-4 col-sm-12 col-xs-12"></div>
                                </form>
                            </div>


                        </div>
                    </div>
                    <div class="clearfix"></div>

                </div>
            </div>
            <div class="clearfix"></div>
            <!-- /page content -->

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
