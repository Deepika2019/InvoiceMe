<%@ Page Language="C#" AutoEventWireup="true" CodeFile="manageTax.aspx.cs" Inherits="inventory_manageTax" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Taxes | Invoice Me</title>
    <script src="../js/common.js" type="text/javascript"></script>
    <script src="../js/jquery-2.0.3.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/pagination.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script src="../js/bootbox.min.js"></script>

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
        var updateId = 0;
        var sessionId = 0;
        $(document).ready(function () {
            sessionId = getSessionID();
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }
            searchTaxes(1);
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
        
        //start create session Id
        function getSessionID() {

            var now = new Date();
            var year = now.getFullYear();
            var month = now.getMonth() + 1;
            var day = now.getDate();
            var hour = now.getHours();
            var minute = now.getMinutes();
            var second = now.getSeconds();
            if (month.toString().length == 1) {
                var month = '0' + month;
            }
            if (day.toString().length == 1) {
                var day = '0' + day;
            }
            if (hour.toString().length == 1) {
                var hour = '0' + hour;
            }
            if (minute.toString().length == 1) {
                var minute = '0' + minute;
            }
            if (second.toString().length == 1) {
                var second = '0' + second;
            }

            var salesman_id = $.cookie("invntrystaffBranchId");

            sessionId = String(year) + String(month) + String(day) + String(hour) + String(minute) + String(second) + String(salesman_id);
            return sessionId;
            //alert(sessionId);
        }
        //end create session Id

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

        // start search taxes
        function searchTaxes(page) {
            var perpage = $("#slPerpage").val();
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            var search = "";
            if ($("#txtSearch").val() != "") {
                search = $("#txtSearch").val();
            }
            // alert(JSON.stringify(filters));
            loading();
            // console.log(filters);
            $.ajax({
                type: "POST",
                url: "manageTax.aspx/searchTaxes",
                data: "{'page':" + page + ",'perpage':'" + perpage + "','search':'" + search + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    $('#tblTaxes > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblTaxes tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    } else {
                        $.each(obj.data, function (i, row) {
                            htm = "";
                            htm += '<tr><td><div style="width:400px;"><div class="fl">';
                            htm += '<span class="myorderMData fl">';
                            htm += '<a class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal">' + getHighlightedValue(search, row.name.toString()) + '</td></span>';
                            htm += '<td><div style="width:400px;"><div class="fl"><span class="myorderMData fl"><a class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal">' + getHighlightedValue(search, row.name.toString()) + '</td></span>';
                            htm += '<td><div style=""><div class="fl"><span class="myorderMData fl"><a class="fl" style="color: inherit; margin-bottom:0px;font-weight:normal">' + row.rate + '</td></span>';
                            htm += "<td><a class='btn btn-primary btn-xs' style='text-align:center;'><li class='fa fa-pencil' style='font-size:14px;margin-top:3px;' onclick=javascript:SelectData(" + row.tp_tax_code + ") title='Edit'></li></a></td>";
                            htm += '</div></div>';
                            htm += '</td></tr>';
                            $('#tblTaxes > tbody').append(htm);
                        });
                        htm = '<tr>';
                        htm += '<td colspan="4">';
                        htm += '<div  id="divPagination" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $('#tblTaxes > tbody').append(htm);
                        //$('#tblCustomers > tbody').html(htm);
                        $('#divPagination').html(paginate(obj.count, perpage, page, "searchTaxes"));
                    }

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
        function addTaxMethod(type) {
            sqlInjection();
            var taxcode = $("#txtTaxCode").val();
            var taxtitle = $("#txtTaxTitle").val();
            var taxtype = $("#comboTaxType").val();
            var taxrate = $("#txtRate").val();
            var cess = $("#txtCess").val();
            //if (taxcode == "") {
            //    alert("Enter taxcode");
            //    return false;
            //}
            if (taxtitle == "") {
                alert("Enter tax name");
                return false;
            } if (taxtype == "" || taxtype == -1) {
                alert("Choose tax type");
                return false;
            } if (taxrate == "") {
                alert("Enter tax rate");
                return false;
            }
            if (cess == "") {
                cess = 0;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "manageTax.aspx/addTaxMethod",
                data: "{'taxcode':'" + taxcode + "','taxtitle':'" + taxtitle + "','taxtype':'" + taxtype + "','taxrate':'" + taxrate + "','cess':'" + cess + "','type':'" + type + "','updateId':'" + updateId + "','sessionId':'" + sessionId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (type == 0) {
                            alert("Tax Added Successfully");
                        } else if (type == 1) {
                            alert("Tax Updated Successfully");
                        }
                        location.reload();

                    }
                    else {
                        alert("Tax Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }



        function SelectData(id) {
            updateId = id;
            loading();
            $.ajax({
                type: "POST",
                url: "manageTax.aspx/SelectData",
                data: "{'id':" + id + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    Unloading();
                    console.log(msg.d);
                    if (msg.d == "N") {
                        alert("There is an error...");
                    } else {
                        var obj = JSON.parse(msg.d);
                        console.log(obj);
                        $("#txtTaxCode").val(obj.data[0]["tp_tax_code"]);
                        $("#txtTaxTitle").val(obj.data[0]["tp_tax_title"]);
                        $("#comboTaxType").val(obj.data[0]["tp_tax_type"]);
                        $("#txtRate").val(obj.data[0]["tp_tax_percentage"]);
                        $("#txtCess").val(obj.data[0]["tp_cess"]);
                        $("#popupTaxSlab").modal('show');
                        $("#btnSave").hide();
                        $("#btnUpdate").show();
                        $("#btnupdateCancel").show();
                        $("#btnsaveCancel").hide();
                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });

        }



        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        function clearTaxForm() {
            $("#txtTaxCode").val("");
            $("#txtTaxTitle").val("");
            $("#comboTaxType").val("-1");
            $("#txtRate").val("");
            $("#txtCess").val("");
            $("#btnSave").show();
            $("#btnUpdate").hide();
            $("#btnupdateCancel").hide();
            $("#btnsaveCancel").show();
            //$("#popupUser").modal('hide');
        }
        function cancelUpdateTaxMethod() {
            SelectData(updateId);
            $("#btnSave").hide();
            $("#btnUpdate").show();
            $("#btnupdateCancel").show();
            $("#btnsaveCancel").hide();

        }

        function resetTaxes() {
            $("#txtSearch").val('');
            searchTaxes(1);
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
                                    <label style="font-weight: bold; font-size: 16px;">Taxes</label>
                                </div>

                                <div class="col-md-6 col-xs-5" data-toggle="modal" data-target="#popupTaxSlab" onclick="clearTaxForm();">
                                    <label class="fa fa-plus-square pull-right" style="text-align: right; font-size: 12px; color: green; cursor: pointer;">
                                        <label style="margin-left: 4px; cursor: pointer;">Add Tax</label></label>
                                </div>


                            </div>

                        </nav>
                    </div>
                </div>
                <!-- /top navigation -->


                <!-- page content -->
                <div class="right_col" role="main">

                    <div class="page-title">
                        <div class="title_left" style="width: 100%;">
                        </div>
                    </div>


                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <div class="col-md-8 col-sm-6 col-xs-8" style="padding-right: 0px;">
                                        <div class="input-group">

                                            <input type="text" class="form-control" id="txtSearch" placeholder="Tax code/Title" style="height: 34px; padding-right: 2px;">

                                            <span class="input-group-btn" title="search">

                                                <button type="button" class="btn btn-default" onclick="searchTaxes(1)">
                                                    <i class="fa fa-search" title="search"></i>
                                                </button>
                                            </span>

                                        </div>
                                    </div>
                                    <div class="col-md-1" style="padding-left: 20px;" onclick="resetTaxes()"><a class="btn btn-primary btn-xs" style="text-align: center; background: #337ab7; border-color: #2e6da4;">
                                        <li class="fa fa-refresh" style="padding: 3px; font-size: 19px; color: white; margin-top: 3px;" onclick="" title="Refresh"></li>
                                    </a></div>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <%--                            <li>

                                                <span style="margin-right: 25px; line-height: 27px; color: #808080;"><strong>Total Records:</strong>
                                                    <label id="lbltotalRecors"></label>
                                                </span>
                                            </li>--%>
                                        <li>

                                            <select class="input-sm" id="slPerpage" onchange="javascript:searchTaxes(1);">
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
                                        <table id="tblTaxes" class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Tax code<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</span></th>
                                                    <th>Name</th>
                                                    <th style="width: 200px;">Rate(%)</th>
                                                    <th style="width: 200px;">Action</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr>
                                                    <td colspan="3"></td>
                                                </tr>
                                            </tbody>
                                        </table>


                                    </div>

                                </div>
                            </div>
                        </div>

                        <%-- start popup starts for add new user --%> <%--popupTaxSlab--%>
                        <div class="modal fade" id="popupTaxSlab" role="dialog">
                            <div class="modal-dialog modal-lg" style="width: ;">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" onclick="javascript:popupclose('popupTaxSlab');">&times;</button>
                                        <div class="col-md-6 col-sm-6 col-xs-8">
                                            <h4 class="modal-title">Tax Slab Entry</h4>
                                        </div>

                                    </div>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-12">
                                                <formview role="form" class="form-horizontal">
                                                        
                                                        <div class="form-group"  style="display:none">

                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                Tax Code<span class="required">*</span>
                                                            </label>
                                                            <input type="hidden" value="0" id="txtTaxId" />
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtTaxCode" placeholder="Enter tax code" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                Tax Title/HSN code<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtTaxTitle" placeholder="Enter tax title" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                Tax Type<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <select class="form-control" id="comboTaxType">
                                                                    <option value="-1" selected="selected">--Select--</option>
                                                                    <option value="0">NO TAX</option>
                                                                    <option value="1">VAT</option>
                                                                    <option value="2">GST</option>
                                                                </select>
                                                            </div>
                                                        </div>

                                                          <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                Tax Rate<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtRate" placeholder="Enter tax rate" required="required" class="form-control col-md-7 col-xs-12">
                                                            </div>
                                                        </div>

                                                          <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12">
                                                                Cess<span class="required">*</span>
                                                            </label>
                                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                                <input type="text" id="txtCess" placeholder="Enter cess" required="required" class="form-control col-md-7 col-xs-12" value="0">
                                                            </div>
                                                        </div>

                                                    </formview>
                                                <div class="clearfix"></div>

                                                <div class="ln_solid"></div>
                                                <div class="form-group" style="padding-bottom: 40px;">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                        <div id="btnSave">
                                                            <div class="btn btn-success mybtnstyl" onclick="javascript:addTaxMethod(0);">SAVE</div>
                                                        </div>
                                                        <div id="btnUpdate" style="display: none;">
                                                            <div class="btn btn-success mybtnstyl" onclick="javascript:addTaxMethod(1);">UPDATE</div>
                                                        </div>
                                                        <div id="btnsaveCancel" style="display: none">
                                                            <div class="btn btn-danger mybtnstyl" onclick="javascript:clearTaxForm();">CANCEL</div>
                                                        </div>
                                                        <div id="btnupdateCancel" style="display: none">
                                                            <div class="btn btn-danger mybtnstyl" onclick="javascript:cancelUpdateTaxMethod();">CANCEL</div>
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

</body>
</html>
