<%@ Page Language="C#" AutoEventWireup="true" CodeFile="productOverview.aspx.cs" Inherits="reports_ReportAll" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
     	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
    <title>Products Overview | Invoice Me</title>

     <script type="text/javascript" src="../js/common.js"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script> 
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/jQuery.print.js"></script>
    <script type="text/javascript" src="../js/pagination.js"></script>
    
    

      <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet"/>
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet"/>
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet"/>
    <!-- iCheck -->
    <link href="../css/bootstrap/green.css" rel="stylesheet"/>

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet"/>
    <!-- mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet"/>


    <!--date picker-->
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!--date picker-->

    <script type="text/javascript">
        var BranchId;
        $(document).ready(function () {
            var userid = $.cookie("invntrystaffId");
            //  alert(userid);
            if (!userid) {
                location.href = "../login.aspx";
                return false;
            }
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }

          showBrand();
          ShowUTCDate();
          $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
        });

        $(function () {
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();

            $('#txtPOFrom').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'dd-mm-yy'
            });
            $('#txtPOTo').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'dd-mm-yy'
            });
        });

        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#txtPOFrom").val(localdate);
            $("#txtPOTo").val(localdate);
            return;
        }

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }//end date picker


        // show brands start (18-04-2017)


        function showBrand() {
            loading();
            $.ajax({
                type: "POST",
                url: "productOverview.aspx/ShowItemBrands",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--Select Brand--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.brand_id + '">' + row.brand_name + '</option>';
                    });
                    $("#selBrand").html(htm);
                    ShowItemCategry();
                      Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }// end brandname
        //category show
        function ShowItemCategry() {
            loading();
            $.ajax({
                type: "POST",
                url: "productOverview.aspx/ShowItemCategry",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">--Select Category--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cat_id + '">' + row.cat_name + '</option>';
                    });
                    $("#selCategory").html(htm);
                    showsalespersons();
                      Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");

                }
            });
        }//end category

        //show sales person

        function showsalespersons() {
            loading();
            $.ajax({
                type: "POST",
                url: "productOverview.aspx/showsalespersons",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="0" selected="selected">-- Select Salesperson--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.user_id + '">' + row.first_name + '&nbsp' + row.last_name + '</option>';
                    });
                    $("#comboSalesInReport").html(htm);
                    getProductOverview();
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }//end


        function resetProductOverviewFilter() {
            $("#selBrand").val(0);
            $("#selCategory").val(0);
            $("#comboSalesInReport").val(0);
            
            ShowUTCDate();
            getProductOverview();
        }







        function getProductOverview() {
            var postObj = {
                filters: {}
            };
            if ($.trim($("#txtPOFrom").val()) != "") {
                postObj.filters.dateFrom = $("#txtPOFrom").val();
            }
            if ($.trim($("#txtPOTo").val()) != "") {
                postObj.filters.dateTo = $("#txtPOTo").val();
            }
            if ($("#selBrand").val() != "0") {
                postObj.filters.brand = $("#selBrand").val();
            }
            if ($("#selCategory").val() != "0") {
                postObj.filters.category = $("#selCategory").val();
            }
            if ($("#comboSalesInReport").val() != "0") {
                postObj.filters.salesperson = $("#comboSalesInReport").val();
            }
           // alert(postObj.filters);
            $("#tblPOBrands tbody").html("");
            loading();
            $.ajax({
                type: "POST",
                url: "productOverview.aspx/getProductOverview",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                crossDomain: true,
               // timeout: 10000,
                success: function (msg) {
                    Unloading();
                    //alert(msg.d);
                    var msgObj = JSON.parse(msg.d);
                   // console.log(msgObj);
                    $("#lblTotalSales").text(msgObj.net_sales);
                    $.each(msgObj.overview, function (i, brand) {
                        var tr = document.createElement('tr');
                        tr.innerHTML = '<td>' + brand.brand + '</td><td><div class="pull-right">' + brand.tot_sales + '(' + brand.sales_percentage + '%)</div></td>';
                        if (brand.sales_count != 0) {
                            tr.onclick = function () {
                                showBrandOverview(this, brand.brand_id, postObj.filters)
                            };
                        }
                        //$("#tblPOBrands tbody").append('<tr class="" onclick="showBrandOverview(this,'+brand.brand_id+','+JSON.stringify(postObj.filters)+')"><td>'+brand.brand+'</td><td><div class="pull-right">'+brand.tot_sales+'('+brand.sales_percentage+'%)</div></td></tr>');
                        $("#tblPOBrands tbody").append(tr);

                    });
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        // to show brand overview
        function showBrandOverview(tr, brandId, filters) {
           // alert("");
            $(tr).addClass("info");
            console.log(filters);
            setTimeout(function () {
                $(tr).removeClass("info");
                getBrandOverview(brandId, filters);
                $("#divSummryall").hide();
                $("#divFilter").hide();
                $("#divBckTo").show();
                $("#divBrandOverview").show();
               // showpage('divBrandOverview');
            }, 100);
        }
        //function for backpage
        function backpage() {
            $("#divSummryall").show();
            $("#divFilter").show();
            $("#divBckTo").hide();
            $("#divBrandOverview").hide();
        }
        // function to get brand overview
        function getBrandOverview(brandId, filters) {
            var postObj = {
                filters: {}
            };
            if (filters) {
                postObj.filters = filters;
            }
            postObj.filters.brand = brandId;
            $("#tblItemsOverview tbody").html("");
            $("#spanBrandName").text("");
            loading();
            $.ajax({
                type: "POST",
                url: "productOverview.aspx/getBrandOverview",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                crossDomain: true,
               // timeout: 10000,
                success: function (msg) {
                    Unloading();
                    var msgObj = JSON.parse(msg.d);
                    //console.log(msgObj);
                    $("#lblBrandTotalSales").text(msgObj.net_sales);
                    $("#spanBrandName").text(msgObj.brand + (msgObj.category ? "(" + msgObj.category + ")" : ""));

                    $.each(msgObj.overview, function (i, item) {
                        $("#tblItemsOverview tbody").append('<tr class=""><td>' + item.item + '</td><td><div class="pull-right">' + item.tot_sales + '(' + item.sales_percentage + '%)</div></td></tr>');
                    });
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
              <a href="../index.html" class="site_title"><!--<i class="fa fa-paw"></i> --><span>Invoice Me</span></a>
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
                  <li><a href="../index.html"a><i class="fa fa-home"></i> Home <span class="fa fa-chevron-down"></span></a>
                  </li>
				    <li><a><i class="fa fa-user"></i> Customer <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
					<li><a href="../customer/newcustomer.html">New Customer</a></li>
                      <li><a href="../customer/customers.html"> Customers</a></li>
                      <li><a href="../customer/customerconfirmation.html">Customer Confirmation</a></li>
                      <li><a href="../customer/assigncustomers.html">Assign Customer</a></li>
                    </ul>
                  </li>
				  <li><a><i class="fa fa-shopping-cart"></i> Sales <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="#">New Order</a></li>
                      <li><a href="#">Orders</a></li>
                           <li><a href="#">Edit Order</a></li>
						        <li><a href="#">Confirm Order</a></li>
                    </ul>
                  </li>
				  		  <li><a><i class="fa fa-cubes"></i> Inventory <span class="fa fa-chevron-down"></span></a>
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
				  		  <li><a><i class="fa fa-wrench"></i> OP Center <span class="fa fa-chevron-down"></span></a>
                    <ul class="nav child_menu">
                      <li><a href="../opcenter/manageuser.html">Manage User</a></li>
                      <li><a href="#">Manage Role</a></li>
                           <li><a href="#">Track Users</a></li>
                    </ul>
                  </li>
				  <li><a><i class="fa fa-gears"></i> Settings <span class="fa fa-chevron-down"></span></a>
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

                            <div class="navbar-header col-md-12 col-sm-12 col-xs-12" style="width: 100%; display: flex; align-items: center">
                                <div class="nav toggle" style="padding: 5px;">
                                    <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                                </div>
                                <div style="font-weight: bold; font-size: 16px;" class="col-md-12 col-sm-12 col-xs-12">Products Overview</div>
                                <div type="button" class="btn btn-success pull-right " style="font-size: 11px; padding: 4px; font-weight: bold;display:none;" onclick="javascript:backpage();" id="divBckTo">
                                    <span class="fa fa-arrow-left"></span>
                                </div>
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
                <label style="font-size:18px; font-weight:normal;">Sales Report</label>
              </div>--%>  
            </div>

            <div class="clearfix"></div>

            <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12" id="divFilter">
                <div class="x_panel" style="padding-left:5px;padding-right:5px;">
                  <div class="x_title" style="margin-bottom:2px; padding:0px 0px 0px;">
                      <label>Filter</label>
                    <ul class="nav navbar-right panel_toolbox">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
               
                    </ul>                          
                      <div class="clearfix"></div>
                  </div>
                  <div class="x_content">

                    <section class="content invoice">
                      <!-- title row -->
                        <div class="col-md-10 col-sm-6 col-xs-12 form-group has-feedback" id="divTophead" style="padding-left:0px; padding-right:0px;">
                      <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback"  id="divshwBranch" >
                           <div id="showBranchesDiv">
							<select id="selBrand" style="text-indent:25px;" class="form-control">
										
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-briefcase form-control-feedback left"></span>
							  </div>

                            <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback"  id="div1" >
                           <div id="ShowCategrydiv">
							<select id="selCategory" style="text-indent:25px;" class="form-control">
										
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-clone form-control-feedback left"></span>
							  </div>
                             <div class="col-md-6 col-sm-6 col-xs-12 form-group has-feedback"  id="div2" >
                           <div id="ShowSalesPersnDiv">
							<select id="comboSalesInReport" style="text-indent:25px;" class="form-control">
										
                          				</select>
                               </div>
								<span aria-hidden="true" class="fa fa-users form-control-feedback left"></span>
							  </div>






                      <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divfrmdte">
                        <input type="text" placeholder="From Date" id="txtPOFrom" class="form-control has-feedback-left"/>
                           <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                        </div>
                      <div class="col-md-3 col-sm-6 col-xs-12 form-group" id="divtodate">
                              <input type="text" placeholder="To Date" id="txtPOTo" class="form-control has-feedback-left"/>
                                             <span aria-hidden="true" class="fa fa-calendar form-control-feedback left"></span>
                                        </div>
                          </div>
                      <div class="col-md-2 col-sm-6 col-xs-12 form-group" id="divBtnSechReset">
                                <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-primary pull-right" type="button" onclick="javascript:resetProductOverviewFilter();">
						<li style="margin-right:5px;" class="fa fa-refresh"></li>Reset 
					</button>
                 
                           <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-success pull-right" type="button"  onclick="javascript:getProductOverview()">
						<li style="margin-right:5px;" class="fa fa-search"></li>Search 
					</button>
                        
                           </div>
                          <div class="clearfix"></div>
                      <!-- info row -->
                  
                      <!-- /.row -->

                      <!-- Table row -->
                        <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                    
                                
                        <!-- /.col -->
                    
                            </div>
                      <!-- /.row -->


                    </section>
                  </div>
                </div>
              </div>
            </div>

              <div class="clearfix"></div>

             <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
                <div class="x_panel">
                  <div style="margin-bottom:0px;" class="x_title">
                    <label>View</label>
                      
                    <ul class="nav navbar-right panel_toolbox pull-right">
                      <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                      </li>
                    
              
                    </ul>
                  </div>
                  <div class="x_content">

                    <section class="content invoice">
                        <div class="row" id="divSummryall">         
                          <div class="clearfix"></div>                       
                 <%-- content invoice--%>
                          <div id="divPOSummery" class="panel panel-primary">
							<div class="panel-heading">
								Overview
								<div class="pull-right">
									Total = <span class="" id="lblTotalSales">0</span>
								</div>
							</div>
							<div class="panel-body" id="divOverviewBrands">
								<table class="table" id="tblPOBrands">
									<tbody>

									</tbody>
								</table>
							</div>
						</div>
                      </div>
                      <!-- /.row -->
                        
			<div id="divBrandOverview" class="overview col-md-12 col-sm-12 col-xs-12" style="margin-bottom: 0px;padding-left:0px;padding-right:0px; display:none">

				<div class="card">
					<div class="content" style="">
						<div id="div3" class="panel panel-primary col-md-12 col-sm-12 col-xs-12" style="overflow-x:auto; padding-left:0px; padding-right:0px;">
							<div class="panel-heading" style="width:100%;">
								<span id="spanBrandName"></span>
								<div class="clearFix"></div>
								<div style="text-align:right">
									Total = <span class="" id="lblBrandTotalSales">0</span>
								</div>
							</div>
							<div class="panel-body" id="Div4">
								<table class="table" id="tblItemsOverview" style="table-layout:auto;">
									<tbody>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
                    </section>
                  </div>
                </div>
              </div>
            </div>


            </div>
          </div>
        </div>
        <!-- /page content -->
     </div>

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
    <%--<script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>

     <!-- Alert Scripts -->
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
