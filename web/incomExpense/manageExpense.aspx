<%@ Page Language="C#" AutoEventWireup="true" CodeFile="manageExpense.aspx.cs" Inherits="manageExpense" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Manage Expense  | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script src="../js/pagination.js" type="text/javascript"></script>
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css"/>
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet"/>
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
        var exactwalletamt = 0;
        var purchaseId;
        var entryObj = "";
        var wareHouse=0;
        $(document).ready(function () {
            disablepayment();
            purchaseId = getQueryString('purchaseId');
          

            if (purchaseId == undefined) {
                location.href = "listExpenseEntries.aspx";
                return;
            }
            //console.log(location.search);
            var dt = new Date();
            var cur_dat = dt.getDate() + '-' + (dt.getMonth() + 1) + '-' + dt.getFullYear();


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
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");

            $('#popupChequeDate').scroller({
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


            //call to select order details
            retrieveExpenseDetail();
        });





        //start: Showing Details of selected Outsatnding Bill from Popup
        function retrieveExpenseDetail() {
           

            loading();

            $.ajax({
                type: "POST",
                url: "manageExpense.aspx/retrieveData",
                data: "{'expenseId':'" + purchaseId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    entryObj = JSON.parse(msg.d);
                    //console.log(entryObj);
                    var entry_details = entryObj.entry[0];
                    console.log(entry_details);
                    wareHouse=entry_details.branch_id;
                    $('#txtEntryRefNo').text(entry_details.ie_invoice_num);
                    $('#txtEntryDate').text(entry_details.date);
                    $("#txtPreviousPaid").text(entry_details.ie_total_paid);
                    
                    $("#txtPreviousBalance").text(entry_details.ie_total_balance);
                    
                    $("#txtTotalBalanceAmount").val(entry_details.ie_total_balance);
                    $("#txtTotalAmt").text(entry_details.total_amount);

                    $("#txtEntryRefNo").text(entry_details.ie_invoice_no);
                    $("#txtVendorName").text(entry_details.ext_user_name);
                    $("#txtVendorId").text(entry_details.ext_user_id);
                    $("#txtOrderDate").text(entry_details.date);
                    $("#txtTotalCurrentAmount").val('0');
                    $("#cbCashPayment").removeProp("checked");
                    $("#cbCardPayment").removeProp("checked");
                    //  $("#cbChequePayment").removeProp("checked");
                    $("#txtSpecialNote").val(entry_details.ie_note);
                    if (entry_details.ie_total_balance == 0) {
                        $("#txtBalance").text(entry_details.ie_total_balance);
                    }
                    else if (entry_details.ie_total_balance < 0) {
                        $("#txtBalance").text(entry_details.ie_total_balance+'(Cr)');
                        $("#txtBalance").css("color", "green");
                    } else {
                        $("#txtBalance").text(entry_details.ie_total_balance + '(Dr)');
                        $("#txtBalance").css("color", "red");
                    }
                    // showing order_items
                    $("#tbodyItems").html("");
                    $.each(entryObj.items, function (i, item) {
                        var htmItemRow = '';
                        htmItemRow += '<tr>';
                        //htmItemRow += '<td>' + item.itm_code + '</td>';
                        htmItemRow += '<td>' + item.ie_category + '</td>';
                        //htmItemRow += '<td>' + item.pi_price + '</td>';
                        //htmItemRow += '<td>' + item.pi_qty + '</td>';
                        htmItemRow += '<td>' + item.ie_total + '</td>';
                        htmItemRow += '<td>' + item.ie_discount_rate + '</td>';
                        htmItemRow += '<td>' + item.ie_discount_amt + '</td>';
                        htmItemRow += '<td>' + item.ie_tax + '</td>';
                        htmItemRow += '<td>' + item.ie_netamount + '</td>';
                        htmItemRow += '<td></td>';
                        htmItemRow += '<td style="border-right:none;"></td>';
                        htmItemRow += '</tr>';
                        $("#tbodyItems").append(htmItemRow);
                    });


                    // showing payment details
                    $("#tblPaymentDetails > tbody").html("");
                    $.each(entryObj.transaction_details, function (i, row) {

                        var htmPaymentDetails = '<tr>';
                        htmPaymentDetails += '<td>#' + row.id + '</td>';
                        htmPaymentDetails += '<td>' + row.date + '</td>';
                        //htmPaymentDetails += '<td>' + row.narration + '</td>';

                        //Added By Arshad--->(Payment Details with Narration)
                        if (row.cheque_amt > 0 && row.cash_amt > 0) { htmPaymentDetails += '<td>' + row.narration + '(' + row.cash_amt + ' By Cash,' + row.cheque_amt + ' By Cheque ' + row.cheque_no + ')' + '</td>'; }
                        else if (row.cheque_amt > 0) { htmPaymentDetails += '<td>' + row.narration + '(By Cheque ' + row.cheque_no + ')' + '</td>'; }
                        else if (row.cash_amt > 0) { htmPaymentDetails += '<td>' + row.narration + '(By Cash)' + '</td>'; }
                        else {
                            htmPaymentDetails += '<td>' + row.narration + '</td>';
                        }


                        htmPaymentDetails += '<td>' + row.user_name + '</td>';
                        htmPaymentDetails += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                        htmPaymentDetails += '<td><div onclick="showTransactionDetails(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;"></li></div></td>';
                        htmPaymentDetails += '</tr>';

                        $("#tblPaymentDetails > tbody").append(htmPaymentDetails);
                    });

                    if (parseFloat($("#txtPreviousBalance").text()) <= 0) {
                        disablepayment();
                    }
                   

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        // Stop: Showing Details of selected Outsatnding Bill from Popup

        //showing transaction details
        function showTransactionDetails(trans_id) {
            var transaction = entryObj.transaction_details.find(x=>x.id == trans_id);
            console.log(transaction)
            $("#lblTransRef").text(transaction.id);
          

            $("#transAmount").text((transaction.dr != 0 ? transaction.dr : transaction.cr));
            $("#transDate").text(transaction.date);
            $("#transDate").text(transaction.date);
            $("#transType").text((transaction.dr != 0 ? "Debit" : "Credit"));
            $("#transUserName").text(transaction.user_name);
            $("#transNarration").text(transaction.narration);
            //$("#cashAmt").text(transaction.cash_amt);
            $("#cashAmt").text(transaction.cash_amt);
            $("#walletAmt").text(transaction.wallet_amt);
            $("#chequeAmt").text(transaction.cheque_amt);
            if (transaction.cheque_no == null) { $("#chequeNo").text("xxxx") }
            else { $("#chequeNo").text(transaction.cheque_no); }
            if (transaction.cheque_date == null) { $("#chequeDate").text("xxxx") }
            else { $("#chequeDate").text(transaction.cheque_date); }
            if (transaction.cheque_bank == null) { $("#chequeBank").text("xxxx") }
            else { $("#chequeBank").text(transaction.cheque_bank); }
            $("#popupTransaction").modal('show');
        }

        //for disabling and enabling payment method textboxes
        function paymentMethod() {
           

            $("#cbCashPayment").prop("disabled", false);
            $("#walletPayment").prop("disabled", false);
            $("#cbCardPayment").prop("disabled", false);
            $("#cbChequePayment").prop("disabled", false);
            $("#divsaveorder").css('pointer-events', '');
            //$("#divprintorder").css('pointer-events', '');

            if ($("#cbCashPayment").is(':checked')) {
                $("#txtCashAmount").attr("disabled", false);
                if (isNaN($('#txtCashAmount').val())) {
                    alert("Enter a valid Cash Amount");
                    $('#txtCashAmount').val(0);
                }
            } else {
                $("#txtCashAmount").attr("disabled", "disabled");
                $("#txtCashAmount").val('');
            }
            if ($("#cbCardPayment").is(':checked')) {
                $("#txtCardAmount").attr("disabled", false);
                $("#txtCardNo").attr("disabled", false);
                $("#txtCardType").attr("disabled", false);
                $("#txtCardBank").attr("disabled", false);
                if (isNaN($('#txtCardAmount').val())) {
                    alert("Enter a valid Card Amount");
                    $('#txtCardAmount').val(0);
                }
            } else {
                $("#txtCardAmount").attr("disabled", "disabled");
                $("#txtCardNo").attr("disabled", "disabled");
                $("#txtCardType").attr("disabled", "disabled");
                $("#txtCardBank").attr("disabled", "disabled");
                $("#txtCardAmount").val('');
                $("#txtCardNo").val('');
                $("#txtCardType").val('');
                $("#txtCardBank").val('');
            }
            if ($("#cbChequePayment").is(':checked')) {

                $("#txtChequeAmount").attr("disabled", false);
                $("#txtChequeNo").attr("disabled", false);
                $("#txtChequeDate").attr("disabled", false);
                $("#txtBankName").attr("disabled", false);
                if (isNaN($('#txtChequeAmount').val())) {
                    alert("Enter a valid Cheque Amount");
                    $('#txtChequeAmount').val(0);
                }
            } else {
                $("#txtChequeAmount").attr("disabled", "disabled");
                $("#txtChequeNo").attr("disabled", "disabled");
                $("#txtChequeDate").attr("disabled", "disabled");
                $("#txtBankName").attr("disabled", "disabled");
                $("#txtChequeAmount").val('');
                $("#txtChequeNo").val('');
                $("#txtChequeDate").val('');
                $("#txtBankName").val('');
            }
            calculteFromPayMethod();
        }

        // calculating total and balance from payment method values
        function calculteFromPayMethod() {

            var cashAmount = $("#txtCashAmount").val();
           

            if (cashAmount == "") {
                cashAmount = 0;
            }
            var cardAmount = $("#txtCardAmount").val();
            if (cardAmount == "") {
                cardAmount = 0;
            }
            var chequeAmount = $("#txtChequeAmount").val();
            if (chequeAmount == "") {
                chequeAmount = 0;
            }
            var walletamt = 0;
            if ($("#walletPayment").is(':checked')) {
                walletamt = $("#textwalletamt").val();

            } else {
                walletamt = 0;
            }
            var cashTotal = parseFloat(cashAmount) + parseFloat(cardAmount) + parseFloat(chequeAmount) + parseFloat(walletamt);

            
            $('#txtTotalCurrentAmount').val(cashTotal.toFixed(2));

            var balance = parseFloat($('#txtPreviousBalance').text()) - parseFloat(cashTotal);
            
            $("#txtTotalBalanceAmount").val(balance.toFixed(2));
            //alert(parseFloat($('#txtBalance').text()));
            if ((parseFloat($('#txtBalance').text())<0)||parseFloat(cashAmount) + parseFloat(chequeAmount) > parseFloat(balanceAmt)) {
                
                alert("Payment Amount Exceeds Total Amount!...")
                $('#txtChequeAmount').val(0);
                $('#txtCashAmount').val(0);
                disablepayment();
                return;
            }

        }

        function saveToPurchaseMaster() {
            // alert(wareHouse);
            var filters = {};
            filters.TimeZone = $.cookie("invntryTimeZone");
            filters.purchaseId = purchaseId;
            filters.invoiceNum = $("#txtEntryRefNo").text();
            filters.vendorId = $("#txtVendorId").text();
            filters.currentPaidamt = $("#txtTotalCurrentAmount").val();
            filters.currentBalance = $("#txtTotalBalanceAmount").val();
            filters.previousPaid = $("#txtPreviousPaid").text();
            if (filters.currentPaidamt == "" || parseFloat(filters.currentPaidamt) == 0) {
                alert("Please Enter Paid Amount");
                return;
            }
            var paymentmode = '';
            if ($("#cbCashPayment").is(':checked')) {
                paymentmode = "Cash";
                if ($('#txtCashAmount').val() == "" || isNaN($('#txtCashAmount').val())) {
                    alert("Enter a valid Cash Amount");
                    return;
                }

            }
            if ($("#cbCardPayment").is(':checked')) {
                paymentmode = "Card";
                if ($('#txtCardAmount').val() == "" || isNaN($('#txtCardAmount').val())) {
                    alert("Enter a valid Card Amount");
                    return;
                } else if ($('#txtCardNo').val() == "") {
                    alert("Enter Card No");
                    return;
                } else if ($('#txtCardType').val() == "") {
                    alert("Enter Card Type");
                    return;
                } else if ($('#txtCardBank').val() == "") {
                    alert("Enter Card Bank");
                    return;
                }
            }
            if ($("#cbChequePayment").is(':checked')) {
                paymentmode = "Cheque";
                if ($('#txtChequeAmount').val() == "" || isNaN($('#txtChequeAmount').val())) {
                    alert("Enter a valid Cheque Amount");
                    return;
                } else if ($('#txtChequeNo').val() == "") {
                    alert("Enter Cheque No");
                    return;
                } else if ($('#txtChequeDate').val() == "") {
                    alert("Enter Cheque Date");
                    return;
                } else if ($('#txtBankName').val() == "") {
                    alert("Enter Bank Name");
                    return;
                }
            }
            if (paymentmode == '') {
                alert("Please Select your Payment Method");
                return;
            }

            filters.UserId = $.cookie('invntrystaffId');
            filters.SpecialNote = $("#txtSpecialNote").val();
            filters.BankName = $("#txtBankName").val();
            filters.ChequeDate = $("#txtChequeDate").val();
            

            filters.ChequeNo = $("#txtChequeNo").val();
            filters.ChequeAmount = $("#txtChequeAmount").val();
            filters.CashAmount = $("#txtCashAmount").val();
            if (filters.CashAmount == '') {
                filters.CashAmount = 0;
            }
            if (filters.ChequeAmount == '') {
                filters.ChequeAmount = 0;
            }
            var creditamount = 0;
          
            filters.branchId=wareHouse;

            console.log(creditamount);
       

            loading();
            $.ajax({
                type: "POST",
                url: "manageExpense.aspx/saveToPurchaseMaster",
                data: "{'filters':" + JSON.stringify(filters) + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();

                    if (msg.d == "N") {
                        alert("Error!.. Please Try Again...");
                        return;
                    } else {

                        alert("Updated Successfully...!");
                        location.href = "manageExpense.aspx?purchaseId=" + purchaseId + "";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function refreshpage() {
            selectOrders();
            //  window.location.reload();
        }


        function printbill() {
            location.href = "billreceipt.aspx?orderId=" + BillNo;
        }


        //function for disable payment section
        function disablepayment() {
            //$("#cbCashPayment").prop("disabled", true);
            $("#cbCashPayment").attr("checked", false);
            $("#walletPayment").prop("disabled", true);
            $("#walletPayment").attr("checked", false);
            $("#cbCardPayment").prop("disabled", true);
            $("#cbCardPayment").attr("checked", false);
            $("#cbChequePayment").prop("disabled", true);
            $("#cbChequePayment").attr("checked", false);
            $('#txtCashAmount').val('0');
            $("#textwalletamt").val('0');
            $('#txtCashAmount').prop("disabled", true);
            $('#txtCardAmount').val('0');
            $('#txtCardAmount').prop("disabled", true);
            $('#txtCardNo').val('');
            $('#txtCardNo').prop("disabled", true);
            $('#txtCardType').val('');
            $('#txtCardType').prop("disabled", true);
            $('#txtCardBank').val('');
            $('#txtCardBank').prop("disabled", true);
            $('#txtChequeAmount').val('0');
            $('#txtChequeAmount').prop("disabled", true);
            $('#txtChequeNo').val('');
            $('#txtChequeNo').prop("disabled", true);
            $('#txtChequeDate').val('');
            $('#txtChequeDate').prop("disabled", true);
            $('#txtBankName').val('');
            $('#txtBankName').prop("disabled", true);
            $("#divsaveorder").css('pointer-events', 'none');
        }


        function editExpense() {
            location.href = "../incomExpense/editExpense.aspx?purchaseId="+ purchaseId + "";
        }

        function updateTransaction()
        {
            var filters = {};
            totalAmt = parseFloat($('#cashAmt').val()) + parseFloat($('#chequeAmt').val());
            filters.totalAmt = totalAmt;
            filters.cashAmt = $('#cashAmt').val();
            filters.chequeAmt = $('#chequeAmt').val();
            filters.chequeNo = $('#chequeNo').val();
            filters.popupChequeDate = $('#popupChequeDate').val();
            filters.chequeBank = $('#chequeBank').val();
            filters.transId=$("#lblTransRef").text();
           

            loading();

            $.ajax({
                type: "POST",
                url: "manageExpense.aspx/updateTransaction",
                data: "{'filters':" + JSON.stringify(filters) + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();

                    if (msg.d == "N") {
                        alert("Error!.. Please Try Again...");
                        return;
                    } else {

                        alert("Updated Successfully...!");
                        location.href = "manageExpense.aspx?purchaseId=" + purchaseId + "";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
           

        }


    </script>
</head>

<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">
                    <div class="navbar nav_title" style="border: 0;">
                        <a href="#" class="site_title"><span>Invoice Me</span></a>
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
            <!-- top navigation -->
            <div class="top_nav">
                <div class="nav_menu">
                    <nav>

                        <div class="navbar-header" style="width: 100%; display: flex; align-items: center">
                            <div class="nav toggle" style="padding: 5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <label style="font-weight: bold; font-size: 16px;">Manage Expense</label>
                            <%--<div style="margin-left:5px;">
                                   <label class="glyphicon glyphicon-chevron-left" style="font-size:24px;  margin-left:20px;"></label>
                  <label class="fa fa-refresh pull-right" style="font-size:24px;"></label>
                                    </div>--%>
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%--<div class="page-title">
			
              <div class="title_left" style="width:100%;">
                <label style="font-size:16px; font-weight:bold;">Manage Order</label>
                   <label class="fa fa-backward pull-right" style="font-size:24px;  margin-left:20px;"></label>
                  <label class="fa fa-refresh pull-right" style="font-size:24px;"></label>
                 

              </div>

              
            </div>--%>

                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Basic Details</label>

                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>

                                </div>
                                <div class="x_content">
                                    <!-- info row -->
                                    <div class="row invoice-info">
                                        <div class="col-sm-2 invoice-col">
                                            <b>#<label id="txtEntryRefNo" style="font-size: 15px"></label>
                                            </b>

                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-2 invoice-col">

                                            <b><span title="City" class="fa fa-calendar"></span>
                                                <label id="txtEntryDate">24-Feb-2017</label></b>

                                        </div>
                                        <!-- /.col -->

                                        <div class="col-sm-4 invoice-col">
                                            <label id="txtVendorName">Istanbul Supermarket Ajman</label>
                                            <label id="txtVendorId" style="display:none;"></label>
                                        </div>
                                          <div class="col-sm-2 invoice-col">
                                            <label id="Label1">Balance To Pay:</label>
                                            <label id="txtBalance" style=";">0</label>
                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-2 invoice-col">
                                            <button class="btn btn-success btn-xs" onclick="editExpense()" style="display:;" id="btnEdit">
                                                <li class="fa fa-pencil"></li>
                                                Edit</button>
                                        </div>


                                        <!-- /.col -->
                                    </div>
                                    <!-- /.row -->
                                </div>
                                <div class="clear"></div>


                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title">
                                    <label>Item Details</label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>
                                </div>


                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="tblOrderItems" class="table table-striped table-bordered" style="table-layout:fixed;">
                                            <thead>
                                                <tr>
                                                    <%--<td>Item Code</td>--%>
                                                    <td style="width: 300px;">Name</td>
                                                   <%-- <td>Price</td>--%>
                                                   <%-- <td>QTY</td>--%>
                                                    <td>Amt</td>
                                                    <td>Dis %</td>
                                                    <td>Dis Amt</td>
                                                    <td>Tax Amt</td>
                                                    <td>Net Amt</td>
                                                    <td>Paid</td>
                                                    <td style="width: 150px;">Balance To Pay</td>


                                                </tr>
                                            </thead>


                                            <tbody id="tbodyItems">
                                                <tr>
                                                    <td>0021</td>
                                                    <td>UAE</td>
                                                    <td>1000</td>
                                                    <td>5</td>
                                                    <td>45</td>
                                                    <td>5</td>
                                                    <td>5</td>
                                                    <td>45</td>
                                                    <td>5</td>
                                                    <td>5</td>


                                                </tr>
                                            </tbody>
                                            <tbody id="tbodyPayments">


                                                <tr>
                                                    <td colspan="5" style="text-align: right;"><b>Total</b></td>

                                                    <td>
                                                        <label id="txtTotalAmt">0</label></td>
                                                    <td>
                                                        <label id="">--</label></td>
                                                    <td>
                                                        <label id="Label2">--</label></td>

                                                </tr>
                                                <tr>
                                                    <td colspan="6" style="text-align: right;"><b>Previous Payment</b></td>

                                                    <td style="font-weight: bold;">
                                                        <label id="txtPreviousPaid"></label>
                                                    </td>
                                                    <td style="font-weight: bold;">
                                                        <label id="txtPreviousBalance"></label>
                                                    </td>

                                                </tr>
                                                <tr>
                                                    <td colspan="6" style="text-align: right;"><b>Current Payment</b></td>
                                                    <td style="color: red; font-weight: bold;">
                                                        <input style="width: 97%; background: none; border: none;" id="txtTotalCurrentAmount" value="0" disabled="" type="text" /></td>
                                                    <td style="color: red; font-weight: bold;">
                                                        <input style="width: 97%; background: none; border: none;" id="txtTotalBalanceAmount" value="0.00" disabled="" type="text" /></td>
                                                </tr>
                                            </tbody>



                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <%-- Cas,Card,Cheque start--%>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel" style="background: #eeeeee;">
                                <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                                    <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                            <div class="checkbox">
                                                <label style="font-size: 1.3em">
                                                    <input type="checkbox" value="" id="cbCashPayment" onclick="javascript: paymentMethod();">
                                                    <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                </label>
                                            </div>
                                            <%--                                            <input type="checkbox"   class="flat" />--%>
                                        </div>

                                        <div class="col-md-4 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>CASH</b> </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12">CashAmt</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCashAmount" class="form-control" style="height: 25px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" value="0" />
                                        </div>
                                        <div class="clearfix"></div>

                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px;display:none;">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                            <div class="checkbox">
                                                <label style="font-size: 1.3em">
                                                    <input type="checkbox" value="" id="cbCardPayment" onclick="javascript: paymentMethod();">
                                                    <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                </label>
                                            </div>

                                        </div>
                                        <div class="col-md-4 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>CARD</b> </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Card Amt</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCardAmount" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" value="0" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Card No</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCardNo" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter No" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Card Type</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCardType" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Type" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Bank</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCardBank" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bank" />
                                        </div>
                                        <div class="clearfix"></div>
                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                            <div class="checkbox">
                                                <label style="font-size: 1.3em">
                                                    <input type="checkbox" value="" id="cbChequePayment" onclick="javascript: paymentMethod();">
                                                    <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                </label>
                                            </div>

                                        </div>
                                        <div class="col-md-4 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>CHEQUE</b> </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Cheque Amt.</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeAmount" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Cheque No.</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeNo" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter No." />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Date</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeDate" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Date" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12">Bank</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12">
                                            <input type="text" id="txtBankName" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bank" />
                                        </div>
                                        <div class="clearfix"></div>
                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px">

                                        <div class="col-md-8 col-sm-6 col-xs-12"><b>Special Notes</b> </div>
                                        <div class="clearfix"></div>

                                        <div class="col-md-12 col-sm-12 col-xs-12">
                                            <textarea id="txtSpecialNote" class="form-control" style="resize: none;"></textarea>
                                        </div>
                                        <div class="clearfix"></div>

                                        <div class="col-md-3 col-sm-3 col-xs-3" style="margin-top: 10px;" id="divsaveorder" onclick="javascript:saveToPurchaseMaster();">
                                            <button class="btn btn-primary" type="button">Update</button>
                                        </div>


                                        <div class="clearfix"></div>

                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                    <%-- Cas,Card,Cheque End--%>

                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title">
                                    <label>Transaction History</label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>
                                </div>


                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="tblPaymentDetails" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <th>Ref.</th>
                                                    <th>Date</th>
                                                    <th>Narration</th>
                                                    <th>Entry By</th>
                                                    <th>Amount</th>
                                                    <th></th>
                                                </tr>
                                            </thead>


                                            <tbody>
                                                <tr>
                                                    <td>0021</td>
                                                    <td>UAE</td>
                                                    <td>1000</td>
                                                    <td>545</td>
                                                    <td>454</td>
                                                    <td>5</td>
                                                    <td>45</td>
                                                    <td>5</td>
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
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Amount :</b><span id="transAmount"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Date :</b><span id="transDate"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Type :</b><span id="transType"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>User :</b><span id="transUserName"></span></div>
                                    <div class="col-md-12"><b>Narration :</b><p id="transNarration" style="text-indent:20px;"></p></div>
                                    <div class="col-md-6" style="margin-bottom:10px;">
                                        <b>Cash</b><br />
                                        <div style="margin-left:10px;">Amount :<span id="cashAmt">0</span></div><br />
                                        <b>Wallet</b><br />
                                        <div style="margin-left:10px;">Amount :<span id="walletAmt">0</span></div>
                                    </div>
                                    <div class="col-md-6" style="margin-bottom:10px;">
                                        <b>Cheque</b><br />
                                        <div style="margin-left: 10px;">
                                            Amount :<span id="chequeAmt">0</span><br />
                                            number :<span id="chequeNo">xxxx</span><br />
                                            Date :<span id="chequeDate">xxxx</span><br />
                                            Bank :<span id="chequeBank">xxxx</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="clearfix"></div>
                                <div class="ln_solid"></div>
                            </div>
                           
                        </div>
                        
                        </div>
                    </div>
                    <div class="clearfix"></div>

                </div>
            </div>
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
