<%@ Page Language="C#" AutoEventWireup="true" CodeFile="editPurchase.aspx.cs" Inherits="purchase_editPurchase" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Edit Purchase  | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
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
        var exactwalletamt = 0;
        var purchaseId;
        var entryObj = "";
        var branchId=0;
        var taxType="";
        var branchName="";
        $(document).ready(function () {
            purchaseId = getQueryString('purchaseId');
            //  alert(BillNo);
            //  alert(BillNo);
            if (purchaseId == undefined) {
                location.href = "listPurchaseEntries.aspx";
                return;
            }
            searchAutoItems();
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
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
            //call to select order details
            
            retrievePurchaseDetail();
            
        });

        //auto populate for item search
        function searchAutoItems() {
            $("#itemNames").keyup(function () {             
                if ($("#itemNames").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });

            $("#itemNames").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "editPurchase.aspx/GetAutoCompleteItemData",
                        data: "{'variable':'" + $("#itemNames").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    $("#itemNames").val(ui.item.label); //ui.item is your object from the array
                    selectOrderItem(ui.item.id);
                    event.preventDefault();
                },
                minLength: 1

            });
        }


        //function for disable payment section
        function disablepayment() {
            $("#cbCashPayment").prop("disabled", true);
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
            $("#divUpdateOrder").css('pointer-events', 'none');
        }

        //start: Showing Details of selected Outsatnding Bill from Popup
        function retrievePurchaseDetail() {
            //  alert(paid);
            loading();

            $.ajax({
                type: "POST",
                url: "editPurchase.aspx/retrieveData",
                data: "{'purchaseId':'" + purchaseId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //$.cookie('salesreturnOrderId', BillNo, {
                    //    path: '/'
                    //});
                    entryObj = JSON.parse(msg.d);
                    console.log(entryObj);
                    var entry_details = entryObj.entry[0];
                    $("#lblUserName").text(entry_details.user);
                    $("#txtTotalCost").text(entry_details.pm_total);
                    $("#txtTotalDiscountRate").text(entry_details.pm_discount_rate);
                    $("#txtTotalDiscountAmount").text(entry_details.pm_discount_amount);
                    $("#txtPaidAmount").val(entry_details.pm_paidamount);
                    $("#txtBalanceAmount").val(entry_details.pm_balance);                   
                    $("#txtTotalNetAmount").text(entry_details.net_amount);
                    $("#txtTotalGrossamount").text(entry_details.net_amount);
                    $("#txtTotalTaxamt").text(entry_details.tax_amount);
                    $("#txtEntryRefNo").val(entry_details.pm_invoice_no);
                    $("#txtVendorName").text(entry_details.vn_name);
                    $("#txtVendorId").text(entry_details.vn_id);
                    $("#txtEntryDate").text(entry_details.date);
                    branchId=entry_details.branch_id;
                    taxType=entry_details.branch_tax_method;
                    branchName=entry_details.branch_name;
                    
                    if (entry_details.vn_balance <= 0) {
                        $("#txtBalance").text(entry_details.vn_balance);
                        $("#txtBalance").css("color", "green");
                    } else {
                        $("#txtBalance").text(entry_details.vn_balance);
                        $("#txtBalance").css("color", "red");
                    }

                    $("#txtTotalCurrentAmount").val('0');
                  
                    $("#txtSpecialNote").val(entry_details.pm_note);

                    // showing order_items
                    $("#tbodyItems").html("");
                    $.each(entryObj.items, function (i, item) {
                        var htmItemRow = '';
                        htmItemRow += '<tr>';
                        htmItemRow += '<td>' + item.itm_code + '</td>';
                        htmItemRow += '<td>' + item.itm_name + '</td>';


                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemPrice'); class='textwidth' style=' width:98%;' value='"+ item.pi_price +"' data-initialValue='0' /></td>";
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemQty'); class='textwidth' style=' width:98%;' value='" + item.pi_qty +"' data-quantityval='0'/></td>";
                        htmItemRow += "<td>" + item.pi_total + "</td>";
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='textwidth' style=' width:98%;' value='" + item.pi_discount_rate + "' data-initialValue='0'/></td>";
                        htmItemRow += "<td>" + item.pi_discount_amt + "</td>";
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemTax'); class='number-only textwidth' style=' width:98%;' value='" + item.pi_tax_amount + "' data-taxval='0'/></td>";
                        htmItemRow += "<td>" + item.pi_netamount + "</td>";
                        htmItemRow += "<td style='display:none;'>" + item.itm_id + "</td>";
                        htmItemRow += "<td style='display:none;'>" + item.pi_id + "</td>";
                        htmItemRow += "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";

                        htmItemRow += '</tr>';
                        $("#tbodyItems").append(htmItemRow);
                    });


                    $("#tblPayments > tbody").html("");
                    $.each(entryObj.transaction_details, function (i, row) {
                        console.log(row);
                        var htmPaymentDetails = '<tr>';
                        htmPaymentDetails += '<td>#' + row.id + '</td>';
                        htmPaymentDetails += '<td>' + row.date + '</td>';
                        htmPaymentDetails += '<td>' + row.narration + '</td>';
                        htmPaymentDetails += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                        htmPaymentDetails += '<td align="center">' +
                            '<div onclick="showTransactionDetails(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;"></li></div>' +
                            ((row.is_reconciliation == 0 && row.dr != 0) ? '<div onclick="showTransactionEdit(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-pencil" style="font-size:large;"></li></div>' : '') +
                            '</td>';
                        htmPaymentDetails += '</tr>';

                        $("#tblPayments > tbody").append(htmPaymentDetails);
                    });
                    loadTaxes(taxType);

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

        //function to show popup for editing transaction
        function showTransactionEdit(trans_id) {
            var transaction = entryObj.transaction_details.find(x=>x.id == trans_id);
            $("#lblTransRefEdit").text(transaction.id);
            $("#txtTotalAmount").text(transaction.dr);
            $("#txtCashAmt").val(transaction.cash_amt);
            $("#txtWalletAmt").val(transaction.wallet_amt);
            $("#txtChequeAmt").val(transaction.cheque_amt);
            $("#popupTransactionEdit").modal('show');
        }

        //function to calculate changes in payment
        function calcPaymentEditForm() {
            var cash_amt = isNaN(parseFloat($("#txtCashAmt").val())) ? 0 : parseFloat($("#txtCashAmt").val());
            var wallet_amt = isNaN(parseFloat($("#txtWalletAmt").val())) ? 0 : parseFloat($("#txtWalletAmt").val());
            var cheque_amt = isNaN(parseFloat($("#txtChequeAmt").val())) ? 0 : parseFloat($("#txtChequeAmt").val());
            $("#txtTotalAmount").text( cash_amt + wallet_amt + cheque_amt);
        }

        //function to save payment edit
        function savePaymentEdit() {
            var postObj = {
                trans_id: $("#lblTransRefEdit").text(),
                cash_amt: isNaN(parseFloat($("#txtCashAmt").val())) ? 0 : parseFloat($("#txtCashAmt").val()),
                cheque_amt: isNaN(parseFloat($("#txtChequeAmt").val())) ? 0 : parseFloat($("#txtChequeAmt").val())
            }
            loading();
            $.ajax({
                type: "POST",
                url: "editPurchase.aspx/savePaymentEdit",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    location.reload();
                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    alert("error");
                }
            });
        }

        //changing each value in table
        function modifyValues(thisRowId, valueType) {
            if (thisRowId != "1") {
                var rowId = $(thisRowId).closest('td').parent()[0].sectionRowIndex;
            }
            else {
                var rowId = thisRowId;
            }
            var unit_price = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').find('input').val());//price
            var item_qty = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').find('input').val());//qty
            var purchase_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').text());//amount
            var discnt_percent = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val());//dis %
            var discnt_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text());//dis amount
            var tax_amt = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(7)').find('input').val());//tax amount
            var net_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text());//net amount

            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
            var regexamount = new RegExp(/^\+?[0-9(),.]+$/);
            if (item_qty.match(regexqty)) {

            }
            else {
                var newVal1 = item_qty.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').find('input').val(newVal);
            }

            if (item_qty == "" || item_qty == "0") {
                alert("Item quantity is null");
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').addClass("error");
                // $("#divUpdateOrder").css('pointer-events', 'none');
                //   $("#divprintorder").css('pointer-events', 'none');
               
            }
            else {
                item_qty = parseInt($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').find('input').val()));
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').removeClass("error");
            }

            if (unit_price.match(regexamount)) {

            }
            else {
                var newVal1 = unit_price.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').find('input').val(newVal);
            }
            if (discnt_percent.match(regexamount)) {

            }
            else {
                var newVal1 = discnt_percent.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val(newVal);
            }
            if (discnt_amount.match(regexamount)) {

            }
            else {
                var newVal1 = discnt_amount.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text(newVal);
            }
            if (net_amount.match(regexamount)) {

            }
            else {
                var newVal1 = net_amount.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(newVal);
            }
            if (discnt_percent == "") {
                discnt_percent = 0.00;
            }
            else {
                discnt_percent = (parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val()))).toFixed(2);
            }
            if (discnt_amount == "") {
                discnt_amount = 0.00;
            }
            else {
                discnt_amount = (parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text()))).toFixed(2);
            }
            if (net_amount == "") {
                net_amount = 0.00;
            }
            else {
                net_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text()));
            }
            if (tax_amt == "") {
                tax_amt = 0.00;
            }
            else {
                tax_amt = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(7)').find('input').val()));
            }
            if (purchase_amount == "") {
                purchase_amount = 0.00;
            }
            else {
                purchase_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').text()));
            }

            purchase_amount = unit_price * item_qty;
            var realprice = 0;
            var discount = 0;
            if (valueType == "ItemPrice") {
                saleprice = parseFloat($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').find('input').val());
                if (isNaN(saleprice) == true) {
                    alert("Check Sales Price..!");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').find('input').val("");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').text(0);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val(0);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text(0);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(0);
                    $("#txtTotalDiscountRate").text("0");
                    $("#txtTotalDiscountAmount").text("0");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').addClass("error");
                    // return false;
                } else {
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').removeClass("error");
                    discnt_percent = 0.00;
                    discnt_amount = 0.00;
                    purchase_amount = parseFloat(saleprice * item_qty).toFixed(2);
                    net_amount = parseFloat(purchase_amount) + parseFloat(tax_amt);

                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').text(purchase_amount);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "ItemQty") {
                discnt_amount = (purchase_amount * discnt_percent / 100).toFixed(2);
                net_amount = parseFloat(purchase_amount - discnt_amount).toFixed(2);
                net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                if (isNaN(item_qty) == true) {
                    alert("Check Quantity..!");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').find('input').val("1");
                    return false;
                }
                else {
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').text(purchase_amount);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "DiscountPercent") {
                discount = parseInt($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val());
                discnt_amount = (purchase_amount * (discnt_percent / 100)).toFixed(2);
                net_amount = purchase_amount - discnt_amount;
                net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                //alert(discnt_percent);
                if (discnt_percent > 100) {
                    //   alert("Check Discount Percentage..!");
                    var newVal1 = discnt_percent.toString();
                    var newVal = newVal1.substr(0, newVal1.length - 1);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val(newVal);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').addClass("error");
                    return false;
                }

                if (isNaN(discnt_percent) == true) {
                    alert("Check Discount Percentage..!");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').find('input').val("");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').addClass("error");
                    return false;
                }
                else {
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').removeClass("error");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "ItemTax") {
                //   alert(discnt_amount);

                net_amount = (purchase_amount - discnt_amount).toFixed(2);

                if (isNaN(tax_amt) == true) {
                    // alert("Check Discount Amount..!");
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text("");
                    //    $(thisRowId).addClass("err");
                    return false;
                }
                else {
                    //  $(thisRowId).removeClass("err");
                    // alert(parseFloat(net_amount) + parseFloat(tax_amt));
                    net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                    //$('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            }
            myCalculations(2);

            paymentMethod();
        }

        //calculations for total
        function myCalculations(actionType) {
            // actionType=1 for initial case of adding items and actionType=2 is for after changing values
            var rowCount = $('#tblPurchaseItems > tbody tr').length;
            if (rowCount == 1) {
                //alert(rowCount);
                $("#txtTotalCost").text("0");
                $("#txtTotalDiscountRate").text("0");
                $("#txtTotalDiscountAmount").text("0");
                $("#txtTotalNetAmount").text("0");
                $("#txtPaidAmount").val("0");
                $("#txtBalanceAmount").val("0");

                $("#cbCashPayment").prop("disabled", true);
                $("#cbCashPayment").attr("checked", false);
                $("#cbCardPayment").prop("disabled", true);
                $("#cbCardPayment").attr("checked", false);
                $("#cbChequePayment").prop("disabled", true);
                $("#cbChequePayment").attr("checked", false);
                $('#txtCashAmount').val('0');
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

                return false;
            }
            var unit_price = 0.00; //unit price Column:2
            var item_qty = 1; //quantity Column:2
            var purchase_amount = 0.00; //Service Cost Column:2
            var discnt_percent = 0.00; //Discount Percentage Column:3
            var discnt_amount = 0.00; //Discount Amount Column:4
            var net_amount = 0.00; //Net Amount Column:5

            var total_service_cost = 0.00; // Total Service Cost 
            var total_discnt_percent = 0.00; //Total Discount Percentage 
            var total_discnt_amount = 0.00; //Total Discount Amount 
            var total_net_amount = 0.00; //Total Net Amount 
            var total_tax_amt = 0;
            var grand_tax_amt = 0;
            var grand_total = 0.00;
            var grand_distcnt_perc = 0.00;
            // alert(grand_distcnt_perc);
            var grand_distcnt_amount = 0.00;
            var grand_netamount = 0.00;

            var start_row = rowCount - 3; //For Identify Start RowId

            for (var i = 0; i <= start_row; i++) {

                unit_price = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(2)').find('input').val());
                item_qty = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(3)').find('input').val());
                purchase_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(4)').text());
                discnt_percent = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(5)').find('input').val());
                discnt_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(6)').text());
                tax_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(7)').find('input').val());
                net_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(8)').text());

                if (item_qty == "" || item_qty == "0") {
                    item_qty = 1;
                }
                else {
                    item_qty = parseInt($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(3)').find('input').val()));
                }
                if (purchase_amount == "") {
                    purchase_amount = 0.00;
                }
                else {
                    purchase_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(4)').text()));
                }
                if (discnt_percent == "") {
                    discnt_percent = 0.00;
                }
                else {
                    discnt_percent = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(5)').find('input').val()));
                }
                if (discnt_amount == "") {
                    discnt_amount = 0.00;
                }
                else {
                    discnt_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(6)').text()));

                }
                if (net_amount == "") {
                    net_amount = 0.00;
                }
                else {
                    net_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(8)').text()));
                }
                if (tax_amount == "") {
                    tax_amount = 0.00;
                }
                else {
                    tax_amount = parseFloat($.trim($('#tblPurchaseItems > tbody tr:eq(' + i + ') td:eq(7)').find('input').val()));
                }
                purchase_amount = unit_price * item_qty;
                total_service_cost += +purchase_amount;
                total_discnt_percent += +discnt_percent;
                total_discnt_amount += +discnt_amount;
                total_net_amount += +net_amount;
                total_tax_amt += +tax_amount;
            }

            grand_total += total_service_cost;
            // alert(total_net_amount);//Have to Add Tax Finally with grand total
            grand_distcnt_perc += (((total_service_cost - (total_net_amount - total_tax_amt)) * 100) / total_service_cost);
            if (!isFinite(grand_distcnt_perc)) {
                grand_distcnt_perc = 0;
                //  alert(grand_distcnt_perc);
            }
            //    alert(grand_distcnt_perc);
            grand_distcnt_amount += total_discnt_amount;
            grand_tax_amt += total_tax_amt;
            grand_netamount += total_net_amount;

            var total_rowid = rowCount - 2;                                                                 //For Identify Total Rowid
            var grand_total_rowid = rowCount - 1;                                                           //For Identify Grand Total Rowid

            $('#tblPurchaseItems > tbody tr:eq(' + total_rowid + ') td:eq(4)').text(grand_total.toFixed(2));

            $('#tblPurchaseItems > tbody tr:eq(' + total_rowid + ') td:eq(5)').text(grand_distcnt_perc.toFixed(2));    //Total Discount Percentage
            $('#tblPurchaseItems > tbody tr:eq(' + total_rowid + ') td:eq(6)').text(grand_distcnt_amount.toFixed(2));
            $('#tblPurchaseItems > tbody tr:eq(' + total_rowid + ') td:eq(7)').text(grand_tax_amt.toFixed(2));   //Total Discount Amount
            $('#tblPurchaseItems > tbody tr:eq(' + total_rowid + ') td:eq(8)').text(grand_netamount.toFixed(2));       //Total Net Amount

            $("#txtTotalGrossamount").text(grand_netamount.toFixed(2)); //Grand Total Amount
            $("#txtPaidAmount").val(0.00);                       //Paid Amount
            $("#txtBalanceAmount").val(grand_netamount.toFixed(2)); //Balance Amount
            paymentMethod();
        }

        //for disabling and enabling payment method textboxes
        function paymentMethod() {
            var tblrowCount = $('#tblPurchaseItems > tbody tr').length;
            if ($("#txtTotalGrossamount").text() == "0.00" && tblrowCount <= 3) {
                $("#cbCashPayment").prop("disabled", true);
                $("#cbCashPayment").attr("checked", false);
                $("#cbCardPayment").prop("disabled", true);
                $("#cbCardPayment").attr("checked", false);
                $("#cbChequePayment").attr("disabled", true);
                $("#cbChequePayment").attr("checked", false);
                $("#txtCashAmount").val('');
                $("#txtCardAmount").val('');
                $("#txtCardNo").val('');
                $("#txtCardType").val('');
                $("#txtCardBank").val('');
                $("#txtChequeAmount").val('');
                $("#txtChequeNo").val('');
                $("#txtChequeDate").val('');
                $("#txtBankName").val('');
            }
            else {
                $("#cbCashPayment").prop("disabled", false);
                $("#cbCardPayment").prop("disabled", false);
                $("#cbChequePayment").prop("disabled", false);
            }

            if ($("#cbCashPayment").is(':checked')) {
                $("#txtCashAmount").attr("disabled", false);
                if (isNaN($('#txtCashAmount').val())) {
                    alert("Enter a valid Cash Amount");
                    $('#txtCashAmount').val(0);
                }
            }
            else {
                $("#txtCashAmount").attr("disabled", true);
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
            }
            else {
                $("#txtCardAmount").attr("disabled", true);
                $("#txtCardNo").attr("disabled", true);
                $("#txtCardType").attr("disabled", true);
                $("#txtCardBank").attr("disabled", true);
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
            }
            else {
                $("#txtChequeAmount").attr("disabled", true);
                $("#txtChequeNo").attr("disabled", true);
                $("#txtChequeDate").attr("disabled", true);
                $("#txtBankName").attr("disabled", true);
                $("#txtChequeAmount").val('');
                $("#txtChequeNo").val('');
                $("#txtChequeDate").val('');
                $("#txtBankName").val('');
            }

            if ($(document).find(".error").length > 0) {
                console.log($(document).find(".error").length);
                $("#divUpdateOrder").css('pointer-events', 'none');
                //    $("#divprintorder").css('pointer-events', 'none');
            }
            else {
                $("#divUpdateOrder").css('pointer-events', 'auto');
                //    $("#divprintorder").css('pointer-events', 'auto');
            }
            calculteFromPayMethod();
        }

        // calculating total and balance from payment method values
        function calculteFromPayMethod() {
            var cashAmount = $("#txtCashAmount").val();
            //alert(cashAmount);
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
            var cashTotal = parseFloat(cashAmount) + parseFloat(cardAmount) + parseFloat(chequeAmount);

            //alert(cashTotal);
            $('#txtPaidAmount').val(cashTotal.toFixed(2));
            var balance = parseFloat($('#txtTotalGrossamount').text()) - parseFloat($('#txtPaidAmount').val());
            //alert(balance);
            //  $('#tblPurchaseItems tr:eq(' + row + ') td:eq(7)').text(total.toFixed(2));
            if (balance <= 0) {
                $("#txtOutstandingBillDate").prop("disabled", true);
                $("#txtOutstandingBillDate").val('');
            }
            else {
                $("#txtOutstandingBillDate").prop("disabled", false);
            }

            $("#txtBalanceAmount").val(balance.toFixed(2));
        }

        function DeleteRaw(ctrl) {

            $(ctrl).closest('tr').remove();
            var rowCount = parseInt($('#tblPurchaseItems tr').length);
            if (rowCount <= 1) {
                //  $("#TrSum").text('');
                $("#txtTotalCost").text(0.0);
                $("#txtTotalDiscountRate").text(0.0);
                $("#txtTotalDiscountAmount").text(0.0);
                $("#txtTotalNetAmount").text(0.0);
                $("#txtTotalGrossamount").text(0.0);
                $("#txtPaidAmount").val(0.0);
                $("#txtBalanceAmount").val(0.0);
            }
            // calculteTable();
            myCalculations(2);
        }

        //search items: shows in popup
        function resetItemlist() {
            for (var i = 1; i <= 2; i++) {
                $("#searchposContent" + i).val('');
            }
            searchOrderitems(1);
        }

        function searchOrderitems(page) {
            var filters = {};
            // alert(filters.warehouse);
            //     var CountryId = "0";
            //  alert($("#txtvendorId").text());
           
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itemname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itemcode = $("#searchposContent1").val();
            }
            
            filters.warehouse = branchId;
            
            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "editPurchase.aspx/searchOrderitems",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tableItemlist tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
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
                            if (row.itbsId == 0) {
                                htm += "<tr ";
                                htm += "  style='cursor:pointer;color: #a7a7a7;'><td>" + getHighlightedValue(filters.itemcode, row.itm_code.toString()) + "</td><td>" + getHighlightedValue(filters.itemname, row.itm_name) + "  <button type='button' class='btn btn-primary btn-sm pull-right' onclick='showAddItemPopUp(" + row.itm_id + ",\"" + row.itm_name + "\");'><label style='font-weight:950'> + </label></button></td><td>" + row.stock + "</td></tr>";
                            } else {
                                htm += "<tr ";
                                htm += " onclick=javascript:selectOrderItem('" + row.itbsId + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.itemcode, row.itm_code.toString()) + "</td><td>" + getHighlightedValue(filters.itemname, row.itm_name) + "</td><td>" + row.stock + "</td></tr>";
                            }


                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        //   alert(htm);
                        $('#tableItemlist tbody').html(htm);
                        $("#popupItems").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitems"));


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

        // start: Showing Details of selected  Item from autopopulate
        function selectOrderItem(id) {
            //alert("product_code: " + product_code + ", product_name: " + product_name + ", sales_price: " + sales_price + ", CountryId: " + CountryId + ", Tax: " + Tax + ", Discount: " + Discount);
            var html = '';
            var rowCount = $('#tblPurchaseItems > tbody tr').length;    
            rowposition = rowCount - 2;
            //for (i = 1; i <= rowposition; i++) {
            //    var currentId = $.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(9)').text());
            //    //  alert(currentId + "--" + id);
            //    if (currentId == id) {
            //        $("#itemNames").val("");
            //        alert("This item already selected");
            //        return false;
            //    }

            //}
            loading();
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "purchaseentry.aspx/selectOrderItem",
                data: "{'itemId':'" + id + "'}",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    html = "<tr>";
                    html = html + "<td>" + obj[0].itm_code + "</td>";
                    html = html + "<td>" + obj[0].itm_name.replace(/\u00a0/g, " "); +"</td>";
                    html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemPrice'); class='textwidth' style=' width:98%;' value='0' data-initialValue='0' /></td>";
                    html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemQty'); class='textwidth' style=' width:98%;' value='1' data-quantityval='0'/></td>";
                    html = html + "<td>0</td>";
                    html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='textwidth' style=' width:98%;' value='0' data-initialValue='0'/></td>";
                    html = html + "<td>0</td>";
                    html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemTax'); class='number-only textwidth' style=' width:98%;' value='0' data-taxval='0'/></td>";
                    html = html + "<td>0</td>";
                    html = html + "<td style='display:none;'>" + id + "</td>";
                    html = html + "<td style='display:none;'>-1</td>";
                    html = html + "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
                    html = html + "</tr>";

                    $("#itemNames").val("");
                    //alert(html);
                    $("#tbodyItems").append(html);
                    popupclose('popupItems');
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        // Stop: Showing Details of selected  Item from autopopulate

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        //Start:TO Replace single quotes with double quotes
        function sqlInjection() {
            $('input, select, textarea').each(
                function (index) {
                    var input = $(this);
                    var type = this.type ? this.type : this.nodeName.toLowerCase();
                    //alert(type);
                    if (type == "text" || type == "textarea") {
                        //var mytest=input.val().replace("'",'"');
                        //alert('Type: ' + type + 'Name: ' + input.attr('id') + 'Value: ' + input.val().replace("'",'"'));

                        //$("#"+input.attr('id')).val(input.val().replace("'",'"'));
                        $("#" + input.attr('id')).val(input.val().replace(/'/g, '"'));
                    }
                    else {
                    }
                }
            );
        }
        //Stop:TO Replace single quotes with double quotes

        function updatePurchaseMaster() {

            sqlInjection();
            var filters = {};
            filters.TimeZone = $.cookie("invntryTimeZone");
            filters.userid = $.cookie("invntrystaffId");
            filters.vendorId = $("#txtVendorId").text();
            // alert(filters.vendorId);
            filters.purchaseId = purchaseId;
            filters.invoicenum = $("#txtEntryRefNo").val();
            filters.note = $("#txtSpecialNote").val();
            filters.TotalAmount = $("#txtTotalCost").text();
            filters.TotalDiscountRate = $("#txtTotalDiscountRate").text();
            filters.TotalDiscountAmount = $("#txtTotalDiscountAmount").text();
            filters.totalTaxamt = $("#txtTotalTaxamt").text();
            filters.TotalNetAmount = $("#txtTotalGrossamount").text();
            var tblrowCount = $('#tblPurchaseItems tr').length;
            if (tblrowCount <= 3) {
                alert("Please Add Item");
                return;
            }


            // filters.SpecialNote = $("#txtSpecialNote").val();
           
            // save to pos
            filters.rowCount = $('#tblPurchaseItems tr').length;
            filters.rowCount = filters.rowCount - 3;
            //  alert(rowCount);
            if (filters.rowCount == 0) {
                alert("select an item");
                return;
            }

            var query = '';
            var itemstring = '';



            for (var row = 1; row <= filters.rowCount; row++) {
                itemstring += "{";
                for (var col = 0; col <= 12; col++) {
                    if (col != 2 && col != 3 && col != 5 && col != 7) {
                        if (col == 0) {
                            itemstring += "'itemcode':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 1) {
                            itemstring += "'itemname':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 4) {
                            itemstring += "'amount':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 6) {
                            itemstring += "'disamount':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 8) {
                            itemstring += "'netamount':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 9) {
                            itemstring += "'itbs_id':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 10) {
                            itemstring += "'purchaseItemId':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }

                    }
                    else {
                        //alert($("#tblPurchaseItems tr:eq(" + row + ") td:eq(3) input").val());
                        if ($("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val() == "") {

                            if ($("#tblPurchaseItems tr:eq(" + row + ") td:eq(3) input").val() == "") {
                                itemstring += "'quantity':'1',";
                            }
                            else {
                                itemstring += "'quantity':'0',";
                            }

                        }
                        else {
                            if (col == 2) {
                                itemstring += "'purchasePrice':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 3) {
                                itemstring += "'quantity':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }

                            if (col == 5) {
                                itemstring += "'dispercent':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }

                            if (col == 7) {
                                itemstring += "'taxamt':'" + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }

                            // tableString = tableString + $("#tblPurchaseItems tr:eq(" + row + ") td:eq(" + col + ") input").val();
                        }
                    }

                }
                itemstring += "},";
            }

            var lastChar = itemstring.slice(-1);
            if (lastChar == ',') {
                itemstring = itemstring.slice(0, -1);
            }
            console.log(itemstring);
            itemstring = "[" + itemstring + "]";
            console.log(itemstring);
            console.log(filters);
            bootbox.confirm("Do you want to continue?", function (result) {
                console.log(result)
                if (result) {
                    loading();
                    // alert("{'MemberId':'" + MemberId + "','MemberName':'" + MemberName + "','TotalCost':'" + TotalCost + "','TotalDiscountRate':'" + TotalDiscountRate + "','TotalDiscountAmount':'" + TotalDiscountAmount + "','Tax':'" + TaxAmount + "','billdate':'" + cur_dat + "','userid':'" + userid + "','TotalAmount':'" + TotalAmount + "','TotalCurrentAmount':'" + TotalCurrentAmount + "','TotalBalanceAmount':'" + TotalBalanceAmount + "','TotalPaidinFull':'" + TotalPaidinFull + "','paymentmode':'" + paymentmode + "','BankName':'" + BankName + "','ChequeAmount':'" + ChequeAmount + "','ChequeDate':'" + ChequeDate + "','ChequeNo':'" + ChequeNo + "','CardAmount':'" + CardAmount + "','CardNo':'" + CardNo + "','CardType':'" + CardType + "','CardBank':'" + CardBank + "','CashAmount':'" + CashAmount + "','CountryId':'" + CountryId + "','BranchId':'" + BranchId + "','SpecialNote':'" + SpecialNote + "','outstandingBillDate':'" + outstand_bl_dt + "','TimeZone':'" + TimeZone + "','tableString':'" + tableString + "','rowCount':" + rowCount + ",'PosCurrentPaidAmount':'" + PosCurrentPaidAmount + "','PosBalanceAmount':'" + PosBalanceAmount + "'}");
                    $.ajax({
                        type: "POST",
                        url: "editPurchase.aspx/updatePurchaseEntry",
                        data: "{'filters':" + JSON.stringify(filters) + ",'tableString':" + JSON.stringify(itemstring) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "N") {
                                alert("Error!.. Please Try Again...");
                                return;
                            } else {
                                alert("Entry edited successfully");
                                window.location.href = "listPurchaseEntries.aspx";
                            }
                        },
                        error: function (xhr, status) {
                            Unloading();
                            console.log(xhr.responseJSON.d);
                            var msgObj = JSON.parse(xhr.responseJSON.d);
                            alert(msgObj.message);
                        }
                    });
                } else {
                    bootbox.hideAll()
                    // What to do here?
                }
            });

        }

        function showAddItemPopUp(itemId, Name) {
            itm_id = itemId;
            $("#txtItemName").val('');
            $("#txtWarehouseName").val('');
            $("#txtClasAprice").val(0);
            $("#txtClasBprice").val(0);
            $("#txtClasCprice").val(0);
            $("#txtItemName").val('-1');
            $("#popupAddNewItem").modal('show');
            $("#txtItemName").val(Name);
            $("#txtWarehouseName").val(branchName);
            // alert($('select[name="warehousediv"] option:selected').val());
        }

        function loadTaxes() {            
            loading();
            $.ajax({
                type: "POST",
                url: "editPurchase.aspx/loadTaxes",
                data: "{'taxType':" + taxType + "}",
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
                        $("#selTaxcode").html(msg.d);
                        //   $("#selTaxcode").val(currentVal);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
       
        //function for add branch stock details
        function addBranchStockdetail() {
            //  alert($("#hdnItem").val());
            var branch =branchId;
            //var item = $("#txtItemAutoPopulate").val();
            var item = itm_id;
            var taxcode = $("#selTaxcode").val();
            if (taxcode == -1 || taxcode == "") {
                alert("choose item tax code");
                return;
            }

            var pricegroup_one = $("#txtClasAprice").val();
            var pricegroup_two = $("#txtClasBprice").val();
            var pricegroup_three = $("#txtClasCprice").val();
            var itm_mrp = 0;

            if (isNaN($("#txtClasAprice").val())) {
                alert("Price should be in number only");
                $("#txtClasAprice").focus();
                return;
            }
            if (isNaN($("#txtClasBprice").val())) {
                alert("Price should be in number only");
                $("#txtClasBprice").focus();
                return;
            }
            if (isNaN($("#txtClasCprice").val())) {
                alert("Price should be in number only");
                $("#txtClasCprice").focus();
                return;
            }

            loading();
            $.ajax({
                type: "POST",
                url: "editPurchase.aspx/addBranchStockDetails",
                data: "{'branch':'" + branch + "','item':'" + item + "','pricegroup_one':'" + pricegroup_one + "','pricegroup_two':'" + pricegroup_two + "','pricegroup_three':'" + pricegroup_three + "','taxcode':'" + taxcode + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "E") {
                        alert("already exist");
                    }
                    if (msg.d == "Y") {
                        alert("Item Added Successfully");
                        popupclose('popupAddNewItem');
                        searchOrderitems(1);
                        return;
                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });


        }

        function popupclose(divId) {
            $("#" + divId + "").modal('hide');
        }

        function addNewItem() {
            window.open('../inventory/itemmaster.aspx', '_blank');
        }

        //function for updating order status
        function cancelFunctn() {
            var result = confirm("Do you want to cancel the purchse entry?");
            if (result) {
                loading();
                $.ajax({
                    type: "POST",
                    url: "editPurchase.aspx/cancelFunctn",
                    data: "{'userId':'" + $.cookie('invntrystaffId') + "','purchaseId':'" + purchaseId + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        //alert(msg.d);
                        //alert("Success");
                        // return;
                        if (msg.d == "N") {
                            alert("Error!.. Please Try Again...");
                            return;
                        }else if(msg.d=="E"){
                            var result = confirm("Some One already changed the page..Do you want to reload and continue ?");
                            if(result){
                                window.location.reload();
                            }else{
                                return;
                            }
                        } else {

                            alert("Cancelled Successfully...");
                            window.location.href = "managepurchase.aspx?purchaseId="+purchaseId;
                            //setTimeout(function () {
                            //    window.location.reload();
                            //}, 3000);

                            return false;
                        }
                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("Internet Problem..!");
                    }
                });
            } else {
                return false;
            }
        }
    </script>

    
    <style>
        .modal {
            overflow: auto !important;
        }
    </style>
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
                            <label style="font-weight: bold; font-size: 16px;">Edit Purchase</label>
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
                                       <%--  <div class="col-auto">
            <!-- Default input -->
            <label class="sr-only" for="inlineFormInputGroup">Username</label>
            <div class="input-group mb-2">
                <div class="input-group-prepend">
                    <div class="input-group-text">@</div>
                </div>
                <input type="text" class="form-control py-0" id="inlineFormInputGroup" placeholder="Username">
            </div>
        </div>--%>
                                 
                                          <div style="text-align:center">
                                        <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                    <input type="text" class="form-control has-feedback-left ui-autocomplete-input" id="txtEntryRefNo"  autocomplete="off" style="font-weight:bold;font-size:18px">
                                    <span class="fa fa-hashtag form-control-feedback left" aria-hidden="true" style="background-color: #e9ecef;color:#495057;text-align: center;line-height: 1.5;"></span>
                                </div>
                                              </div>

                                       <%--     <input type="text" class="col-md-12 col-sm-12 col-xs-12 form-control form-control-sm" id="" style="font-size: 15px"/>--%>
                                       

                                       <div style="text-align:center;line-height: 2.5;" >
                                        <div class="col-sm-2 invoice-col" >

                                            <b><span title="City" class="fa fa-calendar"></span>
                                                <label id="txtEntryDate">24-Feb-2017</label></b>

                                        </div>
                                        <!-- /.col -->

                                        <div class="col-sm-3 invoice-col">
                                            <label id="txtVendorName">Istanbul Supermarket Ajman</label>
                                            <label id="txtVendorId" style="display:none;"></label>
                                        </div>
                                        <!-- /.col -->
                                       
                                         <div class="col-sm-2 invoice-col">
                                            <label id="Label1">Balance:</label>
                                            <label id="txtBalance" style=";">0</label>
                                        </div>
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
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Status Change</label>

                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>

                                </div>
                                <div class="x_content">
                                    <!-- info row -->
                                    <div class="row invoice-info">
                                        <div class="col-sm-10 invoice-col">
                                            APPROVED BY: <label style="font-size:14px;color:#2967b5;" id="lblUserName"></label>
                                           

                                        </div>
                                   
                                        <div class="col-sm-2 invoice-col">
                                            <button class="btn btn-danger btn-xs" onclick="cancelFunctn()" style="display:;" id="btnEdit">
                                                
                                                CANCEL</button>
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


                              
                                     <div class="col-md-6 col-sm-6 col-xs-12 pull-right" style="padding-right: 0px;">
                                    <div class="col-md-10 col-sm-6 col-xs-8" style="display:none;">
                                            <input class="form-control has-feedback-left" placeholder="Search Item" id="itemNames" autocomplete="off" type="search" />
                                            <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                        </div>
                                        <div class="col-md-11 col-sm-6 col-xs-4" style="padding-right: 0px;" onclick="javascript:resetItemlist();">
                                            <div class="pull-right" style="font-size: 25px;" title="Search Items" data-toggle="modal">
                                                <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                                <label class="fa fa-search" style="font-size: 16px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                            </div>

                                        </div>

                                          <%-- pop up for show  items --%>
                                            <div class="container">


                                                <div class="container">


                                            <div class="modal fade" id="popupItems" role="dialog" style="z-index: 1400;">
                                                <div class="modal-dialog modal-lg" style="">

                                                    <!-- Modal content-->
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <button type="button" class="close" onclick="javascript:popupclose('popupItems');">&times;</button>
                                                            <div class="col-md-3 col-sm-6 col-xs-6">
                                                                <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords">0</span></h4>
                                                            </div>
                                                            <div class="col-md-3 col-sm-6 col-xs-6"></div>
                                                            <div class="col-md-4 col-sm-4 col-xs-12 pull-right">

                                                                <div class="col-md-8 col-sm-12 col-xs-12">
                                                                    <div class="" onclick="javascript:searchOrderitems(1);">
                                                                        <button type="button" class="btn btn-success mybtnstyl">
                                                                            <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                            Search
                                                                        </button>
                                                                    </div>
                                                                    <div class="" onclick="javascript:resetItemlist();">
                                                                        <button class="btn btn-primary mybtnstyl" type="reset">
                                                                            <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                            Reset
                                                                        </button>
                                                                    </div>
                                                                </div>

                                                                <div class="col-md-2 col-sm-12 col-xs-3">
                                                                    <select id="txtpospageno" onchange="javascript:searchOrderitems(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                        <option value="50">50</option>
                                                                        <option value="100">100</option>
                                                                        <option value="250">250</option>
                                                                        <option value="500">500</option>
                                                                    </select>
                                                                </div>

                                                            </div>
                                                        </div>
                                                        <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                            <div class="x_content">

                                                                <table id="tableItemlist" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Code</th>
                                                                            <th>Name
                                        <div onclick="javascript:addNewItem();" class="btn btn-success btn-xs pull-right" style="background-color: #d86612; border-color: #d86612;"><span style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></span>New Item</div>
                                                                            </th>
                                                                            <th>Current Stock</th>


                                                                        </tr>


                                                                        <tr>
                                                                            <td>
                                                                                <input type="text" id="searchposContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                            <td>
                                                                                <input type="text" id="searchposContent2" /></td>
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

                                            </div>
                                              <%-- pop up for add new item to item branch stock --%>
                                        <div class="container">


                                            <div class="modal fade" id="popupAddNewItem" role="dialog" style="z-index: 1600;">
                                                <div class="modal-dialog modal-md">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <button type="button" class="close" onclick="javascript:popupclose('popupAddNewItem');">&times;</button>
                                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                                <h4 class="modal-title">Add Item</h4>
                                                            </div>

                                                        </div>
                                                        <div class="modal-body">
                                                            <div class="row">
                                                                <div class="col-md-12">
                                                                    <form role="form" class="form-horizontal">
                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                                Item<span class="required">*</span>
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <input type="text" id="txtItemName" placeholder="Enter Item name" required="required" class="form-control col-md-7 col-xs-12" disabled />
                                                                            </div>
                                                                        </div>

                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                                Warehouse<span class="required">*</span>
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <input type="text" id="txtWarehouseName" placeholder="Enter Item name" required="required" class="form-control col-md-7 col-xs-12" disabled />
                                                                            </div>
                                                                        </div>



                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                                                Tax code<span class="required">*</span>
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <select id="selTaxcode" class="form-control" style="padding-right: 2px;">
                                                                                    <option value="-1" selected="selected">--Tax Code--</option>
                                                                                </select>
                                                                            </div>
                                                                        </div>

                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                                                Class A
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <input type="number" id="txtClasAprice" value="0" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                                                            </div>
                                                                        </div>


                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                                                Class B
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <input type="number" id="txtClasBprice" value="0" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                                                            </div>
                                                                        </div>


                                                                        <div class="form-group">
                                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                                                Class C
                                                                            </label>
                                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                                <input type="number" id="txtClasCprice" value="0" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                                                            </div>
                                                                        </div>
                                                                    </form>
                                                                    <div class="clearfix"></div>

                                                                    <div class="ln_solid"></div>
                                                                    <div class="form-group" style="padding-bottom: 40px;">
                                                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                                            <div id="btnSave">
                                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addBranchStockdetail();">SAVE</div>
                                                                            </div>

                                                                            <div id="btnDelete" style="display: =;">
                                                                                <div class="btn btn-danger mybtnstyl" onclick="javascript:popupclose('popupAddNewItem');">CANCEL</div>
                                                                            </div>
                                                                            <%--<div onclick="javascript:clearUsertype();" class="btn btn-danger mybtnstyl" id="btnCancel">CANCEL</div>--%>
                                                                            <%--<button  id="btnUserDetailsUpdate" style="display:none" class="btn btn-success" onclick="javascript:updateUserDetails();" type="reset">Update</button>--%>
                                                                        </div>
                                                                    </div>

                                                                </div>

                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                        </div>
                                         </div>
                                  <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="tblPurchaseItems" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <td>Item Code</td>
                                                    <td style="width: 300px;">Name</td>
                                                    <td>Price</td>
                                                    <td>QTY</td>
                                                    <td>Amount</td>
                                                    <td>Dis %</td>
                                                    <td>Dis Amount</td>
                                                    <td>Tax Amount</td>
                                                    <td>Net Amount</td>
                                                   
                                                    <td></td>

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
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="text-align: right;"><b>Total</b></td>
                                                    <td id="txtTotalCost"></td>
                                                    <td id="txtTotalDiscountRate"></td>
                                                    <td id="txtTotalDiscountAmount"></td>
                                                    <td id="txtTotalTaxamt"></td>
                                                    <td id="txtTotalNetAmount"></td>
                                                 
                                                    <td></td>
                                                </tr>
                                             <tr style="display:none;">
                                                    <td colspan="4"></td>
                                                    <td></td>
                                                    <td></td>

                                                    <td></td>
                                                    <td></td>
                                                    <td>
                                                        <label id="txtTotalGrossamount"></label>
                                                    </td>
                                                   <td></td>

                                                </tr>
                                            </tbody>



                                        </table>
                                         <div class="col-md-1 col-sm-3 col-xs-3" style="float: right;" id="divUpdateOrder" onclick="javascript:updatePurchaseMaster();">
                                            <button class="btn btn-primary mybtnstyl pull-right" type="button">Save</button>
                                        </div>
                                    </div>
                                </div>
                          
                        </div>
                    </div>
                    <div class="clearfix"></div>
                   
                      
                    <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_title">
                                    <label>Transactions</label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <table id="tblPayments" class="table table-striped table-bordered">
                                        <thead>
                                            <tr>
                                                <th>Ref.</th>
                                                <th>Date</th>
                                                <th>Narration</th>
                                                <th>amount</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="clearfix"></div>
                    <%-- popup for showing transaction details --%>
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

                    <div class="clearfix"></div>
                    <%-- popup for showing payment edit popup --%>
                    <div class="modal fade" id="popupTransactionEdit" role="dialog">
                        <div class="modal-dialog modal-sm" style="">
                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                        <h4 class="modal-title">Edit payment #<span id="lblTransRefEdit"></span></h4>
                                    </div>
                                </div>
                                <div class="x_content">
                                    <form>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label class="col-form-label" for="txtTotalAmount">Total Amount :</label>
                                                    <label class="" id="txtTotalAmount">0</label>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-form-label" for="txtCashAmt">Cash</label>
                                                    <input class="form-control" type="number" id="txtCashAmt" onkeyup="calcPaymentEditForm()" />
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-form-label" for="txtWalletAmt">Wallet</label>
                                                    <input class="form-control" type="number" id="txtWalletAmt" onkeyup="calcPaymentEditForm()" disabled/>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-form-label" for="txtChequeAmt">Cheque</label>
                                                    <input class="form-control" type="number" id="txtChequeAmt" onkeyup="calcPaymentEditForm()" />
                                                </div>
                                                <div class="form-group" style="text-align:center">
                                                    <div style="display:inline-block">
                                                        <div class="btn btn-default " data-dismiss="modal">Cancel</div>
                                                        <div class="btn btn-primary " onclick="savePaymentEdit()">Save</div>
                                                    </div>
                                                    
                                                </div>
                                            </div>
                                        </form>
                                </div>
                                <div class="clearfix"></div>
                                <div class="ln_solid"></div>
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
