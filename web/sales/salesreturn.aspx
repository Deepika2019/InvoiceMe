<%@ Page Language="C#" AutoEventWireup="true" CodeFile="salesreturn.aspx.cs" Inherits="sales_salesreturn" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Sales Return | Invoice Me</title>
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



    <script type="text/javascript">
        var custId;
        var sessionId = 0;
        $(document).ready(function () {
            custId = getQueryString("customerid");
            sessionId = getSessionID();
            //  alert(orderId);
            console.log(custId);
            getBrands();
            showCustomerDetails(custId);
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
        function getBrands() {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreturn.aspx/getBrands",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">-Brands--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.brand_id + '">' + row.brand_name + '</option>';
                    });
                    $("#selBrand").html(htm);
                    getCategories();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function getCategories() {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreturn.aspx/getCategories",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">-Categories--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cat_id + '">' + row.cat_name + '</option>';
                    });
                    $("#selCategory").html(htm);

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }
        //basic order details showing
        function showCustomerDetails(custId) {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreturn.aspx/showCustomerDetails",
                data: "{'custId':" + custId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    console.log(msg);
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);

                        if (obj[0].outstanding == null || obj[0].outstanding == "") {
                            obj[0].outstanding = 0;
                        }
                        $("#txtoutstanding").text(obj[0].outstanding);
                        if (obj[0].outstanding_amt > 0) {
                            $("#txtoutstanding").css("color", "red");
                        } else {
                            $("#txtoutstanding").css("color", "green");
                        }
                        $("#lblcustomerName").text(obj[0].name);
                       
                    } else {
                        alert("No data found");
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });

        }

        function resetOrderitems() {
            $("#searchcustom1").val("");
            $("#searchcustom2").val("");
            $("#selBrand").val(-1);
            $("#selCategory").val(-1);
            searchOrderitems(1);
        }

        function searchOrderitems(page) {
            var postObj = {
                filters: {

                    custid: custId,
                    brand: $("#selBrand").val(),
                    category: $("#selCategory").val(),
                    searchCod: $("#searchcustom1").val(),
                    searchName: $("#searchcustom2").val(),
                    branch_id: $.cookie("invntrystaffBranchId"),
                    page: page
                }
            };

            loading();
          //  var json_req = { orderid: orderNo, itemcode: itemcode, itemname: itemname };
            $.ajax({
                type: "POST",
                url: "salesreturn.aspx/searchOrderitems",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != "N") {
                        var itemdetails = JSON.parse(msg.d);
                        console.log(itemdetails);
                        var htm = "";
                        $("#lblReturnTotalrecords").text($(itemdetails).length);
                      //  htm += "<tr><td colspan='7'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + $(itemdetails).length + "</span></div></td> </tr>";
                        var serialNo = 1;
                        $.each(itemdetails, function (index, item) {
                          //  alert(item.total_qty);
                            var totalqty = item.total_qty - item.returned;
                          //  alert(totalqty);
                            if (totalqty == 0) {
                                htm += "<tr style='cursor:pointer;'";
                                htm += " title='Click to View' onclick=javascript:alertfunctn(); style='cursor:pointer;' alt='Working'><td>" + serialNo + "</td><td>" + item.itm_code + "</td><td>" + item.itm_name + "</td>";
                                htm += "<td>" + totalqty + "</td><td>" + item.return_price + "</td></tr>";
                            } else {
                                htm += "<tr style='cursor:pointer;'";
                                htm += " title='Click to View' onclick=javascript:selectOrderItem('" + item.itm_code.replace(/\s/g, '&nbsp;') + "','" + item.itm_name.replace(/\s/g, '&nbsp;') + "','" + totalqty + "','" + item.return_price + "','" + item.uniqueid + "','" + item.si_qty + "','" + item.si_foc + "','" + item.si_price + "','" + item.si_discount_rate + "','" + item.sm_id + "'); style='cursor:pointer;'><td>" + serialNo + "</td><td>" + getHighlightedValue($("#searchcustom1").val(), item.itm_code.toString()) + "</td><td>" + getHighlightedValue($("#searchcustom2").val(), item.itm_name) + "</td>";
                                htm += "<td>" + item.sm_invoice_no + "</td><td>" + totalqty + "</td><td>" + item.return_price + "</td></tr>";
                            }
                            serialNo = serialNo + 1;

                        });
                        $('#tableitemlist tbody').html(htm);
                        $("#findOrderItemDiv").show();
                    } else {
                        for (var i = 2; i < ($('#tablepos tr').length) ; i++) {
                            $('#tableitemlist > tbody > tr:gt(' + i + ')').remove();
                        }
                        $('#tableitemlist > tbody').html('<td colspan="6"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#lblReturnTotalrecords").text(0);
                        $("#findOrderItemDiv").show();
                        Unloading();
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
        function alertfunctn() {
            alert("Not enough stock for returning this item");
        }
        function popupclose(divid) {
            $("#" + divid).hide();
        }

        // start: Showing Details of selected  Item from Popup
        function selectOrderItem(item_code, item_name, quantity, saleprice,uniqueid,saledQty,foc,price,discount,orderId) {
            //alert("product_code: " + product_code + ", product_name: " + product_name + ", sales_price: " + sales_price + ", CountryId: " + CountryId + ", Tax: " + Tax + ", Discount: " + Discount);
            var html = '';

            // product_name.replace('&nbsp;',' '); 
            var rowCount = $('#tblOrderItems tr').length;
            //  alert(rowCount);


            rowid = rowCount - 3;
            rowposition = rowCount - 1;
            var currentItems = Array();
            for (i = 1; i < rowposition; i++) {
                var currentId = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(10)').text());
                currentItems.push(currentId);
            }
            for (j = 0; j < currentItems.length; j++) {
                if (currentItems[j] === uniqueid) {
                    alert("This item already selected");
                    return false;
                }
            }
            html = "<tr>";
            html = html + "<td>" + item_code + "</td>";
            html = html + "<td>" + item_name.replace(/\u00a0/g, " "); +"</td>";
            html = html + "<td> " + saledQty + "</td>";
            html = html + "<td> " + foc + "</td>";
            html = html + "<td> " + quantity + "</td>";
            html = html + "<td> " + price + "</td>";
            html = html + "<td> " + saleprice + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'ReturnQuantity'); value='1' data-quantityval='" + quantity + "'/></td>";
            html = html + "<td>"+parseFloat(saleprice)+ "</td>";
            html = html + "<td><select><option value='0'>Damaged</option><option value='1'>Convert To bulk</option><option value='2'>Ready To Use</option></select></td>";
            html = html + "<td style='display:none;'>" + uniqueid + "</td>";
            html = html + "<td style='display:none;'>" + discount + "</td>";
            html = html + "<td style='display:none;'>" + orderId + "</td>";
            html += '<td><a onclick="DeleteRaw(this);" class="btn btn-danger btn-xs"><li class="fa fa-close"></li></a></td>';
            html = html + "</tr>";
            //alert(html);
            AddNewRaw(html);
            popupclose('popupReturn');


        }
        // Stop: Showing Details of selected  Item from Popup

        function AddNewRaw(html) {
            $('#TrSum').before(html);
            totalcalculation();
        }

        function modifyValues(rowObj, changefield) {
            var rowId = $(rowObj).closest('td').parent()[0].sectionRowIndex;
            var currentstock = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').attr('data-quantityval'));
            var returnQty = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(7)').find('input').val());
            var saleprice = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(6)').text());
            if (returnQty > currentstock || returnQty == "" || returnQty==0) {
                if (returnQty > currentstock) {
                    alert("Return quantity greater than saled quantity");
                } 
                $(rowObj).addClass("err");

            } else {
                $(rowObj).removeClass("err");
                var totalcost = saleprice * returnQty;
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(8)').text(totalcost.toFixed(2));

            }
            totalcalculation();
        }
        function totalcalculation() {
            var rowCount = $('#tblOrderItems tr').length;
            if (rowCount == 2) {
                $("#txtTotalReturnAmount").text("0");

            } else {
                var lastrow = rowCount - 2;
                var net_amount = 0.00;
                for (var i = 1; i <= lastrow; i++) {
                    net_amount += parseFloat($.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(8)').text()));
                }
                //    alert(net_amount);
                $("#txtTotalReturnAmount").text(net_amount.toFixed(2));
            }
            if ($(document).find(".err").length > 0) {
                $("#divsaveReturn").css('pointer-events', 'none');
            } else {
                $("#divsaveReturn").css('pointer-events', 'auto');
            }

        }

        function DeleteRaw(ctrl) {

            $(ctrl).closest('tr').remove();
            var rowCount = parseInt($('#tblOrderItems tr').length);
            if (rowCount <= 3) {
                $("#txtTotalReturnAmount").text(0.0);

            }
            // calculteTable();
            totalcalculation();
        }

        function saveSalesReturn() {
            var tblrowCount = $('#tblOrderItems tr').length;
            if (tblrowCount <= 2) {
                alert("Please Add Item");
                return;
            }

            rowCount = tblrowCount - 2;
            //  alert(rowCount);
            if (rowCount == 0) {
                alert("select an item");
                return;
            }
            var ret_Items = '';
            for (var i = 1; i <=rowCount; i++) {
                ret_Items += "{";
                ret_Items += "'itbs_id':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(10)").text() + "',";
                ret_Items += "'sm_id':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(12)").text() + "',";
                ret_Items += "'itm_code':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(0)").text() + "',";
                ret_Items += "'itm_name':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(1)").text() + "',";
                ret_Items += "'si_price':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(6)").text() + "',";
                ret_Items += "'si_discount_rate':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(11)").text() + "',";
                ret_Items += "'sri_qty':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(7) input").val() + "',";
                ret_Items += "'sri_total':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(8)").text() + "',";
                ret_Items += "'sri_type':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(9)").find('option:selected').val() + "'";
                ret_Items += "},";
            }
            var lastChar = ret_Items.slice(-1);
            if (lastChar == ',') {
                ret_Items = ret_Items.slice(0, -1);
            }
            ret_Items = "[" + ret_Items + "]";
            console.log(ret_Items);
            var postObj = {

                return_order: {

                    cust_id: custId,
                    branchid: $.cookie("invntrystaffBranchId"),
                    return_Items: ret_Items,
                    item_count: rowCount,
                    user_id: $.cookie("invntrystaffId"),
                    description:$("#txtSpecialNote").val(),
                    session_id: sessionId
                }
            };

            loading();
           
            $.ajax({
                type: "POST",
                url: "salesreturn.aspx/sales_return",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
       
                    if (msg.d == "FAILED") {
                        alert("Error!.. Please Try Again...");
                        return;
                    }
                    else if (msg.d == "SUCCESS") {
                        alert("Selected items returned successfully...");
                        window.location = 'salesreturn.aspx?customerid=' + custId;
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

        function gotomanageorder() {
            window.location = 'manageorders.aspx?orderId=' + orderId;
        }

        function popupclose(divid) {
           // alert("");
            $("#" + divid).modal('hide');
        }
    </script>



</head>
<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">
                    <div class="navbar nav_title" style="border: 0;">
                        <a href="../index.html" class="site_title"><span>Invoice Me</span></a>
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
            <div class="top_nav">
                <div class="nav_menu">
                    <nav>

                        <div class="navbar-header" style="width: 100%; display: flex; align-items: center">
                            <div class="nav toggle" style="padding: 5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <div class="col-md-2">
                                <label style="font-weight: bold; font-size: 16px;">Sales Return</label>
                            </div>
                            <div class="col-md-10 pull-right">
                                <div class="pull-right">
                                  <label id="lblcustomerName" style="font-size:16px; padding-right:10px; color:#0879da;"></label>
                             <b>Account Balance:</b><label id="txtoutstanding" style="color: #432727; font-weight: bold; font-size: 12px; color: red;">0</label>
                                </div>
                            </div>
                          
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%--<div class="page-title">

                        <div class="title_left" style="width: 100%;">
                            <label style="font-size: 16px; font-weight: bold;">Edit Sales Order</label>
                        </div>


                    </div>--%>

                    <div class="clearfix"></div>
                    <%--<div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                            
                                  <div class="x_title" style="margin-bottom: 0px;">
                                    Order #<label id="txtBillRefNo"></label><a id="txtLabelStatus"></a>
                                    
                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>


                                    </ul>
                                </div>
                                <div class="x_content">
                                    <div class="row invoice-info">
                                        <div class="col-sm-3 invoice-col">

                                            <b>Order Date:</b>
                                            <label id="txtOrderDate">24-Feb-2017</label>


                                        </div>
                                        <!-- /.col -->
                                        <div class="col-sm-5 invoice-col">
                                            <b>Customer :</b><a style="text-decoration: underline" href="" id="hrefCustomer">#<span id="txtCustomerId"></span></a>&nbsp;<label id="lblcustomerName"></label>(class <span id="txtClassType"></span>)
                                        </div>
                                        <!-- /.col -->

                                        <div class="col-sm-3 invoice-col">
                                            <b>Account Balance:</b><label id="txtoutstanding" style="color: #432727; font-weight: bold; font-size: 12px; color: red;">0</label>
                                        </div>
                                        <!-- /.col -->

                          <input type="hidden" id="branchid" />
                                        <!-- /.col -->
                                    </div>

                                </div>
                                <div class="clear"></div>


                            </div>
                        </div>
                    </div>--%>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">

                                <div class="x_title" style="margin-bottom: 3px; padding-bottom: 0px;">
                                    <label>Return Items</label>
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

                                <div class="col-md-1 col-sm-2 col-xs-3 pull-right" style="font-size: 22px;" data-toggle="modal" data-target="#popupReturn"  onclick="javascript:resetOrderitems();">
                                    <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                    <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                </div>


                                <div class="container">

                                    <!-- Trigger the modal with a button -->
                                    <%--  <button >Open Modal</button>--%>

                                    <!-- Modal -->
                                    <div class="modal fade" id="popupReturn" role="dialog">
                                        <div class="modal-dialog modal-lg" style="width:;">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" onclick="javascript:popupclose('popupReturn');">&times;</button>
                                                    <div class="col-md-3 col-sm-6 col-xs-8">
                                                        <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblReturnTotalrecords">0</span></h4>
                                                    </div>
                                                    <div class="col-md-3 col-xs-6"></div>
                                                    <div class="col-md-9 col-sm-12 col-xs-12 pull-right">
                                                          <div class="col-md-3 col-sm-12 col-xs-3">
                                                                    <select id="selBrand" class="form-control" onchange="searchOrderitems(1);">
                                                                        <option value="0" selected="selected" taxtype="-1">--Warehouse--</option>
                                                                        <option value="2" taxtype="0">YANA SOLA</option>
                                                                        <option value="1" taxtype="0">Five star</option>
                                                                    </select>
                                                                </div>
                                                                <div class="col-md-3 col-sm-12 col-xs-3">
                                                                    <select id="selCategory" class="form-control" onchange="searchOrderitems(1);">
                                                                        <option value="0" selected="selected" taxtype="-1">--Warehouse--</option>
                                                                        <option value="2" taxtype="0">YANA SOLA</option>
                                                                        <option value="1" taxtype="0">Five star</option>
                                                                    </select>
                                                                </div>

                                                        <div class="col-md-4 col-sm-12 col-xs-12 pull-right">
                                                            <button class="btn btn-primary mybtnstyl" type="button" style="float: right;" onclick="javascript:resetOrderitems();">
                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                Reset
                                                            </button>
                                                            <button type="button" class="btn btn-success mybtnstyl" style="float: right;" onclick="javascript:searchOrderitems(1);">
                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                Search
                                                            </button>


                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                    <div class="x_content">

                                                        <table id="tableitemlist" class="table table-striped table-bordered" style="table-layout: auto;">
                                                            <thead>
                                                                <tr>
                                                                    <th>Sl.No</th>
                                                                    <th>Code</th>
                                                                    <th>Name</th>
                                                                    <th>Invoice Number</th>
                                                                    <th>Qty</th>
                                                                    <th>Amt</th>

                                                                </tr>


                                                                <tr>
                                                                    <td></td>
                                                                    <td>
                                                                        <input type="text" id="searchcustom1" class="form-control" placeholder="search" /></td>
                                                                    <td>
                                                                        <input type="text" class="form-control" placeholder="search" id="searchcustom2" /></td>

                                                                  
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
                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="tblOrderItems" class="table table-striped table-bordered" style="table-layout: auto;">

                                            <tbody>
                                                <tr>
                                                    <td>Item Code</td>
                                                    <td style="width: 300px;">Name</td>
                                                      <td>Qty</td>
                                                    <td>FOC</td>

                                                              <td>Total QTY</td>
                                                     <td>Unit Price</td>
                                                    <td>Return Price</td>
                                          
                                                    <td>Return QTY</td>
                                                    <td>Return Amount</td>
                                                    <td>Reason</td>
                                                    <td></td>

                                                </tr>




                                                <tr id="TrSum">
                                                     <td></td>
                                                     <td></td>
                                                    <td></td>
                                                     <td></td>
                                                    <td></td>
                                                     <td></td>
                                                    <td style="text-align: right;">Total</td>
                                                    <td></td>
                                                    <td id="txtTotalReturnAmount">&nbsp&nbsp;</td>
                                                    <td></td>
                                                    <td></td>

                                                </tr>

                                            </tbody>












                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 3px; padding-bottom: 0px;">
                                    <label class="pull-left">Special Notes</label>

                                    <ul class="nav navbar-right panel_toolbox pull-right">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>

                                    <div class="clearfix"></div>
                                </div>

                                <div class="x_content">
                                    <textarea class="form-control" id="txtSpecialNote" style="resize: none;"></textarea>
                                    <div class="col-md-12 col-sm-12 col-xs-12 pull-right" style="margin-top: 10px;">
                                        <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:gotomanageorder();">Cancel</button>
                                        <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:saveSalesReturn();" id="divsaveReturn">Save</button>

                                    </div>
                                </div>
                                <div class="clear"></div>


                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>

                </div>


            </div>

            <%-- popupStart --%>



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
