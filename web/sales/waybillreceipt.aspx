<%@ Page Language="C#" AutoEventWireup="true" CodeFile="waybillreceipt.aspx.cs" Inherits="sales_waybillreceipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Styles-->
    <link href="../css/bootstrap/mystyle.css" type="text/css" rel="stylesheet" />

    <style media="print">
        @page {
            size: auto;
            margin: 0;
        }

        thead {
            display: table-header-group;
        }
    </style>
    <script type="text/javascript">
        var j = 1;
        $(document).ready(function () {
            showWayBillReceipt();  
        });


        function showWayBillReceipt() {
            var billno = getQueryString("orderId");
            var headerid = getQueryString("headerid");
            // alert(billno);
            if (!billno || billno == "" || billno == 0) {
                location.href = "../login.aspx";
                return false;
            }

            loading();
            $.ajax({
                type: "POST",
                url: "waybillreceipt.aspx/showWayBillReceipt",
                data: "{'billno':'" + billno + "','headerid':'" + headerid + "'}",
                contentType: "application/json; charset=utf-8",
                datatype: "json",
                success: function (msg) {

                    var htm = "";
                    //showing div
                    $("#divReceiptDetails").show();
                    Unloading();
                    // console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    $("#hdnorederid").val(obj.order[0].sm_id);
                    // setting order details

                    // adding order items
                    var sl_no = 0;
                    $.each(obj.items, function (i, row) {
                        // console.log(obj.itemheader[0].date);
                        htm = "";
                        if (sl_no % 31 == 0 && sl_no != 0) {
                            htm += "<tr><td colspan='12' style='text-align:right; font-weight:bold;'></br></br>Continue...</br></br></td></tr>";
                            htm += "<tr><td colspan='12' style='text-align:right; font-weight:bold;border-left:1px solid #fff;border-right:1px solid #fff;padding-top:30px;'><div style='width: 150px; margin: auto; font-weight: bold; font-size: 16px;'>Waying Bill</div></td></tr>";
                            htm += "<tr><td colspan='12' style='border-top:none;'><div style='width: 100%; border: 1px solid #73879c; border-left:none;border-right:none;border-bottom:none;border-top:none;'><div style='width: 50%; float: left;'><div style='width: 100%; float: left; padding: 10px; border-right: 1px solid #73879c; border-bottom: 1px solid #73879c;'><div style='font-weight: bold;'>" + obj.branch[0].branch_name + "</div><div>" + obj.branch[0].branch_address + "</div>";
                            htm += '<div>' + obj.branch[0].branch_country_name + '</div><div>Email:<span>' + obj.branch[0].branch_email + '</span></div></div>';
                            htm += '<div style="width: 100%; padding: 10px; border-right: 1px solid #73879c;">';
                            htm += '<div>Buyer</div><div><label for="">' + obj.order[0].cust_name + '</label></div><div>' + obj.order[0].address + '</div><div><span>' + obj.order[0].city + '</span>&nbsp&nbsp<span>' + obj.order[0].state + '</span></div>';
                            htm += '<div style="display: none;" id="spanemail">Email:<span>' + obj.order[0].email + '</span></div></div></div>';
                            htm += '<div style="float: left; width: 50%; border-left: none; padding: 10px;"><table style="width: 100%;"><tr style="border-bottom: 1px solid #73879c;"><td>Invoice No.<br />';
                            //alert(obj.order[0].invoiceNum);
                            if (obj.order[0].invoiceNum != "" && obj.order[0].invoiceNum !== null) {
                                htm += '<label id="lblInvoiceNum' + j + '">#' + obj.order[0].invoiceNum + '</label><label id="lblOrderId' + j + '">(' + obj.order[0].sm_refno + ')</label></td><td>Dated<br />';
                            }
                            else {
                                htm += '<label id="lblOrderId' + j + '">(' + obj.order[0].sm_refno + ')</label></td><td>Dated<br />';
                            }
                            htm += '<label>' + obj.order[0].date + '</label></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Delivery Note<br /></td><td>Mode/Term of Payments<br /></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Suppliers Ref.<br/></td><td>Other Ref.<br /></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Buyers Order No.<br /></td><td>Dated<br /></td></tr>';
                            htm += '<tr><td colspan="2">Terms of Delivery<br /></td></tr></table></div><div style="clear: both;"></div></div></td></tr>';
                            htm += "<tr><td colspan='12' style='height:20px;border-left:1px solid #fff;border-right:1px solid #fff;'></td></tr>";

                            htm += '<tr>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">No</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Item Name</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Qty</td>';;
                            htm += '</tr>';
                            j++

                        }
                        sl_no++;

                        htm += '<tr>';
                        htm += '<td class="tablefont" style="text-align:center;">' + sl_no + '</td>';
                        htm += '<td class="tablefont" style="text-align:left; padding-left:5px;">' + row.itm_name + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.stock + '</td>';
                        htm += '</tr>';

                        $("#tblOrderDetailsTbody").append(htm);

                    });
                    //  alert(obj.branch[0].branch_declaration);
                    if ((obj.branch[0].branch_declaration) != "" && (obj.branch[0].branch_declaration) !== null) {
                        $("#tblDeclaration").show();
                        $("#divDeclaration").html(obj.branch[0].branch_declaration);
                    }
                    $("#lblCusId").text(obj.order[0].cust_id);
                    $("#lblCusName").text(obj.order[0].cust_name);
                    $("#lblAddress").text(obj.order[0].address);
                    $("#spanCity").text(obj.order[0].city);
                    $("#spanState").text(obj.order[0].state);
                  //  alert(obj.Vehicle[0].sm_vehicle_no);
                    if (obj.Vehicle[0].sm_vehicle_no != (null || "0" || "")) {
                        $("#lblvehicle").text(obj.Vehicle[0].sm_vehicle_no);
                    } else {
                        $("#lblvehicle").text(obj.Vehicle[0].vehicle_name);
                    }

                    if (obj.order[0].phone != "") {
                        $("#spanmob").show();
                        $("#lblMobilenum").text(obj.order[0].phone);
                    } else {
                        $("#spanmob").hide();
                        $("#lblMobilenum").text("");
                    }
                    if (obj.order[0].email != "") {
                        $("#spanemail").show();
                        $("#lblEmailId").text(obj.order[0].email);
                    } else {
                        $("#spanemail").hide();
                        $("#lblEmailId").text("");
                    }
                    if (obj.order[0].sm_refno != "") {
                        $("#lblOrderId0").text("(" + obj.order[0].sm_refno + ")");
                    }
                    if (obj.order[0].invoiceNum != "" && obj.order[0].invoiceNum !== null) {
                        $("#lblInvoiceNum0").text("#" + obj.order[0].invoiceNum + "");
                    }
                    $("#lblOrderDate").text(obj.order[0].date);
                    $("#lblWarehouse").text(obj.branch[0].branch_name);
                    $("#lblBillDisclosure").html(obj.branch[0].branch_bill_disclosure);
                    $("#divBranchAddress").html(obj.branch[0].branch_address);
                    $("#divBranchCountry").html(obj.branch[0].branch_country_name);
                    $("#divBranchEmail").html(obj.branch[0].branch_email);
                    $("#lblStaffNam").text(obj.order[0].staff_name);
                    $("#imgLogo").attr("src", "../logoImage/" + obj.branch[0].branch_image);
                    //  sendPdfmail(billno);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                    return false;
                }

            });
        }
        function printReceipt() {
            //alert(j);
            $("#divBack").hide();
            $("#divPrint").hide();
            $("#divPayment").hide();
            $("#divPaymentDetails").hide();
            $("#divReturnDetails").hide();
            for (i = 0; i <= j; i++) {
                $("#lblOrderId" + i).hide();
            }

            window.print();
            $("#divBack").show();
            $("#divPrint").show();
            $("#divPayment").show();
            $("#divPaymentDetails").show();
            $("#divReturnDetails").show();
            for (i = 0; i <= j; i++) {
                $("#lblOrderId" + i).show();
            }
        }

        function backPressed() {
            var orderid = $("#hdnorederid").val();
            window.location.href = "manageorders.aspx?orderId=" + orderid;
        //window.history.back();
        }
    </script>
    <style type="text/css">
        body {
            background: #ffffff;
        }
    </style>

</head>

<body>

    <form id="form1" runat="server">

        <!-- Start div For loading image-->

        <div id="loading" style="background-repeat: no-repeat; margin: auto; height: 100%; display: none">
            <div align="center" style="margin: auto">
                <img id="loading-image" src="../images/loader.gif" alt="Loading..." />
            </div>
        </div>

        <!-- End div For loading image-->

        <!--Main Div Starts Here-->

        <div class="mainDiv" style="padding: 10px; padding-left: 30px; padding-right: 30px;">

            <!----Start Logo Div Here--->
            <div class="cl"></div>
            <div class="space1"></div>
            <div style="height: 20px">
                <div id="divBack" class="recbtn fl" onclick="javascript:backPressed();" style="cursor: pointer">
                    <img src="../images/backreceipt.png" width="20" height="16" class="fl" style="margin-right: 3px;" />
                    <div class="backbtntext fl" style="line-height: 18px;">Back</div>
                </div>
                <!-- <div id="logoDiv" class="logoDivs fl" style="margin-left:300px; position:absolute;">
                        <img src="../images/logo.png" />
                    </div> -->
                <div id="divPrint" class="recbtn fr" onclick="javascript:printReceipt();" style="cursor: pointer;">
                    <img src="../images/print.png" width="20" height="20" class="fl" style="margin-left: 8px; margin-right: 3px;" />
                    <div class="backbtntext fl">Print</div>
                </div>

            </div>
            <%--     <div class="logoDiv" style="width:100%;">
                <div style="margin:auto;width:100px; ">
                <img src="" style="width:100px; height:64px;" id="imgLogo" /></div></div>
            <div class="cl"></div>
            <div class="spaceDiv"></div>--%>
            <!----End Logo Div Here--->
            <div style="width: 100%">
                <div style="width: 100%;">
                    <div style="width: 150px; margin: auto; font-weight: bold; font-size: 16px;">Way Billing</div>
                </div>
                <div style="width: 100%; border: 1px solid #73879c;">
                    <div style="width: 50%; float: left;">
                        <div style="width: 100%; float: left; padding: 10px; border-right: 1px solid #73879c; border-bottom: 1px solid #73879c;">
                            <div style="font-weight: bold;" id="lblWarehouse"></div>
                            <div id="divBranchAddress"></div>
                            <div id="divBranchCountry"></div>

                            <div>Email:<span id="divBranchEmail"></span></div>
                        </div>
                        <div style="width: 100%; padding: 10px; border-right: 1px solid #73879c;">
                            <div>Buyer</div>
                            <div>
                                <label for="" id="lblCusName"></label>
                            </div>
                            <div id="lblAddress"></div>
                            <div><span id="spanCity">SELAM</span>&nbsp&nbsp<span id="spanState"></span></div>

                            <div style="display: none;" id="spanemail">Email:<span id="lblEmailId"></span></div>
                        </div>
                    </div>
                    <div style="float: left; width: 50%; border-left: none; padding: 10px;">
                        <table style="width: 100%;">
                            <tr style="border-bottom: 1px solid #73879c;">
                                <td>Invoice No.<br />
                                    <label id="lblInvoiceNum0"></label>
                                    <label id="lblOrderId0"></label>
                                </td>
                                <td>Dated<br />
                                    <label id="lblOrderDate"></label>
                                </td>
                            </tr>
                            <tr style="border-bottom: 1px solid #73879c;">
                                <td>Delivery Note<br />
                                </td>
                                <td>Mode/Term of Payments<br />
                                </td>
                            </tr>
                            <tr style="border-bottom: 1px solid #73879c;">
                                <td>Supplier's Ref.<br />
                                </td>
                                <td>Other Ref.<br />
                                </td>
                            </tr>
                            <tr style="border-bottom: 1px solid #73879c;">
                                <td>Vehicle:<label id="lblvehicle">1234</label><br />
                                </td>
                                <td>Dated<br />
                                </td>
                            </tr>

                            <tr>
                                <td colspan="2">Terms of Delivery<br />
                                </td>

                            </tr>
                        </table>
                    </div>
                    <div style="clear: both;"></div>
                </div>
                <div style="clear: both;"></div>

                <div style="width: 100%;" id="divReceiptDetails">

                    <div class="details" style="margin-top: 15px; display: ;">


                        <div style="clear: both;"></div>
                        <table id="tblOrderDetails" style="margin-top: 8px; margin-bottom: 8px;" cellspacing="0" cellpadding="0" border="1" width="100%">
                            <tr>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">No</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">Item Name</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">Qty</td>
                            </tr>


                            <tbody id="tblOrderDetailsTbody">
                            </tbody>
                        </table>
                        <div class="cl"></div>
                        <div style="width: 100%;"></div>

                        <table style="width: 100%; display: none;" id="tblDeclaration">
                            <tr>
                                <td>
                                    <div style="width: 100%; border: 1px solid #000000; padding: 5px;">
                                        <div style="width: 50%; float: left;">
                                            <u>Declaration</u>
                                            <div id="divDeclaration">
                                            </div>
                                        </div>
                                        <div class="clearfix"></div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <table class="fl">
                            <tbody>
                                <tr>
                                    <td style="font-weight: bold">
                                        <div for="" id="lblBillDisclosure"></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="font-weight: bold">SS:
                                <label for="" id="lblStaffNam"></label>
                                    </td>
                                </tr>
                                <tr></tr>
                                <tr>
                                    <td style="font-weight: bold">Client's Signature____________</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                </div>
                <input type="hidden" id="hdnorederid"/>
            </div>
            <!--Main Div Starts Here-->
    </form>
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

</body>
</html>
