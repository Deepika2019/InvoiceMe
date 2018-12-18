<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Customers.aspx.cs" Inherits="Customers" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Customers | Invoice Me</title>
    <script src="js/common.js" type="text/javascript"></script>
    <script src="js/jquery-2.0.3.js" type="text/javascript"></script>

    <script type="text/javascript" src="js/pagination.js"></script>
    <script type="text/javascript" src="js/jquery.cookie.js"></script>


    <!--My Styles-->
    <link href="css/bootstrap/mystyle.css" rel="stylesheet" />

    <!-- Bootstrap -->
    <link href="css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="css/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- bootstrap-daterangepicker -->
    <link href="css/bootstrap/daterangepicker.css" rel="stylesheet" />
    <link href="css/bootstrap/mystyle.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="css/bootstrap/custom.min.css" rel="stylesheet" />


    <script type="text/javascript">

        var htm = "";
        var queryParams = {};

        //alert($.cookie("invntrystaffBranchId") + "branchid@customer");
        //alert($.cookie("invntrystaffCountryId") + "cvvcb");

        var BranchId;

        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }

            $("#txtSearch").focus();

            getBranches();



        });
        /*/ function getQueryString(key) {
             //console.log(queryParams);
             return queryParams[key];
         }
         function setQueryParams() {
             queryParams = {};
             var queryStringArray = location.search.replace(/[`~!@#$%^*()|+\?;:'",.<>\{\}\[\]\\\/]/gi, '').split("&");
             //console.log(queryStringArray);
             for (var i = 0; i < queryStringArray.length; i++) {
                 queryParams[queryStringArray[i].split("=")[0]] = queryStringArray[i].split("=")[1];
 
             }
         }
         //  function to get highlighted text-align
         function getHighlightedValue(searchQuery, value) {
             //console.log(value);
             var regex = new RegExp('(' + searchQuery + ')', 'gi');
             var highlightedtext = "<span style='color:#4A2115' >" + searchQuery + "</span>";
             return value.replace(regex, "<span style='color:#4A2115' >$1</span>");
         }*/




        // Start loading branches

        function getBranches() {
            //loading();
            $.ajax({
                type: "POST",
                url: "Customers.aspx/getBranches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--All Warehouses--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    });
                    $("#slBranch").html(htm);
                  //  $("#slBranch").val(BranchId);
                    resetFilters();
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }
        //end
        // start search customers
        function searchCustomers(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }
            //if ($("#slBranch").val() != -1) {
            //    if ($("#slBranch").val() != undefined) {
            //        filters.branch = $("#slBranch").val();
            //    } else {
            //        filters.branch = branchId;
            //    }

            //}
            if ($("#selConfirm").val() != -1 && $("#selConfirm").val() != undefined) {
                filters.istoConfirm = $("#selConfirm").val();
            }
            if ($("#slAccountStatus").val() != -1 && $("#slAccountStatus").val() != undefined) {
                filters.account_status = $("#slAccountStatus").val();
            }
            if ($("#slCustomertype").val() != -1 && $("#slCustomertype").val() != undefined) {
                filters.cus_type = $("#slCustomertype").val();
            }
            if (getQueryString("sellerId") != undefined && getQueryString("sellerId") != "" && getQueryString("sellerId") != "0") {
                filters.seller_id = getQueryString("sellerId");
            }

            // alert(JSON.stringify(filters));
            loading();
            // console.log(filters);
            $.ajax({
                type: "POST",
                url: "Customers.aspx/searchCustomers",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //console.log(msg);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tblCustomers > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblCustomers tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr><td><div style="width:400px;"><div><div class="fl">';
                        htm += '<span class="myorderMData fl">';
                        htm += '<a  href="managecustomers.aspx?cusId=' + row.cust_id + '" target="_blank"><label class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal;cursor:pointer;">#' + getHighlightedValue(filters.search, row.cust_reg_id.toString()) + '</label></a>';
                        //htm += '<a class="fl" style="color: inherit; margin-bottom:0px;" href="managecustomers.aspx?cusId=' + row.cust_id + '">#' + getHighlightedValue(filters.search, row.cust_id.toString()) + '</a >';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.cust_name.toString()) + '</label></span>';
                        htm += '</span>';
                        if (row.outstanding_amount > 0) {
                            htm += '<span class="label label-danger" style="margin-left:2px; margin-right:2px;">Outstanding</span>';
                        }
                        if (row.is_to_confirm) {
                            htm += '<span class="label label-warning"">To be confirmed</span>';
                        }

                        htm += '</div></div><div class="clear"></div>';
                        htm += '<div style="text-align: left;">';
                        htm += '<span class="myorderSData" style="font-size:13px;">' + (row.cust_type == 1 ? "Class A" : (row.cust_type == 2 ? "Class B" : "Class C")) + '</span>';
                        if (row.cust_phone) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-mobile myicons" style="font-size:13px;"></span>';
                            htm += '<span class="myorderSData">' + getHighlightedValue(filters.search, row.cust_phone.toString()) + '</span>';
                        }
                
                        htm += '&nbsp;&nbsp;<span class="fa fa-map-marker myicons" style="font-size:13px;"></span>';
                        htm += '<span class="myorderSData" style="font-size:13px;">' + getHighlightedValue(filters.search,row.cust_address) + '  ' + getHighlightedValue(filters.search,row.cust_city) + ' &nbsp; </span>';
                        
                        if (row.seller_name) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-user myicons" style="font-size:13px;"></span>';
                            htm += '<span class="myorderSData" style="font-size:13px;">' + row.seller_name + '</span>';
                        }
                      
                        htm += '</div></div></td>';
                       
                        htm += '<td style="text-align:center;' + (row.outstanding_amount > 0 ? "color:red" : "color:green") + '">' + row.outstanding_amount + '</td>';
                        htm += '<td>';
                        htm += '<a href="managecustomers.aspx?cusId=' + row.cust_id + '" class="btn btn-primary btn-xs" style="text-align:center;" target="_blank"><li class="fa fa-eye" style="font-size:20px;"></li></a>';
                        htm += '</td></tr>';

                        // alert(htm);

                        $('#tblCustomers > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="4">';
                    htm += '<div  id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblCustomers > tbody').append(htm);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchCustomers"));
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }//end

        function addnewuser() {
            window.location.href = "managecustomers.aspx";
        }



        function resetFilters() {

            var accountStatus = getQueryString("accountStatus");
            var cusType = getQueryString("cusType");
            var confirmCust = getQueryString("cusConfirm");
            var br_id = BranchId;
            var brid = $("#slBranch").val();
            // alert(br_id);
            if (accountStatus == undefined) {
                accountStatus = -1;
            }
            if (cusType == undefined) {
                cusType = -1;
            }
            if (BranchId == undefined) {
                br_id = -1;
            }
            if (confirmCust == undefined) {
                confirmCust = -1;
            }
            $("#txtSearch").val("");
            $("#slBranch").val(-1);
            $("#slAccountStatus").val(accountStatus);
            $("#slCustomertype").val(cusType);
            $("#selConfirm").val(confirmCust);
            searchCustomers(1);
        }




    </script>
</head>
<body class="nav-md">
    <form id="form1" runat="server">
        <div class="container body">
            <div class="main_container">
                <div class="col-md-3 left_col">
                    <div class="left_col scroll-view">
                        <div class="navbar nav_title" style="border: 0;">
                            <a href="../index.html" class="site_title">
                                <!--<i class="fa fa-paw"></i>-->
                                <span>Invoice</span></a>
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
                            <a data-toggle="tooltip" data-placement="top" title="Logout">
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
                                <div class="col-md-6 col-xs-6">
                                    <label style="font-weight: bold; font-size: 16px;">Customers</label>
                                </div>

                                <div class="col-md-6 col-xs-5">



                                    <div onclick="javascript:addnewuser();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New Customer</div>
                                  
                                </div>

                            </div>

                        </nav>
                    </div>
                </div>
                <!-- /top navigation -->


                <!-- page content -->
                <div class="right_col" role="main">
                    <div class="">
                        <div class="page-title">
                            <div class="title_left" style="width: 100%;">
                                <%-- <label style="font-size:16px; font-weight:bold;">Customers</label--%>
                                <%-- <div class="col-xs-12 col-centered col-max">
                                    <button type="button" class="btn btn-warning pull-right" style="font-size: 11px; padding: 4px; font-weight: bold;" onclick="javascript:addnewuser();">
                                        <li class="fa fa-star-o" style="margin-right: 5px;"></li>
                                        New
                                    </button>
                                </div>--%>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Filter</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>
                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <form class="form-horizontal form-label-left input_mask">
                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="selConfirm" class="form-control" style="text-indent: 25px;" onchange="searchCustomers(1);">
                                                    <option value="-1" selected="selected">--All customers--</option>
                                                    <option value="1">Customers to confirm</option>
                                                    <%--          <option value="-1" selected="selected">--All customers--</option>--%>
                                                </select>
                                                <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                            </div>


                                            <%--<div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="slBranch" class="form-control" style="text-indent: 25px;" onchange="searchCustomers(1);">
                                                </select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>--%>

                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="slAccountStatus" class="form-control" style="text-indent: 25px;" onchange="searchCustomers(1);">
                                                    <option value="-1" selected="selected">--Account Status--</option>
                                                    <option value="0">No outstanding</option>
                                                    <option value="1">Have outstanding</option>
                                                </select>
                                                <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="slCustomertype" onchange="searchCustomers(1);">
                                                    <option value="-1" selected="selected">--Customer Type--</option>
                                                    <option value="1">Class A</option>
                                                    <option value="2">Class B</option>
                                                    <option value="3">Class C</option>
                                                </select>
                                                <span class="fa fa-users form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-10 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="Customer ID/Name/Phone/Reg Id/Address/City" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback pull-right">
                                                  <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:resetFilters();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </button>
                                                <button type="button" class="btn btn-success mybtnstyl pull-right" onclick="javascript:searchCustomers(1);">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </button>
                                            
                                              
                                            </div>


                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <label>Customer List<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</span></label>
                                        <ul class="nav navbar-right panel_toolbox">
                   
                                            <li>

                                                <select class="input-sm" id="slPerpage" onchange="javascript:searchCustomers(1);">
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                    <option value="200">200</option>
                                                </select>



                                            </li>
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>
                                            <li class="dropdown">
                                                <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"></a>

                                            </li>
                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                        </ul>
                                        <div class="clearfix"></div>
                                    </div>
                                    <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                        <div class="x_content">
                                            <table id="tblCustomers" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>Customer</th>
                                               
                                                        <th style="text-align: center;">Account Balance</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%--<tr>
								  <td>
									  <div style="width:300px;">
										  <div>
											  <div class="fl">
												  <span class="myorderMData fl">
												  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
												  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
												  </span>
											  <span class="label label-danger">Outstanding</span>
											  </div>
										  </div>
										  <div class="clear"></div>
									  <div style="text-align: left;">
									  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
									  <span class="myorderSData">sales1 sl</span></div></div>
								  </td>
								  <td>5</td>
								  <td>2</td>
								  <td>
									<a href="#" class="btn btn-primary btn-xs">
										<li class="fa fa-folder-open"></li> View Details
									</a>
								  </td>
								</tr>
								<tr>
								 <td>
									 <div style="width:300px;">
										  <div>
											  <div class="fl">
												  <span class="myorderMData fl">
												  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
												  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
												  </span>
											  <span class="label label-success">Outstanding</span>
											  </div>
										  </div>
										<div class="clear"></div>
									  <div style="text-align: left;">
									  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
									  <span class="myorderSData">sales1 sl</span></div>
									  </div>
								  </td>
								  <td>6</td>
								  <td>3</td>
								  <td>		
									  <a href="newcustomer.html" class="btn btn-primary btn-xs">
											<li class="fa fa-folder-open"></li> View Details
									</a>
								</td>
								</tr>
							    <tr>
								 <td>
								 <div style="width:300px;">
									  <div>
										  <div class="fl">
											  <span class="myorderMData fl">
											  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
											  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
											  </span>
										  <span class="label label-primary">Outstanding</span>
										  </div>
									  </div>
							<div class="clear"></div>
								  <div style="text-align: left;">
								  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
								  <span class="myorderSData">sales1 sl</span></div></div></td>
								  <td>9</td>
								  <td>3</td>
								  <td>		<a href="#" class="btn btn-primary btn-xs">
										<li class="fa fa-folder-open"></li> View Details
									</a></td>
								</tr>
								<tr>
								  <td>
								  <div style="width:300px;">
									  <div>
										  <div class="fl">
											  <span class="myorderMData fl">
											  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
											  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
											  </span>
										  <span class="label label-warning">Outstanding</span>
										  </div>
									  </div>
								     <div class="clear"></div>
									  <div style="text-align: left;">
								  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
								  <span class="myorderSData">sales1 sl</span></div>
								  </div>
								  </td>
								  <td>5</td>
								  <td>2</td>
								  <td>
									<a href="newcustomer.html" class="btn btn-primary btn-xs">
										<li class="fa fa-folder-open"></li> View Details
									</a>
								</td>
								</tr>
								<tr>
								  <td>
								  <div style="width:300px;">
									  <div>
										  <div class="fl">
											  <span class="myorderMData fl">
											  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
											  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
											  </span>
										  <span class="label label-default">Outstanding</span>
										  </div>
									  </div>
							<div class="clear"></div>
								  <div style="text-align: left;">
								  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
								  <span class="myorderSData">sales1 sl</span></div></div>
								  </td>
								  <td>5</td>
								  <td>2</td>
								  <td>
									<a href="newcustomer.html" class="btn btn-primary btn-xs">
										<li class="fa fa-folder-open"></li> View Details
									</a>
								</td>
								</tr>
								<tr>
								  <td>
								  <div style="width:300px;">
									  <div>
										  <div class="fl">
											  <span class="myorderMData fl">
											  <a class="fl" style="color: inherit; margin-bottom:0px;" href="">#3</a>&nbsp;&nbsp;&nbsp;
											  <label class="fl" style="margin-bottom:0px;"><a>Abdul Razzaq Supermarket</a></label>
											  </span>
										  <span class="label label-info">Outstanding</span>
										  </div>
									  </div>
							<div class="clear"></div>
								  <div style="text-align: left;">
								  <span class="myorderSData">Class A</span>&nbsp;&nbsp;<span class="fa fa-mobile myicons" ></span><span class="myorderSData">971 6 7412839</span>&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span><span class="myorderSData">Abu Dhabi</span>&nbsp;&nbsp;<span class="fa fa-user myicons"></span>
								  <span class="myorderSData">sales1 sl</span></div></div>
								  </td>
								  <td>5</td>
								  <td>2</td>
								  <td>
									<a href="newcustomer.html" class="btn btn-primary btn-xs">
										<li class="fa fa-folder-open"></li> View Details
									</a>
								</td>
								</tr>--%>








                                                    <tr>
                                                        <td colspan="4"></td>
                                                    </tr>
                                                </tbody>
                                            </table>

                                            <%--	<table>
        <tr>
            <td>
                    <div class="row">
				    <div class="col-md-8 col-sm-12 col-xs-12 text-center">
                    <div style="text-align:center;" id="divPagination"></div>
					
			
                </div>
				</div>
            </td>
        </tr>
	</table>--%>
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
                        Copyright 2017 ©
                    </div>
                    <div class="clearfix"></div>
                </footer>
                <!-- /footer content -->

            </div>
        </div>
    </form>

    <!-- jQuery -->
    <%--<script src="js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="js/bootstrap/nprogress.js"></script>
    <!-- iCheck -->
    <script src="js/bootstrap/icheck.min.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="js/bootstrap/custom.min.js"></script>
    <script src="js/bootbox.min.js"></script>
</body>
</html>
