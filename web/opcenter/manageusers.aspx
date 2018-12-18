<%@ Page Language="C#" AutoEventWireup="true" CodeFile="manageusers.aspx.cs" Inherits="opcenter_manageusers" %>

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
        var userid = 0;
        var BranchId;
        $(document).ready(function () {
            BranchId = $.cookie("invntrystaffBranchId");
            userid = getQueryString('userId');
            //  alert(BillNo);
            //  alert(BillNo);
            if (userid == undefined) {
                location.href = "users.aspx";
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
            getBranches();
            loadDistricts();
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
        function showUserDetails(id) {
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/showUserDetails",
                data: "{'userid':'" + id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    $("#txtuserId").text(id);
                    $("#textName").text(obj[0].name);
                    $("#txtUserType").text(obj[0].user_type_name);
                    $("#txtwarehouse").text(obj[0].branch_name);
                    $("#txtPhone").text(obj[0].phone);
                    $("#txtUsername").text(obj[0].user_name);
                    $("#txtpassword").text(obj[0].password);
                    $("#txtaddress").text(obj[0].address);
                    $("#txtlocation").text(obj[0].location);
                    $("#txtcountry").text(obj[0].country);
                    $("#txtFirstname").val(obj[0].first_name);
                    $("#txtLastname").val(obj[0].last_name);
                    $("#txtUsrName").val(obj[0].user_name);
                    $("#txtPasswd").val(obj[0].password);
                    $("#txtUsrPhone").val(obj[0].phone);
                    $("#txtEmailid").val(obj[0].emailid);
                    $("#txtUsrCountry").val(obj[0].country);
                    $("#txtUsrLocatn").val(obj[0].location);
                    $("#txtUsrAdrs").val(obj[0].address);
                    // $("#comboWarehouseUser").val(obj[0].branch_id);
                    $("#comboUsertype").val(obj[0].user_type);
                    showAssignWarehouses();
                    // showCustomerlist(1);

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }


        function showCustomerlist(page) {
            var filters = {};
            var perpage = $("#slPerpage").val();
            if ($("#txtSearch").val() != "" && $("#txtSearch").val() != undefined) {
                filters.search = $("#txtSearch").val();
            }
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/showCustomerlist",
                data: "{'userid':'" + userid + "','page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    $('#tblCustomers > tbody').html("");
                    var count = obj.count;
                    $("#lbltotalRecors").text(count);
                    if (obj.count == 0) {
                        $("#tblCustomers tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr><td><div style="width:700px;"><div><div class="fl">';
                        htm += '<a class="fl" style="color: inherit; margin-bottom:0px;" href="../managecustomers.aspx?cusId=' + row.cust_id + '">#' + getHighlightedValue(filters.search, row.cust_id.toString()) + '</a >';
                        htm += '<label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.cust_name.toString()) + '</label>';
                        htm += '<label style="text-align: left;">';
                        if (row.cust_phone) {
                            htm += '&nbsp;&nbsp;<span class="fa fa-mobile myicons" style="margin-left:15px;;"></span>';
                            htm += '<span class="myorderSData" style="line-height: 1;">' + getHighlightedValue(filters.search, row.cust_phone.toString()) + '</span>';
                        }

                        htm += '</label></div></td>';
                        if (row.cust_amount > 0) {
                            htm += '<td style="text-align:center;color:red">' + row.cust_amount + '</td>';
                        } else {
                            htm += '<td style="text-align:center;">' + row.cust_amount + '</td>';
                        }
                        htm += '</tr>';

                        // alert(htm);

                        $('#tblCustomers > tbody').append(htm);
                    });
                    htm = '<tr>';
                    htm += '<td colspan="4">';
                    htm += '<div  id="divPagination" style="text-align: center;">';
                    htm += '</div>';
                    htm += '</td>';
                    htm += '</tr>';
                    $('#tblCustomers > tbody').append(htm);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPagination').html(paginate(obj.count, perpage, page, "showCustomerlist"));
                    showAssignWarehouses();


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
            showUserDetails(userid);

        }

        // Start loading branches
        function getBranches() {
            //loading();
            $.ajax({
                type: "POST",
                url: "manageusers.aspx/getBranches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Branch--</option>';
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
                url: "manageusers.aspx/getUserTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--User Role--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.usertype_id + '">' + row.usertype_name + '</option>';
                    });
                    $("#slUserType").html(htm);
                    $("#comboUsertype").html(htm);
                    showUserDetails(userid);
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

        //update userdetails
        function updateUserDetails() {
            sqlInjection();
            var Firstname = $("#txtFirstname").val();
            var Lastname = $("#txtLastname").val();
            var Username = $("#txtUsrName").val();
            var Password = $("#txtPasswd").val();
            var Usertype = $("#comboUsertype").val();
            var Usertypename = $("#comboUsertype option[value='" + Usertype + "']").text();
            var Phone = $("#txtUsrPhone").val();
            var Emailid = $("#txtEmailid").val();
            var Country = $("#txtUsrCountry").val();
            var Location = $("#txtUsrLocatn").val();
            var Address = $("#txtUsrAdrs").val();
            var warehouseId = $("#comboWarehouseUser").val();
            //if (warehouseId == "-1" || warehouseId == "") {
            //    alert("Select the Warehouse");
            //    return false;
            //}
            if (Firstname == "") {
                alert("Enter First Name");
                return false;
            }
            if (Lastname == "") {
                alert("Enter Last Name");
                return false;
            }
            if (Username == "") {
                alert("Enter User Name");
                return false;
            }
            if (Password == "") {
                alert("Enter Password");
                return false;
            }
            if (Usertype == "-1" || Usertype == "") {
                alert("Select user role");
                return false;
            }


            if (Phone == "") {
                alert("Enter phone number");
                return false;
            }
            loading();
            $.ajax({
                type: "POST",
                url: "manageusers.aspx/updateUserDetails",
                data: "{'user_id':'" + userid + "','Firstname':'" + Firstname + "','Lastname':'" + Lastname + "','Username':'" + Username + "','Password':'" + Password + "','Usertype':'" + Usertype + "','Usertypename':'" + Usertypename + "','Phone':'" + Phone + "','Emailid':'" + Emailid + "','Country':'" + Country + "','Location':'" + Location + "','Address':'" + Address + "','branch_id':'" + warehouseId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "E") {
                        alert("Give Another Username");
                        return false;
                    }
                    if (msg.d == "Y") {
                        alert("User Updated Successfully");
                        cancelUserPopup('popupUser');
                        showUserDetails(userid);
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
        //function for assign customers
        function addAssignCustomer(page) {
            var filters = {};
            var perpage = $("#txtpageno").val();
            if ($("#txtAssgnSearch").val() != "" && $("#txtAssgnSearch").val() != undefined) {
                filters.search = $("#txtAssgnSearch").val();
            }
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/addAssignCustomer",
                data: "{'userid':'" + userid + "','page':" + page + ",'filters':" + JSON.stringify(filters) + ",'perpage':'" + perpage + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    var htmp = "";
                    $('#TBLshowAssignCustomers > tbody').html("");
                    var count = obj.count;
                    $("#lblCustTotalrecords").text(count);
                    if (obj.count == 0) {
                        $("#TBLshowAssignCustomers tbody").html('<td colspan="4" style="text-align:center"></div></div><div class="clear"></div><label>No Data Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr>';
                        htm += "<th><div class='checkbox' style='margin-top:0px; margin-bottom:0px;'><label style='font-size: 1em'><input id='chkbxPageId" + i + "'  class='haschecked' type='checkbox'><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnitbsId" + i + "' value='" + row.cust_id + "'/></th>";
                        htm += '<td>';
                        htm += '<a class="fl" style="color: inherit; margin-bottom:0px;" href="#">#' + getHighlightedValue(filters.search, row.cust_id.toString()) + '</a >';
                        htm += '<label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.cust_name.toString()) + '</label>';
                        htm += '</td>';
                        htm += '<td>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;"><a>' + getHighlightedValue(filters.search, row.name.toString()) + '</label>';
                        htm += '</td>';

                        htm += '</tr>';

                        // alert(htm);

                        $('#TBLshowAssignCustomers > tbody').append(htm);
                    });
                    htmp += '<tr>';
                    htmp += '<td colspan="4">';
                    htmp += '<div  id="divPaginationass" style="text-align: center;">';
                    htmp += '</div>';
                    htmp += '</td>';
                    htmp += '</tr>';
                    $('#TBLshowAssignCustomers > tbody').append(htmp);
                    //$('#tblCustomers > tbody').html(htm);
                    $('#divPaginationass').html(paginate(obj.count, perpage, page, "addAssignCustomer"));
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        //reset customers
        function ResetAssignCustomer() {
            $("#txtAssgnSearch").val("");
            $("#chkbxAll").prop("checked", false);
            addAssignCustomer(1);
        }

        //updateassign customers
        function updateAssignCustomer() {
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one Customer !!!');
                return false;
            } else {
                var confirmVal = confirm("Do you want to assign selected customers to " + $("#textName").text() + "?");
                if (confirmVal == true) {
                    var rowCount = $("#TBLshowAssignCustomers tr").length;
                    var rowValue = rowCount - 2;
                    var customersArray = [];
                    for (var i = 0; i < rowValue; i++) {
                        if ($("#chkbxPageId" + i).is(':checked')) {
                            customersArray.push($("#hdnitbsId" + i).val());
                        }
                    }
                    console.log(customersArray);
                    loading();

                    $.ajax({
                        type: "POST",
                        url: "manageusers.aspx/updateAssignCustomer",
                        data: "{'userid':'" + userid + "','customers':" + JSON.stringify(customersArray) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "Y") {
                                cancelUserPopup('popupAssgncustomer');
                                alert("Assigned successfully");

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


        //list warehouses not assigned
        function listWarehouses(page) {
            $("#btnCheckbox").prop("checked", false);
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/listWarehouses",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    var htmp = "";
                    $('#TBLshowAssignWarehouses > tbody').html("");
                    var count = obj.count;
                    $("#lblWarehouseTotalrecords").text(count);
                    if (obj.count == 0) {
                        $("#TBLshowAssignWarehouses tbody").html('<td colspan="2" style="text-align:center"></div></div><div class="clear"></div><label>No Pages Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr>';
                        htm += "<th><div class='checkbox' style='margin-top:0px; margin-bottom:0px;'><label style='font-size: 1em'><input id='chkbxWarehouseId" + i + "'  class='warehousehaschecked' type='checkbox'><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnwarehouseId" + i + "' value='" + row.branch_id + "'/></th>";
                        htm += '<td>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;">' + row.branch_name.toString() + '</label>';
                        htm += '</td>';

                        htm += '</tr>';

                        // alert(htm);

                        $('#TBLshowAssignWarehouses > tbody').append(htm);
                    });


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function checkWarehouseAll(chboxSelectAllElements) {
            var chboxEmailsArray = document.getElementsByClassName("warehousehaschecked");
            var currentRows = $('#TBLshowAssignWarehouses >tbody >tr').length;;
            console.log(currentRows);
            if (chboxSelectAllElements.checked) {
                $(".warehousehaschecked").prop("checked", "true");
            }

            else {
                $(".warehousehaschecked").removeAttr('checked');
            }

        }

        function updateAssignWarehouses() {
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one !!!');
                return false;
            } else {
                var confirmVal = confirm("Do you want to assign selected warehouses to " + $("#textName").text() + "?");
                if (confirmVal == true) {
                    var rowCount = $("#TBLshowAssignWarehouses tr").length;
                    var rowValue = rowCount - 2;
                    var warehouseArray = [];
                    for (var i = 0; i < rowValue; i++) {
                        if ($("#chkbxWarehouseId" + i).is(':checked')) {
                            warehouseArray.push($("#hdnwarehouseId" + i).val());
                        }
                    }
                    console.log(warehouseArray);
                    loading();

                    $.ajax({
                        type: "POST",
                        url: "manageusers.aspx/updateAssignWarehouses",
                        data: "{'userid':'" + userid + "','warehouses':" + JSON.stringify(warehouseArray) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "Y") {
                                popupclose("popupAssgnWarehouse");
                                //cancelUserPopup('popupAssgncustomer');
                                alert("Assigned successfully");
                                showUserDetails(userid);
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

        //function for display warehouses 
        function showAssignWarehouses() {
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/showAssignWarehouses",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    htm = "";
                    if (obj.count == 0) {
                        $("#tblAssignWarehouses > tbody").html('<tr><td style="text-align:center"><label>No warehouses Found</label></td></tr>');
                    } else {
                        $.each(obj.data, function (i, row) {
                            htm += "<tr><td colspan='4'>" + row.branch_name + "</td><td colspan='4'><a class='btn btn-danger btn-xs pull-right'><li class='fa fa-close' onclick='unAssignWarehouse(" + row.ub_id + ");'></li></a></td></tr>";

                        });
                        $("#tblAssignWarehouses > tbody").html(htm);
                        showAssignLocations();
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function unAssignWarehouse(ubId) {
            var confirmVal = confirm("Do you want to remove the selected warehouse from " + $("#textName").text() + "?");
            if (confirmVal == true) {
                loading();

                $.ajax({
                    type: "POST",
                    url: "manageusers.aspx/removeAssignWarehouse",
                    data: "{'ubId':'" + ubId + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        if (msg.d == "Y") {
                            alert("removed successfully");
                            showAssignWarehouses();
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

        //location starts
        function listLocations(page) {
            $("#btnLocationchckBx").prop("checked", false);
            //alert($("#slDistrict").val());

            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/listLocations",
                data: "{'userid':'" + userid + "','dis_id':'" + $("#slDistrict").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    var htm = "";
                    var htmp = "";
                    $('#TBLshowAssignLocations > tbody').html("");
                    var count = obj.count;
                    $("#lblLocationTotallocations").text(count);
                    if (obj.count == 0) {
                        $("#TBLshowAssignLocations tbody").html('<td colspan="2" style="text-align:center"></div></div><div class="clear"></div><label>No locations Found</label></td>');
                    }
                    $.each(obj.data, function (i, row) {
                        htm = "";
                        htm = "";
                        htm += '<tr>';
                        htm += "<th><div class='checkbox' style='margin-top:0px; margin-bottom:0px;'><label style='font-size: 1em'><input id='chkbxLocationId" + i + "'  class='locationhaschecked' type='checkbox'><span class='cr'><i class='cr-icon fa fa-check'></i></span></label></div><input type='hidden' id='hdnlocationId" + i + "' value='" + row.location_id + "'/></th>";
                        htm += '<td>';
                        htm += '  <label class="fl" style="margin-bottom:0px;margin-left:5px;">' + row.location_name.toString() + '</label>';
                        htm += '</td>';

                        htm += '</tr>';

                        // alert(htm);

                        $('#TBLshowAssignLocations > tbody').append(htm);
                    });


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function checkLocationAll(chboxSelectAllElements) {
            var chboxEmailsArray = document.getElementsByClassName("locationhaschecked");
            var currentRows = $('#TBLshowAssignLocations >tbody >tr').length;;
            console.log(currentRows);
            if (chboxSelectAllElements.checked) {
                $(".locationhaschecked").prop("checked", "true");
            }

            else {
                $(".locationhaschecked").removeAttr('checked');
            }

        }

        function updateAssignLocations() {
            if ($("input[type=checkbox]:checked").length === 0) {
                alert('Please select atleast one !!!');
                return false;
            } else {
                var confirmVal = confirm("Do you want to assign selected locations to " + $("#textName").text() + "?");
                if (confirmVal == true) {
                    var rowCount = $("#TBLshowAssignLocations tr").length;
                    var rowValue = rowCount - 2;
                    var locationArray = [];
                    for (var i = 0; i < rowValue; i++) {
                        if ($("#chkbxLocationId" + i).is(':checked')) {
                            locationArray.push($("#hdnlocationId" + i).val());
                        }
                    }
                    console.log(locationArray);
                    loading();

                    $.ajax({
                        type: "POST",
                        url: "manageusers.aspx/updateAssignLocations",
                        data: "{'userid':'" + userid + "','locations':" + JSON.stringify(locationArray) + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (msg) {
                            Unloading();
                            if (msg.d == "Y") {
                                popupclose("popupAssgnLocation");
                                //cancelUserPopup('popupAssgncustomer');
                                alert("Assigned successfully");
                                showUserDetails(userid);
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

        //function for display warehouses 
        function showAssignLocations() {
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/showAssignLocations",
                data: "{'userid':'" + userid + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    htm = "";
                    if (obj.count == 0) {
                        $("#tblAssignLocations > tbody").html('<tr><td style="text-align:center"><label>No Locations Found</label></td></tr>');
                    } else {
                        $.each(obj.data, function (i, row) {
                            htm += "<tr><td colspan='4'>" + row.location_name + "</td><td colspan='4'><a class='btn btn-danger btn-xs pull-right'><li class='fa fa-close' onclick='unAssignLocation(" + row.ul_id + ");'></li></a></td></tr>";

                        });
                        $("#tblAssignLocations > tbody").html(htm);
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
        }

        function unAssignLocation(ulId) {
            var confirmVal = confirm("Do you want to remove the selected location from " + $("#textName").text() + "?");
            if (confirmVal == true) {
                loading();

                $.ajax({
                    type: "POST",
                    url: "manageusers.aspx/removeAssignLocation",
                    data: "{'ulId':'" + ulId + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        if (msg.d == "Y") {
                            alert("removed successfully");
                            showAssignLocations();
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

        function loadDistricts() {
            loading();

            $.ajax({
                type: "POST",
                url: "manageusers.aspx/loadDistricts",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    if (obj.length == 0) {
                        $("#slDistrict").html('<option value="-1" selected="selected">--District--</option>');
                        //    showStateList();
                        return false;
                    }
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--District--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.dis_id + '">' + row.dis_name + '</option>';
                    });
                    $("#slDistrict").html(htm);


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        //location ends
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
                            <label style="font-weight: bold; font-size: 16px;">User Profile</label>

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

                                    <label>User Info</label>

                                    <ul class="nav navbar-right panel_toolbox">
                                        <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                        </li>
                                        <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                        </li>--%>
                                    </ul>
                                    <%--<a href="" class="btn btn-success btn-xs pull-right"><span class="fa fa-pencil-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Edit</a>--%>

                                    <div data-toggle="modal" data-target="#popupUser" class="btn btn-success btn-xs pull-right"><span class="fa fa-pencil-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Edit Profile</div>

                                </div>
                                <div class="x_content">

                                    <form id="demo-form2" class="">
                                        <div class="col-md-6 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-bottom: 2px;">
                                                <span class="myorderMData">#<a class="" style="color: inherit; margin-bottom: 0px;" id="txtuserId"></a>
                                                    <label class="" style="margin-bottom: 0px; padding-left: 5px; padding-right: 5px; font-size: 14px;"><a id="textName"></a></label>
                                                    <span class="status label label-warning" id="txtUserType"></span></span>
                                            </div>
                                        </div>
                                        <div class="col-md-3 col-sm-12 col-xs-12">
                                            <span class="myorderMDatafor">
                                                <label class="" style="font-weight: normal"><span class="fa fa-map-marker myicons" title="Warehouse"></span><a id="txtwarehouse"></a></label>
                                                <label class="" style="margin-left: 10px; font-weight: normal"><span class="fa fa-mobile myicons" title="Phone Number"></span><a id="txtPhone"></a></label>
                                            </span>
                                        </div>

                                        <div class="col-md-3 col-sm-12 col-xs-12">
                                            <div class="form-group" style="margin-bottom: 2px;">
                                                <span class="myorderMDatafor">
                                                    <label class="" style="color: inherit; margin-bottom: 0px;"><span class="fa fa-user myicons" title="User Name"></span></label>
                                                    <label class="myorderMDatafor" style="font-weight: normal"><a id="txtUsername"></a></label>



                                                    <label class="" style="color: inherit; margin-bottom: 0px; margin-left: 10px;"><span class="fa fa-key myicons" title="Password"></span></label>
                                                    <label class="myorderMDatafor" style="font-weight: normal"><a id="txtpassword"></a></label>
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
                                                    <label id="txtlocation" style="font-weight: normal"></label>
                                                    <span class="fa fa-globe" title="Country"></span>
                                                    <label id="txtcountry" style="font-weight: normal"></label>
                                                </address>
                                            </div>

                                        </div>

                                    </form>
                                </div>
                            </div>
                        </div>

                        <%-- start popup starts for add new user --%>
                        <div class="modal fade" id="popupUser" role="dialog">
                            <div class="modal-dialog modal-lg" style="width: 95%;">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" onclick="javascript:popupclose('popupUser');">&times;</button>
                                        <div class="col-md-6 col-sm-6 col-xs-8">
                                            <h4 class="modal-title">Edit User</h4>
                                        </div>

                                    </div>
                                    <div class="modal-body">
                                        <div class="row">
                                            <div class="col-md-12">
                                                <form role="form" class="form-horizontal">
                                                    <%--   <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Warehouse<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <select class="form-control" id="comboWarehouseUser">
                                                                <option value="0">-Select Warehouse-</option>
                                                            </select>
                                                        </div>
                                                    </div>--%>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            First Name<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtFirstname" placeholder="Enter First Name" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Last Name<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtLastname" placeholder="Enter Last Name" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            User Name<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtUsrName" placeholder="Enter Username" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>

                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Password<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtPasswd" placeholder="Enter Password" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            User Type<span class="required">*</span>
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <select class="form-control" id="comboUsertype">
                                                                <option value="0">-Select User Role-</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Phone
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="number" id="txtUsrPhone" style="padding: 0px; text-indent: 3px;" placeholder="Enter Phone" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Email
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtEmailid" placeholder="Enter Email" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Country
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtUsrCountry" placeholder="Enter Country" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Location
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <input type="text" id="txtUsrLocatn" placeholder="Enter City" required="required" class="form-control col-md-7 col-xs-12">
                                                        </div>
                                                    </div>

                                                    <div class="form-group">
                                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                            Address
                                                        </label>
                                                        <div class="col-md-6 col-sm-6 col-xs-12">
                                                            <textarea class="form-control" rows="3" placeholder="Enter Address" id="txtUsrAdrs" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 70px; resize: none"></textarea>
                                                        </div>
                                                    </div>

                                                </form>
                                                <div class="clearfix"></div>

                                                <div class="ln_solid"></div>
                                                <div class="form-group" style="padding-bottom: 40px;">
                                                    <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-3">
                                                        <div id="btnUserDetailsAction">
                                                            <div class="btn btn-success mybtnstyl" onclick="javascript:updateUserDetails();">UPDATE</div>
                                                        </div>
                                                        <div onclick="javascript:cancelUserPopup('popupUser');" class="btn btn-danger mybtnstyl">CANCEL</div>
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
                    <div class="row" style="display: none;">
                        <div class="col-md-12 col-sm-12 col-xs-12">

                            <div class="x_content">
                                <div class="row">
                                    <div class="col-md-12 col-sm-12 col-xs-12">
                                        <div class="x_panel">
                                            <div class="x_title" style="margin-bottom: 0px;">
                                                <div class="col-md-8 col-sm-12 col-xs-12">

                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                        <label style="">Assigned Customers List</label><span class="badge" style="color: #fff; margin-left: 5px; background: #d00101; padding-left: 5px; padding-right: 5px;" id="lbltotalRecors"></span>
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


                                                <div data-toggle="modal" data-target="#popupAssgncustomer" class="btn btn-success btn-xs pull-right" onclick="ResetAssignCustomer(1);"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Assign Customer</div>

                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="x_title">
                                                <div class="col-md-11 col-sm-6 col-xs-10 " style="margin-top: 10px;">
                                                    <div class="col-md-12 col-sm-6 col-xs-12">
                                                        <div class="col-md-1 col-sm-6 col-xs-12">
                                                            <select class="input-sm" id="slPerpage" onchange="javascript:showCustomerlist(1);">
                                                                <option value="50">50</option>
                                                                <option value="100">100</option>
                                                                <option value="200">200</option>
                                                            </select>
                                                        </div>
                                                        <div class="form-group">
                                                            <div class="input-group">
                                                                <input type="text" class="form-control" id="txtSearch" placeholder="Customer ID/Name/Phone" style="height: 33px;" />
                                                                <span class="input-group-btn">
                                                                    <button type="button" class="btn btn-default" onclick="showCustomerlist(1)">
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


                                            <div class="col-md-12 col-sm-12 col-xs-12" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                <div class="x_content">
                                                    <table id="tblCustomers" class="table table-hover" style="table-layout: auto;">
                                                        <thead>
                                                            <tr>

                                                                <th>Customer</th>
                                                                <th style="text-align: center;">Outstanding amt.</th>
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
                                        <div class="modal-dialog modal-lg" style="">

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


                    <div class="row">
                        <div class="col-md-12 col-sm-12 col-xs-12">

                            <div class="x_content">
                                <div class="row">
                                    <div class="col-md-12 col-sm-12 col-xs-12">
                                        <div class="x_panel">
                                            <div class="x_title" style="margin-bottom: 0px;">
                                                <div class="col-md-8 col-sm-12 col-xs-12">

                                                    <div class="col-md-8 col-sm-6 col-xs-12">
                                                        <label style="">Assigned Warehouses</label>

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


                                                <div data-toggle="modal" data-target="#popupAssgnWarehouse" class="btn btn-success btn-xs pull-right" onclick="listWarehouses(1);"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Assign Warehouse</div>

                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                    <table id="tblAssignWarehouses" class="table table-hover" style="table-layout: auto; font-weight: bold; background: #f9f9f9;">
                                                        <tbody>
                                                        </tbody>
                                                    </table>


                                                </div>

                                            </div>
                                        </div>
                                    </div>

                                    <%-- start popup starts for showing pages --%>
                                    <div class="modal fade" id="popupAssgnWarehouse" role="dialog">
                                        <div class="modal-dialog modal-md">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" onclick="javascript:popupclose('popupAssgnWarehouse');">&times;</button>
                                                </div>
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                    <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                        <table id="TBLshowAssignWarehouses" class="table table-striped table-bordered" style="table-layout: auto;">
                                                            <thead>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        <button class="btn btn-success mybtnstyl" type="button" style="float: right;" onclick="javascript:updateAssignWarehouses();">
                                                                            <li class="fa fa-list" style="margin-right: 5px;"></li>
                                                                            Assign
                                                                        </button>

                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th style="width: 30px;">
                                                                        <div class="checkbox" style="margin-bottom: 0px; margin-top: 0px;">
                                                                            <label style="font-size: 1em">
                                                                                <input id="btnCheckbox" onchange="checkWarehouseAll(this)" name="chk[]" class="" type="checkbox">
                                                                                <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                                            </label>
                                                                            All
                                                                        </div>
                                                                    </th>
                                                                    <th>Warehouses(Total:<label id="lblWarehouseTotalrecords"></label>)</th>


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
                                                        <label style="">Assigned Locations</label>

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


                                                <div data-toggle="modal" data-target="#popupAssgnLocation" class="btn btn-success btn-xs pull-right" onclick="listLocations(1);"><span class="fa fa-plus-square" style="color: #fff; margin-right: 5px; font-size: 14px;"></span>Assign Location</div>

                                                <div class="clearfix"></div>
                                            </div>
                                            <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                    <table id="tblAssignLocations" class="table table-hover" style="table-layout: auto; font-weight: bold; background: #f9f9f9;">
                                                        <tbody>
                                                        </tbody>
                                                    </table>


                                                </div>

                                            </div>
                                        </div>
                                    </div>

                                    <%-- start popup starts for showing pages --%>
                                    <div class="modal fade" id="popupAssgnLocation" role="dialog">
                                        <div class="modal-dialog modal-md">

                                            <!-- Modal content-->
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <button type="button" class="close" onclick="javascript:popupclose('popupAssgnLocation');">&times;</button>
                                                </div>
                                                <div class="col-md-12 col-sm-12 col-xs-12" style="overflow-x: auto;">
                                                    <div class="x_content" style="height: 450px; overflow: scroll; overflow-x: hidden;">
                                                        <table id="TBLshowAssignLocations" class="table table-striped table-bordered" style="table-layout: auto;">
                                                            <thead>
                                                                <tr>

                                                                    <td colspan="2">
                                                                        <div class="col-md-6">
                                                                            <select class="form-control" id="slDistrict" onchange="listLocations(1);">
                                                                                <option value="1">India</option>
                                                                                <option value="2">UAE</option>
                                                                            </select>
                                                                        </div>
                                                                        <div class="col-md-6">
                                                                            <button class="btn btn-success mybtnstyl" type="button" style="float: right;" onclick="javascript:updateAssignLocations();">
                                                                                <li class="fa fa-list" style="margin-right: 5px;"></li>
                                                                                Assign
                                                                            </button>
                                                                        </div>

                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th style="width: 30px;">
                                                                        <div class="checkbox" style="margin-bottom: 0px; margin-top: 0px;">
                                                                            <label style="font-size: 1em">
                                                                                <input id="btnLocationchckBx" onchange="checkLocationAll(this)" name="chk[]" class="" type="checkbox">
                                                                                <span class="cr"><i class="cr-icon fa fa-check"></i></span>
                                                                            </label>
                                                                            All
                                                                        </div>
                                                                    </th>
                                                                    <th>Locations(Total:<label id="lblLocationTotallocations"></label>)</th>


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
