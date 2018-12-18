<%@ Page Language="C#" AutoEventWireup="true" CodeFile="sales_commission.aspx.cs" Inherits="inventory_sales_commission" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Sales Commission | Invoice Me</title>
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
    <!-- Select2 -->
    <link href="../css/bootstrap/select2.min.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            $("#txtSearchFromDate").val('');
            $("#txtSearchToDate").val('');
            $("#lblReportFromDate").text('');
            $("#lblReportToDate").text('');
            $("#lblSummaryFromDate").text('');
            $("#lblSummaryToDate").text('');
            $("#commission").val('');
            // showProfileHeader(1);
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            showBranches();
           
         
            $('#chkbxId').attr('checked', false);
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © ");
      
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



        function checkAll(ele) {
            // alert("haii");
            var checkboxes = document.getElementsByTagName('input');
            if (ele.checked) {
                for (var i = 0; i < checkboxes.length; i++) {
                    if (checkboxes[i].type == 'checkbox') {
                        checkboxes[i].checked = true;
                    }
                }
            } else {
                for (var i = 0; i < checkboxes.length; i++) {
                    //console.log(i)
                    if (checkboxes[i].type == 'checkbox') {
                        checkboxes[i].checked = false;
                    }
                }
            }
        }
        function GetMonthName(monthNumber) {
            var months = ['01', '02', '03', '04', '05', '06',
            '07', '08', '09', '10', '11', '12'];
            return months[monthNumber - 1];
        }

        function showBranches() {

            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/showBranches",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#comboWareHouseInReport").html(msg.d);
                        showBrands();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function showBrands() {
            loading();
            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/showBrands",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#comboBrandtype").html(msg.d);

                        showcategory();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function showcategory() {
            loading();
            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/showCategoryTypes",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#combocategory").html(msg.d);

                        loadsubcategory();
                        // $("#combocategory").val(val);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function loadsubcategory() {
            categoryVal = $("#combocategory").val();
            loading();
            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/showSubCategoryTypes",
                data: "{'categoryVal':'" + categoryVal + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#combosubcategory").html(msg.d);
                        resetCommissionPage();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }
        function showCommissionpage(page) {
            var query = '';
            $('#chkbxId').attr('checked', false);
            sqlInjection();
            var commissionfilters = {};

            if ($("#searchvalContent1").val() !== undefined && $("#searchvalContent1").val() != "") {
                commissionfilters.itm_code = $("#searchvalContent1").val();
            }

            if ($("#searchvalContent2").val() !== undefined && $("#searchvalContent2").val() != "") {
                commissionfilters.itm_name = $("#searchvalContent2").val();
            }

            if ($("#searchvalContent4").val() !== undefined && $("#searchvalContent4").val() != "") {
                commissionfilters.itm_class_two = $("#searchvalContent4").val();
            }
            if ($("#searchvalContent5").val() !== undefined && $("#searchvalContent5").val() != "") {
                commissionfilters.itm_class_three = $("#searchvalContent5").val();
            }

            if ($("#searchvalContent6").val() !== undefined && $("#searchvalContent6").val() != "") {
                commissionfilters.itm_commision = $("#searchvalContent6").val();
            }

            if ($("#searchvalContent7").val() !== undefined && $("#searchvalContent7").val() != "") {
                commissionfilters.itm_class_one = $("#searchvalContent7").val();
            }

            if ($("#comboWareHouseInReport").val() !== undefined && $("#comboWareHouseInReport").val() != "0") {
                commissionfilters.warehouseid = $("#comboWareHouseInReport").val();
            }

            if ($("#comboBrandtype").val() !== undefined && $("#comboBrandtype").val() != "-1") {
                commissionfilters.brandid = $("#comboBrandtype").val();
            }
          //  alert($("#combocategory").val());
            if ($("#combocategory").val() !== undefined && $("#combocategory").val() != "-1") {
                commissionfilters.categoryid = $("#combocategory").val();
            }

            if ($("#combosubcategory").val() !== undefined && $("#combosubcategory").val() != "-1") {
                commissionfilters.subcategoryid = $("#combosubcategory").val();
            }

            var perpage = $("#txtpageno").val();
            loading();
            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/searchSalescommission",
                data: "{'page':" + page + ",'commissionfilters':" + JSON.stringify(commissionfilters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);

                    if (msg.d == "N") {
                        Unloading();
                        $("#tablecommission tbody").html('<td colspan="7"><div style="width:100%;text-align:center;font-weight:bold; padding:5px;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatediv").html('');
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        var htm = "";
                        $("#lblTotalrerd").text(obj.count);
                        //htm += '<tr style="font-size:12px;">';
                        //htm += '<td colspan="7" style="padding:5px; text-align:center; overflow:hidden; border-right:none;">';
                        ////htm += '<div><span style="margin-left:0px;float:right;text-align:right;font-size:14px;">Total Records:' + obj.count + '</span></div>';
                        //htm += '</td> </tr>';
                        $.each(obj.data, function (i, row) {
                            console.log(row);
                            htm += "<tr style='cursor:pointer; font-size:12px;' id='itemRow" + i + "'>";
                            //<input type='checkbox' id='chkbxPageId" + i + "'/>
                            htm += "<td style='padding:2px;'><div style='padding:2px; margin-left:10px;'><div class='checkbox'><label style='font-size: 1em'><input type='checkbox' value='' id='chkbxPageId" + i + "' /><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnitbsId" + i + "' value='" + row.itbs_id + "'/></div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_code + "</div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_name + "</div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_class_one + "</div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_class_two + "</div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_class_three + "</div></td>";
                            htm += "<td style='padding:2px;'><div style='padding:2px;'>" + row.itm_commision + "</div></td>";
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="7">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        Unloading();
                        $("#tablecommission tbody").html(htm);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "showCommissionpage"));
                    }
                    
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }
        function updateCommission() {
            var commission = $("#commission").val();
            if (commission == "") {
                alert("Please enter commission");
                return;
            }
            if (isNaN($("#commission").val())) {
                alert("Commission should be in number only");
                $("#commission").focus();
                return;
            }
            var rowCount = $("#tablecommission tr").length;
            var rowValue = rowCount - 2;
            var resultString = "";
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one item to be updated!!!');
                return false;
            }
            for (var i = 0; i < rowValue; i++) {
                if ($("#chkbxPageId" + i).is(':checked')) {
                    resultString = resultString + $("#hdnitbsId" + i).val() + "@#$";
                }
            }
            loading();
            $.ajax({
                type: "POST",
                url: "sales_commission.aspx/updateCommission",
                data: "{'commission':'" + commission + "','resultString':'" + resultString + "','rowValue':'" + rowValue + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    Unloading();
                    // return;
                    if (msg.d == "Y") {
                       alert("Commission Updated Successfully");
                        $("#commission").val('');
                        for (var i = 0; i < rowValue; i++) {
                            $("#chkbxPageId" + i).attr('checked', false);
                        }
                        showCommissionpage(1);
                        $('#chkbxId').attr('checked', false);
                        return;
                    }
                    else {
                        alert("Updation Failed");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    //alert("fail" + status + ":::" + xhr.d);
                    alert("Internet Problem..!");
                }
            });
        }
        function resetCommissionPage() {
            for (var i = 1; i <= 7; i++) {

                $("#searchvalContent" + i).val('');
            }
            $("#comboBrandtype").val('-1');
            $("#combocategory").val('-1');
            $("#combosubcategory").val('-1');
            $("#comboWareHouseInReport").val('0');
            showCommissionpage(1);

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
                            <%--<img src="../images/img.jpg" alt="..." class="img-circle profile_img"/>--%>
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

                        <div class="navbar-header" style="width:100%; display:flex; align-items:center">
                            <div class="nav toggle" style="padding:5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <label style="font-weight: bold; font-size: 16px;">Sales Commission</label>
                            
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
                            <label style="font-size: 18px; font-weight: normal;">Sales Commission</label>
                        </div>
                    </div>--%>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="padding-left:5px;padding-right:5px;">
                                     <label>Sales Commission</label>
                                    <!--<h2>Sales Commission</h2>-->
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <li><a class="close-link"><%--<i class="fa fa-close"></i>--%></a>
                                        </li>
                                    </ul>
                                 
                                </div>
                                <div class="x_content" style="padding-bottom:0px; padding-left:0px; padding-right:0px;">

                                    <form class="form-horizontal form-label-left input_mask">



                                        <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="showBranchesDiv">
                                            <select class="form-control" style="text-indent: 25px;" id="comboWareHouseInReport" onchange="javascript:showCommissionpage(1);">
                                                <option value='0' selected>--All Warehouse--</option>
                                            </select>
                                            <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                        </div>

                                        <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="showbranddiv">
                                            <select class="form-control" style="text-indent: 25px;" id="comboBrandtype" onchange="javascript:showCommissionpage(1);">
                                                <option value='0'>--Brand--</option>
                                            </select>
                                            <span class="fa fa-clipboard form-control-feedback left" aria-hidden="true"></span>
                                        </div>

                                        <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="showcategorydiv">
                                            <select class="form-control" style="text-indent: 25px;" id="combocategory" onchange="javascript:showCommissionpage(1);">
                                                <option value='0'>--Category--</option>
                                            </select>
                                            <span class="fa fa-clone form-control-feedback left" aria-hidden="true"></span>
                                        </div>

                                        <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback" id="showsubcategorydiv">
                                            <select class="form-control" style="text-indent: 25px;" id="combosubcategory" onchange="javascript:showCommissionpage(1);">
                                                <option value='0'>--Sub Category--</option>
                                            </select>
                                            <span class="fa fa-sticky-note-o form-control-feedback left" aria-hidden="true"></span>
                                        </div> 

                                    </form>
                                

                                    <div class="clear" style="height:5px;"></div>

                                <div class="col-md-1 col-sm-6 col-xs-4" style="padding-left:0px; padding-right:0px;">
                                    <div class="dataTables_length">
                                        <label>
                                            <select id="txtpageno" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class="input-sm" onchange="javascript:showCommissionpage(1);" style="margin-left:5px;">
                                                <option value="100">100</option>
                                                <option value="500">500</option>
                                            </select>
                                        </label>
                                    </div>
                                </div>

                                <div class="col-md-3 col-sm-9 col-xs-8" style="padding-left:0px;padding-right:0px;">


                                    <div onclick="javascript:showCommissionpage(1);" class="btn btn-success mybtnstyl">
                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                        Search
                                    </div>
                                    <div onclick="javascript:resetCommissionPage();" class="btn btn-primary mybtnstyl">
                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                        Reset
                                    </div>
                                </div>


                                <div class="col-md-5 col-sm-6 col-xs-12 pull-right" style="">

                                    <div class="col-md-10 col-sm-6 col-xs-9 form-group has-feedback  " style="float: left; padding-left:0px; padding-right:0px;" id="commissions" >
                                        <div>
                                        <input type="number" class="form-control has-feedback-left" style="padding-right:0px;" id="commission" placeholder="Commission(%)" />
                                        <%--<span class="fa fa-map-marker form-control-feedback left" aria-hidden="true" style="left:1px;"></span>--%>
                                            </div>
                                    </div>
                                    <div class="col-md-2 col-sm-6 col-xs-3" style="float: left">
                                        <div onclick="javascript:updateCommission();" class="btn btn-success mybtnstyl">
                                            Update
                                        </div>
                                    </div>
                                </div>
                                    </div>
                                <div class="clear"></div>
                                <div class="ln_solid" style="margin-top:5px;"></div>

                                <div id="ReportsContentDiv" class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="tablecommission" class="table table-striped table-bordered bulk_action" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <%--<th><input type="checkbox" id="check-all" class="flat"></th>--%>

                                                    <th>Select</th>
                                                    <th>Item Code</th>
                                                    <th style="width: 400px;">Item Name<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></th>
                                                    <th>Class A</th>
                                                    <th>Class B</th>
                                                    <th>Class C</th>
                                                    <th>Commission(%)</th>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <%--<input type='checkbox' id='chkbxId' onchange="checkAll(this)" name="chk[]"/>--%>
                                                        <div class="checkbox">
            <label style="font-size: 1em">
                <input type="checkbox" value="" id="chkbxId" onchange="checkAll(this)" name="chk[]" />
                <span class="cr"><i class="cr-icon fa fa-check"></i></span>              
            </label>
        </div>
                                                        All</td>
                                                    <td>
                                                        <input type="text" id="searchvalContent1" class="form-control" placeholder="Item code"/></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent2" class="form-control" style="width: 450px;"  placeholder="Item name"/></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent7" style="padding:0px; text-indent:3px;" class="form-control" placeholder="Class A"/></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent4" style="padding:0px; text-indent:3px;" class="form-control"  placeholder="Class B"/></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent5" style="padding:0px; text-indent:3px;" class="form-control"  placeholder="Class C"/></td>
                                                    <td>
                                                        <input type="text" id="searchvalContent6" style="padding:0px; text-indent:3px;" class="form-control" placeholder="Commission" /></td>
                                                    <div id="searchposContent3"></div>
                                                    <%-- style="width: 96%; display: " --%>
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
    <%--    <script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- iCheck -->
    <script src="../js/bootstrap/icheck.min.js"></script>
    <!-- Select2 -->
    <script src="../js/bootstrap/select2.full.min.js"></script>
    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
