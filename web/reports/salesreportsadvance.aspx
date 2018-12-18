<%@ Page Language="C#" AutoEventWireup="true" CodeFile="salesreportsadvance.aspx.cs" Inherits="reports_salesreportsadvance" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Advanced Report | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
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
        var BranchId;
        var custid = 0;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            $("#txtSearchFromDate").val('');
            $("#txtSearchToDate").val('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#customerNames").val("");
            SearchAutoCustomer();
            //showProfileHeader(1);
            showBranches();
            ShowUTCDate();
            // userButtonRoles();
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");

        });

        // for querystring

        function getQueryString(key) {
            return queryParams[key];
        }
        function setQueryParams() {
            queryParams = {};
            var queryStringArray = location.search.replace(/[`~!@#$%^*()|+\?;:'",.<>\{\}\[\]\\\/]/gi, '').split("&");
            for (var i = 0; i < queryStringArray.length; i++) {
                queryParams[queryStringArray[i].split("=")[0]] = queryStringArray[i].split("=")[1];
            }
        }
        //  function to get highlighted text-align
        function getHighlightedValue(searchQuery, value) {
            var regex = new RegExp('(' + searchQuery + ')', 'gi');
            var highlightedtext = "<span style='color:#4A2115' >" + searchQuery + "</span>";
            return value.replace(regex, "<span style='color:#4A2115' >$1</span>");
        }
        //end query string

        $(function () {
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();

            $('#txtSearchFromDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
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
                dateFormat: 'dd-mm-yy'
            });
        });//end
        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtSearchFromDate").val(localdate);
            $("#txtSearchToDate").val(localdate);

            //showDailyReports(1);
        }//end

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];

        }//end
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

        //auto populate in vendor search
        function SearchAutoCustomer() {
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
                        url: "salesreportsadvance.aspx/GetAutoCompleteCustomerData",
                        data: "{'variable':'" + $("#customerNames").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            console.log(data.d);
                            var data1 = jQuery.parseJSON(data.d);
                            //  alert(data1);
                            console.log(data1.value);

                            response(data1);


                        },
                        error: function (data) {
                            alert("Internet Problem..!");
                        }
                    });
                },
                select: function (event, ui) {

                    custid = ui.item.id;
                    if (custid == -1) {
                        $("#customerNames").val("");
                    } else {
                        $("#customerNames").val(ui.item.label); //ui.item is your object from the array
                    }
                    // selectVendor();
                    event.preventDefault();
                },
                minLength: 1

            });
        }

        function showDailyReport() {
            ShowUTCDate();
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#comboCustomersInReport").val(0);
            $("#comboSalesInReport").val(0);

            $("#lblSummaryBranchName").text('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');

            $("#comboCustomersInReport").val(0);
            $("#comboSalesInReport").val(0);
            $("#lblcountCollection").text('');
            $("#lblcountSales").text('');
            $("#lblReportBranchName").text('');
            $("#selCeheckOutstand").val(-1);
            $("#customerNames").val("");
            $("#selDeliveryStatus").val(-1);
            custid = 0;
            var brnchid = $.cookie("invntrystaffBranchId");
            $("#comboBranchesInReport").val(brnchid);



            showDailyReports(1);
        }

        //start: show branches in Reports page
        function showBranches() {
            var loggedInBranch = $.cookie("invntrystaffBranchId");
            var userid = $.cookie("invntrystaffId");
            //alert(userid);
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showBranches",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#comboBranchesInReport").html(htm);
                    $("#comboBranchesInReport").val(loggedInBranch);
                    showcustomers();


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        //stop: show warehouse in reports page
        //start function for listing customers
        function showcustomers() {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showCustomersInReports",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Customer--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cust_id + '">' + row.cust_name + '</option>';
                    });
                    $("#comboCustomersInReport").html(htm);
                    showsalespersons();
                    //  showDailyReports(1);

                    // Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end

        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select User--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.first_name + '&nbsp' + row.last_name + '</option>';
                    });
                    $("#comboSalesInReport").html(htm);
                    showDailyReports(1);


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


    

        //Start:Show Daily Reports List
        function showDailyReports(page) {
            var postObj = {
                page: page,
                perpage: $("#txtpageno").val(),
                filters: {
                }
            }
            if ($("#comboBranchesInReport").val() && $("#comboBranchesInReport").val() != "0" && $("#comboBranchesInReport").val() != "") {
                postObj.filters.branch_id = $("#comboBranchesInReport").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }

            if (custid != 0) {
                postObj.filters.customer = custid;
            }

            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.salesmanId = $("#comboSalesInReport").val();
            }
            if ($("#selCeheckOutstand").val() != -1) {
                postObj.filters.outstand = $("#selCeheckOutstand").val();
            }
           // alert($("#selDeliveryStatus").val());
            if ($("#selDeliveryStatus").val() != -1) {
                postObj.filters.status = $("#selDeliveryStatus").val();
            }
            loading();

            //   alert(searchResult);
            // alert("{'page':'" + page + "','searchResult':'" + searchResult + "','perpage':'" + perpage + "','BranchId':'" + BranchId + "','reportfromdate':'" + fromdate1 + "','reporttodate':'" + todate1 + "','BranchName':'" + BranchName + "'}");
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/showDailyReports",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();

                 //   alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    if (msg.d == "N" || obj.data=="") {
                        $("#lblTotalRecords").text(0);

                        $('#tblsalesadvancereport  tbody').html("<tr class='overeffect'><td colspan='12' align='center' style='font-weight:bold; padding:8px;'>No Results Found</td></tr>");
                        //  alert("Not Found..!");
                        //$('#tblsalesadvancereport tbody').html('');
                        $("#lblSummaryBranchName").text('');

                        $("#SummaryReportDiv").html('');
                        $("#divsalesSummary").html('');
                        $("#divSummryall").hide();

                        $("#divsumry").hide();
                        $("#lblReportBranchName").text('');

                        $("#lblcountCollection").text('');
                        $("#lblcountSales").text('');
                        $("#lblSummaryFromDate").text('');
                        $("#lblSummaryToDate").text('');


                        $("#divsalesSummary").html('');

                        $("#paginatediv").html('');

                        return false;
                    }
                    else {
                        //alert(msg.d);
                       
                        var htm = "";
                        var htmc = "";
                        var htms = "";
                        var a;


                        var checkorderId = 0;
                        $.each(obj.data, function (i, row) {
                            if (checkorderId != row.sm_id) {
                                var paymentmode = "";
                                var cnt = obj.count;
                                $("#lblcountCollection").text(cnt);
                                $("#lblcountSales").text(cnt - obj.canceledCount);
                                //   htm += "<tr><td colspan='12' class='bordertopbottom' style='border-bottom:none;'></td></tr>";
                                if (row.sm_invoice_no != "" && row.sm_invoice_no !== null) {
                                    htm += "<tr><td class=''><a href='/sales/manageorders.aspx?orderId=" + row.sm_refno + "' style='text-decoration:none; color:#056dba;' target='_blank'> #" + row.sm_invoice_no + "(" + row.sm_id + ")</a></td>";
                                } else {
                                    htm += "<tr><td class=''><a href='/sales/manageorders.aspx?orderId=" + row.sm_refno + "' style='text-decoration:none; color:#056dba;' target='_blank'><span style='color:red'>(Not Yet Billed)</span> (" + row.sm_id + ")</a></td>";
                                }

                                htm += "<td>" + row.sm_refno + "</td>";

                                htm += "<td>" + row.BillDate + "</td>";

                                if (row.sm_cash_amt > 0) {

                                    paymentmode = paymentmode + ", Cash";
                                    // alert(paymentmode);
                                }
                                if (row.sm_card_amt > 0) {
                                    paymentmode = paymentmode + ", Card";
                                }
                                if (row.sm_chq_amt > 0) {
                                    paymentmode = paymentmode + ", Cheque";
                                }
                                if (paymentmode != "") {
                                    paymentmode = paymentmode.substr(1);
                                }
                                // alert(paymentmode);

                                htm += "<td>" + paymentmode + "</td>";
                                htm += "<td><a href='../managecustomers.aspx?cusId=" + row.cust_id + "'style='text-decoration:none; color:#056dba;' target='_blank'>" + row.cust_id + "</a></td>";
                                htm += "<td>" + row.cust_name + "</td>";
                                if (row.sm_refno != row.sm_id) {
                                    htm += "<td colspan='4' style='text-align:center;color:#056dba;'>Outstanding Bill</td>";
                                    htm += "<td>" + row.sm_paid + "</td><td>" + row.sm_balance + "</td></tr>";
                                    return;
                                }
                                else {
                                    htm += "<td>" + row.sm_total + "</td><td>" + row.sm_discount_rate + "</td><td>" + row.sm_discount_amount + "</td><td>" + row.sm_netamount + "</td>";
                                }
                                htm += "<td>" + row.sm_paid + "</td><td>" + row.sm_balance + "</td></tr>";

                                if (row.approvername == null) {
                                    htm += "<tr><td colspan='12' style='font-size:11px; font-weight:bold;'>Sold By:" + row.salesname + "</td>";
                                }
                                else {
                                    htm += "<tr><td colspan='2' style='font-size:11px; font-weight:bold;'>Sold By:" + row.salesname + "</td>";
                                    htm += "<td colspan='10'  style='font-size:11px; font-weight:bold;' >Approved By:" + row.approvername + "</td>";
                                }


                                // htm += "<tr><td colspan='2' style='font-size:11px; font-weight:bold;'>Sold By:" +row.salesname + "</td>";
                                //if (row.approvername != null) {
                                //    htm += "<td colspan='10'  style='font-size:11px; font-weight:bold;' >Approved By:" + row.approvername + "</td>";
                                //}
                                htm += "</tr>";
                                htm += "<tr><td>Items:</td>";
                                htm += "<td colspan='11' style='font-size:12px;'>";
                                a = 1;
                                htm += "</br>";
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.si_qty + " * " + row.si_price + ")-";

                                htm += "" + row.si_discount_amount + "=" + row.si_net_amount + ")  &nbsp &nbsp ";
                                //  htm += "</td>";
                            }
                            else {
                                a = a + 1;
                                htm += "</br>";
                                htm += "<span style=font-weight:bold;>" + a + ").</span> " + row.itm_name + "";
                                htm += " &nbsp ( (" + row.si_qty + " * " + row.si_price + ")-";
                                htm += "" + row.si_discount_amount + "=" + row.si_net_amount + ")  &nbsp &nbsp ";

                            }

                            checkorderId = row.sm_id;

                            // htm+="<td class='borderbottomdot tablefonts'>" + dt.Rows[i]["ttype"] + "</td>";
                        });
                        htm += "<tr><td colspan='12' class='bordertopbottom' style='border-bottom:none;'></td></tr></table></div>";
                        // $("#ReportsContentDiv").html(htm);

                        //summary report start here



                        htmc += "<table class='table'>";
                        htmc += "<tr><th>Cash</th><td style='text-align:right'><div>" + obj.totalcashamt + " " + obj.currency + "</div></td></tr>";
                        htmc += "<tr> <th>Card</th><td style='text-align:right'><div>" + obj.totalcardamt + " " + obj.currency + "</div></td> </tr>";
                        htmc += "<tr><th class=''>Cheque</th> <td style='text-align:right'><div>" + obj.totalcheqamt + " " + obj.currency + "</div></td> </tr>";
                        htmc += "<tr><th class=''>Wallet</th><td style='text-align:right'><div>" + obj.totalwalletamt + " " + obj.currency + "</div></td> </tr>";
                      
                        //html += "<tr> <th>Outstanding Received</th><td>" + obj.totaloutstand_paid + " " + obj.currency + "</td> </tr>";

                        htmc += "</table>";

                        htms += "<table class='table'>";
                        htms += "<tr> <th>Sales Netamount</th><td><div class='pull-right'>" + obj.totalnetamt + " " + obj.currency + "</div></td> </tr>";
                        htms += "<tr> <th>Total Order Amount</th><td><div class='pull-right'>" + obj.orderAmount + " " + obj.currency + "</div></td> </tr>";
                        htms += "<tr> <th>Total Bill Amount</th><td><div class='pull-right'>" + obj.billAmount + " " + obj.currency + "</div></td> </tr>";
                        htms += "<tr><th>Total Paid</th><td><div class='pull-right'>" + obj.totalpaid + " " + obj.currency + "</div></td> </tr>";
                        htms += "<tr><th>Total Balance</th><td><div class='pull-right'>" + obj.totalbalance + " " + obj.currency + "</div></td> </tr>";

                        htms += "</table>";


                        //cancelled
                        $("#lbl_sl_ovr_can_cnt").html(obj.canceledCount + ' nos.');

                        var realcancelledpaid = obj.canceledPaid - obj.canceledNetAmt
                        $("#lbl_sl_ovr_can_amt").html(obj.canceledNetAmt);
                        //$("#lbl_sl_ovr_can_paid").html(format_currency_value(obj.dt_order[0].cancelled_paid));
                        $("#lbl_sl_ovr_can_paid").html(realcancelledpaid);

                        $('#tblsalesadvancereport tbody').html(htm);
                        $("#divSummryall").show();
                        $("#divsumry").show();
                        $("#SummaryReportDiv").html(htmc);
                        
                        $("#divsalesSummary").html(htms);
                        var BranchName = $("#comboBranchesInReport option:selected").text();
                        $("#lblReportBranchName").text(BranchName);
                        $("#lblSummaryBranchName").text(BranchName);
                        $("#lblTotalRecords").text(obj.count);
                        if (postObj.filters.from_date != "" && postObj.filters.to_date != "") {
                            $("#lblReportFromDate").text(postObj.filters.from_date);
                            $("#lblReportToDate").text(postObj.filters.to_date);
                            $("#lblSummaryFromDate").text(postObj.filters.from_date);
                            $("#lblSummaryToDate").text(postObj.filters.to_date);
                            //  showSummaryReport();
                        }
                        // alert(page);
                        $("#paginatediv").html(paginate(obj.count, $("#txtpageno").val(), page, "showDailyReports"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


        //Start:Download Daily Reports List
        function DownloadDailyReports() {

            var postObj = {
                filters: {
                }
            }
            if ($("#comboBranchesInReport").val() && $("#comboBranchesInReport").val() != "0" && $("#comboBranchesInReport").val() != "") {
                postObj.filters.branch_id = $("#comboBranchesInReport").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }

            if (custid != 0) {
                postObj.filters.customer = custid;
            }

            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.salesmanId = $("#comboSalesInReport").val();
            }
            if ($("#selCeheckOutstand").val() != -1) {
                postObj.filters.outstand = $("#selCeheckOutstand").val();
            }
            if ($("#selDeliveryStatus").val() != -1) {
                postObj.filters.status = $("#selDeliveryStatus").val();
            }
            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/DownloadDailyReports",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N" || msg.d == "0") {
                        alert("Not Found...!");
                        return false;
                    }
                    else {
                        location.href = "downloadreport.aspx";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }
        //Stop:Download Daily Reports List
        function printMainReport() {
            $("#tdDownloadBtn").hide();
            $("#tdPrintBtn").hide();


         
            $("#comboCustomersInReport").hide();
            $("#comboSalesInReport").hide();
            $("#txtSearchFromDate").hide();
            $("#txtSearchToDate").hide();
            $("#lblresultpage").hide();
            $("#txtpageno").hide();
            $("#btnreset").hide();
            $("#btnsearch").hide();
            $("#lblTotalRecords").hide();
            $("#lblrecords").hide();
            $("#tdSearchReportBtn").hide();
            $("#tdSelectBranch").hide();
            $("#tdDateRange").hide();
            $("#spanpageno").hide();
            // $("#lbPrintReportType").html(searchtype);
            $("#tdReportType").hide();

            $("#divfrmdte").hide();
            $("#divtodate").hide();
            $("#divshwCustmr").hide();
            $("#divshowSles").hide();
            $("#divshwBranch").hide();
            $("#divcustSearch").hide();
            $("#comboBranchesInReport").hide();
            $("#lblTotalRecords").show();
            $("#lblrecords").show();
            $("#lbResultperpage").show();
            $("#divReportContent").print();
            $("#tdDownloadBtn").show();
            $("#tdPrintBtn").show();
            $("#tdSearchReportBtn").show();
            $("#tdSelectBranch").show();
            $("#tdDateRange").show();
            $("#lbResultperpage").hide();
            $("#spanpageno").show();
            $("#tdReportType").show();
            $("#tdPrintReportType").hide();

            $("#divfrmdte").show();
            $("#divtodate").show();
            $("#divshwCustmr").show();
            $("#divshwBranch").show();
            $("#divshowSles").show();
            $("#divcustSearch").show();

            $("#comboCustomersInReport").show();
            $("#comboSalesInReport").show();
            $("#txtSearchFromDate").show();
            $("#txtSearchToDate").show();
            $("#lblresultpage").show();
            $("#txtpageno").show();
            $("#btnreset").show();
            $("#btnsearch").show();

            $("#comboBranchesInReport").show();

        }


        //start:Bill print preview
        function billPrintPreview(outstandbill, orderId) {

            $.cookie('print_outstandbill', outstandbill, {
                expires: 365,
                path: '/'
            });
            $.cookie('invntrybillno', orderId, {
                expires: 365,
                path: '/'
            });
            //var win = window.open("../billreceipt.html", '_blank');
            // win.focus();
            // location.href = "billreceipt.aspx";
            var windowSizeArray = ["width=200,height=200",
                                            "width=850,height=600,scrollbars=yes"];
            var url = "/sales/billreceipt.aspx"; //$(this).attr("href");
            var windowName = "popupMemberWindow";//$(this).attr("name");
            var windowSize = windowSizeArray[1];

            var win = window.open(url, windowName, windowSize);
            win.focus();
            event.preventDefault();
            return false;
        }

        //search customers: show in popup
        function resetcustomerdata() {
            for (var i = 1; i <= 7; i++) {
                $("#searchposContent" + i).val('');
            }
            searchcustomerdata(1);
        }
        function searchcustomerdata(page) {
            var filters = {};
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.custname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.custid = $("#searchposContent1").val();
            }

            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/searchcustomerdata",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tableCustList tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
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
                            htm += " onclick=javascript:selectOrderCustomer('" + row.cust_id + "','" + row.cust_name.replace(/\s/g, '&nbsp;') + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.custid, row.cust_id.toString()) + "</td><td>" + getHighlightedValue(filters.custname, row.cust_name) + "</td><td>" + row.cust_amount + "</td></tr>";

                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        //   alert(htm);
                        $('#tableCustList tbody').html(htm);
                        $("#popupcustomers").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchcustomerdata"));


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

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function selectOrderCustomer(id, name) {
            custid = id;
            $("#customerNames").val(name);
            popupclose('popupcustomers');
        }

        function DownloadTaxReports() {

            var postObj = {
                filters: {
                }
            }
            if ($("#comboBranchesInReport").val() && $("#comboBranchesInReport").val() != "0" && $("#comboBranchesInReport").val() != "") {
                postObj.filters.branch_id = $("#comboBranchesInReport").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }

            if (custid != 0) {
                postObj.filters.customer = custid;
            }

            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.salesmanId = $("#comboSalesInReport").val();
            }
            if ($("#selCeheckOutstand").val() != -1) {
                postObj.filters.outstand = $("#selCeheckOutstand").val();
            }
           // alert($("#selDeliveryStatus").val());
            if ($("#selDeliveryStatus").val() != -1) {
                postObj.filters.status = $("#selDeliveryStatus").val();
            }
            
            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/DownloadTaxReports",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N" || msg.d == "0") {
                        alert("Not Found...!");
                        return false;
                    }
                    else {
                        location.href = "downloadTaxreport.aspx";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }

        
        function DownloadCancelTaxReports() {


            var postObj = {
                filters: {
                }
            }
            if ($("#comboBranchesInReport").val() && $("#comboBranchesInReport").val() != "0" && $("#comboBranchesInReport").val() != "") {
                postObj.filters.branch_id = $("#comboBranchesInReport").val();
            }
            if ($("#txtSearchFromDate").val() != "" && $("#txtSearchFromDate").val() != undefined) {
                postObj.filters.from_date = $("#txtSearchFromDate").val();
            }
            if ($("#txtSearchToDate").val() != "" && $("#txtSearchToDate").val() != undefined) {
                postObj.filters.to_date = $("#txtSearchToDate").val();
            }

            if (custid != 0) {
                postObj.filters.customer = custid;
            }

            if ($("#comboSalesInReport").val() && $("#comboSalesInReport").val() != "0" && $("#comboSalesInReport").val() != "") {
                postObj.filters.salesmanId = $("#comboSalesInReport").val();
            }
            if ($("#selCeheckOutstand").val() != -1) {
                postObj.filters.outstand = $("#selCeheckOutstand").val();
            }

            loading();
            loading();

            // alert(searchResult);
            $.ajax({
                type: "POST",
                url: "salesreportsadvance.aspx/DownloadCancelTaxReports",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N" || msg.d == "0") {
                        alert("Not Found...!");
                        return false;
                    }
                    else {
                        location.href = "DownloadCancelTaxrport.aspx";
                        return false;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

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


</head>
<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">
                    <div class="navbar nav_title" style="border: 0;">
                        <a href="../index.html" class="site_title">
                            <!--<i class="fa fa-paw"></i> -->
                            <span>Invoice Me</span></a>
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
                            <label style="font-weight: bold; font-size: 16px;">Sales Advanced Report </label>

                        </div>

                    </nav>
                </div>
            </div>

            <!-- /top navigation -->
            <!-- page content -->

            <div id="divReportContent">

                <div class="right_col" role="main" id="">
                    <div class="">
                        <div class="page-title">
                            <%--  <div class="title_left">
                <h3>Sales Advanced Report</h3>
              </div> --%>
                        </div>

                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title" style="margin-bottom: 3px;">
                                        <label>Filter</label>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                        </ul>


                                        <div class="clearfix"></div>

                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="x_content">

                                        <section class="content invoice">
                                            <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback">

                                                <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwBranch">
                                                    <div id="showBranchesDiv">
                                                        <select id="comboBranchesInReport" style="text-indent: 25px;  padding-right:5px;" class="form-control" onchange="javascript:showDailyReports(1);">
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-map-marker form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="divshowSles">
                                                    <div id="showsalesmansInReport">
                                                        <select id="comboSalesInReport" style="text-indent: 25px;  padding-right:5px;" class="form-control" onchange="javascript:showDailyReports(1);">
                                                            <option>--Sales Person--</option>
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="div1">
                                                    <div id="Div2">
                                                        <select id="selCeheckOutstand" style="text-indent: 25px; padding-right:5px;" class="form-control" onchange="javascript:showDailyReports(1);">
                                                            <option value="-1">--All Orders--</option>
                                                            <option value="0">--Outstanding--</option>
                                                            <option value="1">--Non Outstanding--</option>
                                                        </select>
                                                    </div>
                                                    <span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
                                                </div>
                                                  <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback" >
                           <div id="">
							<select id="selDeliveryStatus" style="text-indent:25px;padding-right:5px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option value="-1" selected="">All Status</option>
                                <option value="0">New</option>
                                            <option value="1">Processed</option>
                                <option value="2">Delivered</option>
                                <option value="3">To be Confirm</option>
                                            <option value="4">Cancel</option>
                                            <option value="5">Reject</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-clipboard form-control-feedback left"></span>
							  </div>
                                                <%--<div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback" id="divshwCustmr">
                           <div id="showcustomersInReport">
							<select id="comboCustomersInReport" style="text-indent:25px;" class="form-control" onchange="javascript:showDailyReports(1);">
											<option>--Customer--</option>
											<option>Abu Dhabi</option>
											<option>Ajman</option>
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-user form-control-feedback left"></span>
							  </div>--%>



                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                                                    <input type="text" placeholder="From Date" id="txtSearchFromDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divtodate">
                                                    <input type="text" placeholder="To Date" id="txtSearchToDate" class="form-control has-feedback-left" style="padding-right: 10px;" />
                                                    <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                                </div>
                                                <div id="divcustSearch">
                                                    <div class="col-md-5 col-sm-6 col-xs-10 form-group has-feedback" style="padding-right: 0px;" >
                                                    <input class="form-control has-feedback-left" placeholder="Search" id="txtSearch" style="padding-right: 2px;" />
                                                    <span aria-hidden="true" class="fa fa-search form-control-feedback left"></span>
                                                </div>
                                                <div class="col-md-1 col-sm-6 col-xs-2 form-group has-feedback" style="padding-left: 0px; padding-right: 0px;">
                                                    <div onclick="javascript:resetcustomerdata(1);" title="Search Customers" data-toggle="modal" style="font-size: 24px; margin-left: 5px;">
                                                        <label style="cursor: pointer;" class="fa fa-user"></label>
                                                        <label style="cursor: pointer; font-size: 20px; color: #ff6a00; position: relative; margin-left: -12px;" class="fa fa-search"></label>
                                                    </div>
                                                </div>
                                                </div>
                                                
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group">
                                                    <button id="btnreset" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:showDailyReport();">
                                                        <li style="margin-right: 5px;" class="fa fa-refresh"></li>
                                                        Reset 
                                                    </button>

                                                    <button id="btnsearch" style="font-size: 11px; padding: 4px; font-weight: bold;" class="btn btn-success pull-right" type="button" onclick="javascript:showDailyReports(1);">
                                                        <li style="margin-right: 5px;" class="fa fa-search"></li>
                                                        Search 
                                                    </button>

                                                </div>
                                            </div>

                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                                <div class="col-md-7 col-sm-6 col-xs-12 form-group">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">Branch :</label>
                                                        <label style="font-weight: normal;" id="lblReportBranchName"></label>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">From :</label>
                                                        <label style="font-weight: normal;" id="lblReportFromDate"></label>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblReportToDate"></label>
                                                    </div>
                                                </div>
                                                <div class="col-sm-5 invoice-col">
                                            
                                              
                                                    <div id="tdDownloadBtn" class="col-md-3 col-sm-6 col-xs-7 form-group" style="cursor:pointer;" onclick="javascript:DownloadDailyReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Report</label>
                                                    </div>
                                                     <div id="Div3" class="col-md-3 col-sm-6 col-xs-7 form-group" style="cursor:pointer;" onclick="javascript:DownloadTaxReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Tax Report</label>
                                                    </div>
                                                    <div id="Div4" class="col-md-4 col-sm-6 col-xs-7 form-group" style="cursor:pointer;display:none" onclick="javascript:DownloadCancelTaxReports();">
                                                        <label class="fa fa-download" style="font-size: 20px; color: red; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">Cancel Tax Report</label>
                                                    </div>
                                                    <div id="tdPrintBtn" class="col-md-2 col-sm-6 col-xs-4 form-group" style="cursor:pointer;" onclick="javascript:printMainReport();">
                                                        <label class="fa fa-print" style="font-size: 20px; color: blue; cursor: pointer;"></label>
                                                        <label style="font-weight: bold; font-size: 11px;">print</label>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto; padding-left: 0px; padding-right: 0px;">
                                                <div class="x_content" style="padding-left: 0px; padding-right: 0px;">
                                                    <table class="table table-striped" style="table-layout: auto;" id="tblsalesadvancereport">
                                                        <thead>
                                                            <tr>      <div class="col-md-6 col-sm-6 col-xs-6" style="">
                                                        <label id="lblrecords" style="font-weight: bold; font-size: 11px;">Total Records:</label>
                                                        <label id="lblTotalRecords"></label>
                                                    </div>
                                                                  <div class="col-md-6 col-sm-6 col-xs-6" style="padding-left: 0px;">
                                                            <select class="input-sm  pull-right" style="text-indent: 0; padding: 5px; height: 28px;" id="txtpageno" onchange="javascript:showDailyReports(1);">
                                                                <option value="25">25</option>
                                                                <option value="50">50</option>
                                                                <option value="100">100</option>
                                                                <option value="500">500</option>
                                                            </select>
                                                        </div>
                                                            </tr>
                                                            <tr>
                                                                <th>Order No</th>
                                                                <th>Ref No</th>
                                                                <th>Date</th>
                                                                <th>Mode</th>
                                                                <th>Cust.ID</th>
                                                                <th>Cust.Name</th>
                                                                <th>Total Amt.</th>
                                                                <th>Dis%</th>
                                                                <th>Dis.Amt </th>
                                                                <th>Net.Amt</th>
                                                                <th>Paid</th>
                                                                <th>Balance</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                           
                                                        </tbody>
                                                    </table>
                                                    <div id="paginatediv" style="text-align: center;"></div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->


                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%--start popup for customers --%>
                        <div class="container">


                            <div class="modal fade" id="popupcustomers" role="dialog">
                                <div class="modal-dialog modal-md" style="">

                                    <!-- Modal content-->
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupcustomers');">&times;</button>
                                            <div class="col-md-5 col-sm-6 col-xs-6">
                                                <h4 class="modal-title">Customers<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords"></span></h4>
                                            </div>
                                            <div class="col-md-6 col-sm-4 col-xs-12">

                                                <div class="col-md-4 col-sm-12 col-xs-3">
                                                    <select id="txtpospageno" onchange="javascript:searchcustomerdata(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                        <option value="25">25</option>
                                                        <option value="50">50</option>
                                                        <option value="100">100</option>
                                                        <option value="200">200</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-8 col-sm-12 col-xs-12">
                                                    <div class="" onclick="javascript:searchcustomerdata(1);">
                                                        <button type="button" class="btn btn-success mybtnstyl">
                                                            <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                            Search
                                                        </button>
                                                    </div>
                                                    <div class="" onclick="javascript:resetcustomerdata();">
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

                                                <table id="tableCustList" class="table table-striped table-bordered" style="table-layout: auto;">
                                                    <thead>
                                                        <tr>
                                                            <th>Cust Id</th>
                                                            <th>Name</th>
                                                            <th>Outstanding</th>


                                                        </tr>


                                                        <tr>
                                                            <td>
                                                                <input type="text" class="form-control" id="searchposContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                            <td>
                                                                <input type="text" id="searchposContent2" class="form-control" /></td>

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
                        <%-- end popup for customers --%>
                        <div class="clearfix"></div>

                        <div class="row" id="divsumry">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel" style="padding-left: 5px; padding-right: 5px;">
                                    <div class="x_title">
                                        <label>Summary Report</label>

                                        <ul class="nav navbar-right panel_toolbox pull-right">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                        </ul>

                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="x_content">

                                        <section class="content invoice">
                                            <!-- title row -->
                                            <div class="row">

                                                <!-- /.col -->
                                            </div>
                                            <!-- info row -->
                                            <div class="row invoice-info" style="background: #f1eded; padding-top: 15px;">
                                                <div class="col-md-8 col-sm-6 col-xs-12 form-group">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">Branch :</label>
                                                        <label style="font-weight: normal;" id="lblSummaryBranchName"></label>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">From :</label>
                                                        <label style="font-weight: normal;" id="lblSummaryFromDate"></label>
                                                    </div>
                                                    <div class="col-md-3 col-sm-6 col-xs-12 form-group">
                                                        <label style="font-weight: bold;">To :</label>
                                                        <label style="font-weight: normal;" id="lblSummaryToDate"></label>
                                                    </div>
                                                </div>

                                                <!-- /.col -->
                                            </div>
                                            <!-- /.row -->

                                            <!-- Table row -->


                                            <div class="row" id="divSummryall">

                                                <!-- /.col -->
                                                
                                                <!-- /.col -->
                                                <!-- /.col -->
                                                <div class="col-md-9 col-sm-12 col-xs-12" style="margin-top:10px;">
                       <label style="font-weight:bold; font-size:14px;">Sales Summary  ( Total Records: <label id="lblcountSales"></label> ) </label>
                          <div class="table-responsive" style="font-weight:bold;" id="divsalesSummary">
                            <table class="table">
                              <tbody>
                             
                              </tbody>
                            </table>
                          </div>
                        </div>
                                                <div class="clearfix"></div>
                                                <div class="col-md-9 col-sm-12 col-xs-12" style="margin-top: 10px;">
                                                    <label style="font-weight: bold; font-size: 14px;">Collection Summary</label>
                                                    <div class="table-responsive" style="font-weight: bold;" id="SummaryReportDiv">
                                                        <table class="table">
                                                            <tbody>
                                                                
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                


                                                  <div class="clearfix"></div>
                                                <div class="col-md-9 col-sm-12 col-xs-12" style="margin-top: 10px;">
                                                    <label style="font-weight: bold; font-size: 14px;">Cancelled Orders & Bills Summary</label>
                                                    <div class="table-responsive" style="font-weight: bold;" id="Div5">
                                                        <table class="table">
                                                        <tbody>
                                                            <tr><td>Total Cancelled Orders & Bills</td><td style="text-align:right"><div id="lbl_sl_ovr_can_cnt">1 nos.</div></td></tr>
                                                            <tr> <td>Total Net Amount</td><td style="text-align:right"><div id="lbl_sl_ovr_can_amt">100.00 Rs</div></td> </tr>
                                                            <tr><td class="">Total Payment Collected</td> <td style="text-align:right" class=""><div id="lbl_sl_ovr_can_paid">70.00 Rs</div></td> </tr>
                                                            <%--<tr><th class="">Wallet</th><td class="">0 INR</td> </tr>--%>
                                                        </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                <!-- /.col -->
                                            </div>
                                            
                                        </section>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /page content -->

            </div>
            <!<!-- footer content -->
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
