<%@ Page Language="C#" AutoEventWireup="true" CodeFile="users.aspx.cs" Inherits="opcenter_users" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Users | Invoice Me</title>
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

        //alert($.cookie("invntrystaffBranchId") + "branchid@customer");
        //alert($.cookie("invntrystaffCountryId") + "cvvcb");

        var BranchId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }
            resetFilters();
            getBranches();
            //  resetFilters();
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
            //Start:Footer
            var docHeight = $(window).height();
            var footerHeight = $('.footerDiv').height();
            var footerTop = $('.footerDiv').position().top + footerHeight;

            if (footerTop < docHeight) {
                $('.footerDiv').css('margin-top', -33 + (docHeight - footerTop) + 'px');
            }
            //Stop:Footer

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

        // Start loading branches
        function getBranches() {
            //loading();
            $.ajax({
                type: "POST",
                url: "users.aspx/getBranches",
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
                    $("#comboWarehouseUser").html(htm);
                    $("#slBranch").val(BranchId);
                    getUserTypes();
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

        // Start loading branches
        function getUserTypes() {
            //loading();
            $.ajax({
                type: "POST",
                url: "users.aspx/getUserTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--All User Types--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.usertype_id + '">' + row.usertype_name + '</option>';
                    });
                    $("#slUserType").html(htm);
                    $("#comboUsertype").html(htm);
                    searchUsers(1);
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

        // start search users
        function searchUsers(page) {
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
            if ($("#slBranch").val() != -1) {
                if ($("#slBranch").val() != undefined) {
                    filters.branch = $("#slBranch").val();
                } else {
                    filters.branch = branchId;
                }

            }
            if ($("#slUserType").val() != -1 && $("#slUserType").val() != undefined) {
                filters.user_type = $("#slUserType").val();
                //filters.user_typeName = $('#slUserType option:selected').text();
            }

            // alert(JSON.stringify(filters));
            loading();
            // console.log(filters);
            $.ajax({
                type: "POST",
                url: "users.aspx/searchUsers",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tblUsers > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblUsers tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr><td><div style="width:400px;"><div><div class="fl">';
                        htm += '<span class="myorderMData fl">';
                        htm += '<label class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal" href="manageusers.aspx?userId=' + row.user_id + '">#' + getHighlightedValue(filters.search, row.user_id.toString()) + '</label>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.name.toString()) + '</label></span>';
                        htm += '</span>';
                        htm += '</div></div>';
                        htm += '<div style="text-align: left;">';
                        if (row.phone) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-mobile myicons" style="margin-left:20px;"></span>';
                            htm += '<span class="myorderSData">' + getHighlightedValue(filters.search, row.phone.toString()) + '</span>';
                        }
                        if (row.location) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-map-marker myicons"></span>';
                            htm += '<span class="myorderSData">' + row.location + '</span>';
                        }
                        htm += '</div></div></td>';
                        htm += '<td style="text-align:center;">' + row.user_type_name + '</td>';
                        htm += '<td>';
                        htm += '<a href="manageusers.aspx?userId=' + row.user_id + '" class="btn btn-primary btn-xs" style="text-align:center;"><li class="fa fa-eye" style="font-size:20px;"></li></a>';
                        htm += '</td></tr>';

                        // alert(htm);

                        $('#tblUsers > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="4">';
                    htm += '<div  id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblUsers > tbody').append(htm);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchUsers"));
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }//end

        //function for reset 
        function resetFilters() {
            $("#txtSearch").val("");
            $("#slBranch").val(BranchId);
            $("#slUserType").val(-1);
            searchUsers(1);
        }
        //end

        //Add user
        function addUserDetails() {
            sqlInjection();
            var Firstname = $("#txtFirstname").val();
            var Lastname = $("#txtLastname").val();
            var Username = $("#txtUsername").val();
            var Password = $("#txtPassword").val();
            var Usertype = $("#comboUsertype").val();
            var Usertypename = $("#comboUsertype option[value='" + Usertype + "']").text();
            var Phone = $("#txtPhone").val();
            var Emailid = $("#txtEmailid").val();
            var Country = $("#txtCountry").val();
            var Location = $("#txtLocation").val();
            var Address = $("#txtAddress").val();
            var UserImage = "";

            var warehouseId = $("#comboWarehouseUser").val();
            var warehousename = $("#comboWarehouseUser option[value='" + warehouseId + "']").text();
            if (warehouseId == "-1") {
                alert("Select the Warehouse");
                return false;
            }


            if (Firstname == "") {
                alert("Enter First Name");
                $("#txtFirstname").focus();
                return false;
            }
            if (Lastname == "") {
                alert("Enter Last Name");
                $("#txtLastname").focus();
                return false;
            }
            if (Username == "") {
                alert("Enter User Name");
                $("#txtUsername").focus();
                return false;
            }
            if (Password == "") {
                alert("Enter Password");
                $("#txtPassword").focus();
                return false;
            }
            if (Usertype == "" || Usertype == "-1") {
                alert("Choose User Role");
                return false;
            }
            if (Phone == "") {
                alert("Enter phone number");
                $("#txtPhone").focus();
                return false;
            }
            if (Country == "") {
                alert("Enter country");
                $("#txtCountry").focus();
                return false;
            }
            if (Address == "") {
                alert("Enter Address");
                $("#txtAddress").focus();
                return false;
            }
            loading();
            $.ajax({
                type: "POST",
                url: "users.aspx/addUserDetails",
                data: "{'Firstname':'" + Firstname + "','Lastname':'" + Lastname + "','Username':'" + Username + "','Password':'" + Password + "','Usertype':'" + Usertype + "','Usertypename':'" + Usertypename + "','Phone':'" + Phone + "','Emailid':'" + Emailid + "','Country':'" + Country + "','Location':'" + Location + "','Address':'" + Address + "','UserImage':'" + UserImage + "','branch_id':'" + warehouseId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "E") {
                        alert("Give Another Username");
                        return false;
                    }
                    if (msg.d == "Y") {
                        alert("User Created Successfully");
                        clearUserDetails();
                        popupclose('popupUser');
                        searchUsers(1);
                        return false;
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

        function clearUserDetails() {
            $("#txtFirstname").val("");
            $("#txtLastname").val("");
            $("#txtUsername").val("");
            $("#txtPassword").val("");
            //$("#comboUsertype").val("1");
            $("#txtPhone").val("");
            $("#txtEmailid").val("");
            $("#txtCountry").val("");
            $("#txtLocation").val("");
            $("#txtAddress").val("");
            $("#comboUsertype").val("-1");
            $("#comboWarehouseUser").val("-1");
            //$("#popupUser").modal('hide');
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
                                    <label style="font-weight: bold; font-size: 16px;">Users</label>
                                </div>
                                <div class="col-md-6 col-xs-6" data-toggle="modal" data-target="#popupUser" onclick="clearUserDetails();">
                                <div class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New User</div>
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

                                        

                                          <%--  <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="slBranch" class="form-control" style="text-indent: 25px;" onchange="searchUsers(1)">
                                                </select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>--%>

                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="slUserType" class="form-control" style="text-indent: 25px;" onchange="searchUsers(1)">
                                                </select>
                                                <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                                <div class="col-md-7 col-sm-6 col-xs-12 form-group has-feedback">
                                                <input type="text" class="form-control has-feedback-left" id="txtSearch" placeholder="UserID/Name/Phone" />
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                <button class="btn btn-primary mybtnstyl pull-right" type="button" onclick="javascript:resetFilters();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </button>
                                                <button type="button" class="btn btn-success pull-right mybtnstyl" onclick="javascript:searchUsers(1);">
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
                                        <label>Users List</label><label class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</label>
                                        <ul class="nav navbar-right panel_toolbox">
                                           
                                            <li>

                                                <select class="input-sm" id="slPerpage" onchange="javascript:searchUsers(1);">
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
                                            <table id="tblUsers" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>User</th>
                                                        <th style="text-align: center;">Type</th>
                                                        <%--                                                        <th style="text-align: center;">Phone</th>--%>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td colspan="4"></td>
                                                    </tr>
                                                </tbody>
                                            </table>


                                        </div>

                                    </div>
                                </div>
                            </div>

                            <%-- start popup starts for add new user --%>
                            <div class="modal fade" id="popupUser" role="dialog">
                                <div class="modal-dialog modal-md">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupUser');">&times;</button>
                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                <h4 class="modal-title">Add New User</h4>
                                            </div>

                                        </div>
                                        <div class="modal-body">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <form role="form" class="form-horizontal">
                                                       <%-- <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Warehouse<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <select class="form-control" id="comboWarehouseUser">
                                                                    <option value="0">-Select Warehouse-</option>
                                                                </select>
                                                            </div>
                                                        </div>--%>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                First Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtFirstname" placeholder="Enter First Name" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Last Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtLastname" placeholder="Enter Last Name" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                User Name<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtUsername" placeholder="Enter Username" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Password<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtPassword" placeholder="Enter Password" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                User Role<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <select class="form-control" id="comboUsertype">
                                                                    <option value="0">-Select User Role-</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Phone<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="number" id="txtPhone" style="padding: 0px; text-indent: 3px;" placeholder="Enter Phone" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Email
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtEmailid" placeholder="Enter Email" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Country<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtCountry" placeholder="Enter Country" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Location
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtLocation" placeholder="Enter City" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Address<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                                <textarea class="form-control" rows="3" placeholder="Enter Address" id="txtAddress" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                                            </div>
                                                        </div>

                                                    </form>
                                                    <div class="clearfix"></div>

                                                    <div class="ln_solid"></div>
                                                    <div class="form-group" style="padding-bottom: 40px;">
                                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                            <div id="btnUserDetailsAction">
                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addUserDetails();">SAVE</div>
                                                            </div>
                                                            <div onclick="javascript:clearUserDetails();" class="btn btn-danger mybtnstyl">CANCEL</div>
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
