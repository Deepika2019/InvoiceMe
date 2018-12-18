<%@ Page Language="C#" AutoEventWireup="true" CodeFile="expense.aspx.cs" Inherits="expense" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Expense Entry  | Invoice Me</title>

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
        var vendorid = 0;
        var itm_id = 0;
        $(document).ready(function () {
           
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
            var dt = new Date();
            day = dt.getDate();
            month = dt.getMonth() + 1;
            if (day.toString().length <= 1) {
                day = '0' + day;
            }
            if (month.toString().length <= 1) {
                month = '0' + month;
            }
            cur_dat = dt.getFullYear() + '-' + month + '-' + day;
            $("#txtpurchaseDate").val(cur_dat);
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");
            
            SearchAutoVendor();
           
            showBranches();
            $("#vendorNames").val("");
            $("#txtinvoiceId").val("");
            $("#itemNames").val("");

            //datepicker
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#txtpurchaseDate').scroller({
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
            // showWarehouses();
            disablepayment();
            getUserTypes();

        });

        //function for load branches
        function showBranches() {
            //alert("");
            //  var loggedInBranch = $.cookie("staffBranchId");
            loading();
            $.ajax({
                type: "POST",
                url: "expense.aspx/showBranches",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "" || msg.d == "N") {
                        return;
                    }
                    else {

                        $("#warehousediv").html(msg.d);
                       // loadTaxes(-1);
                        // searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    
                    alert("Internet Problem..!");
                }
            });
        }

       
        //auto populate in vendor search
        function SearchAutoVendor() {
            $("#vendorNames").keyup(function () {
                //alert("ch");
                if ($("#servicediv").val() == -1) {
                    alert("Select a category");
                    $("#vendorNames").val("");
                    return;
                }
                if ($("#vendorNames").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });
            //$("#servicediv").val();
            $("#vendorNames").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "expense.aspx/GetAutoCompleteVendorData",
                        data: "{'variable':'" + $("#vendorNames").val() + "','usertype':'" + $("#servicediv").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    if (ui.item.id == -1) {
                        $("#vendorNames").val("");
                    } else {
                        $("#vendorNames").val(ui.item.label);
                        vendorid = ui.item.id;
                        selectVendor(vendorid);
                    }

                    event.preventDefault();
                },
                minLength: 1

            });
        }

        //function for select vendor
        function selectVendor(id) {

            vendorid = id;
            popupclose("popupVendors");


            $("#divVendorField").hide();
            $("#divVendorIcon").hide();
            $("#btnAddvendor").hide();
            //loading();

            $.ajax({
                type: "POST",
                url: "expense.aspx/selectVendorData",
                data: "{'vendorId':" + vendorid + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);

                        //console.log(obj[0].cust_name);
                        $("#txtvendorId").text(vendorid);
                        $("#textName").text(obj[0].ext_user_name);
                        $("#txtCity").text(obj[0].ext_user_city);
                        $("#txtPhone").text(obj[0].ext_user_phone);
                        //$("#txtEmail").text(obj[0].vn_email);
                        $("#divVendorDetails").show();
                    } else {
                        alert("No data found");
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

            expenseEntry();
        }

        
        function AddNewRaw(html) {
            $('#TrSum').before(html);
            myCalculations(1);
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
            if (thisRowId != "1") {
                var rowId = $(thisRowId).closest('td').parent()[0].sectionRowIndex;
            }
            else {
                var rowId = thisRowId;
            }

            //var unit_price = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(2)').find('input').val());//price
            //var purchase_amount = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(4)').text());//amount
            //var discnt_percent = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());//dis %
            //var discnt_amount = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text());//dis amount
            //var tax_amt = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());//tax amt
            //var net_amount = $.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text());//net amount

            unit_price = $.trim($('#txtposTotalCost').val());
            discnt_percent = $.trim($('#txtTotalDiscountRate').val());
            // discnt_amount = $.trim($('#txtTotalDiscountAmount').val());
            tax_amount = $.trim($('#txtTotalTaxamt').val());
            
            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
           
            if (discnt_percent == "") {
                discnt_percent = 0.00;
            }
            else {
                discnt_percent = (parseFloat($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val()))).toFixed(2);
            }
            if (discnt_amount == "") {
                discnt_amount = 0.00;
            }
            else {
                discnt_amount = (parseFloat($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text()))).toFixed(2);
            }
            if (tax_amt == "") {
                tax_amt = 0.00;
            }
            else {
                tax_amt = (parseFloat($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(7)').find('input').val()))).toFixed(2);
            }
            if (net_amount == "") {
                net_amount = 0.00;
            }
            else {
                net_amount = (parseFloat($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text()))).toFixed(2);
            }
            if (purchase_amount == "") {
                purchase_amount = 0.00;
            }
            else {
                purchase_amount = (parseFloat($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(4)').text()))).toFixed(2);
            }

            purchase_amount = unit_price * item_qty;
            var realprice = 0;
            var discount = 0;
            if (valueType == "ItemPrice") {
                saleprice = parseFloat($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(2)').find('input').val());
                if (isNaN(saleprice) == true) {
                    //   alert("Check Sales Price..!");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(2)').find('input').val("");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(4)').text(0);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(0);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text(0);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text(0);
                    $("#txtTotalDiscountRate").text("0");
                    $("#txtTotalDiscountAmount").text("0");
                    $(thisRowId).addClass("err");
                    // return false;
                } else {
                    $(thisRowId).removeClass("err");
                    discnt_percent = 0.00;
                    discnt_amount = 0.00;
                    purchase_amount = parseFloat(saleprice * item_qty).toFixed(2);
                    net_amount = parseFloat(purchase_amount) + parseFloat(tax_amt);
                    //  alert(net_amount);

                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(4)').text(purchase_amount);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "ItemQty") {
                if (item_qty == "" || item_qty == "0") {
                    $(thisRowId).addClass("err");
                }
                else {
                    item_qty = parseInt($.trim($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(3)').find('input').val()));
                    $(thisRowId).removeClass("err");
                }

                discnt_amount = (purchase_amount * discnt_percent / 100).toFixed(2);
                net_amount = parseFloat(purchase_amount - discnt_amount).toFixed(2);
                net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                if (isNaN(item_qty) == true) {
                    // alert("Check Quantity..!");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(3)').find('input').val("1");
                    return false;
                }
                else {
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(4)').text(purchase_amount);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "DiscountPercent") {
                discount = parseInt($('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());
                discnt_amount = (purchase_amount * (discnt_percent / 100)).toFixed(2);
                net_amount = (purchase_amount - discnt_amount);
                net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                //alert(discnt_percent);
                if (discnt_percent > 100) {
                    //alert(thisRowId);
                    //   alert("Check Discount Percentage..!");
                    var newVal1 = discnt_percent.toString();
                    var newVal = newVal1.substr(0, newVal1.length - 1);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(newVal);

                    $(thisRowId).addClass("err");
                    // return false;
                }

                if (isNaN(discnt_percent) == true) {
                    //alert("Check Discount Percentage..!");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val("");
                    $(thisRowId).addClass("err");
                    // return false;
                }
                else {
                    $(thisRowId).removeClass("err");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(6)').text(discnt_amount);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            } else if (valueType == "ItemTax") {
                //   alert(discnt_amount);

                net_amount = (purchase_amount - discnt_amount).toFixed(2);

                if (isNaN(tax_amt) == true) {
                    // alert("Check Discount Amount..!");
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').find('input').val("");
                    $(thisRowId).addClass("err");
                    return false;
                }
                else {
                    $(thisRowId).removeClass("err");
                    // alert(parseFloat(net_amount) + parseFloat(tax_amt));
                    net_amount = parseFloat(net_amount) + parseFloat(tax_amt);
                    //$('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(discnt_percent);
                    $('#tblPurchaseItems tr:eq(' + rowId + ') td:eq(8)').text(net_amount);
                }
            }

            myCalculations(2);

            paymentMethod();
        }

        //calculations for total
        var tax_amount = 0.00;
        function myCalculations(actionType) {
            var total_tax_amt = 0.00;
            // actionType=1 for initial case of adding items and actionType=2 is for after changing values
            // actionType=1 for initial case of adding items and actionType=2 is for after changing values
            $('.number-only').keyup(function (e) {
                if (this.value != '-')
                    while (isNaN(this.value))
                        this.value = this.value.split('').reverse().join('').replace(/[\D]/i, '')
                                               .split('').reverse().join('');
                $('#txtTotalDiscountAmount').text("0");
            })
          .on("cut copy paste", function (e) {
              e.preventDefault();
          });




            var bill_amt = 0.00; //unit price Column:2
            var purchase_amount = 0.00; //Service Cost Column:2
            var discnt_percent = 0.00; //Discount Percentage Column:3
           // var discnt_amount = 0.00; //Discount Amount Column:4
            var discnt_amount = $('#txtTotalDiscountAmount').val();
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
            //var start_row = rowCount - 3; //For Identify Start RowId





            bill_amt = $.trim($('#txtposTotalCost').val());
            billAmtValidation(bill_amt)
            discnt_percent = $.trim($('#txtTotalDiscountRate').val());
            // discnt_amount = $.trim($('#txtTotalDiscountAmount').val());
            tax_amount = $.trim($('#txtTotalTaxamt').val());
            //tax_percent = $.trim($('#txtTotalTaxamt').val());
            //net_amount = $.trim($('#txtTotalNetAmount').text());
            discnt_amount = (discnt_percent / 100) * bill_amt;
             //tax_amount = (tax_percent / 100) * bill_amt;
            //discnt_percent = (discnt_amount / unit_price) * 100;
            //alert(discnt_percent);
            $('#txtTotalDiscountAmount').val(discnt_amount.toFixed(2));
      
            total_tax_amt += +tax_amount;
            //if (discnt_percent == "") {
            //    discnt_percent = 0.00;
            //}
            //else {
            //    discnt_percent = parseFloat($.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(5)').find('input').val()));
            //}
            //if (discnt_amount == "") {
            //    discnt_amount = 0.00;
            //}
            //else {
            //    discnt_amount = parseFloat($.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(6)').text()));

            //}
            //if (net_amount == "") {
            //    net_amount = 0.00;
            //}
            //else {
            //    net_amount = parseFloat($.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(8)').text()));
            //}
            //if (tax_amount == "") {
            //    tax_amount = 0.00;
            //}
            //else {
            //    tax_amount = parseFloat($.trim($('#tblPurchaseItems tr:eq(' + i + ') td:eq(7)').find('input').val()));
            //}


            //total_service_cost += +purchase_amount;
            //total_discnt_percent += +discnt_percent;
            //total_discnt_amount += +discnt_amount;
            //total_net_amount += +net_amount;
            //total_tax_amt += +tax_amount;


            //grand_total += total_service_cost;
            //// alert(total_net_amount);//Have to Add Tax Finally with grand total
            //grand_distcnt_perc += (((total_service_cost - (total_net_amount - total_tax_amt)) * 100) / total_service_cost);
            ////  alert(grand_distcnt_perc);
            //if (!isFinite(grand_distcnt_perc)) {
            //    grand_distcnt_perc = 0;
            //    //  alert(grand_distcnt_perc);
            //}
            ////    alert(grand_distcnt_perc);
            //grand_distcnt_amount += total_discnt_amount;
            //grand_tax_amt += total_tax_amt;
            //grand_netamount += total_net_amount;

            //var total_rowid = rowCount - 2;                                                                 //For Identify Total Rowid
            //var grand_total_rowid = rowCount - 1;                                                           //For Identify Grand Total Rowid

            //$('#tblPurchaseItems tr:eq(' + total_rowid + ') td:eq(4)').text(grand_total.toFixed(2));

            //$('#tblPurchaseItems tr:eq(' + total_rowid + ') td:eq(5)').text(grand_distcnt_perc.toFixed(2));    //Total Discount Percentage
            //$('#tblPurchaseItems tr:eq(' + total_rowid + ') td:eq(6)').text(grand_distcnt_amount.toFixed(2));  //Total Discount Amount
            //$('#tblPurchaseItems tr:eq(' + total_rowid + ') td:eq(7)').text(grand_tax_amt.toFixed(2));//total tax amt
            //$('#tblPurchaseItems tr:eq(' + total_rowid + ') td:eq(8)').text(grand_netamount.toFixed(2));       //Total Net Amount

            //$("#txtTotalGrossamount").text(grand_netamount.toFixed(2)); //Grand Total Amount
            //$("#txtPosPaidAmount").val(0.00);                       //Paid Amount
            //$("#txtPosBalanceAmount").val(grand_netamount.toFixed(2)); //Balance Amount

            //var tes=$('#txtTotalNetAmount').val(unit_price);

            $('#txtTotalNetAmount').val((bill_amt - discnt_amount + total_tax_amt).toFixed(2));
            paymentMethod();
        }

        function amountToPercent()
        {
            //var tax_amount = $.trim($('#txtTotalTaxamt').val());
            var discnt_amount = $('#txtTotalDiscountAmount').val();
            bill_amt = $.trim($('#txtposTotalCost').val());
            billAmtValidation(bill_amt)
            var discnt_percent = (discnt_amount / bill_amt) * 100
            $('#txtTotalDiscountRate').val(discnt_percent);
            $('#txtTotalNetAmount').val((parseFloat(bill_amt) - parseFloat(discnt_amount)) + parseFloat(tax_amount));
                            
        }




        function billAmtValidation(bill_amt)
        {
            if (bill_amt == 0 || bill_amt == "") {
                alert("Enter Bill Amount");
                $('#txtTotalDiscountRate').val(0);
                $('#txtTotalDiscountAmount').val(0);
                $('#txtTotalTaxamt').val(0);
                $('#txtTotalNetAmount').val(0);
                return;
            }
        }


        //for disabling and enabling payment method textboxes
        function paymentMethod() {
            
            var tblrowCount = $('#tblPurchaseItems tr').length;
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

            if ($(document).find(".err").length > 0) {
                console.log($(document).find(".err").length);
                $("#divsaveorder").css('pointer-events', 'none');
                $("#divprintorder").css('pointer-events', 'none');
            }
            else {
                $("#divsaveorder").css('pointer-events', 'auto');
                $("#divprintorder").css('pointer-events', 'auto');
            }
            calculteFromPayMethod();
        }


        function expenseEntry() {
            $("#txtposTotalCost").prop("disabled", false);
            $("#txtTotalDiscountRate").prop("disabled", false);
            $("#txtTotalDiscountAmount").prop("disabled", false);
            $("#txtTotalTaxamt").prop("disabled", false);
            $("#txtTotalNetAmount").prop("disabled", false);
           



            $("#cbCashPayment").prop("disabled", false);
            $("#cbCardPayment").prop("disabled", false);
            $("#cbChequePayment").prop("disabled", false);
            //$("#walletPayment").prop("disabled",false)
            //$("#textwalletamt").attr("disabled", false);


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
            if ($("#walletPayment").is(':checked')) {
               
              
            }
            //else {
            //    $("#textwalletamt").attr("disabled", true);
            //    $("#textwalletamt").val('');
            //    alert("else")
            //}


        }



        // calculating total and balance from payment method values
        var paidAmt = 0;
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
            var cashTotal = parseFloat(cashAmount) + parseFloat(chequeAmount);

            //alert(cashTotal);
            $('#txtPosPaidAmount').val(cashTotal.toFixed(2));
            paidAmt = cashTotal.toFixed(2);
          //  var balance = parseFloat($('#txtTotalGrossamount').text()) - parseFloat($('#txtPosPaidAmount').val());
            //var balance = $('#txtTotalNetAmount').val() - $('#txtCashAmount').val();
            var balance = parseFloat($('#txtTotalNetAmount').val()) - (parseFloat(cashAmount) + parseFloat(chequeAmount));
            
            //alert(balance);
            //  $('#tblPurchaseItems tr:eq(' + row + ') td:eq(7)').text(total.toFixed(2));
            //if (balance <= 0) {
            //    $("#txtOutstandingBillDate").prop("disabled", true);
            //    $("#txtOutstandingBillDate").val('');
            //}
            //else {
            //    $("#txtOutstandingBillDate").prop("disabled", false);
            //}


            //$("#txtPosBalanceAmount").val($('#txtTotalNetAmount').val() - $('#txtCashAmount').val());

            //balance


            $("#txtPosBalanceAmount").val(balance.toFixed(2));
        }

        function DeleteRaw(ctrl) {

            $(ctrl).closest('tr').remove();
            var rowCount = parseInt($('#tblPurchaseItems tr').length);
            if (rowCount <= 4) {
                //  $("#TrSum").text('');
                $("#txtposTotalCost").text(0.0);
                $("#txtTotalDiscountRate").text(0.0);
                $("#txtTotalDiscountAmount").text(0.0);
                $("#txtTotalNetAmount").text(0.0);
                $("#txtTotalGrossamount").text(0.0);
                $("#txtPosPaidAmount").val(0.0);
                $("#txtPosBalanceAmount").val(0.0);
            }
            // calculteTable();
            myCalculations(2);
        }

        function addNewSupplier() {
            window.open('../inventory/vendors.aspx', '_blank');
        }

        //function for disable payment
        function disablepayment() {

            $("#txtposTotalCost").prop("disabled", true);
            $("#txtTotalDiscountRate").prop("disabled", true);
            $("#txtTotalDiscountAmount").prop("disabled", true);
            $("#txtTotalTaxamt").prop("disabled", true);
            $("#txtTotalNetAmount").prop("disabled", true);

            $("#cbCashPayment").prop("disabled", true);
            $("#cbCashPayment").attr("checked", false);
            $("#walletPayment").prop("disabled", true);
            $("#walletPayment").attr("checked", false);
            $("#cbCardPayment").prop("disabled", true);
            $("#cbCardPayment").attr("checked", false);
            $("#cbChequePayment").prop("disabled", true);
            $("#cbChequePayment").attr("checked", false);
            $('#txtCashAmount').val('0');
            $('#txtCashAmount').prop("disabled", true);
            $('#walletPayment').prop("disabled", true);
            $("#textwalletamt").val('0');
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
        }

        function addNewItem() {
            window.open('../inventory/itemmaster.aspx', '_blank');
        }

        function gotoVendor() {
            window.open('../inventory/managevendor.aspx?vendorId=' + vendorid, '_blank');
        }

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

        //function to Save Expense Entry to tbl_incm_exps and payment details to tbl_transaction
        function saveAndPrintExpense(take_print) {
            //warehouseValidation();
            if ($("#warehousediv").val() == 0) {
                alert("Select a warehouse");
               return;
            }
           
            if ($('#txtinvoiceId').val() == "") { alert("Provide an Invoice Number"); return; }
            if ($('#txtvendorId').text() == "") { alert("Select a User"); return; }
            if ($('#txtposTotalCost').val() == "" || $('#txtposTotalCost').val() == 0) { alert("Give Bill Amount"); return; }
            var skillsSelect = document.getElementById("servicediv");
            var selectedCtgry = $("#servicediv").val();
           // alert(selectedCtgry);

            sqlInjection();
            var filters = {};

            filters.TimeZone = $.cookie("invntryTimeZone");
            filters.userid = $.cookie("invntrystaffId");
            filters.vendorId = $("#txtvendorId").text();
            filters.userType = $("#servicediv").val();
            filters.externalUserId = $("#txtvendorId").text();
            filters.externalUserName = $("#textName").text();
            filters.selectedCategory = (selectedCtgry);         
            filters.invoiceno = $("#txtinvoiceId").val();
            filters.note = $("#txtSpecialNote").val();

            filters.TotalAmount = $("#txtposTotalCost").val();
            
            filters.TotalDiscountRate = $("#txtTotalDiscountRate").val();
           
            filters.TotalDiscountAmount = $("#txtTotalDiscountAmount").val();
            filters.TotalNetAmount = $("#txtTotalNetAmount").val();
            if (($("#txtCashAmount").val() == "")&&($("#txtCashAmount").val() == "")) { filters.PaidAmount = 0.00 }
            else{
               
                filters.PaidAmount = paidAmt;
            }
            filters.TotalBalanceAmount = $("#txtPosBalanceAmount").val();
            //filters.purchasedate = $("#txtpurchaseDate").val();
            filters.expenseDate = $("#txtpurchaseDate").val();
            //filters.totalTaxamt = $("#txtTotalTaxamt").text();
            filters.totalTaxamt = $("#txtTotalTaxamt").val();


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

            // save to pos
            //filters.rowCount = $('#tblPurchaseItems tr').length;
            //filters.rowCount = filters.rowCount - 3;
           


            //if (filters.rowCount == 0) {
            //    alert("select an item");
            //    return;
            //}

            var query = '';
            var itemstring = '';

            filters.warehouse = $("#warehousediv").val();


            //start changes on 18-apr-2017
            if ($("#cbCashPayment").is(':checked')) {
                if ($('#txtCashAmount').val() == "" || isNaN($('#txtCashAmount').val())) {
                    alert("Enter a valid Cash Amount");
                    return;
                }
                //paymentmode = "Cash";
            }

           
            if ($("#cbChequePayment").is(':checked')) {
                if ($('#txtChequeAmount').val() == "" || isNaN($('#txtChequeAmount').val())) {
                    alert("Enter a valid Cheque Amount");
                    return;
                }
                else if ($('#txtChequeNo').val() == "") {
                    alert("Enter Cheque No");
                    return;
                }

                //else if ($('#txtChequeDate').val() == "") {
                //    alert("Enter Cheque Date");
                //    return;
                    //}

                else if ($('#txtBankName').val() == "") {
                    alert("Enter Bank Name");
                    return;
                }
                // paymentmode = "Cheque";
            }
            var creditamount = 0;
           
            //console.log(creditamount);
            filters.walletAmt = creditamount;
            bootbox.confirm("Do you want to continue?", function (result) {
                console.log(result)
                if (result) {
                    loading();
                    // alert("{'MemberId':'" + MemberId + "','MemberName':'" + MemberName + "','TotalCost':'" + TotalCost + "','TotalDiscountRate':'" + TotalDiscountRate + "','TotalDiscountAmount':'" + TotalDiscountAmount + "','Tax':'" + TaxAmount + "','billdate':'" + cur_dat + "','userid':'" + userid + "','TotalAmount':'" + TotalAmount + "','TotalCurrentAmount':'" + TotalCurrentAmount + "','TotalBalanceAmount':'" + TotalBalanceAmount + "','TotalPaidinFull':'" + TotalPaidinFull + "','paymentmode':'" + paymentmode + "','BankName':'" + BankName + "','ChequeAmount':'" + ChequeAmount + "','ChequeDate':'" + ChequeDate + "','ChequeNo':'" + ChequeNo + "','CardAmount':'" + CardAmount + "','CardNo':'" + CardNo + "','CardType':'" + CardType + "','CardBank':'" + CardBank + "','CashAmount':'" + CashAmount + "','CountryId':'" + CountryId + "','BranchId':'" + BranchId + "','SpecialNote':'" + SpecialNote + "','outstandingBillDate':'" + outstand_bl_dt + "','TimeZone':'" + TimeZone + "','tableString':'" + tableString + "','rowCount':" + rowCount + ",'PosCurrentPaidAmount':'" + PosCurrentPaidAmount + "','PosBalanceAmount':'" + PosBalanceAmount + "'}");
                    $.ajax({
                        type: "POST",
                        url: "expense.aspx/saveExpenseEntry",
                        data: "{'filters':" + JSON.stringify(filters) + ",'tableString':" + JSON.stringify(itemstring) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "N") {
                                alert("Error!.. Please Try Again...");
                                return;
                            } else {
                                alert("Entry saved successfully");
                                // window.location = 'expense.aspx';
                                window.location = 'listExpenseEntries.aspx';
                           
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
                } else {
                    bootbox.hideAll()
                    // What to do here?
                }
            });

        }
              
        function searchVendors(page) {
            var ext_user = $("#servicediv").val();
            if ($("#servicediv").val() == -1) {
                alert("Select a Category");
                return;
            }
                        
            var filters = {};

            if ($("#searchVendortext2").val() !== undefined && $("#searchVendortext2").val() != "") {
                filters.externalUserName = $("#searchVendortext2").val();
            }

            //  alert(itemcode);
            if ($("#searchVendortext1").val() !== undefined && $("#searchVendortext1").val() != "") {
                filters.externalUserId = $("#searchVendortext1").val();
            }

            var perpage = $("#txtvendorpageno").val();
            console.log(JSON.stringify(filters));

            loading();

            $.ajax({
                type: "POST",
                url: "expense.aspx/searchVendors",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + ",'ext_user':'" + ext_user + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblvendorsTotalrecords").text(0);
                        $('#tableVendorlist tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginateVendordiv").html("");
                        $("#popupVendors").modal('show');
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  console.log(obj);
                        $("#lblvendorsTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            htm += "<tr ";
                            htm += " onclick=javascript:selectVendor('" + row.ext_user_id + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.vendorid, row.ext_user_id.toString()) + "</td><td>" + getHighlightedValue(filters.vendorname, row.ext_user_name.toString()) + "</td><td>" + row.ext_user_phone + "</td></tr>";

                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginateVendordiv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';

                        //   alert(htm);
                        $('#tableVendorlist tbody').html(htm);
                        $("#popupVendors").modal('show');
                        $("#paginateVendordiv").html(paginate(obj.count, perpage, page, "searchVendors"));

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

        function resetVendorlist() {
            for (var i = 1; i <= 2; i++) {
                $("#searchVendortext" + i).val('');
            }
            searchVendors(1);
        }
        
        function vendorData(id) {
            vendorid = id;
            popupclose("popupVendors");
            selectVendor();
        }

        function changevendor() {
            $("#txtposTotalCost").val(0.0);
            $("#txtTotalDiscountRate").val(0.0);
            $("#txtTotalDiscountAmount").val(0.0);
            $("#txtTotalNetAmount").val(0.0);
            $("#txtTotalGrossamount").text(0.0);
            $("#txtPosPaidAmount").val(0.0);
            $("#txtPosBalanceAmount").val(0.0);
            $('#txtTotalTaxamt').val(0.0);
            disablepayment();
            $("#vendorNames").val("");
            $("#divVendorDetails").hide();
            $("#btnAddvendor").show();
            $("#txtvendorId").text("");
            $("#divVendorField").show();
            $("#divVendorIcon").show();
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
            $("#txtWarehouseName").val($("#warehousediv option:selected").text());
            // alert($('select[name="warehousediv"] option:selected').val());
        }

        function popupclose(divId) {
            $("#" + divId + "").modal('hide');
        }

        


        // for load users
        //function getExtUsers(currentVal) {
            
        //    var ext_user = $("#servicediv").val();
        //    //alert(ext_user);
        //    loading();

        //    $.ajax({
        //        type: "POST",
        //        url: "expense.aspx/getExtUsers",
        //        data: "{'ext_user':'" + ext_user + "'}",
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (msg) {
        //            var obj = JSON.parse(msg.d);
        //            //alert(msg.d);
        //            var htm = "";
        //            htm += '<option value="-1" selected="selected">--Select User--</option>';
        //            $.each(obj, function (i, row) {
                       
        //                htm += '<option value="' + row.ext_user_id + '">' + row.ext_user_name + '</option>';
        //            });
        //            $("#selUser").html(htm);
        //            $("#selUser").val(currentVal);
        //            Unloading();

        //        },
        //        error: function (xhr, status) {
        //            Unloading();
        //            alert("Internet Problem");
        //        }
        //    });
            
        //}

        
        function getCategories() {
           // alert("getCategories()");
            loading();
            $.ajax({
                type: "POST",
                url: "expense.aspx/getCategories",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Categories--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.ie_cat_id + '">' + row.ie_cat_name + '</option>';
                    });
                    //$("#selCategory").html(htm);
                    $("#servicediv").html(htm);
                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
            changevendor();
        }
        
        function warehouseValidation()
        {
           
            changevendor();
            //getCategories();
            if ($("#warehousediv").val() == 0) {
                alert("Select a warehouse");
                $("#servicediv").val(-1);
                return;
            }
            
        }

        //Add user
        function addUserDetails() {
            sqlInjection();
            var Firstname = $("#txtFirstname").val();
            var Lastname = $("#txtLastname").val();
            var Username = $("#txtUsername").val();
            var Password = $("#txtPassword").val();
            var Usertype = $("#comboUsertype").val();
            var Usertypename = $("#comboUsertype option[value='" + Usertype + "']").text();
            var Phone = $("#numPhone").val();
            var Emailid = $("#txtEmailid").val();
            var Country = $("#txtCountry").val();
            var Location = $("#txtLocation").val();
            var Address = $("#txtAddress").val();
            var UserImage = "";

            var warehouseId = $("#comboWarehouseUser").val();
            var warehousename = $("#comboWarehouseUser option[value='" + warehouseId + "']").text();
            if (warehouseId == "-1") {
                alert("Select the Warehouse");
                return false;
            }


            if (Firstname == "") {
                alert("Enter First Name");
                $("#txtFirstname").focus();
                return false;
            }
            if (Lastname == "") {
                alert("Enter Last Name");
                $("#txtLastname").focus();
                return false;
            }
            if (Username == "") {
                alert("Enter User Name");
                $("#txtUsername").focus();
                return false;
            }
            if (Password == "") {
                alert("Enter Password");
                $("#txtPassword").focus();
                return false;
            }
            if (Usertype == "" || Usertype == "-1") {
                alert("Choose User Role");
                return false;
            }
            if (Phone == "") {
                alert("Enter phone number");
                $("#txtPhone").focus();
                return false;
            }
            if (Country == "") {
                alert("Enter country");
                $("#txtCountry").focus();
                return false;
            }
            if (Address == "") {
                alert("Enter Address");
                $("#txtAddress").focus();
                return false;
            }
            loading();
            $.ajax({
                type: "POST",
                url: "income.aspx/addUserDetails",
                data: "{'Firstname':'" + Firstname + "','Lastname':'" + Lastname + "','Username':'" + Username + "','Password':'" + Password + "','Usertype':'" + Usertype + "','Usertypename':'" + Usertypename + "','Phone':'" + Phone + "','Emailid':'" + Emailid + "','Country':'" + Country + "','Location':'" + Location + "','Address':'" + Address + "','UserImage':'" + UserImage + "','branch_id':'" + warehouseId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "E") {
                        alert("Give Another Username");
                        return false;
                    }
                    if (msg.d == "Y") {
                        alert("User Created Successfully");
                        clearUserDetails();
                        popupclose('popupUser');
                        //searchUsers(1);
                        return false;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                    return false;
                }
            });

        }

        //Getting user types to combobox in #add new user popup
        function getUserTypes() {
            //loading();
            $.ajax({
                type: "POST",
                url: "income.aspx/getUserTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--All User Types--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.usertype_id + '">' + row.usertype_name + '</option>';
                    });
                    //$("#slUserType").html(htm);
                    $("#comboUsertype").html(htm);
                    //searchUsers(1);
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        //To clear user details before loading the #add user popup
        function clearUserDetails() {
            $("#popupVendors").modal('hide');
            $("#txtFirstname").val("");
            $("#txtLastname").val("");
            $("#txtUsername").val("");
            $("#txtPassword").val("");
            //$("#comboUsertype").val("1");
            $("#txtPhone").val("");
            $("#txtEmailid").val("");
            $("#txtCountry").val("");
            $("#txtLocation").val("");
            $("#txtAddress").val("");
            $("#comboUsertype").val("-1");
            $("#comboWarehouseUser").val("-1");
            //$("#popupUser").modal('hide');
        }

    </script>

    <style>
        .modal {
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
                            <label style="font-weight: bold; font-size: 16px;">Expense Entry</label>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="clearfix"></div>
                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">
                        <div class="x_panel">
                            <div class="col-md-4 col-sm-6 col-xs-12">
                                <div id="showbranchdiv">
                                    <select id="warehousediv" class="form-control" onchange="getCategories(-1);">
                                        <option value="0" selected="selected" taxtype="-1">--Warehouse--</option>
                                        <option value="1" taxtype="0">Five star</option>
                                        <option value="2" taxtype="0">YANA SOLA</option>

                                    </select>
                                </div>
                            </div>

                            <div class="col-md-2 col-sm-6 col-xs-6 form-group has-feedback">
                                <input class="form-control has-feedback-left ui-autocomplete-input" placeholder="" id="txtpurchaseDate" style="padding-right: 10px;" />
                                <span class="fa fa-calendar form-control-feedback left" aria-hidden="true"></span>

                                <%--   <span id="txtpurchaseDate" style="font-size: 16px; font-weight: bold">07-Aug-2017</span>--%>
                            </div>

                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                <input class="form-control ui-autocomplete-input" placeholder="Invoice Number" id="txtinvoiceId" style="padding-right: 20px;" />
                            </div>
                        </div>
                    </div>
                  
                </div>



                <div class="row" style="display: none;">
                    <div class="col-md-6 col-sm-12 col-xs-12">
                        <div class="x_panel" style="background: #FFFBE5">

                            <div class="x_title" style="margin-bottom: 5px;">
                                <label>Navigation</label>
                                <ul class="nav navbar-right panel_toolbox">
                                    <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                    </li>
                                </ul>
                            </div>
                            <ul class="nav navbar-right panel_toolbox" onclick="fuctnHidediv()">
                                <li><a><i class="fa fa-chevron-up"></i></a>
                                </li>
                            </ul>
                            <div class="x_content" id="divVendordata">
                                <!-- info row -->


                                <%--        <div class="col-md-3 col-sm-12 col-xs-12">
                                <div class="form-group" style="margin-bottom: 2px;">
                                    <span class="myorderMDatafor">
                                        <label class="" style="color: inherit; margin-bottom: 0px;"><span class="fa fa-envelope-o" title="Email"></span></label>
                                        <label class="myorderMDatafor" style="font-weight: normal"><a id="txtEmail">mariyas@gmail.com</a></label>
                                    </span>

                                </div>
                            </div>--%>
                            </div>

                        </div>
                    </div>


                    <div class="clearfix"></div>




                </div>

                <div class="clearfix"></div>

                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">
                        <div class="x_panel">
                            <div class="x_title" style="margin-bottom: 5px;">
                                <label>Items</label>
                                <ul class="nav navbar-right panel_toolbox">
                                    <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                    </li>
                                </ul>
                            </div>
                            <div class="x_content">
                                <div class="row" style="margin-bottom: 5px;">
                                    
                                <div class="col-md-12 col-sm-6 col-xs-12">
                                <div id="category" class="col-md-3 col-sm-6 col-xs-12">
                                    <%--<select id="servicediv" class="form-control" onchange="getExtUsers(-1);">--%>
                                    <select id="servicediv" class="form-control" onchange="warehouseValidation();">
                                        
                                        <option value="0" selected="selected">---Category---</option>
                                        <option value="2" onclick="javascript:selectOrderItem(2);">Employee Salary</option>
                                        <option value="3" onclick="javascript:selectOrderItem(2);">Water Bill</option>
                                        <option value="4" onclick="javascript:selectOrderItem(2);">Transportation</option>
                                        <option value="5">Equipment Maintenance</option>
                                        <option value="6">Cleaning</option>
                                         <option value="7">Loan Repayment</option>
                                        <option value="8">Others</option>

                                    </select>
                                </div>
                             <div class="col-md-8 col-sm-6 col-xs-12 form-group has-feedback" style="padding-right: 0px;" id="divVendorField">
                                <input class="form-control has-feedback-left" placeholder="Search User" id="vendorNames" style="padding-right: 10px;" />
                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                            </div>
                                    <div class="col-md-1" style="font-size: 22px;" title="search supplier" onclick="searchVendors(1)" id="divVendorIcon">
                                <label class="fa fa-user" style="color: #ff6a00; cursor: pointer;"></label>
                                <label class="fa fa-search" style="font-size: 16px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                            </div>



                            
                                                <div id="divVendorDetails" style="display: none; border-left: 1px solid #bebebe; border-right: 1px solid #bebebe;">
                                <div class="col-md-6 col-sm-12 col-xs-12" style="line-height: 32px;">

                                    <span class="myorderMData">#<a class="" style="color: inherit; margin-bottom: 0px;" id="txtvendorId" onclick="gotoVendor()"></a>
                                        <label class="" style="margin-bottom: 0px; padding-left: 5px; padding-right: 5px; font-size: 14px;"><a id="textName">ITC</a></label>
                                        <label class="" style="font-weight: normal; margin-left: 40px;"><span class="fa fa-map-marker myicons" title="City"></span><a id="txtCity"></a></label>
                                        <label class="" style="margin-left: 10px; font-weight: normal; margin-left: 20px;"><span class="fa fa-mobile myicons" title="Phone Number"></span><a id="txtPhone">12312123</a></label>
                                        <label class="pull-right" style="color: aliceblue; font-size: 10px;" onclick="changevendor()"><a href="#" style="color: #0e9cff; text-decoration: underline;">Change User</a></label>
                                    </span>
                                </div>
                                <div class="col-md-3 col-sm-12 col-xs-12" style="display: none;">
                                </div>
                                <div class="cl"></div>

                            </div>
                            <div class="col-md-2 col-sm-6 col-xs-4 pull-right" style="padding-right: 0px;" id="btnAddvendor">
                                <div class="" style="font-size: 24px;" title="Add Supplier">

                                    <%--<label class="fa fa-user" style="color: #ff6a00; cursor: pointer;"></label>
                                    <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>--%>
                                </div>

                            </div>





                            <div class="container">
                                
                                <%-- start popup for loading vendors --%>
                                <div class="modal fade" id="popupVendors" role="dialog">
                                    <div class="modal-dialog modal-md" style="">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <button type="button" class="close" onclick="javascript:popupclose('popupVendors');">&times;</button>
                                                <div class="col-md-3 col-sm-6 col-xs-6">
                                                    <h4 class="modal-title">Suppliers<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblvendorsTotalrecords">0</span></h4>
                                                </div>

                                                <div class="col-md-6 col-sm-4 col-xs-12 pull-right">

                                                    <div class="col-md-8 col-sm-12 col-xs-12">
                                                        <div class="" onclick="javascript:searchVendors(1);">
                                                            <button type="button" class="btn btn-success mybtnstyl">
                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                Search
                                                            </button>
                                                        </div>
                                                        <div class="" onclick="javascript:resetVendorlist();">
                                                            <button class="btn btn-primary mybtnstyl" type="reset">
                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                Reset
                                                            </button>
                                                        </div>
                                                    </div>
                                                  
                                                    <div class="col-md-2 col-sm-12 col-xs-3">
                                                        <select id="txtvendorpageno" onchange="javascript:searchVendors(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
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

                                                    <table id="tableVendorlist" class="table table-striped table-bordered" style="table-layout: auto;">
                                                        <thead>
                                                            <tr>
                                                                <th>Id</th>
                                                                <th>Name
                                                                    <div class="btn btn-success btn-xs pull-right" style="background-color: #d86612; border-color: #d86612;" onclick="javascript:clearUserDetails();" data-toggle="modal" data-target="#popupUser"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>New</div>
                                                                </th>
                                                                <th>Number</th>


                                                            </tr>


                                                            <tr>
                                                                <td>
                                                                    <input type="text" id="searchVendortext1" placeholder="search" /></td>
                                                                <td>
                                                                    <input type="text" id="searchVendortext2" placeholder="search" /></td>

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
                                <%-- end popup of loading vendors --%>
                                
                                <%-- start popup for add new user --%>
                                <div class="modal fade" id="popupUser" role="dialog">
                                <div class="modal-dialog modal-md">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupUser');">&times;</button>
                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                <h4 class="modal-title">Add New User</h4>
                                            </div>

                                        </div>
                                        <div class="modal-body">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <form role="form" class="form-horizontal">
                                                       <%-- <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Warehouse<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <select class="form-control" id="comboWarehouseUser">
                                                                    <option value="0">-Select Warehouse-</option>
                                                                </select>
                                                            </div>
                                                        </div>--%>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                First Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtFirstname" placeholder="Enter First Name" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Last Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtLastname" placeholder="Enter Last Name" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                User Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtUsername" placeholder="Enter Username" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Password<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtPassword" placeholder="Enter Password" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                User Role<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <select class="form-control" id="comboUsertype">
                                                                    <option value="0">-Select User Role-</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Phone<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="number" id="numPhone" style="padding: 0px; text-indent: 3px;" placeholder="Enter Phone" required="required" class="form-control col-md-7 col-xs-12"/>
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Email
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtEmailid" placeholder="Enter Email" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Country<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtCountry" placeholder="Enter Country" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Location
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtLocation" placeholder="Enter City" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Address<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <textarea class="form-control" rows="3" placeholder="Enter Address" id="txtAddress" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                                            </div>
                                                        </div>

                                                    </form>
                                                    <div class="clearfix"></div>

                                                    <div class="ln_solid"></div>
                                                    <div class="form-group" style="padding-bottom: 40px;">
                                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                            <div id="btnUserDetailsAction">
                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addUserDetails();">SAVE</div>
                                                            </div>
                                                            <div onclick="javascript:clearUserDetails();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                                            <%--<button  id="btnUserDetailsUpdate" style="display:none" class="btn btn-success" onclick="javascript:updateUserDetails();" type="reset">Update</button>--%>
                                                        </div>
                                                    </div>

                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                                <%-- end popup for add new user --%>
                            </div>




                                   <%-- <div class="form-group">--%>
                                                <%--<label class="control-label col-md-1 col-sm-3 col-xs-12" for="last-name">
                                                    User<span class="required">*</span>
                                                </label>--%>
                                              <%--   <div class="col-md-3 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selUser" onchange="javascript:expenseEntry();">
                                                        <option value="0">--Select User--</option>
                                                      
                                                    </select>
                                                </div>--%>
                                           <%-- </div>--%>





                            </div>
                                   
                                    <div class="col-md-6 col-sm-6 col-xs-12 pull-right" style="padding-right: 0px;">






                                        <div class="col-md-10 col-sm-6 col-xs-8" style="display: none;">
                                            <input class="form-control has-feedback-left" placeholder="Search Item" id="itemNames" autocomplete="off" type="search" />
                                            <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                        </div>
                                      
                                        <%-- pop up for show  items --%>
                                        <div class="container">


                                            <div class="modal fade" id="popupItems" role="dialog" style="z-index: 1400;">
                                                <div class="modal-dialog modal-lg" style="">

                                                    <!-- Modal content-->
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <button type="button" class="close" onclick="javascript:popupclose('popupItems');">&times;</button>
                                                            <div class="col-md-2 col-sm-6 col-xs-6">
                                                                <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords">0</span></h4>
                                                            </div>

                                                            <div class="col-md-9 col-sm-4 col-xs-12 pull-right">
                                                                           
                                                                <div class="col-md-3 col-sm-12 col-xs-3">
                                                                    <select id="selCategory" class="form-control" onchange="searchOrderitems(1);">
                                                                        <option value="0" selected="selected" taxtype="-1">--Warehouse--</option>
                                                                        <option value="2" taxtype="0">YANA SOLA</option>
                                                                        <option value="1" taxtype="0">Five star</option>
                                                                    </select>
                                                                </div>
                                                            
                                                              
                                                                
                                                                <div class="col-md-2 col-sm-12 col-xs-3 pull-right">
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
                                                                            <th>Brand/Category</th>
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
                    </div>
                    <div class="clearfix"></div>


                </div>
                <div class="clearfix"></div>

                <div class="x_panel" style="background: #eeeeee;">
                    <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">

                        <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px; ">
                            
                            <div class="col-md-6 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>Expence Entry</b> </div>

                             <div class="clearfix"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12">Bill Amount</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                         <input type="number" id="txtposTotalCost" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:myCalculations(2);" value="0"/>
                            </div>

                            <div class="clearfix"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12">Dis %</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="number" id="txtTotalDiscountRate" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:myCalculations(2);" value="0"/>
                            </div>
                            <div class="clearfix"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12">Dis Amt</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="number" id="txtTotalDiscountAmount" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:amountToPercent();"/>
                            </div>
                            <div class="clearfix"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12">Tax Amt</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="number" id="txtTotalTaxamt" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Tax perc." onkeyup="javascript:myCalculations(2);" />
                            </div>
                            <div class="clearfix"></div>
                            
                           <div class="col-md-4 col-sm-6 col-xs-12">Net Amt</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="number" readonly="true" id="txtTotalNetAmount" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;"/>
                            </div>
                            <div class="clearfix"></div>

                        </div>

                        <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                            <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                <div class="checkbox">
                                    <label style="font-size: 1.3em">
                                        <input type="checkbox" value="" id="cbCashPayment" onclick="javascript: paymentMethod();" disabled=""/>
                                        <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                    </label>
                                </div>

                            </div>


                            <div class="col-md-4 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>CASH</b> </div>
                            <div class="clearfix"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12">Cash Amt</div>
                            <div class="col-md-8 col-sm-6 col-xs-12">
                                <input type="number" id="txtCashAmount" class="form-control number-only textwidth" style="height: 25px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" value="0"/>
                            </div>

                                             <div class="clearfix"></div>
                                        <div class="col-md-2 col-sm-1 col-xs-2" style=" padding-right:0px;">
                                            <div class="checkbox">
            <label style="font-size: 1.3em;display:none">
                <input type="checkbox" value="" id="walletPayment"/>
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
                                           
                                        </div>
                                        <div class="col-md-8 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px;display:none"><b>WALLET</b> (Wallet contains<label id="lblwalletamt" style="color: #432727; font-weight: bold; font-size: 12px; color: #40c863;"></label>) </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12" style="display:none">Wallet Amt</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12" style="display:none">
                                            <input type="text" id="textwalletamt" class="form-control" style="height: 25px;" onkeyup="javascript:paymentMethod();" value="0" readonly="true"/>
                                        </div>





                             <%--<div class="col-md-4 col-sm-6 col-xs-12" ></div>--%>
                              <div class="clearfix" style="margin:30px"></div>
                            <div class="col-md-4 col-sm-6 col-xs-12" >Balance</div>
                            <div class="col-md-8 col-sm-6 col-xs-12">
                                <input type="number" readonly="true" id="txtPosBalanceAmount" class="form-control number-only textwidth" style="height: 25px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" value="0"/>
                            </div>



                            <div class="clearfix"></div>
                            <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                <div class="checkbox">
                                    <label style="font-size: 1.3em">
                                       
                                      
                                    </label>
                                </div>

                            </div>
                           
                        </div>

                        <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px">
                            <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right: 0px;">
                                <div class="checkbox">
                                    <label style="font-size: 1.3em">
                                        <input type="checkbox" value="" id="cbChequePayment" onclick="javascript: paymentMethod();" disabled=""/>
                                        <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                    </label>
                                </div>

                            </div>
                            <div class="col-md-4 col-sm-4 col-xs-4" style="line-height: 3; padding-left: 0px;"><b>CHEQUE</b> </div>
                            <div class="clearfix"></div>
                            <div class="col-md-5 col-sm-6 col-xs-12">Cheque Amt.</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="number" id="txtChequeAmount" class="form-control number-only textwidth" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" disabled=""/>
                            </div>
                            <div class="clearfix"></div>
                            <div class="col-md-5 col-sm-6 col-xs-12">Cheque No.</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="text" id="txtChequeNo" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter No." disabled=""/>
                            </div>
                            <div class="clearfix"></div>
                            <div class="col-md-5 col-sm-6 col-xs-12">Date</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="text" id="txtChequeDate" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Date" disabled="" readonly="">
                            </div>
                            <div class="clearfix"></div>
                            <div class="col-md-5 col-sm-6 col-xs-12">Bank</div>
                            <div class="col-md-7 col-sm-6 col-xs-12">
                                <input type="text" id="txtBankName" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bank" disabled="">
                            </div>
                            <div class="clearfix"></div>
                        </div>

                        

                        

                        <div class="col-md-3 col-sm-6 col-xs-12" style="padding-left: 0px; padding-right: 0px">

                            <div class="col-md-8 col-sm-6 col-xs-12"><b>Special Notes</b> </div>
                            <div class="clearfix"></div>

                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <textarea id="txtSpecialNote" class="form-control" style="resize:none;"></textarea>
                            </div>
                            
                            <div class="clearfix"></div>

                            <div class="col-md-3 col-sm-3 col-xs-3" style="margin-top: 10px;" id="divsaveorder" onclick="javascript:saveAndPrintExpense(false);">
                                <button class="btn btn-primary mybtnstyl" type="button">Save</button>
                            </div>

                            <div class="col-md-3 col-sm-3 col-xs-6" style="margin-top: 10px; margin-left: 0px; display: none" id="divprintorder" onclick="javascript:saveAndPrintExpense(true);">
                                <button class="btn btn-primary mybtnstyl" type="button">Save &amp; Print</button>
                            </div>
                            <div class="clearfix"></div>

                        </div>

                        
                    </div>

                </div>

               <%-- <h5 style="text-align:center"><b>Expense LIST</b></h5>
                                    <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                        <table id="tblPurchaseItems" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <tbody>
                                                <tr>
                                                    <td style="width: 120px;">Date</td>
                                                    <td style="width: 300px;">Category</td>
                                                    <td>Price</td>
                                                   <%-- <td>QTY</td>--%>
                                                   <%-- <td>Amt</td>--%>
                                                    <%--<td>Dis %</td>
                                                    <td>Dis Amt</td>
                                                    <td>Tax Amt</td>
                                                    <td>Net Amt</td>
                                                    <td>Paid</td>
                                                    <td>Balance To Pay</td>
                                                    <td></td>
                                                </tr>
                                                <tr id="TrSum">
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="border-right: none;"></td>
                                                    <td style="text-align: right;"><b>Total</b></td>
                                                    <td id="tableposTotalCost"></td>
                                                    <td id="tableTotalDiscountRate"></td>
                                                    <td id="tableTotalDiscountAmount"></td>
                                                    <td id="tableTotalTaxamt"></td>
                                                    <td id="tableTotalNetAmount"></td>--%>
                                                    <%--<td></td>--%>
                                                   <%-- <td></td>
                                                    <td></td>--%>
                                               <%-- </tr>
                                                <tr>
                                                    <td colspan="4"></td>
                                                    <td></td>
                                                    <td></td>

                                                   <%-- <td></td>
                                                    <td></td>--%>
                                                    <%--<td>
                                                        <label id="tableTotalGrossamount"></label>
                                                    </td>
                                                    <td>
                                                        <input type="text" class="textwidth" id="tablePosPaidAmount" onkeyup="calculteTable();" style="width: 98%; background: none; border: none;" disabled=""></td>
                                                    <td>
                                                        <input type="text" class="textwidth" id="tablePosBalanceAmount" style="width: 98%; background: none; border: none;" disabled=""></td>
                                                    <td></td>

                                                </tr>

                                            </tbody>
                                        </table>--%>

                                    </div>


            </div>
            <!-- page content -->
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
