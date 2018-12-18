<%@ Page Language="C#" AutoEventWireup="true" CodeFile="billreceipt.aspx.cs" Inherits="billreceipt" %>

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
        @page
        {
            size: auto;
            margin: 0;
        }

        thead
        {
            display: table-header-group;
        }
    </style>

    <script type="text/javascript">
        var j = 1;
        $(document).ready(function () {
            showBillReceipt();


        });

        function sendPdfmail(billno) {
            //var jSon = JSON.stringify({ htm: $("#divReceiptDetails").html() });
            //,'mailid': 'fredpjoseph@yahoo.com'
            //billreceipt.aspx/SendPDFAttchedMail

            //alert(jSon);
            $.ajax({
                type: "POST",
                url: "../wm/sendpdfmail.asmx/sendmail",
                data: "{'billno':'" + billno + "','email':'testp7741@gmail.com'}",
                contentType: "application/json; charset=utf-8",
                datatype: "json",
                success: function (msg) {
                    //alert(msg.d)
                },
                error: function (xhr, status) {
                    alert(status);
                }

            });
        }

        function showBillReceipt() {
            var billno = getQueryString("orderId");
            // alert(billno);
            if (!billno || billno == "" || billno == 0) {
                location.href = "../login.aspx";
                return false;
            }

            loading();
            $.ajax({
                type: "POST",
                url: "billreceipt.aspx/showBillReceipt",
                data: "{'billno':'" + billno + "'}",
                contentType: "application/json; charset=utf-8",
                datatype: "json",
                success: function (msg) {

                    var htm = "";
                    //showing div
                    $("#divReceiptDetails").show();
                    Unloading();
                    // console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    // console.log(obj);
                    // setting order details

                    // adding order items
                    var sl_no = 0;
                    $.each(obj.items, function (i, row) {
                        htm = "";
                        if (sl_no % 31 == 0 && sl_no != 0) {
                            htm += "<tr><td colspan='12' style='text-align:right; font-weight:bold;'></br></br>Continue...</br></br></td></tr>";
                            htm += "<tr><td colspan='12' style='text-align:right; font-weight:bold;border-left:1px solid #fff;border-right:1px solid #fff;padding-top:30px;'><div style='width: 150px; margin: auto; font-weight: bold; font-size: 16px;'>Invoice</div></td></tr>";
                            htm += "<tr><td colspan='12' style='border-top:none;'><div style='width: 100%; border: 1px solid #73879c; border-left:none;border-right:none;border-bottom:none;border-top:none;'><div style='width: 50%; float: left;'><div style='width: 100%; float: left; padding: 10px; border-right: 1px solid #73879c; border-bottom: 1px solid #73879c;'><div style='font-weight: bold;'>" + obj.branch[0].branch_name + "</div><div>" + obj.branch[0].branch_address + "</div>";
                            htm += '<div>' + obj.branch[0].branch_country_name + '</div><div>Email:<span>' + obj.branch[0].branch_email + '</span></div></div>';
                            htm += '<div style="width: 100%; padding: 10px; border-right: 1px solid #73879c;">';
                            htm += '<div>Buyer</div><div><label for="">' + obj.order[0].cust_name + '</label></div><div>' + obj.order[0].address + '</div><div><span>' + obj.order[0].city + '</span>&nbsp&nbsp<span>' + obj.order[0].state + '</span></div>';
                            htm += '<div style="display: none;" id="spanemail">Email:<span>' + obj.order[0].email + '</span></div></div></div>';
                            htm += '<div style="float: left; width: 50%; border-left: none; padding: 10px;"><table style="width: 100%;"><tr style="border-bottom: 1px solid #73879c;"><td>Invoice No.<br />';

                            if (obj.order[0].invoiceNum != "" && obj.order[0].invoiceNum !== null) {
                                htm += '<label id="lblInvoiceNum' + j + '">#' + obj.order[0].invoiceNum + '</label><label id="lblOrderId' + j + '">(' + obj.order[0].sm_refno + ')</label></td><td>Dated<br />';
                            }
                            else {
                                htm += '<label id="lblOrderId' + j + '">(' + obj.order[0].sm_refno + ')</label></td><td>Dated<br />';
                            }
                            htm += '<label>' + obj.order[0].sm_date + '</label></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Delivery Note<br /></td><td>Mode/Term of Payments<br /></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Suppliers Ref.<br/></td><td>Other Ref.<br /></td></tr>';
                            htm += '<tr style="border-bottom: 1px solid #73879c;"><td>Buyers Order No.<br /></td><td>Dated<br /></td></tr>';
                            htm += '<tr><td colspan="2">Terms of Delivery<br /></td></tr></table></div><div style="clear: both;"></div></div></td></tr>';
                            htm += "<tr><td colspan='12' style='height:20px;border-left:1px solid #fff;border-right:1px solid #fff;'></td></tr>";

                            htm += '<tr>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">No</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Item Name</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Qty</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">FOC</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Price</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; text-align: center;" class="tablefonthead">Amt</td>';
                            htm += '<td style="text-align: center; font-size: 12px;" class=""><span style="font-weight: bold;">Disc</span>';
                            htm += '<table width="100%" cellspacing="0" cellpadding="0">';
                            htm += '<tbody>';
                            htm += '<tr>';
                            htm += '<td style="width: 50%;" class="tablefonthead bordertopbot">%</td>';
                            htm += '<td class="tablefonthead bodertopleft">Amt</td>';
                            htm += '</tr>';
                            htm += '</tbody>';
                            htm += '</table>';
                            htm += '</td>';
                            htm += '<td style="font-weight: bold; font-size: 12px; width: 70px; text-align: center" class="tablefonthead">Net Amt</td>';
                            htm += '</tr>';
                            j++

                        }
                        sl_no++;

                        htm += '<tr>';
                        htm += '<td class="tablefont" style="text-align:center;">' + sl_no + '</td>';
                        htm += '<td class="tablefont" style="text-align:left; padding-left:5px;">' + row.itm_name + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.qty + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.foc + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.price + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.si_total + '</td>';
                        htm += '<td>';
                        htm += '<table cellspacing="0" cellpadding="0" width="100%">';
                        htm += '<tbody>';
                        htm += '<tr>';
                        htm += '<td class="tablefont" style="text-align:center;border-right:1px solid #000;width:50%;">' + row.dis_rate + '</td>';
                        htm += '<td class="tablefont" style="text-align:center;width:50%;">' + row.dis_amount + '</td>';
                        htm += '</tr>';
                        htm += '</tbody>';
                        htm += '</table>';
                        htm += '<td class="tablefont" style="text-align:center;">' + row.net_amount + '</td>';
                        htm += '</tr>';

                        $("#tblOrderDetailsTbody").append(htm);

                    });
                    // adding payment details
                    $.each(obj.payment_details, function (i, row) {
                        htm = "";
                        var htmPaymentDetails = '<tr>';
                        htmPaymentDetails += '<td>#' + row.id + '</td>';
                        htmPaymentDetails += '<td>' + row.date + '</td>';
                        htmPaymentDetails += '<td>' + row.narration + '</td>';
                        htmPaymentDetails += '<td>' + row.user_name + '</td>';
                        htmPaymentDetails += '<td>' + (row.dr != 0 ? row.dr + " Dr" : (row.cr != 0 ? row.cr + " Cr" : 0)) + '</td>';
                        htmPaymentDetails += '<td>' + row.closing_balance + '</td>';
                        htmPaymentDetails += '</tr>';

                        $("#tblPaymentDetails > tbody").append(htmPaymentDetails);
                    });
                    //adding return details
                    if (obj.return_details.length == 0) {
                        $("#divReturnDetails").hide();
                    }
                    // console.log(obj.return_details);
                    sl_no = 0;
                    $.each(obj.return_details, function (i, row) {
                        console.log(row);
                        htm = "";
                        $.each(row.items, function (k, item) {
                            sl_no++;
                            htm += '<tr>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + sl_no + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.itm_code + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.itm_name + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.qty + '</td>';
                            // htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.foc + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.price + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.discount + '</td>';
                            htm += '<td class="tablefonthead" style="font-weight:bold; font-size:12px;">' + item.total + '</td>';
                            htm += '</tr>';
                        });
                        htm += '<tr>';
                        htm += '<td colspan="7">';
                        htm += '<div style="width:100%;">';
                        htm += '<div style="display:inline-block;margin-left:10px;float:left">';
                        htm += '<span style="font-weight:bold;">Date : </span><label for="" id="">' + row.date + '</label><br/>';
                        htm += '</div>';
                        htm += '<div style="display:inline-block;margin-rght:10px;float:right">';
                        htm += '<span style="font-weight:bold;">Net Amount : </span><label for="" id="">' + row.amount + '</label><br/>';
                        htm += '</div>';
                        htm += '</div>';
                        htm += '<div class="space cl"></div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#tblReturnDetails > tbody").append(htm);




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


                    //    $("#spanCountry").text(obj.order[0].country);
                    if (obj.order[0].sm_payment_type == "" || obj.order[0].sm_payment_type == 0) {
                        $("#spanPaymentMode").hide();
                        $("#lblPaymentMode").text("");
                    } else {
                        $("#spanPaymentMode").show();
                    }
                    if (obj.order[0].sm_payment_type == 1) {
                        $("#lblPaymentMode").text("Cash");
                    } else if (obj.order[0].sm_payment_type == 2) {
                        $("#lblPaymentMode").text("Credit");
                    } else if (obj.order[0].sm_payment_type == 3) {
                        $("#lblPaymentMode").text("Bill to bill");
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
                    if (obj.order[0].invoiceNum != "" && obj.order[0].invoiceNum != null) {
                        $("#lblInvoiceNum0").text("#" + obj.order[0].invoiceNum + "");
                    }
                    $("#lblOrderDate").text(obj.order[0].sm_date);
                    $("#lblWarehouse").text(obj.branch[0].branch_name);
                    $("#lblBillDisclosure").html(obj.branch[0].branch_bill_disclosure);
                    $("#divBranchAddress").html(obj.branch[0].branch_address);
                    $("#divBranchCountry").html(obj.branch[0].branch_country_name);
                    $("#divBranchEmail").html(obj.branch[0].branch_email);
                    $("#lblStaffNam").text(obj.order[0].staff_name);
                    $("#lblNetAmount").text(obj.order[0].net_amount);
                    $("#lblTotalAmount").text(obj.order[0].total);
                    $("#lblTotalTaxAmount").text(obj.order[0].tax);
                    $("#lblTotalDiscAmount").text(obj.order[0].discAmt);
                    $("#lblPaidAmount").text(obj.order[0].total_paid);
                    $("#lblBalanceAmount").text(obj.order[0].total_balance);
                    $("#imgLogo").attr("src", "../logoImage/" + obj.branch[0].branch_image);
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
                $("#lblOrderId"+i).hide();
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
            window.history.back();

        }
    </script>
    <style type="text/css">
        body
        {
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
                    <div style="width: 150px; margin: auto; font-weight: bold; font-size: 16px;">Invoice</div>
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
                                <td>Buyer's Order No.<br />
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
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">FOC</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">Price</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">Amt</td>
                                <td class="" style="text-align: center; font-size: 12px;"><span style="font-weight: bold;">Disc</span>
                                    <table cellspacing="0" cellpadding="0" width="100%">
                                        <tbody>
                                            <tr>
                                                <td class="tablefonthead bordertopbot" style="width: 50%;">%</td>
                                                <td class="tablefonthead bodertopleft">Amt</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>

                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; width: 70px; text-align: center">Net Amt</td>
                                <!-- <td class='tablefonthead'>Paid.Amt</td>-->
                            </tr>


                            <tbody id="tblOrderDetailsTbody">
                            </tbody>

                            <tbody id="tbodyPayments">


                                <tr>
                                   
                                    <td style="text-align: right; padding-right: 10px;" colspan="5"><b>TOTAL</b></td>

                                    <td style="text-align: center">
                                        <label id="lblTotalAmount">250</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalDiscAmount">--</label></td>

                                    <td style="text-align: center">
                                        <label id="lblNetAmount">--</label></td>
                                </tr>

                            </tbody>
                        </table>

                        <div style="width: 100%; text-align: right;" id="divPayment">
                            <div style="display: inline-block; margin-right: 10px;">

                                <span style="font-weight: bold;">Paid Amount : </span>
                                <label for="" id="lblPaidAmount">18.00</label><br />
                                <span style="font-weight: bold;">Balance Amount : </span>
                                <label for="" id="lblBalanceAmount">18.00</label><br />
                            </div>
                        </div>
                        <div id="divPaymentDetails" style="width: 100%">
                            <div style="width: 100%; border: 1px solid #000000;"></div>
                            <span style="font-weight: bold;">Payment details</span>
                            <div class="cl"></div>
                            <table id="tblPaymentDetails" style="margin-top: 8px; margin-bottom: 8px;" cellspacing="0" cellpadding="0" border="1" width="100%">
                                            <thead>
                                                <tr>
                                                    <th>Ref.</th>
                                                    <th>Date</th>
                                                    <th>Narration</th>
                                                    <th>User</th>
                                                    <th>Amount</th>
                                                     <th>Closing Balance</th>
                                                </tr>
                                            </thead>


                                            <tbody>
                                                



                                            </tbody>
                                        </table>
                        </div>

                        <div id="divReturnDetails" style="width: 100%">
                            <div style="width: 100%; border: 1px solid #000000;"></div>
                            <span style="font-weight: bold;">Return details</span>
                            <div class="cl"></div>
                            <div id="divReturns">
                                <table id="tblReturnDetails" style="margin-top: 8px; margin-bottom: 8px;" cellspacing="0" cellpadding="0" border="1" width="100%">
                                    <thead>
                                        <tr>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">No</td>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Item Code</td>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Item Name</td>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Quantity</td>
                                            <%-- <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Foc</td>--%>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Price</td>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Discount</td>
                                            <td class="tablefonthead" style="font-weight: bold; font-size: 12px;">Total</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                                <div class="cl"></div>
                            </div>

                        </div>

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


                                        <%--<div style="width:50%;float:left; text-align:right;"><strong> VJ CXKLVJXCV CXKJVCX </strong>
     <br /><br />
     Authorised Signatory
 </div>--%>
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
                        <%--<table class="fr">
                    <tbody>
                       
                    </tbody>
                </table>
                <div class="cl"></div>
                <table style="width: 100%; font-size: 10px; margin-top: 15px; text-align: center;">
                    <tbody>
                        <tr>
                            <td></td>
                        </tr>
                    </tbody>
                </table>--%>
                    </div>

                </div>
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
