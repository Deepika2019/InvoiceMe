<%@ Page Language="C#" AutoEventWireup="true" CodeFile="neworder.aspx.cs" Inherits="sales_neworder" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>New Bill  | Invoice Me</title>

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


        var cur_dat = "";
        var exactwalletamt = 0;
        var custId = "";
        var tax_type = 0;
        var isInclusive = 0;
        var accuracyNum=2;
        var sessionId=0;
        var slNo = 0;
        var allowZeroStockOrder = 0;
         var systemSettings= <%=settings%>
        console.log(systemSettings);
        $(document).ready(function () {
            sessionId = getSessionID();
            accuracyNum = systemSettings[0].ss_decimal_accuracy;
            allowZeroStockOrder = systemSettings[0].ss_allow_zero_stock_order;
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            getBranchTaxDetails(BranchId);
            custId = getQueryString('custId');
            var dt = new Date();
            cur_dat = dt.getDate() + '-' + (dt.getMonth() + 1) + '-' + dt.getFullYear();
            $("#comboBranchesInBill").val($.cookie("invntrystaffBranchId"));
            //alert($.cookie("invntrystaffBranchName"));
            $("#lblBranchName").text($.cookie("invntrystaffBranchName"));
            userButtonRoles();
            SearchAutoCustomer();
            bindItemAutoComplete();
            $("#customerNames").val('');
            $("#txtNames").val('');
            $("#txtMemberId").text("");
            $("#txtMemberName").text("");
            $("#txtoutstanding").text("");
            $("#txtPosPaidAmount").val(0);
            $("#txtPosBalanceAmount").val(0);
            $("#txtBillDate").text(cur_dat);
            $("#txtOutstandingBillDate").val("");
            $("#txtcreditamount").text("");
            $("#txtcreditperiod").text("");
            $("#txtnewcreditamt").val(0);
            $("#txtnewcreditperiod").val(0);
            $("#selcustomertype").val(0);
            $("#combodeliverystatus").val(0);
            $("#textwalletamt").val(0);
            $("#ItemTypecheck").attr("checked", false);
            if ($("#txtTotalGrossamount").text() == "") {
                disablepayment();
                $('#txtSpecialNote').val('');
            }

            $('#walletPayment').change(function () {
                var currentwalletamount = parseFloat($("#lblwalletamt").text());
                //  alert(currentwalletamount);
                var grand_netamount = parseFloat($("#txtPosBalanceAmount").val());
                //alert(grand_netamount);
                if ($(this).is(":checked")) {
                    if (grand_netamount.toFixed(accuracyNum) >= 0) {
                        if (grand_netamount.toFixed(accuracyNum) > currentwalletamount) {
                            $("#textwalletamt").val(currentwalletamount);
                        } else {
                            $("#textwalletamt").val(grand_netamount.toFixed(accuracyNum));
                        }
                        var paidwalletamt = parseFloat($("#textwalletamt").val());
                        currentwalletamount = currentwalletamount - paidwalletamt;
                        // $("#lblwalletamt").text(currentwalletamount.toFixed(2));
                        // $("#lblwalletamt").text(currentwalletamount);
                    } else {
                        $("#textwalletamt").val(0);
                        // $("#lblwalletamt").text(exactwalletamt);
                    }
                } else {
                    $("#textwalletamt").val(0);
                    //$("#lblwalletamt").text(exactwalletamt);
                }
                paymentMethod();
            });
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
           // alert(custId);
            if (custId !== "" && custId != 0 && typeof custId !== "undefined") {
                selectCustomer(custId);
            } else {
                $("#divSearchCustomer").show();
            }

        });


        function userButtonRoles() {
            var userTypeId = $.cookie("invntrystaffTypeID");
            loading();
            $.ajax({
                type: "POST",
                url: "neworder.aspx/showUserButtons",
                data: "{'userTypeId':'" + userTypeId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //  alert(msg.d);
                    if (msg.d == "N") {
                        return;
                    }
                    else {
                        var splitarray = msg.d.split("@#$");
                        var access = "alert('You Have No Permission..!'); return false;";
                        var newclick = new Function(access);
                        for (var i = 1; i <= splitarray[0]; i++) {
                            //alert(splitarray[i]);
                            $("#" + splitarray[i] + "").attr('onclick', '').click(newclick);

                        }
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }


        //edited anjana
        function SearchAutoCustomer() {
            var warehouse = $.cookie("invntrystaffBranchId");
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
                        url: "neworder.aspx/GetAutoCompleteCustData",
                        data: "{'variable':'" + $("#customerNames").val() + "','warehouse':'" + warehouse + "'}",
                        dataType: "json",
                        success: function (data) {
                            //var objJson = jQuery.parseJSON(data.d);
                            //alert(objJson);                             
                            //response(objJson);

                            //var obj = [{ label: 'Avacado Supermarket', value: '2' }];
                            //alert(data.d);
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    //alert(123);
                    if (ui.item.id == -1) {
                        $("#customerNames").val("");
                    } else {
                        $("#customerNames").val(ui.item.label);
                        searchCustomers(ui.item.id);//ui.item is your object from the array
                    }
                    // Prevent value from being put in the input:
                    //   $("#customerNames").val(ui.item.label); //ui.item is your object from the array
                    //console.log(ui.item.value);

                    event.preventDefault();
                },
                minLength: 1

            });



        }
        //edited by anjana

        //edited by freddy
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
                        parUrl = "neworder.aspx/GetAutoOfferItem";
                    }
                    else {
                        //SearchAutoItem();
                        //alert("SearchAutoItem()");
                        parUrl = "neworder.aspx/GetAutoCompleteData";
                        parData = "{'variable':'" + $("#txtNames").val() + "','BranchId':'" + BranchId + "','allowZeroStockOrder':'"+allowZeroStockOrder+"'}";
                    }

                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: parUrl,
                        data: parData,
                        dataType: "json",
                        success: function (data) {
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    //alert(123);
                    if (ui.item.id == -1) {
                        $("#txtNames").val("");
                    } else {
                        $("#txtNames").val(ui.item.label); //ui.item is your object from the array
                        //console.log(ui.item.value);
                        //searchCustomers(ui.item.id);
                        searchItems();
                    }
                    // Prevent value from being put in the input:

                    event.preventDefault();
                },
                minLength: 1

            });

        }
        //edited by freddy


        //function for disable payment
        function disablepayment() {
            $("#cbCashPayment").prop("disabled", true);
            $("#cbCashPayment").attr("checked", false);
            $("#cbCardPayment").prop("disabled", true);
            $("#cbCardPayment").attr("checked", false);
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

            $('#txtCardAmount').val('0');
            $('#txtCardAmount').prop("disabled", true);
            $('#txtCardType').val('');
            $('#txtCardType').prop("disabled", true);
            $('#txtCardNo').val('');
            $('#txtCardNo').prop("disabled", true);
            $('#txtCardBank').val('');
            $('#txtCardBank').prop("disabled", true);
        }

        //function for reset
        function resetcustomerdata() {
            tableclear();
            $("#divchangeDetails").hide();
            //  $("#hdnCurrentAction").val('main');
            for (var i = 1; i <= 9; i++) {
                $("#searchvalContent" + i).val('');
            }
            $("#combopricegroupdiv").val(0);
            $("#txtNames").val("");


            //  showpricegroups();
            searchCustomersCheck(1);

        }

        //function for table clearing
        function tableclear() {
            $(".classtest").remove();
            $("#txtposTotalCost").text("");
            $("#txtTotalDiscountRate").text("");
            $("#txtTotalDiscountAmount").text("");
            $("#txtTotalNetAmount").text("");
            $("#txtTotalGrossamount").text("");
            $("#txtPosPaidAmount").val("0");
            $("#txtPosBalanceAmount").val("0");
            $("#customerNames").val("");
            $("#txtNames").val("");
            $("#ItemTypecheck").attr("checked", false);
            disablepayment();
        }

        //function for search members
        function searchOrderCustomers() {
            tableclear();
            $("#divchangeDetails").hide();
            //  $("#hdnCurrentAction").val('main');
            for (var i = 1; i <= 9; i++) {
                $("#searchvalContent" + i).val('');
            }
            $("#combopricegroupdiv").val(0);
            $("#txtNames").val("");


            //  showpricegroups();
            searchCustomersCheck(1);

        }

        //for showing search values in  popup...
        function searchCustomersCheck(page) {
            var filters = {};
            if ($("#searchvalContent1").val() != "") {
                filters.cust_id = $.trim($("#searchvalContent1").val());
            }
            if ($("#searchvalContent2").val() != "") {
                filters.cust_name = $.trim($("#searchvalContent2").val());
            }

            if ($("#searchvalContent3").val() != "") {
                filters.cust_phone = $.trim($("#searchvalContent3").val());
            }
            if ($("#searchvalContent4").val() != "") {
                filters.cust_amount = $.trim($("#searchvalContent4").val());
            }

            if ($("#combopricegroupdiv").val() !== undefined && $("#combopricegroupdiv").val() != "0") {
                filters.cust_type = $("#combopricegroupdiv").val();
            }
            filters.warehouse = $.cookie("invntrystaffBranchId");
            console.log(JSON.stringify(filters));
            //   alert(filters.warehouse);
            var perpage = $("#txtpageno").val();
            console.log(JSON.stringify(filters));

            loading();

            $.ajax({
                type: "POST",
                url: "neworder.aspx/searchOrderCustomers",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    if (msg.d == "N") {
                        Unloading();
                        $("#lblCustTotalrecords").text(0);
                        //   alert("No Search Results");
                        $('#TBLshowSearchMembers tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatediv").html("");
                        //  $("#showSearchMembers").html('');
                        //$("#findMember").show();
                    }
                    else {
                        var obj = JSON.parse(msg.d)
                        //  console.log(obj);
                        Unloading();
                        $("#lblCustTotalrecords").text(obj.count);
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            console.log(row);
                            htm += "<tr id='customerRow" + i + "' onclick=javascript:selectCustomer('" + row.cust_id + "'); style='cursor:pointer;'>";
                            htm += "<td>" + getHighlightedValue(filters.cust_id, row.cust_id.toString()) + "</td>";
                            if (row.new_custtype == 0 && row.new_creditamt == 0 && row.new_creditperiod == 0) {
                                htm += "<td>" + getHighlightedValue(filters.cust_name, row.cust_name) + "</td>";
                            } else {
                                htm += "<td>" + getHighlightedValue(filters.cust_name, row.cust_name) + "<label class='label label-warning' style='margin-left:5px;'>To be confirmed</label></td>";
                            }


                            if (row.cust_type == 1) {
                                customer = "Class A";
                            }
                            else if (row.cust_type == 2) {
                                customer = "Class B";
                            }
                            else if (row.cust_type == 3) {
                                customer = "Class C";
                            }
                            if (row.cust_amount == null) {
                                row.cust_amount = 0;
                            }
                            htm += "<td>" + customer + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.cust_phone, row.cust_phone.toString()) + "</td>";
                            var style = "";
                            if (row.cust_amount <= 0) {
                                style = "color:green";
                            } else {
                                style = "color:red";
                            }
                            htm += "<td style='" + style + "'>" + getHighlightedValue(filters.cust_amount, row.cust_amount.toString()) + "</td>";

                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        // $("#showSearchMembers table").html(htm);

                        $("#TBLshowSearchMembers tbody").html(htm);

                        $("#paginatediv").html(paginate(obj.count, perpage, page, "searchCustomersCheck"));
                        //$("#popupcustomer").show();
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    //alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }
        // showing search values in  popup


        //function for after select customer
        function selectCustomer(customerId) {
            loading();

            $.ajax({
                type: "POST",
                url: "neworder.aspx/selectCustomerdata",
                data: "{'customerid':" + customerId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);
                        $("#dupMemberId").text(customerId);
                        $("#txtMemberId").text(customerId);
                        $("#txtMemberName").text(obj[0].cust_name);

                        $("#customerType").val(obj[0].cust_type);
                        if (obj[0].cust_amount == null) {
                            obj[0].cust_amount = 0;
                        }
                        $("#txtoutstanding").text(obj[0].cust_amount);
                        if (obj[0].cust_amount > 0) {
                            $("#txtoutstanding").css("color", "red");
                        } else {
                            $("#txtoutstanding").css("color", "green");
                        }
                        var wallet_amount_payable = obj[0].custBal > obj[0].cust_amount ? Math.abs(obj[0].cust_amount - obj[0].custBal) : obj[0].cust_amount < 0 ? Math.abs(obj[0].cust_amount) : 0;
                        $("#lblwalletamt").text(wallet_amount_payable);
                        exactwalletamt = wallet_amount_payable;
                        // alert(wallet_amount_payable);
                        //start changed on 04-12-2017
                        //if (obj[0].cust_amount >= 0) {
                        //    $("#txtoutstanding").text(obj[0].cust_amount);
                        //    $("#lblwalletamt").text(0);
                        //    exactwalletamt = 0;
                        //} else {
                        //    $("#txtoutstanding").text(0);
                        //    $("#lblwalletamt").text((-1) * obj[0].cust_amount);
                        //    exactwalletamt = (-1) * obj[0].cust_amount;
                        //}
                        //  exactwalletamt = obj[0].cust_wallet_amt;
                        //end changed on 04-12-2017

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
                        //   if (obj[0].new_creditamt==0&&)
                        $('#popupcustomer').modal('hide');
                        $("#divCustomerDetails").show();
                        $("#divChangesettings").show();
                        $("#divSearchCustomer").hide();
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

        function showchangedetailsDiv() {
            $("#divchangeDetails").show();
            $("#selcustomertype").val(0);
            $("#txtnewcreditamt").val(0);
            $("#txtnewcreditperiod").val(0);
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

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        //edited anjana
        function searchItems() {
            var memberid = $("#txtMemberId").text();
            var BranchId = $.cookie("invntrystaffBranchId");
            if (memberid == "") {
                alert("Please Select a Customer...!");
                $("#txtNames").val('');
                return false;
            }
            var searchName = $("#txtNames").val();
            var customertype = $("#customerType").val();
            var type;

            $("#ItemTypecheck").prop("checked") ? type = 1 : type = 0;
            $.ajax({
                type: "POST",
                url: "neworder.aspx/SearchItem",
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
                        //console.log(obj);
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
                                selectOrderItem(row.itm_code, row.itm_name, amount, row.itbs_id, row.itbs_stock, row.tp_tax_percentage, row.tp_cess);
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
                    console.log(xhr);
                    console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });
        }

        //function for type checking whether offer Item or normal items
        function checksearchItems() {
            $("#txtNames").val("");
            $("#customerNames").val("");
            $("#ItemTypecheck").prop("checked") ? resetoffer() : searchOrderitems();
        }

        //normal items search
        function searchOrderitems() {
            //  alert("");
            //   showsearchItems();
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            $("#combosearchitemtype").val(0);
            searchOrderitem(1);
        }

        function searchOrderitem(page) {
            var filters = {};
            var customertype = $("#customerType").val();
            filters.warehouse = $("#comboBranchesInBill").val();
            // alert(filters.warehouse);
            //     var CountryId = "0";
            if ($("#txtMemberId").text() == "") {
                alert("Please Select a Customer...!");
                return false;
            }
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itemname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itemcode = $("#searchposContent1").val();
            }
            //filters.isPackage = 0;
            if ($('#chkPackage').is(':checked')) {
                filters.isPackage = 1;
            }
            filters.allowZeroStockOrder = allowZeroStockOrder;
           // alert(isPackage);
            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "neworder.aspx/searchOrderitem",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + ",'customertype':" + customertype + ",'cust_id':'" + $("#txtMemberId").text() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tablePos tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        $("#popupItems").modal('show');
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        console.log(obj.data);
                        $("#lblItemTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            console.log(row);
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
                            htm += " onclick=javascript:selectOrderItem('" + row.itm_code.replace(/\s/g, '&nbsp;') + "','" + row.itm_name.replace(/\s/g, '&nbsp;') + "','" + amount + "','" + row.itbs_id + "','" + row.itbs_stock + "','" + row.tp_tax_percentage + "','" + row.tp_cess + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.itemcode, row.itm_code) + "</td><td>" + getHighlightedValue(filters.itemname, row.itm_name) + "</td><td>" + row.brand_name + "/" + row.cat_name + "</td>";
                            htm += "<td>" + row.itbs_stock + "</td><td>" + amount + "</td></tr>";
                            //alert(htm);
                            // $('#tablepos > tbody > tr:gt(' + (i + 2) + ')').remove();
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';

                        //   alert(htm);
                        $('#tablePos tbody').html(htm);
                        $("#popupItems").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitem"));


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

        //normal items search

        //offer search
        //function for offer serach
        function searchofferitems(page) {
            var customerId = $("#txtMemberId").text();
            if (customerId == "") {
                alert("Please Select a Customer...!");
                return false;
            }
            var WarehouseId = $("#comboBranchesInBill").val();
            var ofritemcode = $("#searchvalcontent1").val();
            var ofritemname = $("#searchvalcontent2").val();
            var perpage = $("#txtperpage").val();
            var TimeZone = $.cookie("invntryTimeZone");
            loading();
            var json_req = { perpage: perpage, WarehouseId: WarehouseId, page: page, TimeZone: TimeZone, ofritemcode: ofritemcode, ofritemname: ofritemname, cust_id: customerId };
            $.ajax({
                type: "POST",
                url: "neworder.aspx/searchofferitems",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(json_req),
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        $("#lblOfferTotalrecords").text(0);
                        for (var i = 2; i < ($('#tbloffer tr').length) ; i++) {
                            $('#tbloffer > tbody > tr:gt(' + i + ')').remove();
                        }
                        $('#tbloffer > tbody').html('<td colspan="6"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#offerpaginatediv").html("");
                        $("#popupOfferItems").modal('show');
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        $("#lblOfferTotalrecords").text(obj.count);
                        //  console.log(obj);
                        var htm = "";
                        //htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            if (row.ofr_type == 0) {
                                offertype = "Price/Discount Offer";
                            } else if (row.ofr_type == 1) {
                                offertype = "Free of Cost Offer";
                            } else if (row.ofr_type == 2) {
                                offertype = "Banded Offer";
                            }
                            htm += "<tr ";
                            htm += " onclick=javascript:selectOfferItem('" + row.ofr_code.replace(/\s/g, '&nbsp;') + "','" + row.ofr_title.replace(/\s/g, '&nbsp;') + "','" + row.ofr_price + "','" + row.ofr_discount + "','" + row.ofr_focqty + "','" + row.ofr_focnum + "','" + row.ofr_id + "','" + row.ofr_type + "'); style='cursor:pointer;'><td>" + row.ofr_code + "</td><td>" + row.ofr_title + "</td><td>" + offertype + "</td>";
                            htm += "<td>" + row.ofr_price + "</td><td>" + row.ofr_discount + "</td></tr>";

                        });

                        $('#tbloffer  tbody').html(htm);
                        $("#offerpaginatediv").html(paginate(obj.count, perpage, page, "searchofferitems"));
                        $("#popupOfferItems").modal('show');

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

        //function for offer reset
        function resetoffer() {
            for (i = 1; i <= 2; i++) {
                $("#searchvalcontent" + i).val("");
            }
            searchofferitems(1);
        }
        //offer search


        // start: Showing Details of selected  Item from Popup
        function selectOrderItem(item_code, item_name, item_sp, itbs_id, currentstock, tax_rate, cessRate) {
            //alert("product_code: " + product_code + ", product_name: " + product_name + ", sales_price: " + sales_price + ", CountryId: " + CountryId + ", Tax: " + Tax + ", Discount: " + Discount);
            var html = '';
            slNo++;
            var rowCount = $('#tblPosItems tr').length;
            // alert(rowCount);
            rowid = rowCount - 3;
            rowposition = rowCount - 2;
            var currentItems = Array();
            for (i = 1; i < rowposition; i++) {
                var currentId = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(13)').text());
                var itemtype = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(14)').find('input').val());
                var currentItem = [currentId, itemtype];
                currentItems.push(currentItem);
            }
            //   console.log(currentItems[0]);
            for (j = 0; j < currentItems.length; j++) {
                var array1 = currentItems[j];
                var array2 = [itbs_id, "0"];
                console.log(array1.join('|'));
                console.log(array2.join('|'));
                if (array1.join('|') === array2.join('|')) {
                    alert("This item already selected");
                    return false;
                }
            }
            var Discount = 0;
            var realprice = parseFloat(item_sp);
            //tax calculation starts on 25-8-2017
            if (tax_type == 0) // no tax
            {
                realtotal = realprice// price without discount
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
                }
                else {
                    realtotal = realprice;
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
            //realprice = realprice.toFixed(2);
            html = "<tr class='classtest'>";
            html = html + "<td>" + slNo + "</td>";
            html = html + "<td>" + item_code + "</td>";
            html = html + "<td>" + item_name.replace(/\u00a0/g, " "); +"</td>";
            html = html + "<td> " + parseFloat(item_sp) + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemSalePrice'); class='number-only textwidth' style=' width:98%;' value='" + realprice + "' data-initialValue='" + realprice + "' data-change='"+systemSettings[0].ss_price_change+"'/></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemQuantity'); class='number-only textwidth' style=' width:98%;' value='1' data-quantityval='" + currentstock + "' data-taxRate=" + tax_rate + " data-cessRate=" + cessRate + "/></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemFoc'); class='number-only textwidth' style=' width:98%;' value='0' data-initialValue='0' data-change='"+systemSettings[0]. 	ss_foc_change+"'/></td>";
            html = html + "<td>" + realtotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + Discount + "' data-initialValue='" + Discount + "' data-change='"+systemSettings[0].ss_discount_change+"'/></td>";

            html = html + "<td>" + discount_amt.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + nettotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + tax_amount.toFixed(accuracyNum) + "</td>";
            html = html + "<td>" + tax_included_nettotal.toFixed(accuracyNum) + "</td>";
            html = html + "<td style='display:none;'>" + itbs_id + "</td>";
            html = html + "<td style='display:none;'><input type='text' value='0' /></td>";
            html = html + "<td style='display:none;'>0</td>";
            //  html = html + "<td class='nonheadtext' style='padding:3px;display:none;'><input type='text' value='" + Discount + "'/></td>";

            html = html + "<td></td>";
            html = html + "<td></td>";

            html = html + "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
            html = html + "</tr>";
            //alert(html);
            AddNewRaw(html);
            popupclose('popupItems');


        }
        // Stop: Showing Details of selected  Item from Popup

        // start: Showing Details of selected  offer Item from Popup
        function selectOfferItem(offercode, offerTitle, offerTotalprice, offerDiscount, ofr_focqty, ofr_focnum, OfferId, offerType) {
            //offerDiscount = 0;
            var html = '';
            var rowCount = $('#tblPosItems tr').length;
            // alert(rowCount);
            rowid = rowCount - 3;
            rowposition = rowCount - 2;
            var offerprice = 0;
            var currentItems = Array();
            for (i = 1; i < rowposition; i++) {
                var currentId = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(10)').text());
                var itemtype = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(11)').find('input').val());
                var currentItem = [currentId, itemtype];
                currentItems.push(currentItem);
            }
            //   console.log(currentItems[0]);
            for (j = 0; j < currentItems.length; j++) {
                var array1 = currentItems[j];
                var array2 = [OfferId, "1"];
                console.log(array1.join('|'));
                console.log(array2.join('|'));
                if (array1.join('|') === array2.join('|')) {
                    alert("This item already selected");
                    return false;
                }
            }
            offerprice = offerTotalprice;
            var offerfoc = 0;
            if (offerType == "1") {
                html = "<tr style='cursor:pointer;' data-offerType='" + offerType + "' data-offerLimit='" + ofr_focqty + "' data-offerValue='" + ofr_focnum + "'>";
                if (ofr_focqty == 1) {
                    offerfoc = ofr_focnum;
                }
            } else if (offerType == "0") {
                html = "<tr style='cursor:pointer;'  data-offerType='" + offerType + "' data-offerLimit='" + ofr_focqty + "' data-offerValue='" + offerDiscount + "'>";
                if (ofr_focqty > 1) {
                    offerDiscount = 0;
                }
            }
            else {
                offerDiscount = 0;
                html = "<tr style='cursor:pointer;'>";
            }

            html = html + "<td>" + offercode + "</td>";
            html = html + "<td>" + offerTitle.replace(/\u00a0/g, " "); +"</td>";
            html = html + "<td> " + offerprice + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemSalePrice'); class='number-only textwidth' style=' width:98%;' value='" + offerprice + "' disabled/></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemQuantity'); class='number-only textwidth' style=' width:98%;' value='1'/></td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ItemFoc'); class='number-only textwidth' style=' width:98%;' value='" + offerfoc + "' data-initialValue='0' disabled/></td>";
            html = html + "<td>" + offerprice + "</td>";
            if (offerType == "2") {
                html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + offerDiscount + "' data-initialValue='" + offerDiscount + "' disabled/></td>";
                html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountAmount'); class='number-only textwidth' style=' width:98%;' value='" + (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)).toFixed(accuracyNum) + "' data-initialValue='" + (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)).toFixed(accuracyNum) + "' disabled/></td>";
            }
            else {
                html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountPercent'); class='number-only textwidth' style=' width:98%;' value='" + offerDiscount + "' data-initialValue='" + offerDiscount + "'/></td>";
                html = html + "<td><input type='text' onkeyup=modifyValues(this,'DiscountAmount'); class='number-only textwidth' style=' width:98%;' value='" + (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)).toFixed(accuracyNum) + "' data-initialValue='" + (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)).toFixed(accuracyNum) + "'/></td>";
            }
            // alert((parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)).toFixed(2));

            html = html + "<td><input type='text' onkeyup=modifyValues(this,'NetAmount'); class='number-only textwidth' style=' width:98%;' value='" + (parseFloat(parseFloat(offerprice) - (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)))).toFixed(accuracyNum) + "' data-initialValue='" + (parseFloat(parseFloat(offerprice) - (parseFloat(offerprice) * (parseFloat(offerDiscount) / 100)))).toFixed(accuracyNum) + "' /></td>";
            html = html + "<td style='display:none;'>" + OfferId + "</td>";
            html = html + "<td style='display:none;'><input type='text' value='1' /></td>";
            html = html + "<td style='display:none;'>0</td>";
            //   html = html + "<td class='nonheadtext' style='padding:3px;display:none;'><input type='text' value='" + offerDiscount + "'/></td>";

            html = html + "<td></td>";
            html = html + "<td></td>";
            html = html + "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
            html = html + "</tr>";
            //alert(html);
            AddNewRaw(html);
            popupclose('popupOfferItems');


        }
        // Stop: Showing Details of selected offer Item from Popup


        function AddNewRaw(html) {
            $('#TrSum').before(html);
            finalCalculation();
        }


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
            var unit_price = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
            var item_qty = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').val());
            var service_cost = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(7)').text());
            var discnt_percent = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val());
            var discnt_amount = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(9)').text());
            var net_amount = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(10)').text());
            var tax_amount = parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(11)').text()));

            var Total_net_amount = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(12)').text());
            var itemFoc = $.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(6)').find('input').val());
            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
            if (item_qty.match(regexqty)) {

            }
            else {
                var newVal1 = item_qty.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').val(newVal);
            }
            if (itemFoc.match(regexqty)) {

            }
            else {
                var newVal1 = itemFoc.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                $('#tblPosItems tr:eq(' + rowId + ') td:eq(6)').find('input').val(newVal);
            }
            if (service_cost == "") {
                service_cost = 0.00;
            }
            else {
                service_cost = (parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(7)').text()))).toFixed(accuracyNum);
            }
            if (discnt_percent == "") {
                discnt_percent = 0.00;
            }
            else {
                discnt_percent = (parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val()))).toFixed(accuracyNum);
            }
            if (discnt_amount == "") {
                discnt_amount = 0.00;
            }
            else {
                //changed by deepika on 02-11-16
                discnt_amount = (parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(9)').text()))).toFixed(accuracyNum);
                // alert(discnt_amount);
            }
            if (net_amount == "") {
                net_amount = 0.00;
            }
            else {
                net_amount = (parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(10)').text()))).toFixed(accuracyNum);
            }

            service_cost = parseFloat(unit_price * item_qty).toFixed(accuracyNum);
            // alert(service_cost);
            var realprice = 0;
            saleprice = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
            var discount = 0;
            var foc = 0;
            if (valueType == "ItemQuantity") {
                if (item_qty == "" || item_qty == 0) {
                    $(thisRowId).addClass("err");
                    $("#divsaveorder").css('pointer-events', 'none');
                    $("#divprintorder").css('pointer-events', 'none');
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(10)').text(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(12)').text(tax_amount);
                    return;
                }
                item_qty = parseFloat($.trim($('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').val()));

                if (isNaN(item_qty) == true) {
                    // alert("Check Quantity..!");
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').val("1");
                    return false;
                }
                else {
                    $(thisRowId).removeClass("err");
                    calculateValues(thisRowId);
                }
            }
            else if (valueType == "ItemSalePrice") {

                foc = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(6)').find('input').val());
                realprice = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(3)').text());
                saleprice = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
                if (isNaN(saleprice) == true || saleprice == 0) {
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val("");
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(7)').text(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(9)').text(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(10)').text(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(11)').text(0);
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(12)').text(0);
                    $(thisRowId).addClass("err");
                }
                else {
                    $(thisRowId).removeClass("err");
                    if (saleprice > realprice) {
                        $(thisRowId).css("color", "#77d217");
                    } else if (saleprice < realprice) {
                        $(thisRowId).css("color", "red");
                    } else if (saleprice == realprice) {
                        $(thisRowId).css("color", "#73879C");
                    }
                    calculateValues(thisRowId);

                }
            }

            else if (valueType == "DiscountPercent") {
                discount = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val());
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
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val(newVal);
                    $(thisRowId).addClass("err");

                }
                else if (isNaN(discnt_percent) == true) {
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val("0");
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
                    $('#tblPosItems tr:eq(' + rowId + ') td:eq(6)').find('input').val(itemFoc);
                    return false;
                } else {
                    foc = parseInt($('#tblPosItems tr:eq(' + rowId + ') td:eq(6)').find('input').val());
                    realprice = parseInt($('#tblPosItems tr:eq(' + rowId + ') td:eq(3)').text());
                    saleprice = parseInt($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
                    discount = parseInt($('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val());
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
            //console.log(parentRow);
            var isChanged = false;
            $(parentRow).find("[data-initialValue]").each(function (i) {
                //console.log(this);
                var currentvalue = parseFloat($(this).val().trim());
                var initialvalue = parseFloat($(this).attr('data-initialValue').trim());
                var changeNeeded=parseFloat($(this).attr('data-change').trim());
                if(isNaN(currentvalue)){
                    currentvalue=0;
                }
              //  alert(currentvalue);
                if(changeNeeded==1){
                    if (!isNaN(currentvalue)) {
                        if (currentvalue != initialvalue) {
                            console.log(currentvalue + "=" + initialvalue)
                            isChanged = true;
                        }
                    }
                }
                
            })
            if (isChanged) {
                $(parentRow).css('background-color', 'yellow');
                $(parentRow).attr("data-confirm", true);
                $('#tblPosItems tr:eq(' + rowId + ') td:eq(15)').text(1);

            }
            else {
                $(parentRow).css('background-color', '#ebebeb ');
                $(parentRow).attr("data-confirm", false);
                $('#tblPosItems tr:eq(' + rowId + ') td:eq(15)').text(0);
            }
        }
        //end function for color change

        function checkItemOffer(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            if ($(parentRow).attr('data-offertype') != undefined) {
                var offertype = parseFloat($(parentRow).attr('data-offertype').trim());

                if (offertype == 1) {
                    var item_qty = $.trim($(parentRow).find('td:eq(5)').find('input').val());
                    var offer_limit = parseFloat($(parentRow).attr('data-offerlimit').trim());
                    var offer_value = parseFloat($(parentRow).attr('data-offervalue').trim());
                    var tot_foc = Math.floor(item_qty / offer_limit) * offer_value;
                    $(parentRow).find('td:eq(6)').find('input').val(tot_foc);
                    $(parentRow).find('td:eq(6)').find('input').attr("data-initialvalue", tot_foc);
                }
                if (offertype == 0) {
                    var item_qty = $.trim($(parentRow).find('td:eq(5)').find('input').val());
                    var offer_limit = parseFloat($(parentRow).attr('data-offerlimit').trim());
                    var offer_value = parseFloat($(parentRow).attr('data-offervalue').trim());
                    if (item_qty >= offer_limit) {
                        $(parentRow).find('td:eq(8)').find('input').val(offer_value);
                        $(parentRow).find('td:eq(8)').find('input').attr("data-initialvalue", offer_value);
                    }
                    else {
                        $(parentRow).find('td:eq(8)').find('input').val(0);
                        $(parentRow).find('td:eq(8)').find('input').attr("data-initialvalue", 0);
                    }
                }
            }

        }

        function calculateValues(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            var rowId = parentRow.sectionRowIndex;
            var cessRate = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').attr('data-cessRate'));
            var tax_rate = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').attr('data-taxRate'));
            var saleprice = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').val());
            var item_qty = $('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').val();
            var discount = parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val());
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
            tax_amount = calculateTaxAmt(net_amount, parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(5)').find('input').attr('data-taxRate')), parseFloat($('#tblPosItems tr:eq(' + rowId + ') td:eq(4)').find('input').attr('data-cessRate')));
            Total_net_amount = parseFloat(parseFloat(net_amount) + parseFloat(tax_amount));
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(7)').text(service_cost.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(8)').find('input').val(discount);
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(9)').text(discount_amt.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(10)').text(net_amount.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(11)').text(tax_amount.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + rowId + ') td:eq(12)').text(Total_net_amount.toFixed(accuracyNum));

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

        //start function for calculating final amt
        function finalCalculation() {
            var rowCount = $('#tblPosItems tr').length;
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
                unit_price = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(4)').find('input').val());
                item_qty = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(5)').find('input').val());
                service_cost = parseFloat($('#tblPosItems tr:eq(' + i + ') td:eq(7)').text());
                discnt_percent = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(8)').find('input').val());
                discnt_amount = $.trim($('#tblPosItems tr:eq(' + i + ') td:eq(9)').text());
                net_amount = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(10)').text()));
                taxable_amt = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(10)').text()));
                tax_amt = parseFloat($('#tblPosItems tr:eq(' + i + ') td:eq(11)').text());
                bill_amount = parseFloat($('#tblPosItems tr:eq(' + i + ') td:eq(12)').text());

                if (item_qty == "" || item_qty == "0") {
                    item_qty = 1;
                }
                else {
                    item_qty = parseInt($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(5)').find('input').val()));
                }
                if (service_cost == "") {
                    service_cost = 0.00;
                }
                else {
                    service_cost = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(7)').text()));
                }
                if (discnt_percent == "") {
                    discnt_percent = 0.00;
                }
                else {
                    discnt_percent = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(8)').find('input').val()));
                }
                if (discnt_amount == "") {
                    discnt_amount = 0.00;
                }
                else {
                    discnt_amount = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(9)').text()));

                }
                if (net_amount == "" || isNaN(net_amount) == true) {
                    net_amount = 0.00;
                }
                else {
                    if (isInclusive == 1) {
                        net_amount = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(12)').text()));
                        inclusiveTotal = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(7)').text()));
                    } else {
                        net_amount = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(10)').text()));
                    }
                    taxable_amt = parseFloat($.trim($('#tblPosItems tr:eq(' + i + ') td:eq(10)').text()));
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
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(7)').text(grand_total.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(8)').text(grand_distcnt_perc.toFixed(accuracyNum));    //Total Discount Percentage
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(9)').text(grand_distcnt_amount.toFixed(accuracyNum));  //Total Discount Amount
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(10)').text(grand_netamount.toFixed(accuracyNum));       //Total Net Amount
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(11)').text(grand_Taxamount.toFixed(accuracyNum));
            $('#tblPosItems tr:eq(' + total_rowid + ') td:eq(12)').text(grand_netBillamount.toFixed(accuracyNum));
            $("#txtTotalGrossamount").text(grand_netBillamount.toFixed(accuracyNum)); //Grand Total Amount
            $("#txtPosPaidAmount").val(0.00);                       //Paid Amount
            $("#txtPosBalanceAmount").val(grand_netBillamount.toFixed(accuracyNum)); //Balance Amount
            paymentMethod();
        }
        //end function for calculating final amt

        //start function for delete row
        function DeleteRaw(ctrl) {
            var result = confirm("Want to delete?");
            if (result) {
                //Logic to delete the item
                $(ctrl).closest('tr').remove();
                var rowCount = parseInt($('#tblPosItems tr').length);
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
                loadSerialNumbers();
                // calculteTable();
                finalCalculation();
            } else {
                return false;
            }

        }
        //end function for delete row

        //for disabling and enabling payment method textboxes
        function paymentMethod() {
            var tblrowCount = $('#tblPosItems tr').length;
            if ($("#txtTotalGrossamount").text() == "0.00" && tblrowCount <= 3) {
                disablepayment();
            }
            else {
                $("#cbCashPayment").prop("disabled", false);
                $("#cbChequePayment").prop("disabled", false);
                $("#cbCardPayment").prop("disabled", false);
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
                $("#txtChequeAmount").val('');
                $("#txtChequeNo").val('');
                $("#txtChequeDate").val('');
                $("#txtBankName").val('');
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
                $("#txtBankName").attr("disabled", true);
                $("#txtCardAmount").val('');
                $("#txtCardNo").val('');
                $("#txtCardType").val('');
                $("#txtCardBank").val('');
            }

            if ($(document).find("[data-confirm=true]").length > 0) {
                disablepayment();
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

            var cardAmount = $("#txtCardAmount").val();
            if (cardAmount == "") {
                cardAmount = 0;
            }
            var walletamt = 0;

            //change code

            //change code
            var cashTotal = parseFloat(cashAmount) + parseFloat(chequeAmount) + parseFloat(cardAmount);

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
                    //  $("#lblwalletamt").text(exactwalletamt);
                }
                else if (parseFloat(bal) > 0 && parseFloat(bal) < parseFloat(exactwalletamt)) {
                    // alert("3 bal " + bal + "   extwallet" + exactwalletamt);
                    $("#textwalletamt").val(bal);
                    //  $("#lblwalletamt").text(parseFloat(exactwalletamt) - parseFloat(bal));
                }
                walletamt = $("#textwalletamt").val();

            }
            //alert("asdf" + parseFloat($("#txtPosBalanceAmount").val()) + "Wallet " + parseFloat($("#textwalletamt").val()));

            cashTotal = parseFloat(cashAmount) + parseFloat(chequeAmount) + parseFloat(walletamt) + parseFloat(cardAmount);

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

        function changecurrentwalletamt() {
            //wallet amount changing start

            var currentwalletamount = parseFloat($("#lblwalletamt").text());
            var grand_netamount = parseFloat($("#txtPosPaidAmount").text());
            $('#checkbox1').change(function () {
                if ($(this).is(":checked")) {

                    if (grand_netamount.toFixed(accuracyNum) > currentwalletamount) {
                        $("#textwalletamt").val(currentwalletamount);
                    } else {
                        $("#textwalletamt").val(grand_netamount.toFixed(accuracyNum));
                    }
                    var paidwalletamt = parseFloat($("#textwalletamt").val());
                    currentwalletamount = currentwalletamount - paidwalletamt;
                    $("#lblwalletamt").text(currentwalletamount);
                } else {
                    $("#lblwalletamt").text(exactwalletamt);
                }
            });

            //wallet amount changing end
        }

        //start: for rounding final Price
        function roundPrice() {

            var tblrowCount = $('#tblPosItems tr').length;
            if (tblrowCount <= 3) {
                return;
            }

            var GrossAmount = $("#txtTotalGrossamount").text();
            var newGrossAmount = Math.round(GrossAmount).toFixed(accuracyNum);
            $("#txtTotalGrossamount").text(newGrossAmount);
            var Difference = parseFloat(newGrossAmount) - parseFloat(GrossAmount);
            // alert(Difference);
            Difference = Difference.toFixed(accuracyNum);
            var currDiscount = $.trim($('#tblPosItems tr:eq(1) td:eq(9)').text());
            // alert(Difference);


            if (Difference > 0) {
                var newDiscount = parseFloat(currDiscount) - parseFloat(Difference);
                $.trim($('#tblPosItems tr:eq(1) td:eq(9)').text(newDiscount.toFixed(accuracyNum)));
                // alert(newDiscount);
            }
            else {
                // alert("s");
                //  alert(currDiscount);
                //  alert(Difference);
                var newDiscount = parseFloat(currDiscount) - parseFloat(Difference);
                newDiscount = newDiscount.toFixed(accuracyNum);
                //  alert(newDiscount);
                $.trim($('#tblPosItems tr:eq(1) td:eq(9)').text(newDiscount));

            }
            modifyValues(1, 'DiscountAmount');
        }
        //start: for rounding final Price

        //save to bill header

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
        function saveToSalesMaster(take_print) {
            sqlInjection();
            var userid = $.cookie("invntrystaffId");
            var MemberId = $("#txtMemberId").text();
            if (MemberId == "") {
                alert("Please select your customer...");
                return;
            }
            var tblrowCount = $('#tblPosItems tr').length;
            if (tblrowCount <= 3) {
                alert("Please Add Item...");
                return;
            }

            var TotalBalanceAmount = $("#txtPosBalanceAmount").val();
            var totaloutanding = $("#txtoutstanding").text();

            var BranchId = $.cookie('invntrystaffBranchId');
            var SpecialNote = $("#txtSpecialNote").val();
            var BankName = $("#txtBankName").val();
            var ChequeDate = $("#txtChequeDate").val();
            var ChequeNo = $("#txtChequeNo").val();
            var ChequeAmount = $("#txtChequeAmount").val();
            var CashAmount = $("#txtCashAmount").val();
            var CardAmount = $("#txtCardAmount").val();
            if (CashAmount == '') {
                CashAmount = 0;
            }
            if (ChequeAmount == '') {
                ChequeAmount = 0;
            }
            if (CardAmount == '') {
                CardAmount = 0;
            }
            var walletamt = 0;
            if ($("#walletPayment").is(':checked')) {
                walletamt = $("#textwalletamt").val();

            } else {
                walletamt = 0;
            }
            rowCount = tblrowCount - 3;
            //  alert(rowCount);
            if (rowCount == 0) {
                alert("select an item");
                return;
            }
            var paymentMode = $("#comboPaymentMode").val();
            if (paymentMode == 0) {
                alert("select any payment mode");
                $("#comboPaymentMode").focus();
                return;
            }
            var itemstring = '';
            for (var row = 1; row <= rowCount; row++) {
                itemstring += "{";
                for (var col = 0; col <= 15; col++) {
                    if (col != 4 && col != 5 && col != 6 && col != 8 && col != 14) {

                        if (col == 13) {
                            itemstring += "'itbs_id':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }
                        if (col == 15) {
                            itemstring += "'si_approval_status':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "'";
                        }
                        if (col == 3) {
                            itemstring += "'si_org_price':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ")").text() + "',";
                        }

                    }
                    else {
                        //alert($("#tblPosItems tr:eq(" + row + ") td:eq(3) input").val());
                        if ($("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() == "") {

                            if ($("#tblPosItems tr:eq(" + row + ") td:eq(5) input").val() == "") {
                                itemstring += "'si_qty':'1',";
                            }
                            else {
                                itemstring += "'si_qty':'0',";
                            }

                        }
                        else {
                            if (col == 4) {
                                itemstring += "'si_price':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 5) {
                                itemstring += "'si_qty':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 6) {
                                itemstring += "'si_foc':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }
                            if (col == 8) {
                                itemstring += "'si_discount_rate':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
                            }

                            if (col == 14) {
                                itemstring += "'si_itm_type':'" + $("#tblPosItems tr:eq(" + row + ") td:eq(" + col + ") input").val() + "',";
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
            console.log(itemstring);
            itemstring = "[" + itemstring + "]";
            console.log(itemstring);
            //start changes on 18-apr-2017
            if ($("#cbCashPayment").is(':checked')) {
                if ($('#txtCashAmount').val() == "" || isNaN($('#txtCashAmount').val())) {
                    alert("Enter a valid Cash Amount");
                    return;
                }
                //    paymentmode = "Cash";
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
                else if ($('#txtChequeDate').val() == "") {
                    alert("Enter Cheque Date");
                    return;
                }
                else if ($('#txtBankName').val() == "") {
                    alert("Enter Bank Name");
                    return;
                }
                //paymentmode = "Cheque";
            }


            if ($("#cbCardPayment").is(':checked')) {
                if ($('#txtCardAmount').val() == "" || isNaN($('#txtCardAmount').val())) {
                    alert("Enter a valid card Amount");
                    return;
                }
                else if ($('#txtCardNo').val() == "") {
                    alert("Enter Card No");
                    return;
                }
                //else if ($('#txtCardType').val() == "") {
                //    alert("Enter Card Type");
                //    return;
                //}
                //else if ($('#txtCardBank').val() == "") {
                //    alert("Enter Card Bank Name");
                //    return;
                //}
                //paymentmode = "Cheque";
            }


            //end changes on 18-apr-2017
            var creditamount = 0;
            //if (parseFloat(TotalBalanceAmount) < 0) {
            //    alert("Paid amount should not be greater than Net Amount");
            //    return false


            //    ;
            //}
            console.log(creditamount);


            //  alert(tableString);
            var PosCurrentPaidAmount = $("#txtPosPaidAmount").val();
            var PosBalanceAmount = $("#txtPosBalanceAmount").val();

            if (PosCurrentPaidAmount == '') {
                alert("Please Enter Paid Amount");
                return;
            }
            var deliverstatus = 0;
            if ($(document).find("[data-confirm=true]").length > 0) {
                deliverstatus = 3;

            }
           

            //STARTS APPROVE HEAD
            var acknowledgment = {};
            if ($("#checkSaleHead").is(':checked')) {
                acknowledgment.salesTick = 1;
            }// checked
            else {
                acknowledgment.salesTick = 0;
            }

            if ($("#checkAccount").is(':checked')) {
                acknowledgment.accountTick = 1;
            }// checked
            else {
                acknowledgment.accountTick = 0;
            }
            if ($("#checkDelivery").is(':checked')) {
                acknowledgment.deliveryTick = 1;
            }// checked
            else {
                acknowledgment.deliveryTick = 0;
            }
            //END APPROVE HEAD
            var postObj = {

                neworder: {

                    sessionId: sessionId,
                    sm_cash_amt: CashAmount,
                    sm_wallet_amt: walletamt,
                    sm_chq_amt: ChequeAmount,
                    sm_chq_date: ChequeDate,
                    sm_bank: BankName,
                    sm_chq_no: ChequeNo,
                    sm_card_amt: CardAmount,
                    sm_card_no: $("#txtCardNo").val(),
                    sm_card_type: $("#txtCardType").val(),
                    sm_card_bank: $("#txtCardBank").val(),
                    branch_tax_method: tax_type,
                    branch_tax_inclusive: isInclusive,
                    branch: BranchId,
                    sm_userid: userid,
                    cust_id: MemberId,
                    sm_delivery_status: deliverstatus,
                    sm_specialnote: SpecialNote,
                    sm_latitude: 0,
                    sm_longitude: 0,
                    sm_order_type: 1,
                    sm_payment_type: paymentMode,
                    item_details: itemstring,
                    acknowledgement: JSON.stringify(acknowledgment)
                }
                //item_details: item_list

            };
            console.log(postObj);
            bootbox.confirm("Do you want to continue?", function (result) {
                console.log(result)
                if (result) {
                    loading();
                    // alert("{'MemberId':'" + MemberId + "','MemberName':'" + MemberName + "','TotalCost':'" + TotalCost + "','TotalDiscountRate':'" + TotalDiscountRate + "','TotalDiscountAmount':'" + TotalDiscountAmount + "','Tax':'" + TaxAmount + "','billdate':'" + cur_dat + "','userid':'" + userid + "','TotalAmount':'" + TotalAmount + "','TotalCurrentAmount':'" + TotalCurrentAmount + "','TotalBalanceAmount':'" + TotalBalanceAmount + "','TotalPaidinFull':'" + TotalPaidinFull + "','paymentmode':'" + paymentmode + "','BankName':'" + BankName + "','ChequeAmount':'" + ChequeAmount + "','ChequeDate':'" + ChequeDate + "','ChequeNo':'" + ChequeNo + "','CardAmount':'" + CardAmount + "','CardNo':'" + CardNo + "','CardType':'" + CardType + "','CardBank':'" + CardBank + "','CashAmount':'" + CashAmount + "','CountryId':'" + CountryId + "','BranchId':'" + BranchId + "','SpecialNote':'" + SpecialNote + "','outstandingBillDate':'" + outstand_bl_dt + "','TimeZone':'" + TimeZone + "','tableString':'" + tableString + "','rowCount':" + rowCount + ",'PosCurrentPaidAmount':'" + PosCurrentPaidAmount + "','PosBalanceAmount':'" + PosBalanceAmount + "'}");
                    $.ajax({
                        type: "POST",
                        url: "neworder.aspx/saveToSalesMaster",
                        data: JSON.stringify(postObj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "N" || msg.d == "FAILED") {
                                alert("Error!.. Please Try Again...");
                                return;
                            }
                            else {
                                if (deliverstatus == 3) {
                                    alert("There is a need of Confirmation from Admin Side");
                                    location.reload();
                                //    window.location = 'manageorders.aspx?orderId=' + msg.d;
                                    //setTimeout(function () {
                                    //    window.location = 'manageorders.aspx?orderId=' + msg.d;
                                    //}, 2000);

                                }
                                else {
                                    if (take_print) {
                                        if (tax_type == 0) {
                                            window.location.href = "billreceipt.aspx?orderId=" + msg.d;
                                        } else if (tax_type == 1) {
                                            window.location.href = "normalBillreceipt.aspx?orderId=" + msg.d;
                                        } else if (tax_type == 2) {
                                            window.location.href = "gstBillreceipt.aspx?orderId=" + msg.d;
                                        }

                                    }
                                    else {
                                        alert("Bill saved successfully");
                                        location.reload();
                                        //setTimeout(function () {
                                        //    location.reload();
                                        //}, 2000);
                                        //    window.location.reload(true);
                                    }

                                    return true;
                                }
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

        function searchCustomers(custid) {
            //var customer_name = $("#customerNames").val();
            tableclear();
            $.ajax({
                type: "POST",
                url: "neworder.aspx/searchCustomer",
                data: "{'customer_id':'" + custid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d == "N") {
                        //alert("No search Results");
                        //$("#searchTitle").show();
                    } else {
                        //$("#searchTitle").hide();
                        var obj = JSON.parse(msg.d);
                        console.log(obj);
                        Unloading();
                        $.each(obj.data, function (i, row) {
                            selectCustomer(row.cust_id);
                        });
                        $("#customerNames").val('');
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }


        function changecustomerdetails() {
            var memberid = $("#txtMemberId").text();
            if (memberid == "") {
                alert("Please Select a Customer...!");
                return false;
            }
            var newclasstype = $("#selcustomertype").val();
            var newamount = $("#txtnewcreditamt").val();
            var newperiod = $("#txtnewcreditperiod").val();
            var userId = $.cookie("invntrystaffId");
            var userType = $.cookie("invntrystaffTypeID");
            if (newclasstype == 0 && newamount == 0 && newperiod == 0) {
                alert("Change atleast one value");
                return false;
            }

            if (isNaN($("#txtnewcreditamt").val())) {
                alert("Amount should be in number only");
                $("#txtnewcreditamt").focus();
                return;
            }

            if (isNaN($("#txtnewcreditperiod").val())) {
                alert("Period should be in number only");
                $("#txtnewcreditperiod").focus();
                return;
            }

            loading();
            var json_req = { customerid: memberid, newclasstype: newclasstype, newamount: newamount, newperiod: newperiod, userid: userId, userType: userType }
            $.ajax({
                type: "POST",
                url: "neworder.aspx/changecustomerdetails",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(json_req),
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        alert("cannot updated the customer details");
                    } else {
                        alert("problem occured");
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                    // alert(xhr.status);
                    if (xhr.status == 401) {
                        window.location.reload(true);
                    } if (xhr.status == 403) {
                        selectCustomer(memberid);
                        Closechangecustomerdetails();
                    }
                    //tableclear();
                    //$("#divchangeDetails").hide();
                }

            });
        }


        function Closechangecustomerdetails() {
            $("#divchangeDetails").hide();
        }

        function changeInputsearchDiv() {
            $("#divchangesettings").hide();
            $("#divchangeDetails").hide();
            $("#divSearchCustomer").show();
            $("#divCustomerDetails").hide();
            $("#txtMemberId").text("");
            tableclear();
        }

        function getBranchTaxDetails(warehouse) {
            $.ajax({
                type: "POST",
                url: "neworder.aspx/getBranchTaxDetails",
                data: "{'warehouse':'" + warehouse + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);
                        //alert(obj.data[0].branch_tax_method);
                        tax_type = obj.data[0].branch_tax_method;
                        isInclusive = obj.data[0].branch_tax_inclusive;
                    } else {
                        alert("Connection Problem...");
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

        function loadSerialNumbers(){

            for (var row = 1; row < $('#tblPosItems tr').length-2; row++) {
                $("#tblPosItems tr:eq(" + row + ") td:eq(0)").text(row) ;
            }
            slNo=$('#tblPosItems tr').length-3;
        }
    </script>
  
</head>
    <style>

    </style>
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
                                <label style="font-weight: bold; font-size: 16px;">New Bill</label>

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
                           

                                <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" style="padding-left:0px;">
                                     <div class="x_panel">
                             
                                         <input type="hidden" id="comboBranchesInBill"/>
                                    <label id="lblBranchName" style="font-weight:bold; font-size:20px;"></label><br />
                                     <label style="font-size:14px;"><span id="txtBillDate">16/08/2016</span></label>
                                     </div>
                                </div>
                            <div class="col-md-8 col-sm-6 col-xs-12" style="padding-left:0px">
                             <div class="x_panel">
                                <div class="col-md-12" id="divSearchCustomer">
                                <div class="col-md-11 col-sm-6 col-xs-12 form-group has-feedback">
                                    <input type="text" class="form-control has-feedback-left" id="customerNames" placeholder="Search Customer">
                                    <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                </div>
                             
                                <div class="col-md-1 col-sm-6 col-xs-6 <%--form-group has-feedback--%>">
                                    <div class="pull-right" style="font-size: 20px;" data-toggle="modal" data-target="#popupcustomer" onclick="javascript:resetcustomerdata();">
                                        <label class="fa fa-user" style="cursor: pointer;"></label>
                                        <label class="fa fa-search" style="cursor: pointer; font-size: 20px; color: #ff6a00; position: relative; margin-left: -12px;"></label>
                                    </div>
                                    <%-- popup for show customers --%>
                                    <div class="container">

                                        <!-- Trigger the modal with a button -->
                                        <%--  <button >Open Modal</button>--%>

                                        <!-- Modal -->
                                        <div class="modal fade" id="popupcustomer" role="dialog">
                                            <div class="modal-dialog modal-lg" style="">

                                                <!-- Modal content-->
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <button type="button" class="close" onclick="javascript:popupclose('popupcustomer');">&times;</button>
                                                        <div class="col-md-7 col-sm-6 col-xs-8">
                                                            <h4 class="modal-title">Customers<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblCustTotalrecords">0</span></h4>
                                                        </div>
                                                         <div class="col-md-4 col-sm-12 col-xs-12">
                                                           

                                                                <div class="col-md-10 col-sm-12 col-xs-12">
                                                                      <button class="btn btn-primary mybtnstyl" type="button" style="float:right;" onclick="javascript:searchOrderCustomers();">
                                                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                        Reset
                                                                    </button>
                                                                    <button type="button" class="btn btn-success mybtnstyl" style="float:right;"  onclick="javascript:searchCustomersCheck(1);">
                                                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                        Search
                                                                    </button>
                                                              
                                                                  
                                                                </div>
                                                                  <div class="col-md-2 col-sm-12 col-xs-3">
                                                                    <select id="txtpageno" onchange="javascript:searchCustomersCheck(1);"  name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                        <option value="25">25</option>
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

                                                            <table id="TBLshowSearchMembers" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                <thead>
                                                                    <tr>
                                                                        <th>ID</th>
                                                                        <th>Name</th>
                                                                        <th>Type	</th>
                                                                        <th>Phone</th>
                                                                        <th>Outstanding</th>

                                                                    </tr>


                                                                    <tr>
                                                                        <td>
                                                                            <input type="text" class="form-control" id="searchvalContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                        <td>
                                                                            <input type="text" id="searchvalContent2" class="form-control" /></td>
                                                                        <td>
                                                                            <select id="combopricegroupdiv" class="form-control">
                                                                                <option value="0">Select</option>
                                                                                <option value="1">Class A</option>
                                                                                <option value="2">Class B</option>
                                                                                <option value="3">Class c</option>
                                                                            </select>

                                                                        </td>
                                                                        <td>
                                                                            <input type="text" class="form-control" id="searchvalContent3" style="width: 120px; padding-right: 2px;" /></td>
                                                                        <td>
                                                                            <input type="text" class="form-control" id="searchvalContent4" style="width: 100px; padding-right: 2px;" /></td>

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
                                    <div class="clearfix"></div>
                                  <div style="height:18px;" id="divExtraHeight"></div>
                                    </div>

                                 <div class="clearfix"></div>
                                 <div class="row invoice-info" id="divCustomerDetails" style="display:none;font-size:12px;font-weight: normal;">
                                        <div class="col-sm-6 invoice-col">
                                            <div class="pull-left">
                                            <b  style="font-size:14px;">#
                                                <label id="dupMemberId" style="display: none;"></label>
                                                <label id="txtMemberId"></label>
                                            </b>                                           
                                           <label id="txtMemberName" style="font-size:14px; padding-bottom:5px;"></label></div><div class="pull-left" style="font-size: 18px;margin-left:20px;" onclick="javascript:changeInputsearchDiv();" title="Search Customer">
                                        <label class="fa fa-user" style="cursor: pointer;"></label>
                                        <label class="fa fa-search" style="cursor: pointer; font-size: 20px; color: #ff6a00; position: relative; margin-left: -12px;"></label>
                                    </div>
                                            <div class="clearfix"></div>

                                                           <b>Class </b><label id="txtcustomertype"></label>
                                          
                                            <b style="padding-left:10px;">Payment Mode:</b><label>
                                                <select id="comboPaymentMode">
                                                     <option value="1">Cash</option>
                                                     <option value="2">Credit</option>
                                                     <option value="3">Bill to bill</option>
                                                </select>
                                                                </label>

                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-3 invoice-col">
                                            <b>Credit Amt:</b>
                                            <label id="txtcreditamount"></label>
                                            <br />
                                           <b> Period:</b>
                                            <label id="txtcreditperiod"></label> Days
                                        </div>
                                        <!-- /.col -->

                                        <div class="col-sm-2 invoice-col">
                                           
                                            <b>A/C Balance:</b><label id="txtoutstanding" style="color: #432727; font-size: 14px; font-weight: bold; color: red;">0</label>
                                        </div>
                                        <!-- /.col -->
                                 
                                        <div class="col-sm-1 invoice-col" onclick="showchangedetailsDiv();" id="divChangesettings" style="display: none;">
                                            <button type="button" class="btn btn-warning pull-right" style="font-size: 11px; padding: 4px; font-weight: bold;">                                               
                                                Edit
                                            </button>
                                            
                                        </div>

                                        <!-- /.col -->
                                    </div>
                                </div>
                                </div> 
                            </div>
                       
                    </div>
                    <div class="clearfix"></div>
                    <div class="row" >
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel"  id="divchangeDetails" style="display: none;" >
                              
                                <div class="x_title" style="margin-bottom: 0px; padding-bottom:0px;" >
                                    <label class="pull-left" style="margin-bottom:5px;">Edit Details </label>
                                    <div class="clearfix"></div>
                                </div>
                                <div class="x_content">
                                 
                                </div>
                                <div class="clear"></div>
                                <div class="x_content" style="background: #e9e9e9;font-size:12px;font-weight: normal;">

                                    <!-- info row -->
                                    <div class="row invoice-info">
                                        <div class="" style="height: 20px;"></div>
                                        <div class="col-md-12 col-sm-12 col-xs-12">
                                            <div class="col-md-3 col-sm-12 col-xs-12">
                                            <div class="col-md-3 col-sm-6 col-xs-6"><label>Class</label> </div>
                                            <div class="col-md-8 col-sm-6 col-xs-6">
                                                <select class="form-control" style="height: 24px; margin-bottom:10px;" id="selcustomertype">
                                                    <option value="0">Select</option>
                                                    <option value="1">Class A</option>
                                                    <option value="2">Class B</option>
                                                    <option value="3">Class C</option>
                                                </select>
                                            </div>
                                        </div>
                                        <!-- /.col -->
                                       <div class="col-md-3 col-sm-12 col-xs-12">
                                            <div class="col-md-6 col-sm-6 col-xs-6 " style="padding-right: 0px; margin-right: 0px; "><b>Credit Amount</b></div>
                                            <div class="col-md-3 col-sm-6 col-xs-6" style="float: left;">
                                                <input type="text" class="form-control" style="margin-left: 0px; width:70px; margin-bottom:10px; height: 24px; padding-left:2px; padding-right:0px;" id="txtnewcreditamt" />

                                            </div>
                                        </div>
                                       
                                        <!-- /.col -->
                                    <div class="col-md-3 col-sm-12 col-xs-12">
                                        <div class="col-md-5 col-sm-6 col-xs-6"style="padding-right: 0px; margin-right: 0px; ">
                                           
                                                <b>Credit Period</b>
                                            </div>
                                            <div class="col-md-6 col-sm-6 col-xs-6" style="padding-right: 5px; padding-left: 5px; ">
                                                <div class="col-md-8 col-sm-6 col-xs-8" style="float:left;">
                                                <input type="text" class="form-control" style="float: left; width:70px; height: 24px; margin-bottom:10px; padding-left:2px; padding-right:0px;margin-left:-4px;" id="txtnewcreditperiod" />
                                                    </div>
                                                <div class="col-md-2 col-sm-6 col-xs-4" style="float:left;">
                                                <span>Days</span>
                                                
                                            </div>
                                      
                                        </div>
                                     <//div>
                                             </div>
                                        <!-- /.col -->
                                     <div class="col-md-3 col-sm-12 col-xs-12">
                                           <div class=" " onclick="Closechangecustomerdetails()">
                                                <button type="submit" class="btn btn-warning pull-right" style="font-size: 11px; padding: 4px; font-weight: bold;">
                                                    Cancel
                                                </button>
                                            </div>
                                            <div class=" " onclick="changecustomerdetails()">
                                                <button type="submit" class="btn btn-warning pull-right" style="font-size: 11px; padding: 4px; font-weight: bold;">
                                                    Update
                                                </button>
                                            </div>
                                          
                                        </div>
                                        <!-- /.col -->
                                    
                                    <!-- /.row -->
                               

                            </div>
                        </div>
                    </div>
                            </div>
                 

                    <div class="clearfix"></div>
                    
                        <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px;">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom:6px; padding-bottom:0px;">
                                    <label style="" class="pull-left">Items</label>
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
                                
                                    <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px; padding-right:0px;">
                                        <div class="col-md-6 col-sm-6 col-xs-12" style="padding-left:0px;">
                                            <div class="col-md-4 col-sm-6 col-xs-9" style="padding-right:0px; padding-left:0px;display:none;"><label>View Only Offer Items</label></div>
                                            <div class="col-md-2 col-sm-6 col-xs-3" style="padding-left:0px;display:none;">
                                               <div class="checkbox" style="margin-top:0px; margin-bottom:0px;">
                                         <label style="font-size: 1.3em">
                                                      <input type="checkbox" value="" id="ItemTypecheck" />
                                          <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
                                             </label>
                                           </div> 
                                        </div>
                                            </div>
                                        <div class="col-md-6 col-sm-6 col-xs-12" style="padding-right:0px;">
                                            <div class="col-md-10 col-sm-6 col-xs-8">
                                                <input type="search" class="form-control" placeholder="Search Item" id="txtNames" />
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-4" onclick="javascript:checksearchItems();" style="padding-right:0px;">
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
                                                                <div class="col-md-7 col-sm-6 col-xs-6">
                                                                    <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords">0</span></h4>
                                                                </div>
                                                                <div class="col-md-4 col-sm-4 col-xs-12">                                                 
                                                                   
                                                                    <div class="col-md-10 col-sm-12 col-xs-12">
                                                                        
                                                                        <div class="" onclick="javascript:searchOrderitems();" style="float:right;">
                                                                            <button class="btn btn-primary mybtnstyl" type="reset">
                                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                                Reset
                                                                            </button>
                                                                        </div>
                                                                        <div class="" onclick="javascript:searchOrderitem(1);">
                                                                            <button type="button" class="btn btn-success mybtnstyl" style="float:right;">
                                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                                Search
                                                                            </button>
                                                                        </div>
                                                                        </div>
                                                                         <div class="col-md-2 col-sm-12 col-xs-3">
                                                                            <select id="txtpospageno" onchange="javascript:searchOrderitem(1);"  name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                               <option value="25">25</option>
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

                                                                    <table id="tablePos" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Code</th>
                                                                                <th>Name &nbsp &nbsp&nbsp &nbsp<label style="color:green"><input type="checkbox" value="" id="chkPackage" onchange="searchOrderitem(1)"/>PACKAGES</label></th>                                                                            
         
                                                                                <th>Brand/Category</th>
                                                                                <th>Stock</th>
                                                                                <th>Price</th>

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

                                            <%-- pop up for show offer items --%>
                                            <div class="container">


                                                <div class="modal fade" id="popupOfferItems" role="dialog">
                                                    <div class="modal-dialog modal-lg" style="width: 95%;">

                                                        <!-- Modal content-->
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <button type="button" class="close" onclick="javascript:popupclose('popupOfferItems');">&times;</button>
                                                                <div class="col-md-6 col-sm-6 col-xs-10">
                                                                    <h4 class="modal-title">Search Offer Items</h4>
                                                                </div>
                                                                <div class="col-md-5 col-sm-4 col-xs-12">
                                                                     <div class="col-md-4 col-sm-12 col-xs-7"><label>Total Records: </label>  <label id="lblOfferTotalrecords">20</label></div>
                                                                    <div class="col-md-3 pull-right">
                                                                            <select id="txtperpage" onchange="javascript:searchofferitems(1);"  name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                                <option value="50">50</option>
                                                                                <option value="100">100</option>
                                                                                <option value="250">250</option>
                                                                                <option value="500">500</option>
                                                                            </select>
                                                                        </div>
                                                                   
                                                                        
                                                                        <div class="col-md-12 col-sm-12 col-xs-12 pull-right">
                                                                        <div class="" onclick="javascript:searchofferitems(1);">
                                                                            <button type="button" class="btn btn-success mybtnstyl">
                                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                                Search
                                                                            </button>
                                                                        </div>
                                                                        <div class="" onclick="javascript:resetoffer();">
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

                                                                    <table id="tbloffer" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Offer Code</th>
                                                                                <th>Offer Title</th>
                                                                                <th>Offer Type</th>
                                                                                <th>Offer Price</th>
                                                                                <th>Offer Discount</th>

                                                                            </tr>


                                                                            <tr>
                                                                                <td>
                                                                                    <input type="text" class="form-control" id="searchvalcontent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                                <td>
                                                                                    <input type="text" id="searchvalcontent2" class="form-control" /></td>
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
                                         <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left:0px; padding-right:0px;">
                                        <table id="tblPosItems" class="table table-striped table-bordered" style="table-layout: auto;">



                                            <tbody>
                                                <tr>
                                                    <td>Sl.No</td>
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
                                                    <td>Paid</td>
                                                    <td>Balance</td>
                                                    <td></td>

                                                </tr>




                                                <tr id="TrSum">
                                                   <td style="border-right:none;"></td>
                                                    <td style="border-right:none;"></td>
                                                     <td style="border-right:none;"></td>
                                                     <td style="border-right:none;"></td>
                                                     <td style="border-right:none;"></td>
                                                    <td style="text-align: right;"><b>Total</b></td>
                                                   <td></td>
                                                    <td id="txtposTotalCost"></td>
                                                    <td id="txtTotalDiscountRate"></td>
                                                    <td id="txtTotalDiscountAmount"></td>
                                                    <td id="txtTotalNetAmount"></td>
                                                     <td id="txtTotalTaxAmount"></td>
                                                     <td id="txtTotalBillAmount"></td>
                                                    <td></td>
                                                    <td></td>
                                                 
                                                    <td></td>
                                                    
                                                </tr>
                                                <tr>
                                                    <td colspan="6"></td>
                                                    <td></td>
                                                    <td></td>
                                                    <%--<td><b>Round</b></td>--%>
                                                    <td></td>
                                                    <td></td>
                                       
                                                    <td>
                                                      
                                                    </td>
                                                    <td></td>
                                                       <td>  <label id="txtTotalGrossamount"></label></td>
                                                    <td>
                                                        <input type="text" class="textwidth" id="txtPosPaidAmount" onkeyup='calculteTable();' style="width: 98%; background: none; border: none;" disabled /></td>
                                                    <td>
                                                        <input type="text" class="textwidth" id="txtPosBalanceAmount" style="width: 98%; background: none; border: none;" disabled /></td>
                                                    <td></td>

                                                </tr>

                                            </tbody>
                                        </table>
                                        </div>
                                    


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
                                    <div class="x_content">

                                        
                                    </div>
                                </div>
                            </div>
                        </div>
                   
                    <div class="clearfix"></div>
                    <%-- Cas,Card,Cheque start--%>
                    <div class="row" style="display:;">
                        <div class="col-md-12 col-sm-12 col-xs-12" >
                            <div class="x_panel" style="background: #eeeeee;">
                                <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px; padding-right:0px;">
                                    <div class="col-md-4 col-sm-6 col-xs-12" style="padding-left:0px; padding-right:0px;">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right:0px;">
                                                 <div class="checkbox">
            <label style="font-size: 1.3em">
                <input type="checkbox" value="" id="cbCashPayment" onclick="javascript: paymentMethod();">
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
<%--                                            <input type="checkbox"   class="flat" />--%>
                                        </div>
                                        
                                        <div class="col-md-4 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px;"><b>CASH</b> </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-3 col-sm-6 col-xs-12">Cash Amt</div>
                                        <div class="col-md-9 col-sm-6 col-xs-12">
                                            <input type="text" id="txtCashAmount" class="form-control" style="height: 25px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" value="0" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-2 col-sm-1 col-xs-2" style=" padding-right:0px;">
                                            <div class="checkbox">
            <label style="font-size: 1.3em">
                <input type="checkbox" value="" id="walletPayment">
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
                                           
                                        </div>
                                        <div class="col-md-8 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px;"><b>WALLET</b> (Wallet contains<label id="lblwalletamt" style="color: #432727; font-weight: bold; font-size: 12px; color: #40c863;"></label>) </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-3 col-sm-6 col-xs-12">Wallet Amt</div>
                                        <div class="col-md-9 col-sm-6 col-xs-12">
                                            <input type="text" id="textwalletamt" class="form-control" style="height: 25px;" onkeyup="javascript:paymentMethod();" value="0" disabled />
                                        </div>
                                    </div>

                                    <div class="col-md-4 col-sm-6 col-xs-12" style="padding-left:0px; padding-right:0px;display:;">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right:0px;">
                                        <div class="checkbox">
                                         <label style="font-size: 1.3em">
                                                      <input type="checkbox" value="" id="cbCardPayment" onclick="javascript: paymentMethod();">
                                          <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
                                             </label>
                                           </div>
                                           
                                        </div>
                                        <div class="col-md-4 col-sm-4 col-xs-4"  style="line-height:3; padding-left:0px;"><b>CARD</b> </div>
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
                                        <div class="col-md-5 col-sm-6 col-xs-12" style="display:none">Card Type</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12" style="display:none">
                                            <input type="text" id="txtCardType" value="type" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Type" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-5 col-sm-6 col-xs-12" style="display:none">Bank</div>
                                        <div class="col-md-7 col-sm-6 col-xs-12" style="display:none">
                                            <input type="text" value="bank" id="txtCardBank" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bank" />
                                        </div>
                                        <div class="clearfix"></div>
                                    </div>

                                    <div class="col-md-4 col-sm-4 col-xs-12 pull-right" style="padding-left:0px; padding-right:0px">
                                        <div class="col-md-2 col-sm-1 col-xs-2" style="padding-right:0px;">
                                            <div class="checkbox">
                                         <label style="font-size: 1.3em">
                                                      <input type="checkbox" value="" id="cbChequePayment" onclick="javascript: paymentMethod();">
                                          <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
                                             </label>
                                           </div>
                                           
                                        </div>
                                        <div class="col-md-4 col-sm-4 col-xs-4"  style="line-height:3; padding-left:0px;"><b>CHEQUE</b> </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12">Cheque Amt.</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeAmount" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter amt." onkeyup="javascript:paymentMethod();" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12">Cheque No.</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeNo" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter No." />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12">Date</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12">
                                            <input type="text" id="txtChequeDate" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Date" />
                                        </div>
                                        <div class="clearfix"></div>
                                        <div class="col-md-4 col-sm-6 col-xs-12">Bank</div>
                                        <div class="col-md-8 col-sm-6 col-xs-12">
                                            <input type="text" id="txtBankName" class="form-control" style="height: 25px; margin-bottom: 5px;" placeholder="Enter Bank" />
                                        </div>
                                        <div class="clearfix"></div>
                                    </div>

                                    
                                </div>

                            </div>
                        </div>
                    </div>
                    <input type="hidden" id="customerType" />
                    <%-- Cas,Card,Cheque End--%>

                        
                        <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px;" >
                            <div class="x_panel" style="background: #eeeeee;">
                                <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left:0px; padding-right:0px;display:none">
                                    <div class="col-md-4 col-sm-6 col-xs-12" style="padding-left:0px; padding-right:0px;">
                                        <div class="col-md-1 col-sm-1 col-xs-2" style="padding-right:0px;">
                                                 <div class="checkbox">
            <label style="font-size: 1.3em">
                <input type="checkbox" value="" id="checkSaleHead" onclick="javascript: paymentMethod();" checked>
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
<%--                                            <input type="checkbox"   class="flat" />--%>
                                        </div>
                                        
                                        <div class="col-md-8 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px; margin-left:8px;"><b>SALES HEAD</b> </div>
                                      
                                      
                                        <div class="clearfix"></div> 
                                                                                                                                                                                                                                                                      
                                    </div>

                                    <div class="col-md-4 col-sm-6 col-xs-12" style="padding-left:0px; padding-right:0px">
                                <div class="col-md-1 col-sm-1 col-xs-2" style="padding-right:0px;">
                                                 <div class="checkbox">
            <label style="font-size: 1.3em">
                <input type="checkbox" value="" id="checkAccount" onclick="javascript: paymentMethod();" checked>
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
<%--                                            <input type="checkbox"   class="flat" />--%>
                                        </div>                                       
                                        <div class="col-md-8 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px; margin-left:8px;"><b>ACCOUNT HEAD</b> </div>                              
                                        <div class="clearfix"></div> 
                                                                                                                                                     
                                    </div>

                                    <div class="col-md-4 col-sm-6 col-xs-12" style="padding-left:0px; padding-right:0px">
                                           <div class="col-md-1 col-sm-1 col-xs-2" style="padding-right:0px;">
                                                 <div class="checkbox">
            <label style="font-size: 1.3em">
                <input type="checkbox" value="" id="checkDelivery" onclick="javascript: paymentMethod();" checked>
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
<%--                                            <input type="checkbox"   class="flat" />--%>
                                        </div>                                       
                                        <div class="col-md-8 col-sm-4 col-xs-4" style="line-height:3; padding-left:0px;margin-left:8px;"><b>DELIVERY HEAD</b> </div>
                                        <div class="clearfix"></div>
                                     
                                        
                                       
                                      
                                        <div class="clearfix"></div>
                                    </div>

                             
                                </div>
                                <div class="clearfix"></div>
                                <div class="col-md-12 col-sm-12 col-xs-12" style="margin-top:10px;">
                                   <b>General Narration</b> 
                                     <textarea id="txtSpecialNote"  class="form-control" style="resize:none;"></textarea>
                                    <div class="clearfix"></div>
                                    <div class="col-md-2 col-sm-3 col-xs-3 pull-right" style="padding-right:0px;">
                                        <div class="pull-right" style="margin-top: 10px;" id="div1" onclick="javascript:saveToSalesMaster(false);">
                                            <button class="btn btn-primary mybtnstyl" type="button">Save</button>
                                        </div>

                                        <div class="pull-right" style="margin-top: 10px;margin-left:0px;" id="div2" onclick="javascript:saveToSalesMaster(true);">
                                            <button class="btn btn-primary mybtnstyl" type="button">Save & Print</button>
                                        </div>
                                        </div>
                                        <div class="clearfix"></div>
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
