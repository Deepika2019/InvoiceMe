<%@ Page Language="C#" AutoEventWireup="true" CodeFile="managerole.aspx.cs" Inherits="opcenter_managerole" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <!--    <meta name="viewport" content="width=device-width, initial-scale=1">-->

    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Manage User  | Invoice Me</title>
    <script src="../js/common.js"></script>
    <script src="../js/jquery-2.0.3.js"></script>
    <script src="../js/pagination.js"></script>
    <script src="../js/jquery.cookie.js"></script>


    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- iCheck -->
    <link href="../css/bootstrap/green.css" rel="stylesheet" />
    <!-- bootstrap-wysiwyg -->
    <link href="../css/bootstrap/prettify.min.css" rel="stylesheet" />
    <!-- Select2 -->
    <link href="../css/bootstrap/select2.min.css" rel="stylesheet" />
    <!-- Switchery -->
    <link href="../css/bootstrap/switchery.min.css" rel="stylesheet" />
    <!-- starrr -->
    <link href="../css/bootstrap/starrr.css" rel="stylesheet" />
    <!-- bootstrap-daterangepicker -->
    <link href="../css/bootstrap/daterangepicker.css" rel="stylesheet" />

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        var userTypeid = 0;
        var BranchId;
        $(document).ready(function () {
            userTypeid = getQueryString('userTypeId');
            //  alert(BillNo);
            //  alert(BillNo);
            if (userTypeid == undefined) {
                location.href = "userTypes.aspx";
                return;
            }
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }
            if (!CountryId) {
                location.href = "../dashboard.aspx";
                return false;
            }

            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
            getUsers();
        });

        // for select All Check boxes
        function checkAll(chboxSelectAllElements) {
            var chboxEmailsArray = document.getElementsByClassName("haschecked");
            var currentRows = $('#TBLshowAssignPages >tbody >tr').length;;
            console.log(currentRows);
            if (chboxSelectAllElements.checked) {
                $(".haschecked").prop("checked", "true");
            }

            else {
                $(".haschecked").removeAttr('checked');
            }

        }//end

        function checkButtonAll(chboxSelectAllElements) {
            var chboxEmailsArray = document.getElementsByClassName("btnhaschecked");
            var currentRows = $('#TBLshowAssignButtons >tbody >tr').length;;
            console.log(currentRows);
            if (chboxSelectAllElements.checked) {
                $(".btnhaschecked").prop("checked", "true");
            }

            else {
                $(".btnhaschecked").removeAttr('checked');
            }

        }
        //function for get users 
        function getUsers() {
            loading();

            $.ajax({
                type: "POST",
                url: "managerole.aspx/getUsers",
                data: "{'userTypeid':'" + userTypeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    htm = "";
                    if (obj.count == 0) {
                        $("#lbluserTypeName").text(obj.name);
                        $("#ulUsers").html("No users found");
                    } else {
                        $.each(obj.data, function (i, row) {
                            htm += '<li><a href="manageusers.aspx?userId=' + row.user_id + '"><span class="item"><span class="item-left"><img src="../images/defaultUser.jpg" alt="" width="30px" height="30px">';
                            htm += '<span class="item-info"><span>' + row.name + '</span> </span></span><span class="clearfix"></span></span></a></li>';
                            $("#lbluserTypeName").text(row.usertype_name);
                        });
                        $("#ulUsers").html(htm);
                    }

                    showAssignPages();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function for get users 
        function showAssignPages() {
            loading();

            $.ajax({
                type: "POST",
                url: "managerole.aspx/showAssignPages",
                data: "{'userTypeid':'" + userTypeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    htm = "";
                    if (obj.count == 0) {
                        $("#txtAssignCount").hide();
                        $("#tblAssignPages > tbody").html('<tr><td style="text-align:center"><label>No Pages Found</label></td></tr>');
                    } else {
                        $("#txtAssignCount").show();
                        $("#txtAssignCount").text(obj.count);
                        $.each(obj.data, function (i, row) {
                            if (row.important == 0) {
                                htm += "<tr><td colspan='4'>" + row.page_name + "</td><td colspan='4'><a class='btn btn-danger btn-xs pull-right'><li class='fa fa-close' onclick='unAssignPages(" + row.page_id + ");'></li></a></td></tr>";
                            } else if (row.important == 1) {
                                htm += "<tr><td colspan='4'>" + row.page_name + "<span class='fa fa-star pull-right' style='color:#ffa700;'></span></td><td><a class='btn btn-danger btn-xs pull-right'><li class='fa fa-close' onclick='unAssignPages(" + row.page_id + ");'></li></a></td></tr>";
                            }
                        });
                        $("#tblAssignPages > tbody").html(htm);
                    }
                    showAssignButtons();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function listPages() {
            loading();
            $("#chkbxAll").prop("checked", false);
            $.ajax({
                type: "POST",
                url: "managerole.aspx/listPages",
                data: "{'userTypeid':'" + userTypeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    var htmp = "";
                    $('#TBLshowAssignPages > tbody').html("");
                    var count = obj.count;
                    $("#lblPageTotalrecords").text(count);
                    if (obj.count == 0) {
                        $("#TBLshowAssignPages tbody").html('<td colspan="2" style="text-align:center"></div></div><div class="clear"></div><label>No Pages Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr>';
                        htm += "<th><div class='checkbox' style='margin-top:0px; margin-bottom:0px;'><label style='font-size: 1em'><input id='chkbxPageId" + i + "'  class='haschecked' type='checkbox'><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnpageId" + i + "' value='" + row.page_id + "'/></th>";
                        htm += '<td>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + row.page_name.toString() + '</label>';
                        htm += '</td>';

                        htm += '</tr>';

                        // alert(htm);

                        $('#TBLshowAssignPages > tbody').append(htm);
                    });


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function updateAssignPages() {
            if ($("#lblPageTotalrecords").text() == 0) {
                alert('There is no page for assigning !!!');
                return false;
            }
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one Page !!!');
                return false;
            } else {
                var confirmVal = confirm("Do you want to assign selected " + $("input[type=checkbox]:checked").length + " pages to " + $("#lbluserTypeName").text() + "?");
                if (confirmVal == true) {
                    var rowCount = $("#TBLshowAssignPages tr").length;
                    var rowValue = rowCount - 2;
                    var pagesArray = [];
                    for (var i = 0; i < rowValue; i++) {
                        if ($("#chkbxPageId" + i).is(':checked')) {
                            pagesArray.push($("#hdnpageId" + i).val());
                        }
                    }
                    console.log(pagesArray);
                    loading();

                    $.ajax({
                        type: "POST",
                        url: "managerole.aspx/updateAssignPages",
                        data: "{'userTypeid':'" + userTypeid + "','pages':" + JSON.stringify(pagesArray) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "Y") {
                                popupclose("popupAssgnPage");
                                //cancelUserPopup('popupAssgncustomer');
                                alert("Assigned successfully");
                                showAssignPages();
                            } else {
                                alert("There is a problem");
                            }

                        },
                        error: function (xhr, status) {
                            Unloading();
                            alert("Internet Problem..!");
                        }
                    });


                }
                else {
                    return;
                }
            }
        }

        function unAssignPages(pageId) {
            var confirmVal = confirm("Do you want to remove the selected pages from " + $("#lbluserTypeName").text() + "?");
            if (confirmVal == true) {
                loading();

                $.ajax({
                    type: "POST",
                    url: "managerole.aspx/removeAssignPages",
                    data: "{'userTypeid':'" + userTypeid + "','pageId':" + pageId + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        if (msg.d == "Y") {
                            alert("removed successfully");
                            showAssignPages();
                        } else {
                            alert("There is a problem");
                        }

                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("Internet Problem..!");
                    }
                });
            }
            else {
                return;
            }
        }

        function listButtons(page) {
            $("#btnCheckbox").prop("checked", false);
            loading();

            $.ajax({
                type: "POST",
                url: "managerole.aspx/listButtons",
                data: "{'userTypeid':'" + userTypeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    var htmp = "";
                    $('#TBLshowAssignButtons > tbody').html("");
                    var count = obj.count;
                    $("#lblButtonTotalrecords").text(count);
                    if (obj.count == 0) {
                        $("#TBLshowAssignButtons tbody").html('<td colspan="2" style="text-align:center"></div></div><div class="clear"></div><label>No Pages Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr>';
                        htm += "<th><div class='checkbox' style='margin-top:0px; margin-bottom:0px;'><label style='font-size: 1em'><input id='chkbxButtonId" + i + "'  class='btnhaschecked' type='checkbox'><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnbuttonId" + i + "' value='" + row.ub_id + "'/></th>";
                        htm += '<td>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + row.ub_button_name.toString() + '(' + row.page_name.toString() + ')</label>';
                        htm += '</td>';

                        htm += '</tr>';

                        // alert(htm);

                        $('#TBLshowAssignButtons > tbody').append(htm);
                    });


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function updateAssignButtons() {
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one !!!');
                return false;
            } else {
                var confirmVal = confirm("Do you want to assign selected " + $("input[type=checkbox]:checked").length + " buttons to " + $("#lbluserTypeName").text() + "?");
                if (confirmVal == true) {
                    var rowCount = $("#TBLshowAssignButtons tr").length;
                    var rowValue = rowCount - 2;
                    var buttonArray = [];
                    for (var i = 0; i < rowValue; i++) {
                        if ($("#chkbxButtonId" + i).is(':checked')) {
                            buttonArray.push($("#hdnbuttonId" + i).val());
                        }
                    }
                    console.log(buttonArray);
                    loading();

                    $.ajax({
                        type: "POST",
                        url: "managerole.aspx/updateAssignButtons",
                        data: "{'userTypeid':'" + userTypeid + "','buttons':" + JSON.stringify(buttonArray) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "Y") {
                                popupclose("popupAssgnButton");
                                //cancelUserPopup('popupAssgncustomer');
                                alert("Assigned successfully");
                                showAssignPages();
                            } else {
                                alert("There is a problem");
                            }

                        },
                        error: function (xhr, status) {
                            Unloading();
                            alert("Internet Problem..!");
                        }
                    });


                }
                else {
                    return;
                }
            }
        }

        //function for display buttons 
        function showAssignButtons() {
            loading();

            $.ajax({
                type: "POST",
                url: "managerole.aspx/showAssignButtons",
                data: "{'userTypeid':'" + userTypeid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    htm = "";
                    if (obj.count == 0) {
                        $("#tblAssignButtons > tbody").html('<tr><td style="text-align:center"><label>No Buttons Found</label></td></tr>');
                    } else {
                        $.each(obj.data, function (i, row) {
                            htm += "<tr><td colspan='4'>" + row.ub_button_name + "(" + row.page_name + ")</td><td colspan='4'><a class='btn btn-danger btn-xs pull-right'><li class='fa fa-close' onclick='unAssignButtons(" + row.bp_id + ");'></li></a></td></tr>";

                        });
                        $("#tblAssignButtons > tbody").html(htm);
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function unAssignButtons(buttonId) {
            var confirmVal = confirm("Do you want to remove the selected button from " + $("#lbluserTypeName").text() + "?");
            if (confirmVal == true) {
                loading();

                $.ajax({
                    type: "POST",
                    url: "managerole.aspx/removeAssignButtons",
                    data: "{'buttonId':" + buttonId + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        if (msg.d == "Y") {
                            alert("removed successfully");
                            showAssignButtons();
                        } else {
                            alert("There is a problem");
                        }

                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("Internet Problem..!");
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
                            <label style="font-weight: bold; font-size: 16px;">Manage Role</label>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%--<div class="page-title">
                        <div class="title_left" style="width: 100%;">
                            <label style="font-size: 16px; font-weight: bold;">Manage User</label>
                        </div>
                    </div>--%>

                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="DivUserDetails">
                            <div class="x_panel">
                                <style>
                                    ul.dropdown-cart li .item
                                    {
                                        display: block;
                                        padding: 6px 10px;
                                        margin: 3px 0;
                                    }

                                        ul.dropdown-cart li .item:hover
                                        {
                                            background: #dadada;
                                            cursor: pointer;
                                        }

                                    ul.dropdown-cart li .item-left
                                    {
                                        float: left;
                                    }

                                        ul.dropdown-cart li .item-left span.item-info
                                        {
                                            margin-left: 10px;
                                        }

                                        ul.dropdown-cart li .item-left img, ul.dropdown-cart li .item-left span.item-info
                                        {
                                            font-size: 14px;
                                            float: left;
                                        }
                                </style>

                                <div class="x_title" style="margin-bottom: 0px; padding-bottom: 0px;">
                                    <label class="pull-left" style="margin-bottom: 5px;">Users List </label>



                                    <div class="clearfix"></div>
                                </div>
                                <div class="x_content">

                                    <div class="dropdown">
                                        <button class="btn myorderMData dropdown-toggle" type="button" data-toggle="dropdown" style="background: none; padding-left: 0px; padding-right: 0px; width: 100%; text-align: left; color: #3498db; font-size: 18px;">
                                            <label id="lbluserTypeName" style="float: left;">Dropdown Example</label>
                                            <span class="fa fa-angle-double-down" style="float: right; font-size: 25px; margin-top: 5px; font-weight: bold;"></span>
                                        </button>
                                        <ul class="dropdown-menu dropdown-cart" role="menu" aria-labelledby="menu1" style="width: 100%; height: 200px; overflow: scroll; overflow-x: hidden;" id="ulUsers">
                                        </ul>
                                    </div>

                                </div>
                            </div>

                        </div>
                    </div>


                </div>
                <div class="clearfix"></div>
                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">

                        <div class="x_content">
                            <div class="row">
                                <div class="col-md-12 col-sm-12 col-xs-12">
                                    <div class="x_panel">
                                        <div class="x_title" style="margin-bottom: 0px;">
                                            <div class="col-md-8 col-sm-12 col-xs-12">

                                                <div class="col-md-8 col-sm-6 col-xs-12">
                                                    <label style="">Page Role</label>

                                                </div>



                                            </div>

                                            <ul class="nav navbar-right panel_toolbox">
                                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                                </li>
                                                <li class="dropdown">
                                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"></a>

                                                </li>
                                                <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                            </ul>


                                            <div data-toggle="modal" data-target="#popupAssgnPage" class="btn btn-success btn-xs pull-right" onclick="listPages(1);"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Assign Page</div>

                                            <div class="clearfix"></div>
                                        </div>
                                        <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                            <div class="col-md-12" style="padding-top: 10px; padding-bottom: 10px;"><span style="font-weight: bold;">Assigned Pages </span><span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="txtAssignCount"></span></div>
                                            <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                <table id="tblAssignPages" class="table table-hover" style="table-layout: auto; font-weight: bold; background: #f9f9f9;">
                                                    <tbody>
                                                    </tbody>
                                                </table>


                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%-- start popup starts for showing pages --%>
                                <div class="modal fade" id="popupAssgnPage" role="dialog">
                                    <div class="modal-dialog modal-md">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <button type="button" class="close" onclick="javascript:popupclose('popupAssgnPage');">&times;</button>
                                            </div>
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                    <table id="TBLshowAssignPages" class="table table-striped table-bordered" style="table-layout: auto;">
                                                        <thead>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <button class="btn btn-success mybtnstyl" type="button" style="float: right;" onclick="javascript:updateAssignPages();">
                                                                        <li class="fa fa-list" style="margin-right: 5px;"></li>
                                                                        Assign
                                                                    </button>

                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th style="width: 30px;">
                                                                    <div class="checkbox" style="margin-bottom: 0px; margin-top: 0px;">
                                                                        <label style="font-size: 1em">
                                                                            <input id="chkbxAll" onchange="checkAll(this)" name="chk[]" class="" type="checkbox">
                                                                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                                        </label>
                                                                        All
                                                                    </div>
                                                                </th>
                                                                <th>Pages(Total:<label id="lblPageTotalrecords">20</label>)</th>


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
                                <%-- end popup starts for showing customers --%>
                            </div>


                        </div>

                    </div>



                </div>
                <div class="clearfix"></div>
                <div class="row">
                    <div class="col-md-12 col-sm-12 col-xs-12">

                        <div class="x_content">
                            <div class="row">
                                <div class="col-md-12 col-sm-12 col-xs-12">
                                    <div class="x_panel">
                                        <div class="x_title" style="margin-bottom: 0px;">
                                            <div class="col-md-8 col-sm-12 col-xs-12">

                                                <div class="col-md-8 col-sm-6 col-xs-12">
                                                    <label style="">Button Role</label>

                                                </div>



                                            </div>

                                            <ul class="nav navbar-right panel_toolbox">
                                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                                </li>
                                                <li class="dropdown">
                                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"></a>

                                                </li>
                                                <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                            </ul>


                                            <div data-toggle="modal" data-target="#popupAssgnButton" class="btn btn-success btn-xs pull-right" onclick="listButtons(1);"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Button Permission</div>

                                            <div class="clearfix"></div>
                                        </div>
                                        <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                            <div class="col-md-12" style="padding-top: 10px; padding-bottom: 10px;"><span style="font-weight: bold;">Button(Page)</div>
                                            <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                <table id="tblAssignButtons" class="table table-hover" style="table-layout: auto; font-weight: bold; background: #f9f9f9;">
                                                    <tbody>

                                                        <tr>
                                                            <td colspan="4">manage customer</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">manage customer<span class="fa fa-star pull-right" style="color: #ffa700;"></span></td>

                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">manage customer</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">manage customer <span class="fa fa-star pull-right" style="color: #ffa700;"></span></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">manage customer</td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">manage customer</td>
                                                        </tr>
                                                    </tbody>
                                                </table>


                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%-- start popup starts for showing pages --%>
                                <div class="modal fade" id="popupAssgnButton" role="dialog">
                                    <div class="modal-dialog modal-md">

                                        <!-- Modal content-->
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <button type="button" class="close" onclick="javascript:popupclose('popupAssgnButton');">&times;</button>
                                            </div>
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                    <table id="TBLshowAssignButtons" class="table table-striped table-bordered" style="table-layout: auto;">
                                                        <thead>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <button class="btn btn-success mybtnstyl" type="button" style="float: right;" onclick="javascript:updateAssignButtons();">
                                                                        <li class="fa fa-list" style="margin-right: 5px;"></li>
                                                                        Assign
                                                                    </button>

                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th style="width: 30px;">
                                                                    <div class="checkbox" style="margin-bottom: 0px; margin-top: 0px;">
                                                                        <label style="font-size: 1em">
                                                                            <input id="btnCheckbox" onchange="checkButtonAll(this)" name="chk[]" class="" type="checkbox">
                                                                            <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                                        </label>
                                                                        All
                                                                    </div>
                                                                </th>
                                                                <th>Buttons(Total:<label id="lblButtonTotalrecords">20</label>)</th>


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
                                <%-- end popup starts for showing customers --%>
                            </div>


                        </div>

                    </div>



                </div>

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
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- bootstrap-progressbar -->
    <script src="../js/bootstrap/bootstrap-progressbar.min.js"></script>
    <!-- iCheck -->
    <script src="../js/bootstrap/icheck.min.js"></script>
    <!-- bootstrap-daterangepicker -->
    <script src="../js/bootstrap/moment.min.js"></script>
    <script src="../js/bootstrap/daterangepicker.js"></script>
    <!-- bootstrap-wysiwyg -->
    <script src="../js/bootstrap/bootstrap-wysiwyg.min.js"></script>
    <script src="../js/bootstrap/jquery.hotkeys.js"></script>
    <script src="../js/bootstrap/prettify.js"></script>
    <!-- jQuery Tags Input -->
    <script src="../js/bootstrap/jquery.tagsinput.js"></script>
    <!-- Switchery -->
    <script src="../js/bootstrap/switchery.min.js"></script>
    <!-- Select2 -->
    <script src="../js/bootstrap/select2.full.min.js"></script>
    <!-- Parsley -->
    <script src="../js/bootstrap/parsley.min.js"></script>
    <!-- Autosize -->
    <script src="../js/bootstrap/autosize.min.js"></script>
    <!-- jQuery autocomplete -->
    <script src="../js/bootstrap/jquery.autocomplete.min.js"></script>
    <!-- starrr -->
    <script src="../js/bootstrap/starrr.js"></script>
    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
    <%-- edited --%>

    <%-- end --%>
</body>
</html>
