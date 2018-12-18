<%@ Page Language="C#" AutoEventWireup="true" CodeFile="editExpense.aspx.cs" Inherits="incomExpense_editExpense" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Edit Expense  | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script src="../js/pagination.js" type="text/javascript"></script>
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css"/>
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
                location.href = "listExpenseEntries.aspx";
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
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#popupChequeDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'yy-mm-dd'
                
            });



            //call to select order details
            retrieveExpenseDetail();
            
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
                        url: "editExpense.aspx/GetAutoCompleteItemData",
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
        function retrieveExpenseDetail() {
            //  alert(paid);
            loading();

            $.ajax({
                type: "POST",
                url: "editExpense.aspx/retrieveData",
                data: "{'expenseId':'" + purchaseId + "'}",
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
                    $("#txtTotalNetAmount").text(entry_details.total_amount);
                    $("#txtTotalDiscountRate").text(entry_details.ie_discount_rate);
                    $("#txtTotalDiscountAmount").text(entry_details.ie_discount_amt);
                   // $("#txtPaidAmount").val(entry_details.pm_paidamount);
                    $("#txtBalanceAmount").val(entry_details.ie_total_balance);
                    $("#txtTotalNetAmount").text(entry_details.ie_netamount);
                    $("#txtTotalNetAmount").text(entry_details.total_amount);
                    $("#txtTotalTaxamt").text(entry_details.tax_amount);
                    $("#txtEntryRefNo").val(entry_details.ie_invoice_num);
                    $("#txtVendorName").text(entry_details.ext_user_name);
                    $("#txtVendorId").text(entry_details.ext_user_id);
                    $("#txtEntryDate").text(entry_details.date);
                    branchId=entry_details.branch_id;
                    taxType=entry_details.branch_tax_method;
                    branchName=entry_details.branch_name;
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

                    $("#txtTotalCurrentAmount").val('0');
                  
                    $("#txtSpecialNote").val(entry_details.pm_note);

                    // showing order_items
                    $("#tbodyItems").html("");
                    $.each(entryObj.items, function (i, item) {
                        var htmItemRow = '';
                        htmItemRow += '<tr>';
                        
                        htmItemRow += '<td>' + item.ie_category + '</td>';
                        htmItemRow += "<td><input type='number' id='txtbillamount' onkeyup=modifyValues(this,'ItemPrice'); class='number-only textwidth' style=' width:98%;' value='" + item.ie_total + "' data-initialValue='0' /></td>";
                        htmItemRow += "<td><input type='number' id='txtTotalDiscountRate' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + item.ie_discount_rate + "' data-initialValue='0'/></td>";
                        htmItemRow += "<td id='txtTotalDiscountAmount'>" + item.ie_discount_amt + "</td>";
                        htmItemRow += "<td><input type='text' id='txtTotalTaxamt' onkeyup=modifyValues(this,'ItemTax'); class='number-only textwidth' style=' width:98%;' value='" + item.ie_tax + "' data-taxval='0'/></td>";
                        htmItemRow += "<td id='txtTotalNetAmount'>" + item.ie_netamount + "</td>";
                        htmItemRow += "<td style='display:none;'>" + item.itm_id + "</td>";
                 
                       // htmItemRow += "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";

                        htmItemRow += '</tr>';
                        $("#tbodyItems").append(htmItemRow);
                    });


                    $("#tblPayments > tbody").html("");
                    $.each(entryObj.transaction_details, function (i, row) {
                        console.log(row);
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


                        htmPaymentDetails += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                        htmPaymentDetails += '<td align="center">' +
                            '<div onclick="showTransactionDetailsTxt(' + row.id + ')" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;"></li></div>' +
                       
                            '</td>';
                        htmPaymentDetails += '</tr>';

                        $("#tblPayments > tbody").append(htmPaymentDetails);
                    });
                    //loadTaxes(taxType);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        // Stop: Showing Details of selected Outsatnding Bill from Popup
        
        //showing transaction details
        function showTransactionDetailsEdit(trans_id) {
            var transaction = entryObj.transaction_details.find(x=>x.id == trans_id);
            var entry_details = entryObj.entry[0];
            $("#lblTransRef").text(transaction.id);
            $("#transAmount").text((transaction.dr != 0 ? transaction.dr : transaction.cr));
            $("#transDate").text(transaction.date);
            $("#transType").text((transaction.dr != 0 ? "Debit" : "Credit"));
            $("#transUserName").text(transaction.user_name);
            $("#transNarration").text(transaction.narration);
            $("#cashAmt").val(transaction.cash_amt);
            $("#walletAmt").text(transaction.wallet_amt);
            $("#chequeAmt").val(transaction.cheque_amt);
            $("#chequeNo").val(transaction.cheque_no);
            $("#chequeDate").val(transaction.cheque_date);
            $("#chequeBank").val(transaction.cheque_bank);
            $("#popupChequeDate").val(transaction.cheque_date);
            $("#txtInvoiceNum").text(entry_details.ie_invoice_num);
            //alert(entry_details.ie_invoice_num);
            $("#popupTransactionEdit").modal('show');
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





        function showTransactionDetailsTxt(trans_id) {
            var transaction = entryObj.transaction_details.find(x=>x.id == trans_id);
            $("#lblTransRef").text(transaction.id);
            $("#transAmountTxt").text((transaction.dr != 0 ? transaction.dr : transaction.cr));
            $("#transDateTxt").text(transaction.date);
            $("#transTypeTxt").text((transaction.dr != 0 ? "Debit" : "Credit"));
            $("#transUserNameTxt").text(transaction.user_name);
            $("#transNarrationTxt").text(transaction.narration);
            $("#cashAmtTxt").text(transaction.cash_amt);
            $("#walletAmtTxt").text(transaction.wallet_amt);
            $("#chequeAmtTxt").text(transaction.cheque_amt);
            $("#chequeNoTxt").text(transaction.cheque_no);
            $("#chequeDateTxt").text(transaction.cheque_date);
            $("#chequeBankTxt").text(transaction.cheque_bank);                   
            if (transaction.cheque_no == null) { $("#chequeNoTxt").text("xxxx") }
            else { $("#chequeNoTxt").text(transaction.cheque_no); }
            if (transaction.cheque_date == null) { $("#chequeDateTxt").text("xxxx") }
            else { $("#chequeDateTxt").text(transaction.cheque_date); }
            if (transaction.cheque_bank == null) { $("#chequeBankTxt").text("xxxx") }
            else { $("#chequeBankTxt").text(transaction.cheque_bank); }
            $("#popupTransaction").modal('show');
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
                url: "editExpense.aspx/savePaymentEdit",
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
            //start check number only
            $('.number-only').keyup(function (e) {
                if (this.value != '-')
                    while (isNaN(this.value))
                        this.value = this.value.split('').reverse().join('').replace(/[\D]/i, '')
                                               .split('').reverse().join('');
            })
             .on("cut copy paste", function (e) {
                 e.preventDefault();
             });
            //end check number only


            if($('#txtbillamount').val()==""){$('#txtbillamount').val(0)}
            if($('#txtTotalDiscountRate').val()==""){$('#txtTotalDiscountRate').val(0)}
            if($('#txtTotalTaxamt').val()==""){$('#txtTotalTaxamt').val(0)}
           
            if (thisRowId != "1") {
                var rowId = $(thisRowId).closest('td').parent()[0].sectionRowIndex;
                
            }
            else {
                var rowId = thisRowId;
            }
            var unit_price = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(1)').find('input').val());//price
           
            var item_qty = 1;
            var bill_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(1)').find('input').val());//amount
            var discnt_percent = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(2)').find('input').val());//dis %
            var discnt_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(3)').text());//dis amount
            var tax_amt = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(4)').find('input').val());//tax amount
            var net_amount = $.trim($('#tblPurchaseItems > tbody tr:eq(' + rowId + ') td:eq(5)').text());//net amount
            
            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
            var regexamount = new RegExp(/^\+?[0-9(),.]+$/);
         
            var totalDiscount=$('#txtTotalDiscountAmount').text(((discnt_percent/100)*bill_amount).toFixed(2)).text();
            
            var totalNetamount=$('#txtTotalNetAmount').text((parseFloat(bill_amount)+parseFloat(tax_amt))-parseFloat(totalDiscount));
           
           
        }

       
        function DeleteRaw(ctrl) {

            $(ctrl).closest('tr').remove();
            var rowCount = parseInt($('#tblPurchaseItems tr').length);
            if (rowCount <= 1) {
                //  $("#TrSum").text('');
                $("#txtTotalNetAmount").text(0.0);
                $("#txtTotalDiscountRate").text(0.0);
                $("#txtTotalDiscountAmount").text(0.0);
                $("#txtTotalNetAmount").text(0.0);
               // $("#txtTotalNetAmount").text(0.0);
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
                     
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itemname = $("#searchposContent2").val();
            }

            
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itemcode = $("#searchposContent1").val();
            }
            
            filters.warehouse = branchId;
            
            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
           
            loading();

            $.ajax({
                type: "POST",
                url: "editExpense.aspx/searchOrderitems",
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
            
            var html = '';
            var rowCount = $('#tblPurchaseItems > tbody tr').length;    
            rowposition = rowCount - 2;
            for (i = 1; i <= rowposition; i++) {
                var currentId = $.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(9)').text());
               
                if (currentId == id) {
                    $("#itemNames").val("");
                    alert("This item already selected");
                    return false;
                }

            }
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

        function updateExpense() {

            sqlInjection();
            var filters = {};
            filters.TimeZone = $.cookie("invntryTimeZone");
            filters.userid = $.cookie("invntrystaffId");
            filters.externalUserId = $("#txtVendorId").text();
          
            filters.purchaseId = purchaseId;
            filters.invoicenum = $("#txtEntryRefNo").val();
           
            filters.TotalAmount = $("#txtbillamount").val();
            filters.TotalDiscountRate = $("#txtTotalDiscountRate").val();
            
            filters.TotalDiscountAmount = $("#txtTotalDiscountAmount").text();
            filters.totalTaxamt = $("#txtTotalTaxamt").val();
            filters.TotalNetAmount = $("#txtTotalNetAmount").text();
            

            filters.rowCount = $('#tblPurchaseItems tr').length;
            filters.rowCount = filters.rowCount - 3;
           
            filters.warehouse = branchId;
            var query = '';
       

           
            bootbox.confirm("Do you want to continue?", function (result) {
                console.log(JSON.stringify(filters));
                if (result) {
                    loading();
                    $.ajax({
                        type: "POST",
                        url: "editExpense.aspx/updateExpense",
                        data: "{'filters':" + JSON.stringify(filters)+"}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "N") {
                                alert("Error!.. Please Try Again...");
                                return;
                            } else {
                                alert("Entry edited successfully");
                                window.location.href = "editExpense.aspx";
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
            
        }

        function loadTaxes() {            
            loading();
            $.ajax({
                type: "POST",
                url: "editExpense.aspx/loadTaxes",
                data: "{'taxType':" + taxType + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    
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
                url: "editExpense.aspx/addBranchStockDetails",
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



        function updateTransaction() {

            if ($('#chequeAmt').val() > 0)
            { 
                if ($('#chequeNo').val() == "" || ($('#chequeBank').val() == "") || $('#chequeDate').val() == "")
                {
                    alert("Give All Cheque Credentials")
                    return;
                }
            }
            bootbox.confirm("Do you want to continue?", function (result) {
                var filters = {};
                totalAmt = parseFloat($('#cashAmt').val()) + parseFloat($('#chequeAmt').val());
                
                filters.totalAmt = totalAmt;
                filters.cashAmt = $('#cashAmt').val();
                filters.chequeAmt = $('#chequeAmt').val();
                filters.chequeNo = $('#chequeNo').val();
                filters.popupChequeDate = $('#popupChequeDate').val();
                filters.chequeBank = $('#chequeBank').val();
                filters.transId = $("#lblTransRef").text();
                filters.externalUserId = $("#txtVendorId").text();
                filters.invoiceNum = $('#txtInvoiceNum').text();
               
                loading();

                $.ajax({
                    type: "POST",
                    url: "editExpense.aspx/updateTransaction",
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
                            location.href = "editExpense.aspx?purchaseId=" + purchaseId + "";
                            return false;
                        }
                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("2...Internet Problem..!");
                    }
                });

            });
        }

        function popupAmountValidation() {
            $('.number-only').keyup(function (e) {
                if (this.value != '-')
                    while (isNaN(this.value))
                        this.value = this.value.split('').reverse().join('').replace(/[\D]/i, '')
                                               .split('').reverse().join('');
            })
           .on("cut copy paste", function (e) {
               e.preventDefault();
           });
        }

    </script>

    
    <style>
        .modal
        {
            overflow: auto !important;
        }
/*To Remove UpDown Arrows of input type=number*/
        input[type=number]::-webkit-inner-spin-button, 
    input[type=number]::-webkit-outer-spin-button { 
    -webkit-appearance: none;
    -moz-appearance: none;
    -appearance: none;
    margin: 0; 
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
                            <label style="font-weight: bold; font-size: 16px;">Edit Expense</label>
                          
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                   
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
                                            <label>Bill No:</label><input type="text" id="txtEntryRefNo" style="width: 60px;font-weight:bold"/>
                                           

                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-4 invoice-col">

                                            <b><span title="City" class="fa fa-calendar"></span>
                                                <label id="txtEntryDate">24-Feb-2017</label></b>

                                        </div>
                                        <!-- /.col -->

                                        <div class="col-sm-4 invoice-col">
                                            <label id="txtVendorName">Istanbul Supermarket Ajman</label>
                                            <label id="txtVendorId" style="display:none;"></label>
                                        </div>
                                        <!-- /.col -->
                                       
                                         <div class="col-sm-2 invoice-col">
                                            <label id="Label1">Balance To Pay:</label>
                                            <label id="txtBalance" style=";">0</label>
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
                                                    
                                                    <td style="width: 300px;">Name</td>
                                                    
                                                    
                                                    <td>Bill Amount</td>
                                                    <td>Dis %</td>
                                                    <td>Dis Amount</td>
                                                    <td>Tax Amount</td>
                                                    <td>Net Amount</td>
                                                   
                                             

                                                </tr>
                                            </thead>


                                            <tbody id="tbodyItems">
                                               
                                            </tbody>
                                            <tbody id="tbodyPayments">
                                               
                                             <tr style="display:none;">
                                                    <td colspan="4"></td>
                                                    
                                                    <td></td>

                                                    <td></td>
                                                    <td></td>
                                                   
                                            

                                                </tr>
                                            </tbody>



                                        </table>
                                         <div class="col-md-1 col-sm-3 col-xs-3" style="float: right;" id="divUpdateOrder" onclick="javascript:updateExpense();">
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
                    <%-- popup for Editing transaction details --%>
                    <div class="modal fade" id="popupTransactionEdit" role="dialog">
                        <div class="modal-dialog modal-md" style="">

                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                                  <h4 class="modal-title">Transaction #<span id="lblTransRef"></span></h4>
                                        <input type="hidden" id="txtInvoiceNum"/>
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
                                        <%--<div style="margin-left:10px;">Amount :<span id="cashAmt">0</span></div><br />--%>
                                        <%--<div style="margin-left:10px;">Amount :<input type="text" id="cashAmt" style="width:40px"></input></div><br />--%>

                                         <div class="clearfix"></div>
                            <div class="col-md-3 col-sm-6 col-xs-12">Amount</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                         <input type="text" id="cashAmt" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:popupAmountValidation();" value="0"/>
                            </div>
                                       <div class="clearfix"></div>
                                       
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                        <b>Wallet</b><br />
                                        <div style="margin-left:10px;">Amount :<span id="walletAmt">0</span></div>
                                </div>
                                    </div>
                                    <div class="col-md-6" style="margin-bottom:10px;">
                                        <b>Cheque</b><br />
                                       

                                         <div class="clearfix"></div>
                            <div class="col-md-3 col-sm-6 col-xs-12">Amount</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                         <input type="text" id="chequeAmt" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:popupAmountValidation();" value="0"/>
                            </div>

                                         <div class="clearfix"></div>
                            <div class="col-md-3 col-sm-6 col-xs-12">Number</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                         <input type="text" id="chequeNo" class="form-control textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Chq. No." onkeyup="" value="0"/>
                            </div>
                                      
                                        <div class="clearfix"></div>
                                        <div class="col-md-3 col-sm-6 col-xs-6 form-group has-feedback">Date</div>
                                         <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="text" id="popupChequeDate" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="" readonly=""/>
                                <%--<span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>--%>
                                      </div>


                                         <div class="clearfix"></div>
                            <div class="col-md-3 col-sm-6 col-xs-12">Bank</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                         <input type="text" id="chequeBank" class="form-control textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bnk. Name" onkeyup="" value="0"/>
                            </div>

                                         
                                    
                                    </div>
                                    
                                </div>
                               <%-- <div>HI</div>--%>
                                <div class="col-sm-2 invoice-col">
                                            <button class="btn btn-primary mybtnstyl" onclick="javascript:updateTransaction();" style="display:;" id="btnPopupUpdate">
                                              UPDATE</button>
                                </div>
                                <div class="col-sm-2 invoice-col">
                                 <button class="btn btn-danger mybtnstyl" data-dismiss="modal" onclick="" style="display:;" id="btnPopupCancel">
                                             CANCEL</button>
                                    </div>
                                <div class="clearfix"></div>
                                <div class="ln_solid"></div>
                            </div>

                        </div>
                    </div>

                    <div class="clearfix"></div>
                    
                        
                        <%-- popup for showing payment edit popup --%>
                     <div class="modal fade" id="popupTransaction" role="dialog">
                        <div class="modal-dialog modal-md" style="">

                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                        <h4 class="modal-title">Transaction #<span id="lblTransRefTxt"></span></h4>
                                    </div>
                                </div>
                                <div class="x_content">
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Amount :</b><span id="transAmountTxt"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Date :</b><span id="transDateTxt"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>Type :</b><span id="transTypeTxt"></span></div>
                                    <div class="col-md-6" style="margin-bottom:10px;"><b>User :</b><span id="transUserNameTxt"></span></div>
                                    <div class="col-md-12"><b>Narration :</b><p id="transNarrationTxt" style="text-indent:20px;"></p></div>
                                    <div class="col-md-6" style="margin-bottom:10px;">
                                        <b>Cash</b><br />
                                        <div style="margin-left:10px;">Amount :<span id="cashAmtTxt">0</span></div><br />
                                        <b>Wallet</b><br />
                                        <div style="margin-left:10px;">Amount :<span id="walletAmtTxt">0</span></div>
                                    </div>
                                    <div class="col-md-6" style="margin-bottom:10px;">
                                        <b>Cheque</b><br />
                                        <div style="margin-left: 10px;">
                                            Amount :<span id="chequeAmtTxt">0</span><br />
                                            number :<span id="chequeNoTxt"></span><br />
                                            Date :<span id="chequeDateTxt"></span><br />
                                            Bank :<span id="chequeBankTxt"></span>
                                        </div>
                                    </div>
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
