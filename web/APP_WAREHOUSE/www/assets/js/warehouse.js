/* offline testing - put { serverOn = "No" } */
var serverOn = "Yes";
//var serverOn = "No";
var test_mode = 0; // 0 for off , 1 for on
var lowaccuval = "No";
//var lowaccuval = "Yes"

var getServerURL = "";
var imgurl = "";

var imageURIN;
var imageYes = "0";
var Latitude = 0;
var Longitude = 0;
var androidkey = 0;
var device_id = 0;
var uniloctype = 0;
var unipopup = 0;
var current_session_id = 0;
var backcount = 0;
var processeditems = "";

var backKeyStatus = 1; // 1 - enabled , 0 -disabled

if (serverOn == "Yes") {

    getServerURL = " http://jh.billcrm.com/app_Warehouse.aspx";
    imgurl = " http://jh.billcrm.com/custimage/";
    Latitude = 0;
    Longitude = 0;
    androidkey = 0;
    imageYes = "0";
}
else {

    getServerURL = "http://localhost:2827/app_Warehouse.aspx";
    imgurl = " http://jh.billcrm.com/custimage/";
    Latitude = 1.1;
    Longitude = 1.1;
    androidkey = 111;
    imageYes = "1";
    onDeviceReady();
}

// Handle Back key enable/ disable while Ajax calls

function enableBackKey() { backKeyStatus = 1; }
function disableBackKey() { backKeyStatus = 0; }
function getUrl() { return getServerURL; }
function getUrlimage() { return imgurl; }

$(document).ready(function () {
    // to close sidebar on body click
    $(".btnhandle").click(function () {
        $(".navbar-toggle").click();
    });    
    initDomEvents();
});

// prevents multiple pop-ups
var ispopupshown = 0;
function popuploaded() { ispopupshown = 1; }
function popupClosed() { ispopupshown = 0; }

// sqlite db 
function getDB() {return openDatabase('Invoice_Me_Warehouse_new.db', '2.0', 'web database', 5 * 1024 * 1024);}
var pageStack = new Array();

var app = {
    
    initialize: function () {
        document.addEventListener('deviceready',
this.onDeviceReady.bind(this), false);
    },

    onDeviceReady: function () {
        this.receivedEvent('deviceready');
    },
   
    receivedEvent: function (id) {

        var push = PushNotification.init({
            android: {
                senderID: "994295211327"
            },
            browser: {
                pushServiceURL: 'http://push.api.phonegap.com/v1/push'
            },
            ios: {
                alert: "true",
                badge: "true",
                sound: "true"
            },
            windows: {}
        });

        push.on('registration', function (data) {
            androidkey = data.registrationId;
        });

        push.on('notification', function (data) {
            alert(data.message);
            // data.title,
            // data.count,
            // data.sound,
            // data.image,
            // data.additionalData
        });

        push.on('error', function (e) {
            //alert(e.message + "error");
        });

        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
        console.log('Received Event: ' + id);
    }

};
app.initialize();

// local db - table creations -loading necessary values at startup
function onDeviceReady() {

    getIMEI();
    var db = getDB();
    db.transaction(function (tx) {
        
        //tx.executeSql("DROP TABLE tbl_appuser");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_appuser (user_id VARCHAR NOT NULL,name VARCHAR NOT NULL,password VARCHAR NOT NULL,imei VARCHAR NOT NULL,db_last_updated_date)", [], function (tx, res) {

        });

        //tx.executeSql("DROP TABLE tbl_system_settings");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_system_settings (ss_price_change VARCHAR NOT NULL, ss_discount_change VARCHAR NOT NULL, ss_foc_change VARCHAR NOT NULL, ss_class_change VARCHAR NOT NULL, ss_max_period_credit VARCHAR NOT NULL, ss_new_registration VARCHAR NOT NULL, ss_sales_return VARCHAR NOT NULL, ss_due_amount VARCHAR NOT NULL, ss_new_item VARCHAR NOT NULL, ss_location_on_order VARCHAR NOT NULL, ss_validation_email VARCHAR NOT NULL, ss_phone VARCHAR NOT NULL,ss_direct_delivery VARCHAR NOT NULL,ss_currency VARCHAR NOT NULL, ss_decimal_accuracy VARCHAR NOT NULL, ss_multidevice_block VARCHAR NOT NULL,ss_van_based_invoice_number VARCHAR NOT NULL,ss_default_time_zone VARCHAR NOT NULL,ss_default_max_period VARCHAR NOT NULL,ss_default_max_credit VARCHAR NOT NULL,ss_reg_id_required VARCHAR NOT NULL,ss_trn_gst_required VARCHAR NOT NULL,ss_payment_type VARCHAR NOT NULL,ss_last_updated_date VARCHAR NOT NULL)", [], function (tx, res) {

        });
           
        //tx.executeSql("DROP TABLE tbl_itembranch_stock");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_itembranch_stock (itm_type VARCHAR NOT NULL  ,brand_name VARCHAR NOT NULL  ,cat_name VARCHAR NOT NULL  ,branch_id VARCHAR NOT NULL  ,tp_tax_percentage VARCHAR NOT NULL  ,tp_cess VARCHAR NOT NULL  ,itbs_id VARCHAR NOT NULL  ,itm_id VARCHAR NOT NULL  ,itm_brand_id VARCHAR NOT NULL  ,itm_category_id VARCHAR NOT NULL  ,itm_name VARCHAR NOT NULL  ,itbs_stock VARCHAR NOT NULL  ,itm_code VARCHAR NOT NULL  ,itm_mrp VARCHAR NOT NULL  ,itm_class_one VARCHAR NOT NULL  ,itm_class_two VARCHAR NOT NULL  ,itm_class_three VARCHAR NOT NULL  ,itm_commision VARCHAR NOT NULL, itm_rating VARCHAR NOT NULL )", [], function (tx, res) {

        });

        //tx.executeSql("DROP TABLE tbl_location");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_location (location_id VARCHAR NOT NULL , location_name VARCHAR NOT NULL, state_id VARCHAR NOT NULL, state_name VARCHAR NOT NULL, country_id VARCHAR NOT NULL)", [], function (tx, res) {

        });

        //tx.executeSql("DROP TABLE tbl_branch");hh
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_branch (branch_id VARCHAR NOT NULL , branch_name VARCHAR NOT NULL, branch_timezone VARCHAR NOT NULL, branch_tax_method VARCHAR NOT NULL, branch_tax_inclusive VARCHAR NOT NULL)", [], function (tx, res) {

        });
       
        //tx.executeSql("DROP TABLE tbl_item_cart");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_item_cart (itbs_id VARCHAR NOT NULL,itm_code VARCHAR NOT NULL,itm_name VARCHAR NOT NULL,si_org_price VARCHAR NOT NULL,si_price VARCHAR NOT NULL,si_qty VARCHAR NOT NULL,si_total VARCHAR NOT NULL,si_discount_rate VARCHAR NOT NULL,si_discount_amount VARCHAR NOT NULL,si_net_amount VARCHAR NOT NULL,si_foc VARCHAR NOT NULL,si_approval_status VARCHAR NOT NULL,itm_commision VARCHAR NOT NULL,itm_commisionamt VARCHAR NOT NULL,si_itm_type VARCHAR NOT NULL,si_item_tax VARCHAR NOT NULL,si_item_cess VARCHAR NOT NULL,si_tax_excluded_total VARCHAR NOT NULL,si_tax_amount VARCHAR NOT NULL,itm_type VARCHAR NOT NULL,itbs_stock VARCHAR NOT NULL,brand_name VARCHAR NOT NULL)", [], function (tx, res) {

        });

        //tx.executeSql("DROP TABLE tbl_item_cart");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_edit_cart (itbs_id VARCHAR NOT NULL,itm_code VARCHAR NOT NULL,itm_name VARCHAR NOT NULL,si_org_price VARCHAR NOT NULL,si_price VARCHAR NOT NULL,si_qty VARCHAR NOT NULL,si_total VARCHAR NOT NULL,si_discount_rate VARCHAR NOT NULL,si_discount_amount VARCHAR NOT NULL,si_net_amount VARCHAR NOT NULL,si_foc VARCHAR NOT NULL,si_approval_status VARCHAR NOT NULL,itm_commision VARCHAR NOT NULL,itm_commisionamt VARCHAR NOT NULL,si_itm_type VARCHAR NOT NULL,si_item_tax VARCHAR NOT NULL,si_item_cess VARCHAR NOT NULL,si_tax_excluded_total VARCHAR NOT NULL,si_tax_amount VARCHAR NOT NULL,itm_type VARCHAR NOT NULL,itbs_stock VARCHAR NOT NULL,brand_name VARCHAR NOT NULL)", [], function (tx, res) {

        });

        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_return_cart (sm_id VARCHAR NOT NULL,itbs_id VARCHAR NOT NULL,itm_code VARCHAR NOT NULL,itm_name VARCHAR NOT NULL,si_price VARCHAR NOT NULL,si_discount_rate VARCHAR NOT NULL,sri_qty VARCHAR NOT NULL,sri_total VARCHAR NOT NULL,sri_type VARCHAR NOT NULL)", [], function (tx, res) {

        });

       
                
        var selectUser = "select * from tbl_appuser";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;

            if (len > 0) {

                $("#appuserid").val(res.rows.item(0).user_id);
                $("#ss_user_password").val(res.rows.item(0).password);
                $("#ss_user_deviceid").val(res.rows.item(0).imei);
                $("#db_last_updated_date").val(res.rows.item(0).db_last_updated_date);
                $("#loginval").val('1'); 
                showpage('homepage');
                fetch_app_settings();
            }
            else {

                $("#divlogin").show();
                if (serverOn == "Yes") {
                    getAndroidId();
                    getIMEI();
                }
                
            }

        });


    }, function (e) {
        alert("ERROR: " + e.message);
    });
 
   

}

// reading app setting on startup
function fetch_app_settings() {

    var db = getDB();
    db.transaction(function (tx) {

        
        var selectUser = "select * from tbl_system_settings";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;

            if (len > 0) {

                $("#ss_price_change").val(res.rows.item(0).ss_price_change);
                $("#ss_discount_change").val(res.rows.item(0).ss_discount_change);
                $("#ss_foc_change").val(res.rows.item(0).ss_foc_change);
                $("#ss_class_change").val(res.rows.item(0).ss_class_change);
                $("#ss_max_period_credit").val(res.rows.item(0).ss_max_period_credit);
                $("#ss_new_registration").val(res.rows.item(0).ss_new_registration);
                $("#ss_sales_return").val(res.rows.item(0).ss_sales_return);
                $("#ss_due_amount").val(res.rows.item(0).ss_due_amount);
                $("#ss_new_item").val(res.rows.item(0).ss_new_item);
                $("#ss_location_on_order").val(res.rows.item(0).ss_location_on_order);
                $("#ss_validation_email").val(res.rows.item(0).ss_validation_email);
                $("#ss_phone_email").val(res.rows.item(0).ss_phone);
                $("#ss_currency").val(res.rows.item(0).ss_currency);
                $("#ss_decimal_accuracy").val(res.rows.item(0).ss_decimal_accuracy);
                $("#ss_multidevice_block").val(res.rows.item(0).ss_multidevice_block);
                $("#ss_default_time_zone").val(res.rows.item(0).ss_default_time_zone);
                $("#ss_default_max_period").val(res.rows.item(0).ss_default_max_period);
                $("#ss_default_max_credit").val(res.rows.item(0).ss_default_max_credit);
                $("#ss_trn_gst_required").val(res.rows.item(0).ss_trn_gst_required);
                $("#ss_reg_id_required").val(res.rows.item(0).ss_reg_id_required);
                $("#ss_payment_type").val(res.rows.item(0).ss_payment_type);
                $("#ss_direct_delivery").val(res.rows.item(0).ss_direct_delivery);               
                
            }
            else {

                
            }

        });


    }, function (e) {
        alert("ERROR: " + e.message);
    });
}

// loading accessible vranch details to combo box in customer page
function fetch_branch_to_combo() {

    var htm = "";
    var db = getDB();
    db.transaction(function (tx) {


        var selectUser = "select branch_id,branch_name from tbl_branch";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;

            if (len > 0) {

                if (len > 1) {
                    htm = htm + '<option value="0" selected>SELECT BRANCH / WAREHOUSE</option>';
                }
                for (var i = 0; i < len; i++) {
                    htm = htm + '<option value="' + String(res.rows.item(i).branch_id) + '">' + String(res.rows.item(i).branch_name) + '</option>';
                }
                $("#Select_Access_Branch").html(htm);
                if (len == 1) { fetch_branch_details(); }
            }
            else {

                htm = htm + '<option value="0" selected>NO BRANCH / WAREHOUSE AVAILABLE</option>';
            }

        });


    }, function (e) {
        alert("ERROR: " + e.message);
    });
}

// loading branch deatails - tax values etc on change
function fetch_branch_details() {

    if ($("#Select_Access_Branch").val() != 0) {
        var db = getDB();
        db.transaction(function (tx) {

            var selectbranch_info = "select * from tbl_branch where branch_id='"+ $("#Select_Access_Branch").val() + "'";
            tx.executeSql(selectbranch_info, [], function (tx, res) {
                var len = res.rows.length;

                if (len > 0) {

                    $("#br_tax_method").val(res.rows.item(0).branch_tax_method);
                    $("#br_time_zone").val(res.rows.item(0).branch_timezone);
                    $("#br_tax_inclusive").val(res.rows.item(0).branch_tax_inclusive);
                    
                }
                else {

                    reset_branch_values();
                }

            });


        }, function (e) {
            alert("ERROR: " + e.message);
        });
    } else {

        reset_branch_values();

    }

}

// resetting branch values
function reset_branch_values() {

    $("#br_tax_method").val(0);
    $("#br_time_zone").val(0);
    $("#br_tax_inclusive").val(0);
}

// taking imei of the device - security purpose
function getIMEI() {

    if (serverOn == "Yes") { device_id = device.serial; } else { device_id = 1234; }
}

// taking android id for push notification
function getAndroidId() {

    var push = PushNotification.init({
        android: {
            senderID: "994295211327"
        },
        browser: {
            pushServiceURL: 'http://push.api.phonegap.com/v1/push'
        },
        ios: {
            alert: "true",
            badge: "true",
            sound: "true"
        },
        windows: {}
    });

    push.on('registration', function (data) {
        androidkey = data.registrationId;
    });

    push.on('notification', function (data) {
        alert(data.message);
        
    });

    push.on('error', function (e) {
        // alert(e.message + "error");
    });


}

// session id - for new order ,  new registration, sales return , transactions etc.
function getSessionID() {

    var now = new Date();var year = now.getFullYear();var month = now.getMonth() + 1;var day = now.getDate();var hour = now.getHours();var minute = now.getMinutes();var second = now.getSeconds();
    if (month.toString().length == 1) { var month = '0' + month; }
    if (day.toString().length == 1) { var day = '0' + day; }
    if (hour.toString().length == 1) { var hour = '0' + hour; }
    if (minute.toString().length == 1) { var minute = '0' + minute; }
    if (second.toString().length == 1) {var second = '0' + second;}
    var salesman_id = $("#appuserid").val();
    current_session_id = String(year) + String(month) + String(day) + String(hour) + String(minute) + String(second) + String(salesman_id); 
}

// creating a temporary itbs id for NEW ITEM (not in the branch)
function getTempItbsID() {

    var now = new Date();var year = now.getFullYear();var month = now.getMonth() + 1;var day = now.getDate();var hour = now.getHours();var minute = now.getMinutes();var second = now.getSeconds();
    if (month.toString().length == 1) { var month = '0' + month; }
    if (day.toString().length == 1) { var day = '0' + day; }
    if (hour.toString().length == 1) {var hour = '0' + hour;}
    if (minute.toString().length == 1) {var minute = '0' + minute;}
    if (second.toString().length == 1) {var second = '0' + second;}
    var tempitbs =  "1" + String(day) +""+ String(hour) +""+ String(minute) +""+ String(second);
    return tempitbs;  
}

// LOADERS
var dialog = "";
function overlay(message) {
    
    dialog = bootbox.dialog({
        message: '<div align=center id="simage" style="margin-top:0px;margin-bottom:0px"><p class="text-center" style="color:#337ab7;margin-top:0px;margin-bottom:0px"><i class="ti-exchange-vertical blink-image"></i><i class="ti-mobile blink-image"></i>  ' + message + ' </p></div>',
        closeButton: false
    });

}

function closeOverlay() {

    setTimeout(function () {
        dialog.find(dialog.modal('hide'));
        dialog = "";
    }, 1000);
}

function closeOverlayImmediately() {

    dialog.find(dialog.modal('hide'));
    dialog = "";
}

function ajaxerroralert() {

    var log_ajax_failed = bootbox.dialog({
        message: '<p class="text-center" style="color:red"><i class="ti-info"></i> No Internet Access! Please Try again.</p>',
        closeButton: false
    });    
    setTimeout(function () {
        log_ajax_failed.find(log_ajax_failed.modal('hide'));
    }, 1000);
}

function validation_alert(message) {

    var logfailed = bootbox.dialog({
        message: '<p class="text-center" style="color:red"><i class="ti-info"></i> ' + message + '</p>',
        closeButton: false
    });
    setTimeout(function () {
        logfailed.find(logfailed.modal('hide'));
    }, 1500);

}

function successalert(message) {

    var logsuccess = bootbox.dialog({
        message: '<p class="text-center" style="color:green"><i class="ti-info"></i> ' + message + '</p>',
        closeButton: false
    });
    setTimeout(function () {
        logsuccess.find(logsuccess.modal('hide'));
    }, 1500);
}

// remove single & double quotes
function fixquotes() {

    $('input, select, textarea').each(
               function (index) {
                   var input = $(this);
                   var type = this.type ? this.type : this.nodeName.toLowerCase();
                   if (type == "text" || type == "textarea") {        
                       
                      $("#" + input.attr('id')).val(input.val().replace(/['"]+/g, ''));                      
                   }
                   else {

                   }
               }
           );
}

function modalClose() {
    dialog.modal('hide');
    dialog = "";
    unipopup = "";
    popupClosed();
}

//-----------------------------------------
// router -navigation helpers
function showpage(divid) {

    var logStatus = $("#loginval").val();
    if (logStatus == "1") {

        var hidingdiv = $("#hdnCurrentDiv").val();
        pageStack.push(hidingdiv);
        $("#" + hidingdiv).hide();
        $("#" + divid).show();
        $("#hdnCurrentDiv").val(divid);
        $("#"+divid+"").animate({ scrollTop: 0 }, "fast");
    }
    else {
        $("#divlogin").show();
    }


}

function onBackMove() {
    
    onBackKeyDown();
}

function onBackKeyDown() {

    if (backKeyStatus == 1) {

        if (unipopup != "") {
            popupClosed();
            unipopup.find(unipopup.modal('hide'));
            unipopup = "";
        }
        else {

            var hidingdiv = $("#hdnCurrentDiv").val();
            
            if (hidingdiv == "homepage" || hidingdiv == "divlogin") {

                if (backcount == 0) {
                    backcount = 1;

                    bootbox.confirm({
                        size: 'small',
                        message: 'Are you sure to Exit ?',
                        callback: function (result) {
                            if (result == false) {
                                backcount = 0;
                                return;
                            } else {

                                var showingDiv = pageStack.pop();
                                if (showingDiv == hidingdiv) {
                                    var showingDiv = pageStack.pop();
                                }
                                navigator.app.exitApp();


                            }
                        }
                    })
                }
                else {

                    return;
                }
            }
            else if (hidingdiv == "divProducts") {

                var db = getDB();
                db.transaction(function (tx) {

                    var htm = '';
                    var selectTrans = "select itbs_id from tbl_item_cart";
                    tx.executeSql(selectTrans, [], function (tx, res) {
                        var transDate = '';
                        var len = res.rows.length;
                        if (len == 0) {

                            var showingDiv = pageStack.pop();

                            if (showingDiv == hidingdiv) {
                                var showingDiv = pageStack.pop();
                            }
                            $("#hdnCurrentDiv").val(showingDiv);
                            $("#" + hidingdiv).hide();
                            $("#" + showingDiv).show();
                            $("#" + showingDiv + "").animate({ scrollTop: 0 }, "fast");

                        }
                        if (len > 0) {

                            if (ispopupshown == 1) {

                                return;
                            }
                            popuploaded();

                            bootbox.confirm({
                                size: 'small',
                                message: 'Going back will clear your existing cart items. Are you sure to continue ?',
                                callback: function (result) {
                                    if (result == false) {

                                        popupClosed();
                                        list_items_for_sale(1);
                                        return;
                                    } else {

                                        var showingDiv = pageStack.pop();
                                        if (showingDiv == hidingdiv) {
                                            var showingDiv = pageStack.pop();
                                        }
                                        $("#hdnCurrentDiv").val(showingDiv);

                                        $("#" + hidingdiv).hide();
                                        $("#" + showingDiv).show();
                                        $("#" + showingDiv + "").animate({ scrollTop: 0 }, "fast");
                                        popupClosed();

                                    }
                                }

                            })

                        }

                    });

                });

            }                
            else {

                //if (hidingdiv == "divListSellerOrder") {
                //    get_Salesman_with_order_counts();
                //}

                var showingDiv = pageStack.pop();
                if (showingDiv == hidingdiv) {
                    var showingDiv = pageStack.pop();
                }

                //if (showingDiv == "divListSellerOrder") {
                //    get_sellerwise_orders($("#id_seller").val(),1);
                //}
                //if (showingDiv == "divMyOrders") {
                    
                //    get_Orders(1);
                //}

                
                $("#hdnCurrentDiv").val(showingDiv);
                //handleTitles(showingDiv);
                $("#" + hidingdiv).hide();
                $("#" + showingDiv).show();
                $("#" + showingDiv + "").animate({ scrollTop: 0 }, "fast");
                if (hidingdiv == 'divMapContainer') {
                    stopWatchingLocation(map_watch_id);
                }

            }
        }
    }
    else {

        //alert('nothing');
    }
}

// DATE - Offline 
function offline_get_date_time() {

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!

    var yyyy = today.getFullYear();
    var hh = today.getHours();
    var minu = today.getMinutes();
    var sec = today.getSeconds();

    if (dd < 10) {
        dd = '0' + dd
    }
    if (mm < 10) {
        mm = '0' + mm
    }

    if (hh < 10) {
        hh = '0' + hh
    }

    if (minu < 10) {

        minu = '0' + minu
    }

    if (sec < 10) {
        sec = '0' + sec

    }

    var curd = yyyy + '-' + mm + '-' + dd + ' ' + hh + ':' + minu + ':' + sec;

    return curd;


}

function format(inputDate) {
    var date = new Date(inputDate);
    if (!isNaN(date.getTime())) {
        var day = date.getDate().toString();
        var month = (date.getMonth() + 1).toString();
        
        return (month[1] ? month : '0' + month[0]) + '/' +
           (day[1] ? day : '0' + day[0]) + '/' +
           date.getFullYear();
    }
}

function todaysDate() {

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!

    var yyyy = today.getFullYear();
    var hh = today.getHours();
    var minu = today.getMinutes();
    var sec = today.getSeconds();

    if (dd < 10) {
        dd = '0' + dd
    }
    if (mm < 10) {
        mm = '0' + mm
    }

    if (hh < 10) {
        hh = '0' + hh
    }

    if (minu < 10) {

        minu = '0' + minu
    }

    if (sec < 10) {
        sec = '0' + sec

    }

    var curd = yyyy + '-' + mm + '-' + dd;

    return curd;
}

function formatDate(dateTimeVal) {
    var dval=(dateTimeVal.split(" "))[0];
    var tval=(dateTimeVal.split(" "))[1];
    var tAMPM=(dateTimeVal.split(" "))[2];

    var med = dval.split("/");
    var yy = med[2];
    var mm = med[0];
    var dd = med[1];

    var timeVal="";

    if(tval){
      var hr=(tval.split(":"))[0];
      var min=(tval.split(":"))[1];
      var sec=(tval.split(":"))[2];
      timeVal=' ' + hr + ':' + min +(tAMPM?' '+tAMPM:'');
    }


    if (mm == 01) { mm = "Jan"; }
    if (mm == 02) { mm = "Feb"; }
    if (mm == 03) { mm = "Mar"; }
    if (mm == 04) { mm = "Apr"; }
    if (mm == 05) { mm = "May"; }
    if (mm == 06) { mm = "Jun"; }
    if (mm == 07) { mm = "Jul"; }
    if (mm == 08) { mm = "Aug"; }
    if (mm == 09) { mm = "Sep"; }
    if (mm == 10) { mm = "Oct"; }
    if (mm == 11) { mm = "Nov"; }
    if (mm == 12) { mm = "Dec"; }


    var curdate = dd + ' ' + mm + ' ' + yy + timeVal ;

    return curdate;
}

function formatDateSTD(dateTimeVal) {
    var dval=(dateTimeVal.split(" "))[0];
    var tval=(dateTimeVal.split(" "))[1];
    var tAMPM=(dateTimeVal.split(" "))[2];

    var med = dval.split("/");
    var yy = med[2].slice(2);
    var mm = med[0];
    var dd = med[1];

    var timeVal="";

    if(tval){
      var hr=(tval.split(":"))[0];
      var min=(tval.split(":"))[1];
      var sec=(tval.split(":"))[2];
      timeVal=' ' + hr + ':' + min +(tAMPM?' '+tAMPM:'');
    }



    var curdate = dd + '/' + mm + '/' + yy + timeVal ;

    return curdate;
}

function dateformat(idate) {

    var med = idate.split("-");
    var dd = med[0];
    var mm = med[1];
    var yy = med[2];

    var nDate = yy + '-' + mm + '-' + dd;
    return nDate;

}

function currentdate() {

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; 

    var yyyy = today.getFullYear();
    var hh = today.getHours();
    var minu = today.getMinutes();
    var sec = today.getSeconds();

    if (dd < 10) {
        dd = '0' + dd
    }
    if (mm < 10) {
        mm = '0' + mm
    }

    if (hh < 10) {
        hh = '0' + hh
    }

    if (minu < 10) {

        minu = '0' + minu
    }

    if (sec < 10) {
        sec = '0' + sec

    }

    var curd = dd + '-' + mm + '-' + yyyy;

    return curd;
}

function parseInputInteger(ctrl) {
    var num = ctrl.value;
    $(ctrl).val("");
    if ((!num || isNaN(num) || num < 0) && num.toString() != "") {
        num = $(ctrl).attr("data-valid-value");
    }
    else {
        setAsValidInput(ctrl);
    }
    $(ctrl).val(num);

}

function parseInputfloat(ctrl, evnt) {

    var num = ctrl.value;
    if (num.toString() === "" && evnt.keyCode == 8) {
        $(ctrl).val("");
       // alert('hi 1');
        setAsValidInput(ctrl);
    }
    else if (!num || isNaN(num) || num < 0) {
        //alert('hi');
        $(ctrl).val("");
       // num = $(ctrl).attr("data-valid-value");
       // $(ctrl).val(num);
    }
    else {
        setAsValidInput(ctrl);
    }
    // alert("");
}

// function to keep current valid input field value
function setAsValidInput(ctrl) {
    $(ctrl).attr("data-valid-value", ctrl.value);
}

// to initialize all dom event listeners
function initDomEvents() {
    // keydown events for both .float and .integer
    $('.integer,.float').keydown(function (e) {

        setAsValidInput(this);
    });
    // key up events for integer type inputs
    $('.integer').keyup(function (e) {

        parseInputInteger(this);
    });
    //key up events for float type inputs
    $('.float').keyup(function (e) {

        parseInputfloat(this, e);
    });

}

function format_currency_value(value) {

    var amount = parseFloat(value);
    return amount.toFixed($("#ss_decimal_accuracy").val()) + " " + $("#ss_currency").val();    
    
}
function format_decimal_accuray(value) {

    var amount = parseFloat(value);
    return amount.toFixed($("#ss_decimal_accuracy").val());

}
//************************ USER LOGIN / LOGOUT START***************************
function login_user() {
  
    if (androidkey == 0) { ajaxerroralert(); getAndroidId(); return;}
    if ($("#txt_user_name").val() == "") { validation_alert("Please enter the username"); return; }
    if ($("#txt_user_password").val() == "") { validation_alert("Please enter the password"); return; }

    var postObj = {

        logindata: {

            user_name: $("#txt_user_name").val(),
            user_password: $("#txt_user_password").val(),
            device_id: device_id,
            android_id: androidkey,
        }
    };

    disableBackKey();
    overlay("logging you in");    

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Login_user",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 25000,
        success: function (resp) {           
            closeOverlayImmediately();
            enableBackKey();
         
                if (resp.d == "") {

                    validation_alert("Unable to login! Please try again");
                }
                else if (resp.d == "BLOCKED") {

                    validation_alert("This Device is not authorized! Please Contact Admin.");
                }
                else if (resp.d == "NOTEXIST") {

                    validation_alert("Invalid login details!");
                }
                else {

                    var obj = JSON.parse(resp.d);
                    // inserting to tbl_app_user
                    var db = getDB();
                    db.transaction(function (tx) {

                        tx.executeSql("DELETE from tbl_appuser");
                        tx.executeSql("DELETE from tbl_system_settings");
                        var insert_qry = "INSERT INTO tbl_appuser (user_id,name,password,imei,db_last_updated_date) VALUES('" + obj.login_data[0].user_id + "','" + obj.login_data[0].name + "','" + obj.login_data[0].password + "','" + device_id + "','0')";
                        tx.executeSql(insert_qry, [], function (tx, res) {

                                                    
                            insert_to_settings = "INSERT INTO tbl_system_settings (ss_price_change,ss_discount_change,ss_foc_change,ss_class_change,ss_max_period_credit,ss_new_registration,ss_sales_return,ss_due_amount,ss_new_item,ss_location_on_order,ss_validation_email,ss_phone,ss_direct_delivery,ss_currency,ss_decimal_accuracy,ss_multidevice_block,ss_van_based_invoice_number,ss_default_time_zone,ss_default_max_period,ss_default_max_credit,ss_reg_id_required,ss_trn_gst_required,ss_payment_type,ss_last_updated_date) VALUES ('" + obj.settings_data[0].ss_price_change + "','" + obj.settings_data[0].ss_discount_change + "','" + obj.settings_data[0].ss_foc_change + "','" + obj.settings_data[0].ss_class_change + "','" + obj.settings_data[0].ss_max_period_credit + "','" + obj.settings_data[0].ss_new_registration + "','" + obj.settings_data[0].ss_sales_return + "','" + obj.settings_data[0].ss_due_amount + "','" + obj.settings_data[0].ss_new_item + "','" + obj.settings_data[0].ss_location_on_order + "','" + obj.settings_data[0].ss_validation_email + "','" + obj.settings_data[0].ss_phone + "','" + obj.settings_data[0].ss_direct_delivery + "','" + obj.settings_data[0].ss_currency + "','" + obj.settings_data[0].ss_decimal_accuracy + "','" + obj.settings_data[0].ss_multidevice_block + "','" + obj.settings_data[0].ss_van_based_invoice_number + "','" + obj.settings_data[0].ss_default_time_zone + "','" + obj.settings_data[0].ss_default_max_period + "','" + obj.settings_data[0].ss_default_max_credit + "','" + obj.settings_data[0].ss_reg_id_required + "','" + obj.settings_data[0].ss_trn_gst_required + "','" + obj.settings_data[0].ss_payment_type + "','" + obj.settings_data[0].ss_last_updated_date + "')";
                            tx.executeSql(insert_to_settings, [], function (tx, res) { });

                            $("#loginval").val('1');
                            $("#appuserid").val(obj.login_data[0].user_id);
                            $("#db_last_updated_date").val('0');
                            $("#ss_user_password").val(obj.login_data[0].password);
                            $("#ss_user_deviceid").val(device_id);

                            showpage('homepage');
                            fetch_app_settings();
                            successalert("Hi ! " + obj.login_data[0].name + "");

                        });
                    }, function (e) {

                        validation_alert(e.message);
                    });

     
                }
                

            },
            error: function (xhr, status) {

                closeOverlayImmediately();
                enableBackKey();
                ajaxerroralert();

            }
        });
    


}

function logout_user() {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to logout?',
        callback: function (result) {

            if (result == false) {
                return;

            } else {

                if (1 != 1) { }
                else {

                    var db = getDB();
                    db.transaction(function (tx) {

                        tx.executeSql("DELETE FROM tbl_appuser");
                        tx.executeSql("DELETE FROM tbl_system_settings");                        
                        tx.executeSql("DELETE FROM tbl_item_cart");                        
                        tx.executeSql("DELETE FROM tbl_itembranch_stock");
                        tx.executeSql("DELETE FROM tbl_branch");

                        //$("#loginval").val("0");
                        $("#loginval").val('1');
                        showpage('divlogin');
                        $("#loginval").val("0");


                    }, function (e) {
                        alert("ERROR: " + e.message);
                    });

                }


            }
        }
    });

}

//************************ USER LOGIN / LOGOUT ENDS***************************

// loading the settings page
function showSettings() {

    showpage('div_Settings');
    get_user_info_to_settings();
    load_bluetooth_devices();
}

function get_user_info_to_settings() {

    var db = getDB();
    db.transaction(function (tx) {

        var selectUser = "select name from tbl_appuser";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                $("#lbl_settings_name").html(res.rows.item(0).name + '<br /><small> Warehouse</small>');

            }
            else {


            }

        });


    }, function (e) {
        alert("ERROR: " + e.message);
    });
}

// initial loading of data
function First_Sync() {

   
    overlay("Loading data for the first time! This may take some time to complete ");
    disableBackKey();
    
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/First_Sync",
        data: "{'user_id':'" + $("#appuserid").val() + "','timezone':'" + $("#ss_default_time_zone").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (resp) {
            closeOverlay();
            enableBackKey();

            if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else if (resp.d == "ERROR") {

                validation_alert("Invalid login details!");
            }
            else {
                
                var obj = JSON.parse(resp.d); 
                $("#db_last_updated_date").val(obj.sync_time);
                var insert_qry_tbl_itembranch_stock = "INSERT INTO tbl_itembranch_stock (itm_type,brand_name,cat_name,branch_id,tp_tax_percentage,tp_cess,itbs_id,itm_id,itm_brand_id,itm_category_id,itm_name,itbs_stock,itm_code,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_rating) VALUES ";
                var insert_qry_tbl_branch = "INSERT INTO tbl_branch VALUES ";
                var insert_qry_tbl_location = "INSERT INTO tbl_location VALUES ";
                var insert_qry_customers = "INSERT INTO tbl_customer(cust_id,cust_name,cust_address,cust_city,cust_state,cust_country,cust_phone,cust_phone1,cust_email,cust_amount,cust_joined_date, cust_type,max_creditamt,max_creditperiod,new_custtype,new_creditamt,new_creditperiod,cust_latitude,cust_longitude,cust_image,cust_note,cust_status,cust_followup_date,cust_reg_id,location_id,cust_cat_id,cust_tax_reg_id,cust_action_type,cust_sync_status,img_updated,is_new_registration) VALUES ";
                var insert_qry_tbl_customer_category = "INSERT INTO tbl_customer_category VALUES ";

                var itembranch_stock = "";
                var tbl_branch_values = "";
                var tbl_location_values = "";
                var customers_values = "";
                var cust_category_values = "";

                // CUSTOMER CATEGORY - OFFLINE // 
                //******************************************************************************************************

                $.each(obj.dt_customer_catData, function (i, row) {

                    cust_category_values = cust_category_values + " ('" + row.cust_cat_id + "','" + row.cust_cat_name + "'),";

                });

                cust_category_values = cust_category_values.replace(/,\s*$/, "");
              

                // BRANCH DATA * WITH TAX - 
                //******************************************************************************************************


                $.each(obj.dt_branchData, function (i, row) {

                    tbl_branch_values = tbl_branch_values + " ('" + row.branch_id + "','" + row.branch_name + "','" + row.branch_timezone + "','" + row.branch_tax_method + "','" + row.branch_tax_inclusive + "'),";

                });

                tbl_branch_values = tbl_branch_values.replace(/,\s*$/, "");

                // LOCATION DATA - 
                //******************************************************************************************************

                $.each(obj.dt_locationsData, function (i, row) {

                    tbl_location_values = tbl_location_values + " ('" + row.location_id + "','" + row.location_name + "','" + row.state_id + "','" + row.state_name + "','" + row.country_id + "'),";

                });

                tbl_location_values = tbl_location_values.replace(/,\s*$/, "");

                // ITEM BRANCH STOCK DATA - 
                //******************************************************************************************************
                $.each(obj.dt_item_branchstockData, function (i, row) {

                    itembranch_stock = itembranch_stock + " ('" + row.itm_type + "','" + row.brand_name + "','" + row.cat_name + "','" + row.branch_id + "','" + row.tp_tax_percentage + "','" + row.tp_cess + "','" + row.itbs_id + "','" + row.itm_id + "','" + row.itm_brand_id + "','" + row.itm_category_id + "','" + row.itm_name + "','" + row.itbs_stock + "','" + row.itm_code + "','" + row.itm_mrp + "','" + row.itm_class_one + "','" + row.itm_class_two + "','" + row.itm_class_three + "','" + row.itm_commision + "','" + row.itm_rating + "'),";

                });

                itembranch_stock = itembranch_stock.replace(/,\s*$/, "");


                // CUSTOMER DATA - 
                //******************************************************************************************************

                $.each(obj.dt_customersData, function (i, row) {

                

                    customers_values = customers_values + " ('" + row.cust_id + "','" + row.cust_name + "','" + row.cust_address + "','" + row.cust_city + "','" + row.cust_state + "','" + row.cust_country + "','" + row.cust_phone + "','" + row.cust_phone1 + "','" + row.cust_email + "','" + row.cust_amount + "','" + row.cust_joined_date + "','" + row.cust_type + "','" + row.max_creditamt + "','" + row.max_creditperiod + "','" + row.new_custtype + "','" + row.new_creditamt + "','" + row.new_creditperiod + "','" + row.cust_latitude + "','" + row.cust_longitude + "','" + row.cust_image + "','" + row.cust_note + "','" + row.cust_status + "','" + row.cust_followup_date + "','" + row.cust_reg_id + "','" + row.location_id + "','" + row.cust_cat_id + "','" + row.cust_tax_reg_id + "','0','1','0','0'),";
                   
                });

                customers_values = customers_values.replace(/,\s*$/, "");


                var db = getDB();
                db.transaction(function (tx) {

                    // 1. CUSTOMER CATEGORY - OFFLINE //

                    tx.executeSql("delete from tbl_customer_category");
                    var query = insert_qry_tbl_customer_category + cust_category_values;
                    if (cust_category_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }


                    // 3. BRANCH DATA * WITH TAX - 

                    tx.executeSql("delete from tbl_branch");
                    var query = insert_qry_tbl_branch + tbl_branch_values;
                    if (tbl_branch_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                    // 4. LOCATION DATA - 

                    tx.executeSql("delete from tbl_location");
                    var query = insert_qry_tbl_location + tbl_location_values;
                    if (tbl_location_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                    // 5. ITEM DATA - 

                    tx.executeSql("delete from tbl_itembranch_stock");
                    var query = insert_qry_tbl_itembranch_stock + itembranch_stock;
                    if (itembranch_stock != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                    // 8. CUSTOMER  DATA 

                    tx.executeSql("delete from tbl_customer");                   
                    var query = insert_qry_customers + customers_values;
                    if (customers_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                    tx.executeSql("UPDATE tbl_appuser SET db_last_updated_date='"+ obj.sync_time +"'");


                }, function (e) {

                    alert(e.message)

                });



            }


        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });

}

// DISPLAYING ORDERS FROM BOTH SERVER AND LOCAL BASED ON TYPE
function showMyOrders(type) {

    $("#id_process_order_btn").hide();
    $("#id_activity_order_btn").show();
    $('#Select_branch_Orders').html('<option value="0">ALL BRANCH / WAREHOUSE</option>');
    var yyyy = new Date().getFullYear();
    $('#txt_date_orders_from').scroller({
        preset: 'date',
        endYear: yyyy + 10,
        setText: 'Select',
        invalid: {},
        theme: 'android-ics',
        display: 'modal',
        mode: 'scroller',
        //  dateFormat :'yy/mm/dd'
        dateFormat: 'dd-mm-yy'
    });

    $('#txt_date_orders_to').scroller({
        preset: 'date',
        endYear: yyyy + 10,
        setText: 'Select',
        invalid: {},
        theme: 'android-ics',
        display: 'modal',
        mode: 'scroller',
        // dateFormat :'yy/mm/dd'
        dateFormat: 'dd-mm-yy'
    });

    var cday = currentdate();
    $('#txt_date_orders_from').val(cday);
    $('#txt_date_orders_to').val(cday);
    
    showpage('divMyOrders');
    $("#order_load_type").val(type);
    $('#div_online_order_part').show();
    get_Orders(1);

}


// type - 1 - all orders , 2 - customer orders
function get_Orders(page) {
    
    var orders_from = $('#txt_date_orders_from').val();
    var orders_to = $('#txt_date_orders_to').val();

    if ($("#order_load_type").val() == 1) {
        overlay("Loading Orders ");
        $("#customer_id").val("0")
    }
    else if ($("#order_load_type").val() == 2)
    {
        overlay("Loading Customer Orders ");
    }

    disableBackKey();

    var postObj = {

        filters: {

            branch_id: $("#Select_branch_Orders").val(),
            customer_id: $("#customer_id").val(),
            orders_from: dateformat(orders_from),
            orders_to: dateformat(orders_to),
            order_status: $("#Select_Order_Status").val(),
            payment_status: $("#Select_Payment_Status").val(),
            page: page,
            user_id: $("#appuserid").val(),
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };

    
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Orders_with_date_range",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";

            if (resp.d == "BLOCKED") {

                validation_alert("This Device / User has been blocked! Please contact admin.");
                onBackKeyDown();
            }
            else if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);

                $.each(response.order_list, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Order_details(' + row.sm_id + ')">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7;background-color:' + color + '">' + String(row.cust_name) + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "";
                    delivery_status_image = row.sm_delivery_status == 0 && row.sm_packed == 0 ? "assets/img/neww.png" : row.sm_delivery_status == 0 && row.sm_packed == 1 ? "assets/img/packed.png" : row.sm_delivery_status == 1 ? "assets/img/processes.jpg" : row.sm_delivery_status == 2 ? "assets/img/delivered.png" : row.sm_delivery_status == 3 ? "assets/img/underReview.jpg" : row.sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : row.sm_delivery_status == 5 ? "assets/img/rejected.png" : row.sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    if (row.sm_invoice_no == "") {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No:(' + row.sm_id + ')';
                    }
                    else {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No: #' + row.sm_invoice_no + ' (' + row.sm_id + ')';

                    }
                    htm = htm + '<br /><span style="color:#337ab7"><small>Bill Amount : ' + format_currency_value(row.sm_netamount) + '</small></span></br><span class="text-danger"><small>Balance : ' + format_currency_value(row.total_balance) + '</small></span></div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.sm_date + '</small></br>';
                    htm = htm + '</div></div>';                   
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var bhtm = "";
                var common = "";
                var len = 0;
                common = common + '<option value="0">ALL BRANCH / WAREHOUSE</option>';
                $.each(response.branch_data, function (i, row) {
                    bhtm = bhtm + '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    len = i;
                });

                if (bhtm == "") { $("#Select_branch_Orders").html('<option value="0">NO BRANCH / WAREHOUSE ALLOCATED</option>'); }
                else {

                    if (len > 0) { bhtm = common + bhtm; }
                    else { bhtm = bhtm; }

                    $("#Select_branch_Orders").html(bhtm);
                }

                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_ord" onclick="javascript:get_Orders(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_ord" onclick="javascript:get_Orders(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_List_Orders").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);

               

                if (page > 1) {
                    $("#btnPrev_ord").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_ord").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_ord").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_ord").hide();
                }
            }

        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function resetProductSearch() {

    $("#txtsearchProducts").val("");
    $("#selectBrands").val('x');
    $("#selectCategory").val('x');
    load_brands_categories_to_combo();
    list_items_for_sale(1);
}

function clear_Cart_Items() {

    var db = getDB();
    db.transaction(function (tx) {

        var chtm = "";
        var clear_Cart_Items = "DELETE FROM tbl_item_cart";
        tx.executeSql(clear_Cart_Items, [], function (tx, res) {
          
        });

    }, function (e) {

        alert(e.message);

    });
}

function show_product_list_page() {

    if ($("#Select_Access_Branch").val() == "0") {validation_alert('Please select a warehouse to continue!'); return; }
    getSessionID();
    if ($("#ss_new_item").val() == "1") { $("#newitemheader").show(); } else { $("#newitemheader").hide(); }
    showpage('divProducts');
    $("#Selectitmtypes").val(1);
    $("#txtsearchProducts").val("");
    clear_Cart_Items();
    load_brands_categories_to_combo();
    list_items_for_sale(1);
}

function clrSearchBoxandSearch() {
    $("#txtsearchProducts").val("");
    load_categories_based_on_brand();
}

function load_categories_based_on_brand() {

    var db = getDB();
    db.transaction(function (tx) {
      
        var chtm = "";
        var cat_qry = "";
        chtm = chtm + '<option value="x">All Categories</option>';

        if ($("#selectBrands").val() == "x") {

            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_category_id";
        }
        else {
            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes").val() + "' and itm_brand_id='" + $("#selectBrands").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_category_id";
        }

        tx.executeSql(cat_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    chtm = chtm + '<option value="' + String(res.rows.item(i).itm_category_id) + '">' + String(res.rows.item(i).cat_name) + '</option>';
                }
                $("#selectCategory").html(chtm);
                list_items_for_sale(1);
            }
            else { }
        });

    }, function (e) {

        alert(e.message);

    });


}

function load_brands_categories_to_combo() {

    var db = getDB();
    db.transaction(function (tx) {

        var bhtm = "";
        bhtm = bhtm + '<option value="x">All Brands</option>';

        var chtm = "";
        chtm = chtm + '<option value="x">All Categories</option>';

        var brand_qry = "SELECT itm_brand_id,brand_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_brand_id";
        var cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes").val() + "' and  branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_category_id";

        tx.executeSql(brand_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    bhtm = bhtm + '<option value="' + String(res.rows.item(i).itm_brand_id) + '">' + String(res.rows.item(i).brand_name) + '</option>';
                }
                $("#selectBrands").html(bhtm);
            }
            else { }

        });

        tx.executeSql(cat_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    chtm = chtm + '<option value="' + String(res.rows.item(i).itm_category_id) + '">' + String(res.rows.item(i).cat_name) + '</option>';
                }
                $("#selectCategory").html(chtm);
            }
            else { }
        });

    }, function (e) {

        alert(e.message);

    });

    

}

function list_items_for_sale(page) {

    if ($("#hdnCurrentDiv").val() != "divProducts") { showpage('divProducts'); }

    var searchString = $("#txtsearchProducts").val();
    var filterstring = " ";
    var brand = $("#selectBrands").val();
    var category = $("#selectCategory").val();
    var itm_type = $("#Selectitmtypes").val();

    if (brand != 'x') { filterstring = filterstring + " and itm_brand_id='" + brand + "' "; }
    if (category != 'x') { filterstring = filterstring + " and itm_category_id='" + category + "' "; }

    var perPage = 15;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_itembranch_stock where itbs_id NOT IN (SELECT itbs_id FROM tbl_item_cart) and itm_type='" + $("#Selectitmtypes").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' and itm_name like '%" + searchString + "%'" + filterstring + "";

        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            totPages = Math.ceil(totalRows / perPage);
            
            var selectItems = "select itm_name,itbs_id,itm_code,"+$("#cust_class_for_order").val()+" as itm_price,itm_type from tbl_itembranch_stock " +
            " where itbs_id NOT IN (SELECT itbs_id FROM tbl_item_cart) and itm_type='" + $("#Selectitmtypes").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' and itm_name like '%" + searchString + "%'" + filterstring + " order by itm_rating desc,itm_name asc limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Results Found !';
                    htm = htm + '<span class="text-success"><small></small></span>';
                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    $("#dListProduct").html(htm);
                    $("#nOfItems").html('No Results');

                    return;
                }
                if (len > 0) {
                   
                    for (var i = 0; i < len; i++) {

                        var color = 0;
                        var image = "";
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        if (res.rows.item(i).itm_type == "1") { image = "Add-item-icon"; } else if (res.rows.item(i).itm_type == "2") { image = "service"; } else if (res.rows.item(i).itm_type == "3") { image = "coupons"; } else { }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:load_item_details_to_add(' + String(res.rows.item(i).itbs_id) + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/'+image+'.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + String(res.rows.item(i).itm_name) + '<br />';
                        htm = htm + '<span class="text-info"><small style="color:#337ab7">ITEM CODE : #' + String(res.rows.item(i).itm_code) + '</small></span><br />';
                        htm = htm + '<span class="text-danger"><small>ITEM PRICE :<b> ' + format_currency_value(res.rows.item(i).itm_price) + '</b></small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-plus"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev44nc" onclick="javascript:list_items_for_sale(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext44nc" onclick="javascript:list_items_for_sale(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';



                    $("#dListProduct").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);

                    
                    if (page > 1) {
                        $("#btnPrev44nc").show();
                    }
                    if (page < totPages) {
                        $("#btnNext44nc").show();
                    }
                    if (totPages == 1) {
                        $("#btnNext44nc").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext44nc").hide();
                    }

                }

            });

        });

    });


}

function calculate_item_Total() {

    if ($("#hdnCurrentDiv").val() == "divOrderEdit") {

        var tax_method = $("#return_taxmethod").val(); // ( 0 = no tax , 1 - VAT , 2 - GST )
        var isTaxInclusive = $("#return_taxinclusive").val(); //( 0 = No , 1 - Yes)
    }
    else {
        var tax_method = $("#br_tax_method").val(); // ( 0 = no tax , 1 - VAT , 2 - GST )
        var isTaxInclusive = $("#br_tax_inclusive").val(); //( 0 = No , 1 - Yes)
    }
    var cust_state = 0; // for own state - 

    //** required variables
    var realtotal = 0;
    var nettotal = 0;
    var discountRate = 0;
    var discount_amt = 0;
    var tax_rate = 0;
    var tax_amount = 0;
    var tax_exclusive_price = 0;
    var tax_exclusive_total = 0;
    var commisionRate = 0;
    var commisionAmount = 0;
    var tax_included_nettotal = 0;
    var cessRate = 0;
    var cessAmount = 0;

    //**********************

    //*****************  required base values

    var price = format_decimal_accuray($("#txt_item_price").val());
    var quantity = $("#txt_item_quantity").val();
    var discount = $("#txt_item_discount").val();
    var focval = format_decimal_accuray($("#txt_item_foc").val());

    tax_rate = format_decimal_accuray($("#item_cal_tax_percent").val());
    cessRate = format_decimal_accuray($("#item_cal_cess").val());
    commisionRate = format_decimal_accuray($("#item_cal_commision").val());

    if (quantity == "" || quantity == null || isNaN(quantity)) {
        quantity = 0;
    }
    if (discount == "" || discount == null || isNaN(discount)) {
        discount = 0;
    }
    if (price == "" || price == null || isNaN(price)) {
        price = 0;
    }
    if (focval == "" || focval == null || isNaN(focval)) {
        focval = 0;
    }

    //*****************

    if (tax_method == 0) // no tax
    {
        realtotal = price * quantity; // price without discount
        discount_amt = ((realtotal * discount) / 100);
        nettotal = realtotal - ((realtotal * discount) / 100);
        tax_included_nettotal = nettotal;
        commisionAmount = ((nettotal * commisionRate) / 100);
        tax_amount = 0; // not tax used
        cessAmount = 0;
    }
    else if (tax_method == 1) { // VAT CALCULATION

        if (isTaxInclusive == 1) { // tax is included with the price

            if (parseFloat(cessRate) > 0) {

                var denominator = 10000 * price;
                var base = 10000 + (100 * tax_rate) + (tax_rate * cessRate);
                price = denominator / base;
            }
            else {

                var constant = (tax_rate / 100) + 1; // equation for the dividing constant
                price = price / constant;
                cessAmount = 0;
                cessRate = 0;
            }
        }

        realtotal = price * quantity; // price without discount
        discount_amt = ((realtotal * discount) / 100);
        nettotal = realtotal - ((realtotal * discount) / 100);
        commisionAmount = ((nettotal * commisionRate) / 100);
        tax_amount = ((nettotal * tax_rate) / 100);
        cessAmount = ((tax_amount * cessRate) / 100);
        tax_amount = parseFloat(tax_amount) + parseFloat(cessAmount);
        tax_included_nettotal = parseFloat(nettotal) + parseFloat(tax_amount);

    }

    else if (tax_method == 2) { // GST CALCULATION

        if (isTaxInclusive == 1) { // tax is included with the price

            if (parseFloat(cessRate) > 0) {

                var denominator = 10000 * price;
                var base = 10000 + (100 * tax_rate) + (tax_rate * cessRate);
                price = denominator / base;
            }
            else {

                var constant = (tax_rate / 100) + 1; // equation for the dividing constant
                price = price / constant;
            }
        }

        realtotal = price * quantity; // price without discount
        discount_amt = ((realtotal * discount) / 100);
        nettotal = realtotal - ((realtotal * discount) / 100);
        commisionAmount = ((nettotal * commisionRate) / 100);
        tax_amount = ((nettotal * tax_rate) / 100);
        cessAmount = ((tax_amount * cessRate) / 100);
        tax_amount = tax_amount + cessAmount;
        tax_included_nettotal = parseFloat(nettotal) + parseFloat(tax_amount);

        // GST Contents based on Customer state format_decimal_accuray(
        $("#gstTotalPercent").val(format_decimal_accuray(tax_rate));
        $("#gstTotal").val(format_decimal_accuray(tax_amount));

        var splitGSTrate = tax_rate / 2;
        splitGSTrateRounded = format_decimal_accuray(splitGSTrate);

        var splitGSTamount = tax_amount / 2;
        splitGSTamount = format_decimal_accuray(splitGSTamount);

    }

    $("#itm_calc_real_total").val(format_decimal_accuray(realtotal));
    $("#itm_calc_net_total").val(format_decimal_accuray(tax_included_nettotal));
    $("#itm_calc_dics_amount").val(format_decimal_accuray(discount_amt));
    $("#itm_calc_tax_amount").val(format_decimal_accuray(tax_amount));
    $("#itm_calc_commision_amount").val(format_decimal_accuray(commisionAmount));
    $("#itm_calc_cess_amount").val(format_decimal_accuray(cessAmount));
    $("#lbl_itmpop_itm_total").html('NET TOTAL : ' + format_currency_value(tax_included_nettotal) + ' (Tax Inc.)');
    $("#lbl_itmpop_itm_tax").html('TAX AMOUNT: <b>' + format_decimal_accuray(tax_amount) + '</b> ( ' + $("#item_cal_tax_percent").val() + '% )');
    $("#lbl_itmpop_itm_total_without_tax").html('ITEM TOTAL : <b>' + format_currency_value((tax_included_nettotal - tax_amount)) + '</b>');
    $("#lbl_itmpop_itm_total_qty").html('TOTAL QTY (QTY + FOC) : <b>' + (parseInt(quantity) + parseInt(focval)) + '</b>');
    
}

function load_item_details_to_add(itbs_id) {
   
    if (ispopupshown == 0) {
       
        popuploaded();
        var db = getDB();
        db.transaction(function (tx) {

            var htm = '';
            var selectTrans = "select itbs_id,itm_name,itm_code,itbs_stock," + $("#cust_class_for_order").val() + " as itm_price,itm_type,brand_name,itm_commision,tp_tax_percentage,tp_cess from tbl_itembranch_stock where itbs_id=" + itbs_id + " ";
            tx.executeSql(selectTrans, [], function (tx, res) {
                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    closeOverlay();
                    return;
                }
                if (len > 0) {
                    
                    var cls_value = "";
                    var img_value = "";
                    $("#item_cal_tax_percent").val(res.rows.item(0).tp_tax_percentage);
                    $("#item_cal_cess").val(res.rows.item(0).tp_cess);
                    $("#item_cal_commision").val(res.rows.item(0).itm_commision);
                    $("#item_cal_original_price").val(res.rows.item(0).itm_price);
                    
                    if ($("#cust_class_for_order").val() == "itm_class_three") { cls_value = "C CLASS"; } else if ($("#cust_class_for_order").val() == "itm_class_two") { cls_value = "B CLASS"; } else { cls_value = "A CLASS"; }
                    if (String(res.rows.item(0).itm_type) == "1") { img_value = "Add-item-icon"; } else if (String(res.rows.item(0).itm_type) == "2") { img_value = "service"; } else { img_value = "coupons"; }

                    dialog = bootbox.dialog({
                        message: '<div class="content" style="margin-bottom:2px;">' +
            '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/' + img_value + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + String(res.rows.item(0).itm_name) + '</b><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ITEM BRAND : ' + String(res.rows.item(0).brand_name) + '</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ITEM CODE : #' + String(res.rows.item(0).itm_code) + '</small></span><br />' +
            '<span class="text-danger"><small id="lbl_itmpop_itm_stock">STOCK : ' + String(res.rows.item(0).itbs_stock) + ' (Approx.)</small></span></div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ITEM QTY</label><input type="number" id="txt_item_quantity" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input integer" value="1" placeholder="Enter quantity"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">PRICE</label><input type="number" id="txt_item_price" style="font-size:17px" value="' + String(res.rows.item(0).itm_price) + '" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" placeholder="Enter price"></div></td>' +
            '</tr>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ADDITIONAL DISCOUNT %</label><input type="number" id="txt_item_discount" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" value="0.00" placeholder="Enter discount"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">FREE OF COST</label><input type="number" id="txt_item_foc" style="font-size:17px" class="form-control border-input integer" value="0" onkeyup = "javascript:calculate_item_Total();" placeholder="Enter FOC"></div></td>' +
            '</tr>' +
            '</table>' +
            '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">UNIT PRICE : ' + format_decimal_accuray(res.rows.item(0).itm_price) + ' (' + cls_value + ')<br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">TOTAL QTY (QTY + FOC) : 1</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_without_tax">ITEM TOTAL : ' + res.rows.item(0).itm_price + '</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_tax">TAX % : ' + res.rows.item(0).tp_tax_percentage + '</small></span><br />' +
            '<span class="text-danger"><small style="font-size:15px"><b id="lbl_itmpop_itm_total">NET TOTAL : 500 AED (Tax Amt. 50 AED)</b></small></span></div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="add_item_to_cart(\'' + itbs_id + '\',\'' + res.rows.item(0).itm_code + '\',\'' + res.rows.item(0).itm_name + '\',\'' + res.rows.item(0).itm_type + '\',\'' + res.rows.item(0).itbs_stock + '\',\'' + res.rows.item(0).brand_name + '\')">ADD</button></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:modalClose();">CLOSE</button></td>' +
            '</tr>' +
            '</table>' +
            '</div> ',
                        closeButton: false
                    });


                    unipopup = dialog;
                    initDomEvents();
                    calculate_item_Total();
                }

            });



        });

       



    }


}

function add_item_to_cart(itbs_id,itm_code,itm_name,itm_type,itbs_stock,brand_name) {


    var price = $("#txt_item_price").val();
    var quantity = $("#txt_item_quantity").val();
    var discount = $("#txt_item_discount").val();
    var focval = $("#txt_item_foc").val();
    
    if (quantity == "0" || quantity == "" || quantity == null || isNaN(quantity)) {
        validation_alert("Please enter the Quanitiy"); return;
    }
    if (discount == "" || discount == null || isNaN(discount)) {

        validation_alert("Please enter the Discount %"); return;
    }
    if (price == "" || price == null || isNaN(price)) {
        validation_alert("Please enter a valid price"); return;
    }
    if (focval == "" || focval == null || isNaN(focval)) {
        validation_alert("Please enter a valid FOC value"); return;
    }

    if (parseFloat(discount) > 100) { validation_alert("Discount cannot be more than 100%!"); return; }
   
    var db = getDB();
    db.transaction(function (tx) {

        var check_item_existance_qry = "SELECT itbs_id,itm_name FROM tbl_item_cart WHERE itbs_id='"+itbs_id+"'";
        tx.executeSql(check_item_existance_qry, [], function (tx, res) {
            if (res.rows.length > 0) { // check for item existance
                validation_alert(res.rows.item(0).itm_name + ' already exists in the cart'); // item exists
                list_items_for_sale(1);
                modalClose();
                
            }
            else { // add item to cart

                var si_approval_status = 0;

                if ($("#ss_price_change").val() == "1") {

                    if (parseFloat($("#item_cal_original_price").val()) != parseFloat($("#txt_item_price").val())) { si_approval_status = 1; }
                }
                if ($("#ss_discount_change").val() == "1") {

                    if (parseFloat($("#txt_item_discount").val()) > 0) { si_approval_status = 1; }
                }
                if ($("#ss_foc_change").val() == "1") {

                    if (parseInt($("#txt_item_foc").val()) > 0) { si_approval_status = 1; }
                }
                var si_tax_excluded_total = format_decimal_accuray(parseFloat($("#itm_calc_net_total").val()) - parseFloat($("#itm_calc_tax_amount").val()));
               
                var insert_tbl_cart = "INSERT INTO tbl_item_cart(itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type,itbs_stock,brand_name) VALUES ('" + itbs_id + "','" + itm_code + "','" + itm_name + "','" + $("#item_cal_original_price").val() + "','" + $("#txt_item_price").val() + "','" + $("#txt_item_quantity").val() + "','" + $("#itm_calc_real_total").val() + "','" + $("#txt_item_discount").val() + "','" + $("#itm_calc_dics_amount").val() + "','" + $("#itm_calc_net_total").val() + "','" + $("#txt_item_foc").val() + "','" + si_approval_status + "','" + $("#item_cal_commision").val() + "','" + $("#itm_calc_commision_amount").val() + "','0','" + $("#item_cal_tax_percent").val() + "','" + $("#item_cal_cess").val() + "','" + si_tax_excluded_total + "','" + $("#itm_calc_tax_amount").val() + "','" + itm_type + "','" + itbs_stock + "','" + brand_name + "')";
                
                tx.executeSql(insert_tbl_cart, [], function (tx, res) {
                    successalert(itm_name + " has been added to cart!");
                    list_items_for_sale(1);
                    modalClose();
                });

            }
        });

    }, function (e) {

        alert(e.message);

    });
}

function load_item_details_to_edit(itbs_id) {

    

        if (ispopupshown == 0) {
            popuploaded();
            var db = getDB();
            db.transaction(function (tx) {

                var htm = '';
                var selectTrans = "select * from tbl_item_cart where itbs_id=" + itbs_id + " ";
                tx.executeSql(selectTrans, [], function (tx, res) {
                    var transDate = '';
                    var len = res.rows.length;
                    if (len == 0) {

                        closeOverlay();
                        return;
                    }
                    if (len > 0) {

                        var cls_value = "";
                        var img_value = "";
                        $("#item_cal_tax_percent").val(res.rows.item(0).si_item_tax);
                        $("#item_cal_cess").val(res.rows.item(0).si_item_cess);
                        $("#item_cal_commision").val(res.rows.item(0).itm_commision);
                        $("#item_cal_original_price").val(res.rows.item(0).si_org_price);

                        if ($("#cust_class_for_order").val() == "itm_class_three") { cls_value = "C CLASS"; } else if ($("#cust_class_for_order").val() == "itm_class_two") { cls_value = "B CLASS"; } else { cls_value = "A CLASS"; }
                        if (String(res.rows.item(0).itm_type) == "1") { img_value = "Add-item-icon"; } else if (String(res.rows.item(0).itm_type) == "2") { img_value = "service"; } else { img_value = "coupons"; }

                        dialog = bootbox.dialog({
                            message: '<div class="content" style="margin-bottom:2px;">' +
                '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
                '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/' + img_value + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
                '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + String(res.rows.item(0).itm_name) + '</b><br />' +
                '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ITEM BRAND : ' + String(res.rows.item(0).brand_name) + '</small></span><br />' +
                '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ITEM CODE : #' + String(res.rows.item(0).itm_code) + '</small></span><br />' +
                //'<span class="text-danger"><small id="lbl_itmpop_itm_stock">STOCK : ' + String(res.rows.item(0).itbs_stock) + ' (Approx.)</small></span>'+
                '</div></div>' +
                '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
                '<table>' +
                '<tr>' +
                '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ITEM QTY</label><input type="number" id="txt_item_quantity" value="' + String(res.rows.item(0).si_qty) + '" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input integer" value="1" placeholder="Enter quantity"></div></td>' +
                '<td>&nbsp</td>' +
                '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">PRICE</label><input type="number" id="txt_item_price" style="font-size:17px" value="' + String(res.rows.item(0).si_price) + '" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" placeholder="Enter price"></div></td>' +
                '</tr>' +
                '<tr>' +
                '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ADDITIONAL DISCOUNT %</label><input type="number" value="' + String(res.rows.item(0).si_discount_rate) + '" id="txt_item_discount" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" value="0.00" placeholder="Enter discount"></div></td>' +
                '<td>&nbsp</td>' +
                '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">FREE OF COST</label><input type="number" value="' + String(res.rows.item(0).si_foc) + '" id="txt_item_foc" style="font-size:17px" class="form-control border-input integer" value="0" onkeyup = "javascript:calculate_item_Total();" placeholder="Enter FOC"></div></td>' +
                '</tr>' +
                '</table>' +
                '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
                '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
                '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">UNIT PRICE : ' + format_decimal_accuray(res.rows.item(0).si_price) + ' (' + cls_value + ')<br />' +
                '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">TOTAL QTY (QTY + FOC) : 1</small></span><br />' +
                '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_without_tax">ITEM TOTAL : ' + res.rows.item(0).si_total + '</small></span><br />' +
                '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_tax">TAX % : ' + res.rows.item(0).si_item_tax + '</small></span><br />' +
                '<span class="text-danger"><small style="font-size:15px"><b id="lbl_itmpop_itm_total">NET TOTAL : 000 AED (Tax Amt. 50 AED)</b></small></span></div></div>' +
                '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
                '<table>' +
                '<tr>' +
                '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="update_item_in_cart(' + itbs_id + ')">UPDATE</button></td>' +
                '<td>&nbsp</td>' +
                '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:remove_item_from_cart(' + itbs_id + ');">REMOVE</button></td>' +
                '</tr>' +
                '</table>' +
                '<table style="width:100%">' +
                '<tr>' +
                '<td ><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:gray;color:#fff;border:none;margin-top:10px;height:40px" onclick="javascript:modalClose();">CLOSE</button></td>' +
                '</tr>' +
                '</table>' +
                '</div> ',
                            closeButton: false
                        });


                        unipopup = dialog;
                        initDomEvents();

                        calculate_item_Total();
                    }

                });



            });
        }
      

}

function update_item_in_cart(itbs_id) {

    var price = $("#txt_item_price").val();
    var quantity = $("#txt_item_quantity").val();
    var discount = $("#txt_item_discount").val();
    var focval = $("#txt_item_foc").val();

    if (quantity == "0" || quantity == "" || quantity == null || isNaN(quantity)) {
        validation_alert("Please enter the Quanitiy"); return;
    }
    if (discount == "" || discount == null || isNaN(discount)) {

        validation_alert("Please enter the Discount %"); return;
    }
    if (price == "" || price == null || isNaN(price)) {
        validation_alert("Please enter a valid price"); return;
    }
    if (focval == "" || focval == null || isNaN(focval)) {
        validation_alert("Please enter a valid FOC value"); return;
    }

    if (parseFloat(discount) > 100) { validation_alert("Discount cannot be more than 100%!"); return; }

    var db = getDB();
    db.transaction(function (tx) {

        var si_approval_status = 0;

        if ($("#ss_price_change").val() == "1") {

            if (parseFloat($("#item_cal_original_price").val()) != parseFloat($("#txt_item_price").val())) { si_approval_status = 1; }
        }
        if ($("#ss_discount_change").val() == "1") {

            if (parseFloat($("#txt_item_discount").val()) > 0) { si_approval_status = 1; }
        }
        if ($("#ss_foc_change").val() == "1") {

            if (parseInt($("#txt_item_foc").val()) > 0) { si_approval_status = 1; }
        }
        var si_tax_excluded_total = format_decimal_accuray(parseFloat($("#itm_calc_net_total").val()) - parseFloat($("#itm_calc_tax_amount").val()));

        var update_tbl_cart = "UPDATE tbl_item_cart SET si_price='" + $("#txt_item_price").val() + "',si_qty='" + $("#txt_item_quantity").val() + "',si_total='" + $("#itm_calc_real_total").val() + "',si_discount_rate='" + $("#txt_item_discount").val() + "',si_discount_amount='" + $("#itm_calc_dics_amount").val() + "',si_net_amount='" + $("#itm_calc_net_total").val() + "',si_foc='" + $("#txt_item_foc").val() + "',si_approval_status='" + si_approval_status + "',itm_commisionamt='" + $("#itm_calc_commision_amount").val() + "',si_tax_excluded_total='" + si_tax_excluded_total + "',si_tax_amount='" + $("#itm_calc_tax_amount").val() + "' WHERE itbs_id='"+itbs_id +"'";
       
        tx.executeSql(update_tbl_cart, [], function (tx, res) {
            successalert("Item details has been updated!");
            list_items_Cart(1);
            modalClose();
        });
        

    }, function (e) {

        alert(e.message);

    });
}

function remove_item_from_cart(itbs_id) {

    var db = getDB();
    db.transaction(function (tx) {

       
        var delete_from_tbl_cart = "DELETE FROM tbl_item_cart WHERE itbs_id='" + itbs_id + "'";
       
        tx.executeSql(delete_from_tbl_cart, [], function (tx, res) {
            validation_alert("Item has been removed from cart!");
            list_items_Cart(1);
            modalClose();
        });


    }, function (e) {

        alert(e.message);

    });
}

// loading products offline
function load_offline_products() {


    if ($("#Select_Access_Branch").val() == "0") {

        validation_alert('Please select a warehouse to continue!');
        
        return;
    }
   
    getSessionID();

    // end of checkings
    var cust_id = $("#customer_id").val();
    var branch_id = $("#Select_Access_Branch").val();
    var user_id = $("#appuserid").val();
    var custType = "";
    var price_qry = "";

    var custClassQry = "SELECT cust_type,new_custtype FROM tbl_customer WHERE cust_id='" + cust_id + "'";
    
    var db = getDB();
    db.transaction(function (tx) {

        tx.executeSql(custClassQry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                var oldclasstype = res.rows.item(0).cust_type;
                var newclasstype = res.rows.item(0).new_custtype;
                
                if (newclasstype == "0") { custType = oldclasstype; }
                else { custType = newclasstype; }
                if (custType == "0") { alert("NO CLASS"); return; }

                if (cba_new_maxcredit_amount == 0) { custCredit = cba_max_credit_amt; }
                else { custCredit = cba_new_maxcredit_amount; }
                if (custCredit == 0) { alert("NO CREDIT"); return; }

                // fetching items from item branch stock

                if (custType == "1") { price_qry = "itb.itm_class_one"; }
                else if (custType == "2") { price_qry = "itb.itm_class_two"; }
                else if (custType == "3") { price_qry = "itb.itm_class_three"; }
                else { }
                //alert(price_qry);
                var itm_fetch_qry = "select itb.itm_name,itb.itm_code,itb.brand_name," + price_qry + " as itm_price from tbl_itembranch_stock itb join tbl_user_brand_access uba on itb.branch_id=uba.branch_id where uba.branch_id='" + branch_id + "' and uba.cust_id='" + cust_id + "' and uba.brand_id=itb.itm_brand_id ORDER BY itb.itbs_id asc";
                
            }
            else {

                alert("PLEASE SET THE CLASS/CREDIT DETAILS FOR THE WAREHOUSE");
                $("#eselCusType").focus();
                loadCustomertoEdit();

            }
        });



    }, function (e) {

        alert(e.message);
    });

}

function show_salesman_list_page() {

    $("#id_process_order_btn").show();
    $("#id_activity_order_btn").hide();
    showpage('divListSalesforProcess');
    get_Salesman_with_order_counts();
}

function get_Salesman_with_order_counts() {

    overlay("Loading Salesmen List ");
    disableBackKey();

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Salesman_with_order_counts",
        data: "{'user_id':'" + $("#appuserid").val() + "','branch_id':'" + $("#Select_branch_for_process").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";
            if (resp.d == "BLOCKED") {

                validation_alert("This Device / User has been blocked! Please contact admin.");
                onBackKeyDown();
            }
            else if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);
                console.log(JSON.parse(resp.d));
                $.each(response.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f9f9f9"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid gray" onclick="javascript:get_individual_orders(' + row.user_id + ',1);">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7"><i class="ti-user"></i> <b>' + row.name + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                    htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                    htm = htm + '<tr><td style="color:#c23706"> NEW ORDERS : <b>' + row.new_orders + ' </b></td><td style="color:#337ab7">PENDING ORDERS : <b>' + row.pending_orders + '</b></td></tr>';
                    htm = htm + '<tr><td style="color:#e88454">PACKED ORDERS : <b>' + row.packed_orders + '</b></td><td style="color:green">PROCESSED ORDERS : <b>' + row.processed_orders + '</b></td></tr>';
                    htm = htm + '</tbody></table>';
                    htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                $("#div_sales_list").html(htm);

                var bhtm = "";
                var common = "";
                var len = 0;
                common = common + '<option value="0">ALL BRANCH / WAREHOUSE</option>';
                $.each(response.branch_data, function (i, row) {                    
                    bhtm = bhtm + '<option value="' + row.branch_id + '">' + row.branch_name + '</option>';
                    len = i;
                });

                if (bhtm == "") { $("#Select_branch_for_process").html('<option value="0">NO BRANCH / WAREHOUSE ALLOCATED</option>'); }
                else {

                    if (len > 0) { bhtm = common + bhtm; }
                    else { bhtm = bhtm; }

                    $("#Select_branch_for_process").html(bhtm);
                }
                

            }

        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function get_individual_orders(user_id,page) {

    showpage('divListSellerOrder');
    get_sellerwise_orders(user_id, page);
    $("#id_seller").val(user_id);
}

function get_sellerwise_orders(user_id, page) {


    overlay("Loading Orders.");
    disableBackKey();
    $("#div_list_seller_orders").html('');
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_individual_orders",
        data: "{'page':'" + page + "','user_id':'" + user_id + "','branch_id':'" + $("#Select_branch_for_process").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";
            if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);
                //console.log(response);
                $.each(response.order_list, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Order_details(' + row.sm_id + ')">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7;background-color:' + color + '">' + String(row.cust_name) + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "";
                    delivery_status_image = row.sm_delivery_status == 0 && row.sm_packed == 0 ? "assets/img/neww.png" : row.sm_delivery_status == 0 && row.sm_packed == 1 ? "assets/img/packed.png" : row.sm_delivery_status == 1 ? "assets/img/processes.jpg" : row.sm_delivery_status == 2 ? "assets/img/delivered.png" : row.sm_delivery_status == 3 ? "assets/img/underReview.jpg" : row.sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : row.sm_delivery_status == 5 ? "assets/img/rejected.png" : row.sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    if (row.sm_invoice_no == "") {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No:(' + row.sm_id + ')';
                    }
                    else {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No: #' + row.sm_invoice_no + ' (' + row.sm_id + ')';

                    }
                    htm = htm + '<br /><span style="color:#337ab7"><small>Bill Amount : ' + format_currency_value(row.sm_netamount) + '</small></span></br><span class="text-danger"><small>Balance : ' + format_currency_value(row.total_balance) + '</small></span></div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.sm_date + '</small></br>';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });


                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_sord_1" onclick="javascript:get_sellerwise_orders(' + user_id + ',' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_sord_1" onclick="javascript:get_sellerwise_orders(' + user_id + ',' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_seller_orders").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_sord_1").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_sord_1").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_sord_1").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_sord_1").hide();
                }
            }

        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function get_Orders_for_delivery(page) {
   
    overlay("Loading Orders for Delivery ");
    disableBackKey();

    var postObj = {

        filters: {

            user_id: $("#appuserid").val(),
            page: page,
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Orders_for_delivery",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";
            if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);
                //console.log(JSON.parse(resp.d));
                $.each(response.order_list, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Order_details(' + row.sm_id + ')">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7;background-color:' + color + '">' + String(row.cust_name) + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "";
                    delivery_status_image = row.sm_delivery_status == 0 && row.sm_packed == 0 ? "assets/img/neww.png" : row.sm_delivery_status == 0 && row.sm_packed == 1 ? "assets/img/packed.png" : row.sm_delivery_status == 1 && row.sm_packed == 1 ? "assets/img/processes.jpg" : row.sm_delivery_status == 2 ? "assets/img/delivered.png" : row.sm_delivery_status == 3 ? "assets/img/underReview.jpg" : row.sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : row.sm_delivery_status == 5 ? "assets/img/rejected.png" : row.sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    if (row.sm_invoice_no == "") {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No:(' + row.sm_id + ')';
                    }
                    else {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No: #' + row.sm_invoice_no + ' (' + row.sm_id + ')';

                    }
                    htm = htm + '<br /><span style="color:#337ab7"><small>Bill Amount : ' + format_currency_value(row.sm_netamount) + '</small></span></br><span class="text-danger"><small>Balance : ' + format_currency_value(row.total_balance) + '</small></span></div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.sm_date + '</small></br>';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod" onclick="javascript:get_Orders_for_delivery(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod" onclick="javascript:get_Orders_for_delivery(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#divOrderstobeDelivered").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_lod").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod").hide();
                }
            }

        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function show_cart_page() {

    showpage('div_item_cart');
    $("#cartList").html("");
    $("#txtsearch_in_cart").val("");
    list_items_Cart(1);
}

function list_items_Cart(page) {

   
    var searchString = $("#txtsearch_in_cart").val();
    
    var perPage = 10;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_item_cart where itm_name like '%" + searchString + "%'";
        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            if (totalRows == 1) { $("#lbl_cart_item_count").html('( ' + totalRows + ' Item)'); } else { $("#lbl_cart_item_count").html('( ' + totalRows + ' Items)'); }
            totPages = Math.ceil(totalRows / perPage);
            var selectItems = "select * from tbl_item_cart " +
            " where itm_name like '%" + searchString + "%' limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;
                
                if (len == 0) {
                    $("#lbl_cart_item_count").html('( No Items)');
                    //htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                    //htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    //htm = htm + '<div class="avatar">';
                    //htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    //htm = htm + '</div> </div>';
                    //htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Items Found in your cart!';
                    //htm = htm + '<span class="text-success"><small></small></span>';
                    //htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                    
                    //$("#cart_serach_box").hide();
                    
                    $("#cartList").html(htm);
                    $("#nOfItems").html('No Results');

                    return;
                }
                if (len > 0) {

                    //if (len == 1) { $("#lbl_cart_item_count").html('( ' + len + ' Item)'); } else { $("#lbl_cart_item_count").html('( ' + len + ' Items)'); }
                   
                    //$("#cart_serach_box").show();

                    var foc_color = 0;
                    var price_color = 0;
                    var discount_color = 0;
                    var bordercolor = 0;

                    for (var i = 0; i < len; i++) {

                            if ($("#ss_price_change").val() == "1") {

                                if (parseFloat(res.rows.item(i).si_price) < parseFloat(res.rows.item(i).si_org_price)) { price_color = "#CA0E0E"; bordercolor = 1; } else if (parseFloat(res.rows.item(i).si_price) > parseFloat(res.rows.item(i).si_org_price)) { price_color = "#06b606"; bordercolor = 1; } else { price_color = "#635c5c"; }
                            }
                            if ($("#ss_discount_change").val() == "1") {

                                if (parseFloat(res.rows.item(i).si_discount_rate) > 0) { discount_color = "#CA0E0E"; bordercolor = 1; } else { discount_color = "#635c5c"; }
                            }
                            if ($("#ss_foc_change").val() == "1") {

                                if (parseInt(res.rows.item(i).si_foc) > 0) { foc_color = "#CA0E0E"; bordercolor = 1; } else { foc_color = "#635c5c"; }
                            }

                            if (bordercolor == 1) { bordercolor = "#CA0E0E" } else { bordercolor = "#337ab7"; }

                        var color = 0;
                        var image = "";
                        var itm_num = ((perPage * (page - 1)) + (i + 1))
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid '+bordercolor+'" onclick="javascript:load_item_details_to_edit(' + String(res.rows.item(i).itbs_id) + ');">';
                        htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:' + bordercolor + '">[<i class="ti-pencil"></i>] #' + itm_num + ' - <b>' + String(res.rows.item(i).itm_name) + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                        htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                        htm = htm + '<tr><td style="color:' + price_color + '"> Price : <b>' + format_currency_value(res.rows.item(i).si_price) + ' </b></td><td>Qty : <b>' + String(res.rows.item(i).si_qty) + '</b></td><td style="color:#337ab7">Tax : <b>' + format_currency_value(res.rows.item(i).si_tax_amount) + ' (' + String(res.rows.item(i).si_item_tax) + '%)</b></td></tr>';
                        htm = htm + '<tr><td style="color:' + discount_color + '">Discount : <b>' + String(res.rows.item(i).si_discount_rate) + '%</b></td><td style="color:' + foc_color + '">FOC : <b>' + String(res.rows.item(i).si_foc) + '</b></td><td style="color:#337ab7">Total : <b>' + format_currency_value(res.rows.item(i).si_net_amount) + '</b></td></tr>       ';
                        htm = htm + '</tbody></table>';
                        htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_crt" onclick="javascript:list_items_Cart(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_crt" onclick="javascript:list_items_Cart(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';

                    $("#cartList").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);


                    if (page > 1) {
                        $("#btnPrev_crt").show();
                    }
                    if (page < totPages) {
                        $("#btnNext_crt").show();
                    }
                    if (totPages == 1) {
                        $("#btnNext_crt").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext_crt").hide();
                    }

                }

            });

        });

        
        var selecttotals = "select SUM(si_net_amount) as net_total,SUM(si_tax_amount) as total_tax, SUM(si_approval_status) as is_to_be_confirm from tbl_item_cart";
        tx.executeSql(selecttotals, [], function (tx, res) {
           
            var len = res.rows.length;
            if (len == 0) {

            }
            if (len > 0) {
                if (res.rows.item(0).net_total == null) {

                    $("#btn_continue_to_last_step").hide();
                    $("#lbl_total_values").html('<br /><small style="color:#635c5c"> NO ITEMS FOUND IN THE CART</small>');
                }
                else {
                    $("#btn_continue_to_last_step").show();
                    $("#lbl_total_values").html('NET TOTAL : ' + format_currency_value(res.rows.item(0).net_total) + '<br /><small style="color:#635c5c"> TAX AMOUNT : ' + format_currency_value(res.rows.item(0).total_tax) + ' (Inc. in net total)</small>');
                    $("#lbl_ord_nt_amt").html('<small style="color:#337ab7">NET AMOUNT<br /></small>' + format_currency_value(res.rows.item(0).net_total) + '');
                    $("#lbl_ord_balance").html('<small style="color:#b53131">BALANCE<br /></small>' + format_currency_value(res.rows.item(0).net_total) + '');
                    $("#order_total").val(format_decimal_accuray(res.rows.item(0).net_total));
                    $("#order_balance").val(format_decimal_accuray(res.rows.item(0).net_total));
                    $("#order_total_tax").val(format_decimal_accuray(res.rows.item(0).total_tax));
                    $("#order_is_to_be_confirm").val(res.rows.item(0).is_to_be_confirm);
                
                }
            }

        });

    });


}

function show_complete_orderpage() {

    var db = getDB();
    db.transaction(function (tx) {

        var selectcustomer = "select * from tbl_customer";
        tx.executeSql(selectcustomer, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {

            }
            if (len > 0) {

                $("#lbl_ord_cust_name").html(res.rows.item(0).cust_name + ' </br> <small> ' + res.rows.item(0).cust_address+','+res.rows.item(0).cust_city +' </small>');
                showpage('div_finalize_order');
                var htm = "";
                if ($("#order_is_to_be_confirm").val() == "1") {

                    htm = htm + '<option value="3">Requires Confirmation</option>';
                    $("#Select_order_status").html(htm);
                    //$("#Select_order_status").val('3');
                    $("#SelectOrderPayMethod").prop('disabled', 'disabled');
                    $("#txt_current_payment_with_order").prop('disabled', 'disabled');
                    validation_alert("This order requires approval from admin!");
                }
                else {

                    htm = htm + '<option value="0">New Order</option>';
                    htm = htm + '<option value="2">Delivered</option>';

                    $("#Select_order_status").html(htm)
                    $("#SelectOrderPayMethod").prop('disabled', false);
                    $("#txt_current_payment_with_order").prop('disabled', false);
                    if ($("#ss_direct_delivery").val() == "0") { $("#Select_order_status").val('0') } else { $("#Select_order_status").val('2') }
                }
                
                $("#Select_customer_pay_types").val($("#ss_payment_type").val());
                $("#SelectOrderPayMethod").val('0');
                swapPayment_typeDivs();
                $("#txt_ord_cheque_number").val('');
                $("#txt_ord_cheque_date").val('');
                $("#txt_ord_cheque_bank").val('');
                $("#txt_ord_note").val('');
                $("#txt_current_payment_with_order").val('');
                calculate_order_balance();
                
            }

        });

    });


    
    
}

function calculate_order_balance() {

    var is_wallet_used = false;
    if (is_wallet_used == false) {

        var payment = $("#txt_current_payment_with_order").val();
        if (payment == "") { payment = 0; }
        var net_total = format_decimal_accuray(parseFloat($("#order_total").val()));
        payment = format_decimal_accuray(parseFloat(payment));
        var balance = net_total - payment;
        $("#order_balance").val(format_decimal_accuray(balance));
        $("#lbl_ord_balance").html('<small style="color:#b53131">BALANCE<br /></small>' + format_currency_value(balance) + '');

    }
    else { }

}

function save_order_offline() {

    var current_order_balance = parseFloat($("#order_balance").val());
    var max_credit_amount = parseFloat($("#cust_max_credit_allowed").val());
    var current_customer_credit = parseFloat($("#cust_current_outstanding").val());

    var total_credit = current_order_balance + current_customer_credit;
    if (total_credit > max_credit_amount) {

        bootbox.confirm({
            size: 'small',
            message: 'Customer credit exceeded! Maximum credit allowed for this customer is ' + format_currency_value(max_credit_amount) + ' and credit wiil be ' + format_currency_value(total_credit) + ' after placing this order. Would you like to increase the customer max credit amount?',
            callback: function (result) {
                if (result == false) {
                    backcount = 0;
                    return;
                } else {

                    show_Class_Credit_page();
                }
            }
        });

    }
    else {

        bootbox.confirm({
            size: 'small',
            message: 'Are you sure to place order ?',
            callback: function (result) {
                if (result == false) {
                    backcount = 0;
                    return;
                } else {
                    var db = getDB();
                    db.transaction(function (tx) {

                        var selectTrans = "select sessionId from tbl_sales_master where sessionId='" + current_session_id + "'";
                        tx.executeSql(selectTrans, [], function (tx, res) {

                            var item_list = "";
                            var len = res.rows.length;
                            if (len > 0) {

                                $("#div_finalize_order").hide();
                                $("#hdnCurrentDiv").val('homepage');
                                showMyOrders(1);
                                //alert("ALREADY EXISTS");

                                return;

                            }
                            else {

                                var total_paid = 0;
                                fixquotes();

                                // to check to be confirmed order // 1 - pending , 0 - new order
                                var sm_delivery_status = $('#Select_order_status').val();
                                if ($("#order_is_to_be_confirm").val() != "0") {

                                    sm_delivery_status = "3";
                                    $("#txt_current_payment_with_order").val("0");
                                    total_paid = 0;
                                }
                                else {

                                    total_paid = $("#txt_current_payment_with_order").val();
                                    if (total_paid == "") { total_paid = 0; }
                                    total_paid = format_decimal_accuray(total_paid);
                                }

                                var bill_payment_mode = 0;
                                var sm_cash_amt = 0;
                                var sm_wallet_amt = 0;
                                var sm_chq_amt = 0;
                                var sm_chq_date = 0;
                                var sm_bank = 0;
                                var sm_chq_no = 0;
                                var branch_tax_method = $("#br_tax_method").val();
                                var branch_tax_inclusive = $("#br_tax_inclusive").val();

                                var branch = $("#Select_Access_Branch").val();
                                var sm_userid = $("#appuserid").val();
                                var cust_id = $('#customer_id').val();
                                var sm_specialnote = $('#txt_current_payment_with_order').val();
                                var sm_latitude = Latitude;
                                var sm_longitude = Longitude;
                                var sm_order_type = $("#Select_order_type").val();
                                var sm_payment_type = $("#Select_customer_pay_types").val();

                                var sm_total = $("#order_total").val();
                                var sm_discount_rate = 0;
                                var sm_discount_amount = 0;
                                var sm_netamount = $("#order_total").val();
                                var total_balance = $("#order_balance").val();
                                var sm_tax_amount = $("#order_total_tax").val();
                                var sm_price_class = $("#sm_price_class").val();

                               
                                    bill_payment_mode = $("#SelectOrderPayMethod").val(); // 1- cash , 2- cheque

                                    if (bill_payment_mode == "0") { // cash payment

                                        sm_cash_amt = $('#txt_current_payment_with_order').val();
                                        if (sm_cash_amt == "") {

                                            sm_cash_amt = 0.00;
                                            sm_cash_amt = format_decimal_accuray(sm_cash_amt);
                                        }
                                        //sm_wallet_amt = $('#usingWalletAmt').val();

                                    }
                                    else { //  cheque payment

                                        sm_chq_amt = $("#txt_current_payment_with_order").val();
                                        if (sm_chq_amt == "") { sm_chq_amt = 0.00; }
                                        else { sm_chq_amt = format_decimal_accuray(sm_chq_amt); }

                                        sm_bank = $('#txt_ord_cheque_bank').val();
                                        sm_chq_date = $('#txt_ord_cheque_date').val();
                                        sm_chq_date = dateformat(sm_chq_date);
                                        sm_chq_no = $('#txt_ord_cheque_number').val();
                                        //  sm_wallet_amt = $('#usingWalletAmt').val();

                                        if (sm_chq_amt == "") { sm_chq_amt = 0.00; }

                                        if (sm_chq_amt > 0) {

                                            if (sm_bank == null || sm_bank == "") { validation_alert('Please enter bank name'); return; }
                                            if ($('#txt_ord_cheque_date').val() == null || $('#txt_ord_cheque_date').val() == "" || $('#txt_ord_cheque_date').val() == undefined) { validation_alert('Please enter cheque date'); return; }
                                            if (sm_chq_no == null || sm_chq_no == "") { validation_alert('Please enter cheque number'); return; }
                                        }
                                    }
                                    var trans_date = offline_get_date_time();
                                    var slmasterInsert = "INSERT INTO tbl_sales_master(sm_id,sessionId,sm_date,sm_cash_amt,sm_wallet_amt,sm_chq_amt,sm_chq_date,sm_bank ,sm_chq_no,branch_tax_method,branch_tax_inclusive,branch,sm_userid,cust_id,sm_delivery_status,sm_specialnote,sm_latitude,sm_longitude,sm_order_type,sm_payment_type,sm_total,sm_discount_rate,sm_discount_amount,sm_netamount,total_paid,total_balance,sm_tax_amount,sm_action_type,sm_sync_status,sm_type,customer_status,sm_price_class,is_new_registration) VALUES ('" + current_session_id + "','" + current_session_id + "','" + trans_date + "','" + sm_cash_amt + "','" + sm_wallet_amt + "','" + sm_chq_amt + "','" + sm_chq_date + "','" + sm_bank + "','" + sm_chq_no + "','" + branch_tax_method + "','" + branch_tax_inclusive + "','" + branch + "','" + sm_userid + "','" + cust_id + "','" + sm_delivery_status + "','" + sm_specialnote + "','" + sm_latitude + "','" + sm_longitude + "','" + sm_order_type + "','" + sm_payment_type + "','" + sm_total + "','" + sm_discount_rate + "','" + sm_discount_amount + "','" + sm_netamount + "','" + total_paid + "','" + total_balance + "','" + sm_tax_amount + "','0','0','1','0','" + sm_price_class + "','" + $("#is_new_registration").val() + "')";

                                    tx.executeSql(slmasterInsert, [], function (tx, res) {

                                        var selectTrans = "select * from tbl_item_cart";
                                        tx.executeSql(selectTrans, [], function (tx, res) {

                                            var item_list = "";
                                            var len = res.rows.length;
                                            if (len == 0) {

                                                return;
                                            }
                                            if (len > 0) {

                                                var item_inser_qry = "INSERT INTO tbl_sales_items (sm_id,itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type,itbs_stock,brand_name) VALUES "
                                                var item_string = "";

                                                for (var i = 0; i < len; i++) {

                                                    item_string = item_string + "('" + current_session_id + "', '" + res.rows.item(i).itbs_id + "','" + res.rows.item(i).itm_code + "', '" + res.rows.item(i).itm_name + "','" + res.rows.item(i).si_org_price + "','" + res.rows.item(i).si_price + "','" + res.rows.item(i).si_qty + "','" + res.rows.item(i).si_total + "','" + res.rows.item(i).si_discount_rate + "','" + res.rows.item(i).si_discount_amount + "','" + res.rows.item(i).si_net_amount + "','" + res.rows.item(i).si_foc + "','" + res.rows.item(i).si_approval_status + "','" + res.rows.item(i).itm_commision + "','" + res.rows.item(i).itm_commisionamt + "','" + res.rows.item(i).si_itm_type + "','" + res.rows.item(i).si_item_tax + "','" + res.rows.item(i).si_item_cess + "','" + res.rows.item(i).si_tax_excluded_total + "','" + res.rows.item(i).si_tax_amount + "','" + res.rows.item(i).itm_type + "','" + res.rows.item(i).itbs_stock + "','" + res.rows.item(i).brand_name + "'),";
                                                }
                                                item_string = item_string.replace(/,\s*$/, "");
                                                item_inser_qry = item_inser_qry + item_string;
                                                // alert(item_inser_qry);
                                                tx.executeSql(item_inser_qry, [], function (tx, res) {

                                                    var update_tbl_cust_branch_amounts = "UPDATE tbl_customer SET cust_amount=(cust_amount+" + total_balance + ") where cust_id='" + $("#customer_id").val() + "'";
                                                    tx.executeSql(update_tbl_cust_branch_amounts, [], function (tx, res) {

                                                        successalert('ORDER SAVED SUCCESSFULLY');
                                                        $("#div_finalize_order").hide();
                                                        $("#hdnCurrentDiv").val('homepage');
                                                        show_Customer_Details($("#customer_id").val());

                                                    },
                                                        function (e) {

                                                            alert(e.message);
                                                        });


                                                }, function (e) {

                                                    tx.executeSql("delete from tbl_sales_master WHERE sm_id='" + current_session_id + "'");
                                                    alert(e.message);


                                                });


                                            }
                                        });



                                    },


                                    function (e) {

                                        alert(e.message);


                                    });

                            }

                        });



                    }, function (e) {

                        alert(e.message);

                    });
                }
            }
        });
    }
}

function swapPayment_typeDivs() {

    if ($("#SelectOrderPayMethod").val() == "0") { $("#dv_cheque_details_at_order").hide() }
    else {
        $("#dv_cheque_details_at_order").show();
        $(function () {

            var yyyy = new Date().getFullYear();

            $('#txt_ord_cheque_date').scroller({
                preset: 'date',
                endYear: yyyy + 1,
                setText: 'Select',
                invalid: {},
                theme: 'android-ics',
                display: 'modal',
                mode: 'scroller',
                //  dateFormat :'yy/mm/dd'
                dateFormat: 'dd-mm-yy'
            });
        });

    }
}

function show_Order_details(ord_id) {

    $("#order_id").val(ord_id);
    $("#cust_wallet_amount").val("0");
    fetch_full_order_details();
}

var delivery_data = "";
var vehicle_data = "";
function fetch_full_order_details() {

    delivery_data = "";
    vehicle_data = "";

    var order_id = $("#order_id").val();
    $("#is_online_action").val('1');
    var ld_order_dialog = bootbox.dialog({
        message: '<div align=center id="simage" style="margin-top:0px;margin-bottom:0px"><p class="text-center" style="color:#337ab7;margin-top:0px;margin-bottom:0px"><i class="ti-exchange-vertical blink-image"></i><i class="ti-mobile blink-image"></i>  Loading order details </p></div>',
        closeButton: false
    });

    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/fetch_full_order_details",
        data: "{'order_id':'" + order_id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            enableBackKey();
            setTimeout(function () {
                ld_order_dialog.find(ld_order_dialog.modal('hide'));
            }, 1000);
            if (msg.d == "N") {

                validation_alert("No Data Found");                
                return;
            } else {

                var htm = "";
                var obj = JSON.parse(msg.d);
                var amount_in_wallet = 0;

                var needDisplay = "none";
                $.each(obj.order, function (i, row) {

                    $("#order_load_type").val('1');
                    $("#order_packing_status").val(row.sm_packed);
                    $("#customer_id").val(row.cust_id);
                    $("#sm_price_class").val(row.sm_price_class);
                    var class_type = row.sm_price_class;
                    if (class_type == "1") { class_type = "CLASS A"; }
                    else if (class_type == "2") { class_type = "CLASS B"; }
                    else if (class_type == "3") { class_type = "CLASS C"; }
                    $("#spanPriceCLass").html('Price Group : ' + class_type + '');
                    if (row.sm_invoice_no != "") {
                        $("#over_orderid").html('Bill No : #' + row.sm_invoice_no + ' (' + order_id + ')');
                    }
                    else {
                        $("#over_orderid").html('Bill No : (' + order_id + ')');
                    }
                    $("#current_sm_type").val(row.sm_type);
                    $("#over_orderdate").html(row.sm_date);
                    $("#over_storename").html(row.cust_name + '<br><a href="#"><small style="color:grey" id="over_address"></small></a>');
                    $("#over_address").html(row.cust_address + ',' + row.cust_city);
                    $("#newbalanceafter").html(format_currency_value(row.total_balance));
                    $("#over_billamt").html(format_currency_value(row.sm_netamount));
                    $("#over_tax_amount").html(format_currency_value(row.sm_tax_amount) + ' <small>(Inc. in total)</small>');
                    
                    var delivery_status_image = "";
                    delivery_status_image = row.sm_delivery_status == 0 && row.sm_packed == 0 ? "assets/img/neww.png" : row.sm_delivery_status == 0 && row.sm_packed == 1 ? "assets/img/packed.png" : row.sm_delivery_status == 1 ? "assets/img/processes.jpg" : row.sm_delivery_status == 2 ? "assets/img/delivered.png" : row.sm_delivery_status == 3 ? "assets/img/underReview.jpg" : row.sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : row.sm_delivery_status == 5 ? "assets/img/rejected.png" : row.sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                    $("#over_image").html('<img  src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive" style="width: 40px;">');


                    $("#order_branch_id").val(row.branch_id);
                    $("#br_tax_method").val(row.branch_tax_method);
                    $("#br_tax_inclusive").val(row.branch_tax_inclusive);

                    if (row.cust_amount < 0) {

                        amount_in_wallet = (row.cust_amount) * (-1);
                        $('#cust_wallet_amount').val(amount_in_wallet);
                    }
                    else {
                        $('#cust_wallet_amount').val('0');
                    }
                    
                    htm = htm + '<div class="row"  style="display:block">';
                    //htm = htm + '<div class="col-xs-4" >Customer</div>';
                    //htm = htm + '<div class="col-xs-8">: ' + row.cust_name + '</div>';
                    
                    //if (parseFloat(row.new_creditamt) != 0) {
                    //    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Amount</div>';
                    //    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + row.max_creditamt + " To " + row.new_creditamt + '</div>';
                    //}

                    //if (parseFloat(row.new_creditperiod) != 0) {
                    //    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Period</div>';
                    //    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + row.max_creditperiod + " To " + row.new_creditperiod + '</div>';
                    //}
                    //if (parseInt(row.new_custtype) != 0) {

                    //    var oldClass = row.cust_type == 1 ? "A" : (row.cust_type == 2 ? "B" : "C");
                    //    var newClass = row.new_custtype == 1 ? "A" : (row.new_custtype == 2 ? "B" : "C");

                    //    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Class</div>';
                    //    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: Changed From ' + oldClass + " To " + newClass + '</div>';
                    //}
                    if (parseInt(row.cust_status) == 1) {
                        htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold" >Customer Type</div>';
                        htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: NEW</div>';
                    }

                    $("#spanordertype").html(row.sm_order_type == 1 ? " [ Direct ]" : row.sm_order_type == 2 ? " [ Telephonic ]" : " [ LPO ]" + '');
                    $("#spanPayType").html(row.sm_payment_type == 1 ? " [ Cash ]" : row.sm_payment_type == 2 ? " [ Credit ]" : row.sm_payment_type == 3 ? " [ Bill to bill ]" : " [ No Payment Type Specified ]" + '');

                    if (row.sm_payment_type == 0) {

                        $('#SelectspanPayType').show();
                        $('#SelectspanPayType').val(0);

                    }
                    else {

                        $('#SelectspanPayType').hide();

                    }


                    htm = htm + '</div>';
                    $("#order_current_status").val(row.sm_delivery_status);

                    needDisplay = row.sel_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Sold by</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.sel_first_name + " " + row.sel_last_name + '</div>';
                    htm = htm + '</div>';

                    var head = row.sm_delivery_status == 5 ? "Rejected By" : "Approved By";
                    needDisplay = row.app_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >' + head + '</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.app_first_name + " " + row.app_last_name + '</div>';
                    htm = htm + '<div class="col-xs-4" ></div>';
                    htm = htm + '<div class="col-xs-8">: ' + row.sm_approved_date + '</div>';
                    htm = htm + '</div>';

                    needDisplay = row.pak_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Packed by</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.pak_first_name + " " + row.pak_last_name + '</div>';
                    htm = htm + '<div class="col-xs-4" ></div>';
                    htm = htm + '<div class="col-xs-8">: ' + row.sm_packed_date + '</div>';
                    htm = htm + '</div>';

                    head = row.sm_delivery_status == 6 ? "Pending By" : "Processed By";
                    needDisplay = row.pro_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >' + head + '</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.pro_first_name + " " + row.pro_last_name + '</div>';
                    htm = htm + '<div class="col-xs-4" ></div>';
                    htm = htm + '<div class="col-xs-8">: ' + row.sm_processed_date + '</div>';
                    htm = htm + '</div>';

                    if (row.del_first_name != null) { $("#order_sel_person_for_delivery").val(row.sm_delivered_id); } else { $("#order_sel_person_for_delivery").val("0"); }
                    needDisplay = row.del_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    if (row.sm_delivery_status < 2) {
                        htm = htm + '<div class="col-xs-4" >Delivery</div>';
                    }
                    else if (row.sm_delivery_status == 2) {
                        htm = htm + '<div class="col-xs-4" >Delivered by</div>';
                    }
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.del_first_name + " " + row.del_last_name + '</div>';
                    if (row.sm_delivery_status == 2) {
                        htm = htm + '<div class="col-xs-4" ></div>';
                        htm = htm + '<div class="col-xs-8">: ' + row.sm_delivered_date + '</div>';
                    }
                    htm = htm + '</div>';

                    
                    if (row.veh_first_name == null) { $("#order_is_company_vehicle").val("0"); } else { $("#order_is_company_vehicle").val("1"); $("#order_sel_vehicle_for_delivery").val(row.sm_delivery_vehicle_id); }
                    needDisplay = row.veh_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Vehicle</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.veh_first_name + " " + row.veh_last_name + '</div>';
                    htm = htm + '</div>';

                    if (row.sm_vehicle_no != null && row.sm_vehicle_no != 0) { $("#order_sel_vehicle_for_delivery").val(row.sm_vehicle_no); $("#order_is_company_vehicle").val("0"); }
                    needDisplay = row.sm_vehicle_no == null ? "none" : row.sm_vehicle_no == 0 ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Vehicle</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.sm_vehicle_no + '</div>';
                    htm = htm + '</div>';

                    needDisplay = row.canc_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Cancelled By</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.canc_first_name + " " + row.canc_last_name + '</div>';
                    htm = htm + '<div class="col-xs-4" ></div>';
                    htm = htm + '<div class="col-xs-8">: ' + row.sm_cancelled_date + '</div>';
                    htm = htm + '</div>';


                    needDisplay = row.sm_specialnote == "" ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Special Note</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.sm_specialnote + '</div>';
                    htm = htm + '</div>';


                    $("#divOrderHandlers").html(htm);
                });

                var db = getDB();
                db.transaction(function (tx) {
                    tx.executeSql("delete from tbl_item_cart");

                    $.each(obj.items, function (i, row) {

                        var insert_tbl_cart = "INSERT INTO tbl_item_cart(itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type,itbs_stock,brand_name) VALUES ('" + row.itbs_id + "','" + row.itm_code + "','" + row.itm_name + "','" + row.si_org_price + "','" + row.si_price + "','" + row.si_qty + "','" + row.si_total + "','" + row.si_discount_rate + "','" + row.si_discount_amount + "','" + row.si_net_amount + "','" + row.si_foc + "','" + row.si_approval_status + "','" + row.itm_commision + "','" + row.itm_commisionamt + "','" + row.si_itm_type + "','" + row.si_item_tax + "','" + row.si_item_cess + "','" + row.si_tax_excluded_total + "','" + row.si_tax_amount + "','" + row.itm_type + "','0','0')";
                        tx.executeSql(insert_tbl_cart, [], function (tx, res) {
                        });
                    });                  

                },
                function (e) {

                    alert(e.message);
                }
                );

                var dhtm = "";
                var vhtm = "";

                var dhtm_common = '<option value="0">Select Person</option>';
                var vhtm_common = '<option value="0">Select Vehicle</option>';

                $.each(obj.del_data, function (i, row) {
                    if (row.user_type == "6") { vhtm = vhtm + '<option value="' + row.user_id + '">' + row.name + '</option>'; }
                    else { dhtm = dhtm + '<option value="' + row.user_id + '">' + row.name + '</option>'; }                    
                });

                if (dhtm == "") {
                    dhtm_common = '<option value="0">No Delivery Person Available</option>';
                    delivery_data = dhtm_common;
                }
                else {
                    delivery_data = dhtm_common + dhtm;
                }

                if (vhtm == "") {
                    vhtm_common = '<option value="0">No Vehicle Available</option>';
                    vehicle_data = vhtm_common;
                }
                else {
                    vehicle_data = vhtm_common + vhtm;
                }

                $("#txt_order_item_cart_search").val("");
                showpage('divOrderExpanded');
                display_order_items(1);



            }
        },
        error: function (xhr, status) {

            enableBackKey();
            ld_order_dialog.find(ld_order_dialog.modal('hide'));
            ajaxerroralert();

        }
    });






}

function display_order_items(page) {

    var searchString = $("#txt_order_item_cart_search").val();

    var perPage = 10;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_item_cart where itm_name like '%" + searchString + "%'";
        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            if (totalRows == 1) { $("#lbl_cart_item_count").html('( ' + totalRows + ' Item)'); } else { $("#lbl_cart_item_count").html('( ' + totalRows + ' Items)'); }
            totPages = Math.ceil(totalRows / perPage);
            var selectItems = "select * from tbl_item_cart " +
            " where itm_name like '%" + searchString + "%' limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;

                if (len == 0) {
                    $("#lbl_cart_item_count").html('( No Items)');
                    //htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                    //htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    //htm = htm + '<div class="avatar">';
                    //htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    //htm = htm + '</div> </div>';
                    //htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Items Found in your cart!';
                    //htm = htm + '<span class="text-success"><small></small></span>';
                    //htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    //$("#cart_serach_box").hide();

                    $("#items_in_the_order").html(htm);
                    $("#nOfItems").html('No Results');

                    return;
                }
                if (len > 0) {

                    //if (len == 1) { $("#lbl_cart_item_count").html('( ' + len + ' Item)'); } else { $("#lbl_cart_item_count").html('( ' + len + ' Items)'); }

                    //$("#cart_serach_box").show();

                    var foc_color = 0;
                    var price_color = 0;
                    var discount_color = 0;
                    var bordercolor = 0;

                    for (var i = 0; i < len; i++) {

                        if ($("#ss_price_change").val() == "1") {

                            if (parseFloat(res.rows.item(i).si_price) < parseFloat(res.rows.item(i).si_org_price)) { price_color = "#CA0E0E"; bordercolor = 1; } else if (parseFloat(res.rows.item(i).si_price) > parseFloat(res.rows.item(i).si_org_price)) { price_color = "#06b606"; bordercolor = 1; } else { price_color = "#635c5c"; }
                        }
                        if ($("#ss_discount_change").val() == "1") {

                            if (parseFloat(res.rows.item(i).si_discount_rate) > 0) { discount_color = "#CA0E0E"; bordercolor = 1; } else { discount_color = "#635c5c"; }
                        }
                        if ($("#ss_foc_change").val() == "1") {

                            if (parseInt(res.rows.item(i).si_foc) > 0) { foc_color = "#CA0E0E"; bordercolor = 1; } else { foc_color = "#635c5c"; }
                        }

                        if (bordercolor == 1) { bordercolor = "#CA0E0E" } else { bordercolor = "#337ab7"; }

                        var color = 0;
                        var image = "";
                        var itm_num = ((perPage * (page - 1)) + (i + 1))
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" onclick="javascript:changeBg(' + String(res.rows.item(i).itbs_id) + ');" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid ' + bordercolor + '">';
                        htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:' + bordercolor + '">#' + itm_num + ' - <b>' + String(res.rows.item(i).itm_name) + ' <i class="ti-check deliveredcart" style="color:green" id="divCart' + String(res.rows.item(i).itbs_id) + '"></i></b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                        htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                        htm = htm + '<tr><td style="color:' + price_color + '"> Price : <b>' + format_currency_value(res.rows.item(i).si_price) + ' </b></td><td>Qty : <b>' + String(res.rows.item(i).si_qty) + '</b></td><td style="color:#337ab7">Tax : <b>' + format_currency_value(res.rows.item(i).si_tax_amount) + ' (' + String(res.rows.item(i).si_item_tax) + '%)</b></td></tr>';
                        htm = htm + '<tr><td style="color:' + discount_color + '">Discount : <b>' + String(res.rows.item(i).si_discount_rate) + '%</b></td><td style="color:' + foc_color + '">FOC : <b>' + String(res.rows.item(i).si_foc) + '</b></td><td style="color:#337ab7">Total : <b>' + format_currency_value(res.rows.item(i).si_net_amount) + '</b></td></tr>       ';
                        htm = htm + '</tbody></table>';
                        htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_crt_ord" onclick="javascript:display_order_items(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_crt_ord" onclick="javascript:display_order_items(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';

                    $("#items_in_the_order").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);


                    if (page > 1) {
                        $("#btnPrev_crt_ord").show();
                    }
                    if (page < totPages) {
                        $("#btnNext_crt_ord").show();
                    }
                    if (totPages == 1) {
                        $("#btnNext_crt_ord").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext_crt_ord").hide();
                    }

                }

            });

        });



    });

}

function show_customer_transactions() {

    var yyyy = new Date().getFullYear();
    $('#Text_trans_from').scroller({
        preset: 'date',
        endYear: yyyy + 10,
        setText: 'Select',
        invalid: {},
        theme: 'android-ics',
        display: 'modal',
        mode: 'scroller',
        //  dateFormat :'yy/mm/dd'
        dateFormat: 'dd-mm-yy'
    });

    $('#Text_trans_to').scroller({
        preset: 'date',
        endYear: yyyy + 10,
        setText: 'Select',
        invalid: {},
        theme: 'android-ics',
        display: 'modal',
        mode: 'scroller',
        //  dateFormat :'yy/mm/dd'
        dateFormat: 'dd-mm-yy'
    });
    $('#Text_trans_from').val('');
    $('#Text_trans_to').val('');
    showpage('div_cust_transactions');
    get_customer_transactions(1);
}

function get_customer_transactions(page) {

    var htm = "";
    var postObj = {
        filters: {
            cust_id: $("#customer_id").val(),
            dateFrom: dateformat($("#Text_trans_from").val()),
            dateTo: dateformat($("#Text_trans_to").val()),
            user_id: $("#appuserid").val(),
            page:page,
        }
    };

    overlay("Loading Customer Transactions");
    disableBackKey();
    $("#div_list_all_cust_transactions").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_customer_transactions",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (response) {
            closeOverlay();
            enableBackKey();

            if (response.d == "") {
                bootbox.alert('<p style="color:red">No Transactions Found</p>');
                return;
            }
            else if (response.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Transactions Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_all_cust_transactions").html(htm);

                return;

            }
            else {

                var obj = JSON.parse(response.d);
                $.each(obj.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;">';
                    htm = htm + '<div class="col-xs-5" style="margin-top:7px;margin-bottom:5px;color:#337ab7;font-size:12px;background-color:' + color + '"><b>TXN.ID</b> :#<b>' + String(row.id) + '</b></div><div class="col-xs-7" style="float:right;text-align:right;margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '">' + row.tr_date + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "assets/img/exchange.png";
                    //delivery_status_image = row.action_type == 0 ? "assets/img/neww.png" : row.action_type == 1 ? "assets/img/packed.png" : row.action_type == 1 ? "assets/img/processes.jpg" : row.action_type == 2 ? "assets/img/delivered.png" : row.action_type == 3 ? "assets/img/underReview.jpg" : row.action_type == 4 ? "assets/img/cancelled.jpg" : row.action_type == 5 ? "assets/img/rejected.png" : row.action_type == 6 ? "assets/img/time.png" : "" + '';
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';

                    if (row.cr > 0) { htm = htm + '</div> </div><div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;"><small style="color:#337ab7">AMOUNT:</small> ' + format_currency_value(row.cr) + ' <small style="color:#337ab7">(CREDIT)</small>'; }
                    if (row.dr > 0) { htm = htm + '</div> </div><div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;"><small style="color:#337ab7">AMOUNT:</small> ' + format_currency_value(row.dr) + ' <small style="color:#337ab7">(DEBIT)</small>'; }
                   
                    var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 6 ? "DEPOSIT" : "" + '';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action Type : <b>' + action + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action By : <b>' + row.name + '</b></small></span></div>';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '"><b style="color:337ab7">Details</b> : ' + String(row.narration) + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(obj.totalRows);
                var perPage = parseInt(obj.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr" onclick="javascript:get_customer_transactions(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr" onclick="javascript:get_customer_transactions(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_all_cust_transactions").html(htm);

                if (page > 1) {
                    $("#btnPrev_lod_tr").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_tr").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_tr").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_tr").hide();
                }
            }


        },
        error: function (xhr, status) {

            closeOverlay();
            load_follow_ups_offline();
            enableBackKey();
            ajaxerroralert();
            onBackMove();
        }
    });
}

function show_offline_order_page(order_id) {

    $("#order_id").val(order_id);
    $("#current_sm_type").val('1');
    load_offline_order_details();
}

function load_offline_order_details() {

    var order_id = $("#order_id").val();
    $("#is_online_action").val('2');
    var db = getDB();
    db.transaction(function (tx) {

        var htm = "";
        var amount_in_wallet = 0;

        var select_items = "select cu.cust_id,sm.sm_id as order_id,sm.sm_date,cu.cust_name,cu.cust_address,cu.cust_city,sm.total_balance,sm.sm_netamount,sm.sm_tax_amount,sm.sm_delivery_status,sm.branch,sm.branch_tax_method,sm.branch_tax_inclusive,cu.cust_amount,cu.new_creditamt,cu.max_creditamt,cu.cust_type,cu.new_custtype,cu.max_creditperiod,cu.new_creditperiod,sm.sm_order_type,sm.sm_payment_type,cu.cust_status,sm.sm_price_class from tbl_sales_master sm join tbl_customer cu on sm.cust_id=cu.cust_id WHERE sm_id='" + order_id + "'";
        tx.executeSql(select_items, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {

                var itemAdded = bootbox.dialog({
                    message: '<p class="text-center" style="color:red"><i class="ti-info"></i> No info found!</p>',
                    closeButton: false
                });
                onBackKeyDown();
                setTimeout(function () {
                    itemAdded.find(itemAdded.modal('hide'));
                }, 1500);
            }
            if (len > 0) {

                var needDisplay = "none";
                
                $("#customer_id").val(res.rows.item(0).cust_id);
                $("#sm_price_class").val(res.rows.item(0).sm_price_class);

                var class_type = res.rows.item(0).sm_price_class;
                if (class_type == "1") { class_type = "CLASS A"; }
                else if (class_type == "2") { class_type = "CLASS B"; }
                else if (class_type == "3") { class_type = "CLASS C"; }
                $("#spanPriceCLass").html('Price Group : ' + class_type + '');
                $("#over_orderid").html('TEMP ORD ID : (' + order_id + ')');
                $("#over_orderdate").html(res.rows.item(0).sm_date);
                $("#over_storename").html(res.rows.item(0).cust_name + '<br><a href="#"><small style="color:grey" id="over_address"></small></a>');
                $("#over_address").html(res.rows.item(0).cust_address + ',' + res.rows.item(0).cust_city);
                $("#newbalanceafter").html(format_currency_value(res.rows.item(0).total_balance));
                $("#over_billamt").html(format_currency_value(res.rows.item(0).sm_netamount));
                $("#over_tax_amount").html(format_currency_value(res.rows.item(0).sm_tax_amount) + ' <small>(Inc. in total)</small>');

                var delivery_status_image = "";
                delivery_status_image = res.rows.item(0).sm_delivery_status == 0 ? "assets/img/neww.png" : res.rows.item(0).sm_delivery_status == 2 ? "assets/img/delivered.png" : res.rows.item(0).sm_delivery_status == 3 ? "assets/img/underReview.jpg" : res.rows.item(0).sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : res.rows.item(0).sm_delivery_status == 5 ? "assets/img/rejected.png" : res.rows.item(0).sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                $("#over_image").html('<img  src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive" style="width: 40px;">');


                $("#order_branch_id").val(res.rows.item(0).branch);
                $("#br_tax_method").val(res.rows.item(0).branch_tax_method);
                $("#br_tax_inclusive").val(res.rows.item(0).branch_tax_inclusive);

                if (res.rows.item(0).cust_amount < 0) {

                    amount_in_wallet = (res.rows.item(0).cust_amount) * (-1);
                    $('#cust_wallet_amount').val(amount_in_wallet);
                }
                else {
                    $('#cust_wallet_amount').val('0');
                }

                htm = htm + '<div class="row"  style="display:block">';
                //htm = htm + '<div class="col-xs-4" >Customer</div>';
                //htm = htm + '<div class="col-xs-8">: ' + res.rows.item(0).cust_name + '</div>';

                if (parseFloat(res.rows.item(0).new_creditamt) != 0) {
                    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Amount</div>';
                    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + res.rows.item(0).max_creditamt + " To " + res.rows.item(0).new_creditamt + '</div>';
                }

                if (parseFloat(res.rows.item(0).new_creditperiod) != 0) {
                    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Period</div>';
                    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + res.rows.item(0).max_creditperiod + " To " + res.rows.item(0).new_creditperiod + '</div>';
                }
                if (parseInt(res.rows.item(0).new_custtype) != 0) {

                    var oldClass = res.rows.item(0).cust_type == 1 ? "A" : (res.rows.item(0).cust_type == 2 ? "B" : "C");
                    var newClass = res.rows.item(0).new_custtype == 1 ? "A" : (res.rows.item(0).new_custtype == 2 ? "B" : "C");

                    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Class</div>';
                    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: Changed From ' + oldClass + " To " + newClass + '</div>';
                }
                if (parseInt(res.rows.item(0).cust_status) == 1) {
                    htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold" >Customer Type</div>';
                    htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: NEW</div>';
                }

                $("#spanordertype").html(res.rows.item(0).sm_order_type == 1 ? " [ Direct ]" : res.rows.item(0).sm_order_type == 2 ? " [ Telephonic ]" : " [ LPO ]" + '');
                $("#spanPayType").html(res.rows.item(0).sm_payment_type == 1 ? " [ Cash ]" : res.rows.item(0).sm_payment_type == 2 ? " [ Credit ]" : res.rows.item(0).sm_payment_type == 3 ? " [ Bill to bill ]" : " [ No Payment Type Specified ]" + '');

                if (res.rows.item(0).sm_payment_type == 0) {

                    $('#SelectspanPayType').show();
                    $('#SelectspanPayType').val(0);

                }
                else {

                    $('#SelectspanPayType').hide();

                }

                htm = htm + '</div>';
                $("#order_current_status").val(res.rows.item(0).sm_delivery_status);

                needDisplay = res.rows.item(0).sm_specialnote == "" ? "none" : res.rows.item(0).sm_specialnote == null ? "none" : res.rows.item(0).sm_specialnote == undefined ? "none" : "block";
                htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                htm = htm + '<div class="col-xs-4" >Special Note</div>';
                htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + res.rows.item(0).sm_specialnote + '</div>';
                htm = htm + '</div>';

                $("#divOrderHandlers").html(htm);

            }
        });

        tx.executeSql("delete from tbl_item_cart");
        var select_items = "select * from tbl_sales_items WHERE sm_id='" + order_id + "'";
        tx.executeSql(select_items, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {

                var itemAdded = bootbox.dialog({
                    message: '<p class="text-center" style="color:red"><i class="ti-info"></i> Cart is Empty</p>',
                    closeButton: false
                });
                onBackKeyDown();
                setTimeout(function () {
                    itemAdded.find(itemAdded.modal('hide'));
                }, 1500);

            }
            if (len > 0) {
               
                for (var i = 0; i < len; i++) {

                    var insert_tbl_cart = "INSERT INTO tbl_item_cart(itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type,itbs_stock,brand_name) VALUES ('" + res.rows.item(i).itbs_id + "','" + res.rows.item(i).itm_code + "','" + res.rows.item(i).itm_name + "','" + res.rows.item(i).si_org_price + "','" + res.rows.item(i).si_price + "','" + res.rows.item(i).si_qty + "','" + res.rows.item(i).si_total + "','" + res.rows.item(i).si_discount_rate + "','" + res.rows.item(i).si_discount_amount + "','" + res.rows.item(i).si_net_amount + "','" + res.rows.item(i).si_foc + "','" + res.rows.item(i).si_approval_status + "','" + res.rows.item(i).itm_commision + "','" + res.rows.item(i).itm_commisionamt + "','" + res.rows.item(i).si_itm_type + "','" + res.rows.item(i).si_item_tax + "','" + res.rows.item(i).si_item_cess + "','" + res.rows.item(i).si_tax_excluded_total + "','" + res.rows.item(i).si_tax_amount + "','" + res.rows.item(i).itm_type + "','0','0')";
                    tx.executeSql(insert_tbl_cart, [], function (tx, res) {
                    });
                }
            }
        }
        );
    
    },
    function (e) {

        alert(e.message);
    }
    );

    $("#txt_order_item_cart_search").val("");
    display_order_items(1);
    showpage('divOrderExpanded');
}

function load_items_for_edit() {

    var sm_type = $("#current_sm_type").val();
    if (sm_type == "2") { validation_alert("Edit functionality is unavailable for older entry"); return; }
    else {
        if ($("#order_current_status").val() != "4" && $("#order_current_status").val() != "5") {
            // load items to tbl_edit_cart    
            var db = getDB();
            db.transaction(function (tx) {

                tx.executeSql("delete from tbl_edit_cart");
                tx.executeSql("INSERT INTO tbl_edit_cart SELECT * FROM tbl_item_cart");
                showpage('divEditCart');
                list_Edit_cart(1);

            },
            function (e) {

                alert(e.message);
            }
            );
        }
        else {

            if ($("#order_current_status").val() != "4") { validation_alert("Cancelled order cannot be edited! Please contact admin."); } else { validation_alert("Cancelled order cannot be edited! Please change the status and try again."); }
        }
    }

}

function list_Edit_cart(page) {


    var searchString = $("#txtsearch_in_edit_cart").val();

    var perPage = 10;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_edit_cart where itm_name like '%" + searchString + "%'";
        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            if (totalRows == 1) { $("#lbl_total_editcart_values").html('( ' + totalRows + ' Item)'); } else { $("#lbl_total_editcart_values").html('( ' + totalRows + ' Items)'); }
            totPages = Math.ceil(totalRows / perPage);
            var selectItems = "select * from tbl_edit_cart " +
            " where itm_name like '%" + searchString + "%' limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;

                if (len == 0) {
                    $("#lbl_total_editcart_values").html('( No Items)');
                   // $("#div_edit_cart_search").hide();
                    $("#div_edited_cart_list").html(htm);

                    return;
                }
                if (len > 0) {

                    //if (len == 1) { $("#lbl_total_editcart_values").html('( ' + len + ' Item)'); } else { $("#lbl_total_editcart_values").html('( ' + len + ' Items)'); }

                    $("#div_edit_cart_search").show();

                    var foc_color = 0;
                    var price_color = 0;
                    var discount_color = 0;
                    var bordercolor = 0;

                    for (var i = 0; i < len; i++) {

                        if ($("#ss_price_change").val() == "1") {

                            if (parseFloat(res.rows.item(i).si_price) < parseFloat(res.rows.item(i).si_org_price)) { price_color = "#CA0E0E"; bordercolor = 1; } else if (parseFloat(res.rows.item(i).si_price) > parseFloat(res.rows.item(i).si_org_price)) { price_color = "#06b606"; bordercolor = 1; } else { price_color = "#635c5c"; }
                        }
                        if ($("#ss_discount_change").val() == "1") {

                            if (parseFloat(res.rows.item(i).si_discount_rate) > 0) { discount_color = "#CA0E0E"; bordercolor = 1; } else { discount_color = "#635c5c"; }
                        }
                        if ($("#ss_foc_change").val() == "1") {

                            if (parseInt(res.rows.item(i).si_foc) > 0) { foc_color = "#CA0E0E"; bordercolor = 1; } else { foc_color = "#635c5c"; }
                        }

                        if (bordercolor == 1) { bordercolor = "#CA0E0E" } else { bordercolor = "#337ab7"; }

                        var color = 0;
                        var image = "";
                        var itm_num = ((perPage * (page - 1)) + (i + 1))
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid ' + bordercolor + '" onclick="javascript:edit_load_item_details_to_edit(' + String(res.rows.item(i).itbs_id) + ');">';
                        htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:' + bordercolor + '">[<i class="ti-pencil"></i>] #' + itm_num + ' - <b>' + String(res.rows.item(i).itm_name) + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                        htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                        htm = htm + '<tr><td style="color:' + price_color + '"> Price : <b>' + format_currency_value(res.rows.item(i).si_price) + ' </b></td><td>Qty : <b>' + String(res.rows.item(i).si_qty) + '</b></td><td style="color:#337ab7">Tax : <b>' + format_currency_value(res.rows.item(i).si_tax_amount) + ' (' + String(res.rows.item(i).si_item_tax) + '%)</b></td></tr>';
                        htm = htm + '<tr><td style="color:' + discount_color + '">Discount : <b>' + String(res.rows.item(i).si_discount_rate) + '%</b></td><td style="color:' + foc_color + '">FOC : <b>' + String(res.rows.item(i).si_foc) + '</b></td><td style="color:#337ab7">Total : <b>' + format_currency_value(res.rows.item(i).si_net_amount) + '</b></td></tr>       ';
                        htm = htm + '</tbody></table>';
                        htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_crt_edi" onclick="javascript:list_Edit_cart(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_crt_edi" onclick="javascript:list_Edit_cart(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';

                    $("#div_edited_cart_list").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);


                    if (page > 1) {
                        $("#btnPrev_crt_edi").show();
                    }
                    if (page < totPages) {
                        $("#btnNext_crt_edi").show();
                    }
                    if (totPages == 1) {
                        $("#btnNext_crt_edi").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext_crt_edi").hide();
                    }

                }

            });

        });

        var selecttotals = "select SUM(si_net_amount) as net_total,SUM(si_tax_amount) as total_tax, SUM(si_approval_status) as is_to_be_confirm from tbl_edit_cart";
        tx.executeSql(selecttotals, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {

            }
            if (len > 0) {
                if (res.rows.item(0).net_total == null) {

                    $("#btnrtn_continue_to_last_step").hide();
                    $("#lbl_edited_cart_amount").html('<br /><small style="color:#635c5c"> NO ITEMS FOUND IN THE CART</small>');
                }
                else {
                    $("#btnrtn_continue_to_last_step").show();
                    $("#lbl_edited_cart_amount").html('NET TOTAL : ' + format_currency_value(res.rows.item(0).net_total) + '<br><small>Tax Amount : ' + format_currency_value(res.rows.item(0).total_tax) + '</small>');
                    $("#order_total").val(format_decimal_accuray(res.rows.item(0).net_total));
                    $("#order_total_tax").val(format_decimal_accuray(res.rows.item(0).total_tax));
                }
            }

        });       

    });


}

function edit_load_item_details_to_add(itbs_id) {

    if (ispopupshown == 0) {

        popuploaded();
        var db = getDB();
        db.transaction(function (tx) {

            var class_type = $("#sm_price_class").val();
            if (class_type == "1") { class_type = "itm_class_one"; }
            else if (class_type == "2") { class_type = "itm_class_two"; }
            else if (class_type == "3") { class_type = "itm_class_three"; }

            var htm = '';
            var selectTrans = "select itbs_id,itm_name,itm_code,itbs_stock," + class_type + " as itm_price,itm_type,brand_name,itm_commision,tp_tax_percentage,tp_cess from tbl_itembranch_stock where itbs_id=" + itbs_id + " ";
            tx.executeSql(selectTrans, [], function (tx, res) {
                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    closeOverlay();
                    return;
                }
                if (len > 0) {

                    var cls_value = "";
                    var img_value = "";
                    $("#item_cal_tax_percent").val(res.rows.item(0).tp_tax_percentage);
                    $("#item_cal_cess").val(res.rows.item(0).tp_cess);
                    $("#item_cal_commision").val(res.rows.item(0).itm_commision);
                    $("#item_cal_original_price").val(res.rows.item(0).itm_price);

                    if (class_type == "itm_class_three") { cls_value = "C CLASS"; } else if (class_type == "itm_class_two") { cls_value = "B CLASS"; } else { cls_value = "A CLASS"; }
                    if (String(res.rows.item(0).itm_type) == "1") { img_value = "Add-item-icon"; } else if (String(res.rows.item(0).itm_type) == "2") { img_value = "service"; } else { img_value = "coupons"; }

                    dialog = bootbox.dialog({
                        message: '<div class="content" style="margin-bottom:2px;">' +
            '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/' + img_value + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + String(res.rows.item(0).itm_name) + '</b><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ITEM BRAND : ' + String(res.rows.item(0).brand_name) + '</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ITEM CODE : #' + String(res.rows.item(0).itm_code) + '</small></span><br />' +
            '<span class="text-danger"><small id="lbl_itmpop_itm_stock">STOCK : ' + String(res.rows.item(0).itbs_stock) + ' (Approx.)</small></span></div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ITEM QTY</label><input type="number" id="txt_item_quantity" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input integer" value="1" placeholder="Enter quantity"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">PRICE</label><input type="number" id="txt_item_price" style="font-size:17px" value="' + String(res.rows.item(0).itm_price) + '" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" placeholder="Enter price"></div></td>' +
            '</tr>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ADDITIONAL DISCOUNT %</label><input type="number" id="txt_item_discount" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" value="0.00" placeholder="Enter discount"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">FREE OF COST</label><input type="number" id="txt_item_foc" style="font-size:17px" class="form-control border-input integer" value="0" onkeyup = "javascript:calculate_item_Total();" placeholder="Enter FOC"></div></td>' +
            '</tr>' +
            '</table>' +
            '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">UNIT PRICE : ' + format_decimal_accuray(res.rows.item(0).itm_price) + ' (' + cls_value + ')<br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">TOTAL QTY (QTY + FOC) : 1</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_without_tax">ITEM TOTAL : ' + res.rows.item(0).itm_price + '</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_tax">TAX % : ' + res.rows.item(0).tp_tax_percentage + '</small></span><br />' +
            '<span class="text-danger"><small style="font-size:15px"><b id="lbl_itmpop_itm_total">NET TOTAL : 500 AED (Tax Amt. 50 AED)</b></small></span></div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="edit_add_item_to_cart(\'' + itbs_id + '\',\'' + res.rows.item(0).itm_code + '\',\'' + res.rows.item(0).itm_name + '\',\'' + res.rows.item(0).itm_type + '\',\'' + res.rows.item(0).itbs_stock + '\',\'' + res.rows.item(0).brand_name + '\')">ADD</button></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:modalClose();">CLOSE</button></td>' +
            '</tr>' +
            '</table>' +
            '</div> ',
                        closeButton: false
                    });


                    unipopup = dialog;
                    initDomEvents();
                    calculate_item_Total();
                }

            });



        });





    }


}

function edit_add_item_to_cart(itbs_id, itm_code, itm_name, itm_type, itbs_stock, brand_name) {


    var price = $("#txt_item_price").val();
    var quantity = $("#txt_item_quantity").val();
    var discount = $("#txt_item_discount").val();
    var focval = $("#txt_item_foc").val();

    if (quantity == "0" || quantity == "" || quantity == null || isNaN(quantity)) {
        validation_alert("Please enter the Quanitiy"); return;
    }
    if (discount == "" || discount == null || isNaN(discount)) {

        validation_alert("Please enter the Discount %"); return;
    }
    if (price == "" || price == null || isNaN(price)) {
        validation_alert("Please enter a valid price"); return;
    }
    if (focval == "" || focval == null || isNaN(focval)) {
        validation_alert("Please enter a valid FOC value"); return;
    }

    if (parseFloat(discount) > 100) { validation_alert("Discount cannot be more than 100%!"); return; }

    var db = getDB();
    db.transaction(function (tx) {

        var check_item_existance_qry = "SELECT itbs_id,itm_name FROM tbl_edit_cart WHERE itbs_id='" + itbs_id + "'";
        tx.executeSql(check_item_existance_qry, [], function (tx, res) {
            if (res.rows.length > 0) { // check for item existance
                validation_alert(res.rows.item(0).itm_name + ' already exists in the cart'); // item exists
                list_Edit_cart(1);
                list_items_for_sale_for_add_product(1);
                onBackKeyDown();
                modalClose();

            }
            else { // add item to cart

                var si_approval_status = 0;

                if ($("#ss_price_change").val() == "1") {

                    if (parseFloat($("#item_cal_original_price").val()) != parseFloat($("#txt_item_price").val())) { si_approval_status = 1; }
                }
                if ($("#ss_discount_change").val() == "1") {

                    if (parseFloat($("#txt_item_discount").val()) > 0) { si_approval_status = 1; }
                }
                if ($("#ss_foc_change").val() == "1") {

                    if (parseInt($("#txt_item_foc").val()) > 0) { si_approval_status = 1; }
                }
                var si_tax_excluded_total = format_decimal_accuray(parseFloat($("#itm_calc_net_total").val()) - parseFloat($("#itm_calc_tax_amount").val()));

                var insert_tbl_cart = "INSERT INTO tbl_edit_cart(itbs_id,itm_code,itm_name,si_org_price,si_price,si_qty,si_total,si_discount_rate,si_discount_amount,si_net_amount,si_foc,si_approval_status,itm_commision,itm_commisionamt,si_itm_type,si_item_tax,si_item_cess,si_tax_excluded_total,si_tax_amount,itm_type,itbs_stock,brand_name) VALUES ('" + itbs_id + "','" + itm_code + "','" + itm_name + "','" + $("#item_cal_original_price").val() + "','" + $("#txt_item_price").val() + "','" + $("#txt_item_quantity").val() + "','" + $("#itm_calc_real_total").val() + "','" + $("#txt_item_discount").val() + "','" + $("#itm_calc_dics_amount").val() + "','" + $("#itm_calc_net_total").val() + "','" + $("#txt_item_foc").val() + "','" + si_approval_status + "','" + $("#item_cal_commision").val() + "','" + $("#itm_calc_commision_amount").val() + "','0','" + $("#item_cal_tax_percent").val() + "','" + $("#item_cal_cess").val() + "','" + si_tax_excluded_total + "','" + $("#itm_calc_tax_amount").val() + "','" + itm_type + "','" + itbs_stock + "','" + brand_name + "')";

                tx.executeSql(insert_tbl_cart, [], function (tx, res) {
                    successalert(itm_name + " has been added to cart!");
                    list_Edit_cart(1);
                    list_items_for_sale_for_add_product(1);
                    onBackKeyDown();
                    modalClose();
                });

            }
        });

    }, function (e) {

        alert(e.message);

    });
}

function edit_load_item_details_to_edit(itbs_id) {

    if (ispopupshown == 0) {
        popuploaded();

        var db = getDB();
        db.transaction(function (tx) {

            var htm = '';
            var selectTrans = "select * from tbl_edit_cart where itbs_id=" + itbs_id + " ";
            tx.executeSql(selectTrans, [], function (tx, res) {
                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    closeOverlay();
                    return;
                }
                if (len > 0) {

                    var cls_value = "";
                    var img_value = "";
                    $("#item_cal_tax_percent").val(res.rows.item(0).si_item_tax);
                    $("#item_cal_cess").val(res.rows.item(0).si_item_cess);
                    $("#item_cal_commision").val(res.rows.item(0).itm_commision);
                    $("#item_cal_original_price").val(res.rows.item(0).si_org_price);

                    if ($("#cust_class_for_order").val() == "itm_class_three") { cls_value = "C CLASS"; } else if ($("#cust_class_for_order").val() == "itm_class_two") { cls_value = "B CLASS"; } else { cls_value = "A CLASS"; }
                    if (String(res.rows.item(0).itm_type) == "1") { img_value = "Add-item-icon"; } else if (String(res.rows.item(0).itm_type) == "2") { img_value = "service"; } else { img_value = "coupons"; }

                    dialog = bootbox.dialog({
                        message: '<div class="content" style="margin-bottom:2px;">' +
            '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/' + img_value + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + String(res.rows.item(0).itm_name) + '</b><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ITEM CODE : #' + String(res.rows.item(0).itm_code) + '</small></span><br />' +
            '</div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ITEM QTY</label><input type="number" id="txt_item_quantity" value="' + String(res.rows.item(0).si_qty) + '" style="font-size:17px" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input integer" value="1" placeholder="Enter quantity"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">PRICE</label><input type="number" id="txt_item_price" disabled style="font-size:17px;background-color:#fffcf5" value="' + String(res.rows.item(0).si_price) + '" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" placeholder="Enter price"></div></td>' +
            '</tr>' +
            '<tr>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ADDITIONAL DISCOUNT %</label><input type="number" disabled value="' + String(res.rows.item(0).si_discount_rate) + '" id="txt_item_discount" style="font-size:17px;background-color:#fffcf5" onkeyup = "javascript:calculate_item_Total();" class="form-control border-input float" value="0.00" placeholder="Enter discount"></div></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">FREE OF COST</label><input type="number" value="' + String(res.rows.item(0).si_foc) + '" id="txt_item_foc" style="font-size:17px" class="form-control border-input integer" value="0" onkeyup = "javascript:calculate_item_Total();" placeholder="Enter FOC"></div></td>' +
            '</tr>' +
            '</table>' +
            '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
            '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">UNIT PRICE : ' + format_decimal_accuray(res.rows.item(0).si_price) + ' (' + cls_value + ')<br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">TOTAL QTY (QTY + FOC) : 1</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_without_tax">ITEM TOTAL : ' + res.rows.item(0).si_total + '</small></span><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_tax">TAX % : ' + res.rows.item(0).si_item_tax + '</small></span><br />' +
            '<span class="text-danger"><small style="font-size:15px"><b id="lbl_itmpop_itm_total">NET TOTAL : 000 AED (Tax Amt. 50 AED)</b></small></span></div></div>' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<table>' +
            '<tr>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px;" onclick="edit_update_item_in_cart(' + itbs_id + ')">UPDATE</button></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px;" onclick="javascript:edit_remove_item_from_cart(' + itbs_id + ');">REMOVE</button></td>' +
            '</tr>' +
            '</table>' +
            '<table style="width:100%">' +
            '<tr>' +
            '<td ><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:gray;color:#fff;border:none;margin-top:10px;height:40px;" onclick="javascript:modalClose();">CLOSE</button></td>' +
            '</tr>' +
            '</table>' +
            '</div> ',
                        closeButton: false
                    });


                    unipopup = dialog;
                    initDomEvents();

                    calculate_item_Total();
                }

            });



        });


    }


}

function edit_update_item_in_cart(itbs_id) {


    var price = $("#txt_item_price").val();
    var quantity = $("#txt_item_quantity").val();
    var discount = $("#txt_item_discount").val();
    var focval = $("#txt_item_foc").val();

    if (quantity == "0" || quantity == "" || quantity == null || isNaN(quantity)) {
        validation_alert("Please enter the Quanitiy"); return;
    }
    if (discount == "" || discount == null || isNaN(discount)) {

        validation_alert("Please enter the Discount %"); return;
    }
    if (price == "" || price == null || isNaN(price)) {
        validation_alert("Please enter a valid price"); return;
    }
    if (focval == "" || focval == null || isNaN(focval)) {
        validation_alert("Please enter a valid FOC value"); return;
    }

    if (parseFloat(discount) > 100) { validation_alert("Discount cannot be more than 100%!"); return; }

    var db = getDB();
    db.transaction(function (tx) {

        var si_approval_status = 0;

        if ($("#ss_price_change").val() == "1") {

            if (parseFloat($("#item_cal_original_price").val()) != parseFloat($("#txt_item_price").val())) { si_approval_status = 1; }
        }
        if ($("#ss_discount_change").val() == "1") {

            if (parseFloat($("#txt_item_discount").val()) > 0) { si_approval_status = 1; }
        }
        if ($("#ss_foc_change").val() == "1") {

            if (parseInt($("#txt_item_foc").val()) > 0) { si_approval_status = 1; }
        }
        var si_tax_excluded_total = format_decimal_accuray(parseFloat($("#itm_calc_net_total").val()) - parseFloat($("#itm_calc_tax_amount").val()));

        var update_tbl_cart = "UPDATE tbl_edit_cart SET si_price='" + $("#txt_item_price").val() + "',si_qty='" + $("#txt_item_quantity").val() + "',si_total='" + $("#itm_calc_real_total").val() + "',si_discount_rate='" + $("#txt_item_discount").val() + "',si_discount_amount='" + $("#itm_calc_dics_amount").val() + "',si_net_amount='" + $("#itm_calc_net_total").val() + "',si_foc='" + $("#txt_item_foc").val() + "',si_approval_status='" + si_approval_status + "',itm_commisionamt='" + $("#itm_calc_commision_amount").val() + "',si_tax_excluded_total='" + si_tax_excluded_total + "',si_tax_amount='" + $("#itm_calc_tax_amount").val() + "' WHERE itbs_id='" + itbs_id + "'";

        tx.executeSql(update_tbl_cart, [], function (tx, res) {
            successalert("Item details has been updated!");
            list_Edit_cart(1);
            modalClose();
        });


    }, function (e) {

        alert(e.message);

    });
}

function edit_remove_item_from_cart(itbs_id) {

    var db = getDB();
    db.transaction(function (tx) {


        var delete_from_tbl_cart = "DELETE FROM tbl_edit_cart WHERE itbs_id='" + itbs_id + "'";

        tx.executeSql(delete_from_tbl_cart, [], function (tx, res) {
            validation_alert("Item has been removed from cart!");
            list_Edit_cart(1);
            modalClose();
        });


    }, function (e) {

        alert(e.message);

    });
}

function resetProductSearch_for_add_product() {

    $("#txtsearchProducts_for_add").val("");
    $("#selectBrands_for_add").val('x');
    $("#selectCategory_for_add").val('x');
    load_brands_categories_to_combo_for_add_product();
    list_items_for_sale_for_add_product(1);
}

function load_categories_based_on_brand_for_add_product() {

    var db = getDB();
    db.transaction(function (tx) {

        var chtm = "";
        var cat_qry = "";
        chtm = chtm + '<option value="x">All Categories</option>';

        if ($("#selectBrands_for_add").val() == "x") {

            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes_for_add").val() + "' and branch_id='" + $("#order_branch_id").val() + "' GROUP BY itm_category_id";
        }
        else {
            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes_for_add").val() + "' and itm_brand_id='" + $("#selectBrands_for_add").val() + "' and branch_id='" + $("#order_branch_id").val() + "' GROUP BY itm_category_id";
        }

        tx.executeSql(cat_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    chtm = chtm + '<option value="' + String(res.rows.item(i).itm_category_id) + '">' + String(res.rows.item(i).cat_name) + '</option>';
                }
                $("#selectCategory_for_add").html(chtm);
                list_items_for_sale_for_add_product(1);
            }
            else { }
        });

    }, function (e) {

        alert(e.message);

    });


}

function show_product_list_page_for_add_product() {
    
    if ($("#ss_new_item").val() == "1") { $("#newitemheader").show(); } else { $("#newitemheader").hide(); }
    showpage('divProducts_for_add');
    $("#Selectitmtypes_for_add").val(1);
    $("#txtsearchProducts_for_add").val("");
    load_brands_categories_to_combo_for_add_product();
    list_items_for_sale_for_add_product(1);
}

function clrSearchBoxandSearch_for_add_product() {
    $("#txtsearchProducts_for_add").val("");
    load_categories_based_on_brand_for_add_product();
}

function load_brands_categories_to_combo_for_add_product() {

    var db = getDB();
    db.transaction(function (tx) {

        var bhtm = "";
        bhtm = bhtm + '<option value="x">All Brands</option>';

        var chtm = "";
        chtm = chtm + '<option value="x">All Categories</option>';

        var brand_qry = "SELECT itm_brand_id,brand_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes_for_add").val() + "' and branch_id='" + $("#order_branch_id").val() + "' GROUP BY itm_brand_id";
        var cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='" + $("#Selectitmtypes_for_add").val() + "' and  branch_id='" + $("#order_branch_id").val() + "' GROUP BY itm_category_id";

        tx.executeSql(brand_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    bhtm = bhtm + '<option value="' + String(res.rows.item(i).itm_brand_id) + '">' + String(res.rows.item(i).brand_name) + '</option>';
                }
                $("#selectBrands_for_add").html(bhtm);
            }
            else { }

        });

        tx.executeSql(cat_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    chtm = chtm + '<option value="' + String(res.rows.item(i).itm_category_id) + '">' + String(res.rows.item(i).cat_name) + '</option>';
                }
                $("#selectCategory_for_add").html(chtm);
            }
            else { }
        });

    }, function (e) {

        alert(e.message);

    });



}

function list_items_for_sale_for_add_product(page) {

    
    var searchString = $("#txtsearchProducts_for_add").val();
    var filterstring = " ";
    var brand = $("#selectBrands_for_add").val();
    var category = $("#selectCategory_for_add").val();
    var itm_type = $("#Selectitmtypes_for_add").val();

    if (brand != 'x') { filterstring = filterstring + " and itm_brand_id='" + brand + "' "; }
    if (category != 'x') { filterstring = filterstring + " and itm_category_id='" + category + "' "; }

    var perPage = 15;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_itembranch_stock where itbs_id NOT IN (SELECT itbs_id FROM tbl_edit_cart) and itm_type='" + $("#Selectitmtypes_for_add").val() + "' and branch_id='" + $("#order_branch_id").val() + "' and itm_name like '%" + searchString + "%'" + filterstring + "";
        //alert(qryCount);
        tx.executeSql(qryCount, [], function (tx, res) {

            var class_type = $("#sm_price_class").val();
            if (class_type == "1") { class_type = "itm_class_one"; }
            else if (class_type == "2") { class_type = "itm_class_two"; }
            else if (class_type == "3") { class_type = "itm_class_three"; }

            totalRows = res.rows.item(0).cnt;
            totPages = Math.ceil(totalRows / perPage);
            var selectItems = "select itm_name,itbs_id,itm_code," + class_type + " as itm_price,itm_type from tbl_itembranch_stock " +
            " where itbs_id NOT IN (SELECT itbs_id FROM tbl_edit_cart) and itm_type='" + $("#Selectitmtypes_for_add").val() + "' and branch_id='" + $("#order_branch_id").val() + "' and itm_name like '%" + searchString + "%'" + filterstring + " order by itm_rating desc,itm_name asc limit " + perPage + " offset " + lowerBound;
           // alert(selectItems);
            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Results Found !';
                    htm = htm + '<span class="text-success"><small></small></span>';
                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    $("#dListProduct_for_add").html(htm);
                    $("#nOfItems").html('No Results');

                    return;
                }
                if (len > 0) {

                    $("#nOfItems").html("" + len + " Items");


                    for (var i = 0; i < len; i++) {


                        var color = 0;
                        var image = "";
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        if (res.rows.item(i).itm_type == "1") { image = "Add-item-icon"; } else if (res.rows.item(i).itm_type == "2") { image = "service"; } else if (res.rows.item(i).itm_type == "3") { image = "coupons"; } else { }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:edit_load_item_details_to_add(' + String(res.rows.item(i).itbs_id) + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/' + image + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + String(res.rows.item(i).itm_name) + '<br />';
                        htm = htm + '<span class="text-info"><small style="color:#337ab7">ITEM CODE : #' + String(res.rows.item(i).itm_code) + '</small></span><br />';
                        htm = htm + '<span class="text-danger"><small>ITEM PRICE :<b> ' + format_currency_value(res.rows.item(i).itm_price) + '</b></small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-plus"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev44_for_add" onclick="javascript:list_items_for_sale_for_add_product(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext44_for_add" onclick="javascript:list_items_for_sale_for_add_product(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';



                    $("#dListProduct_for_add").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);


                    if (page > 1) {
                        $("#btnPrev44_for_add").show();
                    }
                    if (page < totPages) {
                        $("#btnNext44_for_add").show();
                    }
                    
                    if (totPages == 1) {
                        $("#btnNext44_for_add").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext44_for_add").hide();
                    }
                    

                }

            });

        });

    });


}

function show_editcart_with_reload() {

    list_Edit_cart(1);
    onBackKeyDown();

}

function complete_editing() {

    var db = getDB();
    db.transaction(function (tx) {

        var items_after_edit = '';
        var selectTrans = "select itbs_id from tbl_edit_cart";
        tx.executeSql(selectTrans, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {
                validation_alert("Order cannot saved without an item. Please cancel the order instead!");
                return;
            }
            if (len > 0) {

                if ($("#is_online_action").val() == "1") { edit_order_online(); } else { edit_order_offline(); }
            }
        });

    });
}

function edit_order_online() {

    var istobeConfirm = 0;
    
    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to Continue ?',
        callback: function (result) {
            if (result == false) {                
                return;

            } else {

                var orderAdded = bootbox.dialog({
                    message: '<div align=center id="simage"><img class="avatar border-white" src="assets/img/overlayLoad.gif" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:#337ab7"><i class="ti-rss-alt"></i> updating your order ..</p></div>',
                    closeButton: false
                });
              
                var editedItems = "";
           
                var db = getDB();
                db.transaction(function (tx) {

                    var items_after_edit = '';
                    var selectTrans = "select * from tbl_edit_cart";
                    tx.executeSql(selectTrans, [], function (tx, res) {

                        var len = res.rows.length;
                        if (len == 0) {

                            return;
                        }
                        if (len > 0) {

                            items_after_edit = "[";

                            for (var i = 0; i < len; i++) {

                                items_after_edit = items_after_edit + "{ ";

                                items_after_edit = items_after_edit + '' +
                                    '"itbs_id" :"' + String(res.rows.item(i).itbs_id) + '",' +
                                    '"si_org_price" :"' + String(res.rows.item(i).si_org_price) + '",' +
                                    '"itm_name" :"' + String(res.rows.item(i).itm_name) + '",' +
                                    '"si_price" :"' + String(res.rows.item(i).si_price) + '",' +
                                    '"si_qty" :"' + String(res.rows.item(i).si_qty) + '",' +
                                    '"si_discount_rate" :"' + String(res.rows.item(i).si_discount_rate) + '",' +
                                    '"si_foc" :"' + String(res.rows.item(i).si_foc) + '",' +
                                    '"si_approval_status" :"' + String(res.rows.item(i).si_approval_status) + '",' +
                                    '"itm_type" :"' + String(res.rows.item(i).itm_type) + '",' +
                                    '"si_itm_type" :"' + String(res.rows.item(i).si_itm_type);

                                if (i == (len - 1)) {

                                    items_after_edit = items_after_edit + '" }';

                                } else {

                                    items_after_edit = items_after_edit + '" },';
                                }

                            }

                            items_after_edit = items_after_edit + "]";
                           
                            var cart = items_after_edit;
                            var ordid = $("#orderID").val();
                            var orderstatus = $("#approvalStatusref").val();

                            var postObj = {

                                editedorder: {

                                    sm_id: $("#order_id").val(),
                                    sm_delivery_status: orderstatus,
                                    user_id: $("#appuserid").val(),
                                    istobeConfirm: istobeConfirm,
                                    items_after_edit: items_after_edit,
                                    time_zone: $("#ss_default_time_zone").val(),
                                    ss_decimal_accuracy: $("#ss_decimal_accuracy").val(),
                                    sm_delivery_status: $("#order_current_status").val(),

                                }
                               

                            };

                            disableBackKey();

                            $.ajax({
                                type: "POST",
                                url: "" + getUrl() + "/editOrder",
                                data: JSON.stringify(postObj),
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                crossDomain: true,
                                timeout: 45000,
                                success: function (resp) {

                                    enableBackKey();
                                    var obj = JSON.parse(resp.d);
                                    
                                    if (obj.result == "SUCCESS") {
                                                                              
                                        $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Order edited successfully!</p>');
                                        
                                        setTimeout(function () {
                                            orderAdded.find(orderAdded.modal('hide'));
                                            onBackKeyDown();
                                            fetch_full_order_details();
                                            reloadBgClass();
                                        }, 2000);


                                    }
                                    else { // if edit failed

                                        $("#simage").html('<img class="avatar border-white" src="assets/img/noresults.jpg" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i>Something went wrong , Please try again </p>');

                                        setTimeout(function () {
                                            orderAdded.find(orderAdded.modal('hide'));
                                        }, 1000);


                                    }

                                },
                                error: function (e) {

                                    enableBackKey();
                                    $("#simage").html('<img class="avatar border-white" src="assets/img/noresults.jpg" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i> No Internet Access</p>');

                                    setTimeout(function () {
                                        orderAdded.find(orderAdded.modal('hide'));
                                    }, 1000);
                                }
                            });


                            //end of ajax
                        }

                    });






                }, function (e) {
                    alert("ERROR: " + e.message);
                });



            }
        }

    })

}

var swap_count = 0;
function load_popup_for_status() {

    if (ispopupshown == 0) {
        popuploaded();
        swap_count = 0;
        var sm_type = $("#current_sm_type").val();
        if (sm_type == "2") { validation_alert("Order status cannot be changed for older entry"); return; }
        else {
            var order_status = $("#order_current_status").val();
            var packing_status = $("#order_packing_status").val();

            var htm = "";
            if (order_status != "3" && order_status != "5") {

                dialog = bootbox.dialog({
                    message: '<div class="content" style="margin-bottom:2px;">' +
            '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
            '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;text-align:center" id="lbl_itmpop_itm_name"><b>PROCESS ORDER</b><br />' +
            '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">Order No : #' + $("#order_id").val() + '</small></span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Order Status</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<select id="Select_Status_to_update" onchange="javascript:swap_processing_type();" class="form-control border-input"></select>' +

            '<div id="div_pop_packing_details0" style="display:none">' +
            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Packing Status</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<select id="Select_pkgsts_to_update" class="form-control border-input"><option value="1" selected>PACKED</option><option value="0">NOT PACKED</option></select>' +
            '</div>' +

            '<div id="div_pop_processing" style="display:none">' +
            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Select Person for Delivery</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<select id="Select_person_to_deliver" class="form-control border-input"></select>' +

            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Vehicle Type</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<select id="Select_vehicle_type" onchange="javascript:swap_processing_type();" class="form-control border-input"><option value="1" selected>COMPANY VEHICLE</option><option value="0">OUTSIDE VEHICLE</option></select>' +

            '<div id="div_pop_company_vehicle" style="display:none">' +
            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Choose Vehicle</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<select id="Select_vehicle_id" class="form-control border-input"></select>' +
            '</div>' +

            '<div id="div_pop_other_vehicle" style="display:none">' +
            '<span class="text-info" style="color:#000;margin-top:10px;text-align:center;float:left">Vehicle Number</span><br />' +
            '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
            '<input type="text" id="Select_vehicle_number" class="form-control border-input" value="" placeholder="Enter plate number">' +
            '</div>' +
            '</div>' +

            '<table style="margin-top:10px">' +
            '<tr>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="update_order_status()">UPDATE</button></td>' +
            '<td>&nbsp</td>' +
            '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:modalClose();">CLOSE</button></td>' +
            '</tr>' +
            '</table>' +
            '</div> ',
                    closeButton: false
                });

                unipopup = dialog;

                $("#Select_vehicle_id").html(vehicle_data);
                $("#Select_person_to_deliver").html(delivery_data);

                $("#Select_pkgsts_to_update").val(packing_status);

                if (order_status == "2") {

                    if ($("#is_online_action").val() == "1") {
                        htm = htm + '<option value="2">DELIVERED</option>';
                    }
                }
                else if (order_status == "0") {

                    if (packing_status == "0") {

                        htm = htm + '<option value="0" selected>NEW ORDER</option>';
                        htm = htm + '<option value="10">PACKING ONLY</option>';

                    }
                    else {

                        htm = htm + '<option value="10" selected>PACKING ONLY</option>';
                        htm = htm + '<option value="0">NEW ORDER</option>';

                    }

                    htm = htm + '<option value="1">PACK & ASSIGN FOR DELIVERY</option>';
                    htm = htm + '<option value="6">PENDING</option>';
                }
                else if (order_status == "1" || order_status == "6") {

                    if (order_status == "1") { htm = htm + '<option value="1" selected>PROCESSED</option>'; htm = htm + '<option value="6">PENDING</option>'; }
                    else { htm = htm + '<option value="6" selected>PENDING</option>'; htm = htm + '<option value="1">PACK & ASSIGN FOR DELIVERY</option>'; }
                    htm = htm + '<option value="10">PACKING ONLY</option>';
                    
                }
                else {

                    htm = htm + '<option value="4" selected>CANCELLED</option>';
                }

                $("#Select_Status_to_update").html(htm);
                swap_processing_type();
            }
            else {
                if (order_status == "3") {
                    validation_alert("This order is under review! You cannot change the status of the order at this stage.");
                }
                else {
                    validation_alert("This order has been rejected!");
                }
            }
        }
    }

}

function swap_processing_type() {

    var order_status = $("#order_current_status").val();
    var process_type = $("#Select_Status_to_update").val();
    var vehicle_type = $("#Select_vehicle_type").val();
    
    if (process_type == "0" || process_type == "6") {

        $("#div_pop_packing_details").hide();
        $("#div_pop_processing").hide();
    }
    else if (process_type == "10") {

        $("#div_pop_packing_details").show();
        $("#div_pop_processing").hide();
    }
    else if (process_type == "1") {

        $("#div_pop_packing_details").show();
        $("#div_pop_processing").show();

        if (vehicle_type == "1") {

            $("#div_pop_company_vehicle").show();
            $("#div_pop_other_vehicle").hide();
        }
        else {

            $("#div_pop_other_vehicle").show();
            $("#div_pop_company_vehicle").hide();
        }

        // if current value is processed
        if (swap_count == 0) {

            if (order_status == "1") {
                var del_id = $("#order_sel_person_for_delivery").val();
                $("#Select_person_to_deliver").val(del_id);

                var is_company_veh = $("#order_is_company_vehicle").val();
                if (is_company_veh == "1") {

                    $("#div_pop_company_vehicle").show();
                    $("#div_pop_other_vehicle").hide();
                    $("#Select_vehicle_type").val("1");
                    $("#Select_vehicle_id").val($("#order_sel_vehicle_for_delivery").val());
                }
                else {

                    $("#div_pop_other_vehicle").show();
                    $("#div_pop_company_vehicle").hide();
                    $("#Select_vehicle_type").val("0");
                    $("#Select_vehicle_number").val($("#order_sel_vehicle_for_delivery").val());
                }
            }
        }
        swap_count++;
        
    }
}


function update_order_status() {

    if ($("#Select_Status_to_update").val() == $("#order_current_status").val()) {

        if ($("#Select_Status_to_update").val() == "6" || $("#Select_Status_to_update").val() == "2" || $("#Select_Status_to_update").val() == "4" || ($("#Select_Status_to_update").val() == "0" && $("#order_packing_status").val() == "0")) {
            modalClose(); return;
        }        
    }

    // validation
    if ($("#Select_Status_to_update").val() == "1") {

        if ($("#Select_person_to_deliver").val() == "0") { validation_alert("Please select a person for delivery"); return; }

        if ($("#Select_vehicle_type").val() == "1") {

            if ($("#Select_vehicle_id") == "0") { validation_alert("Please select a vehicle for delivery"); return;}
        }
        else {

            if ($("#Select_vehicle_number").val() == "" || $("#Select_vehicle_number").val() == null) { validation_alert("Please enter delivery vehicle number"); return; }
        }
        

    }



    update_order_status_online();
}

function update_order_status_online() {

    var msg_string = "";
    if ($("#Select_Status_to_update").val() == "1") {
        msg_string = "This will generate Invoice/Bill Number against this Order (If Unavailable).";
    }

    bootbox.confirm({
        size: 'small',
        message: msg_string + ' Are you sure to Continue ?',
        callback: function (result) {
            if (result == false) {

                return;
            } else {

                var orderAdded = bootbox.dialog({
                    message: '<div align=center id="simage"><img class="avatar border-white" src="assets/img/overlayLoad.gif" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:#337ab7"><i class="ti-rss-alt"></i> Updating order status</p></div>',
                    closeButton: false
                });

                var postObj = {

                    order: {

                        sm_id: $("#order_id").val(),
                        user_id: $("#appuserid").val(),
                        time_zone: $("#ss_default_time_zone").val(),
                        order_status: $("#Select_Status_to_update").val(),
                        packing_status: $("#Select_pkgsts_to_update").val(),
                        delivery_man: $("#Select_person_to_deliver").val(),
                        vehicle_type: $("#Select_vehicle_type").val(),
                        vehicle_id: $("#Select_vehicle_id").val(),
                        vehicle_no: $("#Select_vehicle_number").val(),
                        current_packing_status: $("#order_packing_status").val()
                    }
                };
               
                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/update_order_status_online",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 52000,
                    success: function (resp) {

                        enableBackKey();
                        
                        if (resp.d == "SUCCESS") {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Order status changed successfully!</p>');
                            modalClose();                           
                            setTimeout(function () {
                                orderAdded.find(orderAdded.modal('hide'));
                                fetch_full_order_details();
                            }, 2000);

                        }
                        else {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-down"></i> Action failed , Please try again</p>');

                            setTimeout(function () {
                                orderAdded.find(orderAdded.modal('hide'));
                            }, 2000);
                        }


                    },
                    error: function (e) {

                        enableBackKey();

                        $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i> No Internet access..Please try again. </p>');

                        setTimeout(function () {
                            orderAdded.find(orderAdded.modal('hide'));
                        }, 1000);

                    }
                });

            }
        }

    })

}

function make_Payment_for_order() {

    var order_status = $("#order_current_status").val();
    var status_string = "";
    if (order_status == "3" || order_status == "5" || order_status == "4") {
        status_string = order_status == "3" ? "this" : order_status == "5" ? "rejected" : order_status == "4" ? "cancelled" : "" + '';
        validation_alert("Payment cannot be processed for " + status_string + " order.");
    }
    else {

        if ($("#is_online_action").val() == "1") {
            var db = getDB();
            db.transaction(function (tx) {

                var select_transactions = "select id from tbl_transactions WHERE trans_sync_status='0' and partner_id='" + $("#customer_id").val() + "'";
                tx.executeSql(select_transactions, [], function (tx, res) {
                    var len = res.rows.length;
                    if (len == 0) { credit_debit_count = 0; }
                    if (len > 0) { credit_debit_count = len; }

                    var selectSales_master = "select sm_id from tbl_sales_master WHERE sm_sync_status='0' and cust_id='" + $("#customer_id").val() + "'";
                    tx.executeSql(selectSales_master, [], function (tx, res) {

                        var len = res.rows.length;
                        if (len == 0) { new_order_count = 0; }
                        if (len > 0) { new_order_count = len; }

                        if (credit_debit_count == 0 && new_order_count == 0) {

                            fetch_customer_sales_details_for_payment();
                        }
                        else {

                            validation_alert("This customer has offline order/credit/debit entries. Please sync to make payment");
                        }

                    });

                });

            }, function (e) { alert(e.message); });
        }
        else { validation_alert("Payment cannot performed for offline orders!");}
    }
}

function fetch_customer_sales_details_for_payment() {

    var order_id = $("#order_id").val();
    $("#is_online_action").val('1');

    overlay("Loading order payment details");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/fetch_customer_sales_details_for_payment",
        data: "{'sm_id':'" + order_id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            enableBackKey();

            if (msg.d == "N") {
                validation_alert("No Data Found");
                closeOverlay();
                return;
            } else {

                var obj = JSON.parse(msg.d);
                var amount_in_wallet = 0;

                var delivery_status_image = "";
                delivery_status_image = obj.data[0].sm_delivery_status == 0 && obj.data[0].sm_packed == 0 ? "assets/img/neww.png" : obj.data[0].sm_delivery_status == 0 && obj.data[0].sm_packed == 1 ? "assets/img/packed.png" : obj.data[0].sm_delivery_status == 1 && obj.data[0].sm_packed == 1 ? "assets/img/processes.jpg" : obj.data[0].sm_delivery_status == 2 ? "assets/img/delivered.png" : obj.data[0].sm_delivery_status == 3 ? "assets/img/underReview.jpg" : obj.data[0].sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : obj.data[0].sm_delivery_status == 5 ? "assets/img/rejected.png" : obj.data[0].sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                $("#out_image").html('<img  src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive" style="width: 40px;">');

                if (obj.data[0].sm_invoice_no != "") {
                    $("#out_orderid").html('Bill No : #' + obj.data[0].sm_invoice_no + ' (' + order_id + ')');
                }
                else {
                    $("#out_orderid").html('Bill No : (' + order_id + ')');
                }
                if (obj.data[0].cust_amount < 0) {
                    amount_in_wallet = obj.data[0].cust_amount * (-1);
                } else { amount_in_wallet = 0; }

                // handling payable wallet details

                var wallet_amount_payable = obj.order_details[0].custBal > obj.order_details[0].outstanding_amt ? Math.abs(obj.order_details[0].outstanding_amt - obj.order_details[0].custBal) : obj.order_details[0].outstanding_amt < 0 ? Math.abs(obj.order_details[0].outstanding_amt) : 0;
                wallet_amount_payable = format_decimal_accuray(wallet_amount_payable);

                if (wallet_amount_payable > 0 && format_decimal_accuray(obj.data[0].total_balance) > 0) { $("#div_wallet_payment").show(); } else { $("#div_wallet_payment").hide(); $("#cust_wallet_used_amount").val('0.00'); $("#cust_wallet_amount").val('0.00'); }

                $("#cust_wallet_amount").val(wallet_amount_payable);
                $("#lbl_wallet_show").html('WALLET ( 0.00 used / ' + format_currency_value(wallet_amount_payable) + ') : ');
                $('#is_wallet_using').prop('checked', false);
                $("#cust_wallet_used_amount").val('0');
                $("#total_outstanding_payment").val('0');
                $("#out_orderdate").html(obj.data[0].sm_date);
                $("#over_storename").html(obj.data[0].cust_name + '<br><a href="#"><small style="color:grey" id="over_address"></small></a>');
                $("#out_ordertype").html(obj.data[0].sm_order_type == 1 ? " [ Direct ]" : obj.data[0].sm_order_type == 2 ? " [ Telephonic ]" : " [ LPO ]" + '');
                $("#out_PayType").html(obj.data[0].sm_payment_type == 1 ? " [ Cash ]" : obj.data[0].sm_payment_type == 2 ? " [ Credit ]" : obj.data[0].sm_payment_type == 3 ? " [ Bill to bill ]" : " [ No Payment Type Specified ]" + '');

                $("#order_total").val(format_decimal_accuray(obj.data[0].sm_netamount));
                $("#order_balance").val(format_decimal_accuray(obj.data[0].total_balance));
                
                $("#lbl_ord_out_netamt").html('<small style="color:#337ab7">NET AMOUNT<br /></small>' + format_currency_value(obj.data[0].sm_netamount) + '');
                $("#lbl_ord_out_balance").html('<small style="color:#b53131">BALANCE<br /></small>' + format_currency_value(obj.data[0].total_balance) + '');

                $("#lbl_ord_out_cr_netamt").html('<small style="color:#337ab7">CURRENT AMOUNT<br /></small>' + format_currency_value(0) + '');
                $("#lbl_ord_out_cr_balance").html('<small style="color:#b53131">NEW BALANCE<br /></small>' + format_currency_value(obj.data[0].total_balance) + '');
                $("#txt_out_pay_note").val('');
                $("#Select_out_pay_method").val('1');
                $("#txt_out_chk_num").val('');
                $("#txt_out_chk_date").val('');
                $("#txtt_out_chk_bank").val('');
                $("#txt_out_payment_amount").val(format_decimal_accuray(0));
                getSessionID();
                swap_outstanding_Payment_typeDivs();
                showpage('div_outstanding_payments');
                closeOverlay();
               

            }
        },
        error: function (xhr, status) {

            enableBackKey();
            
            closeOverlay();
            var logfailed = bootbox.dialog({
                message: '<p class="text-center" style="color:red"><i class="ti-info"></i> No Internet Access... Please Try again.</p>',
                closeButton: false
            });


            setTimeout(function () {
                logfailed.find(logfailed.modal('hide'));
            }, 1000);
        }
    });

}

function test() {
    validation_alert('worked');   
}

function calculate_outstanding_balance() {

    
    var is_wallet_used = $('#is_wallet_using').is(":checked");
    var wallet_amount = parseFloat($("#cust_wallet_amount").val());

    if (is_wallet_used == false) {

        var payment = $("#txt_out_payment_amount").val();
        if (payment == "") { payment = 0; }
        var net_balance = format_decimal_accuray(parseFloat($("#order_balance").val()));
        payment = format_decimal_accuray(parseFloat(payment));
        var balance = net_balance - payment;
        $("#lbl_ord_out_cr_netamt").html('<small style="color:#337ab7">CURRENT AMOUNT<br /></small>' + format_currency_value(payment) + '');
        $("#lbl_ord_out_cr_balance").html('<small style="color:#b53131">NEW BALANCE<br /></small>' + format_currency_value(balance) + '');
        $("#total_outstanding_payment").val(format_decimal_accuray(payment));
        $("#lbl_wallet_show").html('WALLET ( 0.00 used / ' + format_currency_value(wallet_amount) + ') : ');
    }
    else {

        
        var net_balance = format_decimal_accuray(parseFloat($("#order_balance").val()));        
        var used_wallet_amount = 0;
        var remain_wallet = 0;
        
        if (wallet_amount < net_balance) {

            used_wallet_amount = wallet_amount;
            
        }
        else if (wallet_amount > net_balance) {

            used_wallet_amount = net_balance;
            
        }
        else { // wallet equals to balance

            used_wallet_amount = wallet_amount;
           
        }

        $("#cust_wallet_used_amount").val(used_wallet_amount);

        var payment = $("#txt_out_payment_amount").val();
        if (payment == "" || payment == null || isNaN(payment)) { payment = 0; }        
        payment = format_decimal_accuray(parseFloat(payment));
        payment = parseFloat(payment) + parseFloat(used_wallet_amount);        
        var balance = net_balance - payment;
        $("#lbl_ord_out_cr_netamt").html('<small style="color:#337ab7">CURRENT AMOUNT<br /></small>' + format_currency_value(payment) + '');
        $("#lbl_ord_out_cr_balance").html('<small style="color:#b53131">NEW BALANCE<br /></small>' + format_currency_value(balance) + '');
        $("#total_outstanding_payment").val(format_decimal_accuray(payment));
        $("#lbl_wallet_show").html('WALLET ( ' + format_decimal_accuray(used_wallet_amount) + ' used / ' + format_currency_value(wallet_amount) + ') : ');
    }

}

function swap_outstanding_Payment_typeDivs() {

   
    var pay_type = $("#Select_out_pay_method").val();
    if (pay_type == "1") {

        $("#Div_out_pay_cheque_part").hide();
    }
    else {

        var yyyy = new Date().getFullYear();
        $('#txt_out_chk_date').scroller({
            preset: 'date',
            endYear: yyyy + 10,
            setText: 'Select',
            invalid: {},
            theme: 'android-ics',
            display: 'modal',
            mode: 'scroller',
            dateFormat: 'dd-mm-yy'
        });

        $("#Div_out_pay_cheque_part").show();
    }
}

function make_payment_online() {

    fixquotes();
    var filters = {};
    var pay_method = $('#Select_out_pay_method').val();
    var total_payment = parseFloat( $('#total_outstanding_payment').val());
    
    if (total_payment == 0) { validation_alert("Payment cannot be Zero!"); return;}

    if (pay_method == "2") {

        if ($('#txt_out_chk_num').val() == "") {
            validation_alert("Enter Cheque No");
            return;
        }
        else if ($('#txt_out_chk_date').val() == "") {
            validation_alert("Enter Cheque Date");
            return;
        }
        else if ($('#txtt_out_chk_bank').val() == "") {
            validation_alert("Enter Bank Name");
            return;
        }
    }

    if ($("#walletChckbox").prop("checked") == false) {
        $("#usingWalletAmt").val('0');
    }

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to Continue ?',
        callback: function (result) {
            if (result == false) {

                return;
            } else {

                filters.branch = $("#order_branch_id").val();
                filters.OrderId = $("#order_id").val();
                filters.cust_id = $("#customer_id").val();
                filters.pay_method = $('#Select_out_pay_method').val();
                filters.CashAmount = $("#txt_out_payment_amount").val();
                filters.ChequeAmount = $("#txt_out_payment_amount").val();
                filters.ChequeNo = $("#txt_out_chk_num").val();
                filters.ChequeBank = $("#txtt_out_chk_bank").val();
                filters.ChequeDate = $("#txt_out_chk_date").val();
                filters.walletamt = $("#cust_wallet_used_amount").val();
                filters.sm_paid = $("#total_outstanding_payment").val();
                filters.sessionId = current_session_id;
                filters.delivery_status = $("#order_current_status").val();
                filters.userid = $("#appuserid").val();
                filters.time_zone = $("#ss_default_time_zone").val();
                filters.note = $("#txt_out_pay_note").val();

                if (filters.CashAmount == '') {
                    filters.CashAmount = 0;
                }
                if (filters.ChequeAmount == '') {
                    filters.ChequeAmount = 0;
                }
                if (filters.walletamt == '') {
                    filters.walletamt = 0;
                }

                overlay("Updating Order Details");

                disableBackKey();

                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/make_payment_online",
                    data: "{'filters':" + JSON.stringify(filters) + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 15000,
                    success: function (msg) {

                        enableBackKey();
                        var obj = JSON.parse(msg.d);

                        if (obj.result == "FAILED") {
                            validation_alert("Transaction failed! Please try again.");
                            return;
                        }
                        else if (obj.result == "SUCCESS") {

                            closeOverlayImmediately();
                            var db = getDB();
                            db.transaction(function (tx) {
                                var upQry = "UPDATE tbl_customer SET cust_amount='" + obj.cust_amount + "' where cust_id='" + $("#customer_id").val() + "'";
                                tx.executeSql(upQry, [], function (tx, res) {

                                    onBackKeyDown();
                                    successalert("Payment Updated Succesfully");
                                    Get_Customer_Details();
                                    fetch_full_order_details();
                                });

                            }, function (e) {
                                validation_alert(e.message);
                            });

                        }
                        else {

                            validation_alert("Transaction failed! Please try again.");
                            return;
                        }
                    },
                    error: function (xhr, status) {

                        enableBackKey();
                        ajaxerroralert();
                    }
                });
            }
        }
    });


}

function show_order_activities() {
    if ($("#is_online_action").val() == "1") {
        showpage('div_order_transactions');
        get_order_transactions(1);
    }
    else { validation_alert("Unavailable for offline orders");}
}

function get_order_transactions(page) {

    var htm = "";
    var postObj = {
        filters: {
            sm_id: $("#order_id").val(),
            page: page,
        }
    };

    overlay("Loading order activities");
    disableBackKey();
    $("#div_list_order_activities").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_order_transactions",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (response) {
            closeOverlay();
            enableBackKey();

            if (response.d == "") {
                bootbox.alert('<p style="color:red">No Transactions Found</p>');
                return;
            }
            else if (response.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Transactions Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_order_activities").html(htm);

                return;

            }
            else {

                var obj = JSON.parse(response.d);
                $.each(obj.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;">';
                    htm = htm + '<div class="col-xs-5" style="margin-top:7px;margin-bottom:5px;color:#337ab7;font-size:12px;background-color:' + color + '"><b>TXN.ID</b> :#<b>' + String(row.id) + '</b></div><div class="col-xs-7" style="float:right;text-align:right;margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '">' + row.tr_date + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "assets/img/exchange.png";
                    //delivery_status_image = row.action_type == 0 ? "assets/img/neww.png" : row.action_type == 1 ? "assets/img/packed.png" : row.action_type == 1 ? "assets/img/processes.jpg" : row.action_type == 2 ? "assets/img/delivered.png" : row.action_type == 3 ? "assets/img/underReview.jpg" : row.action_type == 4 ? "assets/img/cancelled.jpg" : row.action_type == 5 ? "assets/img/rejected.png" : row.action_type == 6 ? "assets/img/time.png" : "" + '';
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';

                    if (row.cr > 0) { htm = htm + '</div> </div><div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;"><small style="color:#337ab7">AMOUNT:</small> ' + format_currency_value(row.cr) + ' <small style="color:#337ab7">(CREDIT)</small>'; }
                    if (row.dr > 0) { htm = htm + '</div> </div><div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;"><small style="color:#337ab7">AMOUNT:</small> ' + format_currency_value(row.dr) + ' <small style="color:#337ab7">(DEBIT)</small>'; }

                    var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 6 ? "DEPOSIT" : "" + '';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action Type : <b>' + action + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action By : <b>' + row.name + '</b></small></span></div>';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '"><b style="color:337ab7">Details</b> : ' + String(row.narration) + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(obj.totalRows);
                var perPage = parseInt(obj.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tcr" onclick="javascript:get_order_transactions(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tcr" onclick="javascript:get_order_transactions(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No transactions Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_order_activities").html(htm);

                if (page > 1) {
                    $("#btnPrev_lod_tcr").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_tcr").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_tcr").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_tcr").hide();
                }
            }


        },
        error: function (xhr, status) {

            closeOverlay();
            load_follow_ups_offline();
            enableBackKey();
            ajaxerroralert();
            onBackMove();
        }
    });
}

function load_bluetooth_devices() {

    showpage('div_Settings');
    BluetoothPrintManager.getPairedDevices(function (devices) {
        var selectedDevice = $("#selPrintDevices").val();
        var htm = "<option value='0'>SELECT A DEVICE</option>";
        devices.forEach(function (device) {
            htm += "<option value='" + device.id + "'>" + device.name + "</option>";
        })
        $("#selPrintDevices").html(htm);
    }, function (error) {
        validation_alert('could not fetch the list of paired bluetooth devices.');
    });
}

var is_connected = false;
// connect to a print device
function connectDevice() {

    BluetoothPrintManager.isBLEnabled(function (isEnabled) {
        if (!isEnabled) {
            // if not enabled request bluetooth
            BluetoothPrintManager.requestBluetoothService();
            return;
        }
        else {
            // if blue tooth enabled, get selected printers id
            var id = $("#selPrintDevices").val();            
            if (id == '0') {
                // if no printer chosen, alert message and return
                validation_alert("Please choose a device to print!")
                return;
            }
            // try to connect with the selected printer
            BluetoothPrintManager.connect(id, function (response) {
                successalert("Device connection established.");
                is_connected = true;

            }, function (error) {
                is_connected = false;
                validation_alert("unable to connect to the device! Please try again.");
            });
        }
    }, function (error) {
        validation_alert("An error occured while connecting to device.");
    });
}

function connectAndPrint() {

   // printOrder(); return;
    BluetoothPrintManager.isBLEnabled(function (isEnabled) {
        if (!isEnabled) {
            // if not enabled request bluetooth
            BluetoothPrintManager.requestBluetoothService();
            return;
        }
        else {
            //check if connected
            //alert(is_connected);
            if (is_connected) {
                printOrder();
                return;
            }
            // if blue tooth enabled, get selected printers id
            var id = $("#selPrintDevices").val();
           // alert(id)
            if (id == "0") {
                
                validation_alert("Go to settings and connect a printer");
                return;
            }
            // try to connect with the selected printer
            BluetoothPrintManager.connect(id, function (response) {
                printOrder()
                is_connected = true;

            }, function (error) {
                is_connected = false;
                validation_alert("An error occured while connecting with printer");
                
            });
        }
    }, function (error) {
        validation_alert("An error occured while connecting with printer");
    });
}

function printOrder() {
   
    overlay("Loading order details");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_print_details",
        data: "{'order_id':'" + $("#order_id").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                closeOverlay();
                onBackKeyDown();
                return;

            } else {

                var obj = JSON.parse(msg.d);
                console.log(obj);
                closeOverlay();

                // obj.data[0].new_creditamt
                //print srtarts

                    // clear buffer
                    BluetoothPrintManager.clearPrintBuffer();
                    // adding printing details to print buffer
                    addNewLine();
                    // add print header
                    BluetoothPrintManager.addToPrintBuffer("SAI AGRO PRODUCTS", { double_height: true, justification: 1 });
                    //BluetoothPrintManager.addToPrintBuffer("info@saiagroproducts.com", { justification: 1 });
                    BluetoothPrintManager.addToPrintBuffer("PH.NO: +91 88255 15673, 96290 28289", { justification: 1 });
                    BluetoothPrintManager.addToPrintBuffer("E-mail: info@saiagroproducts.com", { justification: 1 });
                    BluetoothPrintManager.addToPrintBuffer("SALEM-637501.TAMILNADU", { justification: 1 });
                    addNewLine();
                    BluetoothPrintManager.addToPrintBuffer("TAX INVOICE", { justification: 1, underline: true });
                    //BluetoothPrintManager.addToPrintBuffer("[GST IN 100355427400003]", { justification: 1, underline: true });
                    // add order header details to buffer
                    BluetoothPrintManager.addToPrintBuffer("INVOICE NO : " + obj.order[0].sm_invoice_no, {});
                    BluetoothPrintManager.addToPrintBuffer("DATE : " + obj.order[0].sm_date, {});
                    BluetoothPrintManager.addToPrintBuffer("CUSTOMER ID: " + obj.order[0].cust_reg_id, {});
                    BluetoothPrintManager.addToPrintBuffer("GST NO: " + obj.order[0].cust_tax_reg_id, {});
                    BluetoothPrintManager.addToPrintBuffer("NAME: " + obj.order[0].cust_name, {});
                    BluetoothPrintManager.addToPrintBuffer("PARTICUALRS", { justification: 1 });
                    addDottedLine();
                
                    // add cart items to buffer
                    $.each(obj.items, function (i, row) {

                        BluetoothPrintManager.addToPrintBuffer((i + 1) + ". " + row.itm_name, {});
                        BluetoothPrintManager.addToPrintBuffer("Qty:" + row.si_qty + "\tPrice:" + row.si_price, { addLF: false });
                        var foc_Line = (row.si_foc != 0 ? "FOC:" + row.si_foc + "\t" : "");
                        var dis_line = (row.si_discount_rate != 0 ? "Dis:" + row.si_discount_rate + "\t" : "");
                        BluetoothPrintManager.addToPrintBuffer(foc_Line + dis_line, { addLF: false });
                        BluetoothPrintManager.addToPrintBuffer(" Total:" + row.si_net_amount, { justification: 2 });
                        addNewLine();

                    });

                   // Footer
                    BluetoothPrintManager.addToPrintBuffer("Sub Total: " + format_decimal_accuray(obj.order[0].sm_tax_excluded_amt), { justification: 2 });
                    BluetoothPrintManager.addToPrintBuffer("Tax Amount: " + format_decimal_accuray(obj.order[0].sm_tax_amount), { justification: 2 });
                    //BluetoothPrintManager.addToPrintBuffer("VAT Percent: " + $('#branch_vat_percent').val(), { justification: 2 });
                    //BluetoothPrintManager.addToPrintBuffer("VAT Amount: " + vat_amount, { justification: 2 });
                    BluetoothPrintManager.addToPrintBuffer("Grand Total: " + format_decimal_accuray(obj.order[0].sm_netamount), { justification: 2 });
                    //BluetoothPrintManager.addToPrintBuffer("Last Payment: " + last_payment, { justification: 2 });
                    addNewLine();
                    //BluetoothPrintManager.addToPrintBuffer("Total Paid: " + resOrder.rows.item(0).paid_amt, { justification: 2 });
                    //BluetoothPrintManager.addToPrintBuffer("Total Balance: " + resOrder.rows.item(0).balance, { justification: 2 });
                    addDottedLine();
                    BluetoothPrintManager.addToPrintBuffer("SOLD BY: " + obj.order[0].name, { addLF: false, justification: 0 });
                    BluetoothPrintManager.addToPrintBuffer(" , BRANCH: " + obj.order[0].branch_name, { justification: 2 });
                    addNewLine();
                    BluetoothPrintManager.addToPrintBuffer("MOB: " + obj.order[0].phone, { addLF: false, justification: 0 });
                    //addDottedLine();
                    addNewLine();
                    addNewLine();
                    addNewLine();
                    addNewLine();
                    BluetoothPrintManager.addToPrintBuffer("   sign               sign  ", { addLF: true });
                    BluetoothPrintManager.addToPrintBuffer(" SALESMAN           CUSTOMER ", { addLF: true });
                    addNewLine();
                    addNewLine();
                    addNewLine();
                    addNewLine();
                    BluetoothPrintManager.printBufferedData(function (response) {
                        
                        //set connection state to false
                        is_connected = false;
                    }, function (error) {
                       
                        is_connected = false;
                    });

            
                // print ends
                
            }
        },
        error: function (xhr, status) {

            enableBackKey();
            closeOverlayImmediately();
            ajaxerroralert();
        }
    });
   
}
// add line to print buffer
function addDottedLine() {
    BluetoothPrintManager.addToPrintBuffer("-------------------------------", { addLF: true });
}

function addNewLine() {
    BluetoothPrintManager.addToPrintBuffer("\n", { addLF: false });
}

function load_print_options() {

    // validation_alert("Print functionality is temporarily unavailable"); return; // <option value="1" selected>Bluetooth Printer</option>

    if (ispopupshown == 0) {
        
        popuploaded();
        dialog = bootbox.dialog({
            message: '<div class="content" style="margin-bottom:2px;">' +
    '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
    '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>CHOOSE PRINTING METHOD</b><br />' +
    '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ORD ID : #' + $("#order_id").val() + '</small></span><br />' +
    '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +

    '<select id="Select_print_type" class="form-control border-input"><option value="1" selected>Bluetooth Printer</option><option value="2">Wi-Fi Printer</option></select>' +
    '<table style="margin-top:10px">' +
    '<tr>' +
    '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="check_print_type_and_proceed()">PRINT</button></td>' +
    '<td>&nbsp</td>' +
    '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:modalClose();">CANCEL</button></td>' +
    '</tr>' +
    '</table>' +
    '</div> ',
            closeButton: false
        });

        unipopup = dialog;
    }

}

function check_print_type_and_proceed() {

    var print_type = $("#Select_print_type").val();
    modalClose();
    if (print_type == "2") { print_full_order_via_wifi(); } else { connectAndPrint(); }
}

function print_full_order_via_wifi() {

    cordova.plugins.printer.print('http://jh.billcrm.com/sales/wifiBillPrint.aspx?orderId=' + $("#order_id").val() + '', 'Invoice_Ref_id_' + $("#order_id").val() + '');

}

function changeBg(div) {

    $("#divCart" + div).toggleClass("deliveredcart");
    processeditems = "";
    $('.deliveredcart').each(function () {
        var ar = this.id;
        if (processeditems == " " || processeditems == null) {
            processeditems = ar;
        }
        else {
            processeditems = processeditems + '/' + ar;
        }
    });
}

function reloadBgClass() {

    var a = processeditems.split("/"), i;
    if (a == undefined || a == null || a == "") {

    }
    else {
        $('.deliveredcart').toggleClass();
        for (i = 0; i < a.length; i++) {

            $("#" + a[i]).toggleClass();

        }
    }


}

// returns

function showSalesReturnPage() {
    showpage('div_common_sales_return');
    $("#select_return_user").val('0');
    $("#select_return_action").val('0');
    get_returned_item(1);
}

function get_returned_item(page) {

    overlay("searching for items");
    fixquotes();

    var postObj = {
        filters: {

            srm_userid: $("#select_return_user").val(),
            sr_action: $("#select_return_action").val(),
            user_id: $("#appuserid").val(),
            page: page,
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };

    // myApp.showPreloader('Loading Orders');
    disableBackKey();

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_returned_item",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 15000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";

            if (resp.d == "BLOCKED") {

                validation_alert("This Device / User has been blocked! Please contact admin.");
                onBackKeyDown();
            }
            else if (resp.d == "") {

                bootbox.alert('<p style="color:red">No Results Found</p>');
                return;

            }
            else if (resp.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Items found based on the search criteria';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_searached_return_items").html(htm);
                return;

            }
            else {

                var color = "";
                var response = JSON.parse(resp.d);
                var current_user_value = $("#select_return_user").val();
                var dhtm = '<option value="0">All Users</option>';

                $.each(response.user_data, function (i, row) {

                    dhtm = dhtm + '<option value="' + row.user_id + '">' + row.name + '</option>';
                });
                $("#select_return_user").html(dhtm);
                if (current_user_value != "0") { $("#select_return_user").val(current_user_value); }

                $.each(response.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:load_return_item_to_popup(\'' + row.sri_id + '\',\'' + row.sri_type + '\',\'' + row.sri_recieved_id + '\',\'' + row.sri_approved_id + '\',\'' + row.itbs_id + '\',\'' + row.itm_name + '\',\'' + row.itm_code + '\',\'' + row.sm_invoice_no + '\',\'' + row.sm_id + '\',\'' + row.sri_total + '\',\'' + row.sri_qty + '\',\'' + row.name + '\')">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var image = "assets/img/sales-return.png";
                    htm = htm + '<div class="avatar"> <img src="' + image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;"><b>' + row.itm_name + '</b>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>ORD REF.ID: #<b>' + row.sm_id + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>ITEM CODE: #<b>' + row.itm_code + '</b></small></span>';
                    htm = htm + '<br /><span class="text-danger"><small>RETURN QTY: <b>' + row.sri_qty + '</b></small></span>';
                    htm = htm + '<br><span class="text-danger"><small>Returned By : <b>' + row.name + '</b></small></span><br><span class="text-success"><small>Customer : <b>' + row.cust_name + '</b></small></span>';

                    if (row.sri_recieved_id != 0) {

                        htm = htm + '<br><span class="text-success"><small class="text-info">Received By : <b>' + row.rr_name + ' </b></small></span>';
                    }
                    if (row.sri_approved_id != 0) {

                        htm = htm + '<br><span class="text-success"><small class="text-info">Approved by : <b>' + row.adm_name + ' </b></small></span>';
                    }
                    htm = htm + '</div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.srm_date + '</small></br>';
                   // htm = htm + '<small class="text-info">Approved By : <b>' + row.adm_name + ' </b></small>';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                if (response.totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_retord" onclick="javascript:get_returned_item(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_retord" onclick="javascript:get_returned_item(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (response.totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_searached_return_items").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_retord").show();
                }
                if (page < parseInt(response.totPages)) {
                    $("#btnNext_retord").show();
                }
                if (parseInt(response.totPages) == 1) {
                    $("#btnNext_retord").hide();
                }
                if (parseInt(response.totPages) == page) {
                    $("#btnNext_retord").hide();
                }
            }

        },
        error: function (xhr, status) {

            closeOverlay();
            enableBackKey();
            var logfailed = bootbox.dialog({
                message: '<p class="text-center" style="color:red"><i class="ti-info"></i> Internet Error Occured</p>',
                closeButton: false
            });


            setTimeout(function () {
                logfailed.find(logfailed.modal('hide'));
            }, 1000);

        }
    });

}

function load_return_item_to_popup(sri_id, sri_type, sri_recieved_id,sri_approved_id, itbs_id, itm_name, itm_code, sm_invoice_no, sm_id, sri_total, sri_qty, name) {

    if (sri_approved_id == "0") {

        if (ispopupshown == 0) {
            popuploaded();
            dialog = bootbox.dialog({
                message: '<div class="content" style="margin-bottom:2px;">' +
        '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
        '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/sales-return.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
        '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + itm_name + '</b><br />' +
        '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ORD REF ID : #' + sm_id + ' </small></span><br />' +
        '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ITEM CODE : ' + itm_code + '</small></span><br />' +
        '<span class="text-danger"><small id="lbl_itmpop_itm_stock">RETURN QTY : ' + sri_qty + ' nos</small></span></div></div>' +
        '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
        '<label style="margin-top:10px">Reception Status</label>' +
        '<select id="SelectReceptionStatus" class="form-control border-input"><option value="0">NOT RECEIVED</option><option value="1">RECEIVED</option></select>' +
        '<label style="margin-top:10px">Item Condition</label>' +
        '<select id="SelectReturnItemType" class="form-control border-input"><option value="0">DAMAGED</option><option value="1">EXPIRED</option><option value="2">NO DAMAGE & READY TO USE</option></select>' +
        '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
        '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
        '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">TOTAL AMOUNT : ' + format_currency_value(sri_total) + '<br />' +
        '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">RETURNED BY : <b>' + name + '</b></small></span><br />' +
        '</div></div>' +
        '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
        '<table>' +
        '<tr>' +
        '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="update_return_status(' + sri_id + ')">UPDATE</button></td>' +
        '<td>&nbsp</td>' +
        '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#b53131;color:#fff;border:none;height:40px" onclick="javascript:modalClose();">CLOSE</button></td>' +
        '</tr>' +
        '</table>' +
        '</div> ',
                closeButton: false
            });

        }

        unipopup = dialog;
        initDomEvents();
        if (sri_recieved_id == "0") { $("#SelectReceptionStatus").val('0'); }
        else { $("#SelectReceptionStatus").val('1'); }

        $("#SelectReturnItemType").val(sri_type);
    }
    else { validation_alert("The Item's return has been already approved by admin!"); return;}

}

function update_return_status(sri_id) {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to Continue ?',
        callback: function (result) {
            if (result == false) {

                return;
            } else {

                var orderAdded = bootbox.dialog({
                    message: '<div align=center id="simage"><img class="avatar border-white" src="assets/img/overlayLoad.gif" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:#337ab7"><i class="ti-rss-alt"></i> processing return item</p></div>',
                    closeButton: false
                });

                var postObj = {

                    item: {

                        sri_id: sri_id,
                        user_id: $("#appuserid").val(),
                        time_zone: $("#ss_default_time_zone").val(),
                        recep_status: $("#SelectReceptionStatus").val(),
                        item_cond: $("#SelectReturnItemType").val(),
                    }
                };

                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/update_return_status",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 52000,
                    success: function (resp) {

                        enableBackKey();

                        if (resp.d == "SUCCESS") {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Item Return processed successfully!</p>');

                            modalClose();
                            setTimeout(function () {
                                orderAdded.find(orderAdded.modal('hide'));
                                get_returned_item(1);
                            }, 2000);

                        }
                        else {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-down"></i> Action failed, Please try again</p>');
                            setTimeout(function () {
                                orderAdded.find(orderAdded.modal('hide'));
                            }, 2000);
                        }


                    },
                    error: function (e) {

                        enableBackKey();

                        $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i> No Internet access..Please try again. </p>');

                        setTimeout(function () {
                            orderAdded.find(orderAdded.modal('hide'));
                        }, 1000);

                    }
                });

            }
        }

    })

}