<%@ Page Language="C#" AutoEventWireup="true" CodeFile="vendors.aspx.cs" Inherits="inventory_vendors" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>vendors | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script src="../js/jquery-2.0.3.js" type="text/javascript"></script>

    <script type="text/javascript" src="../js/pagination.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>


    <!--My Styles-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />

    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- bootstrap-daterangepicker -->
    <link href="../css/bootstrap/daterangepicker.css" rel="stylesheet" />
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />


    <script type="text/javascript">

        var htm = "";
        var queryParams = {};
        var BranchId;
        var CountryId = $.cookie("invntrystaffCountryId");
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }
            resetFilters();
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

        // start search vendors
        function searchSuppliers(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            if ((!BranchId || BranchId == "undefined" || BranchId == "" || BranchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "../dashboard.aspx";
                return false;
            }
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }

            // alert(JSON.stringify(filters));
            loading();
            // console.log(filters);
            $.ajax({
                type: "POST",
                url: "vendors.aspx/searchSuppliers",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tblvendors > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblvendors tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm += '<tr><td><div style="width:400px;"><div><div class="fl">';
                        htm += '<span class="myorderMData fl">';
                        htm += '<a class="fl" style="color: inherit; margin-bottom:0px;" href="managevendor.aspx?vendorId=' + row.vn_id + '">#' + getHighlightedValue(filters.search, row.vn_id.toString()) + '</a >';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.vn_name.toString()) + '</label></span>';
                        htm += '</span>';
                        if (row.vn_balance > 0) {
                            htm += '<span class="label label-danger" style="margin-left:2px; margin-right:2px;">Outstanding</span>';
                        }

                        htm += '</div></div><div class="clear"></div>';
                        htm += '<div style="text-align: left;">';
                        if (row.vn_phone1) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-mobile myicons"></span>';
                            htm += '<span class="myorderSData">' + row.vn_phone1 + '</span>';
                        }
                        if (row.vn_city) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span>';
                            htm += '<span class="myorderSData">' + row.vn_city + '</span>';
                        }

                        htm += '</div></div></td>';
                        if (row.vn_balance <= 0) {
                            htm += '<td style="text-align:center;color:green">' + (-1) * row.vn_balance + '</td>';
                            htm += '<td style="text-align:center;color:red">0</td>';
                            
                        } else {
                            htm += '<td style="text-align:center;color:green">0</td>';
                            htm += '<td style="text-align:center;color:red">' +row.vn_balance + '</td>';
                        }
                       
                        htm += '<td>';
                        htm += '<a href="managevendor.aspx?vendorId=' + row.vn_id + '" class="btn btn-primary btn-xs"><li class="fa fa-eye" style="font-size:large;" data-toggle="tooltip" data-placement="left" title="View"></li></a><a href="#" class="btn btn-primary btn-xs"><li class="fa fa-trash-o" style="font-size:large;" data-toggle="tooltip" data-placement="left" title="Delete" onclick="deleteVendor(' + row.vn_id + ')"></li></a>';
                        htm += '</td></tr>';

                        // alert(htm);

                        $('#tblvendors > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="4">';
                    htm += '<div id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblvendors > tbody').append(htm);
                    //$('#tblvendors > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchSuppliers"));
                  

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }//end


        function resetFilters() {
            $("#txtSearch").val("");
            searchSuppliers(1);
        }

        //Add vendor
        function addVendorDetails() {
            sqlInjection();
            var Name = $("#txtName").val();
            var mobile = $("#txtPhone1").val();
            var gstNumber = $("#txtGstNo").val();
            var telephone = $("#txtPhone2").val();
            var Emailid = $("#txtEmailid").val();
            var Address = $("#txtAddress").val();
            var City = $("#txtCity").val();
            var State = $("#txtState").val();
            var Country = $("#txtCountry").val();

            if (Name == "") {
                alert("Enter Name");
                $("#txtName").focus();
                return false;
            }
            if (mobile == "") {
                alert("Enter phone number");
                $("#txtPhone").focus();
                return false;
            }
            if (Address == "") {
                alert("Enter Address");
                $("#txtAddress").focus();
                return false;
            }
            if (City == "") {
                alert("Enter city");
                $("#txtCity").focus();
                return false;
            }
            if (Country == "") {
                alert("Enter country");
                $("#txtCountry").focus();
                return false;
            }
           
            loading();
            $.ajax({
                type: "POST",
                url: "vendors.aspx/addVendorDetails",
                data: "{'Name':'" + Name + "','mobile':'" + mobile + "','telephone':'" + telephone + "','Emailid':'" + Emailid + "','Address':'" + Address + "','City':'" + City + "','State':'" + State + "','Country':'" + Country + "','gst':'" + gstNumber + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    
                    if (msg.d == "Y") {
                        alert("Supplier has been saved");
                        clearVendorDetails();
                        popupclose('popupVendor');
                        searchSuppliers(1);
                        return false;
                    } else {
                        alert("There is an error...");
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                    return false;
                }
            });

        }
        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function clearVendorDetails() {
            $("#txtName").val("");
            $("#txtPhone1").val("");
            $("#txtPhone2").val("");
            $("#txtEmailid").val("");
            //$("#comboUsertype").val("1");
            $("#txtAddress").val("");
            $("#txtCity").val("");
            $("#txtState").val("");
            $("#txtCountry").val("");
          //  $("#popupVendor").modal('hide');
        }

        function deleteVendor(id) {
            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the vendor?");
            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "vendors.aspx/deleteVendor",
                    data: "{'vendor_id':'" + id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                           bootbox. alert("Supplier Deleted Successfully");
                           searchSuppliers(1);

                        }
                        else if (msg.d == "E") {
                            alert("Supplier Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("Supplier Deletion Failed");

                        }

                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("Internet Problem");
                    }
                });
            }
            else {

                return;
            }
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
                                    <label style="font-weight: bold; font-size: 16px;">Suppliers</label>
                                </div>
                                  <div class="col-md-6 col-xs-6" data-toggle="modal" data-target="#popupVendor" onclick="clearVendorDetails();">
                                <div class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>Add Supplier</div>
                                      </div>
                                <%--<div class="col-md-6 col-xs-5" >
                                    <label class="fa fa-plus-square pull-right" style="text-align: right; font-size: 12px; color: green; cursor: pointer;">
                                        <label style="margin-left: 4px; cursor: pointer;">Add Supplier</label></label>
                                </div>--%>

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

                                            <div class="col-md-10 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="Supplier ID/Name" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                <div class="container">
                                                    <div class="content">
                                                        <div class="col-xs-6 col-centered col-max">
                                                            <button type="button" class="btn btn-success pull-right mybtnstyl" onclick="javascript:searchSuppliers(1);">
                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                Search
                                                            </button>
                                                        </div>
                                                        <div class="col-xs-6 col-centered col-max">
                                                            <button class="btn btn-primary mybtnstyl" type="button" onclick="javascript:resetFilters();">
                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                Reset
                                                            </button>
                                                        </div>
                                                    </div>
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
                                        <label>Suppliers<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</span></label>
                                        <ul class="nav navbar-right panel_toolbox">
                                           <%-- <li>

                                                <span style="margin-right: 25px; line-height: 27px; color: #808080;"><strong>Total Records:</strong>
                                                    <label id="lbltotalRecors"></label>
                                                </span>
                                            </li>--%>
                                            <li>

                                                <select class="input-sm" id="slPerpage" onchange="javascript:searchSuppliers(1);">
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
                                            <table id="tblvendors" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>Name</th>
                                                        <th style="text-align: center;">Wallet amt</th>
                                                        <th style="text-align: center;">Outstanding amt</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    

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

                    <%-- start popup starts for add new user --%>
                    <div class="modal fade" id="popupVendor" role="dialog">
                        <div class="modal-dialog modal-md" >
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" onclick="javascript:popupclose('popupVendor');">&times;</button>
                                    <div class="col-md-6 col-sm-6 col-xs-8">
                                        <h4 class="modal-title">Add Supplier</h4>
                                    </div>

                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <form role="form" class="form-horizontal">

                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Name<span class="required">*</span>
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtName" placeholder="Enter Name" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        GST No<%--<span class="required">*</span>--%>
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtGstNo" placeholder="Enter Gst Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Mobile<span class="required">*</span>
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="number" id="txtPhone1" placeholder="Enter Mobile Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Telephone
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="number" id="txtPhone2" style="padding: 0px; text-indent: 3px;" placeholder="Enter Telephone Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Email
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtEmailid" placeholder="Enter Email" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Address<span class="required">*</span>
                                                    </label>
                                                  <div class="col-md-7 col-sm-6 col-xs-12">
                                                                <textarea class="form-control" rows="3" placeholder="Enter Address" id="txtAddress" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                                            </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        City<span class="required">*</span>
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtCity" placeholder="Enter City" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        State
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtState" style="padding: 0px; text-indent: 3px;" placeholder="Enter State" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                        Country<span class="required">*</span>
                                                    </label>
                                                    <div class="col-md-7 col-sm-6 col-xs-12">
                                                        <input type="text" id="txtCountry" placeholder="Enter Country" required="required" class="form-control col-md-7 col-xs-12" />
                                                    </div>
                                                </div>

                                                
                                            </form>
                                            <div class="clearfix"></div>

                                            <div class="ln_solid"></div>
                                            <div class="form-group" style="padding-bottom: 40px;">
                                                <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                    <div id="btnUserDetailsAction">
                                                        <div class="btn btn-success mybtnstyl" onclick="javascript:addVendorDetails();">SAVE</div>
                                                    </div>
                                                    <div onclick="javascript:clearVendorDetails();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                                    <%--<button  id="btnUserDetailsUpdate" style="display:none" class="btn btn-success" onclick="javascript:updateUserDetails();" type="reset">Update</button>--%>
                                                </div>
                                            </div>

                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%-- end popup starts for add new user --%>
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
