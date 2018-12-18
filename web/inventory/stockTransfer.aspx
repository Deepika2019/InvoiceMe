<%@ Page Language="C#" AutoEventWireup="true" CodeFile="stockTransfer.aspx.cs" Inherits="inventory_stockTransfer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Stock Transfer  | Invoice Me</title>

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
        $(document).ready(function () {
            getBranches();
            searchAutoItems();
            $("#itemNames").val("");
            $('select').change(function () {
                $("#tblTransferItems").find("tr:gt(0)").remove();
                $("#divShowNoItems").show();
                //  $("#tblTransferItems > tbody").html("");
                // $("#tbodyid").empty();
                // window.location.reload(true);
            })
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");

        });

        //get branch
        function getBranches() {
            loading();
            $.ajax({
                type: "POST",
                url: "stockTransfer.aspx/getBranches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htmF = "";
                    var htmT = "";
                    htmF += '<option value="-1" selected="selected">--Source Warehouse--</option>';
                  //  htmF += '<option value="0" selected="selected">central warehouse</option>';
                    htmT += '<option value="-1" selected="selected">--Destination Warehouse--</option>';
                  //  htmT += '<option value="0" selected="selected">central warehouse</option>';
                    //    htmT += '<option value="0" selected="selected">--central warehouse--</option>';
                    $.each(obj, function (i, row) {
                        htmF += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                        htmT += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#comboFromBranch").html(htmF);
                    $("#comboToBranch").html(htmT);
                    $("#comboFromBranch").val(-1);
                    $("#comboToBranch").val(-1);

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        //auto populate for item search
        function searchAutoItems() {
            $("#itemNames").keyup(function () {
                //alert("ch");
                if ($("#comboFromBranch").val() == -1 || $("#comboToBranch").val() == -1) {
                    alert("Please choose both source and destination warehouses");
                    $("#itemNames").val("");
                    return false;
                }
                if ($("#comboFromBranch").val() == $("#comboToBranch").val()) {
                    alert("Please choose different warehouses");
                    $("#itemNames").val("");
                    return false;
                }
                if ($("#itemNames").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });

            $("#itemNames").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "stockTransfer.aspx/GetAutoCompleteItemData",
                        data: "{'variable':'" + $("#itemNames").val() + "','fromWarehose':'" + $("#comboFromBranch").val() + "','toWarehose':'" + $("#comboToBranch").val() + "'}",
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
                        $("#itemNames").val("");
                    } else {
                        $("#itemNames").val(ui.item.label); //ui.item is your object from the array
                        selectTransferItem(ui.item.id, ui.item.code, ui.item.value, ui.item.stock);
                    }

                   
                    event.preventDefault();
                },
                minLength: 1

            });
        }

        //search items
        function resetItemSearch() {
            //  alert("");
            //   showsearchItems();
            for (var i = 1; i <= 7; i++) {
                $("#searchItemField" + i).val('');
            }
            $("#combosearchitemtype").val(0);
            searchTransferitem(1);
        }

        function searchTransferitem(page) {
            var filters = {};
            filters.fromWarehouse = $("#comboFromBranch").val();
            filters.toWarehouse = $("#comboToBranch").val();
            if (filters.fromWarehouse == -1 || filters.toWarehouse == -1) {
                alert("Please choose both source and destination warehouses");
                return false;
            }
            if (filters.fromWarehouse == filters.toWarehouse) {
                alert("Please choose different warehouses");
                return false;
            }

            if ($("#searchItemField2").val() !== undefined && $("#searchItemField2").val() != "") {
                filters.itemname = $("#searchItemField2").val();
            }

            //  alert(itemcode);
            if ($("#searchItemField1").val() !== undefined && $("#searchItemField1").val() != "") {
                filters.itemcode = $("#searchItemField1").val();
            }

            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "stockTransfer.aspx/searchTransferitem",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N") {
                        alert("No Items found...");
                        $("#lblItemTotalrecords").text(0);
                        $('#tableItemList tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        $("#popupItems").modal('show');
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  console.log(obj);
                        $("#lblItemTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {

                            htm += "<tr ";
                            htm += " onclick=javascript:selectTransferItem('" + row.itemId + "','" + row.itemCode.replace(/\s/g, '&nbsp;') + "','" + row.itemName.replace(/\s/g, '&nbsp;') + "','" + row.stock + "'); style='cursor:pointer;'><td>" + row.itemCode + "</td><td>" + row.itemName + "</td><td>" + row.stock + "</td>";

                            // $('#tableItemList > tbody > tr:gt(' + (i + 2) + ')').remove();
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';

                        //   alert(htm);
                        $('#tableItemList tbody').html(htm);
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
                    $("#lblItemTotalrecords").text(0);
                    $('#tableItemList tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    $("#paginatedivone").html("");
                    $("#popupItems").modal('show');
                    return;
                }
            });

        }

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        //add item to table
        function selectTransferItem(itemId, code, name, stock) {
            $("#itemNames").val("");
            var html = '';
            var rowCount = $('#tblTransferItems tr').length;
            for (i = 1; i < rowCount; i++) {
                var currentId = $.trim($('#tblTransferItems tr:eq(' + i + ') td:eq(3)').text());
                if (currentId == itemId) {
                    alert("This item already selected");

                    return false;
                }

            }

            html = "<tr class='classtest'>";
            html = html + "<td>" + code + "</td>";
            html = html + "<td>" + name + "(Available stock=" + stock + ")</td>";
            html = html + "<td><input type='text' onkeyup=modifyQuantity(this); class='textwidth' style=' width:98%;' value='1' data-quantityval=" + stock + "/></td>";
            html = html + "<td style='display:none;'>" + itemId + "</td>";
            html = html + "<td><a class='btn btn-danger btn-xs'><li class='fa fa-close' onclick='DeleteRaw(this);'></li></a></td>";
            html = html + "</tr>";
            $("#divShowNoItems").hide();
            $(html).appendTo($("#tblTransferItems"));
            popupclose('popupItems');

        }

        //modify input field
        function modifyQuantity(ctrl) {
            var parentRow = $(ctrl).closest('td').parent()[0];
            var rowId = parentRow.sectionRowIndex;
            $(parentRow).find("[data-quantityval]").each(function (i) {
                var currentstock = $.trim($(this).val());
                var totalstock = parseFloat($(this).attr('data-quantityval').trim());
                if (isNaN(currentstock) == false) {
                    if (currentstock > totalstock) {
                        alert("There is no enough stock");
                        $(ctrl).addClass('err');
                        return false;
                    } else if (currentstock <= totalstock) {
                        $(ctrl).removeClass('err');

                        if (currentstock == 0) {
                            $(ctrl).addClass('err');
                            // $(this).val(1);
                        }
                    }
                } else {
                    // alert("Enter a valid number");
                    $(ctrl).addClass('err');
                    return false;
                }
            })

            if ($(document).find(".err").length > 0) {
                console.log($(document).find(".err").length);
                $("#divtransferItem").css('pointer-events', 'none');
            }
            else {
                $("#divtransferItem").css('pointer-events', 'auto');
            }
        }

        //delete row
        function DeleteRaw(ctrl) {
            $(ctrl).closest('tr').remove();
        }

        //save transfer items
        function saveTransferItems() {
            var filters = {};
            filters.TimeZone = $.cookie("invntryTimeZone");
            filters.fromWarehouse = $("#comboFromBranch").val();
            filters.toWarehouse = $("#comboToBranch").val();
            filters.userId = $.cookie("invntrystaffId");
            var tblrowCount = $('#tblTransferItems tr').length;
            if (tblrowCount <= 1) {
                alert("Please Add Item");
                return;
            }
            var itemstring = '';
            for (var row = 1; row < tblrowCount; row++) {
                //  alert(row);
                itemstring += "{";
                itemstring += "'itemId':'" + $("#tblTransferItems tr:eq(" + row + ") td:eq(3)").text() + "',";
                itemstring += "'stock':'" + $("#tblTransferItems tr:eq(" + row + ") td:eq(2) input").val() + "'";
                itemstring += "},";
            }
            var lastChar = itemstring.slice(-1);
            if (lastChar == ',') {
                itemstring = itemstring.slice(0, -1);
            }
            itemstring = "[" + itemstring + "]";
            bootbox.confirm("Do you want to continue?", function (result) {
                if (result) {
                    loading();
                    // alert("{'MemberId':'" + MemberId + "','MemberName':'" + MemberName + "','TotalCost':'" + TotalCost + "','TotalDiscountRate':'" + TotalDiscountRate + "','TotalDiscountAmount':'" + TotalDiscountAmount + "','Tax':'" + TaxAmount + "','billdate':'" + cur_dat + "','userid':'" + userid + "','TotalAmount':'" + TotalAmount + "','TotalCurrentAmount':'" + TotalCurrentAmount + "','TotalBalanceAmount':'" + TotalBalanceAmount + "','TotalPaidinFull':'" + TotalPaidinFull + "','paymentmode':'" + paymentmode + "','BankName':'" + BankName + "','ChequeAmount':'" + ChequeAmount + "','ChequeDate':'" + ChequeDate + "','ChequeNo':'" + ChequeNo + "','CardAmount':'" + CardAmount + "','CardNo':'" + CardNo + "','CardType':'" + CardType + "','CardBank':'" + CardBank + "','CashAmount':'" + CashAmount + "','CountryId':'" + CountryId + "','BranchId':'" + BranchId + "','SpecialNote':'" + SpecialNote + "','outstandingBillDate':'" + outstand_bl_dt + "','TimeZone':'" + TimeZone + "','tableString':'" + tableString + "','rowCount':" + rowCount + ",'PosCurrentPaidAmount':'" + PosCurrentPaidAmount + "','PosBalanceAmount':'" + PosBalanceAmount + "'}");
                    $.ajax({
                        type: "POST",
                        url: "stockTransfer.aspx/saveTransferItems",
                        data: "{'filters':" + JSON.stringify(filters) + ",'tableString':" + JSON.stringify(itemstring) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            //    alert(msg.d);
                            if (msg.d == "Y") {
                                alert("Items transfered successfully from " + $('#comboFromBranch option:selected').text() + " to " + $('#comboToBranch option:selected').text() + "");
                                setTimeout(function () {
                                    location.reload();
                                }, 1000);
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

        function addNewItem() {
            window.open('../inventory/warehousemanagement.aspx', '_blank');
            //  location.href = "../inventory/warehousemanagement.aspx";
        }


    </script>



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
                            <label style="font-weight: bold; font-size: 16px;">Stock Transfer</label>

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
                        <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                            <div class="x_panel">

                                <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                    <select class="form-control" style="text-indent: 25px;" id="comboFromBranch">
                                        <option value="1">Abudhabi</option>
                                        <option value="2">Ajman</option>
                                    </select>
                                    <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                </div>
                                <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback">
                                    <select class="form-control" style="text-indent: 25px;" id="comboToBranch">
                                        <option value="1">Abudhabi</option>
                                        <option value="2">Ajman</option>
                                    </select>
                                    <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                </div>


                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">



                        <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 6px; padding-bottom: 0px;">
                                    <label style="" class="pull-left">Transfer Items</label>
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

                                <div class="col-md-12 col-sm-12 col-xs-12" style="padding-left: 0px; padding-right: 0px;">

                                    
                                    <div class="col-md-6 col-sm-6 col-xs-9 pull-right form-group has-feedback" style="padding-right: 0px; margin-bottom: 10px">
                                        <div class="col-md-11 col-sm-6 col-xs-9">
                                            <input type="search" class="form-control" placeholder="Search Item" id="itemNames" style="text-indent: 30px; padding-right: 5px;" />
                                            <span aria-hidden="true" class="fa fa-search form-control-feedback left"></span>
                                        </div>
                                        <div class="col-md-1 col-sm-6 col-xs-2" onclick="javascript:resetItemSearch();" style="padding-right: 0px;">
                                            <div class="" style="font-size: 20px;" data-toggle="modal" title="Search Items">
                                                <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                                <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                            </div>

                                        </div>

                                        <%-- pop up for show normal items --%>
                                        <div class="container">


                                            <div class="modal fade" id="popupItems" role="dialog">
                                                <div class="modal-dialog modal-lg">

                                                    <!-- Modal content-->
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <button type="button" class="close" onclick="javascript:popupclose('popupItems');">&times;</button>
                                                            <div class="col-md-3 col-sm-6 col-xs-6">
                                                                <h4 class="modal-title">Items<label class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords">0</label></h4>
                                                            </div>
                                                            <div class="col-md-3 col-sm-6 col-sm-6"></div>
                                                            <div class="col-md-4 col-sm-4 col-xs-12 pull-right">
                                                                
                                                                
                                                                <div class="col-md-8 col-sm-12 col-xs-12">
                                                                    <div class="" onclick="javascript:searchTransferitem(1);">
                                                                        <button type="button" class="btn btn-success mybtnstyl">
                                                                            <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                            Search
                                                                        </button>
                                                                    </div>
                                                                    <div class="" onclick="javascript:resetItemSearch();">
                                                                        <button class="btn btn-primary mybtnstyl" type="reset">
                                                                            <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                            Reset
                                                                        </button>
                                                                    </div>
                                                                   
                                       
                                   
                                                                </div>
                                                                <div class="col-md-3 col-sm-12 col-xs-3">
                                                                    <select id="txtpospageno" onchange="javascript:searchTransferitem(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
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

                                                                <table id="tableItemList" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                    <thead>
                                                                        <tr>
                                                                            <th>Item Code</th>
                                                                            <th>Item Name  <div onclick="javascript:addNewItem();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612;"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New Item</div></th>

                                                                            <th>Stock</th>


                                                                        </tr>


                                                                        <tr>
                                                                            <td>
                                                                                <input type="text" class="form-control" id="searchItemField1" style="width: 80px; padding-right: 2px;" /></td>
                                                                            <td>
                                                                                <input type="text" id="searchItemField2" class="form-control" /></td>
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

                                    <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">
                                        <table id="tblTransferItems" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <tr>
                                                <th style="width: 150px;">Item Code</th>
                                                <th>Item Name</th>
                                                <th style="width: 80px;">Quantity	</th>
                                                <th style="width: 40px;"></th>
                                            </tr>


                                            <tbody>
                                            </tbody>

                                        </table>
                                        <div id="divShowNoItems">
                                            <label style="display: block; text-align: center; line-height: 150%; font-size: 12px;">No Items Found</label>
                                        </div>
                                        <div onclick="javascript:saveTransferItems();" id="divtransferItem" style="margin-top: 10px; pointer-events: auto;" class="col-md-12 col-sm-6 col-xs-12">
                                            <button type="button" class="btn btn-success mybtnstyl pull-right" style="padding-bottom: 2px; padding-top: 2px;"><span class="fa fa-truck" style="color: #fff; margin-right: 5px; font-size: 20px;"></span>Transfer</button>
                                        </div>
                                    </div>



                                </div>


                            </div>
                        </div>

                        <div class="clearfix"></div>
                        <%-- Cas,Card,Cheque start--%>

                        <input type="hidden" id="customerType" />
                        <%-- Cas,Card,Cheque End--%>
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
