<%@ Page Language="C#" AutoEventWireup="true" CodeFile="itemcategory.aspx.cs" Inherits="inventory_itemcategory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Item Category  | Invoice Me</title>
    <script type="text/javascript" src="../js/common.js"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>
    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
    <script type="text/javascript" src="../js/pagination.js"></script>



    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />

    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />
    <script type="text/javascript">

        var BranchId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            if (!BranchId) {
                location.href = "../dashboard.aspx";
                return false;
            }


            clearCategoryData();
            loadparentcategory();
            // searchCategory(1);
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
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

        //search category
        function searchCategory(page) {
            //alert("search");
            var CatType = '';
            var CatTypename = '';
            var filters = {};
            if ($("#searchCategory1").val() !== undefined && $("#searchCategory1").val() != "") {
                filters.cat_id = $("#searchCategory1").val();
            }
            if ($("#searchCategory2").val() !== undefined && $("#searchCategory2").val() != "") {
                filters.cat_name = $("#searchCategory2").val();
            }


            var perpage = $("#txtpageno").val();
            // console.log(JSON.stringify(filters));
            loading();
            $.ajax({
                type: "POST",
                url: "itemcategory.aspx/searchCategory",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                   // alert(msg.d);
                    if (msg.d == "N") {

                        $("#divcategorytbl1 tbody").html('<td colspan="4" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        // alert("No Search Results");
                        $("#lblTotalrerd").text(0);

                        $("#paginatediv").html("");
                        Unloading();
                    }
                    else {
                        var obj = JSON.parse(msg.d)
                        //  console.log(obj);
                        Unloading();
                        var count = obj.count;
                        //alert(count);
                        $("#lblTotalrerd").text(count);

                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            CatType = row.parent_id;
                            //alert(CatType);
                            if (CatType == "0") {
                                //alert("typ 0");
                                CatTypename = "Main category";
                            }
                            else {
                                // alert("typ 1");
                                CatTypename = "Sub category";
                            }
                            htm += "<tr style='cursor:pointer; font-size:12px;' class='overeffect' id='vendorRow" + i + "'>";
                            htm += "<td>" + getHighlightedValue(filters.cat_id, row.cat_id.toString()) + "</td>";
                            htm += "<td style='width:300px;'>" + getHighlightedValue(filters.cat_name, row.cat_name) + "</td>";
                            htm += "<td>" + CatTypename + "</td>";
                            htm += "<td><div onclick=javascript:editcategorydetail(" + row.cat_id + "); class='btn btn-primary btn-xs'><li class='fa fa-folder-open'></li> View</div></td>";
                            htm += "</tr>";
                        });

                        htm += '<tr>';
                        htm += '<td colspan="4">';
                        htm += '<div id="divPagination" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        $("#divcategorytbl1 tbody").html(htm);

                        $("#divPagination").html(paginate(obj.count, perpage, page, "searchCategory"));
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });

        }//end search
        //function for reset
        function resetcategory() {
            for (var i = 1; i <= 2; i++) {

                $("#searchCategory" + i).val('');

            }
            searchCategory(1);

        }
        //function for clear form
        function clearCategoryData() {

            //$("#lblTotalrerd").text(0);
            //$("#txtCorporateID").val('');
            $("#txtcategoryName").val('');
            $("#comboParentCategory").val(0);

            //$("#searchCategory1").val('');
            //$("#searchCategory2").val('');


            $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl ' onclick=javascript:AddCategory('insert',0);>Save</div>");

            $("#btnUpdate").hide();

        }//end clear

        function loadparentcategory() {
            // alert("parent loading");
            loading();
            $.ajax({
                type: "POST",
                url: "itemcategory.aspx/loadparentcategory",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var htm = "";
                    if (msg.d == "N" || msg.d=="") {
                        htm += "<select id='comboParentCategory' class='form-control'>";
                        htm += "<option value='0' selected>None</option>";
                        htm += "</select>";
                        //  alert("No Search Results");
                    }
                    else {

                        var obj = JSON.parse(msg.d);

                        htm += "<select  id='comboParentCategory' class='form-control'>";
                        htm += "<option value='0' selected>None</option>";
                        $.each(obj.data, function (i, row) {
                            htm += "<option value='" + row.cat_id + "'>" + row.cat_name + "</option>";
                        })
                        htm += "</select>";

                    }
                    $("#loadparentcategorydiv").html(htm);
                    searchCategory(1);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }
        //end

        //function for edit category details
        function editcategorydetail(categoryid) {
            //alert("edit");
            var parent_id = "";
            loading();
            $.ajax({
                type: "POST",
                url: "itemcategory.aspx/editcategorydetail",
                data: "{'categoryid':'" + categoryid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    //  alert(msg.d);
                    Unloading();
                    //return;
                    if (msg.d != 0) {

                        var splitarray = msg.d.split("@#$");
                        //alert(splitarray);
                        $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick=javascript:AddCategory('update','" + splitarray[0] + "');><div>Update</div></div>");

                        // $("#btnservMasterAction").html("<div class='btn btn-success' onclick=javascript:AddCategory('update','" + splitarray[0] + "'); ><div class='logintext'>UPDATE</div></div>");

                        parent_id = splitarray[2];
                        if (parent_id == "0") {
                            $("#comboParentCategory").val(0);
                        } else {

                            //alert(parent_id);
                            $("#comboParentCategory").val(parent_id);
                        }



                        $("#txtcategoryName").val(splitarray[1]);
                        // 

                        $('html,body').animate({
                            scrollTop: $('#DivCorporateMaster').offset().top
                        }, 500);
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }//end

        //start saving
        function AddCategory(actionType, categoryId) {

            sqlInjection();
            var categoryname = $.trim($("#txtcategoryName").val());

            if (categoryname == "") {
                alert("Please Enter category Name...!");
                return;
            }

            var parentcategoryId = $("#comboParentCategory").val();
            loading();
            $.ajax({
                type: "POST",
                url: "itemcategory.aspx/AddCategory",
                data: "{'actionType':'" + actionType + "','categoryid':'" + categoryId + "','categoryname':'" + categoryname + "','parentcategoryId':'" + parentcategoryId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    Unloading();
                    //alert(msg.d);
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("category Added Successfully");
                            searchCategory(1);
                            clearCategoryData();
                            return;
                        }
                        if (actionType == "update") {
                            alert("category Updated Successfully");
                            searchCategory(1);
                            clearCategoryData();
                            return;
                        }

                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }//end save



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
                            <label style="font-weight: bold; font-size: 16px;">Item Category</label>
                            </div>
                                             <div class="col-md-6 col-xs-5">

                                    <div onclick="javascript:clearCategoryData();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New</div>
                                  
                                </div>
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                  <%--  <div class="page-title">
                        <div class="title_left" style="width: 100%;">
                            <label style="font-weight: bold; font-size: 16px;">Item Category</label>
                        </div>
                    </div>
                    <div class="clearfix"></div>--%>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="DivCorporateMaster">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 0px;">
                                    
                  
                                    <label>Category Details </label>
                        

    
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <%--  <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>                     
                      </li>--%>
                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>

                                </div>
                                <div class="x_content">

                                    <form id="demo-form2" class="form-horizontal form-label-left">

                                        <br />
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Category Name<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtcategoryName" placeholder="Enter Category Name" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Choose Parent Category
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">


                                                <div id="loadparentcategorydiv"></div>




                                                <%-- <select class="form-control" id="comboParentCategory">
                            <option>Choose option</option>
                            <option>Option one</option>
                            <option>Option two</option>
                            <option>Option three</option>
                            <option>Option four</option>
                          </select>--%>
                                            </div>
                                            <div class="clearfix"></div>
                                            <div class="ln_solid"></div>
                                            <div class="form-group">
                                                <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-5">
                                                  

                                                    <div id="btnservMasterAction">
                                                        <div class="btn btn-success mybtnstyl" onclick="javascript:AddCategory('insert',0);" style="display: ;">Save</div>
                                                    </div>

                                                    <%-- <div id="divUpdate" class="btn btn-success" type="button" onclick="javascript:AddCategory('update',0);" style="display:none;">Update</div>--%>



                                                    <div class="btn btn-danger mybtnstyl" onclick="javascript:clearCategoryData();">Cancel</div>
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


                            <%--<div style="text-align:center;" id="divPaginate"></div>--%>


                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 2px;">
                                    <label>Categories<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <%--<li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><i class="fa fa-wrench"></i></a>
                        
                      </li>--%>
                                        <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>
                                </div>
                                <div class="x_content">
                                    <div class="row">


                                       

                                        <div class="form-group" style="float: right; padding-bottom: 5px;">
                                            <div class="col-md-12 col-sm-12 col-xs-12 ">

                                               <%-- <div style="float: left; margin-right: 10px; line-height: 30px;">
                                                    <span><strong>Total Count :
                                                    <label id="lblTotalrerd"></label>
                                                    </strong></span>
                                                </div>--%>
                                                <div style="float: left;">
                                                    <button type="button" class="btn btn-success mybtnstyl" onclick="javascript:searchCategory(1);">
                                                        <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                        Search
                                                    </button>
                                                    <button class="btn btn-primary mybtnstyl" type="button" onclick="javascript:resetcategory();">
                                                        <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                        Reset
                                                    </button>
                                                </div>

                                            </div>
                                        </div>

                                           <div class="form-group" style="float: right;">
                                            <div class="col-md-4 col-sm-3 col-xs-4">
                                                <div class="dataTables_length" id="Div1">
                                                    <label>
                                                        <select id="txtpageno" name="datatable-checkbox_length" aria-controls="datatable-checkbox" class="input-sm" onchange="searchCategory(1);">
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
                                  
                                    <table id="divcategorytbl1" class="table table-striped table-bordered">
                                        <thead>
                                            <tr>
                                                <th>ID</th>

                                                <th>Category Name	</th>
                                                <th>Type</th>
                                                <th></th>

                                            </tr>
                                            <tr>
                                                <td>
                                                    <input id="searchCategory1" placeholder="id" class="form-control" type="text" />
                                                </td>
                                                <td>
                                                    <input id="searchCategory2" placeholder="Name" class="form-control" type="text" />
                                                </td>
                                                <td></td>
                                                <td></td>

                                            </tr>

                                        </thead>


                                        <tbody>


                                        </tbody>
                                    </table>

                                    <div class="row">
                                        <div class="col-md-8 col-sm-12 col-xs-12 text-center">
                                            <div style="text-align: center;" id="divPagination"></div>


                                        </div>
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
    <%-- <script src="../js/bootstrap/jquery.min.js"></script>--%>
    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
