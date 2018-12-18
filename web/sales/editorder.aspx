<%@ Page Language="C#" AutoEventWireup="true" CodeFile="editorder.aspx.cs" Inherits="sales_editorder" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Edit Bill  | Invoice Me</title>
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
    <style>
        .blink_text
        {
            animation: 1s blinker linear infinite;
            -webkit-animation: 1s blinker linear infinite;
            -moz-animation: 1s blinker linear infinite;
            color: #ff3300;
        }

        @-moz-keyframes blinker
        {
            0%
            {
                opacity: 1.0;
            }

            50%
            {
                opacity: 0.0;
            }

            100%
            {
                opacity: 1.0;
            }
        }

        @-webkit-keyframes blinker
        {
            0%
            {
                opacity: 1.0;
            }

            50%
            {
                opacity: 0.0;
            }

            100%
            {
                opacity: 1.0;
            }
        }

        @keyframes blinker
        {
            0%
            {
                opacity: 1.0;
            }

            50%
            {
                opacity: 0.0;
            }

            100%
            {
                opacity: 1.0;
            }
        }
    </style>
    <script type="text/javascript">
        //object to keep details of order
        var orderObj;

        var exactwalletamt = 0;
        var BillNo;
        var userId;
        var status;
        var tax_type = 0;
        var isInclusive = 0;
        var warehouse;
        var customerType;
        var custId;
        var trCurrent;
        var deletedArray = [];
          var accuracyNum=2;
          var systemSettings= <%=settings%>;
        var lastUpdatedDate="";
        console.log(systemSettings);
        $(document).ready(function () {
            accuracyNum=systemSettings[0].ss_decimal_accuracy;
            BillNo = getQueryString('orderId');
            if (BillNo == undefined) {
                location.href = "orders.aspx";
                return;
            }
            ////console.log(location.search);
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
            loadBranches();
            selectOrders();
            disablepayment();
            bindItemAutoComplete();
            //call to select order details
            $('#walletPayment').change(function () {
                var currentwalletamount = parseFloat($("#lblwalletamt").text());
                var grand_netamount = parseFloat($("#txtPosBalanceAmount").val());
                //alert(grand_netamount);
                if ($(this).is(":checked")) {
                    if (grand_netamount.toFixed(accuracyNum) >= 0) {
                        if (grand_netamount.toFixed(accuracyNum) > currentwalletamount.toFixed(accuracyNum)) {
                            $("#textwalletamt").val(currentwalletamount);
                        } else {
                            $("#textwalletamt").val(grand_netamount.toFixed(accuracyNum));
                           
                        }
                        var paidwalletamt = parseFloat($("#textwalletamt").val());
                        currentwalletamount = currentwalletamount - paidwalletamt;

                        $("#lblwalletamt").text(currentwalletamount);
                    } else {
                        $("#textwalletamt").val(0);
                        $("#lblwalletamt").text(exactwalletamt);
                    }
                } else {
                    $("#textwalletamt").val(0);
                    $("#lblwalletamt").text(exactwalletamt);
                }
                paymentMethod();
            });

            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#txtProcessDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                //dateFormat :'yy-mm-dd'
                //dateFormat: 'yyyy-mm-dd'
                dateFormat: 'dd-mm-yy'
            });
            $('#txtProcessTime').scroller({
                preset: 'time',
                endYear: yyyy + 100,
                min: new Date(new Date().setHours(10, 00)),
                max: new Date(new Date().setHours(22, 00)),
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
            });
        });

        //function for disable payment
        function disablepayment() {
            $("#cbCashPayment").prop("disabled", true);
            $("#cbCashPayment").attr("checked", false);
            $("#walletPayment").prop("disabled", true);
            $("#walletPayment").attr("checked", false);
            $("#cbChequePayment").prop("disabled", true);
            $("#cbChequePayment").attr("checked", false);
            $('#txtCashAmount').val('0');
            $('#txtCashAmount').prop("disabled", true);
            $('#walletPayment').prop("disabled", true);
            $("#textwalletamt").val('0');
            $('#txtChequeAmount').val('0');
            $('#txtChequeAmount').prop("disabled", true);
            $('#txtChequeNo').val('');
            $('#txtChequeNo').prop("disabled", true);
            $('#txtChequeDate').val('');
            $('#txtChequeDate').prop("disabled", true);
            $('#txtBankName').val('');
            $('#txtBankName').prop("disabled", true);
        }

        //Start:TO Replace single quotes with double quotes
        function sqlInjection() {
            $('input, select, textarea').each(
                function (index) {
                    var input = $(this);
                    var type = this.type ? this.type : this.nodeName.toLowerCase();

                    if (type == "text" || type == "textarea") {

                        $("#" + input.attr('id')).val(input.val().replace(/'/g, '"'));
                    } else { }
                }
            );
        }

        //start: Showing Details of selected Outsatnding Bill from Popup
        function selectOrders() {
            loading();

            $.ajax({
                type: "POST",
                url: "editorder.aspx/selectOrders",
                data: "{'billno':'" + BillNo + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    orderObj = JSON.parse(msg.d);
                    var classType = "";
                    console.log(orderObj);
                    var order_details = orderObj.order[0];
                    
                    if (order_details.order_status == 4 || order_details.order_status == 5) {
                        window.location.href = "orders.aspx";
                    }
                    lastUpdatedDate=order_details.lastUpdatedDate;
                    tax_type = order_details.branch_tax_method;
                    isInclusive = order_details.branch_tax_inclusive;
                    warehouse = order_details.branch_id;
                    custId = order_details.cust_id;
                   // alert(order_details.processedDate);
                    var processDate = order_details.processedDate.split(' ')[0];
                    var processTime = order_details.processedDate.split(' ')[1] + " " + order_details.processedDate.split(' ')[2]; 
                    $("#txtProcessDate").val(processDate);
                    $("#txtProcessTime").val(processTime);
                    $("#txtBillRefNo").text(order_details.sm_refno);
                    $("#txtMemberId").text(order_details.cust_id);
                    if (order_details.invoiceNum != "" && order_details.invoiceNum !== null) {
                        $("#lblInvoiceNum").text("#" + order_details.invoiceNum);
                    }else{
                        $("#lblInvoiceNum").html(" <label style='color:red'> (Not Yet Billed) </label>");
                    }
                    customerType = order_details.cust_type;
                    if (order_details.cust_type == 1) {
                        classType = "A";
                    } else if (order_details.cust_type == 2) {
                        classType = "B";
                    } else if (order_details.cust_type == 3) {
                        classType = "C";
                    }
                    $("#txtClassType").text(classType);
                    var a = document.getElementById('hrefCustomer'); //or grab it by tagname etc
                    a.href = "../managecustomers.aspx?cusId=" + order_details.cust_id;
                    $("#txtMemberName").text(order_details.cust_name);
                    $("#txtOrderDate").text(order_details.date);
                    $("#selBranches").val(order_details.branch_id);
                    loadAssignPersons();
                    $("#lblOrderstatus").text(order_details.order_status);
                    if (order_details.order_status == 0) {
                        $("#txtLabelStatus").html('<span class="label label-warning" style="margin-left: 2px; margin-right: 2px; color: #fff;">New</span>');
                        $("#divAssign").show();
                        $("#divCancel").show();

                    } else if (order_details.order_status == 1) {
                        $("#txtLabelStatus").html('<span class="status label label-primary" style="margin-left: 2px; margin-right: 2px; color: #fff;">Processed</span>');
                        $("#divDeliver").show();
                        $("#divPending").show();
                        $("#divNew").show();
                        $("#divCancel").show();

                    } else if (order_details.order_status == 2) {
                        $("#txtLabelStatus").html('<span class="status label label-success" style="margin-left: 2px; margin-right: 2px; color: #fff;">Delivered</span>');

                    }
                    else if (order_details.order_status == 3) {
                        $("#txtLabelStatus").html('<span class="status label label-info" style="margin-left: 2px; margin-right: 2px; color: #fff;">To be confirmed</span>');
                        $("#divApprove").show();
                        $("#divReject").show();
                        $("#divCancel").show();
                    }
                    else if (order_details.order_status == 4) {
                        $("#txtLabelStatus").html('<span class="status label label-danger" style="margin-left: 2px; margin-right: 2px; color: #fff;">Cancelled</span>');
                    }
                    else if (order_details.order_status == 5) {
                        $("#txtLabelStatus").html('<span class="status label label-danger" style="margin-left: 2px; margin-right: 2px; color: #fff;">Rejected</span>');
                    }
                    else if (order_details.order_status == 6) {
                        $("#txtLabelStatus").html('<span class="status label label-default" style="margin-left: 2px; margin-right: 2px; color: #fff;">Pending</span>');
                    }
                    //   $("#txtdeliverystatus").val(order_details.order_status);
                    $("#txtSpecialNote").val(order_details.sm_specialnote);
                    if (order_details.outstanding_amt == null || order_details.outstanding_amt == "") {
                        order_details.outstanding_amt = 0;
                    }
                    $("#lbloutstanding").text(order_details.outstanding_amt);
                    if (order_details.outstanding_amt > 0) {
                        $("#lbloutstanding").css("color", "red");
                    } else {
                        $("#lbloutstanding").css("color", "green");
                    }
                    

                    if (order_details.approver_name == null || order_details.approver_name == "") {
                        $("#trconfirm").hide();
                    } else {
                        $("#lblconfirmusername").text(order_details.approver_name);
                        $("#trconfirm").show();
                    }
                    // showing order_items

                    $.each(orderObj.items, function (i, item) {
                        var htmItemRow = '';
                        htmItemRow += '<tr>';
                        htmItemRow += '<td>' + item.itm_code + '</td>';
                        if (item.si_itm_type == 4) {
                            htmItemRow += '<td>' + (item.itm_name).replace(/\u00a0/g, " ") + '(<label class="blink_text">New Item</label>)</td>';
                        } else {
                            htmItemRow += '<td>' + (item.itm_name).replace(/\u00a0/g, " ") + '</td>';
                        }
                        htmItemRow += '<td>' + parseFloat(item.si_org_price) + '</td>';
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemSalePrice'); class='number-only textwidth' style=' width:98%;' value='" + item.si_price + "' data-initialValue='" + item.si_price + "' /></td>";
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemQuantity'); class='number-only textwidth' style=' width:98%;' value='" + item.si_qty + "' data-quantityval='" + item.si_qty + "' data-taxRate='" + item.si_item_tax + "' data-cessRate='" + item.si_item_cess + "'/></td>";
                        htmItemRow += "<td><input type='text' onkeyup=modifyValues(this,'ItemFoc'); class='number-only textwidth' style=' width:98%;' value='" + item.si_foc + "' data-initialValue='" + item.si_foc + "' data-netValue='" + item.si_net_amount + "'/></td>";
                        htmItemRow += '<td>' + item.si_total + '</td>';
                        htmItemRow += "<td> <input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + item.si_discount_rate + "' data-initialValue='" + item.si_discount_rate + "'/></td>";
                        htmItemRow += '<td>' + item.si_discount_amount + '</td>';
                        htmItemRow += '<td>' + item.si_tax_excluded_total + '</td>';
                        htmItemRow += '<td>' + item.si_tax_amount + '</td>';
                        htmItemRow += '<td>' + item.si_net_amount + '</td>';
                        htmItemRow += '<td style="display:none;">' + item.itbs_id + '</td>';
                        htmItemRow += "<td style='display:none;'><input type='text' value='0' /></td>";
                        htmItemRow += "<td style='display:none;'>" + item.si_itm_type + "</td>";
                        htmItemRow += "<td style='display:none;'>" + item.itm_type + "</td>";
                        //htmItemRow += '<td></td>';
                        //htmItemRow += '<td style="border-right:none;"></td>';
                        if (item.si_itm_type == 4) {
                            htmItemRow += "<td><a class='btn btn-success btn-xs'><li class='fa fa-arrows-h' onclick='searchOrderitems(this);'></li></a><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
                        } else {
                            htmItemRow += "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
                        }
                       
                        htmItemRow += '</tr>';
                        $('#TrSum').before(htmItemRow);
                    });

                    finalCalculation();

                    //setting payments
                    $("#tblPayments > tbody").html("");
                    $.each(orderObj.payments, function (i, row) {
                        console.log(row);
                        var htmPaymentDetails = '<tr>';
                        htmPaymentDetails += '<td>#' + row.id + '</td>';
                        htmPaymentDetails += '<td>' + row.date + '</td>';
                        htmPaymentDetails += '<td>' + row.narration + '</td>';
                        htmPaymentDetails += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                        htmPaymentDetails += '<td align="center">' +
                            '<div onclick="showTransactionDetails(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;"></li></div>' +
                            ((row.is_reconciliation==0 && row.cr!=0)?'<div onclick="showTransactionEdit(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-pencil" style="font-size:large;"></li></div>':'') +
                            '</td>';
                        htmPaymentDetails += '</tr>';

                        $("#tblPayments > tbody").append(htmPaymentDetails);
                    });

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
            var transaction = orderObj.payments.find(x=>x.id == trans_id);
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
            var transaction = orderObj.payments.find(x=>x.id == trans_id);
            $("#lblTransRefEdit").text(transaction.id);
            $("#txtTotalAmount").text(transaction.cr);
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
                cheque_amt: isNaN(parseFloat($("#txtChequeAmt").val())) ? 0 : parseFloat($("#txtChequeAmt").val()),
                lastUpdatedDate:lastUpdatedDate,
                billNo:BillNo
            }
            loading();
            $.ajax({
                type: "POST",
                url: "editorder.aspx/savePaymentEdit",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if(msg.d=="N"){
                        alert("Error..");
                    }else if(msg.d=="E"){
                        var result = confirm("Some One already changed the page..Do you want to reload and continue ?");
                        if(result){
                            window.location.reload();
                        }else{
                            return;
                        }
                    } else{
                        alert("Payment edited succesfully..");
                        $('#popupTransactionEdit').modal('hide');
                        window.location.reload();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    alert("error");
                }
            });
        }

        //start function for delete row
        function DeleteRaw(ctrl) {
            var result = confirm("Want to delete?");
            if (result) {
                deletedArray.push(ctrl);

                $(ctrl).closest('tr').remove();
                var rowCount = parseInt($('#tblOrderItems tr').length);
                if (rowCount <= 4) {
                    //  $("#TrSum").text('');
                    $("#txtposTotalCost").text(0.0);
                    $("#txtTotalDiscountRate").text(0.0);
                    $("#txtTotalDiscountAmount").text(0.0);
                    $("#txtTotalNetAmount").text(0.0);
                    $("#txtTotalGrossamount").text(0.0);
                    $("#txtPosPaidAmount").val(0.0);
                    $("#txtPosBalanceAmount").val(0.0);
                    $("#txtTotalTaxAmount").text(0);
                    $("#txtTotalBillAmount").text(0);
                }
                // calculteTable();
                finalCalculation();
            } else {
                return false;
            }
        }
        //end function for delete row

        //Start:Modify Discount percentage,amount and Net Amount
        function modifyValues(thisRowId, valueType) {
            //start check number only
            $('.number-only').keyup(function (e) {
                if (this.value != '-')
                    while (isNaN(this.value))
                        this.value = this.value.split('').reverse().join('').replace(/[\D]/i, '')
                                               .split('').reverse().join('');
                return false;
            })
             .on("cut copy paste", function (e) {
                 e.preventDefault();
             });
            //end check number only
            checkItemOffer(thisRowId);
            var parentRow = $(thisRowId).closest('td').parent()[0];
            var rowId = parentRow.sectionRowIndex;
            var unit_price = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
            var item_qty = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
            var service_cost = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(6)').text());
            var discnt_percent = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());
            var discnt_amount = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(8)').text());
            var net_amount = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text());
            var tax_amount = parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(10)').text()));

            var Total_net_amount = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(11)').text());
            var itemFoc = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());
            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
            if (item_qty.match(regexqty)) {

            }
            else {
                var newVal1 = item_qty.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').val(newVal);
            }
            if (itemFoc.match(regexqty)) {

            }
            else {
                var newVal1 = itemFoc.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(newVal);
            }
            if (service_cost == "") {
                service_cost = 0.00;
            }
            else {
                service_cost = (parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(6)').text()))).toFixed(accuracyNum);
            }
            if (discnt_percent == "") {
                discnt_percent = 0.00;
            }
            else {
                discnt_percent = (parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val()))).toFixed(accuracyNum);
            }
            if (discnt_amount == "") {
                discnt_amount = 0.00;
            }
            else {
                //changed by deepika on 02-11-16
                discnt_amount = (parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(8)').text()))).toFixed(accuracyNum);
                // alert(discnt_amount);
            }
            if (net_amount == "") {
                net_amount = 0.00;
            }
            else {
                net_amount = (parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text()))).toFixed(accuracyNum);
            }

            service_cost = parseFloat(unit_price * item_qty).toFixed(accuracyNum);
            // alert(service_cost);
            var realprice = 0;
            saleprice = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
            var discount = 0;
            var foc = 0;
            if (valueType == "ItemQuantity") {
                if (item_qty == "" || item_qty == 0) {
                    $(thisRowId).addClass("err");
                    $("#divsaveorder").css('pointer-events', 'none');
                    $("#divprintorder").css('pointer-events', 'none');
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(11)').text(tax_amount);
                    return;
                }
                item_qty = parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').val()));

                if (isNaN(item_qty) == true) {
                    // alert("Check Quantity..!");
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').val("1");
                    return false;
                }
                else {
                    $(thisRowId).removeClass("err");
                    calculateValues(thisRowId);
                }
            }
            else if (valueType == "ItemSalePrice") {

                foc = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());
                realprice = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(2)').text());
                saleprice = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
                if (isNaN(saleprice) == true || saleprice == 0) {
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val("");
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(6)').text(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(8)').text(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(10)').text(0);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(11)').text(0);
                    $(thisRowId).addClass("err");
                }
                else {
                    $(thisRowId).removeClass("err");
                    calculateValues(thisRowId);

                }
            }

            else if (valueType == "DiscountPercent") {
                discount = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());
                if (discnt_percent == "") {
                    $(thisRowId).addClass("err");
                    $("#divsaveorder").css('pointer-events', 'none');
                    $("#divprintorder").css('pointer-events', 'none');
                    //$('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text(0);
                    //$('#tblOrderItems tr:eq(' + rowId + ') td:eq(11)').text(tax_amount);
                    return;
                }
                if (discnt_percent > 100) {
                    // alert("Check Discount Percentage..!");
                    var newVal1 = discnt_percent.toString();
                    var newVal = newVal1.substr(0, newVal1.length - 1);
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val(newVal);
                    $(thisRowId).addClass("err");

                }
                else if (isNaN(discnt_percent) == true) {
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val("0");
                    return false;
                } else if (discnt_percent == "") {
                    return true;
                }
                else {
                    $(thisRowId).removeClass("err");
                    calculateValues(thisRowId);

                }
            }

            else if (valueType == "ItemFoc") {
                if (isNaN(itemFoc) == true) {
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(itemFoc);
                    return false;
                } else {
                    foc = parseInt($('#tblOrderItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());
                    realprice = parseInt($('#tblOrderItems tr:eq(' + rowId + ') td:eq(2)').text());
                    saleprice = parseInt($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
                    discount = parseInt($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());
                }
            }

            if ($.cookie("invntrystaffTypeID") != 1) {
                checkIsEntryToConfirm(thisRowId);
            }
            finalCalculation(); // 1 for initial case of adding items and 2 is for after changing values
        }
        //Stop:Modify Discount percentage,amount and Net Amount

        //start function for color change
        function checkIsEntryToConfirm(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            var rowId = parentRow.sectionRowIndex;
            ////console.log(parentRow);
            var isChanged = false;
            $(parentRow).find("[data-initialValue]").each(function (i) {
                ////console.log(this);
                var currentvalue = parseFloat($(this).val().trim());
                var initialvalue = parseFloat($(this).attr('data-initialValue').trim());
                if (!isNaN(currentvalue)) {
                    if (currentvalue != initialvalue) {
                        isChanged = true;
                    }
                }
            })
            if (isChanged) {
                $(parentRow).css('background-color', 'yellow');
                $(parentRow).attr("data-confirm", true);
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(14)').text(1);

            }
            else {
                $(parentRow).css('background-color', '#ebebeb ');
                $(parentRow).attr("data-confirm", false);
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(14)').text(0);
            }
        }
        //end function for color change

        function calculateValues(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            var rowId = parentRow.sectionRowIndex;
            var cessRate = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').attr('data-cessRate'));
            var tax_rate = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').attr('data-taxRate'));
            var saleprice = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
            var item_qty = $('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').val();
            var discount = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());
            if (isInclusive == 1) { // tax is included with the price

                if (parseFloat(cessRate) > 0) {

                    var denominator = 10000 * saleprice;
                    var base = 10000 + (100 * tax_rate) + (tax_rate * cessRate);
                    realtotal = denominator / base;
                }
                else {
                    var constant = (tax_rate / 100) + 1; // equation for the dividing constant
                    realtotal = saleprice / constant;
                }
            }
            else {
                realtotal = saleprice;
            }

            service_cost = parseFloat(realtotal * item_qty);
            discount_amt = ((service_cost * discount) / 100);
            net_amount = (service_cost - ((service_cost * discount) / 100));
            tax_amount = calculateTaxAmt(net_amount, parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').attr('data-taxRate')), parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(4)').find('input').attr('data-cessRate')));
            Total_net_amount = parseFloat(parseFloat(net_amount) + parseFloat(tax_amount));
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(6)').text(service_cost.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val(discount);
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(8)').text(discount_amt.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(9)').text(net_amount.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(10)').text(tax_amount.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + rowId + ') td:eq(11)').text(Total_net_amount.toFixed(accuracyNum));

        }

        //start function for calculate taxAmount
        function calculateTaxAmt(realprice, tax_rate, cessRate) {
            if (tax_rate == 0) {
                return 0;
            }
            else {

                tax_amount = ((realprice * tax_rate) / 100);
                if (cessRate > 0) {

                    cessAmount = ((tax_amount * cessRate) / 100);
                    tax_amount = parseFloat(parseFloat(tax_amount) + parseFloat(cessAmount)).toFixed(accuracyNum);
                }
                else {

                    tax_amount = tax_amount;
                }
                return tax_amount;
            }
        }
        //end function for calculate taxAmount
        function checkItemOffer(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            if ($(parentRow).attr('data-offertype') != undefined) {
                var offertype = parseFloat($(parentRow).attr('data-offertype').trim());

                if (offertype == 1) {
                    var item_qty = $.trim($(parentRow).find('td:eq(4)').find('input').val());
                    var offer_limit = parseFloat($(parentRow).attr('data-offerlimit').trim());
                    var offer_value = parseFloat($(parentRow).attr('data-offervalue').trim());
                    var tot_foc = Math.floor(item_qty / offer_limit) * offer_value;
                    $(parentRow).find('td:eq(5)').find('input').val(tot_foc);
                    $(parentRow).find('td:eq(5)').find('input').attr("data-initialvalue", tot_foc);
                }
                if (offertype == 0) {
                    var item_qty = $.trim($(parentRow).find('td:eq(4)').find('input').val());
                    var offer_limit = parseFloat($(parentRow).attr('data-offerlimit').trim());
                    var offer_value = parseFloat($(parentRow).attr('data-offervalue').trim());
                    if (item_qty >= offer_limit) {
                        $(parentRow).find('td:eq(7)').find('input').val(offer_value);
                        $(parentRow).find('td:eq(7)').find('input').attr("data-initialvalue", offer_value);
                    }
                    else {
                        $(parentRow).find('td:eq(7)').find('input').val(0);
                        $(parentRow).find('td:eq(7)').find('input').attr("data-initialvalue", 0);
                    }
                }
            }

        }
        //start function for calculating final amt
        function finalCalculation() {
            var rowCount = $('#tblOrderItems tr').length;
            if (rowCount == 3) {
                $("#txtposTotalCost").text("0");
                $("#txtTotalDiscountRate").text("0");
                $("#txtTotalDiscountAmount").text("0");
                $("#txtTotalNetAmount").text("0");
                $("#txtTotalTaxAmount").text("0");
                $("#txtTotalBillAmount").text("0");
                $("#txtPosPaidAmount").val("0");
                $("#txtPosBalanceAmount").val("0");
                disablepayment();
                return false;
            }
            var unit_price = 0.00; //unit price Column:2
            var item_qty = 1; //quantity Column:2
            var service_cost = 0.00; //Service Cost Column:2
            var discnt_percent = 0.00; //Discount Percentage Column:3
            var discnt_amount = 0.00; //Discount Amount Column:4
            var net_amount = 0.00; //Net Amount Column:5
            var bill_amount = 0.00;
            var tax_amt = 0.00;
            var total_service_cost = 0.00; // Total Service Cost 
            var total_discnt_percent = 0.00; //Total Discount Percentage 
            var total_discnt_amount = 0.00; //Total Discount Amount 
            var total_net_amount = 0.00; //Total Net Amount 
            var total_bill_amount = 0.00;
            var total_tax_amt = 0.00;
            var grand_total = 0.00;
            var grand_distcnt_perc = 0.00;
            var grand_distcnt_amount = 0.00;
            var grand_netamount = 0.00;
            var grand_netBillamount = 0.00;
            var grand_Taxamount = 0.00;
            var taxable_amt = 0.00;
            var total_taxable_amount = 0.00;
            var inclusiveTotal = 0.00;
            var grantInclusiveTotal = 0.00;
            var start_row = rowCount - 3; //For Identify Start RowId
            for (var i = 1; i <= start_row; i++) {
                unit_price = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(3)').find('input').val());
                item_qty = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(4)').find('input').val());
                service_cost = parseFloat($('#tblOrderItems tr:eq(' + i + ') td:eq(6)').text());
                discnt_percent = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(7)').find('input').val());
                discnt_amount = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(8)').text());
                net_amount = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(9)').text()));
                taxable_amt = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(9)').text()));
                tax_amt = parseFloat($('#tblOrderItems tr:eq(' + i + ') td:eq(10)').text());
                bill_amount = parseFloat($('#tblOrderItems tr:eq(' + i + ') td:eq(11)').text());

                if (item_qty == "" || item_qty == "0") {
                    item_qty = 1;
                }
                else {
                    item_qty = parseInt($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(4)').find('input').val()));
                }
                if (service_cost == "") {
                    service_cost = 0.00;
                }
                else {
                    service_cost = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(6)').text()));
                }
                if (discnt_percent == "") {
                    discnt_percent = 0.00;
                }
                else {
                    discnt_percent = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(7)').find('input').val()));
                }
                if (discnt_amount == "") {
                    discnt_amount = 0.00;
                }
                else {
                    discnt_amount = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(8)').text()));

                }
                if (net_amount == "" || isNaN(net_amount) == true) {
                    net_amount = 0.00;
                }
                else {
                    if (isInclusive == 1) {
                        net_amount = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(11)').text()));
                        inclusiveTotal = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(6)').text()));
                    } else {
                        net_amount = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(9)').text()));
                    }
                    taxable_amt = parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(9)').text()));
                }
                if (isNaN(unit_price) == true) {
                    unit_price = parseFloat(unit_price.match(/-?(?:\d+(?:\.\d*)?|\.\d+)/)[0]);
                }
                service_cost = unit_price * item_qty;
                if (isInclusive == 1) {
                    grantInclusiveTotal += +inclusiveTotal;
                } else {
                    grantInclusiveTotal += +service_cost;
                }
                total_service_cost += +service_cost;
                total_discnt_percent += +discnt_percent;
                total_discnt_amount += +discnt_amount;
                total_net_amount += +net_amount;
                total_taxable_amount += +taxable_amt;
                total_bill_amount += +bill_amount;
                total_tax_amt += +tax_amt;
            }

            grand_total += grantInclusiveTotal;                                                                //Have to Add Tax Finally with grand total
            grand_distcnt_perc += (((total_service_cost - total_net_amount) * 100) / total_service_cost);
            grand_distcnt_amount += total_discnt_amount;
            grand_netamount += total_taxable_amount;
            grand_netBillamount += total_bill_amount;
            grand_Taxamount += total_tax_amt;
            if (!isFinite(grand_distcnt_perc)) {
                grand_distcnt_perc = 0;
            }
            var total_rowid = rowCount - 2;
            var grand_total_rowid = rowCount - 1;                                                           //For Identify Grand Total Rowid
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(6)').text(grand_total.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(7)').text(grand_distcnt_perc.toFixed(accuracyNum));    //Total Discount Percentage
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(8)').text(grand_distcnt_amount.toFixed(accuracyNum));  //Total Discount Amount
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(9)').text(grand_netamount.toFixed(accuracyNum));       //Total Net Amount
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(10)').text(grand_Taxamount.toFixed(accuracyNum));
            $('#tblOrderItems tr:eq(' + total_rowid + ') td:eq(11)').text(grand_netBillamount.toFixed(accuracyNum));
            $("#txtTotalGrossamount").text(grand_netBillamount.toFixed(accuracyNum)); //Grand Total Amount
            $("#txtPosPaidAmount").val(0.00);                       //Paid Amount
            $("#txtPosBalanceAmount").val(grand_netBillamount.toFixed(accuracyNum)); //Balance Amount
            paymentMethod();
        }
        //end function for calculating final amt

        //for disabling and enabling payment method textboxes
        function paymentMethod() {
            var tblrowCount = $('#tblOrderItems tr').length;
            if ($("#txtTotalGrossamount").text() == "0.00" && tblrowCount <= 3) {
                disablepayment();
            }
            else {
                $("#cbCashPayment").prop("disabled", false);
                $("#cbCardPayment").prop("disabled", false);
                $("#cbChequePayment").prop("disabled", false);
                $("#walletPayment").prop("disabled", false);

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
                $("#txtCashAmount").val(0);
            }
            if ($("#cbCardPayment").is(':checked')) {
                /*   $("#txtCardAmount").removeAttr("disabled");
                $("#txtCardNo").removeAttr("disabled");
                $("#txtCardType").removeAttr("disabled");*/
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
                $("#txtCardAmount").val(0);
                $("#txtCardNo").val('');
                $("#txtCardType").val('');
                $("#txtCardBank").val('');
            }
            if ($("#cbChequePayment").is(':checked')) {
                /* $("#txtChequeAmount").removeAttr("disabled");
                $("#txtChequeNo").removeAttr("disabled");
                $("#txtChequeDate").removeAttr("disabled");
                $("#txtBankName").removeAttr("disabled");*/
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
                $("#txtChequeAmount").val(0);
                $("#txtChequeNo").val('');
                $("#txtChequeDate").val('');
                $("#txtBankName").val('');
            }
            if ($(document).find("[data-confirm=true]").length > 0) {
                disablepayment();
            }
            if ($(document).find(".err").length > 0) {
                ////console.log($(document).find(".err").length);
                $("#divsaveorder").css('pointer-events', 'none');
                $("#divprintorder").css('pointer-events', 'none');
            }
            else {
                $("#divsaveorder").css('pointer-events', 'auto');
                $("#divprintorder").css('pointer-events', 'auto');
            }
            calculteFromPayMethod();
        }

        // calculating total and balance from payment method values and wallet calculation
        function calculteFromPayMethod() {
            var cashAmount = $("#txtCashAmount").val();
            //alert(cashAmount);
            if (cashAmount == "") {
                cashAmount = 0;
            }

            var chequeAmount = $("#txtChequeAmount").val();
            if (chequeAmount == "") {
                chequeAmount = 0;
            }
            var walletamt = 0;

            //change code

            //change code
            var cashTotal = parseFloat(cashAmount) + parseFloat(chequeAmount);

            if ($("#walletPayment").is(':checked') && parseFloat(exactwalletamt) > 0) {
                var bal = (parseFloat($("#txtTotalGrossamount").text() - parseFloat(cashTotal)));
                if (parseFloat(bal) >= parseFloat(exactwalletamt)) {
                    //alert("1 bal " + bal + "   extwallet" + exactwalletamt);
                    $("#textwalletamt").val(exactwalletamt);
                    $("#walletPayment").prop("disabled", false);
                }
                else if (parseFloat(bal) <= 0) {
                    //alert("2 bal " + bal + "   extwallet" + exactwalletamt);
                    $("#walletPayment").prop("disabled", true);
                    $("#walletPayment").prop("checked", false);
                    $("#textwalletamt").val(0);
                    $("#lblwalletamt").text(exactwalletamt);
                }
                else if (parseFloat(bal) > 0 && parseFloat(bal) < parseFloat(exactwalletamt)) {
                    // alert("3 bal " + bal + "   extwallet" + exactwalletamt);
                    $("#textwalletamt").val(bal);
                    $("#lblwalletamt").text(parseFloat(exactwalletamt) - parseFloat(bal));
                }
                walletamt = $("#textwalletamt").val();

            }
            //alert("asdf" + parseFloat($("#txtPosBalanceAmount").val()) + "Wallet " + parseFloat($("#textwalletamt").val()));

            cashTotal = parseFloat(cashAmount) + parseFloat(chequeAmount) + parseFloat(walletamt);

            //alert(cashTotal);
            $('#txtPosPaidAmount').val(cashTotal.toFixed(accuracyNum));
            var balance = parseFloat($('#txtTotalGrossamount').text()) - parseFloat(cashTotal);



            if (balance <= 0) {
                $("#txtOutstandingBillDate").prop("disabled", true);
                $("#txtOutstandingBillDate").val('');
            }
            else {
                $("#txtOutstandingBillDate").prop("disabled", false);
            }

            $("#txtPosBalanceAmount").val(balance.toFixed(accuracyNum));
            // changecurrentwalletamt();

        }

        //function for type checking whether offer Item or normal items
        function checksearchItems() {
            $("#txtNames").val("");
            $("#customerNames").val("");
            $("#ItemTypecheck").prop("checked") ? resetoffer() : searchOrderitems(0);
        }

        //normal items search
        function searchOrderitems(ctrl) {
            trCurrent = ctrl;
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            $("#combosearchitemtype").val(0);
            searchOrderitem(1);
        }

        function searchOrderitem(page) {
            var filters = {};
            var customertype = customerType;
            filters.warehouse = warehouse;

            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itemname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itemcode = $("#searchposContent1").val();
            }

            var perpage = $("#txtpospageno").val();
            //console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "editorder.aspx/searchOrderitem",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + ",'customertype':" + customertype + ",'cust_id':'" + $("#txtMemberId").text() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tablePos tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  //console.log(obj);
                        $("#lblItemTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            // //console.log(row);
                            var amount = 0;
                            if (customertype == 1) {
                                amount = row.itm_class_one;
                            }
                            else if (customertype == 2) {
                                amount = row.itm_class_two;
                            }
                            else if (customertype == 3) {
                                amount = row.itm_class_three;
                            }
                            //  alert(amount);
                            //if (amount == 0) {
                            //    return;
                            //}
                            htm += "<tr ";
                            htm += " onclick=javascript:selectOrderItem('" + row.itm_code.replace(/\s/g, '&nbsp;') + "','" + row.itm_name.replace(/\s/g, '&nbsp;') + "','" + amount + "','" + row.itbs_id + "','" + row.itbs_stock + "','" + row.tp_tax_percentage + "','" + row.tp_cess + "','" + row.itm_type + "'); style='cursor:pointer;'><td>" + row.itm_code + "</td><td>" + row.itm_name + "</td><td>" + row.brand_name + "/" + row.cat_name + "</td>";
                            htm += "<td>" + row.itbs_stock + "</td><td>" + amount + "</td></tr>";

                            // $('#tablepos > tbody > tr:gt(' + (i + 2) + ')').remove();
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        //   alert(htm);
                        $('#tablePos tbody').html(htm);
                        $("#popupItems").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitem"));


                        return;
                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    //console.log(xhr);
                    //console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });

        }


        // start: Showing Details of selected  Item from Popup
        function selectOrderItem(item_code, item_name, item_sp, itbs_id, currentstock, tax_rate, cessRate,type) {
            //console.log(trCurrent);
            var html = '';
            var rowCount = $('#tblOrderItems tr').length;
            // alert(rowCount);
            rowid = rowCount - 3;
            rowposition = rowCount - 2;
            var currentItems = Array();
            for (i = 1; i < rowposition; i++) {
                var currentId = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(12)').text());
                var itemtype = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(13)').find('input').val());
                var currentItem = [currentId, itemtype];
                currentItems.push(currentItem);
            }
            //   //console.log(currentItems[0]);
            for (j = 0; j < currentItems.length; j++) {
                var array1 = currentItems[j];
                var array2 = [itbs_id, "0"];
                //console.log(array1.join('|'));
                //console.log(array2.join('|'));
                if (array1.join('|') === array2.join('|')) {
                    alert("This item already selected");
                    return false;
                }
            }

            var Discount = 0;
            var realprice = parseFloat(item_sp);
            var foc = 0;
            var quantity = 1;

            if (trCurrent != 0 && typeof trCurrent !== 'undefined') {
                Discount = parseFloat($(trCurrent).closest("tr").find('td:eq(7)').find('input').val());
                realprice = parseFloat($(trCurrent).closest("tr").find('td:eq(3)').find('input').val());
                foc = parseFloat($(trCurrent).closest("tr").find('td:eq(5)').find('input').val());
                quantity = parseFloat($(trCurrent).closest("tr").find('td:eq(4)').find('input').val());
            }
            //tax calculation starts on 25-8-2017
            if (tax_type == 0) // no tax
            {
                realtotal = realprice * quantity// price without discount
                discount_amt = (parseFloat(realtotal) * (parseFloat(Discount) / 100));
                nettotal = (parseFloat(parseFloat(realtotal) - (parseFloat(realtotal) * (parseFloat(Discount) / 100))));
                tax_included_nettotal = nettotal;
                tax_amount = 0; // not tax used
                cessAmount = 0;

            }
            else { // VAT CALCULATION
                //clearValues(); // clears gst values

                if (isInclusive == 1) { // tax is included with the price

                    if (parseFloat(cessRate) > 0) {

                        var denominator = 10000 * realprice;
                        var base = 10000 + (100 * tax_rate) + (tax_rate * cessRate);
                        realtotal = denominator / base;
                    }
                    else {
                        var constant = (tax_rate / 100) + 1; // equation for the dividing constant
                        realtotal = realprice / constant;
                    }
                    realtotal = realtotal * quantity;
                }
                else {
                    realtotal = realprice * quantity;
                }

                // price without discount
                discount_amt = (parseFloat(realtotal) * (parseFloat(Discount) / 100));
                nettotal = (parseFloat(parseFloat(realtotal) - (parseFloat(realtotal) * (parseFloat(Discount) / 100))));
                tax_amount = ((nettotal * tax_rate) / 100);
                tax_included_nettotal = parseFloat(parseFloat(nettotal) + parseFloat(tax_amount));

            }

            if (tax_type != 0 && cessRate > 0) {

                cessAmount = ((tax_amount * cessRate) / 100);
                tax_included_nettotal = parseFloat(tax_included_nettotal) + parseFloat(cessAmount);
                tax_amount = parseFloat(parseFloat(tax_amount) + parseFloat(cessAmount));
            }
            else {

                cessAmount = 0;
            }
            //tax calculation ends on 25-8-2017
            //realprice = realprice.toFixed(accuracyNum);
            html = "<tr class='classtest'>";
            html = html + "<td>" + item_code + "</td>";
            html = html + "<td>" + item_name.replace(/\u00a0/g, " "); +"</td>";
            html = html + "<td> " + parseFloat(item_sp) + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemSalePrice'); class='number-only textwidth' style=' width:98%;' value='" + realprice + "' data-initialValue='" + realprice + "' /></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemQuantity'); class='number-only textwidth' style=' width:98%;' value='" + quantity + "' data-quantityval='" + currentstock + "' data-taxRate=" + tax_rate + " data-cessRate=" + cessRate + "/></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemFoc'); class='number-only textwidth' style=' width:98%;' value='" + foc + "' data-initialValue='" + foc + "' data-netValue='" + tax_included_nettotal.toFixed(accuracyNum) + "'/></td>";
            html = html + "<td>" + realtotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + Discount + "' data-initialValue='" + Discount + "'/></td>";

            html = html + "<td>" + discount_amt.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + nettotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + tax_amount.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + tax_included_nettotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td style='display:none;'>" + itbs_id + "</td>";
            html = html + "<td style='display:none;'><input type='text' value='0' /></td>";
            html = html + "<td style='display:none;'>0</td>";
            html = html + "<td style='display:none;'>" + type + "</td>";
            html = html + "<td style='display:none;'>newItem</td>";
           
            //  html = html + "<td class='nonheadtext' style='padding:3px;display:none;'><input type='text' value='" + Discount + "'/></td>";

            //html = html + "<td></td>";
            //html = html + "<td></td>";

            html = html + "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
            html = html + "</tr>";
            //  var value = $(trCurrent).closest("tr").find(".textvalue").attr("name");
            if (trCurrent != 0 && typeof trCurrent !== 'undefined') {
                DeleteRaw(trCurrent);
            }
            //alert(html);
            AddNewRaw(html);
            popupclose('popupItems');


        }
        // Stop: Showing Details of selected  Item from Popup

        function AddNewRaw(html) {
            $('#TrSum').before(html);
            finalCalculation();
        }

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }
        function bindItemAutoComplete() {
            $("#txtNames").autocomplete({
                source: function (request, response) {
                    var BranchId = $.cookie("invntrystaffBranchId");
                    var TimeZone = $.cookie("invntryTimeZone");

                    var parUrl = "";
                    var parData = "";


                    if ($("#ItemTypecheck").prop("checked")) {
                        //SearchAutoOfferItem();
                        //alert("SearchAutoOfferItem()");
                        parData = "{'variable':'" + $("#txtNames").val() + "','BranchId':'" + BranchId + "',TimeZone:'" + TimeZone + "'}";
                        parUrl = "editorder.aspx/GetAutoOfferItem";
                    }
                    else {
                        //SearchAutoItem();
                        //alert("SearchAutoItem()");
                        parUrl = "editorder.aspx/GetAutoCompleteData";
                        parData = "{'variable':'" + $("#txtNames").val() + "','BranchId':'" + BranchId + "'}";
                    }

                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: parUrl,
                        data: parData,
                        dataType: "json",
                        success: function (data) {
                            var data1 = jQuery.parseJSON(data.d);
                            //console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    //alert(123);
                    // Prevent value from being put in the input:
                    $("#txtNames").val(ui.item.label); //ui.item is your object from the array
                    ////console.log(ui.item.value);
                    //searchCustomers(ui.item.id);
                    searchItems();
                    event.preventDefault();
                },
                minLength: 1

            });

        }

        function searchItems() {
            var memberid = custId;
            var BranchId = warehouse;
            var searchName = $("#txtNames").val();
            var customertype = customerType;
            var type;

            $("#ItemTypecheck").prop("checked") ? type = 1 : type = 0;
            $.ajax({
                type: "POST",
                url: "editorder.aspx/SearchItem",
                data: "{'searchName':'" + searchName + "',BranchId:'" + BranchId + "',type:'" + type + "',cust_id:'" + memberid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d == "N") {
                        //alert("No search Results");
                        // $("#searchTitle").show();
                    } else {
                        $("#searchTitle").hide();
                        Unloading();
                        var obj = JSON.parse(msg.d);
                        ////console.log(obj);
                        $.each(obj.data, function (i, row) {
                            if (type == "0") {
                                var amount = 0;
                                if (customertype == 1) {
                                    amount = row.itm_class_one;
                                }
                                else if (customertype == 2) {
                                    amount = row.itm_class_two;
                                }
                                else if (customertype == 3) {
                                    amount = row.itm_class_three;
                                }
                                selectOrderItem(row.itm_code, row.itm_name, amount, row.itbs_id, row.itbs_stock, row.tp_tax_percentage, row.tp_cess,row.itm_type);
                            } else if (type == "1") {
                                if (row.ofr_type == 0) {
                                    offertype = "Price/Discount Offer";
                                } else if (row.ofr_type == 1) {
                                    offertype = "Free of Cost Offer";
                                } else if (row.ofr_type == 2) {
                                    offertype = "Banded Offer";
                                }
                                selectOfferItem(row.ofr_code, row.ofr_title, row.ofr_price, row.ofr_discount, row.ofr_focqty, row.ofr_focnum, row.ofr_id, row.ofr_type);

                            }
                        });
                        $("#txtNames").val('');
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    //console.log(xhr);
                    //console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });
        }

        //function for updating order status
        function orderstatuschange(type) {
            var assignId = 0;
            var ownVehicleUsed = 0;
            var sm_vehicle_no = 0;
            var sm_delivery_vehicle_id = 0;
            if (type == 1) {
                assignId = $("#selAssignUsers").val();
                // alert(assignId);
                if (assignId == -1) {
                    alert("Choose any person for assigning");
                    return false;
                }
                if ($("#chckcmpnyVehicle").prop("checked") == false && $("#chckotherVehicle").prop("checked") == false) {
                    alert("Please select a vehicle type");
                    return false;
                }
                if ($("#chckcmpnyVehicle").prop("checked") == true) {

                    ownVehicleUsed = 1;
                    if ($("#selVehicles").val() == "-1") {

                        alert('please allot a vehicle for the delivery');
                        return;
                    } else {
                        sm_delivery_vehicle_id = $("#selVehicles").val();
                    }
                }
                if ($("#chckotherVehicle").prop("checked") == true) {
                    ownVehicleUsed = 0;
                    if ($("#txtVehicle").val() == "") {

                        alert('please enter delivery vehicle number');
                        return;
                    } else {
                        sm_vehicle_no = $("#txtVehicle").val();
                    }
                }
            }
            else if (type == 7) {
                alert("Please click the edit button for verification and approve the Bill");
                return false;
            }
            var result = confirm("Do you want to change the status?");
            if (result) {
                loading();
                $.ajax({
                    type: "POST",
                    url: "editorder.aspx/updateOrderStatus",
                    data: "{'userid':'" + $.cookie('invntrystaffId') + "','ordid':'" + BillNo + "','status':'" + type + "','TimeZone':'" + $.cookie("invntryTimeZone") + "','assignId':'" + assignId + "','sm_delivery_vehicle_id':'" + sm_delivery_vehicle_id + "','sm_vehicle_no':'" + sm_vehicle_no + "','ownVehicleUsed':'" + ownVehicleUsed + "'}",
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
                        } else {

                            alert("Bill Status Updated Successfully...");
                            window.location.href = "editorder.aspx?orderId=" + BillNo;
                            //  selectOrders();
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

        function loadBranches() {
            $.ajax({
                type: "POST",
                url: "editorder.aspx/loadBranches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--select--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#selBranches").html(htm);

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function loadAssignPersons() {
            $.ajax({
                type: "POST",
                url: "editorder.aspx/loadAssignPersons",
                data: "{'warehouse':'" + $("#selBranches").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--select--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.name + '</option>';
                    });
                    $("#selAssignUsers").html(htm);


                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function editSalesOrder() {
            sqlInjection();
            var userid = $.cookie("invntrystaffId");
            var tblrowCount = $('#tblOrderItems tr').length;
            if (tblrowCount <= 3) {
                alert("Please Add Item...");
                return;
            }
            rowCount = tblrowCount - 3;
            //  alert(rowCount);
            if (rowCount == 0) {
                alert("select an item");
                return;
            }
            if ($(document).find(".blink_text").length > 0) {
                //console.log($(document).find(".blink_text").length);
                alert("This bill contains 'New items'..please map it with existing items");
                return false;
            }
            //start json object for items in the order
            var itemstring = '';
            for (var row = 1; row <= rowCount; row++) {
                itemstring += "{";
                for (var col = 0; col <= 15; col++) {
                    if (col != 3 && col != 4 && col != 5 && col != 7 && col != 13) {

                        if (col == 12) {
                            itemstring += "'itbs_id':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 14) {
                            itemstring += "'si_approval_status':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 2) {
                            itemstring += "'si_org_price':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        } if (col == 15) {
                            itemstring += "'itm_type':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "'";
                        }

                    }
                    else {
                        if ($("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() == "") {

                            if ($("#tblOrderItems tr:eq(" + row + ") td:eq(4) input").val() == "") {
                                itemstring += "'si_qty':'1',";
                            }
                            else {
                                itemstring += "'si_qty':'0',";
                            }

                        }
                        else {
                            if (col == 3) {
                                itemstring += "'si_price':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 4) {
                                itemstring += "'si_qty':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 5) {
                                itemstring += "'si_foc':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 7) {
                                itemstring += "'si_discount_rate':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }

                            if (col == 13) {
                                itemstring += "'si_itm_type':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                        }
                    }

                }
                itemstring += "},";
            }


            var lastChar = itemstring.slice(-1);
            if (lastChar == ',') {
                itemstring = itemstring.slice(0, -1);
            }
            itemstring = "[" + itemstring + "]";
            //console.log("items:" + itemstring);
            //end json object for items in the order
            var istobeConfirm = 0;
            var isEdited = 0;
            if ($(document).find("[data-confirm=true]").length > 0 || $("#lblOrderstatus").text() == 3) {
                istobeConfirm = 1;

            }
            //start json object for editeditems in the order for history, deletedarray keeps deleted items history
            var editItemstring = '';
            if (deletedArray.length > 0) {
                isEdited = 1;
                for (var i = 0; i < deletedArray.length; i++) {
                    var obj = deletedArray[i];
                    editItemstring += "{";
                    editItemstring += "'itbs_id':'" + parseFloat($(obj).closest("tr").find('td:eq(12)').text()) + "',";
                    editItemstring += "'si_price':'" + parseFloat($(obj).closest("tr").find('td:eq(3)').find('input').attr('data-initialvalue')) + "',";
                    editItemstring += "'si_qty':'" + parseFloat($(obj).closest("tr").find('td:eq(4)').find('input').attr('data-quantityval')) + "',";
                    editItemstring += "'si_discount_rate':'" + parseFloat($(obj).closest("tr").find('td:eq(7)').find('input').attr('data-initialvalue')) + "',";
                    editItemstring += "'si_foc':'" + parseFloat($(obj).closest("tr").find('td:eq(5)').find('input').attr('data-initialvalue')) + "',";
                    editItemstring += "'si_net_amount':'" + parseFloat($(obj).closest("tr").find('td:eq(5)').find('input').attr('data-netvalue')) + "',";
                    editItemstring += "'new_si_price':'" + parseFloat($(obj).closest("tr").find('td:eq(3)').find('input').val()) + "',";
                    editItemstring += "'new_si_qty':'" + parseFloat($(obj).closest("tr").find('td:eq(4)').find('input').val()) + "',";
                    editItemstring += "'new_si_discount_rate':'" + parseFloat($(obj).closest("tr").find('td:eq(7)').find('input').val()) + "',";
                    editItemstring += "'new_si_foc':'" + parseFloat($(obj).closest("tr").find('td:eq(5)').find('input').val()) + "',";
                    editItemstring += "'new_si_net_amount':'" + parseFloat($(obj).closest("tr").find('td:eq(11)').text()) + "',";
                    editItemstring += "'edit_action':'2',";
                    editItemstring += "'edited_by':'" + userid + "',";
                    editItemstring += "'itm_tpe':'" + parseFloat($(obj).closest("tr").find('td:eq(15)').text())  + "'";
                    editItemstring += "},";
                }
            }

            for (var row = 1; row <= rowCount; row++) {
                if (($("#tblOrderItems tr:eq(" + row + ") td:eq(3) input").val() != $("#tblOrderItems tr:eq(" + row + ") td:eq(3) input").attr('data-initialvalue')) || ($("#tblOrderItems tr:eq(" + row + ") td:eq(4) input").val() != $("#tblOrderItems tr:eq(" + row + ") td:eq(4) input").attr('data-quantityval')) || ($("#tblOrderItems tr:eq(" + row + ") td:eq(5) input").val() != $("#tblOrderItems tr:eq(" + row + ") td:eq(5) input").attr('data-initialvalue')) || ($("#tblOrderItems tr:eq(" + row + ") td:eq(7) input").val() != $("#tblOrderItems tr:eq(" + row + ") td:eq(7) input").attr('data-initialvalue'))) {
                    isEdited = 1;
                    editItemstring += "{";
                    editItemstring += "'itbs_id':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(12)").text() + "',";
                    editItemstring += "'si_price':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(3) input").attr('data-initialvalue') + "',";
                    editItemstring += "'si_qty':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(4) input").val() + "',";
                    editItemstring += "'si_discount_rate':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(7) input").attr('data-initialvalue') + "',";
                    editItemstring += "'si_foc':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(5) input").attr('data-initialvalue') + "',";
                    editItemstring += "'si_net_amount':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(5) input").attr('data-netvalue') + "',";
                    editItemstring += "'new_si_price':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(3) input").val() + "',";
                    editItemstring += "'new_si_qty':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(4) input").val() + "',";
                    editItemstring += "'new_si_discount_rate':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(7) input").val() + "',";
                    editItemstring += "'new_si_foc':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(5) input").val() + "',";
                    editItemstring += "'new_si_net_amount':'" + $("#tblOrderItems tr:eq(" + row + ") td:eq(11)").text() + "',";
                    if ($("#tblOrderItems tr:eq(" + row + ") td:eq(16)").text() == "newItem") {
                        editItemstring += "'edit_action':'3',";
                    } else {
                        editItemstring += "'edit_action':'1',";
                    }
                    editItemstring += "'edited_by':'" + userid + "',";
                    editItemstring += "'itm_tpe':'" + parseFloat($(obj).closest("tr").find('td:eq(15)').text())  + "'";
                    editItemstring += "},";
                }
            }

            var editedSTring = editItemstring.slice(-1);
            if (editedSTring == ',') {
                editItemstring = editItemstring.slice(0, -1);
            }
            editItemstring = "[" + editItemstring + "]";
            console.log("edited:" + editItemstring);
            //end json object for editeditems in the order for history, deleted array keeps deleted items history

            //process date
            var processDate = $("#txtProcessDate").val();
            var processTime = $("#txtProcessTime").val();
            if (processDate != "") {
                var splitarray = processDate.split("-");
                processDate = splitarray[2] + "/" + splitarray[1] + "/" + splitarray[0];
            }

            if (processTime != "") {
                var splitAmPm = processTime.split(" ");
                var splittime = splitAmPm[0].split(":");
                if (splitAmPm[1] == "AM" && splittime[0] == "12") {
                    splittime[0] = "00";
                } else if (splitAmPm[1] == "AM" && splittime[0] != "12") {
                    splittime[0] = splittime[0];
                }
                else if (splitAmPm[1] == "PM" && splittime[0] == "12") {
                    splittime[0] = "12";
                } else {
                    splittime[0] = parseInt(splittime[0]) + 12;
                }
                processTime = splittime[0] + ":" + splittime[1] + ":00";
            }
            else {
                processTime = processTime;
            }
            //process date
            var postObj = {

                editedorder: {

                    sm_id: $("#txtBillRefNo").text(),
                    cust_id: $("#txtMemberId").text(),
                    user_id: userid,
                    sm_delivery_status: $("#lblOrderstatus").text(),
                    istobeConfirm: istobeConfirm,
                    isEdited: isEdited,
                    items_after_edit: itemstring,
                    editedItems: editItemstring,
                    specialNote:$("#txtSpecialNote").val(),
                    processedDate:processDate,
                    processedTime:processTime,
                    lastUpdatedDate:lastUpdatedDate
                }
                //item_details: item_list

            };
            //console.log(JSON.stringify(postObj));

            $.ajax({
                type: "POST",
                url: "editorder.aspx/editOrder",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                timeout: 45000,
                success: function (msg) {
                    Unloading();
                    if (msg.d == "SUCCESS") {
                        alert("Order edited successfully...");
                        window.location.href = "orders.aspx";
                        return;
                    } else if(msg.d=="E"){
                        var result = confirm("Some One already changed the page..Do you want to reload and continue ?");
                        if(result){
                            window.location.reload();
                        }else{
                            return;
                        }
                    } 
                    else {
                        alert("Error!.. Please Try Again...");
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function loadVehicles() {
            if ($("#chckcmpnyVehicle").prop("checked") == true) {
                $.ajax({
                    type: "POST",
                    url: "editorder.aspx/loadVehicles",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        var obj = JSON.parse(msg.d);
                        var htm = "";
                        htm += '<option value="-1" selected="selected">--select--</option>';
                        $.each(obj, function (i, row) {
                            htm += '<option value="' + row.user_id + '">' + row.name + '</option>';
                        });
                        $("#selVehicles").html(htm);
                        $("#divCmpnyVehicle").show();
                        $("#divVehicleText").hide();
                        $('#chckotherVehicle').attr('checked', false);

                    },
                    error: function (xhr, status) {
                        Unloading();
                        // alert("fail" + status + ":::" + xhr.d);
                        alert("Internet Problem..!");
                    }
                });
            } else {
                $("#divCmpnyVehicle").hide();
                $("#divVehicleText").hide();
                $('#chckotherVehicle').attr('checked', false);
            }
        }

        function showVehicleDiv() {
            if ($("#chckotherVehicle").prop("checked") == true) {
                $("#divVehicleText").show();
                $("#divCmpnyVehicle").hide();
                $('#chckcmpnyVehicle').attr('checked', false);
            } else {
                $("#divVehicleText").hide();
                $("#divCmpnyVehicle").hide();
                $('#chckcmpnyVehicle').attr('checked', false);
            }
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
            <!-- top navigation -->
            <div class="top_nav">
                <div class="nav_menu">
                    <nav>

                        <div class="navbar-header" style="width: 100%; display: flex; align-items: center">
                            <div class="nav toggle" style="padding: 5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <label style="font-weight: bold; font-size: 16px;">Edit Bill</label>
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
                                    Bill<label id="lblInvoiceNum"></label>
                                    (<label id="txtBillRefNo"></label>)<a id="txtLabelStatus"></a><label style="display: none;" id="lblOrderstatus"></label>

                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>

                                </div>
                                <div class="x_content">
                                    <!-- info row -->
                                    <div class="col-md-5 col-sm-6 col-xs-12">
              
                             <div class="col-md-5 col-sm-6 col-xs-12">
                                           <input type="text" id="txtProcessDate" placeholder="Choose Date" class="form-control has-feedback-left" style="height: 28px;" readonly="">
                                 <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>

                                        </div>
                                                                     <div class="col-md-4 col-sm-6 col-xs-12">
                                           <input type="text" id="txtProcessTime" placeholder="Choose Date" class="form-control has-feedback-left" style="height: 28px;" readonly="">
                                 <span class="fa fa-clock-o form-control-feedback left" aria-hidden="true"></span>

                                        </div>
                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-5 invoice-col">
                                            <b>Customer :</b><a style="text-decoration: underline" href="" id="hrefCustomer" target="_blank">#<span id="txtMemberId"></span></a>&nbsp;<label id="txtMemberName"></label>(class <span id="txtClassType"></span>)
                                        </div>
                                        <!-- /.col -->

                                    

                                        <div class="col-sm-2 invoice-col">
                                            <b>Account Balance:</b><label id="lbloutstanding" style="color: #432727; font-weight: bold; font-size: 12px; color: red;">0</label>
                                        </div>
                                        <!-- /.col -->
                                        <div class="row" style="margin-top: 10px;display:none;">
                                            <div class="col-sm-6 col-sm-offset-6 " style="padding-right: 50px;">
                                                <div class="btn btn-danger pull-right mybtnstyl" id="divCancel" style="display: none;" onclick="orderstatuschange(4)">Cancel</div>
                                                <div class="btn btn-primary pull-right mybtnstyl" id="divAssign" style="display: none;" onclick="" data-toggle="modal" data-target="#popupAssign">Assign</div>
                                                <div class="btn btn-warning pull-right mybtnstyl" id="divNew" style="display: none;" onclick="orderstatuschange(0)">New</div>
                                                <div class="btn btn-success pull-right mybtnstyl" id="divDeliver" style="display: none;" onclick="orderstatuschange(2)">Deliver</div>
                                                <div class="btn btn-success pull-right mybtnstyl" id="divApprove" style="display: none;" onclick="orderstatuschange(7)">Approve</div>
                                                <div class="btn btn-danger pull-right mybtnstyl" id="divReject" style="display: none;" onclick="orderstatuschange(5)">Reject</div>
                                                <div class="btn btn-default pull-right mybtnstyl" id="divPending" style="display: none;" onclick="orderstatuschange(6)">Pending</div>
                                                <div class="btn btn-default pull-right mybtnstyl" id="divConfirm" style="display: none; background-color: #6facd5; color: #ffffff" onclick="orderstatuschange(3)">To be confirm</div>
                                            </div>
                                        </div>

                                        <!-- /.col -->
                                    </div>

                                    <!-- Modal -->
                                    <div class="modal fade" id="popupAssign" role="dialog">
                                        <div class="modal-dialog modal-md" style="">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header" style="padding-bottom: 5px;">
                                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                                        <h4 class="modal-title">Assign</h4>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; margin-top: 5px;">
                                                    <div class="x_content">
                                                        <div class="col-md-12 col-sm-12 col-xs-12 ">
                                                            <form class="form-horizontal form-label-left">

                                                                <div class="form-group">
                                                                    <label class="col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                                        Person for delivery:
                                                                    </label>
                                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                                        <div id="Div2">
                                                                            <select id="selAssignUsers" class="form-control">
                                                                                <option value="0">--Select--</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="form-group">
                                                                    <label class="col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                                        Vechicle Type:
                                                                    </label>
                                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                                        Company Vehicle
                                                                        <input type="checkbox" value="" id="chckcmpnyVehicle" onclick="javascript: loadVehicles();">
                                                                        Other Vehicle
                                                                        <input type="checkbox" value="" id="chckotherVehicle" onclick="javascript: showVehicleDiv();">
                                                                    </div>

                                                                </div>
                                                                <div class="form-group" style="display: none;" id="divCmpnyVehicle">

                                                                    <label class="col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                                        Select Vechicle:
                                                                    </label>
                                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                                        <div>
                                                                            <select id="selVehicles" class="form-control">
                                                                                <option value="0">--Select--</option>
                                                                            </select>
                                                                        </div>
                                                                    </div>

                                                                </div>
                                                                <div class="form-group" style="display: none;" id="divVehicleText">

                                                                    <label class="col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                                        Vehicle No:
                                                                    </label>
                                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                                        <input type="text" id="txtVehicle" placeholder="enter vehicle number" class="form-control" style="height: 25px;" />
                                                                    </div>

                                                                </div>
                                                                <div class="clearfix"></div>

                                                            </form>

                                                        </div>

                                                    </div>
                                                </div>
                                                <div class="clearfix"></div>
                                                <div class="ln_solid"></div>
                                                <div class="form-group" style="padding-bottom: 40px;">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-5">

                                                        <div class="btn btn-success mybtnstyl" onclick="javascript:orderstatuschange(1);">
                                                            Assign
                                                        </div>

                                                    </div>
                                                </div>
                                            </div>

                                        </div>
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
                                    <label>Items</label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>
                                </div>

                                <%--<div class="row">
					<div class="col-sm-6">
					<div class="dataTables_length" id="datatable-checkbox_length">
                        <label>
                         <select name="datatable-checkbox_length" aria-controls="datatable-checkbox" class="form-control input-sm">
                             <option value="10">10</option>
                             <option value="25">25</option>
                             <option value="50">50</option>
                             <option value="100">100</option>
                         </select> 
                        </label>
					</div>
					</div>
					
					<div class="form-group"  style="float:right;">
								<div class="col-md-12 col-sm-12 col-xs-12 ">
								  <button type="submit" class="btn btn-success">
								  <li class="fa fa-search" style="margin-right:5px;"></li>Search
								  </button>
								     <button class="btn btn-primary" type="reset">
									 <li class="fa fa-refresh" style="margin-right:5px;"></li>Reset
									 </button>
								</div>
							  </div>
					</div>--%>
                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="col-md-6 col-sm-6 col-xs-12 pull-right" style="padding-right: 0px;">
                                        <div class="col-md-10 col-sm-6 col-xs-8">
                                            <input type="search" class="form-control" placeholder="Search Item" id="txtNames" />
                                        </div>
                                        <div class="col-md-2 col-sm-6 col-xs-4 " onclick="javascript:checksearchItems();" style="padding-right: 0px;">
                                            <div class="" style="font-size: 28px;" data-toggle="modal">
                                                <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                                <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                            </div>

                                        </div>
                                        <%-- pop up for show normal items --%>
                                        <div class="container">


                                            <div class="modal fade" id="popupItems" role="dialog">
                                                <div class="modal-dialog modal-lg" style="">

                                                    <!-- Modal content-->
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <button type="button" class="close" onclick="javascript:popupclose('popupItems');">&times;</button>
                                                            <div class="col-md-6 col-sm-6 col-xs-6">
                                                                <h4 class="modal-title">Search Items</h4>
                                                            </div>
                                                            <div class="col-md-5 col-sm-4 col-xs-12">
                                                                <div class="col-md-4 col-sm-12 col-xs-8">
                                                                    <label>Total Records: </label>
                                                                    <label id="lblItemTotalrecords">20</label>
                                                                </div>
                                                                <div class="col-md-2 col-sm-12 col-xs-3">
                                                                    <select id="txtpospageno" onchange="javascript:searchOrderitem(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                        <option value="50">50</option>
                                                                        <option value="100">100</option>
                                                                        <option value="250">250</option>
                                                                        <option value="500">500</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-6 col-sm-12 col-xs-12">
                                                                    <div class="" onclick="javascript:searchOrderitem(1);">
                                                                        <button type="button" class="btn btn-success mybtnstyl">
                                                                            <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                            Search
                                                                        </button>
                                                                    </div>
                                                                    <div class="" onclick="javascript:searchOrderitems();">
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

                                                                <table id="tablePos" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Item Code</th>
                                                                            <th>Item Name</th>
                                                                            <th>Brand/Category</th>
                                                                            <th>Stock</th>
                                                                            <th>Maximum Retail Price</th>

                                                                        </tr>


                                                                        <tr>
                                                                            <td>
                                                                                <input type="text" class="form-control" id="searchposContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                            <td>
                                                                                <input type="text" id="searchposContent2" class="form-control" /></td>
                                                                            <td></td>
                                                                            <td></td>
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
                                    <div class="x_content">

                                        <table id="tblOrderItems" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <tbody>
                                                <tr>
                                                    <td>Item Code</td>
                                                    <td style="width: 300px;">Name</td>
                                                    <td>RealPrice	</td>
                                                    <td>SalePrice</td>
                                                    <td>QTY</td>
                                                    <td>FOC</td>
                                                    <td>Amt</td>
                                                    <td>Dis %</td>
                                                    <td>Dis Amt</td>
                                                    <td>Taxable Value</td>
                                                    <td>Tax Amt</td>
                                                    <td>Net Amt</td>
                                                    <%--  <td>Paid</td>
                                                    <td>Balance</td>--%>
                                                    <td></td>

                                                </tr>


                                                <tr id="TrSum">
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="text-align: right;"><b>Total</b></td>
                                                    <td></td>
                                                    <td id="txtposTotalCost"></td>
                                                    <td id="txtTotalDiscountRate"></td>
                                                    <td id="txtTotalDiscountAmount"></td>
                                                    <td id="txtTotalNetAmount"></td>
                                                    <td id="txtTotalTaxAmount"></td>
                                                    <td id="txtTotalBillAmount"></td>
                                                    <td></td>
                                                    <%--   <td></td>
                                                    <td></td>--%>
                                                </tr>
                                                <tr>
                                                    <td colspan="5"></td>
                                                    <td></td>
                                                    <td></td>
                                                    <%--<td><b>Round</b></td>--%>
                                                    <td></td>
                                                    <td></td>

                                                    <td></td>
                                                    <td></td>
                                                    <td>
                                                        <label id="txtTotalGrossamount"></label>
                                                    </td>
                                                    <%--<td>
                                                        <input type="text" class="textwidth" id="" onkeyup='calculteTable();' style="width: 98%; background: none; border: none;" disabled /></td>
                                                    <td>
                                                        <input type="text" class="textwidth" id="" style="width: 98%; background: none; border: none;" disabled /></td>--%>
                                                    <td></td>

                                                </tr>
                                            </tbody>

                                        </table>
                                         <div class="col-md-8 col-sm-6 col-xs-12"><b>Special Notes</b> </div>
                                        <div class="clearfix"></div>

                                        <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px; padding-right:0px;">
                                            <textarea id="txtSpecialNote" class="form-control" style="resize: none;height:100px;"></textarea>
                                        </div>

                                      
                                        <div class="col-md-1 col-sm-3 col-xs-3" style="float: right; margin-top:15px;" id="divsaveorder" onclick="javascript:editSalesOrder();">
                                            <button class="btn btn-primary mybtnstyl pull-right" type="button">Save</button>
                                        </div>

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
