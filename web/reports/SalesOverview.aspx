<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SalesOverview.aspx.cs" Inherits="reports_SalesOverview" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Sales Overview | Invoice Me</title>
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


    

    <style media="print">
        @page
        {
            size: auto;
            margin: 0;
        }

        thead {display: table-header-group; }
        

    </style>

    <script type="text/javascript">

        $(document).ready(function () {
            
            show_sales_overview();
        });

        function format_currency_value(value) {

            var amount = parseFloat(value);
            return amount.toFixed($("#ss_decimal_accuracy").val()) + " " + $("#ss_currency").val();

        }

        function format_decimal_accuray(value) {

            var amount = parseFloat(value);
            return amount.toFixed($("#ss_decimal_accuracy").val());

        }

        function currentdate() {

            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1;

            var yyyy = today.getFullYear();
            var hh = today.getHours();
            var minu = today.getMinutes();
            var sec = today.getSeconds();

            if (dd < 10) {
                dd = '0' + dd
            }
            if (mm < 10) {
                mm = '0' + mm
            }

            if (hh < 10) {
                hh = '0' + hh
            }

            if (minu < 10) {

                minu = '0' + minu
            }

            if (sec < 10) {
                sec = '0' + sec

            }

            var curd = dd + '-' + mm + '-' + yyyy;

            return curd;
        }

        function dateformat(idate) {

            var med = idate.split("-");
            var dd = med[0];
            var mm = med[1];
            var yy = med[2];

            var nDate = yy + '-' + mm + '-' + dd;
            return nDate;

        }

        function findAndReplace(searchText, replacement, searchNode) {
            if (!searchText || typeof replacement === 'undefined') {
                // Throw error here if you want...
                return;
            }
            var regex = typeof searchText === 'string' ?
                        new RegExp(searchText, 'g') : searchText,
                childNodes = (searchNode || document.body).childNodes,
                cnLength = childNodes.length,
                excludes = 'html,head,style,title,link,meta,script,object,iframe';
            while (cnLength--) {
                var currentNode = childNodes[cnLength];
                if (currentNode.nodeType === 1 &&
                    (excludes + ',').indexOf(currentNode.nodeName.toLowerCase() + ',') === -1) {
                    arguments.callee(searchText, replacement, currentNode);
                }
                if (currentNode.nodeType !== 3 || !regex.test(currentNode.data)) {
                    continue;
                }
                var parent = currentNode.parentNode,
                    frag = (function () {
                        var html = currentNode.data.replace(regex, replacement),
                            wrap = document.createElement('div'),
                            frag = document.createDocumentFragment();
                        wrap.innerHTML = html;
                        while (wrap.firstChild) {
                            frag.appendChild(wrap.firstChild);
                        }
                        return frag;
                    })();
                parent.insertBefore(frag, currentNode);
                parent.removeChild(currentNode);
            }
        }

        function show_sales_overview() {
          
            
            //$(".text_div").html(function () {
            //    return $(this).text().replace("Orders", "hello everyone");
            //});

            var yyyy = new Date().getFullYear();
            $('#txt_date_overview_from').scroller({
                preset: 'date',
                endYear: yyyy + 10,
                setText: 'Select',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                //  dateFormat :'yy/mm/dd'
                dateFormat: 'dd-mm-yy'
            });

            $('#txt_date_overview_to').scroller({
                preset: 'date',
                endYear: yyyy + 10,
                setText: 'Select',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                //  dateFormat :'yy/mm/dd'
                dateFormat: 'dd-mm-yy'
            });

            var user_id = $.cookie("invntrystaffId");
          //  alert($.cookie("invntrystaffId"));
            var cday = currentdate();
            $('#txt_date_overview_from').val(cday);
            $('#txt_date_overview_to').val(cday);

           // overlay("loading users and warehouses");
           // disableBackKey();
            $.ajax({
                type: "POST",
                url: "SalesOverview.aspx/Get_users_and_warehouses",
                data: "{'user_id':'" + user_id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                crossDomain: true,
                timeout: 30000,
                success: function (msg) {

                    //closeOverlayImmediately();
                    //enableBackKey();

                    if (msg.d == "N") {

                        //validation_alert("No Data Found");
                        //onBackKeyDown();
                        return;

                    }
                    else if (msg.d == "BLOCKED") {

                       // validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                        //onBackKeyDown();
                    }
                    else {

                        var obj = JSON.parse(msg.d);

                        var bhtm = "";
                        bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                        $.each(obj.dt_warehouse, function (i, row) {

                            bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                        });
                        $("#select_over_view_branch_id").html(bhtm);


                        var uhtm = "";
                        uhtm = uhtm + '<option value="0">ALL USERS</option>';
                        $.each(obj.dt_users, function (i, row) {

                            uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                        });
                        $("#Select_sl_ovrvie_user_id").html(uhtm);

                       // showpage('div_sales_overview');
                        get_sales_overview();
                    }
                },
                error: function (xhr, status) {

                    //closeOverlayImmediately();
                    //enableBackKey();
                    //ajaxerroralert();
                }
            });




        }

        function get_sales_overview() {

           // overlay("Generating sales overview");
           // disableBackKey();
            $.ajax({

                type: "POST",
                url: "SalesOverview.aspx/Sales_Overview",
                data: "{'branch_id':'" + $("#select_over_view_branch_id").val() + "','user_id':'" +  $.cookie("invntrystaffId") + "','date_from':'" + dateformat($("#txt_date_overview_from").val()) + "','date_to':'" + dateformat($("#txt_date_overview_to").val()) + "','seller_id':'" + $("#Select_sl_ovrvie_user_id").val() + "','report_type':'" + $("#selInvoiceType").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                crossDomain: true,
                timeout: 35000,
                success: function (msg) {

                   // closeOverlay();
                   // enableBackKey();
                    var obj = JSON.parse(msg.d);
                    // console.log(obj);

                    // SETTING VALUES BLOCKWISE - obj.checkin_count[0].checkin_count
                    //* FOR CHECKIN 
                    //lbl_main_over_total_visit
                    $("#lbl_main_over_total_visit").html(obj.check_in[0].checkin_count + ' nos.');

                    // COMMSION INFO

                    $("#lbl_txt_ovr_other_commision").html(format_currency_value(obj.dt_order[0].sold_commision));
                    $("#lbl_txt_ovr_delivered_commision").html(format_currency_value(obj.dt_order[0].delivered_commision));
                    $("#lbl_txt_ovr_review_commision").html(format_currency_value(obj.dt_order[0].tobeconfirm_commision));

                    // RETURN
                    $("#lbl_slover_return_count").html(obj.dt_cr_dr_rt[0].returned_count + ' nos.');
                    $("#lbl_slover_return_amount").html(format_currency_value(obj.dt_cr_dr_rt[0].total_returned));

                    // CREDIT DEBIT WALLET-USE
                    $("#lbl_sloverview_credit_count").html(obj.dt_cr_dr_rt[0].credit_count + ' nos.');
                    $("#lbl_sloverview_credit_amt").html(format_currency_value(obj.dt_cr_dr_rt[0].total_credit));

                    $("#lbl_sloverview_debit_count").html(obj.dt_cr_dr_rt[0].debit_count + ' nos.');
                    $("#lbl_sloverview_debit_amount").html(format_currency_value(obj.dt_cr_dr_rt[0].total_debit));

                    $("#lbl_sloverview_wallet_count").html(obj.dt_cr_dr_rt[0].withdrawn_count + ' times.');
                    $("#lbl_sloverview_wallet_used").html(format_currency_value(obj.dt_cr_dr_rt[0].wallet_withdrawn));


                    $("#lbl_main_over_total_sales").html(format_currency_value(obj.dt_order[0].total_sale));
                    var cash_in_hand = (parseFloat(obj.dt_cr_dr_rt[0].tot_cash_amount) + parseFloat(obj.dt_cr_dr_rt[0].tot_cheque_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit)
                    $("#lbl_main_over_total_collection").html(format_currency_value(cash_in_hand));

                    var tot_cash_amt = (parseFloat(obj.dt_cr_dr_rt[0].tot_cash_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit_as_cash)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit_as_cash);
                    var tot_cheque_amt = (parseFloat(obj.dt_cr_dr_rt[0].tot_cheque_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit_as_cheque)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit_as_cheque);

                    $("#lbl_ovr_in_totcash").html('CASH : ' + format_currency_value(tot_cash_amt));
                    $("#lbl_ovr_in_totcheque").html(' |  CHEQUE : ' + format_currency_value(tot_cheque_amt));

                    // ACTIVE ORDERS
                    $("#lbl_slover_active_order_count").html(obj.dt_order[0].active_order_count + ' nos.');
                    $("#lbl_slover_active_total_sale").html(format_currency_value(obj.dt_order[0].active_total_sale));
                    $("#lbl_slover_active_active_total_receipt").html(format_currency_value(obj.dt_order[0].active_total_receipt));
                    $("#lbl_slover_active_outstanding_count").html(obj.dt_order[0].active_outstanding_count + ' nos.');

                    $("#lbl_slover_active_total_outstanding").html(format_currency_value(obj.dt_order[0].active_total_sale - obj.dt_order[0].active_total_receipt));
                    
                   // $("#lbl_slover_active_total_outstanding").html(format_currency_value(obj.dt_order[0].active_total_outstanding));

                    // TOTOAL SUMMARY
                    $("#lbl_slover_totordercount").html(obj.dt_order[0].order_count + ' nos.');
                    $("#lbl_slover_tot_netamt").html(format_currency_value(obj.dt_order[0].total_sale));
                    $("#lbl_slover_tot_pay_collected").html(format_currency_value(obj.dt_order[0].total_receipt));
                    $("#lbl_slover_totorder_with_bal").html(obj.dt_order[0].outstanding_count + ' nos.');
                    $("#lbl_slover_tot_bal_amt").html(format_currency_value(obj.dt_order[0].total_outstanding));
                    $("#lbl_slover_active_exceeded_outstanding_count").html(obj.dt_order[0].exceeded_outstanding_count + ' nos.');
                    $("#lbl_slover_active_exceeded_outstanding").html(format_currency_value(obj.dt_order[0].exceeded_outstanding));
                    $("#lbl_old_bill_entry").html(obj.dt_order[0].old_order_count + ' nos.');

                    // STATUS WISE
                    //new
                    $("#lbl_sl_ovr_new_cnt").html(obj.dt_order[0].new_order_count + ' nos.');
                    $("#lbl_sl_ovr_new_amt").html(format_currency_value(obj.dt_order[0].new_order_netamt));
                    $("#lbl_sl_ovr_new_paid").html(format_currency_value(obj.dt_order[0].new_order_paid));
                    $("#lbl_sl_ovr_new_bal").html(format_currency_value(obj.dt_order[0].new_order_balance));
                    //packed
                    $("#lbl_sl_ovr_pak_cnt").html(obj.dt_order[0].packed_order_count + ' nos.');
                    $("#lbl_sl_ovr_pak_amt").html(format_currency_value(obj.dt_order[0].packed_netamt));
                    $("#lbl_sl_ovr_pak_paid").html(format_currency_value(obj.dt_order[0].packed_paid));
                    $("#lbl_sl_ovr_pak_bal").html(format_currency_value(obj.dt_order[0].packed_balance));
                    //processed
                    $("#lbl_sl_ovr_pro_cnt").html(obj.dt_order[0].processed_order_count + ' nos.');
                    $("#lbl_sl_ovr_pro_amt").html(format_currency_value(obj.dt_order[0].processed_netamt));
                    $("#lbl_sl_ovr_pro_paid").html(format_currency_value(obj.dt_order[0].processed_paid));
                    $("#lbl_sl_ovr_pro_bal").html(format_currency_value(obj.dt_order[0].processed_balance));
                    //delivered
                    $("#lbl_sl_ovr_del_cnt").html(obj.dt_order[0].delivered_order_count + ' nos.');
                    $("#lbl_sl_ovr_del_amt").html(format_currency_value(obj.dt_order[0].delivered_order_netamt));
                    $("#lbl_sl_ovr_del_paid").html(format_currency_value(obj.dt_order[0].delivered_order_paid));
                    $("#lbl_sl_ovr_del_bal").html(format_currency_value(obj.dt_order[0].delivered_order_balance));
                    //pending
                    $("#lbl_sl_ovr_pen_cnt").html(obj.dt_order[0].pending_order_count + ' nos.');
                    $("#lbl_sl_ovr_pen_amt").html(format_currency_value(obj.dt_order[0].pending_netamt));
                    $("#lbl_sl_ovr_pen_paid").html(format_currency_value(obj.dt_order[0].pending_paid));
                    $("#lbl_sl_ovr_pen_bal").html(format_currency_value(obj.dt_order[0].pending_balance));
                    //cancelled
                    $("#lbl_sl_ovr_can_cnt").html(obj.dt_order[0].cancelled_order_count + ' nos.');

                    var realcancelledpaid = obj.dt_order[0].cancelled_paid - obj.dt_order[0].cancelled_netamt
                    $("#lbl_sl_ovr_can_amt").html(format_currency_value(obj.dt_order[0].cancelled_netamt));
                    //$("#lbl_sl_ovr_can_paid").html(format_currency_value(obj.dt_order[0].cancelled_paid));
                    $("#lbl_sl_ovr_can_paid").html(format_currency_value(realcancelledpaid));
                    //rejected
                    $("#lbl_sl_ovr_rej_cnt").html(obj.dt_order[0].rejected_order_count + ' nos.');
                    $("#lbl_sl_ovr_rej_amt").html(format_currency_value(obj.dt_order[0].rejected_netamt));
                    // $("#lbl_sl_ovr_rej_paid").html(format_currency_value(obj.dt_order[0].rejected_paid));

                    //to be confirm
                    $("#lbl_sl_ovr_rev_cnt").html(obj.dt_order[0].toBeConfirmed_order_count + ' nos.');
                    $("#lbl_sl_ovr_rev_amt").html(format_currency_value(obj.dt_order[0].toBeConfirmed_netamt));


                    // OLD PAYMENTS

                    $("#lbl_pay_info_lbl").html('( Payments recieved for orders placed before ' + $("#txt_date_overview_from").val() + ')');
                    $("#lbl_sl_ovr_old_paycnt").html(obj.dt_past_paid[0].pre_pay_count + ' nos.');
                    $("#lbl_sl_ovr_old_payamt").html(format_currency_value(obj.dt_past_paid[0].old_payments));

                    $("#lbl_main_sl_ovr_hdr").html('Based on orders placed between ' + $("#txt_date_overview_from").val() + ' and ' + $("#txt_date_overview_to").val() + ' Only ');
                    // customer info

                    $("#lbl_sl_ovrview_new_reg_total").html(obj.dt_new_reg[0].total_reg + ' nos.');
                    $("#lbl_sl_ovrview_new_reg_pend").html(obj.dt_new_reg[0].pending_customer + ' nos.');
                    $("#lbl_sl_ovrview_new_reg_approved").html(obj.dt_new_reg[0].approved_customer + ' nos.');
                    $("#lbl_sl_ovrview_new_reg_rejected").html(obj.dt_new_reg[0].rejected_customer + ' nos.');

                },
                error: function (e) {

                   // closeOverlayImmediately();
                   // enableBackKey();
                   // ajaxerroralert();

                }

            });

        }

        function reset_SlOverview_Filter() {

            var cday = currentdate();
            $('#txt_date_overview_from').val(cday);
            $('#txt_date_overview_to').val(cday);

            $("#Select_sl_ovrvie_user_id").val("0");
            $("#select_over_view_branch_id").val("0");
            get_sales_overview();
        }

    </script>

</head>
<body class="nav-md">
    
    <input type="hidden" id="ss_decimal_accuracy" value="2" />
    <input type="hidden" id="ss_currency" value="Rs" />
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
                        


                    </div>
                    <!-- /sidebar menu -->

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
                            <label style="font-weight: bold; font-size: 16px;">Sales Overview</label>

                        </div>

                    </nav>
                </div>
            </div>

            <!-- /top navigation -->
            <!-- page content -->

            <div id="divReportContent" class="text_div">

                <div class="right_col" role="main" id="">
                    <div id="div_sales_overview" class="col-lg-12 col-md-6" style="margin-bottom: 0px; ">

				<div class="card">
					
                     
                    
                     
                    <table style="width:100%">
                            <tr>
                                <td class="col-lg-4">
                                    <div>
                                        <div class="form-group">
                                            <label style="color:#337ab7;font-size:12px">Warehouse</label>
                                            <select id="select_over_view_branch_id" style="background-color:white;color:#000;margin-bottom:5px;" class="form-control border-input">
											<option value="0">All WAREHOUSES</option>
										</select>
                                        </div>
                                    </div>
                                </td>
                                <td class="col-lg-4">
                                    <div>
                                        <div class="form-group">
                                            <label style="color:#337ab7;font-size:12px">User</label>
                                            <select id="Select_sl_ovrvie_user_id" style="background-color:white;color:#000;margin-bottom:5px;" class="form-control border-input">
											<option value="0">All USERS</option>
										</select>
                                        </div>

                                    </div>
                                </td>
                                <td class="col-lg-4">
                                    <div>
                                        <div class="form-group">
                                            <label style="color:#337ab7;font-size:12px">Show</label>
                                            <select id="selInvoiceType" style="background-color:white;color:#000;margin-bottom:5px;" class="form-control border-input">
											<option value="-1">All ORDERS & BILLS</option>
                                                <option value="0">ORDERS ONLY</option>
                                                <option value="1">BILLS ONLY</option>
										</select>
                                        </div>

                                    </div>
                                </td>
                            </tr>
                        </table>


                    
                    <div id="Div20" class="input-group input-group-sm">
                        <table>
                            <tr>
                                <td class="col-lg-3">
                                    <label style="color:#337ab7;font-size:12px">Overview From</label>
                                </td>
                                <td class="col-lg-3">
                                    <label style="color:#337ab7;font-size:12px">Overview Upto</label>
                                </td>
                                 
                            </tr>
                            <tr>
                                
                                <td class="col-lg-3"><input type="text" class="form-control" id="txt_date_overview_from"  placeholder=" overview from" style="background-color: #fff;border:1px solid #337ab7;color:#000; height: 40px; font-size: 17px;"></td>
                                
                                <td class="col-lg-3"><input type="text" class="form-control" id="txt_date_overview_to"  placeholder="overview upto" style="background-color: #fff;border:1px solid #337ab7;color:#000; height: 40px; font-size: 17px;"></td>
                                         <td class="col-lg-3"><button onclick="javascript:get_sales_overview()" id="Button20" style="background-color:#337ab7;color:#fff;border:none;border-radius:2px;width:100%;float:right;height:40px" class="btn btn-info">SEARCH</button></td>
                                <td class="col-lg-3"><button onclick="javascript:reset_SlOverview_Filter();" id="Button19" style="background-color:#808080;color:#fff;border:none;border-radius:2px;width:100%;float:left;height:40px" class="btn btn-info">RESET</button></td>
                 
                            </tr>
                        </table>
                        
                       
                    </div>

                     
                    <div class="form-group" style="width:100%">
											
											
										</div>
                        
                    
                    <h5 class="panel-heading" style="text-align:center;margin:0px;color:#337ab7">Sales Overview<br /><small style="color:#635c5c">Track activities within Date-Range <small style="color:#b53131"><br />(Offline entries not included)</small></small></h5>
                    
                    
                  
					
						 <div id="div27" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#337ab7;display:none">
								OVERVIEW  :
                                <small id="Small1"></small>
								<div class="pull-right">
									 <span class="" id="Span2"></span>
								</div>
							</div>
							<div class="panel-body" id="div28" style="display:none">
								<table class="table" id="Table1">
									<tbody>
                                         
                                        
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Total Sales:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_main_over_total_sales" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Amount Collected from Customer: <br /><small >( Cash & Cheque Included )</small></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_main_over_total_collection" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td  style="font-weight:bolder;font-size:14px;color:#635c5c"><small id="lbl_ovr_in_totcash"></small><small id="lbl_ovr_in_totcheque"></small></td><td><div id="Div37" class="pull-right"></div></td>
                                        </tr>
                                        
									</tbody>
								</table>
							</div>
						</div>
					
						

                    <div id="div29" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#337ab7">
								 SALES SUMMARY :
                                <small id="lbl_main_sl_ovr_hdr"></small><small>( Cancelled & Rejected Orders Excluded )</small>
								<div class="pull-right">
									 <span class="" id="Span3"></span>
								</div>
							</div>
							<div class="panel-body" id="div30">
								<table class="table" id="Table2">
									<tbody>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Total Visits (Check Ins):</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_main_over_total_visit" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Total Active Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_active_order_count" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_active_total_sale" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_active_active_total_receipt" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" >Orders With Balance:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_active_outstanding_count" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" >Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_active_total_outstanding" class="pull-right">0</div></td>
                                        </tr>

                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Credit Note Entries:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_credit_count" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Credit Note Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_credit_amt" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Debit Note Entries:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_debit_count" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Debit Note Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_debit_amount" class="pull-right">0</div></td>
                                        </tr>

                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7">Old Order Entries:</td><td style="font-weight:bolder;font-size:14px;color:#337ab7"><div id="lbl_old_bill_entry" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        
									</tbody>
								</table>
							</div>
						</div>

                    <div id="div35" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#337ab7">
								OTHER PAYMENTS  :
                                <small id="lbl_pay_info_lbl"></small>
								<div class="pull-right">
									 <span class="" id="Span9"></span>
								</div>
							</div>
							<div class="panel-body" id="div36">
								<table class="table" id="Table8">
									<tbody>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Payment Entries:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_old_paycnt" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Amount Recieved:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_old_payamt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        
									</tbody>
								</table>
							</div>
						</div>

                    <div id="div31" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#808080">
								WALLET USAGE :
                                <small></small>
								<div class="pull-right">
									 <span class="" id="Span4"></span>
								</div>
							</div>
							<div class="panel-body" id="div32">
								<table class="table" id="Table3">
									<tbody>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Wallet Withdrawals:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_wallet_count" class="pull-right">0</div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Amount Withdrawn:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sloverview_wallet_used" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        
									</tbody>
								</table>
							</div>
						</div>

                    <div id="div33" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#337ab7">
								SALES RETURNS :
                                <small></small>
								<div class="pull-right">
									 <span class="" id="Span6"></span>
								</div>
							</div>
							<div class="panel-body" id="div34">
								<table class="table" id="Table5">
									<tbody>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Sales Return Entries:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_return_count" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c">Items Worth:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_slover_return_amount" class="pull-right">0</div></td>
                                        </tr>
									</tbody>
								</table>
							</div>
						</div>

                    <div id="div38" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#808080;">
								REGISTRATION INFO :
                                <small></small>
								<div class="pull-right">
									 <span class="" id="Span5"></span>
								</div>
							</div>
							<div class="panel-body" id="div39">
								<table class="table" id="Table4">
									<tbody>
                                        <!--<tr>
                                            <td >Total Check- Ins :</td><td><div id="lbl_ovr_total_checkin" class="pull-right"></div></td>
                                        </tr>-->
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7" >Total Registrations :</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovrview_new_reg_total" class="pull-right"></div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" >Pending Approvals :</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovrview_new_reg_pend" class="pull-right"></div></td>
                                        </tr>
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c" >Approved Registrations :</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovrview_new_reg_approved" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:red" >Rejected Registrations :</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovrview_new_reg_rejected" class="pull-right"></div></td>
                                        </tr>
									</tbody>
								</table>
							</div>
						</div>

                    <div id="div40" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#337ab7;">
								SALES COMMISSION INFO :
                                <small></small>
								<div class="pull-right">
									 <span class="" id="Span7"></span>
								</div>
							</div>
							<div class="panel-body" id="div41">
								<table class="table" id="Table6">
									<tbody>
                                        
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c" >Commission for Delivered Orders :</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_txt_ovr_delivered_commision" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c" >Commission for Orders under Review:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_txt_ovr_review_commision" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#635c5c" >Commission for other Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div class="pull-right" id="lbl_txt_ovr_other_commision">0</div></td>                                            
                                        </tr>
									</tbody>
								</table>
							</div>
						</div>

                    <h5 class="panel-heading" style="text-align:center;margin:0px;color:#337ab7">Orders & Payments In Detail</h5>
                    <hr style="margin:0px;padding:0px" />
					
				<div id="div42" class="panel panel-primary" >
							<div class="panel-heading" style="background-color:#808080;">
								ORDERS & PAYMENT SUMMARY AGAINST ORDER STATUS :
                                <small></small>
								<div class="pull-right">
									 <span class="" id="Span8"></span>
								</div>
							</div>
							<div class="panel-body" id="div43">
								<table class="table" id="Table7">
									<tbody>

                                        <!--new order-->
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" ><b>TO BE CONFIRMED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div44" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" >Total Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_rev_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131" >Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_rev_amt" class="pull-right">0</div></td>
                                        </tr>
                                        

                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#e17605" ><b>NEW ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div57" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#e17605" >Total New Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_new_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#e17605" >Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_new_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#e17605" >Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_new_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#e17605">Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_new_bal" class="pull-right">0</div></td>
                                        </tr>

                                        <!--packed order-->
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#808080" ><b>PACKED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div45" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#808080" >Packed Only Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pak_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#808080">Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pak_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#808080" >Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pak_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#808080" >Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pak_bal" class="pull-right">0</div></td>
                                        </tr>

                                        <!--processed order-->
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#5c84f3" ><b>PROCESSED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div62" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#5c84f3" >Total Processed Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pro_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#5c84f3" >Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pro_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#5c84f3" >Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pro_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#5c84f3" >Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pro_bal" class="pull-right">0</div></td>
                                        </tr>

                                        <!--delivered order-->
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c"><b>DELIVERED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div46" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c" >Total Delivered Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_del_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c" >Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_del_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c" >Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_del_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#25a21c" >Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_del_bal" class="pull-right">0</div></td>
                                        </tr>

                                        <!--pending order-->
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7"><b>PENDING ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div47" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7">Total Pending Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pen_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7">Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pen_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7">Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pen_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#337ab7">Total Balance Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_pen_bal" class="pull-right">0</div></td>
                                        </tr>

                                        <!--cancelled order-->
                                         <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131"><b>CANCELLED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div48" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131">Total Cancelled Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_can_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131">Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_can_amt" class="pull-right">0</div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:#b53131">Total Payment Collected:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_can_paid" class="pull-right">0</div></td>
                                        </tr>
                                         
                                        

                                        <!--rejected order-->
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:red"><b>REJECTED ORDERS</b></td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="Div50" class="pull-right"></div></td>
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:red">Total Rejected Orders:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_rej_cnt" class="pull-right">0</div></td>
                                            
                                        </tr>
                                        <tr>
                                            <td style="font-weight:bolder;font-size:14px;color:red" >Total Net Amount:</td><td style="font-weight:bolder;font-size:14px;color:#635c5c"><div id="lbl_sl_ovr_rej_amt" class="pull-right">0</div></td>
                                        </tr>
                                       <!-- <tr>
                                            <td style="color:red">Total Payment Collected:</td><td><div id="lbl_sl_ovr_rej_paid" class="pull-right">0</div></td>
                                        </tr>-->
                                         
                                        

									</tbody>
								</table>
							</div>
						</div>

					<div class="content" style="margin-left: 10px; margin-right: 10px;">

						
                        <div id="div49"></div>
                        


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
                            Copyright 2019 ©
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
