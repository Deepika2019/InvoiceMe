<%@ Page Language="C#" AutoEventWireup="true" CodeFile="redeemPackage.aspx.cs" Inherits="redeemPackage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Redeem Packages | Invoice Me</title>
    <script src="js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="js/jquery.cookie.js"></script>
    <script type="text/javascript" src="js/jQuery.print.js"></script>
    <script src="js/pagination.js" type="text/javascript"></script>
    <link rel="stylesheet" href="mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">

        var htm = "";
        var queryParams = {};
        var customerid = 0;
        var customerId= <%=customerId%>;
        var customerName= '<%=customerName%>';
        var packageId=0;
        var currentCount=0;
        $(document).ready(function () {
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            if (!BranchId) {
                location.href = "dashboard.aspx";
                return false;
            }
            if (!CountryId) {
                location.href = "dashboard.aspx";
                return false;
            }
            $("#txtPckgCount").keypress(function (e) {
                //if the letter is not digit then display error and don't type anything
                if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
                    //display error message
                    alert("Support digits only");
                    return false;
                }
            });
            customerid = getQueryString("customerid");
            if (getQueryString("customerid") != undefined && getQueryString("customerid") != "") {
              $("#lblcusomer").text("#"+customerid+" "+customerName);
                resetFilters();
            }

            else {
                window.location.href = "Customers.aspx";
            }


            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");
            var yyyy = new Date().getFullYear();
            var curr_date = new Date().getDate();
            $('#pckgDate').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'dd-mm-yy'
                // dateFormat: 'dd-MM-yy'
            });
            ShowUTCDate();
        });
    
        function ShowUTCDate() {
            var dNow = new Date();
            var date = dNow.getDate();
            if (date < 10) {
                date = "0" + date;
            }
            var localdate = date + '-' + GetMonthName(dNow.getMonth() + 1) + '-' + dNow.getFullYear();
            $("#pckgDate").val(localdate);
            return;
        }

        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
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



        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

    
        //function for reset 
        function resetFilters() {
            $("#txtSearchItem").val("");
            searchPackages(1);
        }

        function searchPackages(page) {
            var branchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");

            if ((!branchId || branchId == "undefined" || branchId == "" || branchId == "null") || (!CountryId || CountryId == "undefined" || CountryId == "" || CountryId == "null")) {
                location.href = "dashboard.aspx";
                return false;
            }
            var postObj = {
                page: page,
                perpage: $("#slPerpage").val(),
                filters: {
                }
            }
            if ($("#txtSearchItem").val() != "") {
                postObj.filters.search = $("#txtSearchItem").val();
            }
            postObj.filters.custId = customerid;
            $.ajax({
                type: "POST",
                url: "redeemPackage.aspx/searchPackages",
                data: JSON.stringify(postObj),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    console.log(msg.d);
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    var slno = 0;
                    $('#tblPacakgeData > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblPacakgeData tbody").html('<td colspan="7" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        slno++;
                        htm = "";
                        htm += "<tr>";
                        htm += "<td>" + slno + "</td>";
                        htm += "<td><label>#" + getHighlightedValue(postObj.filters.search, row.itm_code) + "</label> " + getHighlightedValue(postObj.filters.search, row.itm_name);
                        if(row.currentCount==0){
                            htm+="  <span class='status label label-default'>Completed</span>";
                        }
                        
                        htm+="</td>";
                        htm += "<td>" + row.pckgDate + "</td>";
                        htm += "<td><a href='/sales/manageorders.aspx?orderId=" + row.sm_id + "' style='text-decoration:none; color:#056dba;' target='_blank'>#" + row.sm_id + "</a></td>";
                        htm += "<td>"+row.currentCount+"</td>";
                        htm += "<td>" + row.total + "</td>";
                        if(row.currentCount==0){
                            htm += '<td><a class="btn btn-primary btn-xs" style="text-align: center;background-color: #45ad46; border-color: #45ad46" onclick="showRedeemHistory('+row.package_id+');">History</a></td>';
                        }else{
                            htm += '<td><a class="btn btn-primary btn-xs" style="text-align: center; background-color: #e01d1d; border-color: #e01d1d" onclick="showRedeemPopUp('+row.package_id+','+row.currentCount+');">Redeem</span></a><a class="btn btn-primary btn-xs" style="text-align: center;background-color: #45ad46; border-color: #45ad46" onclick="showRedeemHistory('+row.package_id+');">History</a></td>';
                        }
                        htm += "</tr>";
                        $('#tblPacakgeData > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="7">';
                    htm += '<div  id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblPacakgeData > tbody').append(htm);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, $("#slPerpage").val(), page, "searchLeaveDatas"));
                    //Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    // alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }

        function showRedeemPopUp(id,count){
            packageId=id;
            currentCount=count;
            $("#txtPckgCount").val(1);
            $("#lblCurrentCount").text("(Available Count:"+currentCount+")");
            $("#popUpRedeem").modal('show');
        }
        function redeemPackage(){
            if($("#txtPckgCount").val()>currentCount){
                alert("Sorry this customer have only "+currentCount+" packages exist");
                return;
            }
            if ($("#pckgDate").val() != "") {
                var splitarrayone = $("#pckgDate").val().split("-");
               pckgDate = splitarrayone[2] + "-" + splitarrayone[1] + "-" + splitarrayone[0];
            }
            $.ajax({
                type: "POST",
                url: "redeemPackage.aspx/redeemPckage",
                data: "{'packageId':'" + packageId + "','count':'" + $("#txtPckgCount").val() + "','pkgdate':'" + pckgDate + "','customerId':'" + customerid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if(msg.d=="Y"){
                        alert("Redeemed successfully");
                        popupclose('popUpRedeem');
                        searchPackages(1);
                       
                        return;
                    }else{
                        alert("There is an error");
                        return;
                    }
                
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function showRedeemHistory(id){
            $.ajax({
                type: "POST",
                url: "redeemPackage.aspx/showRedeemHistory",
                data: "{'packageId':'" + id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    console.log(obj);
                    $("#lblPkgRef").text(id);
                    htm = "";
                    if(obj.length==0){
                        htm= '<div class="col-md-6" style="margin-bottom:10px;text-align:center"><b>No History found</b><span id=""></span></div>';
                    }else{
                        $.each(obj, function (i, row) {
                  
                            htm+='<ul class="list-group"><li class="list-group-item list-group-item-danger justify-content-between" style="color:#2450ce;background-color:#e4f2de">';
                            htm+='Date:'+row.packageDate+'<span class="badge badge-default" style="color:red;background-color:transparent;font-size:14px;">Count:'+row.redeem_count+'</span>';
                            htm+='</li></ul>';
                        });
                    }
               
                    $("#divHistory").html(htm)
                    $("#popupHistory").modal('show');
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
    <form id="form1" runat="server">
        <div class="container body">
            <div class="main_container">
                <div class="col-md-3 left_col">
                    <div class="left_col scroll-view">
                        <div class="navbar nav_title" style="border: 0;">
                            <a href="index.html" class="site_title">
                                <!--<i class="fa fa-paw"></i>-->
                                <span>Invoice</span></a>
                        </div>

                        <div class="clearfix"></div>

                        <!-- menu profile quick info -->
                        <div class="profile clearfix">
                            <div class="profile_pic">
                                <img src="images/img.jpg" alt="..." class="img-circle profile_img">
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
                                    <label style="font-weight: bold; font-size: 16px;">Redeem Packages</label>
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
                            <div class="title_right" style="text-align: right; float: right">
                        <label id="lblcusomer">#3123 THomas</label>
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

                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <div class="col-md-10 col-sm-6 col-xs-8" style="padding-right: 0px;">
                                        <div class="input-group">

                                            <input type="text" class="form-control" id="txtSearchItem" placeholder="Search package code/Name" style="height: 34px; padding-right: 2px;">

                                            <span class="input-group-btn" title="search">

                                                <button type="button" class="btn btn-default" onclick="searchPackages(1)">
                                                    <i class="fa fa-search" title="search"></i>
                                                </button>
                                            </span>

                                        </div>
                                    </div>




                                        <div class="fl" style="padding-left: 2px;" onclick="resetFilters()"><a class="btn btn-primary btn-xs" style="text-align: center; background: #337ab7; border-color: #2e6da4;">
                                        <li class="fa fa-refresh" style="padding: 3px; font-size: 19px; color: white; margin-top: 3px;" onclick="" title="Refresh"></li>
                                    </a></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">

                                        <ul class="nav navbar-right panel_toolbox">

                                            <li>

                                                <select class="input-sm" id="slPerpage" onchange="javascript:searchPackages(1);">
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
                                            <table id="tblPacakgeData" class="table table-hover" style="table-layout: auto;">
                                                <thead>
                                                    <tr>
                                                        <th>Sl.No<label class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors">0</label></th>
                                                        <th>Package</th>
                                                        <th>Date</th>
                                                        <th>Bill Ref Id</th>
                                                        <th>UsedCount</th>
                                                         <th>AvailableCount</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>


                                        </div>

                                    </div>
                                </div>
                            </div>

                            <%-- start popup starts for add new user --%>
                            <div class="modal fade" id="popupLeave" role="dialog">
                                <div class="modal-dialog modal-md">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popupLeave');">&times;</button>
                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                <h4 class="modal-title">Leave Request</h4>
                                            </div>

                                        </div>
                                        <div class="modal-body">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <form role="form" class="form-horizontal">
                                              

                                                    </form>
                                                    <div class="clearfix"></div>

                                                    <div class="ln_solid"></div>
                                                    

                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%-- end popup starts for add new user --%>
                               <div class="clearfix"></div>
                            <%-- start popup for redeem history --%>
                               <div class="modal fade" id="popupHistory" role="dialog">
                        <div class="modal-dialog modal-md" style="">

                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header" style="padding-bottom: 5px;">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                        <h4 class="modal-title">Package #<span id="lblPkgRef"></span></h4>
                                    </div>
                                </div>
                               <div class="x_content" id="divHistory">
                                        <ul class="list-group"><li class="list-group-item list-group-item-danger justify-content-between" style="color:#2450ce;background-color:#e4f2de">Date:12/05/2018<span class="badge badge-default" style="color:red;background-color:transparent;font-size:14px;">Count:6</span> </li></ul>
                                       <ul class="list-group"><li class="list-group-item list-group-item-danger justify-content-between" style="color:#2450ce;background-color:#e4f2de">Date:12/05/2018<span class="badge badge-default" style="color:red;background-color:transparent;font-size:14px;">Count:6</span> </li></ul>
                                    <ul class="list-group"><li class="list-group-item list-group-item-danger justify-content-between" style="color:#2450ce;background-color:#e4f2de">Date:12/05/2018<span class="badge badge-default" style="color:red;background-color:transparent;font-size:14px;">Count:6</span> </li></ul>
                                    <ul class="list-group"><li class="list-group-item list-group-item-danger justify-content-between" style="color:#2450ce;background-color:#e4f2de">Date:12/05/2018<span class="badge badge-default" style="color:red;background-color:transparent;font-size:14px;">Count:6</span> </li></ul>
                                    </div>
                                <div class="clearfix"></div>
                                <div class="ln_solid"></div>
                            </div>

                        </div>
                    </div>
                             <%-- start popup for redeem history --%>
                            <div class="clearfix"></div>
                            <%-- popup for showing transaction details --%>

                        <div class="modal fade" id="popUpRedeem" role="dialog">
                                <div class="modal-dialog modal-md">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" onclick="javascript:popupclose('popUpRedeem');">&times;</button>
                                            <div class="col-md-6 col-sm-6 col-xs-8">
                                                <h4 class="modal-title">Redeem Package</h4>
                                            </div>

                                        </div>
                                        <div class="modal-body">
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <form role="form" class="form-horizontal">
                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Used Packages<span class="required">*</span>
                                                            </label>
                                                            <div class="form-group col-md-6 col-sm-6 col-xs-12">
                                                                 <input type="text" id="txtPckgCount" placeholder="Enter Used Qty" required="required" class="form-control col-md-7 col-xs-12" value="1">
                                                            </div><label id="lblCurrentCount"></label>
                                                        </div>

                                                        

                                                        <div class="form-group">
                                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                                Date<span class="required">*</span>
                                                            </label>
                                                            <div class="form-group col-md-6 col-sm-6 col-xs-12">
                                                                <input id="pckgDate" placeholder="Date" required="required" class="form-control col-md-7 col-xs-12" type="text">
                                                            </div>
                                                        </div>

                                                        

                                                        

                                                    </form>
                                                    <div class="clearfix"></div>

                                                    <div class="ln_solid"></div>
                                                    <div class="form-group" style="padding-bottom: 40px;">
                                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                            <div id="btnSave">
                                                                <div class="btn btn-success mybtnstyl" onclick="javascript:redeemPackage();">SAVE</div>
                                                            </div>
                                                           
                                                        </div>
                                                    </div>

                                                </div>

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
