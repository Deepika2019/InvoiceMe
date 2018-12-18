<%@ Page Language="C#" AutoEventWireup="true" CodeFile="managevendor.aspx.cs" Inherits="inventory_managevendor" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <!--    <meta name="viewport" content="width=device-width, initial-scale=1">-->

    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Manage Supplier  | Invoice Me</title>
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
        var vendorid = 0;
        var BranchId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            vendorid = getQueryString('vendorId');
            //  alert(BillNo);
            //  alert(BillNo);
            if (vendorid == undefined) {
                location.href = "vendors.aspx";
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
            showVendorDetails();
        });

        // for select All Check boxes
        function checkAll(chboxSelectAllElements) {
            var chboxEmailsArray = document.getElementsByClassName("haschecked");
            var currentRows = $('#TBLshowAssignCustomers >tbody >tr').length;;
            console.log(currentRows);
            if (chboxSelectAllElements.checked) {
                $(".haschecked").prop("checked", "true");
            }

            else {
                $(".haschecked").removeAttr('checked');
            }

        }//end
        //function for user detrails
        function showVendorDetails() {
            $("#txtSearch").val('');
            loading();

            $.ajax({
                type: "POST",
                url: "managevendor.aspx/showVendorDetails",
                data: "{'vendorid':'" + vendorid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    $("#txtvendorId").text(vendorid);
                    $("#textName").text(obj[0].vn_name);
                    $("#txtCity").text(obj[0].vn_city);
                    $("#txtCity").text(obj[0].vn_city);
                    $("#txtPhone").text(obj[0].vn_phone1);
                    $("#txtEmail").text(obj[0].vn_email);
                    $("#txtaddress").text(obj[0].vn_address);
                    $("#txtcountry").text(obj[0].vn_country);
                   // alert(obj[0].vn_gst);
                    if (obj[0].vn_gst != "") {
                        $("#spnGst").show();
                        $("#txtGstNo").text(obj[0].vn_gst);
                    } else {
                        $("#spnGst").hide();
                        $("#txtGstNo").text("");
                    }
                    $("#txtEditGstNo").val(obj[0].vn_gst);
                    $("#txtEditName").val(obj[0].vn_name);
                    $("#txtEditPhone1").val(obj[0].vn_phone1);
                    $("#txtEditPhone2").val(obj[0].vn_phone2);
                    $("#txtEditEmailid").val(obj[0].vn_email);
                    $("#txtEditAddress").val(obj[0].vn_address);
                    $("#txtEditCity").val(obj[0].vn_city);
                    $("#txtEditState").val(obj[0].vn_state);
                    $("#txtEditCountry").val(obj[0].vn_country);
                  //  alert(obj[0].vn_balance);
                    if (obj[0].vn_balance <= 0) {
                        $("#txtBalance").text(obj[0].vn_balance);
                        $("#txtBalance").css("color", "green");
                    } else {
                        $("#txtBalance").text(obj[0].vn_balance);
                        $("#txtBalance").css("color", "red");
                    }
                    showpurchaseEntries(1);

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //show purchase entries
        function showpurchaseEntries(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }
            loading();

            $.ajax({
                type: "POST",
                url: "managevendor.aspx/showpurchaseEntries",
                data: "{'vendorid':'" + vendorid + "','page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var html = "";
                    $('#tblCustomers > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblPurchaseEntry tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                       // <div style="width:400px;"><div><div class="fl"><span class="myorderMData fl"><a class="fl" style="color: inherit; margin-bottom:0px;" href="manageusers.aspx?userId=1">#1</a>  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>Admin Ad</a></label></span>
                        html += '<tr><td><div style="width:400px;"><div><div class="fl">';
                        html += '<span class="myorderMData fl"><a class="fl" style="color: inherit; margin-bottom:0px;" href="../purchase/managepurchase.aspx?purchaseId=' + row.pm_id + '"><label class="fl" style="margin-bottom:0px; padding-left:5px; padding-right:5px; font-size:15px;cursor:pointer;">#' + getHighlightedValue(filters.search, row.pm_invoice_no.toString()) + '</label></span></a >';
                        

                        html += '</div></div><div style="text-align: left;"><a>&nbsp;&nbsp;<span class="fa fa-edit myicons" style="margin-left:20px;"></span><span class="myorderSData">' + row.name.toString() + '</span></a><a>&nbsp;&nbsp;<span class="fa fa-calendar myicons" style="margin-left:20px;"></span><span class="myorderSData">' + row.entryDate + '</span></a></div></div>';

                        //htm += '<label style="text-align: left;">';
                        //if (row.name) {
                        //    htm += '&nbsp;&nbsp;<span class="fa fa-edit myicons" style="margin-left:15px;;"></span>';
                        //    htm += '<span class="myorderSData" style="line-height: 1;">' + row.name.toString() + '</span>';
                        //    htm += '&nbsp;&nbsp;<span class="fa fa-calendar myicons" style="margin-left:15px;;"></span>';
                        //    htm += '<span class="myorderSData" style="line-height: 1;">' + row.entryDate + '</span>';
                        //}

                        //htm += '</label></div></td>';
                        html += '<td style="text-align:center;">' + row.pm_netamount + '</td>';
                        html += '<td style="text-align:center;">' + row.pm_balance + '</td>';
                        html += '</tr>';

                        // alert(htm);

                       
                    });
                    html += '<tr>';
                    html += '<td colspan="4">';
                    html += '<div  id="divPagination" style="text-align: center;">';
                    html += '</div>';
                    html += '</td>';
                    html += '</tr>';
                    $("#tblPurchaseEntry tbody").html(html);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "showpurchaseEntries"));
                  //  Unloading();

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



        //function for cancel in popup
        function cancelUserPopup(popupId) {
            popupclose(popupId);
           // showUserDetails(userid);

        }

        //update userdetails
        function updateVendorDetails() {
            sqlInjection();
            var Name = $("#txtEditName").val();
            var mobile = $("#txtEditPhone1").val();
            var telephone = $("#txtEditPhone2").val();
            var Emailid = $("#txtEditEmailid").val();
            var Address = $("#txtEditAddress").val();
            var City = $("#txtEditCity").val();
            var State = $("#txtEditState").val();
            var Country = $("#txtEditCountry").val();
            var gstNumber = $("#txtEditGstNo").val();
            if (Name == "") {
                alert("Enter Name");
                $("#txtEditName").focus();
                return false;
            }
            if (mobile == "") {
                alert("Enter phone number");
                $("#txtEditPhone1").focus();
                return false;
            }
            if (Address == "") {
                alert("Enter Address");
                $("#txtEditAddress").focus();
                return false;
            }
            if (City == "") {
                alert("Enter city");
                $("#txtEditCity").focus();
                return false;
            }
            if (Country == "") {
                alert("Enter country");
                $("#txtEditCountry").focus();
                return false;
            }
            loading();
            $.ajax({
                type: "POST",
                url: "managevendor.aspx/updateVendorDetails",
                data: "{'vendor_id':'" + vendorid + "','Name':'" + Name + "','mobile':'" + mobile + "','telephone':'" + telephone + "','Emailid':'" + Emailid + "','Address':'" + Address + "','City':'" + City + "','State':'" + State + "','Country':'" + Country + "','gst':'" + gstNumber + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "E") {
                        alert("Updation Failed...");
                        return false;
                    }
                    if (msg.d == "Y") {
                        alert("Updated Successfully");
                        showVendorDetails();
                        cancelUserPopup('popupVendor');

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
        //Stop:TO Replace single quotes with double quotes
       
        function gotoPurchaseEntry() {
            window.location = '../purchase/purchaseentry.aspx?vendorId=' + vendorid;
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
                            <label style="font-weight: bold; font-size: 16px;">Manage Supplier</label>

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
                                <div class="x_title" style="margin-bottom: 0px;">

                                    <label>Profile</label>

                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                    </ul>
                                    <%--<a href="" class="btn btn-success btn-xs pull-right"><span class="fa fa-pencil-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Edit</a>--%>

                                    <div data-toggle="modal" data-target="#popupVendor" class="btn btn-success btn-xs pull-right"><span class="fa fa-pencil-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Edit</div>

                                </div>
                                <div class="x_content">

                                    <form id="demo-form2" class="">
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-bottom: 2px;">
                                                <span class="myorderMData">#<a class="" style="color: inherit; margin-bottom: 0px;" id="txtvendorId"></a>
                                                    <label class="" style="margin-bottom: 0px; padding-left: 5px; padding-right: 5px; font-size: 14px;"><a id="textName"></a></label><span id="spnGst" style="display:none">(GST No:<label id="txtGstNo"></label>)</span>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-12 col-xs-12">
                                            <span class="myorderMDatafor">
                                                <label class="" style="font-weight: normal"><span class="fa fa-map-marker myicons" title="City"></span><a id="txtCity"></a></label>
                                                <label class="" style="margin-left: 10px; font-weight: normal"><span class="fa fa-mobile myicons" title="Phone Number"></span><a id="txtPhone"></a></label>
                                            </span>
                                        </div>

                                        <div class="col-md-3 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-bottom: 2px;">
                                                <span class="myorderMDatafor">
                                                    <label class="" style="color: inherit; margin-bottom: 0px;"><span class="fa fa-envelope-o" title="Email"></span></label>
                                                    <label class="myorderMDatafor" style="font-weight: normal"><a id="txtEmail"></a></label>
                                                </span>
                                            </div>
                                        </div>


                                        <div class="col-md-12 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-top: 15px;">
                                                <%--<label class="" style=""><span class="fa fa-address-card myicons"></span><a id="txtaddress"></a>  </label>--%>
                                                <address>
                                                    <span class="fa fa-address-book"></span><strong>
                                                        <label id="txtaddress" style="font-weight: normal"></label>
                                                    </strong>
                                                    <%--  <span class="fa fa-map-marker" title="Location"></span>--%>
                                                    <%--   <label id="txtlocation" style="font-weight: normal"></label>--%>
                                                    <span class="fa fa-globe" title="Country"></span>
                                                    <label id="txtcountry" style="font-weight: normal"></label>
                                                </address>
                                            </div>

                                        </div>

                                          <div class="col-md-3 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-bottom: 2px;">
                                                <span class="myorderMDatafor">
                                                    <label class="" style="color: inherit; margin-bottom: 0px;">Balance:</label>
                                                    <label class="myorderMDatafor" style="font-weight: normal;color:black" id="txtBalance">0</label>
                                                </span>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <%-- start popup starts for add new user --%>
                        <div class="modal fade" id="popupVendor" role="dialog">
                            <div class="modal-dialog modal-lg" style="">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" onclick="javascript:popupclose('popupVendor');">&times;</button>
                                        <div class="col-md-6 col-sm-6 col-xs-8">
                                            <h4 class="modal-title">Edit Profile</h4>
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
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditName" placeholder="Enter Name" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            GST No<%--<span class="required">*</span>--%>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditGstNo" placeholder="Enter Gst Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Mobile<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="number" id="txtEditPhone1" placeholder="Enter Mobile Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Telephone
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="number" id="txtEditPhone2" style="padding: 0px; text-indent: 3px;" placeholder="Enter Telephone Number" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Email
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditEmailid" placeholder="Enter Email" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Address<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <textarea class="form-control" rows="3" placeholder="Enter Address" id="txtEditAddress" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                                        </div>
                                                    </div>

                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            City
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditCity" placeholder="Enter City" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>

                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            State
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditState" style="padding: 0px; text-indent: 3px;" placeholder="Enter State" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Country<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEditCountry" placeholder="Enter Country" required="required" class="form-control col-md-7 col-xs-12" />
                                                        </div>
                                                    </div>


                                                </form>
                                                <div class="clearfix"></div>

                                                <div class="ln_solid"></div>
                                                <div class="form-group" style="padding-bottom: 40px;">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                        <div id="btnUserDetailsAction">
                                                            <div class="btn btn-success mybtnstyl" onclick="javascript:updateVendorDetails();">UPDATE</div>
                                                        </div>
                                                        <div onclick="javascript:cancelUserPopup('popupVendor');" class="btn btn-danger mybtnstyl">CANCEL</div>
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
                                                        <label style="">Purchase Entries</label>
                                                    </div>


                                                    <div class="col-md-3 col-sm-6 col-xs-12">
                                                        <span style="font-size: 12px; line-height: 27px; color: #808080;"><strong>Total Records:</strong>
                                                            <label id="lbltotalRecors"></label>
                                                        </span>
                                                    </div>
                                                    <div class="col-md-1 col-sm-6 col-xs-12 pull-right">
                                                        <select class="input-sm" id="slPerpage" onchange="javascript:showCustomerlist(1);">
                                                            <option value="50">50</option>
                                                            <option value="100">100</option>
                                                            <option value="200">200</option>
                                                        </select>
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


                                                <div data-toggle="modal" class="btn btn-success btn-xs pull-right" onclick="gotoPurchaseEntry();"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Purchase Entry</div>

                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="x_title">
                                                <div class="col-md-11 col-sm-6 col-xs-10 " style="margin-top: 10px;">
                                                    <div class="col-md-12 col-sm-6 col-xs-12">
                                                        <div class="form-group">
                                                            <div class="input-group">
                                                                <input type="text" class="form-control" id="txtSearch" placeholder="Invoice Number" style="height: 33px;" />
                                                                <span class="input-group-btn">
                                                                    <button type="button" class="btn btn-default" onclick="showpurchaseEntries(1)">
                                                                        <i class="fa fa-search"></i>
                                                                    </button>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <%--<input type="text" class="form-control has-feedback-left" style="padding-left:5px;" id="txtSearch" placeholder="Customer ID/Name/Phone" />
                                                       <span class="fa fa-search form-control-feedback right" aria-hidden="true"  onclick="showCustomerlist(1)" style="cursor:pointer; pointer-events:visible; color:#0cb9e2; font-weight:bold;" title="Search"></span>--%>
                                                    </div>
                                                </div>
                                                <div class="clearfix"></div>
                                            </div>


                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content">
                                                    <table id="tblPurchaseEntry" class="table table-hover" style="table-layout: auto;">
                                                        <thead>
                                                            <tr>

                                                                <th>Entry</th>
                                                                <th style="text-align: center;">Net Amount</th>
                                                                <th style="text-align: center;">Balance</th>
                                                      
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

                                    <%-- start popup starts for showing customers --%>
                                    <div class="modal fade" id="popupAssgncustomer" role="dialog">
                                        <div class="modal-dialog modal-lg" style="width: 95%;">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" onclick="javascript:popupclose('popupAssgncustomer');">&times;</button>
                                                    <div class="col-md-9 col-sm-6 col-xs-8">
                                                        <div class="input-group">
                                                            <input type="text" class="form-control" id="txtAssgnSearch" placeholder="Customer/SalesMan ID/Name" style="height: 33px; padding-right: 2px;" />
                                                            <span class="input-group-btn">
                                                                <button type="button" class="btn btn-default" onclick="addAssignCustomer(1)">
                                                                    <i class="fa fa-search" title="search"></i>
                                                                </button>
                                                            </span>
                                                        </div>

                                                        <%--  <input type="text" class="form-control has-feedback-left" id="txtAssgnSearch" placeholder="Customer ID/Name">
                                                        <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>--%>
                                                    </div>



                                                    <div class="col-md-2 col-sm-12 col-xs-3">

                                                        <button class="btn btn-primary mybtnstyl" type="button" style="float: right;" onclick="javascript:ResetAssignCustomer();">
                                                            <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                            Reset
                                                        </button>


                                                    </div>




                                                </div>
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                    <div class="x_content">
                                                        <table id="TBLshowAssignCustomers" class="table table-striped table-bordered" style="table-layout: auto;">
                                                            <thead>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        <select id="txtpageno" onchange="javascript:addAssignCustomer(1);" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class="pull-right input-sm">
                                                                            <option value="50">50</option>
                                                                            <option value="100">100</option>
                                                                            <option value="250">250</option>
                                                                            <option value="500">500</option>
                                                                        </select>
                                                                        <button class="btn btn-success mybtnstyl" type="button" style="float: right;" onclick="javascript:updateAssignCustomer();">
                                                                            <li class="fa fa-list" style="margin-right: 5px;"></li>
                                                                            Update
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
                                                                    <th>Customers(Total:<label id="lblCustTotalrecords">20</label>)</th>
                                                                    <th>Sales Persons</th>

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
