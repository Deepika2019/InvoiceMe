<%@ Page Language="C#" AutoEventWireup="true" CodeFile="itemmaster.aspx.cs" Inherits="inventory_itemmaster" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Item Master  | Invoice Me</title>

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
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!-- mystyle Style -->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" />
     <%-- autosearch --%>
    <script src="../autosearch/jquery-ui.js" type="text/javascript"></script>
    <link href="../autosearch/jquery-ui.css" rel="Stylesheet" type="text/css" />
    <script src="../autosearch/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../autosearch/jquery-1.12.4.js" type="text/css"></script>
    <%-- autosearch --%>
    <script type="text/javascript">
        var brandval = '';
        var pricegrupsNo = "";
        var pricegruparray = [];
        var itemid = "";
        var couponItemId = 0;
        $(document).ready(function () {

            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            //if (!BranchId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            //if (!CountryId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            // showProfileHeader(1);
            //  loadpricegroups();
            SearchAutoItems();
            clearform();
            showBrands();
            //showsupplierlist();
            showsearchbrands();
            loadcategory();
            loadsearchcategory();
            searchitemlist(1);
           
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



        //function for showing brand
        function showBrands() {
            //  var loggedInBranch = $.cookie("staffBranchId");
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/showBrands",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#comboBrandtype").html(msg.d);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }


        //function for load suppliers
        function showsupplierlist() {
            //  var loggedInBranch = $.cookie("staffBranchId");
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/showsupplierlist",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#showSupplierdiv").html(msg.d);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function for load subcategory
        function loadcategory() {
            //  brandval = $("#comboBrandtype").val();
            //  alert(brandVal);
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/showCategoryTypes",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#combocategory").html(msg.d);
                        // $("#combocategory").val(val);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function for add item
        function addItemDetails(actionType, itemid) {
            sqlInjection();
            var itmcode = $("#txtitemcode").val();
            var itmname = $("#txtitemname").val();
            var itmdescrptn = $("#txtitemdescrptn").val();
            var itmbrand = $("#comboBrandtype").val();
            var itmcatgry = $("#combocategory").val();
            var itmsubcategory = $("#comboselectsubcategory").val();
            var itemType = $("#comboItemtype").val();
            var couponItemQty=$("#txtitemqty").val();
            if (itemType == -1) {
                alert("Please select item type");
                return;
            } else if (itemType == 3) {
                if ($("#txtAutoitemName").val() == "") {
                    alert("Please add an item");
                    return;
                }
                if (couponItemQty == "" || couponItemQty == 0) {
                    alert("Please enter quantity");
                    return;
                }
                if (isNaN($("#txtitemqty").val())) {
                    alert("Quantity should be in number only");
                    $("#txtitemqty").focus();
                    return;
                }
            }
            if (couponItemQty == "") {
                couponItemQty = 0;
            }
            var supplier = 0;
            itmname = itmname.trim();

            if (itmcode == "") {
                alert("Please enter item code");
                return;
            }
            if (itmname == "") {
                alert("Please enter item name");
                return;
            }
            if (itmbrand == "" || itmbrand == -1) {
                alert("Please choose Brand");
                return;
            }

            if (itmcatgry == "" || itmcatgry == -1) {
                alert("Please choose Category type");
                return;
            }

            //if (supplier == "" || supplier == 0) {
            //    alert("Please Select the Supplier..");
            //    return;
            //}


            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/Additemmasters",
                data: "{'actionType':'" + actionType + "','itemid':'" + itemid + "','itemcode':'" + itmcode + "','itemname':'" + itmname + "','itemdesc':'" + itmdescrptn + "','itmbrand':'" + itmbrand + "','itmcatgry':'" + itmcatgry + "','itmsubcategory':'" + itmsubcategory + "','supplier':'" + supplier + "','itemType':'" + itemType + "','couponItemId':'" + couponItemId + "','quantity':'" + couponItemQty + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    Unloading();
                    //alert(msg.d);
                    if (msg.d == "E") {
                        alert("Item code or Item Name already exist");
                    }
                    if (msg.d == "Y") {
                        // alert("Group Added Successfully");
                        if (actionType == "insert") {
                            alert("Item Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("Item Updated Successfully");
                        }
                        clearform();
                        searchitemlist(1);
                        return;


                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //search
        function searchitemlist(page) {
            //alert(page);
            sqlInjection();
            var filters = {};

            if ($("#txtSearchItem").val() !== undefined && $("#txtSearchItem").val() != "") {
                filters.search = $("#txtSearchItem").val();
            }

            

            //var brandid = $("#combobranddiv").val();
            //  alert($("#combobranddiv").val());
            if ($("#combobranddiv").val() !== undefined && $("#combobranddiv").val() != "-1") {
                filters.brandid = $("#combobranddiv").val();
            }

            // var categoryid = $("#combosearchcategory").val();
            if ($("#combosearchcategory").val() !== undefined && $("#combosearchcategory").val() != "-1") {
                filters.categoryid = $("#combosearchcategory").val();
            }
            if ($("#combosearchType").val() !== undefined && $("#combosearchType").val() != "-1") {
                filters.itemType = $("#combosearchType").val();
            }

            var perpage = $("#txtpageno").val();
            // alert(perpage);
            console.log(filters);
            // alert("");
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/searchItemList",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                
                    if (msg.d == "N") {

                        //$("#divSearchItems table").html('<td colspan="6"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#divSearchItems1 tbody").html('<td colspan="4" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatediv").html('');
                        $("#lblTotalrerd").text(0);
                        // alert("No Search Results");
                    }
                    else {
                        var obj = JSON.parse(msg.d)
                        //  console.log(obj);

                        var htm = "";
                        $("#lblTotalrerd").text(obj.count);
                        $.each(obj.data, function (i, row) {
                            console.log(row);
                            htm += "<tr style='cursor:pointer; font-size:12px;' id='itemRow" + i + "' onclick='javascript:editItemDetails(" + row.itm_id + ");'>";
                            htm += "<td>" + getHighlightedValue(filters.search, row.itm_code.toString()) + "</td>";
                            htm += "<td>" + getHighlightedValue(filters.search, row.itm_name.toString()) + "</td>";
                            htm += "<td>" + row.brand_name + "/" + row.cat_name + "</td>";
                            htm += '<td><div class="btn btn-primary btn-xs" onclick="javascript:editItemDetails(' + row.itm_id + ');">';
                            htm += '<li class="fa fa-eye" style="font-size:large;"></li>';
                            htm += '</div></td>';
                            
                            htm += "</tr>";
                        });
                        htm += '<tr>';
                        htm += '<td colspan="5">';
                        htm += '<div id="paginatediv" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';
                        // $("#divSearchItems table").html(htm);
                        // alert(htm);
                        $("#divSearchItems1 tbody").html(htm);
                        $("#paginatediv").html(paginate(obj.count, perpage, page, "searchitemlist"));
                    }
                    Unloading();
                },
                error: function (xhr, status) {
                    Unloading();
                    //console.log("error--" + status);
                    //console.log(xhr);
                    alert("Internet Problem");
                }
            });
        }

        //function for reset
        function resetitem() {
            $("#txtSearchItem").val('');
            $("#combobranddiv").val(-1);
            $("#combosearchcategory").val(-1);
            $("#combosearchType").val(-1);
            searchitemlist(1);
        }

        //function for clearform
        function clearform() {
            $("#btnservMasterAction").html("<div class='btn btn-success fl mybtnstyl' onclick='javascript:addItemDetails(\"insert\");'>SAVE</div>");
            //$("#btnservMasterAction").html("<div class='buttons fl' onclick=javascript:addItemDetails('insert');> <div class='logintext'>SAVE</div></div>");
            //  $("#btnUserDetailsAction").html("<div style='margin-right: 15px; margin-top:20px; cursor: pointer; color: rgb(255, 255, 255); font-weight: bold; border-radius: 3px 3px 3px 3px;' class='groupbtn fl' onclick=javascript:addGroupDetails('insert'); ><div class='groupbtntext'>SAVE</div></div>");
            $("#txtitemcode").val('');
            $("#comboBrandtype").val(-1);
            $("#combocategory").val(-1);
            $("#combovendorlist").val(0);
            $("#txtitemname").val('');
            $("#txtitemdescrptn").val('');
            $("#txtitemSP").html('');
            $("#comboselectsubcategory").val(-1);
            for (var i = 1; i <= 5; i++) {
                $("#searchvalContent" + i).val('');
            }
            $("#comboItemtype").val(-1);
            $("#txtAutoitemName").val("");
            $("#txtitemqty").val("");
            showDivCoupon();
            //  $("#pricegroupsdiv").hide();

        }

        //function for view item details
        function editItemDetails(id) {
            // alert(id);

            itemid = id;
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/editItemDetails",
                data: "{'itmid':'" + id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);

                    $("#btnservMasterAction").html("<div class='btn btn-success mybtnstyl' onclick='javascript:addItemDetails(\"update\"," + obj[0].itm_id + ");'>UPDATE</div>");
                    $("#txtitemcode").val(obj[0].itm_code);
                    $("#txtitemname").val(obj[0].itm_name);
                    //  $("#txtLocation").val(splitarray[2]);
                    $("#txtitemdescrptn").val(obj[0].itm_description);
                    $("#comboBrandtype").val(obj[0].itm_brand_id);
                    $("#combocategory").val(obj[0].itm_category_id);
                    $("#combovendorlist").val(obj[0].itm_supplierid);
                    $("#comboItemtype").val(obj[0].itm_type);
                    if (obj[0].itm_type == 3) {
                        showDivCoupon();
                        $("#txtAutoitemName").val(obj[0].copnItem);
                        $("#txtitemqty").val(obj[0].quantity);
                        couponItemId = obj[0].couponItemId;
                    }
                    loadsubcategory(obj[0].itm_subcategory_id);

                        $('html,body').animate({
                            scrollTop: $('#Divitemdetails').offset().top
                        }, 500);

                        //    $("#comboselectsubcategory").val(splitarray[7]);

                        return;
                    

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        //function for show brands
        function showsearchbrands() {
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/showsearchbrands",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#combobranddiv").html(msg.d);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function for load search subcategory
        function loadsearchcategory() {
            // brandval = $("#combobranddiv").val();
            //  alert(brandVal);
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/loadsearchcategory",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#combosearchcategory").html(msg.d);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //function for load subcategory
        function loadsubcategory(val) {
            // alert(val);
            categoryVal = $("#combocategory").val();
            //  alert(brandVal);
            loading();
            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/showSubCategoryTypes",
                data: "{'categoryVal':'" + categoryVal + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //alert(msg.d);
                    if (msg.d == "") {
                        alert("Error..!");
                        return;
                    }
                    else {
                        $("#comboselectsubcategory").html(msg.d);
                        if (val == 0) {
                            val = -1;
                        }
                        $("#comboselectsubcategory").val(val);
                        //if (group_id !== undefined) {
                        //    // alert("");
                        //    editGroupDetails(group_id);
                        //}
                        //  searchGroupClass(1);
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function addNewBrand() {
            window.open('../inventory/itembrand.aspx', '_blank');
        }
        function addNewCategory() {
            window.open('../inventory/itemcategory.aspx', '_blank');
        }
        function showDivCoupon() {
            if ($("#comboItemtype").val() == 3) {
                $("#divCoupon").show();
            } else {
                $("#divCoupon").hide();
            }
        }

        //normal items search
        function searchItems() {
            //  alert("");
            //   showsearchItems();
            for (var i = 1; i <= 2; i++) {
                $("#searchposContent" + i).val('');
            }
           // $("#combosearchitemtype").val(0);
            searchOrderitem(1);
        }

        function searchOrderitem(page) {
            var filters = {};
       
            if ($("#searchposContent2").val() !== undefined && $("#searchposContent2").val() != "") {
                filters.itemname = $("#searchposContent2").val();
            }

            //  alert(itemcode);
            if ($("#searchposContent1").val() !== undefined && $("#searchposContent1").val() != "") {
                filters.itemcode = $("#searchposContent1").val();
            }
           // filters.item_type = $("#comboItemtype").val();
            var perpage = $("#txtpospageno").val();
            console.log(JSON.stringify(filters));
            //    alert("{ 'page': " + page + ", 'searchResult1': '" + searchResult + "', 'perpage': '" + perpage + "', 'customertype': '" + customertype + "' }");
            // alert(searchResult);
            loading();

            $.ajax({
                type: "POST",
                url: "itemmaster.aspx/searchOrderitem",
                data: "{'page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':" + perpage + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    // alert(msg.d);
                    if (msg.d == "N") {
                        $("#lblItemTotalrecords").text(0);
                        $('#tablePos tbody').html('<td colspan="6" style="background:#ebebeb; padding:5px;font-weight:bold;"><div style="width:100%;text-align:center"><div style="display:inline-block">Nothing Found...</div></div></td>');
                        $("#paginatedivone").html("");
                        $("#popupItems").modal('show');
                        return;
                    }
                    else {
                        var obj = JSON.parse(msg.d);
                        console.log(obj.data);
                        $("#lblItemTotalrecords").text(obj.count);
                        var htm = "";
                        //   htm += "<tr class='overeffect' style='font-size:12px;'><td style='padding:5px; text-align:center; overflow:hidden; border-right:none;' colspan='7' class='nonheadtext'><div><span style='margin-left:0px;float:right;margin-top:4px;text-align:right;font-size:14px;color:#660000;'>Total Records: " + obj.count + "</span></div></td> </tr>";
                        $.each(obj.data, function (i, row) {
                            console.log(row);
                         
                            htm += "<tr ";
                            htm += " onclick=javascript:selectCouponItem('" + row.itm_name.replace(/\s/g, '&nbsp;') + "','" + row.itm_id + "'); style='cursor:pointer;'><td>" + getHighlightedValue(filters.itemcode, row.itm_code.toString()) + "</td><td>" + getHighlightedValue(filters.itemname, row.itm_name.toString()) + "</td>";
                         
                            //alert(htm);
                            // $('#tablepos > tbody > tr:gt(' + (i + 2) + ')').remove();
                        });
                        htm += '<tr>';
                        htm += '<td colspan="6">';
                        htm += '<div  id="paginatedivone" style="text-align: center;">';
                        htm += '</div>';
                        htm += '</td>';
                        htm += '</tr>';

                        //   alert(htm);
                        $('#tablePos tbody').html(htm);
                        $("#popupItems").modal('show');
                        $("#paginatedivone").html(paginate(obj.count, perpage, page, "searchOrderitem"));


                        return;
                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    console.log(xhr);
                    console.log(status);
                    var msgObj = JSON.parse(xhr.responseJSON.d);
                    alert(msgObj.message);
                }
            });

        }

        //normal items search

        //popupclose
        function popupclose(divid) {
            $("#" + divid).modal('hide');
        }

        //autosearch for select an item for coupon 
        function SearchAutoItems() {
            $("#txtAutoitemName").keyup(function () {
                //alert("ch");
                if ($("#txtAutoitemName").val().trim() === "") {
                    $("#searchTitle").hide();
                }
            });

            $("#txtAutoitemName").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "itemmaster.aspx/GetAutoCompleteItemData",
                        data: "{'variable':'" + $("#txtAutoitemName").val() + "'}",
                        dataType: "json",
                        success: function (data) {
                            //var objJson = jQuery.parseJSON(data.d);
                            //alert(objJson);                             
                            //response(objJson);

                            //var obj = [{ label: 'Avacado Supermarket', value: '2' }];
                            //alert(data.d);
                            var data1 = jQuery.parseJSON(data.d);
                            console.log(data1);
                            response(data1.slice(0, 20));
                        }
                    });
                },
                select: function (event, ui) {
                    //alert(123);
                    // Prevent value from being put in the input:
                    $("#txtAutoitemName").val(ui.item.label); //ui.item is your object from the array
                    selectCouponItem(ui.item.label, ui.item.id);
                    //console.log(ui.item.value);
                 //   searchCustomers(ui.item.id);
                    event.preventDefault();
                },
                minLength: 1

            });



        }
        //autosearch for select an item for coupon 

        function selectCouponItem(name, id) {
            $("#txtAutoitemName").val(name);
            couponItemId = id;
            popupclose('popupItems');
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
                            <div class="col-md-6 col-xs-5">
                            <label style="font-weight: bold; font-size: 16px;">Item Master</label>
                            </div>
                            <div class="col-md-6 col-xs-5"><div onclick="javascript:clearform();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612; margin-top:5px"><label style="color: #fff; margin-right: 5px; font-size: 14px;" class="fa fa-plus-square"></label>New</div></div>
                        </div>

                    </nav>
                </div>
            </div>
            <!-- /top navigation -->

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <%--<div class="page-title">
			
              <div class="title_left" style="width:100%;">
                <label style="font-size:18px; font-weight:normal;">Item Master</label>
              </div>

              
            </div>
                    --%>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12" id="Divitemdetails">
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
                                         <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Item Type<span class="required">*</span>
                                            </label>
                                              <div class="col-md-6 col-sm-6 col-xs-12">
                                                <select class="form-control" id="comboItemtype" onchange="showDivCoupon()">
                                                    <option value="-1">--Type--</option>
                                                    <option value="1">Product</option>
                                                    <option value="2">Service</option>
                                                    <option value="3">Package</option>
                                                    
                                                </select>
                                            </div>
                                        </div>
                                        <div id="divCoupon" style="display:none;">
                                            <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Choose Item<span class="required">*</span>
                                            </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                  <input type="text" id="txtAutoitemName" placeholder="Search Item" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>

                                                <div class="col-md-2 col-sm-6 col-xs-4" onclick="javascript:searchItems();" style="padding-right:0px;">
                                                <div class="" style="font-size: 28px;" data-toggle="modal" title="Add Item">
                                                    <label class="fa fa-shopping-cart" style="color: #ff6a00; cursor: pointer;"></label>
                                                    <label class="fa fa-plus-circle" style="font-size: 20px; cursor: pointer; position: relative; margin-left: -12px;"></label>
                                                </div>

                                            </div>

                                        </div>
                                           <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Redeem Count<span class="required">*</span>
                                            </label>
                                              <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtitemqty" placeholder="Enter Count" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>

                                             <%-- pop up for show normal items --%>
                                            <div class="container">


                                                <div class="modal fade" id="popupItems" role="dialog">
                                                    <div class="modal-dialog modal-lg" style="">

                                                        <!-- Modal content-->
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <button type="button" class="close" onclick="javascript:popupclose('popupItems');">&times;</button>
                                                                <div class="col-md-7 col-sm-6 col-xs-6">
                                                                    <h4 class="modal-title">Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblItemTotalrecords">0</span></h4>
                                                                </div>
                                                                <div class="col-md-4 col-sm-4 col-xs-12">                                                 
                                                                   
                                                                    <div class="col-md-10 col-sm-12 col-xs-12">
                                                                        
                                                                        <div class="" onclick="javascript:searchItems();" style="float:right;">
                                                                            <button class="btn btn-primary mybtnstyl" type="reset">
                                                                                <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                                                Reset
                                                                            </button>
                                                                        </div>
                                                                        <div class="" onclick="javascript:searchOrderitem(1);">
                                                                            <button type="button" class="btn btn-success mybtnstyl" style="float:right;">
                                                                                <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                                                Search
                                                                            </button>
                                                                        </div>
                                                                        </div>
                                                                         <div class="col-md-2 col-sm-12 col-xs-3">
                                                                            <select id="txtpospageno" onchange="javascript:searchOrderitem(1);"  name="datatable-checkbox_length" aria-controls="datatable-checkbox" class=" input-sm">
                                                                               <option value="25">25</option>
                                                                                 <option value="50">50</option>
                                                                                <option value="100">100</option>
                                                                                <option value="250">250</option>
                                                                                <option value="500">500</option>
                                                                            </select>
                                                                        </div>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                                <div class="x_content">

                                                                    <table id="tablePos" class="table table-striped table-bordered" style="table-layout: auto;">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>Code</th>
                                                                                <th>Name</th>
                                                                           

                                                                            </tr>


                                                                            <tr>
                                                                                <td>
                                                                                    <input type="text" class="form-control" id="searchposContent1" style="width: 80px; padding-right: 2px;" /></td>
                                                                                <td>
                                                                                    <input type="text" id="searchposContent2" class="form-control" /></td>
                                                                                

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

                                            </div>

                                            <%-- pop up for show offer items --%>
                                        </div>
                                           
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Item Code<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtitemcode" placeholder="Enter Item Code" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                Item Name<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <input type="text" id="txtitemname" placeholder="Enter Item Name" name="last-name" required="required" class="form-control col-md-7 col-xs-12">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Description	 
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <textarea id="txtitemdescrptn" class="form-control" rows="3" placeholder="Enter Description" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Brand<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12" id="showBrandDiv">
                                                <select class="form-control" id="comboBrandtype">
                                                    <option value="0">--Select Brand--</option>
                                                </select>
                                            </div>
                                            <div class="" style="font-size: 20px;" onclick="javascript:addNewBrand();" title="Add New Brand">
                                                <label class="fa fa-plus-square" style="color: #ff6a00; cursor: pointer;"></label>
                                            </div>

                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Category<span class="required">*</span>
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12" id="showcategorydiv">
                                                <select class="form-control" id="combocategory">
                                                    <option value="0">--Select Category--</option>
                                                </select>
                                            </div>
                                            <div class="" style="font-size: 20px;" onclick="javascript:addNewCategory();" title="Add New Category">
                                                <label class="fa fa-plus-square" style="color: #ff6a00; cursor: pointer;"></label>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                Sub Category
                                            </label>
                                            <div class="col-md-6 col-sm-6 col-xs-12">
                                                <select class="form-control" id="comboselectsubcategory">
                                                    <option value="-1">--Subcategory--</option>
                                                </select>
                                            </div>
                                        </div>
                                    </form>

                                    <div class="clearfix"></div>
                                    <div class="ln_solid"></div>
                                    <div class="form-group" style="padding-bottom: 40px;">
                                        <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-5">
                                            
                                            <div id="btnservMasterAction">
                                                <div class="btn btn-success mybtnstyl" onclick="javascript:addItemDetails('insert',0);">SAVE</div>
                                            </div>

                                            <div onclick="javascript:clearform();" class="btn btn-danger mybtnstyl">CANCEL</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="clearfix"></div>
                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">
                            <div class="x_panel">
                                <div class="x_title" style="margin-bottom: 5px;">
                                    <label>Items<span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lblTotalrerd">0</span></label>
                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>

                                        <%--                      <li><a class="close-link"><i class="fa fa-close"></i></a>
                      </li>--%>
                                    </ul>
                                </div>

                                <div class="x_content" style="padding-bottom: 0px;">

                                    <form class="form-horizontal form-label-left input_mask">

                                        <div class="col-md-12 col-sm-6 col-xs-12 form-group has-feedback">
                                            <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="combobranddiv" onchange="searchitemlist(1)">
                                                    <option value="-1">--Brand--</option>
                                                    <%--                            <option>Abu Dhabi</option>
                            <option>Ajman</option>--%>
                                                </select>
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-3 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="combosearchcategory" onchange="javascript:searchitemlist(1);">
                                                    <option value="-1">--Category--</option>
                                                    <%--                            <option>No Outstanding</option>
                            <option>Have Outstanding</option>--%>
                                                </select>
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                              <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select class="form-control" style="text-indent: 25px;" id="combosearchType" onchange="javascript:searchitemlist(1);">
                                                       <option value="-1">--Type--</option>
                                                    <option value="1">Product</option>
                                                    <option value="3">Package</option>
                                                    <option value="2">Service</option>
                                                </select>
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>

                                                <div class="col-md-3 col-sm-6 col-xs-8" style="padding-right:0px;">
                                            <div class="input-group">
                                               
                                                <input type="text" class="form-control" id="txtSearchItem" placeholder="Item code/Name" style="height: 30px; padding-right: 2px;">
                                               
                                                <span class="input-group-btn" title="search">
                                                    
                                                    <button type="button" class="btn btn-default" onclick="searchitemlist(1)" style="padding:4px 12px;">
                                                        <i class="fa fa-search" title="search"></i>
                                                    </button>
                                                </span>
                                              
                                            </div>                                      
                                        </div>
                                        <div class="col-md-1" style="padding-left:17px;" onclick="resetitem()">  <a class="btn btn-primary btn-xs" style="text-align:center;background:#337ab7; border-color:#2e6da4;"><li class="fa fa-refresh" style="padding:3px; font-size:17px;color:white;margin-top:0px;" onclick="" title="Reset"></li></a></div>
                                        <ul class="nav navbar-right panel_toolbox">
                
                                            <li>

                                                <select class="input-sm" id="txtpageno" onchange="javascript:searchitemlist(1);">
                                                    <option value="25">25</option>
                                                    <option value="50">50</option>
                                                    <option value="100">100</option>
                                                      <option value="500">500</option>
                                                </select>



                                            </li>
                                         
                                            
                                        </ul>

                                        </div>
                                        <%--<div class="col-md-3 col-sm-6 col-xs-12">

                                            <div class="col-md-3 col-sm-6 col-xs-3" style="padding-right: 0px;">
                                                <div class="" id="datatable-checkbox_length">
                                                    <label>
                                                        
                                                        <select id="txtpageno" onchange="javascript:searchitemlist(1);" style="height: 30px;" class="pull-right">
                                                            <option value="20">20</option>
                                                            <option value="50">50</option>
                                                            <option value="100">100</option>
                                                            <option value="500">500</option>
                                                        </select>
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="col-md-9 col-sm-6 col-xs-9" style="padding-left: 0px;">
                                                <div class="btn btn-primary pull-right mybtnstyl" onclick="javascript:resetitem();" type="reset">
                                                    <li class="fa fa-refresh" style="margin-right: 5px;"></li>
                                                    Reset
                                                </div>
                                                <div type="button" onclick="javascript:searchitemlist(1);" class="btn btn-success pull-right mybtnstyl">
                                                    <li class="fa fa-search" style="margin-right: 5px;"></li>
                                                    Search
                                                </div>
                                            </div>

                                        </div>--%>
                                    </form>
                                </div>

                                <div class="clearfix"></div>
                                <div class="ln_solid" style="margin-top: 0px;"></div>

                                <div id="divSearchItems" class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                    <div class="x_content">

                                        <table id="divSearchItems1" class="table table-striped table-bordered" style="table-layout: auto;">
                                            <thead>
                                                <tr>
                                                    <th>Item Code</th>
                                                    <th>Item Name	</th>
                                                    <th>Brand/Category</th>
                                                    <th>View</th>

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
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
