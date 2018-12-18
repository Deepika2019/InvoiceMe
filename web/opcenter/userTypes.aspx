<%@ Page Language="C#" AutoEventWireup="true" CodeFile="userTypes.aspx.cs" Inherits="opcenter_managerole" %>

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
            searchUserTypes(1);
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

        // start search users
        function searchUserTypes(page) {
            var perpage = $("#slPerpage").val();
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }

            // alert(JSON.stringify(filters));
            loading();
            // console.log(filters);
            $.ajax({
                type: "POST",
                url: "userTypes.aspx/searchUserTypes",
                data: "{'page':" + page + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tblUserTypes > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblUserTypes tbody").html('<td colspan="2" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm += '<tr><td><div style="width:400px;"><div class="fl">';
                        htm += '<span class="myorderMData fl">';
                        htm += '<a class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal" href="managerole.aspx?userTypeId=' + row.usertype_id + '">' + row.name.toString() + '</label></td>';
                        htm += '</span>';
                        htm += "<td><a href='managerole.aspx?userTypeId=" + row.usertype_id + "' class='btn btn-primary btn-xs' style='text-align:center;'><span class='fa fa-tasks' style='font-size:14px;margin-top:3px;' title='Manage role'></span></a><a class='btn btn-primary btn-xs' style='text-align:center;'><span class='fa fa-pencil' style='font-size:14px;margin-top:3px;' onclick=javascript:UpdateData('" + row.name.replace(/\s/g, '&nbsp;') + "'," + row.usertype_id + ") title='Edit'></span></a></td>";
                        htm += '</div></div>';
                        htm += '</td></tr>';
                        $('#tblUserTypes > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="2">';
                    htm += '<div  id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblUserTypes > tbody').append(htm);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "searchUserTypes"));
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
            searchUserTypes(1);
        }
        //end
        function addUserType(type) {
            sqlInjection();
            var UserType_name = $("#txtUserTypeName").val();
            var userTypeId = $("#txtusertypeId").val();
            if (UserType_name == "") {
                alert("Enter UserType");
                return false;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "userTypes.aspx/addUserType",
                data: "{'UserType_name':'" + UserType_name + "','type':'" + type + "','userTypeId':'" + userTypeId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (type == 0) {
                            alert("UserType Added Successfully");
                        } else if (type == 1) {
                            alert("UserType Updated Successfully");
                        }
                        clearUsertype();
                        popupclose("popupUserType");
                        searchUserTypes(1);
                    }
                    else {
                        alert("UserType Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function deleteUserType() {
            var r = confirm("Do You want to Delete the UserType?");
            if (r == true) {
                loading();

                $.ajax({
                    type: "POST",
                    url: "userTypes.aspx/removeUserType",
                    data: "{'UserType_id':'" + $("#txtusertypeId").val() + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("UserType Deleted Successfully");
                            clearUsertype();
                            popupclose("popupUserType");
                            searchUserTypes(1);
                        }
                        else if (msg.d == "E") {
                            alert("UserType Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("UserType Deletion Failed");

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
        function UpdateData(name, id) {
            $("#txtusertypeId").val(id);
            $("#txtUserTypeName").val(name);
            $("#popupUserType").modal('show');
            $("#btnSave").hide();
            $("#btnUpdate").show();
            $("#btnDelete").show();
        }



        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function clearUsertype() {
            $("#txtUserTypeName").val("");
            $("#btnSave").show();
            $("#btnUpdate").hide();
            $("#btnDelete").hide();
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
                                    <label style="font-weight: bold; font-size: 16px;">User Types</label>
                                </div>
                                <div class="col-md-6 col-xs-5" data-toggle="modal" data-target="#popupUserType" onclick="clearUsertype();">

                                    <div class="btn btn-success btn-xs pull-right" style="background-color: #d86612; border-color: #d86612; margin-top: 5px">
                                        <label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>
                                        User Type</div>

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

                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">

                                        <ul class="nav navbar-right panel_toolbox">

                                            <li>

                                                <select class="input-sm" id="slPerpage" onchange="javascript:searchUserTypes(1);">
                                                    <option value="10">10</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
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
                                            <table id="tblUserTypes" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>User Types<label class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</label></th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td colspan="2"></td>
                                                    </tr>
                                                </tbody>
                                            </table>


                                        </div>

                                    </div>
                                </div>
                            </div>

                            <%-- start popup starts for add new user --%>
                            <div class="modal fade" id="popupUserType" role="dialog">
                                <div class="modal-dialog modal-md">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupUserType');">&times;</button>
                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                <h4 class="modal-title">Add User Type</h4>
                                            </div>

                                        </div>
                                        <div class="modal-body">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <form role="form" class="form-horizontal">
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                User Type Name<span class="required">*</span>
                                                            </label>
                                                            <input type="hidden" value="0" id="txtusertypeId" />
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtUserTypeName" placeholder="Enter UserType name" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                    </form>
                                                    <div class="clearfix"></div>

                                                    <div class="ln_solid"></div>
                                                    <div class="form-group" style="padding-bottom: 40px;">
                                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                            <div id="btnSave">
                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addUserType(0);">SAVE</div>
                                                            </div>
                                                            <div id="btnUpdate" style="display: none;">
                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addUserType(1);">Update</div>
                                                            </div>
                                                            <div id="btnDelete" style="display: none;">
                                                                <div class="btn btn-danger mybtnstyl" onclick="javascript:deleteUserType();">Delete</div>
                                                            </div>
                                                            <%--<div onclick="javascript:clearUsertype();" class="btn btn-danger mybtnstyl" id="btnCancel">CANCEL</div>--%>
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
