<%@ Page Language="C#" AutoEventWireup="true" CodeFile="waybilling.aspx.cs" Inherits="sales_waybilling" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Way Billing | Invoice Me</title>
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
        var orderId;

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
            orderId = getQueryString("orderId");
            showOrderDetails(orderId);
            $("#txtSpecialNote").val('');
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
        });

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
        //basic order details showing
        function showOrderDetails(orderId) {
            loading();
            $.ajax({
                type: "POST",
                url: "waybilling.aspx/showOrderDetails",
                data: "{'orderid':" + orderId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    console.log(msg);
                    if (msg.d != "N") {
                        var obj = JSON.parse(msg.d);

                        $("#txtCustomerId").text(obj[0].ID);
                        $("#txtBillRefNo").text(orderId);
                        if (obj[0].outstanding == null) {
                            obj[0].outstanding = 0;
                        }
                        $("#txtoutstanding").text(obj[0].outstanding);
                        if (obj[0].outstanding > 0) {
                            $("#txtoutstanding").css("color", "red");
                        } else {
                            $("#txtoutstanding").css("color", "green");
                        }
                        $("#lblcustomerName").text(obj[0].name);
                  //      $("#lblwalletamount").text(obj[0].walletamount);
                        $("#txtOrderDate").text(obj[0].date);
                        if ((obj[0].sm_delivery_vehicle_id == 0 || obj[0].sm_delivery_vehicle_id == "") && (obj[0].sm_vehicle_no == "" || obj[0].sm_vehicle_no == 0)) {
                            $("#vehiclediv").hide();
                        } else if ((obj[0].sm_delivery_vehicle_id == 0 || obj[0].sm_delivery_vehicle_id == "") && (obj[0].sm_vehicle_no != "" || obj[0].sm_vehicle_no != 0)) {
                            $("#vehiclediv").show();
                            $("#txtVehicle").text(obj[0].sm_vehicle_no);
                        } else if ((obj[0].sm_vehicle_no == "" || obj[0].sm_vehicle_no == 0) && (obj[0].sm_delivery_vehicle_id != 0 || obj[0].sm_delivery_vehicle_id != "")) {
                            $("#vehiclediv").show();
                            $("#txtVehicle").text(obj[0].vehicle_id);
                        }
                        
                        $("#branchid").val(obj[0].branch_id);
                        if (obj[0].cust_type == 1) {
                            classType = "A";
                        } else if (obj[0].cust_type == 2) {
                            classType = "B";
                        } else if (obj[0].cust_type == 3) {
                            classType = "C";
                        }
                        if (obj[0].invoiceNum != "" && obj[0].invoiceNum !== null) {
                            $("#lblInvoiceNum").text("#" + obj[0].invoiceNum);
                        }
                        $("#txtClassType").text(classType);
                        var a = document.getElementById('hrefCustomer'); //or grab it by tagname etc
                        a.href = "../managecustomers.aspx?cusId=" + obj[0].ID;
                        if (obj[0].order_status == 0) {
                            $("#txtLabelStatus").html('<span class="label label-warning" style="margin-left: 2px; margin-right: 2px; color: #fff;">New</span>');

                        } else if (obj[0].order_status == 1) {
                            $("#txtLabelStatus").html('<span class="status label label-primary" style="margin-left: 2px; margin-right: 2px; color: #fff;">Processed</span>');

                        } else if (obj[0].order_status == 2) {
                            $("#txtLabelStatus").html('<span class="status label label-success" style="margin-left: 2px; margin-right: 2px; color: #fff;">Delivered</span>');

                        }
                        else if (obj[0].order_status == 3) {
                            $("#txtLabelStatus").html('<span class="status label label-info" style="margin-left: 2px; margin-right: 2px; color: #fff;">To be confirmed</span>');
                        }
                        else if (obj[0].order_status == 4) {
                            $("#txtLabelStatus").html('<span class="status label label-danger" style="margin-left: 2px; margin-right: 2px; color: #fff;">Cancelled</span>');
                        }
                        else if (obj[0].order_status == 5) {
                            $("#txtLabelStatus").html('<span class="status label label-danger" style="margin-left: 2px; margin-right: 2px; color: #fff;">Rejected</span>');
                        }
                        else if (obj[0].order_status == 6) {
                            $("#txtLabelStatus").html('<span class="status label label-default" style="margin-left: 2px; margin-right: 2px; color: #fff;">Pending</span>');
                        }
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

        function popupclose(divid) {
            $("#" + divid).modal('hide');
            $('body').removeClass('modal-open');
            $('.modal-backdrop').remove();
            // $("#" + divid).hide();
        }

        function resetOrderitems() {
            $("#searchcustom1").val("");
            $("#searchcustom2").val("");
            searchOrderitems(1);
        }

        function searchOrderitems(page) {
            var orderNo = orderId;
            var itemcode = $("#searchcustom1").val();
            var itemname = $("#searchcustom2").val();

            loading();
            var json_req = { orderid: orderNo, itemcode: itemcode, itemname: itemname };
            $.ajax({
                type: "POST",
                url: "waybilling.aspx/searchOrderitems",
                data: JSON.stringify(json_req),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != "N") {
                        var itemdetails = JSON.parse(msg.d);
                        console.log(itemdetails);
                        var htm = "";
                        $("#lblTransfertotalrecords").text($(itemdetails).length);
                        //  htm += "<tr><td colspan='7'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + $(itemdetails).length + "</span></div></td> </tr>";
                        var serialNo = 1;
                        $.each(itemdetails, function (index, item) {
                            console.log(index);
                            if (item.totalqty == 0) {
                                htm += "<tr style='cursor:pointer;'";
                                htm += " title='Click to View' onclick=javascript:alertfunctn(); style='cursor:pointer;' alt='Working'><td>" + serialNo + "</td><td>" + item.itm_code + "</td><td>" + item.itm_name + "</td>";
                                htm += "<td>" + item.totalqty + "</td></tr>";
                            } else {
                                htm += "<tr style='cursor:pointer;'";
                                htm += " title='Click to View' onclick=javascript:selectOrderItem('" + item.itm_code.replace(/\s/g, '&nbsp;') + "','" + item.itm_name.replace(/\s/g, '&nbsp;') + "','" + item.totalqty + "','" + item.uniqueid + "'); style='cursor:pointer;'><td>" + serialNo + "</td><td>" + getHighlightedValue(itemcode, item.itm_code.toString()) + "</td><td>" + getHighlightedValue(itemname, item.itm_name) + "</td>";
                                htm += "<td>" + item.totalqty + "</td></tr>";
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
                        $("#lblTransfertotalrecords").text(0);
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
            alert("Not enough stock for transfering this item");
        }

        function selectOrderItem(item_code, item_name, quantity, uniqueid) {
            var html = '';
            var rowCount = $('#tblOrderItems tr').length;
            rowposition = rowCount - 1;
            var currentItems = Array();
            for (i = 0; i < rowposition; i++) {
                var currentId = $.trim($('#tblOrderItems tr:eq(' + i + ') td:eq(4)').text());
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
            html = html + "<td> " + quantity + "</td>";
            html = html + "<td><input type='text' onkeyup=modifyValues(this,'TransferQuantity'); class='number-only textwidth' value='1' data-quantityval='" + quantity + "'  /></td>";
            html = html + "<td style='display:none;'>" + uniqueid + "</td>";
            html += '<td><a onclick="DeleteRaw(this);" class="btn btn-danger btn-xs"><li class="fa fa-close"></li></a></td>';
            html = html + "</tr>";
            $('#TrSum').before(html);
            popupclose('popupWayBill');
        }

        function modifyValues(rowObj, changefield) {
            //start check number only
            $('.number-only').keyup(function (e) {
             // this.value = this.value.replace(/\D/g, '');
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
            var rowId = $(rowObj).closest('td').parent()[0].sectionRowIndex;
            var currentstock = parseFloat($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').attr('data-quantityval'));
            var transferQty = $.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val());
            var regexqty = new RegExp(/^\+?[0-9(),]+$/);
            if (transferQty.match(regexqty)) {

            }
            else {
                var newVal1 = transferQty.toString();
                var newVal = newVal1.substr(0, newVal1.length - 1);
                transferQty = parseInt($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val()));
                $('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val(newVal);
            }
            if (transferQty > currentstock || transferQty == "" || transferQty == 0) {
                if (transferQty > currentstock) {
                    alert("Transfer quantity greater than saled quantity");
                    $(rowObj).addClass("err");
                    $("#divsaveTransfer").css('pointer-events', 'none');
                    $("#divprintTransfer").css('pointer-events', 'none');
                    return;
                } else {
                    $("#divsaveTransfer").css('pointer-events', '');
                    $("#divprintTransfer").css('pointer-events', '');
                }
                $(rowObj).addClass("err");

            } else {
                $(rowObj).removeClass("err");
            }
            if (changefield == "TransferQuantity") {
                if (transferQty == "" || transferQty == 0) {
                    $(rowObj).addClass("err");
                    $("#divsaveTransfer").css('pointer-events', 'none');
                    $("#divprintTransfer").css('pointer-events', 'none');
                    return;
                } else {
                    $("#divsaveTransfer").css('pointer-events', '');
                    $("#divprintTransfer").css('pointer-events', '');
                }
                transferQty = parseFloat($.trim($('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val()));

                if (isNaN(transferQty) == true) {
                    // alert("Check Quantity..!");
                    $('#tblOrderItems tr:eq(' + rowId + ') td:eq(3)').find('input').val("1");
                    return false;
                }
                else {
                    $(rowObj).removeClass("err");
                }
            }
        }

        function DeleteRaw(ctrl) {
            bootbox.confirm("Are you sure you want to delete this item?", function (result) {
                console.log(result)
                if (result) {
                    $(ctrl).closest('tr').remove();
                } else {
                    bootbox.hideAll()
                }
            });
        }

        function gotomanageorder() {
            window.location = 'manageorders.aspx?orderId=' + orderId;
        }

        function saveWayBilling(take_print) {
            sqlInjection();
            var tblrowCount = $('#tblOrderItems tr').length;
            if (tblrowCount <= 2) {
                alert("Please Add Item");
                return;
            }
            var way_description = $("#txtSpecialNote").val();
            rowCount = tblrowCount - 2;
            //  alert(rowCount);
            if (rowCount == 0) {
                alert("select an item");
                return;
            }
            var trans_Items = '';
            for (var i = 1; i <= rowCount; i++) {
                trans_Items += "{";
                trans_Items += "'itbs_id':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(4)").text() + "',";
                trans_Items += "'si_transfer_qty':'" + $("#tblOrderItems tr:eq(" + i + ") td:eq(3) input").val() + "',";
                trans_Items += "},";
            }
            var lastChar = trans_Items.slice(-1);
            if (lastChar == ',') {
                transfer_Items = trans_Items.slice(0, -1);
            }
            trans_Items = "[" + trans_Items + "]";
            console.log(trans_Items);
            var postObj = {

                transfer_order: {

                    sm_id: $("#txtBillRefNo").text(),
                    cust_id: $("#txtCustomerId").text(),
                    branchid: $("#branchid").val(),
                    transfer_by: $.cookie("invntrystaffId"),
                    item_count: rowCount,
                    description: way_description,
                    transfer_Items: trans_Items
                }

            };

            loading();

            $.ajax({
                type: "POST",
                url: "waybilling.aspx/saveWayBilling",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj.headerid);
                    console.log(obj.result);
                    if (obj.result == "FAILED") {
                        alert("Error!.. Please Try Again...");
                        return;
                    }
                    else if (obj.result == "SUCCESS") {
                        if (take_print) {
                            //window.location.href = "waybillreceipt.aspx?orderId=" + orderId;
                            window.location.href = "waybillreceipt.aspx?orderId=" + orderId + "&headerid=" + obj.headerid;
                        }
                        else {
                            alert("Way Bill Saved successfully...");
                            $("#txtSpecialNote").val('');
                            //window.location.reload();
                            window.location = 'manageorders.aspx?orderId=' + orderId;
                        }
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
            <div class="top_nav">
                <div class="nav_menu">
                    <nav>

                        <div class="navbar-header" style="width: 100%; display: flex; align-items: center">
                            <div class="nav toggle" style="padding: 5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <label style="font-weight: bold; font-size: 16px;">Way Billing</label>

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
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">

                                <div class="x_title" style="margin-bottom: 0px;">
                                    <%--Order #<label id="txtBillRefNo"></label><a id="txtLabelStatus"></a>--%>
                                    Order<label id="lblInvoiceNum"></label> (<label id="txtBillRefNo"></label>)<a id="txtLabelStatus"></a>

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
                                        <div class="col-sm-3 invoice-col">
                                            <b>Customer :</b><a style="text-decoration: underline" href="" target="_blank" id="hrefCustomer">#<span id="txtCustomerId"></span></a>&nbsp;<label id="lblcustomerName"></label>(class <span id="txtClassType"></span>)
                                        </div>
                                        <!-- /.col -->

                                      
                                        <div class="col-sm-2 invoice-col">
                                            <b>Account Balance:</b><label id="txtoutstanding" style="color: #432727; font-weight: bold; font-size: 12px; color: red;">0</label>
                                        </div>

                                        <div class="col-sm-2 invoice-col" style="display:none;" id="vehiclediv">
                                            <b>Vehicle:</b><label id="txtVehicle" style="color: #0026ff; font-weight: bold; font-size: 12px;"></label>
                                        </div>
                                        <!-- /.col -->

                                        <input type="hidden" id="branchid" />
                                        <!-- /.col -->
                                    </div>

                                </div>
                                <div class="clear"></div>


                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">

                                <div class="x_title" style="margin-bottom: 3px; padding-bottom: 0px;">
                                    <label>Items List</label>
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

                                <div class="col-md-1 col-sm-2 col-xs-3 pull-right" style="font-size: 22px;" data-toggle="modal" data-target="#popupWayBill" data-backdrop="static" data-keyboard="false" onclick="javascript:resetOrderitems();">
                                    <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                    <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>

                                </div>
                                <div class="container">
                                    <div class="modal fade" id="popupWayBill" role="dialog">
                                        <%-- --%>
                                        <div class="modal-dialog modal-lg" style="font-size: 12px;">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                                    <%-- onclick="javascript:popupclose('popupWayBill');" --%>
                                                    <%-- data-dismiss="modal" --%>
                                                    <div class="col-md-3 col-sm-6 col-xs-8">
                                                        <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTransfertotalrecords">0</span></h4>
                                                    </div>
                                                    <div class="col-md-3 col-xs-6"></div>
                                                    <div class="col-md-6 col-sm-12 col-xs-12 pull-right">


                                                        <div class="col-md-12 col-sm-12 col-xs-12 pull-right">
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
                                                                    <th>Available Qty</th>
                                                                </tr>


                                                                <tr>
                                                                    <td></td>
                                                                    <td>
                                                                        <input type="text" id="searchcustom1" class="form-control" placeholder="search" /></td>
                                                                    <td>
                                                                        <input type="text" class="form-control" placeholder="search" id="searchcustom2" /></td>


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
                                                    <td>Available Qty</td>
                                                    <td>Transfer Qty</td>
                                                    <td></td>
                                                </tr>




                                                <tr id="TrSum" style="display: none;">
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
                                        <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:saveWayBilling(false);" id="divsaveTransfer">Save</button>
                                        <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:saveWayBilling(true);" id="divprintTransfer">Save & Print</button>

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
