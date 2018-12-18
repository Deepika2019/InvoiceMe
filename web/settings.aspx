<%@ Page Language="C#" AutoEventWireup="true" CodeFile="settings.aspx.cs" Inherits="settings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
      	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>
    <title>Settings | Invoice Me</title>
        <script src="js/common.js"></script>
    <script src="js/jquery-2.0.3.js"></script>
    <script src="js/pagination.js"></script>
    <script src="js/jquery.cookie.js"></script>
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet"/>
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet"/>
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet"/>
    <!-- iCheck -->
    <link href="../css/bootstrap/green.css" rel="stylesheet"/>
    <!-- Select2 -->
    <link href="../css/bootstrap/select2.min.css" rel="stylesheet"/>
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet"/>

    <script type="text/javascript">

        $(document).ready(function () {
            var BranchId = $.cookie("invntrystaffBranchId");
            //alert(BranchId);
            var CountryId = $.cookie("invntrystaffCountryId");
          //alert(CountryId);
            //if (!BranchId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            //if (!CountryId) {
            //    location.href = "login.aspx";
            //    return false;
            //}
            clearAll();
            showUserTypeList();
          
           
          
          
            
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

        function clearAll() {
            $("#txtUserTypeName").val("");
            $("#txtLocationName").val("");
            $("#txtCountryName").val("");
            $("#txtStateName").val("");
            $("#txtCurrencyName").val("");
            $("#slCountry").val("-1");
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
        ///////////////////////////////////////////////////////



        function showUserTypeList() {

            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showUserTypeList",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        Unloading();
                        $("#tblUserType tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            console.log(row);
                            console.log(row.country_name);
                            // sb.Append("<tr style='cursor:pointer'><td>" + dt.Rows[i]["country_name"] + "<button class='btn bg-green btn-xs pull-right' onclick=javascript:editCountry('" + dt.Rows[i]["country_id"] + "','" + dt.Rows[i]["country_name"].ToString().Replace(" ", "&nbsp;") + "');  style='margin-top:2px; margin-right:15px; cursor:pointer;'><li class='fa fa-edit'></li></button> <button class='btn btn-danger btn-xs pull-right' onclick=javascript:removeCountry('" + dt.Rows[i]["country_id"] + "'); style='cursor:pointer;'><li class='fa fa-close'></button></td></tr>");
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.usertype_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editUserType(" + row.usertype_id + ",\"" + row.usertype_name + "\");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeUserType(" + row.usertype_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                            //
                        });
                        $("#tblUserType tbody").html(htm);
                        
                    }
                    showCurrencyList();
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }



        function editUserType(UserTypeId, UserTypeName) {
            $("#txtUserTypeName").val(UserTypeName.replace(/\u00a0/g, " "));
            $("#spanUserTypeAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addUserType(\'update\'," + UserTypeId + "); class='btn btn-warning pull-right'>Update</div></div>");
        }


        function addUserType(actionType, UserType_id) {
            sqlInjection();

            var UserType_name = $("#txtUserTypeName").val();
            if (UserType_name == "") {
                alert("Enter UserType");
                return false;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addUserType",
                data: "{'actionType':'" + actionType + "','UserType_id':'" + UserType_id + "','UserType_name':'" + UserType_name + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("UserType Added Successfully");
                            clearUsertype();
                            showUserTypeList();
                        }
                        if (actionType == "update") {
                            alert("UserType Updated Successfully");
                            clearUsertype();
                            showUserTypeList();
                        }


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


        function removeUserType(UserType_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the UserType?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeUserType",
                    data: "{'UserType_id':'" + UserType_id + "'}",
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
                            showUserTypeList();
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

        function clearUsertype() {
            $("#txtUserTypeName").val('');
            $("#spanUserTypeAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addUserType(\'insert\','0'); class='btn btn-warning pull-right'>Save</div></div>");
        }

        ///////////////////////////////////////////////////////////// 



        function showCurrencyList() {

            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showCurrencyList",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        Unloading();
                        $("#tblCurrency tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            // console.log(row);
                            //console.log(row.country_name);
                            // sb.Append("<tr style='cursor:pointer'><td>" + dt.Rows[i]["country_name"] + "<button class='btn bg-green btn-xs pull-right' onclick=javascript:editCountry('" + dt.Rows[i]["country_id"] + "','" + dt.Rows[i]["country_name"].ToString().Replace(" ", "&nbsp;") + "');  style='margin-top:2px; margin-right:15px; cursor:pointer;'><li class='fa fa-edit'></li></button> <button class='btn btn-danger btn-xs pull-right' onclick=javascript:removeCountry('" + dt.Rows[i]["country_id"] + "'); style='cursor:pointer;'><li class='fa fa-close'></button></td></tr>");
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.currency_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editCurrency(" + row.currency_id + ",\"" + row.currency_name + "\");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeCurrency(" + row.currency_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                        });
                        $("#tblCurrency tbody").html(htm);
                      
                    }
                    showCountryList();
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function editCurrency(CurrencyId, CurrencyName) {
            $("#txtCurrencyName").val(CurrencyName.replace(/\u00a0/g, " "));
            $("#spanCurrencyAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addCurrency(\'update\'," + CurrencyId + "); class='btn btn-warning pull-right'>Update</div></div>");
            // $("#spanCurrencyAction").html("<div class='smallbutton fl' style='margin-left:5px;' onclick=javascript:addCurrency('update','" + CurrencyId + "');><div class='smallbuttontext'>Update</div></div>");

        }


        function addCurrency(actionType, Currency_id) {

            sqlInjection();

            var Currency_name = $("#txtCurrencyName").val();
            if (Currency_name == "") {
                alert("Enter Currency");
                return false;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addCurrency",
                data: "{'actionType':'" + actionType + "','Currency_id':'" + Currency_id + "','Currency_name':'" + Currency_name + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Currency Added Successfully");
                            clearCurrency();
                        }
                        if (actionType == "update") {
                            alert("Currency Updated Successfully");
                            clearCurrency();
                        }
                        showUserTypeList();

                    }
                    else {
                        alert("Currency Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function removeCurrency(Currency_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the Currency?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeCurrency",
                    data: "{'Currency_id':'" + Currency_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("Currency Deleted Successfully");
                            clearCurrency();
                            showCurrencyList();
                        }
                        else if (msg.d == "E") {
                            alert("Currency Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("Currency Deletion Failed");

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

        function clearCurrency() {
            $("#txtCurrencyName").val('');
            $("#spanCurrencyAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addCurrency(\'insert\','0'); class='btn btn-warning pull-right'>Save</div></div>");
        }


        function showCountryList() {

            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showCountryList",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        Unloading();
                        $("#tblCountry tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                           // console.log(row);
                            //console.log(row.country_name);
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.country_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editCountry(" + row.country_id + ",\"" + row.country_name + "\");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeCountry(" + row.country_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                        });
                        $("#tblCountry tbody").html(htm);
                    }
                   
                    loadCountries();
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function editCountry(contryId, CountryName) {
            $("#txtCountryName").val(CountryName.replace(/\u00a0/g, " "));
            $("#spanCountryAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addCountry(\'update\'," + contryId + "); class='btn btn-warning pull-right'>Update</div></div>");
           // $("#spanCountryAction").html("<div class='smallbutton fl' style='margin-left:5px;' onclick=javascript:addCountry('update','" + contryId + "');><div class='smallbuttontext'>Update</div></div>");

        }


        function addCountry(actionType, country_id) {

            sqlInjection();

            var country_name = $("#txtCountryName").val();
            if (country_name == "") {
                alert("Enter Country");
                return false;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addCountry",
                data: "{'actionType':'" + actionType + "','country_id':'" + country_id + "','country_name':'" + country_name + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Country Added Successfully");
                            clearCountry();
                        }
                        if (actionType == "update") {
                            alert("Country Updated Successfully");
                            clearCountry();
                        }
                        showUserTypeList();

                    }
                    else {
                        alert("Country Adding Failed");
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function removeCountry(country_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the Country?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeCountry",
                    data: "{'country_id':'" + country_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("Country Deleted Successfully");
                            clearCountry();
                            showCountryList();
                            
                        }
                        else if (msg.d == "E") {
                            alert("Country Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("Country Deletion Failed");

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

        function clearCountry() {
            $("#txtCountryName").val('');
            $("#spanCountryAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addCountry(\'insert\','0'); class='btn btn-warning pull-right'>Save</div></div>");
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////////
        
      
        function showStateList() {
          //  alert("");
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showStateList",
                data: "{'country_id':'" + $("#slCountry").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        Unloading();
                        $("#tblstatelist tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            // console.log(row);
                            //console.log(row.country_name);
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.state_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editState(" + row.state_id + ",\"" + row.state_name + "\","+row.country_id+");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeState(" + row.state_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                        });
                        $("#tblstatelist tbody").html(htm);
                       
                        showDistrictList();

                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function editState(StateId, StateName,country) {
            $("#txtStateName").val(StateName.replace(/\u00a0/g, " "));
            $("#slCountry").val(country);
            $("#spanStateAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addState(\'update\'," + StateId + "); class='btn btn-warning pull-right'>Update</div></div>");
          
            $('html,body').animate({
                scrollTop: $('#tblstatelist').offset().top
            }, 500);
        }


        function addState(actionType, State_id) {

            sqlInjection();

            var State_name = $("#txtStateName").val();
            if (State_name == "") {
                alert("Enter State");
                return false;
            }
            if ($("#slCountry").val() == -1) {
                alert("Choose country");
                return false;
            }
            var country = $("#slCountry").val();
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addState",
                data: "{'actionType':'" + actionType + "','State_id':'" + State_id + "','State_name':'" + State_name + "','country':'" + country + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("State Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("State Updated Successfully");
                        }
                        $("#txtStateName").val("");
                        showUserTypeList();

                    }
                    else {
                        alert("State Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        function clearStateFields() {
            $("#txtStateName").val('');
            $("#slCountry").val(-1);
            $("#spanStateAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addState(\'insert\','0'); class='btn btn-warning pull-right'>Save</div></div>");
        }

        function removeState(State_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the State?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeState",
                    data: "{'State_id':'" + State_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("State Deleted Successfully");
                            showStateList();
                        }
                        else if (msg.d == "E") {
                            alert("State Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("State Deletion Failed");

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

        //////////////////////////////////////////////////////////////////////////////////////////


        function clearSettingsTextbox(textbx_id) {
            $("#" + textbx_id).val("");
        }

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //function for addcategory
        function addcategory(actionType, type_id) {
            sqlInjection();

            var cat_name = $("#txtcategoryname").val();
            if (cat_name == "") {
                alert("Enter Category Name");
                return false;
            }
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addcategory",
                data: "{'actionType':'" + actionType + "','type_id':'" + type_id + "','cat_name':'" + cat_name + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("category Type Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("Category Type Updated Successfully");
                        }
                        showcategorylist();
                    }
                    else {
                        alert("Category Type Adding Failed");
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //function for list category
        function showcategorylist() {

            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showcategorylist",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d != 0 && msg.d != "N") {

                        $("#tblcategorylist").html(msg.d);

                        return;
                    }
                    else {
                        alert("No Category types Found");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //function for remove category
        function removecategory(type_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the Category Type?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removecategory",
                    data: "{'type_id':'" + type_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("Category Type Deleted Successfully");
                            showcategorylist();
                        }
                        else if (msg.d == "E") {
                            alert("Category Type Reference Found,Can't Delete");
                            return false;

                        }
                        else {
                            alert("Category Type Deletion Failed");

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

        //function for edit category
        function editcategory(cat_id, cat_name) {
            $("#txtcategoryname").val(cat_name.replace(/\u00a0/g, " "));
            $("#spanCategoryAction").html("<div class='smallbutton fl' style='margin-left:5px;' onclick=javascript:addcategory('update','" + cat_id + "');><div class='smallbuttontext'>Update</div></div>");

        }

   


        function showLocationList() {
           // alert("");
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showLocationList",
                data: "{'dis_id':'" + $("#selDistrict").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "N") {
                        Unloading();
                        $("#tbllocationlist tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            // console.log(row);
                            //console.log(row.country_name);
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.location_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editLocation(" + row.location_id + ",\"" + row.location_name + "\"," + row.dist_id + ");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeLocation(" + row.location_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                        });
                        $("#tbllocationlist tbody").html(htm);
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function editLocation(LocationId, LocationName, district) {
            $("#txtLocationName").val(LocationName.replace(/\u00a0/g, " "));
            $("#selDistrict").val(district);
            $("#spanLocationAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addLocation(\'update\'," + LocationId + "); class='btn btn-warning pull-right'>Update</div></div>");
           // $("#spanLocationAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick='javascript:addLocation(\'update\'," + LocationId + ");' class='btn btn-warning pull-right'>Update</div>");

        }


        function addLocation(actionType, Location_id) {

            sqlInjection();

            var Location_name = $("#txtLocationName").val();
            if (Location_name == "") {
                alert("Enter Location");
                return false;
            }
            if ($("#selDistrict").val() == -1) {
                alert("Choose district");
                return false;
            }
            var district = $("#selDistrict").val();
          //  loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addLocation",
                data: "{'actionType':'" + actionType + "','Location_id':'" + Location_id + "','Location_name':'" + Location_name + "','district':'" + district + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                   // Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Location Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("Location Updated Successfully");
                        }
                        $("#txtLocationName").val("");
                        showLocationList();

                    }
                    else {
                        alert("Location Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function removeLocation(Location_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the Location?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeLocation",
                    data: "{'Location_id':'" + Location_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("Location Deleted Successfully");
                            showStateList();
                        }
                        else if (msg.d == "E") {
                            alert("Location Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("Location Deletion Failed");

                        }
                        showLocationList();
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

        ///////////////////////////////////////////////////////////////////

        function showDistrictList() {

            loading();
           // $("#slState").html(htm);
            $.ajax({
                type: "POST",
                url: "settings.aspx/showDistrictList",
                data: "{'state_id':'" +  $("#slState").val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "N") {
                        Unloading();
                        $("#tbldistrictlist tbody").html('<td colspan="2" style="padding:5px;"><div style="width:100%;text-align:center;font-weight:bold;"><div style="display:inline-block">Nothing Found...</div></div></td>');
                    }
                    else {
                        //alert("haii");
                        var obj = JSON.parse(msg.d)
                        var htm = "";
                        $.each(obj.data, function (i, row) {
                            // console.log(row);
                            //console.log(row.country_name);
                            htm += "<tr>";
                            htm += "<td colspan='2'>" + row.dis_name + "";
                            htm += "<button class='btn bg-green btn-xs pull-right' onclick='javascript:editDistrict(" + row.dis_id + ",\"" + row.dis_name + "\"," + row.state_id + ");' type='reset'><li class='fa fa-edit'></li></button>";
                            htm += "<button class='btn btn-danger btn-xs pull-right' onclick='javascript:removeDistrict(" + row.dis_id + ");' type='reset'><li class='fa fa-close'></button></td>";
                            htm += "</tr>";
                        });
                        $("#tbldistrictlist tbody").html(htm);
                        

                    }
                    showLocationList();
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function editDistrict(DistrictId, DistrictName, state) {
            $("#txtDistrictName").val(DistrictName.replace(/\u00a0/g, " "));
            $("#slState").val(state);
            $("#spanDistrictAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addDistrict(\'update\'," + DistrictId + "); class='btn btn-warning pull-right'>Update</div></div>");

            $('html,body').animate({
                scrollTop: $('#tbldistrictlist').offset().top
            }, 500);
        }


        function addDistrict(actionType, District_id) {

            sqlInjection();

            var district_name = $("#txtDistrictName").val();
            if (district_name == "") {
                alert("Enter District");
                return false;
            }
            if ($("#slState").val() == -1) {
                alert("Choose state");
                return false;
            }
            var state = $("#slState").val();
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addDistrict",
                data: "{'actionType':'" + actionType + "','District_id':'" + District_id + "','district_name':'" + district_name + "','state':'" + state + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("District Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("District Updated Successfully");
                        }
                        clearDistrictFields();
                        showUserTypeList();

                    }
                    else {
                        alert("District Adding Failed");

                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        function clearDistrictFields() {
            $("#txtDistrictName").val('');
            //$("#slState").val(-1);
            $("#spanDistrictAction").html("<div style='font-size:11px; padding:4px; font-weight:bold;' onclick=javascript:addDistrict(\'insert\','0'); class='btn btn-warning pull-right'>Save</div></div>");
        }

        function removeDistrict(District_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the District?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeDistrict",
                    data: "{'District_id':'" + District_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("District Deleted Successfully");
                            showUserTypeList();
                        }
                        else if (msg.d == "E") {
                            alert("District Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("District Deletion Failed");

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

        ///////////////////////////////////////////////////////

        

        function showDateSetting() {

            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/showDateSetting",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d != 0 && msg.d != "N") {

                        $("#tbldatesetting").html(msg.d);

                        return;
                    }
                    else {
                        alert("No data Found");
                        return;
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        //function editState(StateId, StateName) {
        //    $("#txtStateName").val(StateName.replace(/\u00a0/g, " "));
        //    $("#spanStateAction").html("<div class='smallbutton fl' style='margin-left:5px;' onclick=javascript:addState('update','" + StateId + "');><div class='smallbuttontext'>Update</div></div>");

        //}


        function addDateSetting(actionType) {

            sqlInjection();

            var mandatory_count = $("#txtMandatoryCount").val();
            if (mandatory_count == "") {
                alert("Enter Mandatory Day Count");
                return false;
            }
            var expiry_count = $("#txtExpiryCount").val();
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/addDateSetting",
                data: "{'actionType':'" + actionType + "','mandatory_count':'" + mandatory_count + "','expiry_count':'" + expiry_count + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    // alert(msg.d);
                    //alert("Success");
                    Unloading();
                    //return;
                    if (msg.d == "E") {
                        alert("Already exist the mandatory and expiry count..");
                    }
                    else if (msg.d == "Y") {
                        if (actionType == "insert") {
                            alert("Added Successfully");
                        }
                        if (actionType == "update") {
                            alert("Updated Successfully");
                        }
                        showDateSetting();

                    }


                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }


        function removeState(State_id) {

            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the State?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeState",
                    data: "{'State_id':'" + State_id + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("State Deleted Successfully");
                            showStateList();
                        }
                        else if (msg.d == "E") {
                            alert("State Reference Found,Can't Delete");
                            return false;
                        }
                        else {
                            alert("State Deletion Failed");

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

        //////////////////////////////////////////////////////////////////////////////////////////
        //clear function for datesetting
        function clearDateSetting() {
            $("#txtMandatoryCount").val("");
            $("#txtExpiryCount").val("");
        }

        //edit date setting
        function editDatesetting(mandatorydaycount, expirydaycount) {
            $("#txtMandatoryCount").val(mandatorydaycount);
            $("#txtExpiryCount").val(expirydaycount);
            $("#spanDateSettingAction").html("<div class='smallbutton fl' style='margin-left:5px;' onclick=javascript:addDateSetting('update');><div class='smallbuttontext'>Update</div></div>");
        }

        function removeDatesetting() {
            var r;  //confirm("Do you want to deacvtivate the member or not?");
            r = confirm("Do You want to Delete the Datesettings Data?");

            if (r == true) {

                sqlInjection();

                loading();

                $.ajax({
                    type: "POST",
                    url: "settings.aspx/removeDatesetting",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        // alert(msg.d);
                        //alert("Success");
                        Unloading();
                        //return;
                        if (msg.d == "Y") {
                            alert("Data Deleted Successfully");
                            showCountryList();
                        }

                        else {
                            alert("Data Deletion Failed");

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

        function loadCountries() {
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/loadCountries",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                  
                    var obj = JSON.parse(msg.d);
                    if (obj.length == 0) {
                        $("#slCountry").html('<option value="-1" selected="selected">--Country--</option>');
                        return false;
                    }
                    var htm = "";
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.country_id + '">' + row.country_name + '</option>';
                    });
                    $("#slCountry").html(htm);
                   
                    loadStates();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        function loadStates() {
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/loadStates",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                   // console.log(msg.d);
                    if (msg.d == "N") {
                     
                    }
                    var obj = JSON.parse(msg.d);
                    console.log(obj);
                    if (obj.length==0) {
                        $("#slState").html('<option value="-1" selected="selected">--State--</option>');
                        loadDistricts();
                        return false;
                    }
                    var htm = "";
                 //   htm += '<option value="-1" selected="selected">--State--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.state_id + '">' + row.state_name + '</option>';
                    });
                    $("#slState").html(htm);
                    loadDistricts();
               
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        
        function loadDistricts() {
            loading();

            $.ajax({
                type: "POST",
                url: "settings.aspx/loadDistricts",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    if (obj.length == 0) {
                        $("#selDistrict").html('<option value="-1" selected="selected">--District--</option>');
                        showStateList();
                    //    showStateList();
                        return false;
                    }
                    var htm = "";
                    //   htm += '<option value="-1" selected="selected">--State--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.dis_id + '">' + row.dis_name + '</option>';
                    });
                    $("#selDistrict").html(htm);
                    showStateList();
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
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
              <a href="#" class="site_title"><!--<i class="fa fa-paw"></i> --><span>Invoice Me</span></a>
            </div>

            <div class="clearfix"></div>

            <!-- menu profile quick info -->
            <div class="profile clearfix">
              <div class="profile_pic">
                <img src="" alt="..." class="img-circle profile_img">
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

                        <div class="navbar-header" style="width:100%; display:flex; align-items:center">
                            <div class="nav toggle" style="padding:5px;">
                                <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                            </div>
                            <label style="font-weight: bold; font-size: 16px;">Settings</label>
                            
                        </div>

                    </nav>
                </div>
            </div>
        <!-- /top navigation -->

        <!-- page content -->
        <div class="right_col" role="main">
          <div class="">
            <%--<div class="page-title">
			
              <div class="title_left">
               <label style="font-weight:bold;font-size:16px;">Settings</label>                    
              </div>--%>
                 
            </div>
		    <div class="clearfix"></div>
          <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>User Type</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
<%--							  <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
						
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content">
          
                    <table id="tblUserType" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
               <thead>
               <tr>
                    <td colspan="2">
                        <div class="col-md-10 col-sm-6 col-xs-6">
                            <input type="text" placeholder="Enter User Type here" class="form-control" id="txtUserTypeName"/>
                        </div>
                         
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtUserTypeName');" type="button">
						Clear
					</button>
                         <span id='spanUserTypeAction'>
                              <div style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addUserType('insert','0');" class="btn btn-warning pull-right">
						Save
					</div>

                          </span> 
                    </td>
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
            <%-- country starts --%>
			<div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>Country</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
							 <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
					
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content">
          
                    <table id="tblCountry" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
                        <thead>
               <tr>
                    <td colspan="2">
                        <div class="col-md-10 col-sm-6 col-xs-6">
                            <input type="text" style="" placeholder="Enter Country here" class="form-control" id="txtCountryName"/>
                           
                        </div>
                        
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtCountryName');" type="button">
						Clear
					</button>
                          <span id='spanCountryAction'><button style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addCountry('insert','0');" class="btn btn-warning pull-right" type="button">
						Save
					</button></span> 
                    </td>
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
             <%-- country ends --%>


            <div class="clearfix"></div>
             <%-- state starts --%>
			<div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>States</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
							 <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
					
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content" style="height: 350px; overflow: scroll; overflow-x: hidden;">
          
                    <table id="tblstatelist" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
                        <thead>
               <tr>
                    <td colspan="2">
                          <div class="col-md-4 col-sm-6 col-xs-8 form-group has-feedback" id="divsearchwarehouse">
                                                <select class="form-control" style="text-indent: 25px;" id="slCountry" onchange="showStateList();"><option value="-1" selected="selected">--Country--</option><option value="1">EKMa</option><option value="2">Aluva</option></select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                        <div class="col-md-6 col-sm-6 col-xs-8">
                            <input type="text" style="" placeholder="Enter State here" class="form-control" id="txtStateName"/>
                           
                        </div>
                      
                        
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtStateName');" type="button">
						Clear
					</button>
                          <span id='spanStateAction'><button style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addState('insert','0');" class="btn btn-warning pull-right" type="button">
						Save
					</button></span> 
                    </td>
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
               <%-- state ends --%>
			
               <div class="clearfix"></div>
             <%-- district starts --%>
			<div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>Districts</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
							 <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
					
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content"  style="height: 350px; overflow: scroll; overflow-x: hidden;">
          
                    <table id="tbldistrictlist" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
                        <thead>
               <tr>
                    <td colspan="2">
                          <div class="col-md-4 col-sm-6 col-xs-8 form-group has-feedback" id="div1">
                                                <select class="form-control" style="text-indent: 25px;" id="slState" onchange="showDistrictList();"></select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                        <div class="col-md-6 col-sm-6 col-xs-8">
                            <input type="text" style="" placeholder="Enter District here" class="form-control" id="txtDistrictName"/>
                           
                        </div>
                      
                        
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtDistrictName');" type="button">
						Clear
					</button>
                          <span id='spanDistrictAction'><button style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addDistrict('insert','0');" class="btn btn-warning pull-right" type="button">
						Save
					</button></span> 
                    </td>
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
               <%-- district ends --%>


            <%-- location starts --%>
            <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>Location</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
<%--							  <li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
						
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content"  style="height: 350px; overflow: scroll; overflow-x: hidden;">
          
                    <table id="tbllocationlist" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
               <thead>
               <tr>
                    <td colspan="2">
                          <div class="col-md-4 col-sm-6 col-xs-8 form-group has-feedback" id="div2">
                                                <select class="form-control" style="text-indent: 25px;" id="selDistrict" onchange="showLocationList();"></select>
                                                <span class="fa fa-map-marker form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                        <div class="col-md-6 col-sm-6 col-xs-8">
                            <input type="text" style="" placeholder="Enter Location here" class="form-control" id="txtLocationName"/>
                           
                        </div>
                      
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtLocationName');" type="button">
						Clear
					</button>
                        <span id='spanLocationAction'>
                              <div style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addLocation('insert','0');" class="btn btn-warning pull-right">
						Save
					</div>

                          </span> 
                    </td>
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
            <%-- location ends --%>












			<div class="clearfix"></div>
              <%-- currency starts --%>
            <div class="row">
              <div class="col-md-12 col-sm-12 col-xs-12">
			  <div class="x_panel">
						  <div class="x_title">
                              <label>Currency</label>
							<ul class="nav navbar-right panel_toolbox">
							  <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
							  </li>
							
							  <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
							  </li>--%>
							</ul>
						
						  </div>
						  
				
							  <div class="clearfix"></div>
						
       
                  <div class="col-md-12 col-sm-12 col-xs-12"  style="overflow-x: auto;">
                  <div class="x_content">
          
                    <table id="tblCurrency" class="table table-striped table-bordered bulk_action" style="table-layout:auto;">
                        <thead>
               <tr>
                    <td colspan="2">
                        <div class="col-md-10 col-sm-6 col-xs-6">
                            <input type="text" style="" placeholder="Enter currency here" class="form-control" id="txtCurrencyName"/>
                       </div>
                        
                        <button style="font-size:11px; padding:4px; font-weight:bold;" class="btn btn-warning pull-right" onclick="javascript:clearSettingsTextbox('txtCurrencyName');" type="button">
						Clear
					</button>
                          <span id='spanCurrencyAction'><button style="font-size:11px; padding:4px; font-weight:bold;" onclick="javascript:addCurrency('insert','0');" class="btn btn-warning pull-right" type="button">
						Save
					</button></span> 
                        
                    </td>
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
             <%-- currency ends --%>
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
  </body>
</html>
