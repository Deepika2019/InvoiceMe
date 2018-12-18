<%@ Page Language="C#" AutoEventWireup="true" CodeFile="wifiBillPrint.aspx.cs" Inherits="sales_wifiBillPrint" %>

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
    <script type="text/javascript">
        function printReceipt() {
            $("#divBack").hide();
            $("#divPrint").hide();
            $("#divPayment").hide();
            $("#divPaymentDetails").hide();
            $("#divReturnDetails").hide();
            $("#lblOrderId").hide();
            window.print();
            $("#divBack").show();
            $("#divPrint").show();
            $("#divPayment").show();
            $("#divPaymentDetails").show();
            $("#divReturnDetails").show();
            $("#lblOrderId").show();
        }

        function backPressed() {
            window.history.back();

        }
    </script>
    <style media="print">
        @page
        {
            size: auto;
            margin: 0;
        }
        thead {display: table-header-group;}
    </style>

    
    <style type="text/css">
        body
        {
			color:#0c0c0c;
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

        <div class="mainDiv" style="padding: 10px; padding-left:20px; padding-right:20px;">

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
                    <div style="width: 150px; margin: auto; font-weight: bold; font-size: 16px; text-align:center;">Tax Invoice</div>
                </div>
                <div style="width: 100%; border: 1px solid #73879c;">
                    <div style="width: 100%; float: left;">
                        <div style="width: 50%; height: 140px; float: left; padding: 10px; border-right: 1px solid #73879c; border-bottom: 1px solid #73879c;">
                            <div style="font-weight: bold;font-size:16px" id="lblWarehouse" runat="server"></div>
                            <div id="divBranchAddress" runat="server"></div>
                            <div id="divBranchCountry" runat="server"></div>
                            <div>GSTIN/UINL:<span id="divRegno" runat="server"></span></div>
                            <div>Email:<span id="divBranchEmail" runat="server"></span>  </div>
                        </div>
                        <div style="width: 50%; height: 140px; float: left; padding: 10px; border-bottom: 1px solid #73879c;">
                            <div>Name & Address of Customer</div>
                            <div>
                                <label for="" id="lblCusName" style="margin-bottom: 0px; font-size: 15px;" runat="server"></label>
                            </div>
                            <div id="lblAddress" runat="server"></div>
                            <div><span id="spanCity" runat="server">SELAM</span></div>
                            <div>State:<span id="spanStateCode" runat="server"></span></div>

                            <div style="float: left;"><span id="lblEmailId" runat="server"></span>&nbsp&nbsp<span id="spanPhone" runat="server"></span></div>
                            <div id="spanGst" style="float: right; font-weight: bold;" runat="server"></div>
                        </div>
                    </div>
                    <div style="clear: both;"></div>
                    <div style="float: left; width: 50%; border-left: none; border-right: 1px solid #73879c; padding: 10px;">
                        <table style="width: 100%;">
                            <tr>
                                <td style="font-weight: bold;">Invoice No&nbsp&nbsp&nbsp&nbsp&nbsp:
                                    <label id="lblInvoiceNum" style="font-size: 15px;" runat="server"></label>
                                    <label id="lblOrderId" style="font-size: 15px;" runat="server"></label>
                                </td>
                                <td style="font-weight: bold;">Date:
                                    <label id="lblOrderDate" style="font-size: 15px;" runat="server"></label>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp</td>
                            </tr>
                            <tr>
                                <td style="font-weight: bold">Delivery Note:
                                </td>
                                <td style="font-weight: bold">Mode/Term of Payments:
                                </td>
                            </tr>
                            <%--  <tr style="border-bottom: 1px solid #73879c;">
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
                            </tr>--%>
                        </table>
                    </div>
                    <div style="float: left; width: 50%; border-left: none; padding: 10px;">
                        <table style="width: 100%;">
                            <tr>
                                <td colspan="2" style="font-weight: bold; font-size: 15px; text-transform: uppercase;">Terms of Delivery<br />
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
                        <table id="tblOrderDetails" style="margin-top: 8px; margin-bottom: 8px;font-size:13px;font-weight:bold" cellspacing="0" cellpadding="0" border="1" width="100%">
                                <tr>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">No</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">Item Name</td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; text-align: center;">HSN</td>
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
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; width: 60px; text-align: center;">Taxable Value</td>
                                <td class="" style="text-align: center; font-size: 12px;"><span style="font-weight: bold;">CGST</span>
                                    <table cellspacing="0" cellpadding="0" width="100%">
                                        <tbody>
                                            <tr>
                                                <td class="tablefonthead bordertopbot" style="width: 30%;">%</td>
                                                <td class="tablefonthead bodertopleft">Amt</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                                <td class="" style="text-align: center; font-size: 12px;"><span style="font-weight: bold;">SGST</span>
                                    <table cellspacing="0" cellpadding="0" width="100%">
                                        <tbody>
                                            <tr>
                                                <td class="tablefonthead bordertopbot" style="width: 30%;">%</td>
                                                <td class="tablefonthead bodertopleft">Amt</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                                <td class="" style="text-align: center; font-size: 12px;"><span style="font-weight: bold;">IGST</span>
                                    <table cellspacing="0" cellpadding="0" width="100%">
                                        <tbody>
                                            <tr>
                                                <td class="tablefonthead bordertopbot" style="width: 30%;">%</td>
                                                <td class="tablefonthead bodertopleft">Amt</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                                <td class="tablefonthead" style="font-weight: bold; font-size: 12px; width: 70px; text-align: center">Net Amt</td>
                                <!-- <td class='tablefonthead'>Paid.Amt</td>-->
                            </tr>

                       
                            <tbody id="tblOrderDetailsTbody" runat="server">
                            </tbody>

                            <tbody id="tbodyPayments">


                                <tr>
                                    <td style="text-align: right; padding-right: 10px;" colspan="6"><b>TOTAL</b></td>

                                    <td style="text-align: center">
                                        <label id="lblTotalAmount" runat="server">250</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalDiscAmount" runat="server">--</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalTaxExAmount" runat="server">--</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalCgstAmount" runat="server">--</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalSgstAmount" runat="server">--</label></td>
                                    <td style="text-align: center">
                                        <label id="lblTotalIgstAmount" runat="server">--</label></td>
                                    <td style="text-align: center">
                                        <label id="lblNetAmount" runat="server">--</label></td>
                                </tr>








                           <%--     <tr>
                                    <td style="text-align: right; padding-right: 10px;" colspan="5"><b>TOTAL</b></td>

                                 
                                     <td style="text-align: center">     
                                        <label id="lblTotalTaxExAmount" runat="server">--</label></td>
                                     <td style="text-align: center">
                                        <label id="lblTotalDiscAmount" runat="server">--</label></td>
                                  
                                    <td style="text-align: center">
                                        <label id="lblNetAmount" runat="server">--</label></td>
                                </tr>--%>

                            </tbody>
                        </table>

                        <div style="width: 100%; text-align: right;" id="divPayment">
                            <div style="display: inline-block; margin-right: 10px;">
                                <label id="lblVatStatus" runat="server"></label><br />
                                <label id="lblGrandTotal" runat="server"></label><br />
                                <span style="font-weight: bold;">Paid Amount : </span>
                                <label for="" id="lblPaidAmount" runat="server">18.00</label><br />
                                <span id="Span1" style="font-weight: bold;" runat="server">Balance Amount : </span>
                                <label for="" id="lblBalanceAmount" runat="server">18.00</label><br />
                            </div>
                        </div>
             

                        <div class="cl"></div>
                        <div style="width: 100%;"></div>
                        <table style="width:100%;display:;" id="tblDeclaration">
                            <tr>
                                <td>
                                      <div style="width: 100%; border: 1px solid #000000; padding:5px;">
                                          <div style="width:50%;float:left;"><%--<u>Declaration</u>--%>
                                                <div id="divDeclaration" runat="server">

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
                        <table width="100%" class="fl">
                            <tbody>
                                <tr>
                                      <td style="font-weight: bold">
                                        <div for="" id="lblBillDisclosure" runat="server"></div></td>
                                </tr>
                                <tr>
                                    <td style="font-weight: bold" id="lblWarehouseName" runat="server">
										<label for="" id="lblStaffNam" style="display:none" runat="server"></label>
                                    </td>
                                </tr>
								
                                <tr>
                                    <td style="font-weight: bold; line-height:60px;">Authorised Signature____________</td>
                                </tr>
								
								<tr></tr>
								
                                <tr></tr>
                                <tr>
									<td style="font-weight: bold;float:right">Client Signature____________</td>
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
