<%@ Page Language="C#" AutoEventWireup="true" CodeFile="warehouse.aspx.cs" Inherits="inventory_warehouse" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Warehouse  | Invoice Me</title>
    <%-- Edited --%>
    <script src="../js/common.js"></script>
    <script src="../js/jquery-2.0.3.js"></script>
    <script src="../js/pagination.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
     <script src="../js/ajaxupload.js" type="text/javascript"></script>
    <%-- end --%>
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />



    <script type="text/javascript">
        $(document).ready(function () {

            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            //if (!BranchId) {
            //    location.href = "../dashboard.aspx";
            //    return false;
            //}
            //if (!CountryId) {
            //    location.href = "../dashboard.aspx";
            //    return false;
            //}
            //showProfileHeader(1);
            clearBranch();
          //  searchBranchDetails(1);
            getCountryNames(-1,-1);
            showCurrency();
            $("#txtitemcountry").val("0");


            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");


        });

        $(function () {
            new AjaxUpload('#btnUploadButton', {
                action: 'UploadHandler.ashx',
                onComplete: function (file, response) {
                  //  alert(response);

                    if ($("#hdnImages").val()) {

                        $.ajax({
                            url: "UploadHandler.ashx?file=" + $("#hdnImages").val(),
                            type: "GET",
                            cache: false,
                            async: true,
                            success: function (html) {
                                $("#hdnImages").val(response);
                                $('#UploadedFile').html("<img src='../logoImage/" + response + "' style='width:150px;height:140px;padding:2px; border:1px solid #999999;'/>");
                                // $('#UploadedFile').html("<img src='DownloadedFiles/" + response + "' style='width:80px;height:60px;padding:2px; border:1px solid #999999;'/>");
                                return;
                            }
                        });
                    }
                    else {
                        $("#hdnImages").val(response);
                        $('#UploadedFile').html("<img src='../logoImage/" + response + "' style='width:150px;height:140px;padding:2px; border:1px solid #999999;'/>");
                        // $('#UploadedFile').html("<img src='http://DownloadedFiles/" + response + "' style='width:80px;height:60px;padding:2px; border:1px solid #999999;'/>");
                        return;
                    }
                },
                onSubmit: function (file, ext) {
                    if (!(ext && /^(txt|doc|docx|xls|pdf|jpg|png)$/i.test(ext))) {
                        alert('Invalid File Format.');
                        return false;
                    }
                    // $('#UploadStatus').html("Uploading...");
                }
            });

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
        //Stop:TO Replace single quotes with double quotes

        //Get Country names
        function getCountryNames(country, state) {
        //    alert(country + "-" + state);
            loading();
            $.ajax({
                type: "POST",
                url: "warehouse.aspx/getCountryNames",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d != 0 && msg.d != "Y") {

                        $("#txtitemcountry").html(msg.d);
                        $("#txtitemcountry").val(country);
                        getstates(state);

                        return;
                    }
                    else {
                        $("#txtitemcountry").html("No Country Found");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    console.log(status);
                    alert("Internet Problem..!");
                }
            });
        }

        function getstates(currentVal) {
            var country = $("#txtitemcountry").val();
            if (country == -1 || country == null) {
                $("#selState").val(-1);
                return;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "warehouse.aspx/getstates",
                data: "{'country':'" + country + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Select State--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.state_id + '">' + row.state_name + '</option>';
                    });
                    $("#selState").html(htm);
                    $("#selState").val(currentVal);
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        // for inserting branch
        function AddBranch(actiontype, branchid) {

            sqlInjection();

            var country = $("#txtitemcountry").val();
            var state=$("#selState").val();
            var branch = $.trim($("#txtbranch").val());
            var branchemail = $.trim($("#txtBranchEmailid").val());
            var phone1 = $.trim($("#txtphone1").val());
            var phone2 = $.trim($("#txtphone2").val());
            var address = $.trim($("#txtaddress").val());

            //searchitems();
            var countryName = $("#txtitemcountry option[value='" + country + "']").text();
            var Currency = $("#comboCurrency").val();
            var TimeZone = $("#comboTimeZone").val();
            var BillDisclosure = $("#txtBillDisclosure").val();
            var BillFooter = $("#txtBillFooter").val();
            var imagePath = $("#hdnImages").val();
            var registerNumber = $("#txtRegNumber").val();
            var taxMethod = $("#selTaxMethod").val();
            var isInclusive = $("#selInclusive").val();
            var orderPrefix = $("#txtOrderPrefix").val().replace(/ /g, '');;
            var orderNumber = $("#txtOrderStart").val().replace(/ /g, '');;
            var serialNumber = $("#txtSerialNumber").val();
            var declaration = $("#txtdeclaration").val()
            // loading();
            //alert(country+countryName);
            if ($("#txtitemcountry").val() == "" || $("#txtitemcountry").val() == "-1") {
                alert("Please Select Country...!");
                return;
            }
            if (state == "" || state == -1) {
                alert("Please Select state...!");
                return;
            }
            if (branch == "") {
                alert("Please Enter Warehouse Name...!");
                return;
            }

            if (branchemail == "") {
                alert("Please Enter Email Id...!");
                return;
            }
            var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

            if (!filter.test(branchemail)) {
                alert('Please provide a valid email address');
                return false;
            }
            if (address == "") {
                alert("Please Enter  Address...!");
                return;
            }


            if (phone1 == "") {
                alert("Please Enter  Phone number...!");
                return;
            }
            if (isNaN(phone1)) {
                alert("Phone1 should be in number only...!");
                return false;
            }
            if (taxMethod == "" || taxMethod == "-1") {
                alert("Please select tax method...!");
                return;
            }
            if (isInclusive == "" || isInclusive == "-1") {
                alert("Please select price tax type...!");
                return;
            }
            if (Currency == "" || Currency == "0" || Currency == null) {
                alert("Please Select Currency...!");
                return;
            }
            if (TimeZone == "" || TimeZone == "0" || TimeZone == null) {
                alert("Please Select TimeZone...!");
                return;
            }
            //if (orderPrefix == "") {
            //    alert("Please Enter  Order Prefix...!");
            //    return;
            //}

            //if (imagePath == "") {
            //    alert("Please choose your logo image...!");
            //    return;
            //}

            loading();

            $.ajax({
                type: "POST",
                url: "warehouse.aspx/AddBranch",
                data: "{'Actiontype':'" + actiontype + "','Branchid':'" + branchid + "','CountryId':'" + country + "','countryName':'" + countryName + "','Branch':'" + branch + "','BranchEmail':'" + branchemail + "','Phone1':'" + phone1 + "','Phone2':'" + phone2 + "','Address':'" + address + "','Currency':'" + Currency + "','TimeZone':'" + TimeZone + "','BillDisclosure':'" + BillDisclosure + "','BillFooter':'" + BillFooter + "','imagePath':'" + imagePath + "','registerNumber':'" + registerNumber + "','taxMethod':'" + taxMethod + "','isInclusive':'" + isInclusive + "','state':'" + state + "','orderPrefix':'" + orderPrefix + "','orderNumber':'" + orderNumber + "','declaration':'" + declaration + "','serialNumber':'" + serialNumber + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    
                    if (msg.d == "Y") {
                        if (actiontype == "insert") {

                            alert("Warehouse added Successfully...!");
                            //viewBranchfull();
                            clearBranch();
                            searchBranchDetails(1);
                            // clearBranch();

                        }
                        if (actiontype == "Update") {
                            alert("Warehouse Updated Successfully...!");
                            clearBranch();
                            searchBranchDetails(1);
                        }
                        return;
                    } else if (msg.d == "P") {
                        alert("Given prefix already used in one of the warehouse. Please change value...");
                        return;
                    }
                    else {
                        alert("Warehouse name already used. Try again with another Name");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function viewBranchfull() {

        //    loading1();
        //    // alert(searchResult);
        //    // var searchResult1 = "where  first_name LIKE *z%*";
        //    //return;
        //    $.ajax({
        //        type: "POST",
        //        url: "warehouse.aspx/viewBranchservice",
        //        data: "{}",
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (msg) {
        //            // alert(msg.d);
        //            //alert("Success");
        //            Unloading1();
        //            // return;
        //            if (msg.d == "N") {
        //                alert("Error Occured..!");
        //                return;
        //            }
        //            if (msg.d != "N") {


        //                var splitarray = msg.d.split("*");
        //                $("#btnitemMasterAction").html("<div class='btn btn-success' onclick='javascript:AddBranch('Update','" + splitarray[0] + "');' >Update</div>");
        //                $("#txtbranch").val(splitarray[1]);
        //                $("#txtphone").val(splitarray[3]);
        //                $("#txtaddress").val(splitarray[4]);
        //                $("#txtitemcountry").val(splitarray[2]);
        //                //   $("#txtServiceTax").val(splitarray[5]);
        //                //  $("#txtCess").val(splitarray[6]);
        //                return;
        //            }

        //        },
        //        error: function (xhr, status) {
        //            Unloading1();
        //            alert("Internet Problem..!");
        //        }
        //    });

        //}
        function searchitems() {
            for (var i = 1; i <= 6; i++) {

                $("#txtitemsearch" + i).val('');

            }
            searchBranchDetails(1);
        }

        // for showing search results
        function searchBranchDetails(page) {
            // alert(page);
            sqlInjection();
            var filters = {};
            // alert($("#txtitemsearch1").val());
            

            if ($("#txtitemsearch2").val() !== undefined && $("#txtitemsearch2").val() != "") {
                filters.country = $("#txtitemsearch2").val();
            }

            if ($("#txtitemsearch3").val() !== undefined && $("#txtitemsearch3").val() != "") {
                filters.warehouse = $("#txtitemsearch3").val();
            }

            if ($("#txtitemsearch4").val() !== undefined && $("#txtitemsearch4").val() != "") {
                filters.phone = $("#txtitemsearch4").val();
            }

            var perpage = $("#txtpageno").val();
            console.log(JSON.stringify(filters));
            loading();
            //return;
            $.ajax({
                type: "POST",
                url: "warehouse.aspx/searchBranchMaster",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    if (msg.d == "N") {
                        Unloading();
                        $("#itemsearchdiv1 tbody").html('<td colspan="5"><div style="font-weight:bold;text-align:center;padding:10px;" >Nothing Found...</div></td>');
                        $("#lblTotalrerd").text(0);
                        $("#paginatediv").html('');
                    }
                    else {
                        var obj = JSON.parse(msg.d)
                        //   console.log(obj);
                        Unloading();
                        var htm = "";
                        //htm += '<tr style="font-size:12px;">';
                        //htm += '<td colspan="5" style="padding:5px; text-align:center; overflow:hidden; border-right:none;">';
                        //htm += '<div><span style="margin-left:0px;float:right;text-align:right;font-size:14px;">Total Records:' + obj.count + '</span></div>';
                        //htm += '</td> </tr>';
                        $.each(obj.data, function (i, row) {
                            //    console.log(row);
                            htm += "<tr onclick=javascript:editBranchMaster('" + row.branch_id + "','itemMasterRow" + i + "'); id='itemMasterRow" + i + "'>";
                            htm += "<td>" + row.branch_id + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.country, row.branch_country_name.toString()) + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.warehouse, row.branch_name.toString()) + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.phone, row.branch_phone1.toString()) + "</td><td><a class='btn btn-primary btn-xs' style='text-align:center;'><li class='fa fa-eye' style='font-size:20px;'></li></a></td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="5">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#itemsearchdiv1 tbody").html(htm);
                        $("#lblTotalrerd").text(obj.count);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "searchBranchDetails"));
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }
        function editBranchMaster(Id) {
            loading();
            $.ajax({
                type: "POST",
                url: "warehouse.aspx/editBranchMaster",
                data: "{'Id':'" + Id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    if (msg.d != 0) {
                        clearBranch();
                        var splitarray = msg.d.split("*");
                        // $("#btnitemMasterAction").html("<div class='btn btn-success' onclick='javascript:AddBranch('insert',0);'>Save</div>");

                        $("#btnitemMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:AddBranch(\"Update\"," + splitarray[0] + ");'>UPDATE</div>");
                        getCountryNames(splitarray[2], splitarray[16]);
                        $("#txtbranch").val(splitarray[1]);
                        $("#txtphone1").val(splitarray[3]);
                        $("#txtaddress").val(splitarray[4]);
                      //  $("#txtitemcountry").val(splitarray[2]);
                      //  alert(splitarray[16]);
                    //    getstates(splitarray[16]);
                        $("#txtBranchEmailid").val(splitarray[6]);
                        $("#txtphone2").val(splitarray[7]);

                        $("#comboCurrency").val(splitarray[8]);
                        $("#comboTimeZone").val(splitarray[9]);
                        $("#txtBillDisclosure").val(splitarray[10]);
                        $("#txtBillFooter").val(splitarray[11]);
                        $("#hdnImages").val(splitarray[12]);
                        $("#txtRegNumber").val(splitarray[15]);
                        $("#selTaxMethod").val(splitarray[13]);
                        $("#selInclusive").val(splitarray[14]);
                        $("#txtOrderPrefix").val(splitarray[17]);
                        $("#txtOrderStart").val(splitarray[18]);
                        $("#txtdeclaration").val(splitarray[19]);
                        $("#txtSerialNumber").val(splitarray[20]);
                        if (splitarray[12]!="") {
                            $('#UploadedFile').html("<img src='../logoImage/" + splitarray[12] + "' style='width:150px;height:140px;padding:2px; border:1px solid #999999;'/>");
                    }
                        $('html,body').animate({
                            scrollTop: $('#DivWarehouseDetails').offset().top
                        }, 500);
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }
        function clearBranch() {
            $("#btnitemMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:AddBranch(\"insert\",0);'>SAVE</div>");
            $("#txtbranch").val('');
            $("#txtphone1").val('');
            $("#txtaddress").val('');
            $("#txtitemcountry").val('-1');
            $("#txtServiceTax").val('');
            $("#txtCess").val('');
            $("#txtBranchCode").val('');
            $("#txtBranchEmailid").val('');
            $("#txtphone2").val('');
            $("#txtphone3").val('');
            $("#comboCurrency").val('0');
            $("#comboTimeZone").val('0');
            $("#txtBillDisclosure").val('');
            $("#txtBillFooter").val('');
            $("#txttargetsales").val('');
            $("#hdnImages").val('');
            $('#UploadedFile').html("");
            $("#txtRegNumber").val('');
            $("#selTaxMethod").val('-1');
            $("#selInclusive").val('-1');
            $("#selState").val(-1);
            $("#txtOrderPrefix").val('');
             $("#txtOrderStart").val('');
            $("#txtOutPrefix").val('');
            $("#txtOutStart").val('');
            $("#txtdeclaration").val('');
            $("#txtSerialNumber").val('')
            searchitems();
        }

        //Get Country names
        function showCurrency() {
            loading();
            $.ajax({
                type: "POST",
                url: "warehouse.aspx/showCurrency",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d != 0 && msg.d != "Y") {

                        $("#comboCurrency").html(msg.d);

                        return;
                    }
                    else {

                        return;
                    }

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
                        <a href="#" class="site_title"><span>Invoice Me</span></a>
                    </div>

                    <div class="clearfix"></div>

                    <!-- menu profile quick info -->
                    <div class="profile clearfix">
                        <div class="profile_pic">
                            <%--<img src="../images/img.jpg" alt="..." class="img-circle profile_img">--%>
                        </div>
                        <div class="profile_info">
                            <%-- <span>Welcome,</span>
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
                            <label style="font-weight: bold; font-size: 16px;">Warehouse</label>

                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%-- <div class="page-title">

                        <div class="title_left" style="width: 100%;">
                            <label style="font-size: 16px; font-weight: bold;">Warehouse</label>
                        </div>
                    </div>--%>

                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="DivWarehouseDetails">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    <label>Basic Details </label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                    </ul>

                                </div>
                                <div class="x_content">
                                    <br />
                                    <form id="demo-form2" data-parsley-validate class="form-horizontal form-label-left">
                                        <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Country<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="txtitemcountry" onchange="getstates(-1);">
                                                    <option value="0">-Select Country-</option>
                                                </select>
                                            </div>
                                        </div>
                                              <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                State<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="selState">
                                                    <option value="-1">-Select State-</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Name <span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input type="text" id="txtbranch" placeholder="Enter Warehouse Name" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>
                                             <%--<div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Registration No: <span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input type="text" id="txtRegNumber" placeholder="Enter Registration Number" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>--%>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="last-name">
                                                Email ID<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input type="text" id="txtBranchEmailid" placeholder="Enter Email ID" name="" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Address <span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <textarea class="form-control" rows="3" placeholder="Enter Address" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none" id="txtaddress"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Phone1<span class="required">*</span></label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtphone1" placeholder="Enter Phone" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="number" name="middle-name">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Phone2</label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtphone2" placeholder="Enter Phone" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="number" name="middle-name">
                                            </div>
                                        </div>
 <div class="form-group">
                                            <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Registration No</label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtRegNumber" placeholder="Enter registration number" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="text" name="middle-name">
                                            </div>
                                        </div>
                                         <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Tax Method<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="selTaxMethod">
                                                    <option value="-1">Select</option>
                                                    <option value="0">NO TAX</option>
                                                    <option value="1">VAT</option>
                                                    <option value="2">GST</option>
                                                </select>
                                            </div>
                                        </div>
                                               <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Price tax<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="selInclusive">
                                                    <option value="-1">Select</option>
                                                    <option value="0">Exclusive</option>
                                                    <option value="1">Inclusive</option>
                                                </select>
                                            </div>
                                        </div>

                     
                                        </div>
                                         <div class="col-md-6">
                                        
                                          <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Currency<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="comboCurrency">
                                                    <option value="0">-Select Currency-</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Time Zone<span class="required">*</span>
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <select class="form-control" id="comboTimeZone">
                                                    <option value="0">-Select TimeZone-</option>
                                                    <option value="Arabian Standard Time">Arabian Time Zone (UTC+04:00)</option>
                                                    <option value="India Standard Time">Indian Time Zone  (UTC+05:30)</option>
                                                      <option value="W. Central Africa Standard Time">West Africa Time Zone  (UTC+01:00)</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Order Disclosure
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <textarea class="form-control" id="txtBillDisclosure" rows="3" placeholder="" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Order Footer
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <textarea class="form-control" id="txtBillFooter" rows="3" placeholder="" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                            </div>
                                        </div>
                                    
                                                <div class="form-group">
                                                       <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Order Prefix</label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtOrderPrefix" placeholder="Enter order prefix" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="text" name="middle-name">
                                            </div>
                                                    </div>
                                                <div class="form-group">
                                                       <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Serial Number</label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtSerialNumber" placeholder="Enter starting Serial Number" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="number" name="middle-name">
                                            </div>
                                                    </div>
                                              <div class="form-group">
                                                       <label for="middle-name" class="control-label col-md-4 col-sm-3 col-xs-12">Order Suffix</label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <input id="txtOrderStart" placeholder="Enter order suffix" style="padding: 0px; text-indent: 3px;" class="form-control col-md-7 col-xs-12" type="text" name="middle-name">
                                            </div>
                                                    </div>

                                             <div class="form-group">
                                            <label class="control-label col-md-4 col-sm-3 col-xs-12" for="first-name">
                                                Declaration
                                            </label>
                                            <div class="col-md-8 col-sm-6 col-xs-12">
                                                <textarea class="form-control" id="txtdeclaration" rows="3" placeholder="" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                         
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                      <%--      <label class="control-label" for="first-name">
                                                Choose Logo
                                            </label>
                                                <div class="input-group">
                                                    <input type="button" class="fl" id="btnUploadButton" value="Upload Photo" style="width: 92px; height: 25px; cursor: pointer; margin-top: 5px;" />
                                                    
                                                </div>--%>
                                                   <div class="input-group" style="margin-top:20px;margin-left:20px">
                <input id="fakeUploadLogo" class="form-control fake-shadow" placeholder="Choose File" disabled="disabled" style="height:32px;">
                <div class="input-group-btn">
                  <div class="fileUpload btn btn-danger fake-shadow" style="padding:5px;">
                    <span style="font-size:12px;"><i class="fa fa-upload"></i> Upload Logo</span>
                    <input id="btnUploadButton" name="logo" type="file" class="attachment_upload">
                      <input type="hidden" id="hdnImages" value="" />
                  </div>
                </div>
              </div>

                                                <style>
                                                    /* File Upload */
.fake-shadow {
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}
.fileUpload {
    position: relative;
    overflow: hidden;
}
.fileUpload #btnUploadButton{
    position: absolute;
    top: 0;
    right: 0;
    margin: 0;
    padding: 0;
    font-size: 23px;
    cursor: pointer;
    opacity: 0;
    filter: alpha(opacity=0);
}
                                                </style>
                                            </div>

                                             <div class="col-md-6 col-sm-6 col-xs-12"> <div class="photoDiv" style="margin-left: 22px;" id="UploadedFile">
                                                <%--<img src="images/defaultUser.jpg" width="150" height="140" style="padding: 2px; border: 1px solid #999999;" id="imgMember" alt="" />--%>
                                            </div></div>
                                        </div>
                                            </div>
                                    </form>

                                    <div class="clearfix"></div>
                                    <div class="ln_solid"></div>
                                    <div class="form-group" style="padding-bottom: 40px;">
                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-4 col-xs-offset-1">
                                            <div class="btn btn-primary mybtnstyl" onclick="javascript:clearBranch();">ADD NEW</div>

                                            <div id="btnitemMasterAction">
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:AddBranch('insert',0);">SAVE</div>
                                            </div>
                                            <div onclick="javascript:clearBranch();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                        </div>
                                    </div>

                                    <div class="clearfix"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 5px;">
                                    <label>Warehouses<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <%--                                     <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i>
                                        </li>
                                        <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <div class="row" style="margin-bottom: 5px;">



                                        <%-- <div class="col-md-8 col-sm-12 col-xs-8 ">
                                    
                                                <div type="submit" onclick="javascript:searchBranchDetails(1);" class="btn btn-success mybtnstyl">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </div>
                                                <div class="btn btn-primary mybtnstyl" onclick="javascript:searchitems();">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </div>
                                      
                                        </div>--%>



                                        <div class="form-group" style="float: right; padding-bottom: 5px;">
                                            <div class="col-md-12 col-sm-12 col-xs-12">

                                             <%--   <div class="" style="float: left; margin-right: 10px; line-height: 30px;">
                                                    <span><strong>Total Records:
                                                        <label id=""></label>
                                                    </strong></span>
                                                </div>--%>

                                                <div class="" style="float: left;">
                                                    <button type="button" class="btn btn-success mybtnstyl" onclick="javascript:searchBranchDetails(1);">
                                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                        Search</button>
                                                    <button class="btn btn-primary mybtnstyl" type="button" onclick="javascript:searchitems();">
                                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                        Reset</button>

                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-group" style="float: left;">
                                            <div class="col-md-4 col-sm-3 col-xs-4">
                                                <div class="dataTables_length" id="datatable-checkbox_length">
                                                    <label>
                                                        <select id="txtpageno" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm" onchange="searchBranchDetails(1);">
                                                            <option value="20">20</option>
                                                            <option value="50">50</option>
                                                            <option value="100">100</option>
                                                            <option value="500">500</option>
                                                        </select>
                                                    </label>
                                                </div>
                                            </div>

                                        </div>




                                        <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                            <table id="itemsearchdiv1" class="table table-striped table-bordered" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th style="width:20px;">ID</th>
                                                        <th>Country</th>
                                                        <th>Warehouse</th>
                                                        <th>Phone</th>
                                                        <th>View</th>

                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            
                                                        <td>
                                                            <input type="text" id="txtitemsearch2" placeholder="search" class="form-control" style="width: 100px;" /></td>
                                                        <td>
                                                            <input type="text" id="txtitemsearch3" placeholder="search" class="form-control" /></td>
                                                        <td>
                                                            <input type="text" id="txtitemsearch4" placeholder="search" class="form-control" /></td>
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
                        </div>
                        <div class="clearfix"></div>


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
                    <%--Invoice Me Admin  by <a href="">Lucidplus IT Solutions</a>--%>
                </div>
                <div class="clearfix"></div>
            </footer>
            <!-- /footer content -->
        </div>

        <!-- jQuery -->
        <%--<script src="../js/bootstrap/jquery.min.js"></script>--%>
        <!-- Bootstrap -->
        <script src="../js/bootstrap/bootstrap.min.js"></script>
        <script src="../js/bootstrap/nprogress.js"></script>
        <!-- FastClick -->
        <!-- Custom Theme Scripts -->
        <script src="../js/bootstrap/custom.min.js"></script>
        <script src="../js/bootbox.min.js"></script>
</body>
</html>
