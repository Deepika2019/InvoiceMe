<%@ Page Language="C#" AutoEventWireup="true" CodeFile="warehousemanagement.aspx.cs" Inherits="inventory_warehousemanagement" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Items Management  | Invoice Me</title>
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


    <style type="text/css">
        .activebtn {
            background: url(../images/icon_active.gif);
            width: 20px;
            height: 20px;
        }

        .inactive {
            background: url(../images/icon_inactive.png);
            width: 20px;
            height: 20px;
        }
    </style>
    <script type="text/javascript">
        var BranchId = "";
        var sessionId = 0;
        var currentStock = 0;
        $(document).ready(function () {
            sessionId = getSessionID();
            BranchId = $.cookie("invntrystaffBranchId");
            //alert(BranchId);
            var CountryId = $.cookie("invntrystaffCountryId");
 
            clearform();
            showBranches();
            //showItems();

            var stock = location.search.split('stock=')[1];
            if (stock != "" || stock != undefined) {
                $("#comboinvntrystock").val(stock);
            } if (stock === undefined) {
                $("#comboinvntrystock").val(0);
            }
            //showsearchItems();
            showsearchBranches();
            //Start:Footer
            var docHeight = $(window).height();
            var footerHeight = $('.footerDiv').height();
            var footerTop = $('.footerDiv').position().top + footerHeight;

            if (footerTop < docHeight) {
                $('.footerDiv').css('margin-top', -33 + (docHeight - footerTop) + 'px');
            }
            //Stop:Footer

            bindItemSearchAutoComplete();

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

        function bindItemSearchAutoComplete() {

            //Start autocoumplete
            $("#txtItemAutoPopulate").autocomplete({

                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "warehousemanagement.aspx/showItems",
                        data: "{'searchText':'" + $("#txtItemAutoPopulate").val() + "'}",
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
                        $("#txtItemAutoPopulate").val("");
                        $("#hdnItem").val(0);
                    } else {
                        $("#txtItemAutoPopulate").val(ui.item.label); //ui.item is your object from the array
                        $("#hdnItem").val(ui.item.id);
                    }
                    //Prevent value from being put in the input:

                    // alert(ui.item.id);
                    //searchCustomers(ui.item.id);
                    event.preventDefault();
                },
                minLength: 1
            });
            //End autocomplete
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


        //start by deepika 
        //function for load branches
        function showBranches() {
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/showBranches",
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
                        loadTaxes(-1);
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

        //function for load branches in search
        function showsearchBranches() {
            // alert("");
            //  var loggedInBranch = $.cookie("staffBranchId");
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/showsearchBranches",
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
                        $("#combosearchbranchtype").html(msg.d);
                        // $("#showsearchbranchdiv").html(msg.d);
                        $("#combosearchbranchtype").val(BranchId);
                        loadcategory();

                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function loadcategory() {
            //  brandval = $("#comboBrandtype").val();
            //  alert(brandVal);
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/loadCategory",
                data: "{}",
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
                        $("#combosearchcategory").html(msg.d);
                        loadBrands();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function loadBrands() {
            //  var loggedInBranch = $.cookie("staffBranchId");
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/loadbrands",
                data: "{}",
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
                        $("#combobranddiv").html(msg.d);

                        searchBranchStockdetail(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //function for load items

        //function for add branch stock details
        function addBranchStockdetail(actionType, itbsid) {
            var stockChange = 0;
            var stockdifr = 0;
            var branch = $("#warehousediv").val();
            //var item = $("#txtItemAutoPopulate").val();
            var item = $("#hdnItem").val();
            var stock = $("#txt_actual_stock").val();
            var reorderlevel = $("#txtReorderLevel").val();
            var available = $("#comboavailablestatus").val();
            var taxcode = $("#selTaxcode").val();
            var duration = $("#txtDuration").val();
            var priority = $("#comboPriority").val();
            var purchasePrice = $("#txtPurchasePrice").val();
            //var itm_mrp = $("#txtitemMRP").val();
            if (branch == 0 || branch == "") {
                alert("select Warehouse");
                return;
            }
            if (item == 0 || item == "") {
                alert("select item");
                return;
            }
         
            if (isNaN($("#txt_actual_stock").val()) || $("#txt_actual_stock").val() == "") {
                alert("Stock should be in number only");
                $("#txt_actual_stock").focus();
                return;
            }

            if (purchasePrice == 0) {
                alert("Enter Purchase Price");
                $("#txtPurchasePrice").focus();
                return;
            }
            if (isNaN($("#txtPurchasePrice").val())) {
                alert("Purchase Price should be in number only");
                $("#txtPurchasePrice").focus();
                return;
            }

            if (reorderlevel == 0) {
                alert("Enter reorderlevel");
                return;
            }
            if (isNaN($("#txtReorderLevel").val())) {
                alert("Reorder Level should be in number only");
                $("#txtReorderLevel").focus();
                return;
            }
            if (taxcode == -1 || taxcode == "") {
                alert("choose item tax code");
                return;
            }
            if (currentStock != $("#txt_actual_stock").val()) {
                stockChange = 1;
                stockdifr = $("#txt_actual_stock").val() - currentStock;
               
            }

            var pricegroup_one = $("#pricegroup0").val();
            var pricegroup_two = $("#pricegroup1").val();
            var pricegroup_three = $("#pricegroup2").val();
            var itm_mrp = 0;

            if (isNaN($("#pricegroup0").val())) {
                alert("Price should be in number only");
                $("#pricegroup0").focus();
                return;
            }
            if (isNaN($("#pricegroup1").val())) {
                alert("Price should be in number only");
                $("#pricegroup1").focus();
                return;
            }
            if (isNaN($("#pricegroup2").val())) {
                alert("Price should be in number only");
                $("#pricegroup2").focus();
                return;
            }
            if (stock == "") {
                stock = 0;
            }

            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/addBranchStockDetails",
                data: "{'actionType':'" + actionType + "','itbsid':'" + itbsid + "','branch':'" + branch + "','item':'" + item + "','currentstock':'" + stock + "','reorderlevel':'" + reorderlevel + "','status':'" + available + "','itm_mrp':'" + itm_mrp + "','pricegroup_one':'" + pricegroup_one + "','pricegroup_two':'" + pricegroup_two + "','pricegroup_three':'" + pricegroup_three + "','taxcode':'" + taxcode + "','duration':'" + duration + "','priority':'" + priority + "','sessionId':'" + sessionId + "','actual_stock':'" + $("#txt_actual_stock").val() + "','stockChange':'" + stockChange + "','stockDifr':'" + stockdifr + "','purchasePrice':'" + purchasePrice + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "E") {
                        alert("already exist");
                    }
                    if (msg.d == "Y") {
                        // alert("Group Added Successfully");
                        if (actionType == "insert") {

                            alert("Item Added Successfully");
                            $("#div_stock_status").hide();
                            window.location.reload();
                            return;
                        }
                        if (actionType == "update") {

                            alert("Item Updated Successfully");
                            $("#div_stock_status").hide();
                            clearform();
                            searchBranchStockdetail(1);
                            return;
                        }

                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });


        }

        function clearform() {
            $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:addBranchStockdetail(\"insert\",0);'>SAVE</div>");
            $("#comboinvntrystock").val(0);
            $("#warehousediv").val("0");
            $("#txtItemAutoPopulate").val("");
            $("#hdnItem").val(0);
            $("#div_stock_status").hide();
            $("#txtReorderLevel").val("0");
            $("#comboavailablestatus").val(1);
            $("#txtitemMRP").val('');
            $("#pricegroup0").val('0');
            $("#pricegroup1").val('0');
            $("#pricegroup2").val('0');
            $("#txtDuration").val("0");
            $("#selTaxcode").val('-1');
            $("#comboPriority").val(0);
            $("#txt_actual_stock").val('0');
            //$("#sales_commission").val('');
            //$("#sales_target").val('');
        }

        //function for load items
        //function for search
        function searchBranchStockdetail(page) {
            // alert(page);
            sqlInjection();
            var filters = {};

            //var itemval = $("#txtSearchItem").val();
            if ($("#txtSearchItem").val() !== undefined && $("#txtSearchItem").val() != "") {
                filters.itemval = $("#txtSearchItem").val();
            }

            // var branch = $("#combosearchbranchtype").val();
            if ($("#combosearchbranchtype").val() !== undefined) {
                filters.branch = $("#combosearchbranchtype").val();
            }

            var brand = $("#combobranddiv").val();
            if ($("#combobranddiv").val() !== undefined && $("#combobranddiv").val() != "-1") {
                filters.brand = $("#combobranddiv").val();
            }

            //var category = $("#combosearchcategory").val();
            if ($("#combosearchcategory").val() !== undefined && $("#combosearchcategory").val() != "-1") {
                filters.category = $("#combosearchcategory").val();
            }

            filters.itmstock = $("#comboinvntrystock").val();

            var perpage = $("#txtpageno").val();
            // alert(perpage);
            console.log(JSON.stringify(filters));
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/searchBranchStock",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //  alert(msg.d);
                    if (msg.d == "N") {
                        Unloading();
                        // alert("No Search Results");
                        for (var i = 2; i < ($('#divSearchBranchStock1 tr').length) ; i++) {
                            $('#divSearchBranchStock1 > tbody > tr:gt(' + i + ')').remove();
                        }
                        $("#divSearchBranchStock1 tbody").html('<td colspan="6" style="padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#lblTotalrerd").text(0);
                        $("#paginatediv").html("");
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //   console.log(obj);
                        Unloading();
                        var htm = "";
                        //  htm += '<tr style="font-size:12px;" >';
                        //htm += '<td colspan="5" style="padding:5px; text-align:center; overflow:hidden; border-right:none;">';
                        //htm += '<div><span style="margin-left:0px;float:right;text-align:right;font-size:14px;">Total Records:' + obj.count + '</span></div>';
                        //htm += '</td> </tr>';
                        $.each(obj.data, function (i, row) {
                            htm += "<tr style='cursor:pointer; font-size:12px;' id='itemRow" + i + "' onclick='javascript:editBranchStockdetail(" + row.itbs_id + ");'>";
                            if (row.itbs_available == "1") {
                                htm += "<td><div class='activebtn fl'></div></td>";
                            }
                            else {
                                htm += "<td><div class='inactive fl'></div></td>";
                            }


                            htm += "<td>" + getHighlightedValue(filters.itemval, row.itm_name.toString()) + "</td>";
                            htm += "<td>" + row.branch_name + "</td>";
                            htm += "<td>" + row.itbs_stock + "</td>";
                            htm += "<td>" + row.itbs_reorder + "</td>";
                            htm += '<td><div class="btn btn-primary btn-xs">';
                            htm += '<li class="fa fa-eye" style="font-size:large;"></li>';
                            htm += '</div></td>';
                            //htm += "<td style='width:90px!important; padding:2px;' class='nonheadtext'><div style='width:124px!important; padding:2px;'>" + row.itm_mrp + "</div></td>";
                            //    htm += "<td><button class='btn btn-primary btn-xs' onclick='javascript:editBranchStockdetail(" + row.itbs_id + ");' type='reset'><li class='fa fa-folder-open'></li>View</button></td>";
                            // htm += "<td style='width:200px!important; padding:2px;border-right:none;' class='nonheadtext'><div onclick=javascript:editBranchStockdetail(" + row.itbs_id + "); class='viewbtn'><div class='viewbtntext'>View</div></div></td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#divSearchBranchStock1 tbody").html(htm);
                        $("#lblTotalrerd").text(obj.count);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "searchBranchStockdetail"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //function for edit branch stock
        function editBranchStockdetail(itbsid) {
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/editBranchStockdetail",
                data: "{'itbsid':'" + itbsid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d != 0) {

                        var splitarray = msg.d.split("@#$");
                        //alert(splitarray);
                        $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:addBranchStockdetail(\"update\"," + splitarray[0] + ");'>UPDATE</div>");
                        // $("#txtCorporateID").val(id);
                        $("#warehousediv").val(splitarray[1]);
                        $("#hdnItem").val(splitarray[2]);
                        $("#txtItemAutoPopulate").val(splitarray[12]);
                        
                        $("#txtReorderLevel").val(splitarray[4]);
                        $("#comboavailablestatus").val(splitarray[5]);
                        $("#txtitemMRP").val(splitarray[6]);
                        $("#pricegroup0").val(splitarray[7]);
                        $("#pricegroup1").val(splitarray[8]);
                        $("#pricegroup2").val(splitarray[9]);
                        $("#txtDuration").val(splitarray[14]);
                        $("#comboPriority").val(splitarray[15]);
                        $("#txtPurchasePrice").val(splitarray[18]);
                        $("#lbl_req_stock").html(splitarray[16] + " Units");
                        $("#lbl_processed_stock").html(splitarray[17] + " Units");
                        var wh_stock = parseInt(splitarray[16]);
                        $("#txt_actual_stock").val(parseInt(splitarray[3]) + parseInt(wh_stock));
                        currentStock=parseInt(splitarray[3]) + parseInt(wh_stock);
                        loadTaxes(splitarray[13]);

                        $("#div_stock_status").show();
                        //if (splitarray[13] == "") {
                        //    $("#selTaxcode").val('-1');
                        //} else {
                        //    $("#selTaxcode").val('Notax12345');
                        //}
                        //$("#sales_commission").val(splitarray[10]);
                        //$("#sales_target").val(splitarray[11]);
                        $('html,body').animate({
                            scrollTop: $('#Divstockdetails').offset().top
                        }, 500);
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //function for rest
        function resetBranchStockdetail() {
            //alert("");
            for (var i = 1; i <= 4; i++) {
                $("#searchwarehouse" + i).val('');
            }
            $("#comboinvntrystock").val(0);
            $("#combobranddiv").val(-1);
            $("#combosearchcategory").val(-1);
            $("#txtSearchItem").val('');
            $("#combosearchbranchtype").val(0);
            $("#comboPriority").val(0);
            searchBranchStockdetail(1);
        }

        //start: searching pos items
        function searchOrderitems() {
            //   showsearchItems();
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            $("#combosearchitemtype").val(0);
            searchOrderitem(1);
        }
        //stop: searching pos items

        //start: Adding New Item Pop Up
        function searchOrderitem(page) {
            if ($("#warehousediv").val() == 0) {
                alert("Please choose a warehouse..");
                $('#itemModal').modal('toggle');
                // $('#itemModal').modal('hide');
                //    $("#itemModal").modal('hide');
                return false;
            }
            //var isConditionNeed = 0;
            sqlInjection();
            var Itemfilters = {};

            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                Itemfilters.item_code = $("#searchposContent1").val();
            }

            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                Itemfilters.item_name = $("#searchposContent2").val();
            }
            Itemfilters.warehouse = $("#warehousediv").val();
            var perpage = $("#txtpospageno").val();
            //if (isConditionNeed == 1) {
            //    searchResult = "where " + searchResult;
            //}
            loading();

            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/searchItem",
                data: "{'page':" + page + ",'Itemfilters':" + JSON.stringify(Itemfilters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();

                    if (msg.d == "N") {

                        $('#tablepos > tbody').html('<td colspan="2" style="background:#ebebeb; padding:5px;font-weight:bold; "><div style="width:100%;text-align:center"><div style="display:inline-block;font-size:12px;">Nothing Found...</div></div></td>');
                        //  $('#tableoutstanding > tbody > tr:gt(1)').replaceWith(altmessage);
                        $("#paginatedivone").html("");
                        $("#lblTotalRecord").text(0);
                        // $("#findPosItemDiv").show();

                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  console.log(obj);
                        var htm = "";
                        //htm += "<tr style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='2'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            // console.log(row);

                            htm += "<tr style='font-size:12px; cursor:pointer;text-align:left'";
                            htm += " title='Click to View' onclick=javascript:selectOrderItem('" + row.itm_id + "','" + row.itm_name.replace(/\s/g, '&nbsp;') + "'); style='cursor:pointer;' alt='Working'><td style='padding:5px;'>" + getHighlightedValue(Itemfilters.item_code, row.itm_code.toString()) + "</td><td style='padding:5px;height:auto;'>" + getHighlightedValue(Itemfilters.item_name, row.itm_name.toString()) + "</td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="2">';
                        htm += '<div id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        //alert(htm);
                        $('#tablepos tbody').html(htm);
                        $("#lblTotalRecord").text(obj.count);
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitem"));
                        //$("#findPosItemDiv").show();
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
        //stop: Adding New Item Pop Up

        // start: Showing Details of selected  Item from Popup
        function selectOrderItem(item_code, item_name) {

            $("#txtItemAutoPopulate").val(item_name); //ui.item is your object from the array
            $("#hdnItem").val(item_code);
            $('#itemModal').modal('hide');
        }
        // Stop: Showing Details of selected  Item from Popup

        function loadTaxes(currentVal) {
            var taxType = $("#warehousediv option:selected").attr("taxType");
            loading();
            $.ajax({
                type: "POST",
                url: "warehousemanagement.aspx/loadTaxes",
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
                        $("#selTaxcode").val(currentVal);
                        return;
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
                        <a href="#" class="site_title">
                            <!--<i class="fa fa-paw"></i> -->
                            <span>Invoice Me</span></a>
                    </div>

                    <div class="clearfix"></div>

                    <!-- menu profile quick info -->
                    <div class="profile clearfix">
                        <div class="profile_pic">
                            <%--<img src="../images/img.jpg" alt="..." class="img-circle profile_img">--%>
                        </div>
                        <div class="profile_info">
                            <%--<span>Welcome,</span>
                <h2>John Doe</h2>--%>
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
                                <label style="font-weight: bold; font-size: 16px;">Item Management</label>
                            </div>
                            <div class="col-md-6 col-xs-5">
                                <div onclick="javascript:clearform();" class="btn btn-success btn-xs pull-right" style="background-color: #d86612; border-color: #d86612; margin-top: 5px">
                                    <label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>
                                    New
                                </div>
                            </div>
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">

                <div class="clearfix"></div>
                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12" id="Divstockdetails">
                        <div class="x_panel">
                            <div class="x_title" style="margin-bottom: 0px;">
                                <label>Basic Details </label>
                                <ul class="nav navbar-right panel_toolbox">
                                    <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                    </li>

                                    <%--                                        <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                </ul>
                            </div>
                            <div class="x_content">
                                <br />
                                <form id="demo-form2" data-parsley-validate class="form-horizontal form-label-left">

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Select Warehouse<span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <div id="showbranchdiv">
                                                <select id="warehousediv" class="form-control" onchange="loadTaxes(-1);">
                                                    <option value="0">--Select Warehouse--</option>
                                                </select>
                                            </div>
                                        </div>
                                        <a href="warehouse.aspx" target="_blank"><div class="btn btn-success btn-xs" style="background-color:#4796ce; border-color:#4796ce; margin-top:5px">Manage Warehouse</div></a>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Select Item<span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-9" id="showitemDiv">
                                            <input type="text" class="form-control col-md-7 col-sm-6 col-xs-12" placeholder="Select Item" required="required" id="txtItemAutoPopulate" />
                                        </div>
                                        <div onclick="javascript:searchOrderitems();" class="col-md-3 col-sm-2 col-xs-3" style="font-size: 22px; padding-left: 0px;" data-toggle="modal" data-target="#itemModal">
                                            <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                            <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;" title="Add item"></label>
                                        </div>
                                    </div>
                                    <%--<div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Stock<small>( Includes New,Processed,To be Confirmed & Pending Orders )</small>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" disabled id="txt_actual_stock" placeholder="" style="padding: 0px; text-indent: 3px;" required="required" class="form-control col-md-7 col-xs-12">
                                        </div>
                                    </div>--%>
                                     <hr />
                                    <div class="form-group" id="div_stock_status" style="display:none">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Stock Status
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <table class="table-bordered table-striped" style="width:100%;text-align:center">
                                                <tr>
                                                    <td> Stock Required for <b>New, To be Confirmed & Pending </b>Orders </td>
                                                    <td> <b>Stock in Vehicle</b> <br />(Processed Orders) </td>
                                                </tr>
                                                <tr>
                                                    <td ><b id="lbl_req_stock" style="margin-top:5px;margin-bottom:5px">0 Units </b></td>
                                                    <td ><b id="lbl_processed_stock" style="margin-top:5px;margin-bottom:5px">0 Units </b></td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="purchase-price">
                                            Purchase Price<span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="txtPurchasePrice" style="padding: 0px; text-indent: 3px;" name="purchase-price" required="required" class="form-control col-md-7 col-xs-12" value="0"/>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Stock in Warehouse 
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="txt_actual_stock" placeholder="" style="padding: 0px; text-indent: 3px;" required="required" class="form-control col-md-7 col-xs-12">
                                        </div>
                                        <small style="color:#d00101"> Exact Stock in godown</small>
                                    </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            Reorder Level<span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="txtReorderLevel" style="padding: 0px; text-indent: 3px;" placeholder="" name="last-name" required="required" class="form-control col-md-7 col-xs-12">
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                            Available
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <select class="form-control" id="comboavailablestatus">
                                                <option value="1">Yes</option>
                                                <option value="0">No</option>
                                            </select>
                                        </div>
                                        </div>
                                    <hr />
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            Tax code<span class="required">*</span>
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <select id="selTaxcode" class="form-control" style="padding-right: 2px;">
                                                <option value="0">--Brand--</option>
                                            </select>
                                        </div>
                                         <a href="manageTax.aspx" target="_blank"><div class="btn btn-success btn-xs" style="background-color:#4796ce; border-color:#4796ce; margin-top:5px">Manage Tax</div></a>
                                    </div>
                                    
                                    

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="duration">
                                            Duration
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="txtDuration" style="padding: 0px; text-indent: 3px;" placeholder="0.00" name="duration" required="required" class="form-control col-md-7 col-xs-12">
                                        </div>
                                        minutes

                                    </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="priority">
                                            Priority
                                        </label>

                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <select class="form-control" id="comboPriority">
                                                <option value="0">0</option>
                                                <option value="1">1</option>
                                                <option value="2">2</option>
                                                <option value="3">3</option>
                                                <option value="4">4</option>
                                                <option value="5">5</option>
                                                <option value="6">6</option>
                                                <option value="7">7</option>
                                                <option value="8">8</option>
                                                <option value="9">9</option>
                                                <option value="10">10</option>
                                            </select>
                                        </div>
                                        <%--<input type="number" id="txtPriority" style="padding: 0px; text-indent: 3px;" placeholder="0.00" name="duration" required="required" class="form-control col-md-7 col-xs-12">--%>
                                    </div>
                                </form>
                                <%-- </div>--%>
                                <div class="clearfix"></div>

                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Client Price Groups </label>
                                    <div class="clearfix" style="clear: both;"></div>

                                </div>
                                <%--	  <div class="x_content">--%>
                                <br>
                                <form class="form-horizontal form-label-left">


                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            Class A
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="pricegroup0" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                            <input type='hidden' value='1' id='custrtype0' />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            Class B
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="pricegroup1" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                            <input type='hidden' value='2' id='custrtype1' />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                            Class C
                                        </label>
                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                            <input type="number" id="pricegroup2" style="padding: 0px; text-indent: 3px;" placeholder="Enter price" name="last-name" min="0" required="required" class="form-control col-md-7 col-xs-12" />
                                            <input type='hidden' value='3' id='custrtype2' />
                                        </div>
                                    </div>
                                </form>

                                <div class="clearfix"></div>
                                <div class="ln_solid"></div>
                                <div class="form-group" style="padding-bottom: 40px;">
                                    <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-5" style="padding-left: 0px; padding-right: 0px;">


                                        <div id="btnservMasterAction">
                                            <div class="btn btn-success mybtnstyl" onclick="javascript:addBranchStockdetail('insert',0);">SAVE</div>
                                        </div>
                                        <div onclick="javascript:clearform();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="clearfix"></div>
                <div class="container">

                    <!-- Trigger the modal with a button -->
                    <%--  <button >Open Modal</button>--%>

                    <!-- Modal -->
                    <div class="modal fade" id="itemModal" role="dialog">
                        <div class="modal-dialog modal-md" style="width: ;">

                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-3 col-sm-6 col-xs-12">
                                        <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalRecord">0</span></h4>
                                    </div>
                                    <div class="col-md-6 col-sm-12 col-xs-12 pull-right">




                                        <div class="col-md-8 col-sm-4 col-xs-4">
                                            <div class="btn btn-success mybtnstyl" onclick="javascript:searchOrderitem(1);">
                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                Search
                                            </div>
                                            <div class="btn btn-primary mybtnstyl" onclick="javascript:searchOrderitems();">
                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                Reset
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-4 col-xs-3" style="float: right;">
                                            <select id="txtpospageno" onchange="javascript:searchOrderitem(1);" class="input-sm">
                                                <option value="50">50</option>
                                                <option value="100">100</option>
                                                <option value="250">250</option>
                                                <option value="500">500</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; margin-top: 5px;">
                                    <div class="x_content">

                                        <table id="tablepos" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <th>Item Code</th>
                                                    <th>Item Name</th>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="text" id="searchposContent1" placeholder="Item Code" class="form-control" /></td>
                                                    <td>
                                                        <input type="text" id="searchposContent2" placeholder="Item Name" class="form-control" /></td>
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
                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">
                        <div class="x_panel">
                            <div class="x_title" style="margin-bottom: 2px;">
                                <label>Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                <ul class="nav navbar-right panel_toolbox">
                                    <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                    </li>
                                    <%-- <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>

                                        </li>--%>
                                    <%--  <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
                                </ul>

                            </div>
                            <div class="x_content" style="padding-bottom: 0px;">
                                <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                        <div class="fl" id="showsearchbranchdiv"></div>
                                        <select id="combosearchbranchtype" class="form-control" style="text-indent: 25px;" onchange="javascript:searchBranchStockdetail(1);">
                                            <option>--Warehouse--</option>
                                            <%--                          <option>Abu Dhabi</option>
                            <option>Ajman</option>--%>
                                        </select>
                                        <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                        <div class="" id="showbranddiv">
                                            <select id="combobranddiv" class="form-control" style="text-indent: 25px; padding-right: 2px;" onchange="javascript:searchBranchStockdetail(1);">
                                                <option value="0">--Brand--</option>
                                            </select>
                                        </div>
                                        <%--								<select id="combobranddiv" class="form-control" style="text-indent:25px;">
                            <option>--Brand--</option>
                            <option>No Outstanding</option>
                            <option>Have Outstanding</option>
                       
                          </select>--%>
                                        <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                        <div class="" id="showcategorydiv">
                                            <select id="combosearchcategory" class="form-control" style="text-indent: 25px; padding-right: 2px;" onchange="javascript:searchBranchStockdetail(1);">
                                                <option value="0">--Category--</option>
                                            </select>
                                        </div>
                                        <%--			<select id="combosearchcategory" class="form-control" style="text-indent:25px;">
                            <option>--Category--</option>
                            <option>Class A</option>
                            <option>Have Outstanding</option>
                       
                          </select--%>
                                        <span class="fa fa-clone form-control-feedback left" aria-hidden="true"></span>
                                    </div>

                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                        <select id="comboinvntrystock" class="form-control" style="text-indent: 25px; padding-right: 2px;" onchange="javascript:searchBranchStockdetail(1);">
                                            <option value="0">All Stock</option>
                                            <option value="1">In Stock</option>
                                            <option value="2">Out Of Stock</option>

                                        </select>
                                        <span class="fa fa-shopping-basket form-control-feedback left" aria-hidden="true"></span>
                                    </div>

                                    <div class="clearfix"></div>
                                    <div style="height: 5px;"></div>

                                    <div class="col-md-11 col-sm-6 col-xs-8" style="padding-right: 0px;">
                                        <div class="input-group">

                                            <input type="text" class="form-control" id="txtSearchItem" placeholder="Search Item code/Name" style="height: 34px; padding-right: 2px;">

                                            <span class="input-group-btn" title="search">

                                                <button type="button" class="btn btn-default" onclick="searchBranchStockdetail(1)">
                                                    <i class="fa fa-search" title="search"></i>
                                                </button>
                                            </span>

                                        </div>
                                    </div>
                                    <div class="fl" style="padding-left: 2px;" onclick="resetBranchStockdetail()">
                                        <a class="btn btn-primary btn-xs" style="text-align: center; background: #337ab7; border-color: #2e6da4;">
                                            <li class="fa fa-refresh" style="padding: 3px; font-size: 19px; color: white; margin-top: 3px;" onclick="" title="Refresh"></li>
                                        </a>
                                    </div>
                                    <div class="fl">
                                        <ul class="nav navbar-right panel_toolbox">

                                            <li>

                                                <select class="input-sm" id="txtpageno" onchange="javascript:searchBranchStockdetail(1);">
                                                    <option value="25">25</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                     <option value="500">500</option>
                                                </select>



                                            </li>


                                        </ul>
                                    </div>


                                </div>
                            </div>

                            <div class="clearfix"></div>
                            <div class="ln_solid" style="margin-top: 5px;"></div>
                            <div id="divSearchBranchStock" class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                <div class="x_content">
                                    <table id="divSearchBranchStock1" class="table table-striped table-bordered" style="table-layout: auto;">
                                        <thead>
                                            <tr>
                                                <th>Status</th>
                                                <th>Item Name</th>
                                                <th>Warehouse</th>
                                                <th>Stock</th>
                                                <th>Reorder</th>
                                                <th>View</th>
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
        <input type="hidden" id="hdnItem" value="0" />
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
