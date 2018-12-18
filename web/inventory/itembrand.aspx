<%@ Page Language="C#" AutoEventWireup="true" CodeFile="itembrand.aspx.cs" Inherits="inventory_itembrand" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Item Brand  | Invoice Me</title>
    <script src="../js/common.js"></script>
    <script src="../js/jquery-2.0.3.js"></script>
    <script src="../js/pagination.js"></script>
    <script src="../js/jquery.cookie.js"></script>
    <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />

    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!-- mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            //if (!BranchId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            //if (!CountryId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            // showProfileHeader(1);
            clearbrandData();
            searchBrand(1);
            //  clearCorporateMasterReg();
            //  searchCorporateMaster(1);
            //   RetrieveTaxDetails();
            // disablePaymentFields();

        });
        //Start:TO Replace single quotes with double quotes
        function sqlInjection() {
            $('input, select, textarea').each(
                function (index) {
                    var input = $(this);
                    var type = this.type ? this.type : this.nodeName.toLowerCase();
                    //alert(type);
                    if (type == "text" || type == "textarea") {
                        $("#" + input.attr('id')).val(input.val().replace(/'/g, '"'));
                    }
                    else {
                    }
                }
            );
        }
        //Stop:TO Replace single quotes with double quotes

        function AddNewBrand(actionType, typeid) {

            sqlInjection();

            var brandname = $.trim($("#txtbrandName").val());

            if (brandname == "") {
                alert("Please Enter Brand Name...!");
                return;
            }

            loading();
            $.ajax({
                type: "POST",
                url: "itembrand.aspx/AddNewBrand",
                //timeout: 20,
                data: "{'actionType':'" + actionType + "','typeid':'" + typeid + "','brandname':'" + brandname + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    
                    // alert(msg.d);
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Brand Added Successfully");
                            //searchCorporateMaster(1);
                            //clearCorporateMasterReg();
                            searchBrand(1);
                            clearbrandData();
                            return;
                        }
                        if (actionType == "update") {
                            alert("Brand Updated Successfully");
                            //searchCorporateMaster(1);
                            //clearCorporateMasterReg();
                            searchBrand(1);
                            clearbrandData();
                            return;
                        }
                        Unloading();
                    }
                    else {
                        alert("Brand already exist");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //search customertype
        function searchBrand(page) {
            //alert(page);
            sqlInjection();
            var filters = {};

            if ($("#searchBrand1").val() !== undefined && $("#searchBrand1").val() != "") {
                filters.brand_id = $("#searchBrand1").val();
            }

            if ($("#searchBrand2").val() !== undefined && $("#searchBrand2").val() != "") {
                filters.brand_name = $("#searchBrand2").val();
            }

            var perpage = $("#txtpageno").val();
            console.log(JSON.stringify(filters));

            loading();
            $.ajax({
                type: "POST",
                url: "itembrand.aspx/searchBrand",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    if (msg.d == "N") {
                        Unloading();
                        $("#divBrandShowtbl1 tbody").html('<td colspan="3" style="background:#ebebeb; padding:5px;font-weight:bold;" ><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatediv").html("");
                        $("#lblTotalrerd").text(0);
                        //alert("No Search Results");
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        //  console.log(obj);
                        Unloading();
                        var htm = "";
                        //htm += '<tr style="font-size:12px;">';
                        //htm += '<td colspan="3" style="padding:5px; text-align:center; overflow:hidden; border-right:none;">';
                        //htm += '<div><span style="margin-left:0px;float:right;text-align:right;font-size:14px;">Total Records:' + obj.count + '</span></div>';
                        //htm += '</td> </tr>';
                        $.each(obj.data, function (i, row) {
                            // console.log(row);
                            htm += "<tr onclick=javascript:editbranddetail(" + row.brand_id + "); id='vendorRow" + i + "'>";
                            htm += "<td><div>" + getHighlightedValue(filters.brand_id, row.brand_id.toString()) + "</div></td>";
                            htm += "<td><div>" + getHighlightedValue(filters.brand_name, row.brand_name) + "</div></td>";
                            htm += "<td> <button class='btn btn-primary btn-xs'><li class='fa fa-folder-open'></li>View</button><div onclick=javascript:editbranddetail(" + row.brand_id + ");></div></td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="3">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#divBrandShowtbl1 tbody").html(htm);
                        $("#lblTotalrerd").text(obj.count);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "searchBrand"));
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });

        }

        //function for edit customertype details
        function editbranddetail(typeid) {
            loading();
            $.ajax({
                type: "POST",
                url: "itembrand.aspx/editbranddetail",
                data: "{'typeid':'" + typeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d != 0) {

                        var splitarray = msg.d.split("@#$");
                        $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl'  onclick='javascript:AddNewBrand(\"update\"," + splitarray[0] + ");'>UPDATE</div>");
                        $("#txtbrandName").val(splitarray[1]);


                        $('html,body').animate({
                            scrollTop: $('#Divbranddetails').offset().top
                        }, 500);
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //function for clear form
        function clearbrandData() {
            $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:AddNewBrand(\"insert\",0);'>SAVE</div>");
            //   $("#txtCorporateID").val('');
            $("#txtbrandName").val('');
            $("#searchBrand1").val('');
            $("#searchBrand2").val('');

        }

        //function for reset
        function resetcustomertype() {
            for (var i = 1; i <= 2; i++) {

                $("#searchBrand" + i).val('');

            }
            searchBrand(1);
        }
    </script>
</head>
<body class="nav-md">
    <div class="container body">
        <div class="main_container">
            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">
                    <div class="navbar nav_title" style="border: 0;">
                        <a href="#" class="site_title">
                            <!--<i class="fa fa-paw"></i> -->
                            <span>Invoice Me</span></a>
                    </div>

                    <div class="clearfix"></div>

                    <!-- menu profile quick info -->
                    <div class="profile clearfix">
                        <div class="profile_pic">
                            <%--<img src="../images/img.jpg" alt="..." class="img-circle profile_img">--%>
                        </div>
                        <div class="profile_info">
                            <%--<span>Welcome,</span>
                <h2>John Doe</h2>--%>
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
                        <a data-toggle="tooltip" data-placement="top" title="Logout" href="">
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
                              <div class="col-md-6 col-xs-5">
                            <label style="font-weight: bold; font-size: 16px;">Item Brand</label>
                                  </div>

                            <div class="col-md-6 col-xs-5">

                                    <div onclick="javascript:clearbrandData();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New</div>
                                  
                                </div>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%--     <div class="page-title">
			
              <div class="title_left" style="width:100%;">
                <label style="font-size:18px; font-weight:normal;">Item Brand</label>
              </div>
        
            </div>--%>

                    <%--  <div class="clearfix"></div>--%>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="Divbranddetails">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Brand Details </label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <br />
                                    <form id="demo-form2" data-parsley-validate class="form-horizontal form-label-left">


                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Item Brand Name<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtbrandName" placeholder="Enter Brand Name" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                                  <div class="col-md-3 col-sm-6 col-xs-12">
                                          
                                            <div id="btnservMasterAction">
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:AddNewBrand('insert',0);">SAVE</div>
                                            </div>

                                            <div onclick="javascript:clearbrandData();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                        </div>
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
                                    <label>Brands<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <div class="row" style="margin-bottom: 5px;">

                                        <%--<div class="form-group"  style="float:right;">
								<div class="col-md-12 col-sm-12 col-xs-12 ">
								  
								
								  <div onclick="javascript:searchBrand(1);" class="btn btn-success mybtnstyl">
								  <li class="fa fa-search" style="margin-right:5px;" ></li>Search
								  </div>
								     <div class="btn btn-primary mybtnstyl" onclick="javascript:resetcustomertype();">
									 <li class="fa fa-refresh" style="margin-right:5px;"></li>Reset
									 </div>
								</div>
							  </div>       --%>
                                        <div class="form-group" style="float: right; padding-bottom: 5px;">
                                            <div class="col-md-12 col-sm-12 col-xs-12 ">
                                              <%--  <div style="float: left; margin-right: 10px; line-height: 30px;">
                                                    <span><strong>Total Records:
                                                        <label id="lblTotalrerd"></label>
                                                    </strong></span>
                                                </div>--%>
                                                <div style="float: left;">
                                                    <button type="button" class="btn btn-success mybtnstyl" onclick="javascript:searchBrand(1);">
                                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                        Search</button>
                                                    <button class="btn btn-primary mybtnstyl" type="button" onclick="javascript:resetcustomertype();">
                                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                        Reset</button>
                                                </div>
                                            </div>
                                        </div>


                                        <div class="form-group" style="float: right;">
                                            <div class="col-md-4 col-sm-3 col-xs-4">
                                                <div class="dataTables_length" id="datatable-checkbox_length">
                                                    <label>
                                                        <select id="txtpageno" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class="input-sm" onchange="searchBrand(1);">
                                                            <option value="20">20</option>
                                                            <option value="50">50</option>
                                                            <option value="100">100</option>
                                                            <option value="500">500</option>
                                                        </select>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>


                                    <table id="divBrandShowtbl1" class="table table-striped table-bordered">
                                        <thead>
                                            <tr>
                                                <th>ID</th>

                                                <th>Brand Name	</th>

                                                <th>View</th>

                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="text" id="searchBrand1" placeholder="search" style="padding:0px; text-indent:3px;" class="form-control" /></td>
                                                <td>
                                                    <input type="text" id="searchBrand2" placeholder="search" class="form-control" /></td>
                                                <td></td>
                                            </tr>
                                        </thead>


                                        <tbody>
                                        </tbody>
                                    </table>

                                </div>

                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>


                </div>
            </div>
            <!-- /page content -->

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

    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>

</body>
</html>
