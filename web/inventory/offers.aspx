<%@ Page Language="C#" AutoEventWireup="true" CodeFile="offers.aspx.cs" Inherits="inventory_offers" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Offer Master  | Invoice Me</title>
    <script src="../js/common.js"></script>
    <script src="../js/jquery-2.0.3.js"></script>
    <script src="../js/pagination.js"></script>
    <script src="../js/jquery.cookie.js"></script>

    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- bootstrap-daterangepicker -->
    <link href="../css/bootstrap/daterangepicker.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">

        var BranchId = "";
        var regexNumber = new RegExp(/^\+?[0-9(),.]+$/);
        $(document).ready(function () {
            $("input[data-type='number']").on('keyup', function () {
                var value = $(this).val();
                //console.log(value);
                if (!value.match(regexNumber)) {
                    value = value.slice(0, -1);
                    //console.log(value);
                    $(this).val(value);
                }
                //console.log("a");
            });
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#txtStartDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'yy-mm-dd'
                //dateFormat: 'dd-mm-yy'
            });
            $('#txtEndDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'yy-mm-dd'
                // dateFormat: 'dd-mm-yy'
            });
            $('#txtSearchFromDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                //dateFormat :'yy-mm-dd'
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
                //dateFormat :'yy-mm-dd'
                dateFormat: 'dd-mm-yy'
            });
            BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            //if (!BranchId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            //if (!CountryId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            showWarehouses();
            //showProfileHeader(1);
            $("#offer_type").val('select');
            clearform();
            var stock = location.search.split('stock=')[1];
            if (stock != "" || stock != undefined) {
                $("#comboinvntrystock").val(stock);
            } if (stock === undefined) {
                $("#comboinvntrystock").val(0);
            }
            //Start:Footer
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");
            //Start:Footer
            var docHeight = $(window).height();
            var footerHeight = $('.footerDiv').height();
            var footerTop = $('.footerDiv').position().top + footerHeight;

            if (footerTop < docHeight) {
                $('.footerDiv').css('margin-top', -2 + (docHeight - footerTop) + 'px');
            }
            //Stop:Footer
        });


        function offerTypeChange() {
            clearform();
            var offer_type = $("#offer_type").val();
            if (offer_type == "1") {
                $("#FocQtyTr").show();
                $("#FoclimitQtyTr").show();
                $("#itemPriceTr").hide();
                $("#itemQtyTr").hide();
                $("#bandItems").hide();
                $("#offerPriceTr").hide();
                $("#offerDiscountTr").hide();
                // $("#totalPriceTr").hide();
            } else if (offer_type == "2") {
                $("#itemPriceTr").show();
                $("#itemQtyTr").show();
                $("#FocQtyTr").hide();
                $("#FoclimitQtyTr").hide();
                $("#bandItems").show();
                $("#offerPriceTr").show();
                $("#offerDiscountTr").show();
                //  $("#totalPriceTr").show();
            } else if (offer_type == "0" || offer_type == "select") {
                $("#FocQtyTr").hide();
                $("#FoclimitQtyTr").show();
                $("#itemPriceTr").hide();
                $("#itemQtyTr").hide();
                $("#bandItems").hide();
                $("#offerPriceTr").show();
                $("#offerDiscountTr").show();
                // $("#totalPriceTr").hide();
            }
        }
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
        function clearform() {
            $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:addOfferDetail(\"insert\",0);'>SAVE</div>");
            // $("#btnservMasterAction").html("<div class='buttons fl' onclick=javascript:addOfferDetail('insert',0); ><div class='logintext'>SAVE</div></div>");
            $("#txtItem").val('');
            $("#hdnitemId").val('');
            $("#txtTitle").val('');
            $("#txtStartDate").val('');
            $("#txtEndDate").val('');
            $("#txtCost").val('');
            $("#txtFocQty").val('0');
            $("#txtFoc").val('0');
            $("#txtdiscount").val('');
            $("#txtCode").val('');
            $("#txtDiscount").val('');
            $("#offer_status").val(0);
            $("#txtofrcommission").val('');
            //$("#offer_type").val('select');
            $("#txtlimitFoc").val('');
            $("#divbandedItems").html('');
            $("#FocQtyTr").hide();
            // $("#FoclimitQtyTr").hide();
            $("#totalPriceTr").val('');
            $("#itemPriceTr").hide();
            $("#itemQtyTr").hide();
            $("#bandItems").hide();
            $("#txtItemQty").val('');
            $("#txtItemPrice").val('');

            $("#txtTotalamt").val('');
            for (i = 1; i <= 7; i++) {
                $("searchvalContent" + i).val("");
            }
            $("#txtSearchFromDate").val("");
            $("#txtSearchToDate").val("");
        }
        function searchOrderitems() {
            // showsearchItems();
            for (var i = 1; i <= 3; i++) {
                $("#searchposContent" + i).val('');
            }
            $("#combosearchitemtype").val(0);
            searchOrderitem(1);
        }

        function searchOrderitem(page) {
            sqlInjection();
            var filters = {};

            var BranchId = $("#selwarehouse").val();
            var perpage = $("#txtpospageno").val();

            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itm_code = $("#searchposContent1").val();
            }

            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itm_name = $("#searchposContent2").val();
            }

            $.ajax({
                type: "POST",
                url: "offers.aspx/searchOrderitem",
                data: "{'BranchId':" + BranchId + ",'page':" + page + ",'perpage':'" + perpage + "','filters':" + JSON.stringify(filters) + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //alert(msg.d);
                    if (msg.d == "N") {
                        for (var i = 2; i < ($('#tableOffer tr').length) ; i++) {
                            $('#tableOffer > tbody > tr:gt(' + i + ')').remove();
                        }
                        $('#tableOffer > tbody').html('<td colspan="6"><div style="width:100%;text-align:center"><div>No Data Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        $("#lblTotalRecord").text(0);
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        // alert(obj);
                        var htm = "";
                        // htm += "<tr style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            htm += "<tr style='font-size:12px; cursor:pointer;'";
                            htm += " title='Click to View' onclick=javascript:selectOrderItem('" + row.itm_name.replace(/\s/g, '&nbsp;') + "','" + row.itbs_reorder + "','" + row.itbs_stock + "','" + row.itm_mrp + "','" + row.itm_class_one + "','" + row.itm_class_two + "','" + row.itm_class_three + "','" + row.itbs_id + "'); style='cursor:pointer;' alt='Working'><td style='padding:5px;text-align:left'>" + getHighlightedValue(filters.itm_code, row.itm_code.toString()) + "</td><td style='padding:5px;height:auto;text-align:left'>" + getHighlightedValue(filters.itm_name, row.itm_name.toString()) + "</td><td style='width:74px; padding:5px;text-align:left'>" + row.brand_name + "/" + row.cat_name + "</td>";
                            htm += "<td style='padding:5px;'>" + row.itbs_stock + "</td><td style='padding:5px;'>" + row.itm_class_two + "</td></tr>";
                            $("#hdnitemId").val(row.itbs_id);
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        //alert(htm);
                        $('#tableOffer  tbody').html(htm);
                        $("#lblTotalRecord").text(obj.count);
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitem"));
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    //alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });

        }
        //function for load branches in search

        function selectOrderItem(itm_name, item_stock, item_reorder, item_price, item_one, item_two, item_three, itm_id) {
            var offertype = $("#offer_type").val();
            if (offertype != 2) {
                $("#txtTotalamt").val(item_two);
            }
            $("#txtItem").val(itm_name);

            $("#txtItemPrice").val(item_two);
            $("#hdnItbsId").val(itm_id);
            $("#hdnItbsName").val(itm_name);
            $('#itemModal').modal('hide');

        }
        function addOfferDetail(actionType, offer_id) {
            sqlInjection();
            var warehouseId = $("#selwarehouse").val();
            if (warehouseId == 0) {
                alert("select warehouse");
                return;
            }
            var item_id = $("#hdnItbsId").val();
            var offer_type = $("#offer_type").val();
            if (offer_type == "" || offer_type == "select") {
                alert("Select offer Type");
                return;
            }
            var itbs_id = '';
            var band_price = '';
            var band_qty = '';
            var warehouse_id = '';
            $('.usrename').each(function () {
                itbs_id += $(this).attr("data-id") + "#";
                //alert(itbs_id);
            });
            console.log(itbs_id);

            $('.usrename').each(function () {
                band_price += $(this).attr("data-price") + "#";
            });
            $('.usrename').each(function () {
                band_qty += $(this).attr("data-qty") + "#";
            });
            //$('.warehousename').each(function () {
            //    warehouse_id += $(this).attr("data-id") + "#";
            //});
            //var warehouses = warehouse_id.slice(0, -1);
            //var warehouseIds = warehouses.replace(/#/g, ",");
            var offerTitle = $("#txtTitle").val();
            if (offerTitle == "") {
                alert("Enter Title");
                return;
            }
            if (offer_type == "0" || offer_type == "1") {
                if ($("#txtItem").val() == "") {
                    alert("Select Item Name");
                    return;
                }
                //var item_name = $("#hdnItbsName").val();
                // $("#txtItem").val(item_name);
            }
            var offerCode = $("#txtCode").val();
            if (offerCode == "") {
                alert("Enter Offer Code");
                return;
            }
            var start_date = $("#txtStartDate").val();
            if (start_date == "") {
                alert("Enter start date");
                return;
            }
            var end_date = $("#txtEndDate").val();
            if (end_date == "") {
                alert("Enter end date");
                return;
            }
            var item_Qty = $("#txtItemQty").val();
            var item_price = $("#txtItemPrice").val();
            var totalprice = $("#txtTotalamt").val();
            if (totalprice == 0 || totalprice == "") {
                alert("Please choose an item");
                return;
            }

            if (offer_type != 1) {
                var offer_price = $("#txtCost").val();
                if (offer_price == "" || isNaN(offer_price)) {
                    alert("Enter offer price");
                    return;
                }
                var discount = $("#txtDiscount").val();
                if (discount == "" || isNaN(discount)) {
                    alert("Enter offer discount");
                    return;
                }
            } else {
                var offer_price = totalprice;
                var discount = 0;
            }

            var band_prices = band_price.slice(0, -1);
            var band_rplc = band_prices.replace(/#/g, ",");
            var bandPrice_array = band_rplc.split(',');

            var band_qtys = band_qty.slice(0, -1);
            var band_qtyrplc = band_qtys.replace(/#/g, ",");
            var bandQty_array = band_qtyrplc.split(',');

            band_cost = 0;
            for (var i = 0; i < bandPrice_array.length; i++) {

                band_cost = band_cost + parseInt(bandPrice_array[i] * bandQty_array[i]);
            }
            if (offer_type == "2") {
                var checkarray = [];
                var checkarray = itbs_id.split("#");
                // alert(checkarray[0]);
                checkarray.splice(-1, 1);
                var leng = checkarray.length;
                console.log(checkarray);
                //alert(leng);
                if (leng == "1") {
                    alert("Please select atleast two items!!!");
                    return;
                }
            }

            var foc_Qty = "";
            var limit_foc = "";
            if (offer_type == "1") {
                foc_Qty = $("#txtFocQty").val();
                if (foc_Qty == "0" || isNaN(foc_Qty)) {
                    alert("Enter FOC");
                    return;
                }
            }
            if (offer_type != "2") {

                limit_foc = $("#txtlimitFoc").val();

                if (limit_foc == "" || isNaN(limit_foc)) {
                    alert("Enter Limit");
                    return;
                }
            }
            else {
                $("#txtlimitFoc").val('0');
                limit_foc = 0;
            }
            //alert(limit_foc);
            var status = $("#offer_status").val();
            if (status == "" || status == "select") {
                alert("Enter status");
                return;
            }
            var ofr_commission = $("#txtofrcommission").val();
            if (ofr_commission == "") {
                alert("Enter commission");
                return;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "offers.aspx/addOfferItem",
                data: "{'offer_type':" + offer_type + ",'offerTitle':'" + offerTitle + "','start_date':'" + start_date + "','end_date':'" + end_date + "','offer_price':'" + offer_price + "','discount':'" + discount + "','foc_Qty':'" + foc_Qty + "','limit_foc':'" + limit_foc + "','item_Qty':'" + item_Qty + "','item_price':'" + item_price + "','actionType':'" + actionType + "','offerCode':'" + offerCode + "','status':'" + status + "','item_id':'" + item_id + "','itbs_id':'" + itbs_id + "','band_price':'" + band_price + "','band_qty':'" + band_qty + "','offer_id':'" + offer_id + "','totalprice':'" + totalprice + "','warehouseId':'" + warehouseId + "','ofr_commission':'" + ofr_commission + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //  alert(msg.d);
                    console.log(msg.d);

                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Offer added successfully");
                        } else {
                            alert("Offer updated successfully");
                        }

                        $("#hdnitemId").val('');
                        $("#txtTitle").val('');
                        $("#txtStartDate").val('');
                        $("#txtEndDate").val('');
                        $("#txtCost").val('');
                        $("#txtFocQty").val('');
                        $("#txtFoc").val('');
                        $("#txtdiscount").val('');
                        $("#txtItem").val('');
                        $("#txtCode").val('');
                        $("#txtDiscount").val('');
                        $("#offer_status").val(0);
                        $("#divbandedItems").html('');
                        $("#offer_type").val('select');
                        $("#txtlimitFoc").val('');
                        //alert("");
                        window.location.reload(true);
                        //showOffers(1);
                    } else {
                        alert("There is problem");
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function showOffers(page) {
            sqlInjection();
            var filters = {};
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }

            // today = yyyy + '/' + mm + '/' + dd;
            today = dd + '-' + mm + '-' + yyyy;

            //needded format 2014/02/12
            //now 24-01-2014
            var fromdate1 = $("#txtSearchFromDate").val();
            var todate1 = $("#txtSearchToDate").val();
            if (fromdate1 != "") {
                var splitarray = fromdate1.split("-");
                var fromdate = splitarray[2] + "/" + splitarray[1] + "/" + splitarray[0];
            }
            else {
                var fromdate = fromdate1;
            }
            if (todate1 != "") {
                var splitarray1 = todate1.split("-");
                var todate = splitarray1[2] + "/" + splitarray1[1] + "/" + splitarray1[0];
            }
            else {
                var todate = todate1;
            }

            if ($("#searchvalContent1").val() !== undefined && $("#searchvalContent1").val() != "") {
                filters.ofr_code = $("#searchvalContent1").val();
            }

            if ($("#searchvalContent2").val() !== undefined && $("#searchvalContent2").val() != "") {
                filters.ofr_title = $("#searchvalContent2").val();
            }
            if ($("#warehousesel").val() !== undefined && $("#warehousesel").val() != 0) {
                filters.warehouseId = $("#warehousesel").val();
            }

            var offerstatus = $("#selofferstatus").val();

            var perPage = $("#selPerPage").val();
            loading();
            $.ajax({
                type: "POST",
                url: "offers.aspx/showOffers",
                data: "{'page':" + page + ",'perPage':'" + perPage + "','filters':" + JSON.stringify(filters) + ",'startdate':'" + fromdate + "','enddate':'" + todate + "','offerstatus':'" + offerstatus + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    if (msg.d == "N") {
                        Unloading();
                        $("#tblOfferdetail tbody").html('<td colspan="8" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#lblTotalrerd").text(0);
                        //<div style="background:#ebebeb;width:100%;text-align:center"><div style="background:#ebebeb;display:inline-block">Nothing Found...</div></div>');
                    }
                    else {
                        var obj = JSON.parse(msg.d)
                        console.log(obj);
                        Unloading();
                        var htm = "";
                        //htm += '<tr style="font-size:12px;">';
                        //htm += '<td colspan="8" style="padding:5px; text-align:center; overflow:hidden; border-right:none;">';
                        //htm += '<div><span style="margin-left:0px;float:right;text-align:right;font-size:14px;">Total Records:' + obj.count + '</span></div>';
                        //htm += '</td> </tr>';
                        $.each(obj.data, function (i, row) {
                            htm += "<tr  style='cursor:pointer; font-size:12px;' onclick=javascript:editOfferDetails(" + row.itbs_id + "," + row.ofr_id + "); id='itemRow" + i + "'>";
                            //,'" + row.ofr_type + "','" + row.ofr_title + "','" + row.ofr_code + "','" + row.startDate + "','" + row.endDate + "','" + row.ofr_price + "','" + row.ofr_totalqty + "','" + row.ofr_foc + "','" + row.ofr_discount + "','" + row.ofr_status + "','" + row.itm_price + "','" + row.itm_qty + "','" + row.itm_name.replace(/\s/g, '&nbsp;') + "'
                            htm += "<td>" + getHighlightedValue(filters.ofr_code, row.ofr_code.toString()) + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.ofr_title, row.ofr_title.toString()) + "</td>";
                            htm += "<td>" + row.startDate + "</td>";
                            htm += "<td>" + row.endDate + "</td>";
                            htm += "<td>" + row.ofr_price + "</td>";
                            htm += "<td>" + row.ofr_discount + "</td>";
                            htm += "<td>" + row.ofr_focqty + "/" + row.ofr_focnum + "</td>";
                            htm += "<td><button class='btn btn-primary btn-xs' onclick='javascript:editOfferDetails(" + row.itbs_id + "," + row.ofr_id + ");' type='reset'><li class='fa fa-folder-open'></li>View</button></td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="8">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#tblOfferdetail tbody").html(htm);
                        $("#lblTotalrerd").text(obj.count);
                        $("#paginatediv").html(paginate(obj.count, perPage, page, "showOffers"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function editOfferDetails(item_id, offer_id) {
            $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:addOfferDetail(\"Update\"," + offer_id + ");'>UPDATE</div>");
            loading();
            $.ajax({
                type: "POST",
                url: "offers.aspx/editOffers",
                data: "{'item_id':" + item_id + ",'offer_id':'" + offer_id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d)
                    console.log(obj);
                    $("#hdnItbsId").val(item_id);
                    var htm = "";
                    $.each(obj.data, function (i, row) {
                        console.log(row.itm_name);
                        if (row.ofr_type == "1") {
                            $("#FocQtyTr").show();
                            //$("#FoclimitQtyTr").show();
                            $("#itemPriceTr").hide();
                            $("#itemQtyTr").hide();
                            $("#bandItems").hide();
                            $("#txtItem").val(row.itm_name);
                            $("#offerPriceTr").hide();
                            $("#offerDiscountTr").hide();
                        } else if (row.ofr_type == "2") {
                            $("#itemPriceTr").show();
                            $("#itemQtyTr").show();
                            $("#FocQtyTr").hide();
                            //$("#FoclimitQtyTr").hide();
                            $("#bandItems").show();
                            $("#divbandedItems").html('');
                            $("#txtItem").val('');
                            $("#offerPriceTr").show();
                            $("#offerDiscountTr").show();
                        } else if (row.ofr_type == "0") {
                            $("#FocQtyTr").hide();
                            // $("#FoclimitQtyTr").hide();
                            $("#itemPriceTr").hide();
                            $("#itemQtyTr").hide();
                            $("#bandItems").hide();
                            $("#txtItem").val(row.itm_name);
                            $("#offerPriceTr").show();
                            $("#offerDiscountTr").show();
                        }
                        // alert(row.itbs_id);
                        htm += "<div id='' class='bandNameOuter'><div id='' class='usrename' data-id='" + row.itbs_id + "' data-price='" + row.itm_price + "' data-qty='" + row.itm_qty + "'  style='font-weight:bold; float:left;'> " + row.itm_name + "/(" + row.itm_qty + "*" + row.itm_price + ")/" + (row.itm_qty * row.itm_price) + "<input type='hidden' value='' class='hdnusrid'/></div> <div  onclick='removeOfferItem(this)' style='float:left;'><img src='../images/btnclose.png' width='18' height='18' style='cursor:pointer; ' /></div></div>";
                        $("#selwarehouse").val(row.branch_id);
                        $("#offer_type").val(row.ofr_type);
                        $("#txtTitle").val(row.ofr_title);
                        $("#txtCode").val(row.ofr_code);
                        //alert(row.startDate);
                        var date = new Date(row.startDate);
                        //alert(date);
                        var edate = new Date(row.endDate);
                        var start_date = date.getFullYear() + '-' + ("0" + (date.getMonth() + 1)).slice(-2) + '-' + ("0" + (date.getDate())).slice(-2);
                        var end_date = edate.getFullYear() + '-' + ("0" + (edate.getMonth() + 1)).slice(-2) + '-' + ("0" + (edate.getDate())).slice(-2);
                        //alert(start_date);
                        //getDate
                        //alert((date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear())
                        $("#txtStartDate").val(start_date);
                        $("#txtEndDate").val(end_date);
                        // $("#txtStartDate").val(row.startDate);
                        //$("#txtEndDate").val(row.endDate);
                        $("#txtCost").val(row.ofr_price);
                        $("#txtDiscount").val(row.ofr_discount);
                        $("#offer_status").val(row.ofr_status);
                        $("#txtFocQty").val(row.ofr_focnum);
                        $("#txtlimitFoc").val(row.ofr_focqty);
                        $("#txtTotalamt").val(row.ofr_totalprice);
                        $("#txtofrcommission").val(row.ofr_commission);
                    });
                    $("#divbandedItems").html(htm);
                    $('html,body').animate({
                        scrollTop: $('#Divofferdetails').offset().top
                    }, 500);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function addBandItem() {
            var item_name = $("#txtItem").val();
            if (item_name == "") {
                alert("Choose an item");
                return;
            }
            var item_Qty = $("#txtItemQty").val();
            if (item_Qty == "") {
                alert("Enter item Qty");
                return;
            }
            var item_price = $("#txtItemPrice").val();
            //if (item_price == "") {
            //    alert("Enter item Price");
            //    return;
            //}

            var item_id = $("#hdnItbsId").val();
            var branch = "";
            var assignto = "";
            $('.usrename').each(function () {
                assignto += $(this).attr("data-id") + "#"
            });
            var team = assignto.split('#');
            // alert(team);
            var leng = team.length;
            // alert(leng);
            //for (var i = 0; i < leng - 1; i++) {
            //    if (item_id == team[i]) {
            //        alert("Already selected");
            //        return;
            //    }
            //}

            if (item_id == assignto) {
                return;
            } else {
                $("#divbandedItems").append("<div id='" + item_id + "' class='bandNameOuter'  value='" + item_id + "' style='float:left;'><div  style='font-weight:bold; float:left;' id='' class='usrename' data-id='" + item_id + "' data-price='" + item_price + "' data-qty='" + item_Qty + "' >" + item_name + "/(" + item_Qty + "*" + item_price + ")/" + (item_Qty * item_price) + "</div> <div onclick='removeOfferItem(this)' style='float:left;' ><img src='../images/btnclose.png' width='18' height='18' style='cursor:pointer; ' /></div></div>");
                $("#txtItem").val('');
                $("#txtItemQty").val('');
                $("#txtItemPrice").val('');
            }
            resetTotalAmount();
        }
        function removeOfferItem(cntrl) {
            var conf;
            conf = confirm("Do you want to delete ?");
            if (conf == true) {
                $(cntrl).closest(".bandNameOuter").remove();
                resetTotalAmount();
            }
            else {
                return;
            }
        }
        function clearSearch() {
            for (var i = 1; i <= 7; i++) {

                $("#searchvalContent" + i).val('');
            }
            $("#txtSearchFromDate").val("");
            $("#txtSearchToDate").val("");
            $("#selofferstatus").val(0);
            $("#warehousesel").val(0);
            showOffers(1);
        }
        function clearItem() {
            for (var i = 1; i <= 3; i++) {

                $("#searchposContent" + i).val('');
            }
            searchOrderitem(1);
        }

        function resetTotalAmount() {
            var band_price = '';
            var band_qty = '';
            $('.usrename').each(function () {
                band_price += $(this).attr("data-price") + "#";
            });
            $('.usrename').each(function () {
                band_qty += $(this).attr("data-qty") + "#";
            });
            var band_prices = band_price.slice(0, -1);
            var band_rplc = band_prices.replace(/#/g, ",");
            var bandPrice_array = band_rplc.split(',');

            var band_qtys = band_qty.slice(0, -1);
            var band_qtyrplc = band_qtys.replace(/#/g, ",");
            var bandQty_array = band_qtyrplc.split(',');

            band_cost = 0;
            for (var i = 0; i < bandPrice_array.length; i++) {

                band_cost = band_cost + parseFloat(bandPrice_array[i] * bandQty_array[i]);
            }
            $("#txtTotalamt").val(band_cost);
            $("#txtCost").val(band_cost);
            $("#txtDiscount").val(0);
        }

        function calculatediscount() {
            // alert("haii");
            var totalprice = parseFloat($("#txtTotalamt").val());
            var offerprice = parseFloat($("#txtCost").val());
            console.log(offerprice);
            if (isNaN(offerprice)) {
                offerprice = 0;
            }
            else if (offerprice > totalprice) {
                alert("Offer price must be less than actual price");
                $("#txtCost").val(totalprice);
                offerprice = totalprice;
            }
            else if (offerprice < 0) {
                $("#txtCost").val(0);
                offerprice = 0;
            }
            var discount = parseFloat((1 - (offerprice / totalprice)) * 100);
            $("#txtDiscount").val(discount);

        }

        function calculateofferprice() {
            var totalprice = parseFloat($("#txtTotalamt").val());
            var offerdiscount = parseFloat($("#txtDiscount").val());
            console.log(offerdiscount);
            if (offerdiscount > 100) {
                alert("Maximum discount rate is 100%");
                $("#txtDiscount").val('0');
                offerdiscount = 0;
            }
            else if (offerdiscount < 0) {
                $("#txtDiscount").val('0');
                offerdiscount = 0;
            }
            else if (isNaN(offerdiscount)) {
                offerdiscount = 0;
            }
            var offerprice = totalprice * (1 - (offerdiscount / 100));
            $("#txtCost").val(offerprice);
        }

        function showWarehouses() {
            var warehouseId = $.cookie("invntrystaffBranchId");
            // alert(warehouseId);
            loading();
            //return;
            $.ajax({
                type: "POST",
                url: "offers.aspx/showWarehouses",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //  console.log(msg);
                    warehouses = JSON.parse(msg.d);
                    var htm = "<option value='0'>Select</option>";
                    $.each(warehouses, function (index, warehouse) {
                        htm += "<option value='" + warehouse.id + "'>" + warehouse.name + "</option>";
                        //console.log(user);
                    });
                    $("#selwarehouse").html(htm);
                    $("#selwarehouse").val(warehouseId);
                    $("#warehousesel").html(htm);
                    $("#warehousesel").val(warehouseId);
                    showOffers(1);
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
                        <a href="#" class="site_title"><%--<i class="fa fa-paw"></i>--%> <span>Invoice Me</span></a>
                    </div>

                    <div class="clearfix"></div>

                    <!-- menu profile quick info -->
                    <div class="profile clearfix">
                        <div class="profile_pic">
                        </div>
                        <div class="profile_info">
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
                        <a data-toggle="tooltip" data-placement="top" title="Logout" href="">
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
                             <div class="col-md-6 col-xs-5">
                            <label style="font-weight: bold; font-size: 16px;">Offer Master</label></div>
                            <div class="col-md-6 col-xs-5"><div onclick="javascript:window.location.reload(true);" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New</div></div>
                             
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%-- <div class="page-title">

                        <div class="title_left" style="width: 100%;">
                            <label style="font-size: 16px; font-weight: bold;">Offer Master</label>
                        </div>


                    </div>--%>

                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="Divofferdetails">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Offer Details</label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>

                                </div>
                                <div class="x_content">
                                    <form id="demo-form2" data-parsley-validate class="form-horizontal form-label-left">

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Warehouse<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <select class="form-control" id="selwarehouse" onchange="showOffers(1)">
                                                    <option value="0">Select </option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Offer Type<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <select class="form-control" id="offer_type" onchange="javascript:offerTypeChange();">
                                                    <option value="select">Select</option>
                                                    <option value="0">Discount/Price</option>
                                                    <option value="1">FOC</option>
                                                    <option value="2">Banded</option>
                                                </select>
                                            </div>
                                        </div>


                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Offer Title <span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtTitle" placeholder="Enter Offer Title" required="required" class="form-control col-md-7 col-xs-12" />
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Item Name<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-9">
                                                <input type="text" placeholder="Select Item Name" id="txtItem" name="last-name" required="required" class="form-control col-md-7 col-sm-6 col-xs-12" disabled />
                                            </div>
                                            <div onclick="javascript:searchOrderitem(1);" class="col-md-3 col-sm-2 col-xs-3" style="font-size: 22px; padding-left: 0px;" data-toggle="modal" data-target="#itemModal">
                                                <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer; margin-top: -5px;"></label>
                                                <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                            </div>
                                        </div>

                                        <div id="itemQtyTr" style="display: none" class="form-group">
                                            <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Item Qty<span class="required">*</span></label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input id="txtItemQty" placeholder="Enter Item Quantity" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" />
                                            </div>
                                        </div>

                                        <div id="itemPriceTr" style="display: none" class="form-group">
                                            <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Item Price<span class="required">*</span></label>
                                            <div class="col-md-6 col-sm-6 col-xs-10">
                                                <input id="txtItemPrice" placeholder="Enter Item Price" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" />
                                            </div>
                                            <div onclick="javascript:addBandItem();" class="col-md-3 col-sm-2 col-xs-2">
                                                <label class="fa fa-plus-circle" style="font-size: 26px; margin-top: 2px; cursor: pointer; position: relative; margin-left: -12px;" data-toggle="tooltip" title="Click here to add Item"></label>
                                                <button type="button" class="btn btn-warning" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;">
                                                    Add
                                                </button>
                                            </div>
                                        </div>

                                        <div id="bandItems" style="display: none;" class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <td colspan="2">
                                                    <%--                                 <div class="fr" id="div1" style="width: 350px; height: 120px; overflow: scroll; overflow-style: scrollbar; margin-left: 10px; border: 1px solid #aeabab;"></div>--%>
                                                    <div class="form-control" rows="3" placeholder="Select Banded Items" id="divbandedItems" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; overflow: scroll; overflow-style: scrollbar;"></div>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Offer Code<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtCode" placeholder="Enter Offer Code" name="last-name" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Offer Status<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <select class="form-control" id="offer_status">
                                                    <option value="0">Active</option>
                                                    <option value="1">Deactive</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Date Range<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtStartDate" name="last-name" required="required" placeholder="Start Date" class="form-control col-md-7 col-xs-12">
                                            </div>

                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtEndDate" name="last-name" placeholder="End Date" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>

                                        </div>

                                        <div id="totalPriceTr" style="display: " class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Total Price<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" id="txtTotalamt" style="padding: 0px; text-indent: 3px;" name="last-name" required="required" placeholder="Total Price" class="form-control col-md-7 col-xs-12" disabled>
                                            </div>

                                        </div>

                                        <div id="offerPriceTr" class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Offer Price <span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" id="txtCost" style="padding: 0px; text-indent: 3px;" name="last-name" required="required" placeholder="Enter Price" class="form-control col-md-7 col-xs-12" onkeyup="calculatediscount();">
                                            </div>
                                        </div>

                                        <div id="offerDiscountTr" class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Offer Discount (%)<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" id="txtDiscount" style="padding: 0px; text-indent: 3px;" name="last-name" required="required" placeholder="Enter Discount (%)" class="form-control col-md-7 col-xs-12" onkeyup="calculateofferprice();">
                                            </div>

                                        </div>

                                        <div id="FoclimitQtyTr" style="display: " class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Minimum Qty:<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" data-type="number" style="padding: 0px; text-indent: 3px;" id="txtlimitFoc" name="last-name" required="required" placeholder="Enter limit" class="form-control col-md-7 col-xs-12">
                                            </div>

                                        </div>
                                        <div id="FocQtyTr" style="display: none" class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                FOC Qty:<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" data-type="number" id="txtFocQty" name="last-name" required="required" style="padding: 0px; text-indent: 3px;" placeholder="Enter Qty" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Offer Commission (%)<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="number" data-type="number" id="txtofrcommission" style="padding: 0px; text-indent: 3px;" name="last-name" required="required" placeholder="Enter Commission (%)" class="form-control col-md-7 col-xs-12">
                                            </div>

                                        </div>
                                    </form>


                                    <div class="clearfix"></div>
                                    <div class="ln_solid"></div>
                                    <div class="form-group" style="padding-bottom: 40px;">
                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-5 col-sm-offset-4">
                                           
                                            <div id="btnservMasterAction">
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addOfferDetail('insert',0);">SAVE</div>
                                            </div>
                                            <div type="button" onclick="javascript:window.location.reload(true)" class="btn btn-danger mybtnstyl">CANCEL</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="clearfix"></div>
                            </div>
                        </div>
                    </div>


                    <div class="modal fade" id="itemModal" role="dialog">
                        <div class="modal-dialog modal-lg" style="width:;">

                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-3 col-sm-6 col-xs-12">
                                        <h4 class="modal-title">Items<label class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalRecord">0</label></h4>
                                    </div>
                                     <div class="col-md-3 col-sm-4 col-xs-8">
                                          
                                            </div>
                                    <div class="col-md-5 col-sm-12 col-xs-12 pull-right">
                                           
                                           <div class="col-md-2 col-sm-4 col-xs-3 pull-right">
                                                <select id="txtpospageno" class="input-sm" onchange="javascript:searchOrderitem(1); ">
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                    <option value="250">250</option>
                                                    <option value="500">500</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6 col-sm-4 col-xs-4" style="float: right;">
                                                  <div class="btn btn-success mybtnstyl" onclick="javascript:searchOrderitem(1);">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </div>
                                                <div class="btn btn-primary mybtnstyl" onclick="javascript:clearItem();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </div>
                                           
                                              
                                            </div>
                                         

                                        </div>
                                </div>
                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; margin-top: 5px;">
                                    <div class="x_content">
                                        
                                        <table id="tableOffer" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <th>Item Code</th>
                                                    <th>Item Name</th>
                                                    <th>Brand/Category</th>
                                                    <th>Stock</th>
                                                    <th>Price</th>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="text" id="searchposContent1" placeholder="Item Code" class="form-control" /></td>
                                                    <td>
                                                        <input type="text" id="searchposContent2" placeholder="Item Name" class="form-control" /></td>
                                                    <%--<td><input type="text" id="searchposContent6" class="form-control" /></td>--%>
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
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title">
                                    <label>Offer Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <form class="form-horizontal form-label-left input_mask">
                                        <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                            <select class="form-control" onchange="javascript:showOffers(1)" style="text-indent: 25px;" id="warehousesel">
                                                <option value="0">Select </option>

                                            </select>
                                            <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                        </div>
                                        <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                            <select onchange="javascript:showOffers(1);" class="form-control" style="text-indent: 25px; padding-right:5px;" id="selofferstatus">
                                                <option value="0">Active</option>
                                                <option value="1">Deactive</option>

                                            </select>
                                            <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                        </div>
                                        <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                            <input type="text" id="txtSearchFromDate" name="last-name" required="required" placeholder="Start Date" class="form-control col-md-7 col-xs-12" />
                                        </div>
                                        <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                            <input type="text" id="txtSearchToDate" name="last-name" required="required" placeholder="End Date" class="form-control col-md-7 col-xs-12" />
                                        </div>
                                  


                                        <div class="col-md-2 col-sm-12 col-xs-9 ">
                                            <div style="float: right;">
                                                <button type="button" class="btn btn-success mybtnstyl" onclick="javascript:showOffers(1);">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search</button>
                                                <button class="btn btn-primary mybtnstyl" type="button" onclick="javascript:clearSearch();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset</button>
                                            </div>
                                            <%--<div style="float: right; margin-right: 10px; line-height: 30px;">
                                                <span><strong>Total Records:
                                                    <label id="lblTotalrerd"></label>
                                                </strong></span>
                                            </div>--%>

                                        </div>
                                              <div class="col-md-1 col-sm-3 col-xs-3">
                                            <div class="dataTables_length" id="datatable-checkbox_length">
                                                <label style="margin-top: 5px; margin-left: 5px;">
                                                    <select id="selPerPage" onchange="javascript:showOffers(1);" style="height: 25px;">
                                                        <option value="20">20</option>
                                                        <option value="50">50</option>
                                                        <option value="100">100</option>
                                                        <option value="500">500</option>
                                                    </select>
                                                </label>
                                            </div>
                                        </div>
                                        <%--      <div class="form-group" style="float: right;">
                                            <div class="col-md-12 col-sm-12 col-xs-12 ">
                                                <div type="button" onclick="javascript:showOffers(1);" class="btn btn-success mybtnstyl">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </div>
                                                <div class="btn btn-primary mybtnstyl" onclick="javascript:clearSearch();" type="reset">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </div>
                                            </div>
                                        </div>--%>
                                    </form>
                                </div>
                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">
                                        <table id="tblOfferdetail" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <th style="width: 175px">Offer Code</th>
                                                    <th style="width: 200px;">Offer Title</th>
                                                    <th>Start Date	</th>
                                                    <th>End Date</th>
                                                    <th>Amount</th>
                                                    <th>Discount </th>
                                                    <th>FOC limit/foc</th>
                                                    <th>View</th>

                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="text" id="searchvalContent1" class="form-control" placeholder="Offer Title" style="width: 200px" /></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent2" placeholder="Offer Code" class="form-control" style="width: 175px" /></td>
                                                    <td>
                                                        <input type="text" id="" class="form-control" style="display: none;" /></td>
                                                    <td>
                                                        <input type="text" id="Text1" class="form-control" style="display: none;" /></td>
                                                    <td></td>
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
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>


                </div>
            </div>
            <input type="hidden" id="customerType" />
            <input type="hidden" id="hdnitemId" />
            <div id="hdnItbsId" style="display: none"></div>
            <div id="hdnItbsName" style="display: none"></div>
            <!-- /page content -->

            <!-- footer content -->
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

    <!-- jQuery -->
    <%--    <script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- bootstrap-daterangepicker -->
    <script src="../js/bootstrap/moment.min.js"></script>
    <script src="../js/bootstrap/daterangepicker.js"></script>
    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
