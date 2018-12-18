<%@ Page Language="C#" AutoEventWireup="true" CodeFile="managecustomers.aspx.cs" Inherits="managecustomers" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Manage Customer|Invoice</title>
  <script src="js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="js/jquery.cookie.js"></script>
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
        var cust_id = 0;
        var sessionId = 0;
        var systemSettings= <%=settings%>;
        console.log(systemSettings);
        $(document).ready(function () {
            sessionId = getSessionID();
            if(systemSettings[0].ss_default_max_credit!=0){
                $("#txtcreditamount").val(systemSettings[0].ss_default_max_credit);
            }
            if(systemSettings[0].ss_default_max_period!=0){
                $("#txtcreditperiod").val(systemSettings[0].ss_default_max_period);
            }
            if(systemSettings[0].ss_trn_gst_required==1){
                $("#spanMandTrn").show();
            }
            if(systemSettings[0].ss_reg_id_required==1){
                $("#spanMandReg").show();
            }
            if(systemSettings[0].ss_phone==1){
                $("#spanMandPhone").show();
            }
            if(systemSettings[0].ss_validation_email==1){
                $("#spanMandEmail").show();
            }
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
            $("#btnnew").hide();
            $("#btnNewOrder").hide();

            $("#btnNewBooking").hide();
            $("#btnRedeem").hide();
            $("#btnAddtoWallet").hide();
            $("#btnDebitNote").hide();
            $("#btnOldorderEntry").hide();
            $("#btnBckTo").hide();
            $("#btnBillhistory").hide();
            $("#btnSalesReturn").hide();
            
            $("#btnTransactionhistory").hide();
            
            getCategories();
            //setQueryParams();
            loadwarehouse();

            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " ©");
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
        //start image popup
        $(function () {
            $('.pop').on('click', function () {

                var imgnames = $("#CustimgName").val();
                //alert(imgnames);
                if (imgnames == "") {
                    //$('.imagepreview').attr('src', $(this).find('img').attr('src'));
                    $('#imagemodal').modal('hide');
                    return;
                }


                $('.imagepreview').attr('src', $(this).find('img').attr('src'));
                $('#imagemodal').modal('show');
            });
        });

        //Get Categories
        function getCategories() {
            loading();
            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/getCategories",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Select Category--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.cust_cat_id + '">' + row.cust_cat_name + '</option>';
                    });
                    $("#selCategory").html(htm);
                   // getstates();
                    getCountryNames();
                    //getstates(5);
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        //Get Country names
        function getCountryNames() {
            loading();
            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/getCountryNames",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Select Country--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.country_id + '">' + row.country_name + '</option>';
                    });
                    $("#selCountry").html(htm);
                    $("#selCountry").val($.cookie("invntrystaffCountryId"));
                    getstates();
                   
                    //getstates(5);
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        function getstates(currentVal) {
           
            if (currentVal == "" || currentVal == undefined) {
                currentVal = -1;
              //  alert(currentVal);
            }
            var country = $("#selCountry").val();
            loading();

            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/getstates",
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
                    //getLocations($("#selState").val());
                    Unloading();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        function getLocations(currentVal,state) {
        //    alert(currentVal);
            if (currentVal == "" || currentVal == undefined) {
               // alert("");
                currentVal = -1;
            }
            if (state == undefined) {
                state = $("#selState").val();
            } 
            loading();

            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/getLocations",
                data: "{'state':'" + state + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d);
                    var htm = "";
                    htm += '<option value="-1" selected="selected">--Select Location--</option>';
                    $.each(obj, function (i, row) {
                        htm += '<option value="' + row.location_id + '">' + row.location_name + '</option>';
                    });
                    $("#selLocation").html(htm);
                    $("#selLocation").val(currentVal);
                    //$("#selState").val(currentVal);
                  

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }

        // for querystring
        /*
               function getQueryString(key) {
                    return queryParams[key];
                }
                function setQueryParams() {
                    queryParams = {};
                    var queryStringArray = location.search.replace(/[`~!@#$%^*()|+\?;:'",.<>\{\}\[\]\\\/]/gi, '').split("&");
                    for (var i = 0; i < queryStringArray.length; i++) {
                        queryParams[queryStringArray[i].split("=")[0]] = queryStringArray[i].split("=")[1];
                    }
                }
                //  function to get highlighted text-align
                function getHighlightedValue(searchQuery, value) {
                    var regex = new RegExp('(' + searchQuery + ')', 'gi');
                    var highlightedtext = "<span style='color:#4A2115' >" + searchQuery + "</span>";
                    return value.replace(regex, "<span style='color:#4A2115' >$1</span>");
                }*/
        //end query string

        //Start:TO Replace single quotes with double quotes
        function sqlInjection() {
            $('input, select, textarea').each(
                function (index) {
                    var input = $(this);
                    var type = this.type ? this.type : this.nodeName.toLowerCase();
                    if (type == "text" || type == "textarea") {
                        $("#" + input.attr('id')).val(input.val().replace(/'/g, '"'));
                    }
                    else {
                    }
                }
            );
        }
        //Stop:TO Replace single quotes with double quotes





        //load the warehouse 24-03-2017
        function loadwarehouse() {

            loading();

            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/loadwarehouse",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var obj = JSON.parse(msg.d)
                    Unloading();
                    var htm = "";
                    htm += "<option value='0' selected='selected'>Select</option>";
                    $.each(obj.data, function (i, row) {
                        htm += "<option value='" + row.id + "'>" + row.name + "</option>";

                    });
                    $("#selwarehouse").html(htm);
                    $("#selwarehouse").val('1');
                    cust_id = getQueryString('cusId');

                    if (typeof cust_id != 'undefined') {
                        $("#divIdentity").show();
                        editcustomerdetail(cust_id);
                    }
                    else {
                        $("#divBasic").removeClass();
                        $("#divBasic").addClass("col-md-12 col-sm-12 col-xs-12");
                        $("#divIdentity").hide();
                        $("#menutitle_customer").hide();
                        $("#menutitle_orderhistory").hide();
                        $("#divNewBtn").hide();
                    }

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }//end warehouse load

        //start Save customer details 24-03-2017
        function AddCustomer(actionType, CustomerId) {
            sqlInjection();
            //alert(actionType);
            var customertype = $.trim($("#combopricegroupdiv").val());
            if (customertype == "" || customertype == "0") {
                alert("Please Select Customer type...!");
                return;
            }
            var creditamount = parseFloat($("#txtcreditamount").val());
            var creditperiod = parseFloat($("#txtcreditperiod").val());
            //var warehouse = $("#selwarehouse").val();
            //if (warehouse == "0") {
            //    alert("Please Choose Warehouse");
            //    return;
            //}

            var customerName = $.trim($("#txtCustomerName").val());
            if (customerName == "") {
                alert("Please Enter CustomerName...!");
                return;
            }
            var trnNo = $.trim($("#txtTrnNo").val());
            var Address = $("#txtAddress").val();
            var country = $('#selCountry').val();
            var place = $("#txtCity").val();
            var category = $("#selCategory").val();
            if (country == "" || country == "-1") {
                alert("Please select Country");
                return;
            }
            var State = $('#selState').val();
            if (State == "" || State == "-1") {
                alert("Please select State");
                return;
            }
            var City = $("#selLocation").val();
            if (City == "" || City == "-1") {
                alert("Please select Location");
                return;
            }
            var email = $.trim($("#txtemail").val());
            var Phone1 = $("#txtPhone").val();
            if(systemSettings[0].ss_phone==1){
                if (Phone1 == 0) {
                    alert("Please Enter Phone number...!");
                    return;
                }
                if (isNaN($("#txtPhone").val())) {
                    alert("Phone number should be in number only");
                    $("#txtPhone").focus();
                    return;
                }
            }

            if(systemSettings[0].ss_validation_email==1){
                if (email == "") {
                    alert("Please Enter Email...!");
                    return;
                }
            }


            if(systemSettings[0].ss_trn_gst_required==1){
                if (trnNo == "") {
                    alert("Please Enter TRN No...!");
                    return;
                }
            }
            if(systemSettings[0].ss_reg_id_required==1){
                if ($("#txtRegId").val() == "") {
                    alert("Please Enter Registration No...!");
                    return;
                }
            }
          
           
            
           
            if (category == -1) {
                alert("Please choose any category");
                return;
            }
            var phone2 = $("#txtphonetwo").val();
            var outstanding = $("#txtoutstanding").val();
            var note = $("#txtareanote").val();

            var userid = $.cookie("invntrystaffId");
            var userType = $.cookie("invntrystaffTypeID");
            var status = 0;
            loading();
            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/AddCustomer",
                data: "{'actionType':'" + actionType + "','CustomerId':'" + CustomerId + "','CustomerName':'" + customerName + "','CustomerType':'" + customertype + "','Address':'" + Address + "','City':'" + City + "','State':'" + State + "','Phone':'" + Phone1 + "','PhoneOne':'" + phone2 + "','Email':'" + email + "','country':'" + country + "','note':'" + note + "','creditamount':'" + creditamount + "','creditperiod':'" + creditperiod + "','userid':'" + userid + "','status':'" + status + "','userType':'" + userType + "','trnNo':'" + trnNo + "','regId':'" + $("#txtRegId").val() + "','place':'" + $("#txtCity").val() + "','category':'" + $("#selCategory").val() + "','sessionId':'" + sessionId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                      //alert(msg.d);
                    Unloading();
                    if (msg.d == "E") {
                        alert("Please check your registration number. This is already existing");
                    }
                    if (msg.d == "Y") {

                        if (actionType == "insert") {
                            alert("Customer added successfully");
                        }
                        if (actionType == "update") {
                            alert("Customer details updated successfully");
                        }
                        window.location = 'customers.aspx';
                        return;

                    } 
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }//end Save
        // start the backbutton

        function clearall() {

            // window.location.href = "managecustomers.aspx";
            $("#btnnew").hide();
            $("#btnBckTo").hide();
            $("#btnNewOrder").hide();
            $("#btnNewBooking").hide();
            $("#btnRedeem").hide();
            $("#btnOldorderEntry").hide();
            $("#btnAddtoWallet").hide();
            $("#btnDebitNote").hide();
            $("#btnBillhistory").hide();
            $("#btnSalesReturn").hide();
            $("#btnTransactionhistory").hide();


            //  $("#txtcustomerid").text('');
            $("#lblwalletamt").text(0);
            $("#lbloutstanding").text(0);
            $("#combopricegroupdiv").val(0);
            $("#txtcreditamount").val('0');
            $("#txtcreditperiod").val('0');
            $("#selwarehouse").val(0);
            $("#txtCustomerName").val('');
            $("#txtTrnNo").val('');
            $("#txtAddress").val('');
            $("#txtlocation").val('');
            $("#txtstate").val('');
            $("#selCountry").val(-1);
            $("#selState").val(-1);
            $("#txtemail").val('');
            $("#txtPhone").val('0');
            $("#txtphonetwo").val('0');
            $("#txtoutstand").val('0');
            $("#txtareanote").val('');

            // $("#btnMemberAction").html("<div class='btn btn-success mybtnstyl' onclick=javascript:AddCustomer('insert',0);>SAVE</div>");

            window.location.href = "managecustomers.aspx";


        }

        function backpage() {
            parent.history.back();
            return false;
        }



        //start update customer details
        function editcustomerdetail(id) {
            sqlInjection();

            //  alert(cust_id);
            loading();
            $.ajax({
                type: "POST",
                url: "managecustomers.aspx/editcustomerdetail",
                data: "{'cust_id':'" + id + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    Unloading();
                    if (msg.d != 0) {
                        var obj = JSON.parse(msg.d);
                        var splitarray = msg.d.split("@#$");
                        $("#btnMemberAction").html("<div class='btn btn-success mybtnstyl' onclick=javascript:AddCustomer('update','" + id + "');>UPDATE</div>");
                        //$("#btnMemberAction").html("<button type='button' class='btn btn-success' onclick='javascript:AddCustomer('update',' + cust_id + ');'">Update</button>);


                        // $("#custidProfiled").text(obj[0].cust_id);      
                        $("#txtcustomerid").text(obj[0].cust_reg_id);
                        $("#txtRegId").val(obj[0].cust_reg_id);
                        $("#txtCustomerName").val(obj[0].cust_name);
                        $("#txtTrnNo").val(obj[0].cust_tax_reg_id);
                        $("#txtAddress").val(obj[0].cust_address);
                        $("#txtCity").val(obj[0].cust_city);
                      //  $("#txtCity").val(obj[0].cust_city);
                      //  alert($.trim(obj[0].cust_phone));
                       
                        $("#txtPhone").val(obj[0].cust_phone.split(" ").join(""));
                        $("#txtphonetwo").val(obj[0].cust_phone1.split(" ").join(""));
                        $("#txtemail").val(obj[0].cust_email);
                        $("#selCountry").val(obj[0].cust_country);
                    //    $("#selState").val(obj[0].cust_state);
                        getstates(obj[0].cust_state);
                        getLocations(obj[0].location_id, obj[0].cust_state);
               
                       
                    //    console.log(obj[0].cust_note);
                        $("#txtareanote").val(obj[0].cust_note);
                        if (obj[0].cust_amount == null || obj[0].cust_amount == "") {
                            obj[0].cust_amount = 0;
                        }
                        $("#lbloutstanding").text(obj[0].cust_amount);
                        $("#lbloutstanding").text(obj[0].cust_amount);
                        // alert(obj[0].cust_amount);
                        if (obj[0].cust_amount > 0) {
                            $("#lbloutstanding").css("color", "red");
                        } else {
                            $("#lbloutstanding").css("color", "green");
                        }
                        $("#txtoutstand").val(obj[0].cust_amount);
                     //   $("#selwarehouse").val(obj[0].branch_id);
                       // $("#lblwalletamt").text(obj[0].cust_wallet_amt);
                        if (obj[0].new_custtype != 0 && (obj[0].new_custtype != obj[0].cust_type)) {
                            $("#spancustType").html("Changed From <label style='color: blue;'> " + $("#combopricegroupdiv option[value='" + obj[0].cust_type + "']").text() + "</label> To <label id='Label4' style='color: blue;'> " + $("#combopricegroupdiv option[value='" + obj[0].new_custtype + "']").text() + "</label>");
                            $("#combopricegroupdiv").val(obj[0].new_custtype);
                        } else {
                            $("#spancustType").text("");
                            $("#combopricegroupdiv").val(obj[0].cust_type);
                        }
                        if (obj[0].new_creditamt != 0 && (obj[0].new_creditamt != obj[0].max_creditamt)) {
                            $("#spancreditamt").html("Changed From <label style='color: blue;'> " + obj[0].max_creditamt + "</label> To <label id='Label4' style='color: blue;'> " + obj[0].new_creditamt + "</label>");
                            $("#txtcreditamount").val(obj[0].new_creditamt);
                        } else {
                            $("#spancreditamt").text("");
                            $("#txtcreditamount").val(obj[0].max_creditamt);
                        }
                        if (obj[0].new_creditperiod != 0 && (obj[0].new_creditperiod != obj[0].max_creditperiod)) {
                            $("#spancreditperiod").html("Changed From <label style='color: blue;'> " + obj[0].max_creditperiod + "</label> To <label id='Label4' style='color: blue;'> " + obj[0].new_creditperiod + "</label>");
                            $("#txtcreditperiod").val(obj[0].new_creditperiod);
                        } else {
                            $("#spancreditperiod").text("");
                            $("#txtcreditperiod").val(obj[0].max_creditperiod);
                        }

                        //  alert(obj[0].assignedname);
                        if (obj[0].assignedname != null) {

                            $("#lblassignedto").text(obj[0].assignedname);

                        }


                        if (obj[0].cust_image != "0") {
                            var imageUpdate = document.getElementById('imgCustPhoto');
                            $("#CustimgName").val(obj[0].cust_image);
                            imageUpdate.src = "/custimage/" + obj[0].cust_image;
                            imgpopup.src = "/custimage/" + obj[0].cust_image;

                            // imageUpdate.src = "custimage/" + obj[0].cust_image + ".jpg";
                            // imgpopup.src = "custimage/" + obj[0].cust_image + ".jpg";
                        }
                        else {
                            //imageUpdate.src = "/custimage/defaultUser.jpg";
                            $("#CustimgName").val(0);
                        }
                        $("#selCategory").val(obj[0].cust_cat_id);
                        $("#btnnew").show();
                        $("#btnBckTo").show();
                        $("#btnNewOrder").show();
                        $("#btnNewBooking").show();
                        $("#btnRedeem").show();
                        $("#btnOldorderEntry").show();
                        $("#btnAddtoWallet").show();
                        $("#btnDebitNote").show();
                        $("#btnBillhistory").show();
                        $("#btnSalesReturn").show();
                        $("#btnTransactionhistory").show();
                        $("#findMember").hide();
                        return;
                    }
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });

        }


        function gotoOldorderEntry() {
            var customerid = cust_id;
            // alert(customerid);
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "sales/oldorderentry.aspx?customerid=" + customerid;

        }

        function gotoBillHistory() {
            var customerid = cust_id;
            // alert(customerid);
            //  customername = customername.trim().replace(/ /g, '%20');
            //alert(customername);
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "sales/orders.aspx?customerid=" + customerid;

        }

        function gotoOldSalesReturn() {
            var customerid = cust_id;
            //alert(customerid);
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "sales/oldsalesreturn.aspx?customerid=" + customerid;
        }


        function gotoneworder() {
            var customerid = cust_id;
            //alert(customerid);
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            else {
                location.href = "sales/neworder.aspx?custId=" + customerid;
                return;

            }
        }


        function gotoNewBooking() {
            var customerid = cust_id;
            //alert(customerid);
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            else {
                location.href = "newBooking.aspx?custId=" + customerid;
                return;

            }
        }





        function gotoTransactionHistory() {
            var customerid = cust_id;
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "transactionHistory.aspx?customerid=" + customerid;
        }

        function gotoDebitEntry() {
            var customerid = cust_id;
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "addDebitEntry.aspx?customerid=" + customerid;
        }

        function gotoRedeemPackage() {
            var customerid = cust_id;
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "redeemPackage.aspx?customerid=" + customerid;
        }
        function gotoSalesReturn() {
            var customerid = cust_id;
            if (customerid == "") {
                alert("Select Customer");
                return false;
            }
            location.href = "sales/salesreturn.aspx?customerid=" + customerid;
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
                            <a href="dashboard.aspx" class="site_title">
                                <!--<i class="fa fa-paw"></i> -->
                                <span>Invoice Me</span></a>
                        </div>

                        <div class="clearfix"></div>

                        <!-- menu profile quick info -->
                        <div class="profile clearfix">
                            <div class="profile_pic">
                                <img src="../images/img.jpg" alt="..." class="img-circle profile_img">
                            </div>
                            <div class="profile_info">
                                <span>Registration ID</span>
                                <h2>
                                    <label id="custidProfiled"></label>
                                </h2>
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
                                <label style="font-weight: bold; font-size: 16px;">Customer</label></div>
                                <div class="col-md-6 col-xs-6">
                                <label onclick="javascript:clearall();" class="btn btn-success btn-xs pull-right" style="background-color:#d86612; border-color:#d86612;"><label style="color: #fff; font-size: 14px;" class="fa fa-plus-square" title="Add New Customer"></label></label>
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
                            <%--  <div class="title_left">

                                <label style="font-size: 16px; font-weight: bold;">New Customer</label>
                            </div>--%>
                            <%--<button class="fa fa-backward pull-right"></button>--%>
                            <div id="divNewBtn" style="display: ;">
                                <button type="button" class="btn btn-success pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:backpage();" id="btnBckTo">
                                    <label class="fa fa-arrow-left"></label>
                                </button>

                               
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoOldSalesReturn();" id="btnAddtoWallet">
                                   <label class="fa fa-plus-square"></label>  Credit Note
                                </button>
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoDebitEntry();" id="btnDebitNote">
                                   <label class="fa fa-plus-square"></label>  Debit Note
                                </button>
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoOldorderEntry();" id="btnOldorderEntry">
                                   <label class="fa fa-plus-square"></label> Old Entry
                                </button>
                                 
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoBillHistory();" id="btnBillhistory">
                                    Bill History
                                </button>
                                  <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoTransactionHistory();" id="btnTransactionhistory">
                                    Transaction History
                                </button>
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoneworder();" id="btnNewOrder">
                                   New Bill
                                </button>

                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoSalesReturn();" id="btnSalesReturn">
                                   Sale Return
                                </button>
                           
                            <%--    <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoNewBooking();" id="btnNewBooking">
                                  New Booking
                                </button>--%>
                                
                                <button type="button" class="btn btn-primary pull-right" style="font-size: 11px; padding: 4px; font-weight: bold; display: none;" onclick="javascript:gotoRedeemPackage();" id="btnRedeem">
                                  <label class="fa fa-gift"></label> Redeem Package
                                </button>
                           </div>

                        </div>
                        <div class="row" style="display: none;">
                            <div class="col-md-6 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Basic Information</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--  <li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>
                                    </div>
                                    <div class="x_content">
                                        <form id="Form4" data-parsley-validate="" class="form-horizontal form-label-left" novalidate="">

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Type<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control">
                                                        <option>Choose option</option>
                                                        <option>Option one</option>
                                                        <option>Option two</option>
                                                        <option>Option three</option>
                                                        <option>Option four</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Credit Amount<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="Text8" class="form-control col-md-7 col-xs-12" type="text" name="middle-name">
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Credit Period<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="Text9" class="form-control col-md-7 col-xs-12" type="text" name="middle-name">
                                                </div>
                                            </div>

                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                        <div class="row">
                            <div class="col-md-6 col-sm-12 col-xs-12" style="display:none;" id="divIdentity">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Identity Information</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>
                                    </div>
                                    <div class="x_content">

                                        <form id="demo-form2" data-parsley-validate="" class="form-horizontal form-label-left" novalidate="">


                                            <%--    <div class="col-md-4 col-sm-12 col-xs-4">
                                                 <img src="images/defaultUser.jpg" width="100" height="100" id="imgCustPhoto" />
                                            </div>--%>


                                            <%--image popup my code 24-04-2017 --%>
                                            <input type="hidden" id="CustimgName" />
                                            <div class="col-md-2 col-sm-12 col-xs-4" style="padding-left: 0px;">
                                                <img src="images/defaultUser.jpg" width="80" height="85" class="pop" id="imgCustPhoto" style="margin-top: 5px;" />
                                            </div>

                                            <div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                                                <div class="modal-dialog">
                                                    <div class="modal-content">
                                                        <div class="modal-body">
                                                            <label id="imgname" class="pull-left"></label>
                                                            <%--  <a class="close-link pull-right"><i class="fa fa-close" ></i></a>--%>
                                                            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                                            <img class="imagepreview" style="width: 100%;" id="imgpopup" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>




                                            <%--image popup my code 24-04-2017 --%>





                                            <div class="col-md-8 col-sm-12 col-xs-8" style="margin-top: 5px; margin-bottom: 12px;">
                                                <div class="form-group" style="margin-bottom: 2px;">
                                                    <label class="control-label col-md-6 col-sm-3 col-xs-8">
                                                        Customer ID	
                                                    </label>
                                                    <div class="col-md-6 col-sm-6 col-xs-4">
                                                        #
                                                    <label id="txtcustomerid"></label>
                                                        <%--<input type="text" class="form-control"  disabled />--%>
                                                    </div>
                                                </div>


                                                <div class="form-group" style="margin-bottom: 2px;">
                                                    <label class="control-label col-md-6 col-sm-3 col-xs-8">
                                                        Account Balance	
                                                    </label>
                                                    <div class="col-md-6 col-sm-6 col-xs-4">
                                                        <label style="color: red; font-weight: bold;" id="lbloutstanding">0</label>
                                                    </div>
                                                </div>


                                                <%--new edit done on(28-04-17)  --%>
                                                <div class="form-group" style="margin-bottom: 2px;">
                                                    <label class="control-label col-md-6 col-sm-3 col-xs-8">
                                                        Assigned To
                                                    </label>
                                                    <div class="col-md-6 col-sm-6 col-xs-4">
                                                        <label style="font-size: 14px; font-weight: bold;" id="lblassignedto"></label>
                                                    </div>
                                                </div>
                                                <%--new edit done on(28-04-17)  --%>
                                            </div>

                                        </form>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-sm-12 col-xs-12" id="divBasic">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Basic Information</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>
                                    </div>
                                    <div class="x_content">

                                        <form id="Form5" data-parsley-validate="" class="form-horizontal form-label-left" novalidate="">

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Type<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="combopricegroupdiv">
                                                        <option value="0">Select</option>
                                                        <option value="1" selected>Class A</option>
                                                        <option value="2">Class B</option>
                                                        <option value="3">Class C</option>
                                                    </select>
                                                </div>

                                                <span id="spancustType" class="">
                                                                            
                                                </span>
                                                
                                            </div>

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Credit Amount
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtcreditamount" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" value="0" style="padding-right: 1px;" />
                                                </div>
                                                  <span id="spancreditamt" class="">
                                                                            
                                                </span>
                                            </div>

                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Credit Period
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtcreditperiod" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" value="0" style="padding-right: 1px;" />
                                                </div>
                                                 <span id="spancreditperiod" class="">
                                                                            
                                                </span>
                                            </div>

                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Personal Information </strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%--<li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>

                                    </div>
                                    <div class="x_content">
                                        <form id="Form2" data-parsley-validate class="form-horizontal form-label-left">

                                       <%--     <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Warehouse<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selwarehouse">
                                                        <option name="select" value="0"></option>
                                                    </select>
                                                </div>
                                            </div>--%>
                                             <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Name <span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input type="text" id="txtCustomerName" required="required" class="form-control col-md-7 col-xs-12" />
                                                </div>
                                            </div>
                                             <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Country<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selCountry" onchange="getstates();">
                                                        <option value="0">Select</option>
                                                        <option value="1">INDIA</option>
                                                        <option value="2">UAE</option>
                                                    </select>
                                                </div>
                                            </div>
                                         
                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                    State<span class="required">*</span>
                                                </label>
                                                 <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selState"  onchange="getLocations()">
                                                    </select>
                                                </div>
                                            </div>
                                             <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Location <span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selLocation">
                                                    </select>
                                                </div>
                                            </div>
                                              <div class="form-group">
                                                <label for="city" class="control-label col-md-3 col-sm-3 col-xs-12">City</label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtCity" class="form-control col-md-7 col-xs-12" type="text" name="city" style="padding-right: 1px;" />
                                                </div>
                                            </div>
                                             <div class="form-group">
                                                <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Phone1<span class="required" id="spanMandPhone" style="display:none;">*</span></label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtPhone" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" style="padding-right: 1px;" />
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Phone2</label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtphonetwo" class="form-control col-md-7 col-xs-12" type="number" name="middle-name" style="padding-right: 1px;" />
                                                </div>
                                            </div>
                                           
                                           
                                         
                                            <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="last-name">
                                                    Address<span class="required"></span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input type="text" id="txtAddress" name="last-name" required="required" class="form-control col-md-7 col-xs-12" />
                                                </div>
                                            </div>
                                            
                                             
                                            <div class="form-group">
                                                <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Email<span class="required" id="spanMandEmail" style="display:none;">*</span></label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtemail" class="form-control col-md-7 col-xs-12" type="text" name="middle-name" />
                                                </div>
                                            </div>
                                           
                                          <%--  <div class="form-group">
                                                <label for="middle-name" class="control-label col-md-3 col-sm-3 col-xs-12">Outstanding</label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input id="txtoutstand" class="form-control col-md-7 col-xs-12" type="text" name="middle-name" disabled value="0" />
                                                </div>
                                            </div>--%>
                                               <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="reg-number">
                                                    TRN/GST<span class="required" id="spanMandTrn" style="display:none;">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input type="text" id="txtTrnNo" required="required" class="form-control col-md-7 col-xs-12"/>
                                                </div>
                                            </div>
                                             <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Registration ID<span class="required" id="spanMandReg" style="display:none;">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <input type="text" id="txtRegId" required="required" class="form-control col-md-7 col-xs-12" />
                                                </div>
                                            </div>
                                                  <div class="form-group">
                                                <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">
                                                    Category<span class="required">*</span>
                                                </label>
                                                <div class="col-md-6 col-sm-6 col-xs-12">
                                                    <select class="form-control" id="selCategory">
                                                        
                                                    </select>
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
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Note History</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>

                                            <%-- <li><a class="close-link"><i class="fa fa-close"></i></a>
                                            </li>--%>
                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <form id="Form3" data-parsley-validate class="form-horizontal form-label-left">
                                            <div class="">
                                                <textarea id="txtareanote" class="form-control" rows="3" placeholder="" style="margin: 0px -0.375px 0px 0px; width: 100%; height: 109px; resize: none"></textarea>
                                            </div>
                                            <div class="ln_solid"></div>
                                            <div class="form-group" style="padding-bottom: 40px;">
                                                <div class="col-md-6 col-sm-6 col-xs-12 col-md-offset-4 col-xs-offset-1">

                                                    <div class="" id="btnMemberAction">
                                                        <div class="btn btn-success mybtnstyl" onclick="javascript:AddCustomer('insert',0);">SAVE</div>
                                                    </div>

                                                    <div class="btn btn-danger mybtnstyl" onclick="javascript:clearall();">CANCEL</div>

                                                    <!--  <button class="btn btn-primary" type="reset">Reset</button>-->

                                                </div>

                                            </div>
                                        </form>
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
