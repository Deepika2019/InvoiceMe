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

var backKeyStatus = 1; // 1 - enabled , 0 -disabled

if (serverOn == "Yes") {

    getServerURL = " http://jh.billcrm.com/app_Admin.aspx";
    imgurl = " http://jh.billcrm.com/custimage/";
    Latitude = 0;
    Longitude = 0;
    androidkey = 0;
    imageYes = "0";
}
else {

    getServerURL = "http://localhost:2827/app_Admin.aspx";
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
function getDB() { return openDatabase('Invoice_Me_Admin_new.db', '2.0', 'web database', 5 * 1024 * 1024); }
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

        //tx.executeSql("DROP TABLE tbl_transactions");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_transactions (id VARCHAR NOT NULL,session_id VARCHAR NOT NULL,action_type VARCHAR NOT NULL,action_ref_id VARCHAR NOT NULL,partner_id VARCHAR NOT NULL,partner_type VARCHAR NOT NULL,branch_id VARCHAR NOT NULL,user_id VARCHAR NOT NULL,narration VARCHAR NOT NULL,cash_amt VARCHAR NOT NULL,wallet_amt VARCHAR NOT NULL,card_amt VARCHAR NOT NULL,card_no VARCHAR NOT NULL,cheque_amt VARCHAR NOT NULL,cheque_no VARCHAR NOT NULL,cheque_date VARCHAR NOT NULL,cheque_bank VARCHAR NOT NULL,dr VARCHAR NOT NULL,cr VARCHAR NOT NULL,date VARCHAR NOT NULL,is_reconciliation VARCHAR NOT NULL,closing_balance VARCHAR NOT NULL,trans_sync_status VARCHAR NOT NULL,is_new_registration VARCHAR NOT NULL)", [], function (tx, res) {

        });

        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_return_cart (sm_id VARCHAR NOT NULL,itbs_id VARCHAR NOT NULL,itm_code VARCHAR NOT NULL,itm_name VARCHAR NOT NULL,si_price VARCHAR NOT NULL,si_discount_rate VARCHAR NOT NULL,sri_qty VARCHAR NOT NULL,sri_total VARCHAR NOT NULL,sri_type VARCHAR NOT NULL)", [], function (tx, res) {

        });

        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_mynotes (msg_id VARCHAR NOT NULL,msg_date VARCHAR NOT NULL,msg_subject VARCHAR NOT NULL,msg_body VARCHAR NOT NULL)", [], function (tx, res) {

        });

        //tx.executeSql("DROP TABLE tbl_sales_items");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_sales_items (sm_id VARCHAR NOT NULL,itbs_id VARCHAR NOT NULL,itm_code VARCHAR NOT NULL,itm_name VARCHAR NOT NULL,si_org_price VARCHAR NOT NULL,si_price VARCHAR NOT NULL,si_qty VARCHAR NOT NULL,si_total VARCHAR NOT NULL,si_discount_rate VARCHAR NOT NULL,si_discount_amount VARCHAR NOT NULL,si_net_amount VARCHAR NOT NULL,si_foc VARCHAR NOT NULL,si_approval_status VARCHAR NOT NULL,itm_commision VARCHAR NOT NULL,itm_commisionamt VARCHAR NOT NULL,si_itm_type VARCHAR NOT NULL,si_item_tax VARCHAR NOT NULL,si_item_cess VARCHAR NOT NULL,si_tax_excluded_total VARCHAR NOT NULL,si_tax_amount VARCHAR NOT NULL,itm_type VARCHAR NOT NULL,itbs_stock VARCHAR NOT NULL,brand_name VARCHAR NOT NULL)", [], function (tx, res) {

        });
        //tx.executeSql("DROP TABLE tbl_sales_master");
        tx.executeSql("CREATE TABLE IF NOT EXISTS tbl_sales_master (sm_id VARCHAR NOT NULL,sessionId VARCHAR NOT NULL,sm_date VARCHAR NOT NULL, sm_cash_amt VARCHAR NOT NULL, sm_wallet_amt VARCHAR NOT NULL, sm_chq_amt VARCHAR NOT NULL, sm_chq_date VARCHAR NOT NULL, sm_bank VARCHAR NOT NULL, sm_chq_no VARCHAR NOT NULL, branch_tax_method VARCHAR NOT NULL, branch_tax_inclusive VARCHAR NOT NULL, branch VARCHAR NOT NULL, sm_userid VARCHAR NOT NULL, cust_id VARCHAR NOT NULL, sm_delivery_status VARCHAR NOT NULL, sm_specialnote VARCHAR NOT NULL, sm_latitude VARCHAR NOT NULL, sm_longitude VARCHAR NOT NULL, sm_order_type VARCHAR NOT NULL, sm_payment_type VARCHAR NOT NULL, sm_total VARCHAR NOT NULL,sm_discount_rate VARCHAR NOT NULL,sm_discount_amount VARCHAR NOT NULL,sm_netamount VARCHAR NOT NULL,total_paid VARCHAR NOT NULL,total_balance VARCHAR NOT NULL,sm_tax_amount VARCHAR NOT NULL, sm_action_type VARCHAR NOT NULL, sm_sync_status VARCHAR NOT NULL, sm_type VARCHAR NOT NULL, customer_status VARCHAR NOT NULL, sm_price_class VARCHAR NOT NULL,is_new_registration VARCHAR NOT NULL)", [], function (tx, res) {

        });



        var selectUser = "select * from tbl_appuser";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;

            if (len > 0) {

                $("#appuserid").val(res.rows.item(0).user_id);
                $("#db_last_updated_date").val(res.rows.item(0).db_last_updated_date);
                $("#loginval").val('1');
                $("#ss_user_password").val(res.rows.item(0).password);
                $("#ss_user_deviceid").val(res.rows.item(0).imei);
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

    var height = $(window).height();
    $("#divMap").height(parseInt(height) - 70);
    loadMapsApi();

}

// reading app setting on startup
function fetch_app_settings() {

    var db = getDB();
    db.transaction(function (tx) {


        var selectUser = "select * from tbl_system_settings";
        tx.executeSql(selectUser, [], function (tx, res) {
            var len = res.rows.length;

            if (len > 0) {

                //$("#ss_price_change").val(res.rows.item(0).ss_price_change);
                //$("#ss_discount_change").val(res.rows.item(0).ss_discount_change);
                //$("#ss_foc_change").val(res.rows.item(0).ss_foc_change);
                //$("#ss_class_change").val(res.rows.item(0).ss_class_change);
                //$("#ss_max_period_credit").val(res.rows.item(0).ss_max_period_credit);
                //$("#ss_new_registration").val(res.rows.item(0).ss_new_registration);
                //$("#ss_sales_return").val(res.rows.item(0).ss_sales_return);
                //$("#ss_due_amount").val(res.rows.item(0).ss_due_amount);

                $("#ss_price_change").val(0);
                $("#ss_discount_change").val(0);
                $("#ss_foc_change").val(0);
                $("#ss_class_change").val(0);
                $("#ss_max_period_credit").val(0);
                $("#ss_new_registration").val(0);
                $("#ss_sales_return").val(res.rows.item(0).ss_sales_return);
                $("#ss_due_amount").val(0);
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

            var selectbranch_info = "select * from tbl_branch where branch_id='" + $("#Select_Access_Branch").val() + "'";
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
            //senderID: "614955798424"
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

    var now = new Date(); var year = now.getFullYear(); var month = now.getMonth() + 1; var day = now.getDate(); var hour = now.getHours(); var minute = now.getMinutes(); var second = now.getSeconds();
    if (month.toString().length == 1) { var month = '0' + month; }
    if (day.toString().length == 1) { var day = '0' + day; }
    if (hour.toString().length == 1) { var hour = '0' + hour; }
    if (minute.toString().length == 1) { var minute = '0' + minute; }
    if (second.toString().length == 1) { var second = '0' + second; }
    var salesman_id = $("#appuserid").val();
    current_session_id = String(year) + String(month) + String(day) + String(hour) + String(minute) + String(second) + String(salesman_id);
}

// creating a temporary itbs id for NEW ITEM (not in the branch)
function getTempItbsID() {

    var now = new Date(); var year = now.getFullYear(); var month = now.getMonth() + 1; var day = now.getDate(); var hour = now.getHours(); var minute = now.getMinutes(); var second = now.getSeconds();
    if (month.toString().length == 1) { var month = '0' + month; }
    if (day.toString().length == 1) { var day = '0' + day; }
    if (hour.toString().length == 1) { var hour = '0' + hour; }
    if (minute.toString().length == 1) { var minute = '0' + minute; }
    if (second.toString().length == 1) { var second = '0' + second; }
    var tempitbs = "1" + String(day) + "" + String(hour) + "" + String(minute) + "" + String(second);
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

function upmodalClose() {

    updatepopup.modal('hide');
    updatepopup = "";
    unipopup = "";
    onBackMove();
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
        $("#" + divid + "").animate({ scrollTop: 0 }, "fast");
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
                //else if (hidingdiv == "divCustomerDetail") {

                //    Get_Customer_Details();
                //}
            else {

                var showingDiv = pageStack.pop();
                if (showingDiv == hidingdiv) {
                    var showingDiv = pageStack.pop();
                }

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
    var dval = (dateTimeVal.split(" "))[0];
    var tval = (dateTimeVal.split(" "))[1];
    var tAMPM = (dateTimeVal.split(" "))[2];

    var med = dval.split("/");
    var yy = med[2];
    var mm = med[0];
    var dd = med[1];

    var timeVal = "";

    if (tval) {
        var hr = (tval.split(":"))[0];
        var min = (tval.split(":"))[1];
        var sec = (tval.split(":"))[2];
        timeVal = ' ' + hr + ':' + min + (tAMPM ? ' ' + tAMPM : '');
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


    var curdate = dd + ' ' + mm + ' ' + yy + timeVal;

    return curdate;
}

function formatDateSTD(dateTimeVal) {
    var dval = (dateTimeVal.split(" "))[0];
    var tval = (dateTimeVal.split(" "))[1];
    var tAMPM = (dateTimeVal.split(" "))[2];

    var med = dval.split("/");
    var yy = med[2].slice(2);
    var mm = med[0];
    var dd = med[1];

    var timeVal = "";

    if (tval) {
        var hr = (tval.split(":"))[0];
        var min = (tval.split(":"))[1];
        var sec = (tval.split(":"))[2];
        timeVal = ' ' + hr + ':' + min + (tAMPM ? ' ' + tAMPM : '');
    }



    var curdate = dd + '/' + mm + '/' + yy + timeVal;

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

function takePhoto() {

    navigator.camera.getPicture(onSuccess, onFail, { targetWidth: 700, targetHeight: 700, quality: 50, destinationType: Camera.DestinationType.DATA_URL });
}

function onSuccess(imageURI) {

    imageYes = "1";
    imageURI = imageURI;

    var image = document.getElementById('myimage');
    imageURIN = imageURI;
    image.src = "data:image/jpeg;base64," + imageURIN;

}

function onFail(message) {

    // alert('Failed because: ' + message);
}

function loadNewImageFromServer(cust_image) {

    if (cust_image == "0") {

        var imageUpdate = document.getElementById('custdefaultimage');
        imageUpdate.src = "assets/img/noimage.png";
    }
    else {
        reset_cust_image();
        var imageUpdate = document.getElementById('custdefaultimage');
        imageUpdate.src = getUrlimage() + cust_image;
    }
}

function load_image_From_Server_for_customer_data(cust_image) {



    if (cust_image == "0") {

        var imageUpdate = document.getElementById('myimage');
        imageUpdate.src = "assets/img/noimage.png";
        $("#is_image_exist").val("0");
    }
    else {

        var cimageUpdate = document.getElementById('myimage');
        cimageUpdate.src = "assets/img/noimage.png";

        var imageUpdate = document.getElementById('myimage');
        imageUpdate.src = getUrlimage() + cust_image;
        $("#is_image_exist").val("1");
    }
}

function reset_cust_image() {

    var imageUpdate = document.getElementById('custdefaultimage');
    imageUpdate.src = "assets/img/noimage.png";
}

var map;
var userMarker;
var watch_id;
var map_watch_id;
var cus_infowindow;

function showcurrentPosition(latlng) {
    if (!userMarker) {
        userMarker = new google.maps.Marker({
            position: latlng,
            map: map,
            icon: 'http://maps.google.com/mapfiles/ms/icons/blue-dot.png'
        });
        userMarker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|4d89ea|13|b|You');
        (function (marker) {
            var infowindow = new google.maps.InfoWindow({
                content: "YOU"
            });
            marker.addListener('click', function () {
                infowindow.open(map, marker);
            });
        })(userMarker);
        map.setCenter(latlng);
    }
    else {
        userMarker.setPosition(latlng);
    }
    //alert(userMarker)
}

function showCustomersOnMap() {

    showpage('divMapContainer');
    if (serverOn == "Yes") {
        stopWatchingLocation(map_watch_id);
        userMarker = undefined;
        navigateUserOnMap();
        locationStateListener();
    }
    initialize('divMap');
}

function navigateUserOnMap() {
    //stopWatchingLocation(map_watch_id);
    isLocationEnabled(function () {
        requestLocationPermisstion(function (resp) {
            if (resp.status) {
                map_watch_id = watchlocation(map_watch_id, function (position) {
                    var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                    showcurrentPosition(latlng);
                }, function () {

                });
            }
            else {
                //permisstion denied
            }
        }, function (error) {
            alert(JSON.stringify(error))
        });

    }, function (error) { });

}

// for loading google map api
function loadMapsApi() {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'http://maps.googleapis.com/maps/api/js?key=AIzaSyCWvHWrDDwowXKHTPzORjR5N5u_JRfO0o8&sensor=false';
    script.async = true;
    document.body.appendChild(script);
}

//map initialization
function initialize(id) {
    var mapProp = {
        center: new google.maps.LatLng(10.014759150281261, 76.51599743408147),
        zoom: 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById(id), mapProp);

    //google.maps.event.addListenerOnce(map, 'idle', function() { google.maps.event.trigger(map, 'resize'); });
    if (id == "divMap") {
        showMarkers();
    }
}
//showing markers on map

function showMarkers() {

    var user_id = $("#appuserid").val();
    disableBackKey();

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Customers",
        data: "{'user_id':'" + user_id + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 15000,
        success: function (msg) {

            enableBackKey();
            var markers_obj = JSON.parse(msg.d);

            $.each(markers_obj.data, function (i, markerObj) {
                var myLatlng = new google.maps.LatLng(markerObj.lat, markerObj.lng);
                var marker = new google.maps.Marker({
                    position: myLatlng,
                    map: map

                });
                (function (marker, data) {
                    cus_infowindow == undefined;
                    cus_infowindow = new google.maps.InfoWindow({});
                    //marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.80|0|ce4704|15|b| ');
                    marker.addListener('click', function () {
                        cus_infowindow.setContent('<div style="overflow: auto;">Customer :' + data.cust_name + '<br><a href="#" onclick="javascript:show_Customer_Details(' + data.cust_id + ')">View Customer</a></div>');
                        cus_infowindow.open(map, marker);
                    });
                })(marker, markerObj);
            });



        },
        error: function (xhr, status) {

            enableBackKey();
            ajaxerroralert();

        }
    });



}

function locationStateListener() {
    cordova.plugins.diagnostic.registerLocationStateChangeHandler(function (state) {
        var currentdiv = $("#hdnCurrentDiv").val();
        //alert(state);
        if (state !== cordova.plugins.diagnostic.locationMode.LOCATION_OFF && currentdiv == 'divMapContainer') {
            navigateUserOnMap();
        }
        else {
            stopWatchingLocation(map_watch_id);
        }
    });
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

// function to get location
function getlocation(enableHighAccuracy, successCallback, errorCallBack, locUnavailableCallback) {
    // alert(locUnavailableCallback);


    if (!locUnavailableCallback) {
        locUnavailableCallback = function () { }
    }

    isLocationEnabled(function () {
        requestLocationPermisstion(function (resp) {
            // alert(JSON.stringify(resp))
            if (resp.status) {
                // check high accur
                if (enableHighAccuracy) {
                    // stop watching location
                    stopWatchingLocation(watch_id);
                    // array to hold all locations b/w time interwal
                    var position_array = [];
                    watch_id = watchlocation(watch_id, function (position) {
                        position_array.push(position);
                    }, function (error) { }, 1000);
                    // timout 10000- to varify accracy:check atleast 5 positions are added to array
                    setTimeout(function () {
                        // stop watching location
                        stopWatchingLocation(watch_id);
                        // check position array count
                        if (lowaccuval == "No") {
                            if (position_array.length >= 4) {
                                // return last location
                                // alert(position_array.length)
                                successCallback(position_array.pop());
                            }
                            else {
                                errorCallBack({ message: "low accuracy" });
                            }
                        }
                        else {

                            if (position_array.length >= 1) {
                                // return last location
                                // alert(position_array.length)
                                successCallback(position_array.pop());
                            }
                            else {
                                errorCallBack({ message: "low accuracy" });
                            }
                        }
                    }, 10000);


                }
                else {
                    // alert("low");
                    navigator.geolocation.getCurrentPosition(successCallback, errorCallBack
                    , { maximumAge: 3000, timeout: 20000, enableHighAccuracy: true });
                }
            }
            else {
                errorCallBack({ message: "Permission Denied" });
            }
        }, function (error) {
            alert(JSON.stringify(error))
        });

    }, locUnavailableCallback);
}

// to watch location
function watchlocation(old_watch_id, successCallback, errorCallBack, timeout) {
    stopWatchingLocation(old_watch_id);
    if (!errorCallBack) {
        errorCallBack = function () { }
    }
    if (!timeout) {
        timeout = 3000;
    }

    return navigator.geolocation.watchPosition(successCallback, errorCallBack, { maximumAge: 10000, timeout: timeout, enableHighAccuracy: true });

}
// to stop watching location
function stopWatchingLocation(w_id) {
    if (w_id) {
        navigator.geolocation.clearWatch(w_id);
    }

}

// function to call another routine periodically
function callPeriodically(routine, period) {
    var callId = setInterval(routine, period);
    return callId;
}

// function for stop calling routine periodically
function stopPeriodicCall() {
    if (periodicCallId) {
        clearInterval(periodicCallId);
    }
}
// function to check if location available or not
function isLocationEnabled(availableCallBack, unavailableCallback) {
    cordova.plugins.diagnostic.isGpsLocationEnabled(function (available) {
        if (!available) {
            var error = { loc_enabled: false };
            //alert(error);
            unavailableCallback(error);
            var f = confirm("Enable location service?");
            if (f) {
                enableBackKey();
                cordova.plugins.diagnostic.switchToLocationSettings();
            } else {

                enableBackKey();
            }
        }
        else {
            availableCallBack();
        }
    }, function (error) {
        unavailableCallback(error);
        console.error("The following error occurred: " + error);
    });
}

// function check and request access location permisstion
function requestLocationPermisstion(successCallback, errorCallBack) {
    if (!errorCallBack) {
        errorCallBack = function (error) { }
    }
    cordova.plugins.diagnostic.getPermissionAuthorizationStatus(function (status) {
        if (status == cordova.plugins.diagnostic.permissionStatus.GRANTED) {
            successCallback({ status: true });
        }
        else {
            cordova.plugins.diagnostic.requestRuntimePermission(function (status) {
                if (status == cordova.plugins.diagnostic.permissionStatus.GRANTED) {
                    successCallback({ status: true });
                }
                else {
                    successCallback({ status: false });
                }
            }, function (error) {
                errorCallBack(error);
            }, cordova.plugins.diagnostic.permission.ACCESS_FINE_LOCATION);
        }
    }, function (error) {
        errorCallBack(error);
    }, cordova.plugins.diagnostic.permission.ACCESS_FINE_LOCATION);
}

function showfollDatepic() {

    //$('#txtcustExpandFollowup_date').
    var l = document.getElementById('txtcustExpandFollowup_date');

    l.click();

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

    if (androidkey == 0) { ajaxerroralert(); getAndroidId(); return; }
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

    overlay("logging you in");
    disableBackKey();

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

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
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
                        tx.executeSql("DELETE FROM tbl_sales_master");
                        tx.executeSql("DELETE FROM tbl_sales_items");
                        tx.executeSql("DELETE FROM tbl_item_cart");
                        tx.executeSql("DELETE FROM tbl_itembranch_stock");
                        tx.executeSql("DELETE FROM tbl_location");
                        tx.executeSql("DELETE FROM tbl_branch");

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

                $("#lbl_settings_name").html(res.rows.item(0).name + '<br /><small> Admin</small>');

            }
            else {


            }

        });


    }, function (e) {
        alert("ERROR: " + e.message);
    });
}

// fetching customer location for registration
function fetchLocationforCustomer() {

    overlay("fetching location data");
    disableBackKey();

    getlocation(true, function (position) {

        enableBackKey();
        closeOverlay();
        Latitude = position.coords.latitude;
        Longitude = position.coords.longitude;

        var latlng = new google.maps.LatLng(Latitude, Longitude);
        var geocoder = geocoder = new google.maps.Geocoder();
        geocoder.geocode({ 'latLng': latlng }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                if (results[1]) {

                  //  alert("Location: " + results[1].formatted_address);
                    var address_details = results[1].formatted_address
                    var splitter = address_details.split(",");
                    var streetname = splitter[0];
                    var place = splitter[1];

                    $("#txtstreetname").val(streetname);
                    $("#txtPlace").val(place);


                }
            }
        });

        $("#newcustomerlocation").val(Latitude + ',' + Longitude);
        $("#editcustomerlocation").val(Latitude + ',' + Longitude);


    }, function (error) {

        enableBackKey();
        closeOverlay();
        validation_alert('unable to get the location , please try again');

    }, function (locUnavailableObj) {
        enableBackKey();
        closeOverlay();
    });


}

// loading customer list for new order
function showCustomers() {
    $("#txtsearchCustomer").val("");
    showpage('divCustomerList');
    $("#divListCustomer").html('');
    list_customers(1);
}

function list_customers(page) {

    overlay("Loading Customer List ");
    disableBackKey();
    fixquotes();
    var postObj = {

        filters: {

            user_id: $("#appuserid").val(),
            search_term: $.trim($("#txtsearchCustomer").val()),
            page: page,
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/list_customers",
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
            else if (resp.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);
                var is_new_registration = "";
                var area = $("#ss_currency").val();
                var tax_head = 0;
                $.each(response.customer_list, function (i, row) {

                    is_new_registration = row.is_new_registration;
                    if (is_new_registration == "1") { is_new_registration = '<b style="color:red">[NEW]</b>' } else { is_new_registration = ""; }
                    var color = 0;
                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + String(row.cust_id) + ');">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + is_new_registration + ' ' + String(row.cust_name) + '<br />';
                    if (row.cust_reg_id != "" && row.cust_reg_id != null && row.cust_reg_id != undefined && row.cust_reg_id != "0") {

                        htm = htm + '<span class="text-info"><small>CUSTOMER ID: <b>' + String(row.cust_reg_id) + '</b></small></span><br />';
                    }
                    if (area == "AED") { tax_head = "TRN NO"; } else if (area == "Rs") { tax_head = "GSTIN"; } else { }
                    if (row.cust_tax_reg_id != "" && row.cust_tax_reg_id != null && row.cust_tax_reg_id != undefined && row.cust_tax_reg_id != "0") {

                        htm = htm + '<span class="text-info"><small>' + tax_head + ': <b>' + String(row.cust_tax_reg_id) + '</b></small></span><br />';
                    }

                    htm = htm + '<span class="text-success"><small>' + String(row.cust_address) + ',' + String(row.cust_city) + '</small></span>';
                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';


                });

                var totalRows = parseInt(response.totalRows);
                $("#lbl_cust_toto_count_at_view").html(' ('+totalRows+')');
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod" onclick="javascript:list_customers(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod" onclick="javascript:list_customers(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#divListCustomer").html(htm);
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

function showdivMyNotes() {

    showpage('divListNotes');
    list_My_Notes(1);
}

function show_new_note_page() {

    showpage('divMyNotes');
    $("#txt_msg_subject").val("");
    $("#txt_msg_body").val("");
}

function save_mynote() {

    fixquotes();
    var msg_id = getTempItbsID();
    var msg_subject = $.trim($("#txt_msg_subject").val());
    var msg_body = $.trim($("#txt_msg_body").val());
    var msg_date = offline_get_date_time();

    if (msg_subject == "") { validation_alert("Please enter the subject for the note"); return; }
    if (msg_body == "") { validation_alert("Please enter the note"); return; }

    var db = getDB();
    db.transaction(function (tx) {
        var insert_tbl_customer = "INSERT INTO tbl_mynotes(msg_id,msg_date,msg_subject,msg_body) VALUES('" + msg_id + "','" + msg_date + "','" + msg_subject + "','" + msg_body + "')";
        tx.executeSql(insert_tbl_customer, [], function (tx, res) {

            onBackKeyDown();
            successalert("Note saved successfully!");
            list_My_Notes(1);

        });

    }, function (e) {
        alert("ERROR: " + e.message);
    });


}

function list_My_Notes(page) {

    var perPage = 15;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var qryCount = "";
    qryCount = "SELECT count(*) as cnt FROM tbl_mynotes";

    var db = getDB();
    db.transaction(function (tx) {



        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            totPages = Math.ceil(totalRows / perPage);
            var htm = "";

            var selectItemsQry = "select * from tbl_mynotes order by msg_date desc limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItemsQry, [], function (tx, res) {
                var len = res.rows.length;

                if (len > 0) {
                    var is_new_registration = "";

                    for (var i = 0; i < len; i++) {
                        var color = 0;
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;">';
                        htm = htm + '<div class="col-xs-12" style="background-color:#337ab7;color:#fff;" >' + String(res.rows.item(i).msg_date) + '</div>';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + String(res.rows.item(i).msg_subject) + '<br />';
                        htm = htm + '<span class="text-success"><small>' + String(res.rows.item(i).msg_body) + '</small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrevlist025" onclick="javascript:list_My_Notes(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNextlist025" onclick="javascript:list_My_Notes(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';

                    $("#divListMyNotes").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 000);


                    if (page > 1) {
                        $("#btnPrevlist025").show();
                    }
                    if (page < totPages) {
                        $("#btnNextlist025").show();
                    }
                    if (totPages == 1) {
                        $("#btnNextlist025").hide();
                    }
                    if (totPages == page) {
                        //$("#btnPrevlist").hide();
                        $("#btnNextlist025").hide();
                    }
                    if (page == 1) { $("#btnPrevlist025").hide(); }
                }

                else {

                    htm = htm + '<div class="widget-tasks-item" style="margin-bottom:2px;text-align:center" ><div class="user-card-row" ><div class="tbl-row"><div class="tbl-cell tbl-cell-photo">';
                    htm = htm + '<p>NO NOTES FOUND</p>';
                    htm = htm + '<p class="color-blue" style="font-size:14px;style="color:#ba4689;"></p> </div></div></div><div class="btn-group widget-menu">';
                    htm = htm + '</button >';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-top:0px;margin-bottom:2px" />';

                    $("#divListMyNotes").html(htm);
                }



            });

        });

    }, function (e) {

        alert(e);
    });

}

function Get_category_and_locations() {

    overlay("fetching data for registration");

    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_category_and_locations",
        data: "{'user_id':'" + $("#appuserid").val() + "'}",
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
                closeOverlay();

                var chtm = "";
                chtm = chtm + '<option value="0">choose category</option>';
                $.each(obj.dt_category, function (i, row) {

                    chtm = chtm + '<option value="' + String(row.cust_cat_id) + '">' + String(row.cust_cat_name) + '</option>';
                });

                $("#SelectCustomerCategory").html(chtm);

                var insert_qry_tbl_location = "INSERT INTO tbl_location VALUES ";
                var tbl_location_values = "";

                $.each(obj.dt_locations, function (i, row) {

                    tbl_location_values = tbl_location_values + " ('" + row.location_id + "','" + row.location_name + "','" + row.state_id + "','" + row.state_name + "','" + row.country_id + "'),";

                });

                tbl_location_values = tbl_location_values.replace(/,\s*$/, "");

                var db = getDB();
                db.transaction(function (tx) {

                    tx.executeSql("delete from tbl_location");
                    var query = insert_qry_tbl_location + tbl_location_values;
                    if (tbl_location_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                    var selectTrans = "select state_id,state_name from tbl_location group by state_id";
                    tx.executeSql(selectTrans, [], function (tx, res) {
                        var shtm = "";
                        var len = res.rows.length;
                        if (len > 0) {

                            shtm = shtm + '<option value="0">Select State</option>';
                            for (var i = 0; i < len; i++) {
                                shtm = shtm + '<option value="' + String(res.rows.item(i).state_id) + '">' + String(res.rows.item(i).state_name) + '</option>';
                            }
                            $("#SelectStateforRegistration").html(shtm);

                        }
                        else {

                        }

                    });


                },
                function (e) {

                    alert(e.message);
                }
                );

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

// customer registration page - related functions - start
function showCustomerRegistraionPage() {
    showpage('divAddNewCustomer');
    $("#lbl_customer_action").html('<h5 class="title" id="lbl_customer_action" style="color:#337ab7">CUSTOMER REGISTRATION<br /> <small style="color:#635c5c">Please fill the details</small></h5>');
    clearRegistrationFields();
    $("#btn_customer_update").hide();
    $("#btn_customer_reg").show();
    $("#section_credit_class").show();
    $("#txtMaxCredit").val($("#ss_default_max_credit").val());
    $("#txtMaxPeriod").val($("#ss_default_max_period").val());
    getSessionID();
    Get_category_and_locations();
}

// loading accessible branches to combo - in the customer detail page
function load_states_locations_to_combo() {

    var db = getDB();
    db.transaction(function (tx) {

        var selectTrans = "select state_id,state_name from tbl_location group by state_id";
        tx.executeSql(selectTrans, [], function (tx, res) {
            var shtm = "";
            var len = res.rows.length;
            if (len > 0) {

                shtm = shtm + '<option value="0">Select State</option>';

                for (var i = 0; i < len; i++) {

                    shtm = shtm + '<option value="' + String(res.rows.item(i).state_id) + '">' + String(res.rows.item(i).state_name) + '</option>';
                }

                $("#SelectStateforRegistration").html(shtm);

            }
            else {

            }

        });

    });
}

// load locations based on states - > using state id
function loadLocationbasedonState() {

    var state_id = $("#SelectStateforRegistration").val();
    if (state_id == "0") {

        $("#SelectLocationforRegistration").html('<option value="0">please select a State</option>');
    }
    else {

        var db = getDB();
        db.transaction(function (tx) {

            var selectTrans = "select location_id,location_name from tbl_location where state_id='" + state_id + "'";
            tx.executeSql(selectTrans, [], function (tx, res) {
                var lhtm = "";
                var len = res.rows.length;
                if (len > 0) {

                    lhtm = lhtm + '<option value="0">Select Location</option>';

                    for (var i = 0; i < len; i++) {

                        lhtm = lhtm + '<option value="' + String(res.rows.item(i).location_id) + '">' + String(res.rows.item(i).location_name) + '</option>';
                    }

                    $("#SelectLocationforRegistration").html(lhtm);

                }
                else {

                    $("#SelectLocationforRegistration").html('<option value="0">Select Location</option>');

                }

            });


        }, function (e) {

            alert(e.message);

        });

    }
}

// clear all form fields for registration , updation
function clearRegistrationFields() {

    $("#is_image_exist").val('0')
    imageURIN = "";
    imageYes = "0";
    $("#txtStoreName").val('');
    $("#textgst_trn_number").val('');
    $("#textCustomerRegId").val('');
    $("#SelectCustomerCategory").html('<option value="0">choose category</option>');
    $("#txtstreetname").val('');
    $("#txtPlace").val('');
    $("#txtPhoneNumber").val('');
    $("#txtPhoneNumber2").val('');
    $("#SelectStateforRegistration").html('<option value="0">Select State</option>');
    $("#SelectLocationforRegistration").html('<option value="0">Select Location</option>');
    $("#txtEmail").val('');
    $("#selCusType").val('0');
    $("#txtMaxCredit").val('');
    $("#txtMaxPeriod").val('');
    $("#txtCustomerNote").val('');
    $("#newcustomerlocation").val('Not Found');
    $("#myimage").attr("src", "assets/img/noimage.png");
    Latitude = 0;
    Longitude = 0;
}

// customer field validation
function validateAndSave(type) {

    validate_customer_form(type);

}

function validate_customer_form(type) {

    fixquotes();
    // perform validations
    if (serverOn == "Yes" && test_mode == 0) {

        if ($("#is_image_exist").val() == "0") {
            if (imageYes == "0") { validation_alert("Please take photo of customer by clicking camera button"); return; }
        }
        if (Latitude == 0 && Longitude == 0) { validation_alert("Customer Location Required!"); return; }

    }

    if (serverOn == "Yes" && test_mode == 0) {


    }

    if ($("#txtStoreName").val() == "") { validation_alert("Please enter the Store/Customer name!"); return; }
    if ($("#SelectCustomerCategory").val() == "0") { validation_alert("Please select a category for the customer!"); return; }

    if ($("#ss_reg_id_required").val() == "1") {

        if ($("#textCustomerRegId").val() == "") { validation_alert("Please enter the registration id!"); return; }
    }
    if ($("#ss_trn_gst_required").val() == "1") {

        if ($("#textgst_trn_number").val() == "") { validation_alert("Please enter the TRN/GST Number!"); return; }
    }

    if ($("#txtstreetname").val() == "") { validation_alert("Please enter the Street name!"); return; }
    if ($("#txtPlace").val() == "") { validation_alert("Please enter the Place!"); return; }


    if ($("#SelectStateforRegistration").val() == "0") { validation_alert("Please select a state!"); return; }
    if ($("#SelectLocationforRegistration").val() == "0") { validation_alert("Please select a location!"); return; }

    if ($("#ss_validation_email").val() == "1") {

        if ($("#txtEmail").val() == "") { validation_alert("Please enter the email!"); return; }
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!filter.test(email)) { validation_alert("Please enter a vaild email!"); return; }
    }

    if ($("#txtEmail").val() != "") {

        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!filter.test($("#txtEmail").val())) { validation_alert("Please enter a vaild email!"); return; }
    }

    if ($("#ss_phone_email").val() == "1") {

        if ($("#txtPhoneNumber").val() == "") { validation_alert("Please enter the Phone number!"); return; }
        if ($("#txtPhoneNumber").val() != "" && $("#txtPhoneNumber2").val() != "") {

            if ($("#txtPhoneNumber").val() == $("#txtPhoneNumber2").val()) { validation_alert(" Phone numbers cannot be same! "); return; }
        }
    }

    if (type == 1) {

        if ($("#selCusType").val() == "0") { validation_alert("Please select a price class type!"); return; }
        if ($("#txtMaxCredit").val() == "" || $("#txtMaxCredit").val() == "0") { validation_alert("Please enter the maximum credit amount!"); return; }
        if ($("#txtMaxPeriod").val() == "" || $("#txtMaxPeriod").val() == "0") { validation_alert("Please enter the maximum credit period!"); return; }
    }

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {
                return;
            } else {

                if (type == 1) { customer_Registration(); }
                else if (type == 2) { update_customer_details(); }
                else { }
            }
        }
    });

}

// registering customer - > try online  first , if succeed save offline with cust_id from server -> if failed insert in local with session id as cust_id
function customer_Registration() {

    var postObj = {

        data: {

            cust_name: $("#txtStoreName").val(),
            cust_type: $("#selCusType").val(),
            cust_address: $("#txtstreetname").val(),
            cust_city: $("#txtPlace").val(),
            cust_state: $("#SelectStateforRegistration").val(),
            cust_phone: $("#txtPhoneNumber").val(),
            cust_phone1: $("#txtPhoneNumber2").val(),
            cust_email: $("#txtEmail").val(),
            cust_latitude: Latitude,
            cust_longitude: Longitude,
            cust_image: imageURIN,
            cust_note: $("#txtCustomerNote").val(),
            user_id: $("#appuserid").val(),
            max_creditamt: $("#txtMaxCredit").val(),
            max_creditperiod: $("#txtMaxPeriod").val(),
            cust_sessionid: current_session_id,
            cust_reg_id: $.trim($("#textCustomerRegId").val()),
            location_id: $("#SelectLocationforRegistration").val(),
            cust_cat_id: $("#SelectCustomerCategory").val(),
            cust_tax_reg_id: $("#textgst_trn_number").val(),
            timezone: $("#ss_default_time_zone").val(),

        }
    };

    overlay("Registering Customers ");
    disableBackKey();
    //alert(JSON.stringify(postObj));
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/customer_Registration",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (resp) {

            closeOverlayImmediately();
            enableBackKey();

            var obj = JSON.parse(resp.d);

            if (resp.d == "") {

                validation_alert("Registration Failed! Please try again");
            }
            else if (resp.d == "FAILED") {

                validation_alert("Registration Failed! Please try again");
            }
            else if (resp.d == "REGID") {

                validation_alert("Registration ID exist with another customer! Please provide a different ID");
            }
            else if (obj.result == "SUCCESS" || obj.result == "EXIST") {

                if ($("#textCustomerRegId").val() == "") { $("#textCustomerRegId").val(obj.customer_id) }
                onBackKeyDown();
                successalert("Customer Registration Succeed!");
                $("#txtsearchCustomer").val($("#txtStoreName").val());
                list_customers(1);
                clearRegistrationFields();
            }


        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

// load customer details // loading banches for sales
function show_Customer_Details(customer_id) {

    showpage('divCustomerDetail');
    $("#customer_id").val(customer_id);
    Get_Customer_Details();

}

function Get_Customer_Details() {

    overlay("Loading customer details");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Customer_Details",
        data: "{'cust_id':'" + $("#customer_id").val() + "','user_id':'" + $("#appuserid").val() + "'}",
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
                closeOverlay();

                var insert_qry_tbl_branch = "INSERT INTO tbl_branch VALUES ";
                var tbl_branch_values = "";
                $.each(obj.branch, function (i, row) {

                    tbl_branch_values = tbl_branch_values + " ('" + row.branch_id + "','" + row.branch_name + "','" + row.branch_timezone + "','" + row.branch_tax_method + "','" + row.branch_tax_inclusive + "'),";
                });
                tbl_branch_values = tbl_branch_values.replace(/,\s*$/, "");

                var db = getDB();
                db.transaction(function (tx) {
                    tx.executeSql("delete from tbl_branch");
                    var query = insert_qry_tbl_branch + tbl_branch_values;
                    if (tbl_branch_values != "") {
                        tx.executeSql(query, [], function (tx, res) {

                        });
                    }

                },
                function (e) {

                    alert(e.message);
                }
                );



                var class_type = obj.data[0].new_custtype != 0 ? obj.data[0].new_custtype : obj.data[0].cust_type;
                $("#sm_price_class").val(class_type);
                if (class_type == "1") { $("#cust_class_for_order").val("itm_class_one"); }
                else if (class_type == "2") { $("#cust_class_for_order").val("itm_class_two"); }
                else if (class_type == "3") { $("#cust_class_for_order").val("itm_class_three"); }

                class_type = class_type == 1 ? "A class" : class_type == 2 ? "B Class" : class_type == 3 ? "C Class" : "Unavailable";
                var max_credit = obj.data[0].new_creditamt != 0 ? obj.data[0].new_creditamt : obj.data[0].max_creditamt;
                var max_period = obj.data[0].new_creditperiod != 0 ? obj.data[0].new_creditperiod : obj.data[0].max_creditperiod;
                $("#cust_max_credit_allowed").val(max_credit);

                $("#gg_map_lat").val(obj.data[0].cust_latitude);
                $("#gg_map_lon").val(obj.data[0].cust_longitude);

                $("#cust_current_status").val(obj.data[0].cust_status);
                if (obj.data[0].cust_status == 0) { $("#cust_approval_div").hide(); }
                else if (obj.data[0].cust_status == 1) { $("#cust_approval_div").show(); }
                else { $("#cust_approval_div").hide(); }
                $("#txt_lbl_customer_name").html(obj.data[0].cust_name + ' <small style="color:#337ab7">[' + class_type + ']</small><br /><a href="#"><small id="exCustAddress" style="color:#635c5c">' + obj.data[0].cust_address + ', ' + obj.data[0].cust_city + '</small></a>');
                var curbal = 0.00;
                curbal = parseFloat(obj.data[0].cust_amount);
                curbal = curbal.toFixed($("#ss_decimal_accuracy").val());
                $("#cust_current_outstanding").val(curbal);
                var cwallet = 0.00;
                if (curbal < 0) {

                    curbal = curbal * (-1);
                    cwallet = curbal.toFixed($("#ss_decimal_accuracy").val());
                    curbal = 0.00;
                }

                var yyyy = new Date().getFullYear();
                $('#txtcustExpandFollowup_date').scroller({
                    preset: 'date',
                    endYear: yyyy + 10,
                    setText: 'Select',
                    invalid: {},
                    theme: 'android-ics',
                    display: 'modal',
                    mode: 'scroller',
                    dateFormat: 'dd-mm-yy'
                });
                var cday = currentdate();


                max_credit = parseFloat(max_credit).toFixed($("#ss_decimal_accuracy").val());
                $("#exwallet").html('<small style="color:#337ab7">Wallet<br /></small>' + cwallet + ' <small>' + $("#ss_currency").val() + '</small>');
                $("#excredit").html('<small style="color:#337ab7">Max Credit<br /></small>' + max_credit + ' <small>' + $("#ss_currency").val() + '</small>');
                $("#excreditperiod").html('<small style="color:#337ab7">Period<br /></small>' + max_period + '  <small>Days</small>');
                $("#exclassname").html('<h5 class="title" id="" style="font-size:14px;color:#d01b1b">Total Outstanding : ' + curbal + ' ' + $("#ss_currency").val() + ' <small style="color:#337ab7"></small></h5>');

                if (obj.data[0].cust_followup_date != 'null') {
                    $("#txtcustExpandFollowup_date").val(obj.data[0].cust_followup_date);
                } else { $("#txtcustExpandFollowup_date").val('NO INFO'); }

                fetch_branch_to_combo();
                reset_branch_values();

                loadNewImageFromServer(obj.data[0].cust_image);



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

function update_customer_status(status) {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {

                return;

            } else {

                if (status == 0) { overlay("Approving customer registration"); }
                else if (status == 2) { overlay("Rejecting customer registration"); }
                else { overlay("Processing your request"); }

                disableBackKey();
                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/update_customer_status",
                    data: "{'time_zone':'" + $("#ss_default_time_zone").val() + "','cust_id':'" + $("#customer_id").val() + "','user_id':'" + $("#appuserid").val() + "','status':'" + status + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 30000,
                    success: function (msg) {

                        enableBackKey();
                        closeOverlayImmediately();
                        if (msg.d == "ERROR") {
                            validation_alert("Action failed at server! Please try again");
                            return;
                        }
                        else if (msg.d == "TR") {
                            validation_alert("The Customer is having balance/wallet amount in the system hence cannot be rejected! Please try again after clearing all the payments");
                            return;
                        }
                        else if (msg.d == "EX") {

                            if (status == 0) { successalert("The Customer registration has been approved by someone else"); }
                            else if (status == 2) { successalert("The Customer registration has been rejected by someone else"); }
                            else { successalert("Action completed succesfully!"); }
                            Get_Customer_Details();
                            return;
                        }
                        else if (msg.d == "SUCCESS") {

                            if (status == 0) { successalert("The Customer registration has been approved successfully"); }
                            else if (status == 2) { successalert("The Customer registration has been rejected succesfully"); }
                            else { successalert("Action completed succesfully!"); }
                            Get_Customer_Details();
                        }
                        else { validation_alert("Unknown error occured at server! Please try again."); }
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
        }
    });

}

function approve_or_reject_order(status) {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {

                return;

            } else {

                if (status == 0) { overlay("Approving the Order"); }
                else if (status == 2) { overlay("Rejecting the Order"); }
                else { overlay("Processing your request"); }

                disableBackKey();
                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/approve_or_reject_order",
                    data: "{'cust_id':'" + $("#customer_id").val() + "','time_zone':'" + $("#ss_default_time_zone").val() + "','order_id':'" + $("#order_id").val() + "','user_id':'" + $("#appuserid").val() + "','status':'" + status + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 30000,
                    success: function (msg) {

                        enableBackKey();
                        closeOverlayImmediately();
                        if (msg.d == "ERROR") {
                            validation_alert("Action failed at server! Please try again");
                            return;
                        }
                        else if (msg.d == "EX") {

                            if (status == 0) { successalert("The order has been approved by someone else"); }
                            else if (status == 2) { successalert("The order has been rejected by someone else"); }
                            else { successalert("Action completed succesfully!"); }
                            fetch_full_order_details();
                            return;
                        }
                        else if (msg.d == "SUCCESS") {

                            if (status == 0) { successalert("The order has been approved successfully"); }
                            else if (status == 2) { successalert("The order has been rejected succesfully"); }
                            else { successalert("Action completed succesfully!"); }
                            fetch_full_order_details();
                        }
                        else { validation_alert("Unknown error occured at server! Please try again."); }
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
        }
    });

}

// class/credit change functions
function show_Class_Credit_page() {

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    $("#Select_cls_type_for_edit").val('0');
    $("#txt_edit_credit").val('');
    $("#txt_edit_mxperiod").val('');

    overlay("Loading customer details");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Customer_Details",
        data: "{'cust_id':'" + $("#customer_id").val() + "','user_id':'" + $("#appuserid").val() + "'}",
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
                closeOverlay();

                // Active Values // pushing to form 
                var class_val_digit = 0;
                var class_type = obj.data[0].new_custtype != 0 ? obj.data[0].new_custtype : obj.data[0].cust_type;
                class_val_digit = class_type;

                class_type = class_type == 1 ? "A class" : class_type == 2 ? "B Class" : class_type == 3 ? "C Class" : "Unavailable";
                var max_credit = obj.data[0].new_creditamt != 0 ? obj.data[0].new_creditamt : obj.data[0].max_creditamt;
                var max_period = obj.data[0].new_creditperiod != 0 ? obj.data[0].new_creditperiod : obj.data[0].max_creditperiod;

                $("#Select_cls_type_for_edit").val(class_val_digit);
                $("#txt_edit_credit").val(max_credit);
                $("#txt_edit_mxperiod").val(max_period);

                $("#lbl_cls_chng_customer_name").html(obj.data[0].cust_name + ' <br /><a href="#"><small id="" style="color:#635c5c">' + obj.data[0].cust_address + ', ' + obj.data[0].cust_city + '</small></a>');

                //finding old values               
                if (obj.data[0].new_custtype != 0) {

                    var class_val_digit = obj.data[0].cust_type;
                    var old_class_txt = class_val_digit == 1 ? "A class" : class_val_digit == 2 ? "B Class" : class_val_digit == 3 ? "C Class" : "Unavailable";
                    $("#lbl_cls_old").html('OLD CLASS VALUE : ' + old_class_txt);
                }
                else {
                    $("#lbl_cls_old").html('');
                }
                if (obj.data[0].new_creditamt != 0) {
                    $("#lbl_old_credit").html('OLD CREDIT AMOUNT : ' + format_currency_value(obj.data[0].max_creditamt));
                }
                else {
                    $("#lbl_old_credit").html('');
                }
                if (obj.data[0].new_creditperiod != 0) {
                    $("#lbl_old_period").html('OLD CREDIT PERIOD : ' + obj.data[0].max_creditperiod + ' Days');
                }
                else {
                    $("#lbl_old_period").html('');
                }


                showpage('divclasscreditpage');

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

function update_customer_class_credits() {

    if ($("#Select_cls_type_for_edit").val() == 0) { validation_alert("Please select a price class"); return; }
    if ($("#txt_edit_credit").val() == "" || $("#txtMaxCredit").val() == "0") { validation_alert("Please enter the maximum credit amount!"); return; }
    if ($("#txt_edit_mxperiod").val() == "" || $("#txtMaxPeriod").val() == "0") { validation_alert("Please enter the maximum credit period!"); return; }

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to update the class/credit values ?',
        callback: function (result) {
            if (result == false) {

                return;

            } else {

                overlay("Updating Customer class/credit details");
                disableBackKey();
                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/update_customer_class_credits",
                    data: "{'time_zone':'" + $("#ss_default_time_zone").val() + "','user_id':'" + $("#appuserid").val() + "','cust_id':'" + $("#customer_id").val() + "','cust_type':'" + $("#Select_cls_type_for_edit").val() + "','max_creditamt':'" + $("#txt_edit_credit").val() + "','max_creditperiod':'" + $("#txt_edit_mxperiod").val() + "'}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 30000,
                    success: function (msg) {

                        enableBackKey();
                        closeOverlayImmediately();
                        if (msg.d == "ERROR") {
                            validation_alert("Action failed at server! Please try again");
                            return;
                        }

                        else if (msg.d == "SUCCESS") {

                            onBackKeyDown();
                            successalert("The Customer class/credit details has been updated successfully");
                            Get_Customer_Details();
                        }
                        else { validation_alert("Unknown error occured at server! Please try again."); }
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
        }
    });

}

// load customer details for function
function show_customer_edit_page() {

    $("#lbl_customer_action").html('<h5 class="title" id="lbl_customer_action" style="color:#337ab7">UPDATE CUSTOMER DETAILS<br /> <small style="color:#635c5c">Please fill the details</small></h5>');
    clearRegistrationFields();
    $("#btn_customer_update").show();
    $("#btn_customer_reg").hide();
    $("#section_credit_class").hide();
    load_states_locations_to_combo();
    Get_Customer_Details_to_edit();
    showpage('divAddNewCustomer');


}

function Get_Customer_Details_to_edit() {

    overlay("Loading customer details");
    var shtm = "";
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Customer_Details_to_edit",
        data: "{'cust_id':'" + $("#customer_id").val() + "','user_id':'" + $("#appuserid").val() + "'}",
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
                closeOverlay();

                var chtm = "";
                chtm = chtm + '<option value="0">choose category</option>';
                $.each(obj.dt_category, function (i, row) {

                    chtm = chtm + '<option value="' + String(row.cust_cat_id) + '">' + String(row.cust_cat_name) + '</option>';
                });

                $("#SelectCustomerCategory").html(chtm);

                var insert_qry_tbl_location = "INSERT INTO tbl_location VALUES ";
                var tbl_location_values = "";

                $.each(obj.dt_locations, function (i, row) {

                    tbl_location_values = tbl_location_values + " ('" + row.location_id + "','" + row.location_name + "','" + row.state_id + "','" + row.state_name + "','" + row.country_id + "'),";

                });

                tbl_location_values = tbl_location_values.replace(/,\s*$/, "");

                var db = getDB();
                db.transaction(function (tx) {

                    tx.executeSql("delete from tbl_location");
                    var query = insert_qry_tbl_location + tbl_location_values;
                    if (tbl_location_values != "") {
                        tx.executeSql(query, [], function (tx, res) {



                        });
                    }

                    var selectTrans = "select state_id,state_name from tbl_location group by state_id";
                    tx.executeSql(selectTrans, [], function (tx, res) {
                        var shtm = "";
                        var len = res.rows.length;
                        if (len > 0) {

                            shtm = shtm + '<option value="0">Select State</option>';

                            for (var i = 0; i < len; i++) {

                                shtm = shtm + '<option value="' + String(res.rows.item(i).state_id) + '">' + String(res.rows.item(i).state_name) + '</option>';
                            }

                            $("#SelectStateforRegistration").html(shtm);
                            $("#SelectStateforRegistration").val(obj.data[0].cust_state);

                            var selectloc = "select location_id,location_name from tbl_location where state_id='" + $("#SelectStateforRegistration").val() + "'";
                            tx.executeSql(selectloc, [], function (tx, res) {
                                var lhtm = "";
                                var len = res.rows.length;
                                if (len > 0) {
                                    lhtm = lhtm + '<option value="0">Select Location</option>';
                                    for (var i = 0; i < len; i++) {
                                        lhtm = lhtm + '<option value="' + String(res.rows.item(i).location_id) + '">' + String(res.rows.item(i).location_name) + '</option>';
                                    }
                                    $("#SelectLocationforRegistration").html(lhtm);
                                    $("#SelectLocationforRegistration").val(obj.data[0].location_id);
                                }
                                else {

                                    $("#SelectLocationforRegistration").html('<option value="0">Select Location</option>');

                                }

                            });


                        }
                        else {

                        }

                    });



                },
                function (e) {

                    alert(e.message);
                }
                );

                $("#txtStoreName").val(obj.data[0].cust_name);
                $("#textgst_trn_number").val(obj.data[0].cust_tax_reg_id);
                $("#textCustomerRegId").val(obj.data[0].cust_reg_id);
                $("#SelectCustomerCategory").val(obj.data[0].cust_cat_id);
                $("#txtstreetname").val(obj.data[0].cust_address);
                $("#txtPlace").val(obj.data[0].cust_city);
                $("#txtPhoneNumber").val(obj.data[0].cust_phone);
                $("#txtPhoneNumber2").val(obj.data[0].cust_phone1);


                $("#txtEmail").val(obj.data[0].cust_email);
                $("#txtCustomerNote").val(obj.data[0].cust_note);

                if (parseFloat(obj.data[0].cust_latitude) == 0) {
                    $("#newcustomerlocation").val('Not Found');
                    Latitude = 0;
                    Longitude = 0;
                }
                else {
                    Latitude = obj.data[0].cust_latitude;
                    Longitude = obj.data[0].cust_longitude;
                    $("#newcustomerlocation").val(Latitude + ',' + Longitude);
                }

                load_image_From_Server_for_customer_data(obj.data[0].cust_image);

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

function go_to_customer_page_from_order() {

    var cust_id = $("#customer_id").val();
    show_Customer_Details(cust_id);
}

// update customer details
function update_customer_details() {

    var postObj = {

        data: {

            cust_id: $("#customer_id").val(),
            cust_name: $("#txtStoreName").val(),
            cust_address: $("#txtstreetname").val(),
            cust_city: $("#txtPlace").val(),
            cust_state: $("#SelectStateforRegistration").val(),
            cust_phone: $("#txtPhoneNumber").val(),
            cust_phone1: $("#txtPhoneNumber2").val(),
            cust_email: $("#txtEmail").val(),
            cust_latitude: Latitude,
            cust_longitude: Longitude,
            cust_image: imageURIN,
            cust_note: $("#txtCustomerNote").val(),
            cust_sessionid: current_session_id,
            cust_reg_id: $.trim($("#textCustomerRegId").val()),
            location_id: $("#SelectLocationforRegistration").val(),
            cust_cat_id: $("#SelectCustomerCategory").val(),
            cust_tax_reg_id: $("#textgst_trn_number").val(),
            timezone: $("#ss_default_time_zone").val(),
            img_updated: imageYes,

        }
    };

    overlay("Updating Customer details ");
    disableBackKey();

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/update_customer_details",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (resp) {

            closeOverlayImmediately();
            enableBackKey();

            var obj = JSON.parse(resp.d);

            if (resp.d == "") {

                validation_alert("Customer details updation Failed! Please try again");
            }
            else if (resp.d == "FAILED") {

                validation_alert("Customer details updation Failed! Please try again");
            }
            else if (obj.result == "REGID") {

                validation_alert("Registration ID exist with another customer! Please provide a different ID");
            }
            else if (obj.result == "SUCCESS") {

                onBackKeyDown();
                successalert("Customer Details Updated Successfully!");
                Get_Customer_Details();
                clearRegistrationFields();
            }


        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function show_pending_items() {

    showpage('div_pending_headers');
    Get_Pending_Counts_with_users();

}

function Get_Pending_Counts_with_users() {

    var htm = "";
    var type = "";
    overlay("Loading users with pending approvals..");

    disableBackKey();
    $("#div_list_pending_headers").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Pending_Counts_with_users",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();

            if (msg.d == "") {
                bootbox.alert('<p style="color:red">No Customers Found</p>');
                return;
            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else if (msg.d == "N") {


                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No' + type + ' Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_pending_headers").html(htm);

                return;

            }
            else {

                var obj = JSON.parse(msg.d);

                $.each(obj.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f9f9f9"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid gray" onclick="javascript:show_userwise_pending_items(\'' + row.user_id + '\',\'' + row.name + '\');">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7"><i class="ti-user"></i> <b>' + row.name + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                    htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                    htm = htm + '<tr><td style="color:#c23706"> New Registrations : <b>' + row.new_registrations + ' </b></td><td style="color:#337ab7">Class/Credit Changes : <b>' + row.new_classchanges + '</b></td></tr>';
                    htm = htm + '<tr><td style="color:#e88454">Pending Orders : <b>' + row.pending_orders + '</b></td><td style="color:green">Pending Returns : <b>' + row.pending_returns + '</b></td></tr>';
                    htm = htm + '</tbody></table>';
                    htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });
                $("#div_list_pending_headers").html(htm);


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

function show_userwise_pending_items(user_id, username) {

    showpage('divPendingItems');
    $("#Select_pending_item").val('0');
    $("#selected_user_id").val(user_id);
    $("#selected_user_name").html(username);
    get_pending_approvals();
    selected_user_id
}

// LOAD PENDING ITEMS
function get_pending_approvals() {

    var htm = "";
    var postObj = {
        filters: {
            user_id: $("#appuserid").val(),
            approval_type: $("#Select_pending_item").val(),
            seller_id: $("#selected_user_id").val(),
        }
    };
    var type = "";
    if ($("#Select_pending_item").val() == '0') { overlay("Loading pending approvals.."); type = " Pending Items"; }
    else if ($("#Select_pending_item").val() == '1') { overlay("Loading pending orders.."); type = " Orders"; }
    else if ($("#Select_pending_item").val() == '2') { overlay("Loading pending registrations.."); type = " Registrations"; }
    else if ($("#Select_pending_item").val() == '3') { overlay("Loading pending class/credit change approvals.."); type = " Class/Credit Changes"; }
    else if ($("#Select_pending_item").val() == '4') { overlay("Loading pending Item Return approvals.."); type = " Item Return approvals"; }
    else { }

    disableBackKey();
    $("#div_list_approvals").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_pending_approvals",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();

            if (msg.d == "") {
                bootbox.alert('<p style="color:red">No Customers Found</p>');
                return;
            }
            else if (msg.d == "N") {


                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No' + type + ' Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_approvals").html(htm);

                return;

            }
            else {

                var obj = JSON.parse(msg.d);

                if ($("#Select_pending_item").val() == '1') {

                    $.each(obj.data, function (i, row) {

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
                }
                else if ($("#Select_pending_item").val() == '2') {

                    $.each(obj.data, function (i, row) {

                        var color = 0;
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + row.cust_id + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + row.cust_name + '<br />';
                        htm = htm + '<span class="text-info"><small>' + row.cust_address + ',' + row.cust_city + '</small></span><br />';
                        htm = htm + '<span class="text-info"><small>Registered On : ' + row.cust_joined_date + '</small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                    });

                }
                else if ($("#Select_pending_item").val() == '3') {

                    $.each(obj.data, function (i, row) {

                        var color = 0;
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }

                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + row.cust_id + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + row.cust_name + '<br />';
                        htm = htm + '<span class="text-info"><small>' + row.cust_address + ',' + row.cust_city + '</small></span><br />';

                        if (parseInt(row.new_custtype) != 0) {

                            var old_class = row.cust_type == 1 ? "A class" : row.cust_type == 2 ? "B Class" : row.cust_type == 3 ? "C Class" : "Unavailable";
                            var new_class = row.new_custtype == 1 ? "A class" : row.new_custtype == 2 ? "B Class" : row.new_custtype == 3 ? "C Class" : "Unavailable";

                            htm = htm + '<span class="text-danger"><small># Price Class changed from ' + old_class + ' to ' + new_class + '</small></span><br />';
                        }
                        if (parseFloat(row.new_creditamt) != 0) {

                            htm = htm + '<span class="text-danger"><small># Max credit changed from ' + format_currency_value(row.max_creditamt) + ' to ' + format_currency_value(row.new_creditamt) + '</small></span><br />';
                        }
                        if (parseInt(row.new_creditperiod) != 0) {

                            htm = htm + '<span class="text-danger"><small># Max Period changed from ' + row.max_creditperiod + ' to ' + row.new_creditperiod + '</small></span><br />';
                        }

                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                    });
                }
                else if ($("#Select_pending_item").val() == '4') {

                    $.each(obj.data, function (i, row) {

                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:load_return_item_to_popup_to_approve(\'' + row.sri_id + '\',\'' + row.sri_type + '\',\'' + row.sri_recieved_id + '\',\'' + row.sri_approved_id + '\',\'' + row.itbs_id + '\',\'' + row.itm_name + '\',\'' + row.itm_code + '\',\'' + row.sm_invoice_no + '\',\'' + row.sm_id + '\',\'' + row.sri_total + '\',\'' + row.sri_qty + '\',\'' + row.name + '\')">';
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
                }
                else {

                    var ord_count = 0;
                    htm = htm + '<div id="vl_sh_order" class="row"><div class="panel panel-primary"><div class="panel-heading" style="text-align:center;">ORDERS TO BE REVIEWED</div></div></div>';
                    $.each(obj.pend_order, function (i, row) {

                       
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
                        ord_count = ord_count + 1;

                    });

                    

                    var reg_count = 0;
                    htm = htm + '<div id="vl_sh_reg" class="row"><div class="panel panel-primary"><div class="panel-heading" style="text-align:center;">NEW CUSTOMER REGISTRATIONS</div></div></div>';
                    $.each(obj.pend_reg, function (i, row) {

                        var color = 0;
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + row.cust_id + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + row.cust_name + '<br />';
                        htm = htm + '<span class="text-info"><small>' + row.cust_address + ',' + row.cust_city + '</small></span><br />';
                        htm = htm + '<span class="text-info"><small>Registered On : ' + row.cust_joined_date + '</small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                        reg_count = reg_count + 1;

                    });

                    

                    var cls_count = 0;
                    htm = htm + '<div id="vl_sh_cls" class="row"><div class="panel panel-primary"><div class="panel-heading" style="text-align:center;">CLASS / CREDIT CHANGES</div></div></div>';
                    $.each(obj.dt_cls_crd, function (i, row) {

                        var color = 0;
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + row.cust_id + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + row.cust_name + '<br />';
                        htm = htm + '<span class="text-info"><small>' + row.cust_address + ',' + row.cust_city + '</small></span><br />';

                        if (parseInt(row.new_custtype) != 0) {

                            var old_class = row.cust_type == 1 ? "A class" : row.cust_type == 2 ? "B Class" : row.cust_type == 3 ? "C Class" : "Unavailable";
                            var new_class = row.new_custtype == 1 ? "A class" : row.new_custtype == 2 ? "B Class" : row.new_custtype == 3 ? "C Class" : "Unavailable";

                            htm = htm + '<span class="text-danger"><small># Price Class changed from ' + old_class + ' to ' + new_class + '</small></span><br />';
                        }
                        if (parseFloat(row.new_creditamt) != 0) {

                            htm = htm + '<span class="text-danger"><small># Max credit changed from ' + format_currency_value(row.max_creditamt) + ' to ' + format_currency_value(row.new_creditamt) + '</small></span><br />';
                        }
                        if (parseInt(row.new_creditperiod) != 0) {

                            htm = htm + '<span class="text-danger"><small># Max Period changed from ' + row.max_creditperiod + ' to ' + row.new_creditperiod + '</small></span><br />';
                        }

                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                        cls_count = cls_count + 1;

                    });

                    

                    var ret_count = 0;
                    htm = htm + '<div id="vl_sh_ret" class="row"><div class="panel panel-primary"><div class="panel-heading" style="text-align:center;">ITEM RETURNS TO APPROVE</div></div></div>';
                    $.each(obj.dt_return, function (i, row) {

                        
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:load_return_item_to_popup_to_approve(\'' + row.sri_id + '\',\'' + row.sri_type + '\',\'' + row.sri_recieved_id + '\',\'' + row.sri_approved_id + '\',\'' + row.itbs_id + '\',\'' + row.itm_name + '\',\'' + row.itm_code + '\',\'' + row.sm_invoice_no + '\',\'' + row.sm_id + '\',\'' + row.sri_total + '\',\'' + row.sri_qty + '\',\'' + row.name + '\')">';
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

                        ret_count = ret_count + 1;

                    });

                    
                }

                $("#div_list_approvals").html(htm);
                if (ret_count == 0) { $("#vl_sh_ret").hide(); }
                if (cls_count == 0) { $("#vl_sh_cls").hide(); }
                if (reg_count == 0) { $("#vl_sh_reg").hide(); }
                if (ord_count == 0) { $("#vl_sh_order").hide(); }
                if (ret_count == 0 && cls_count == 0 && reg_count == 0 && ord_count == 0) { $("#div_list_approvals").html('<h5 style="text-align:center">No Items exist for approval!</h5>'); }
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

function load_return_item_to_popup_to_approve(sri_id, sri_type, sri_recieved_id, sri_approved_id, itbs_id, itm_name, itm_code, sm_invoice_no, sm_id, sri_total, sri_qty, name) {

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
    else { validation_alert("The Item's return has been already approved by admin!"); return; }

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

// CHECKING FOR CUSTOMR LOCATION
function view_cust_location_in_google_map() {

    var g_lat = parseFloat($("#gg_map_lat").val());
    var g_lon = parseFloat($("#gg_map_lon").val());
    if (g_lat == 0) { validation_alert("Customer location is unavailable!"); return; }
    else { window.open('https://maps.google.com/?q=' + g_lat + ',' + g_lon + ''); }

}

//SETTING GLOBAL LOCATION VARIABLES AS 0
function clr_location_data() {

    Latitude = 0; Longitude = 0;
}

// DISPLAYING ORDERS FROM BOTH SERVER AND LOCAL BASED ON TYPE
function showMyOrders(type) {

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
    $('#div_online_order_part').show(); get_Orders(1);

}

// type - 1 - all orders , 2 - customer orders
function get_Orders(page) {

    var orders_from = $('#txt_date_orders_from').val();
    var orders_to = $('#txt_date_orders_to').val();

    if ($("#order_load_type").val() == 1) {
        overlay("Loading Orders ");
        $("#customer_id").val("0")
    }
    else if ($("#order_load_type").val() == 2) {
        overlay("Loading Customer Orders ");
    }

    disableBackKey();

    var postObj = {

        filters: {

            type: $("#order_load_type").val(),
            customer_id: $("#customer_id").val(),
            orders_from: dateformat(orders_from),
            orders_to: dateformat(orders_to),
            order_status: $("#Select_Order_Status").val(),
            payment_status: $("#Select_Payment_Status").val(),
            page: page,
            user_id: $("#appuserid").val(),
            seller_id: $("#Select_seller_for_Orders").val(),
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
            if (resp.d == "") {

                validation_alert("Unable to load data! Please try again");
            }
            else if (resp.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);


                var current_user_value = $("#Select_seller_for_Orders").val();
                var dhtm = '<option value="0">All Users</option>';

                $.each(response.user_list, function (i, row) {

                    dhtm = dhtm + '<option value="' + row.user_id + '">' + row.name + '</option>';
                });
                $("#Select_seller_for_Orders").html(dhtm);
                if (current_user_value != "0") { $("#Select_seller_for_Orders").val(current_user_value); }

                //console.log(JSON.parse(resp.d));
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

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    if ($("#Select_Access_Branch").val() == "0") { validation_alert('Please select a warehouse to continue!'); return; }
    Get_item_list();
}

function Get_item_list() {

    overlay("fetching items for order.");

    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_item_list",
        data: "{'branch_id':'" + $("#Select_Access_Branch").val() + "'}",
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
                closeOverlay();

                var insert_qry_tbl_itembranch_stock = "INSERT INTO tbl_itembranch_stock (itm_type,brand_name,cat_name,branch_id,tp_tax_percentage,tp_cess,itbs_id,itm_id,itm_brand_id,itm_category_id,itm_name,itbs_stock,itm_code,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_rating) VALUES ";
                // ITEM BRANCH STOCK DATA - 
                var itembranch_stock = "";
                //******************************************************************************************************
                $.each(obj.dt_item_branchstock, function (i, row) {

                    itembranch_stock = itembranch_stock + " ('" + row.itm_type + "','" + row.brand_name + "','" + row.cat_name + "','" + row.branch_id + "','" + row.tp_tax_percentage + "','" + row.tp_cess + "','" + row.itbs_id + "','" + row.itm_id + "','" + row.itm_brand_id + "','" + row.itm_category_id + "','" + row.itm_name + "','" + row.itbs_stock + "','" + row.itm_code + "','" + row.itm_mrp + "','" + row.itm_class_one + "','" + row.itm_class_two + "','" + row.itm_class_three + "','" + row.itm_commision + "','" + row.itm_rating + "'),";

                });

                itembranch_stock = itembranch_stock.replace(/,\s*$/, "");

                var db = getDB();
                db.transaction(function (tx) {

                    tx.executeSql("delete from tbl_itembranch_stock");
                    var query = insert_qry_tbl_itembranch_stock + itembranch_stock;
                    if (itembranch_stock != "") {
                        tx.executeSql(query, [], function (tx, res) {


                            getSessionID();
                            if ($("#ss_new_item").val() == "1") { $("#newitemheader").show(); } else { $("#newitemheader").hide(); }
                            showpage('divProducts');
                            $("#Selectitmtypes").val(1);
                            $("#txtsearchProducts").val("");
                            clear_Cart_Items();
                            load_brands_categories_to_combo();
                            list_items_for_sale(1);

                        });
                    }

                },
                function (e) {

                    alert(e.message);
                }
                );

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

            var selectItems = "select itm_name,itbs_id,itm_code," + $("#cust_class_for_order").val() + " as itm_price,itm_type from tbl_itembranch_stock " +
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
                        htm = htm + '<img src="assets/img/' + image + '.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
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

function add_item_to_cart(itbs_id, itm_code, itm_name, itm_type, itbs_stock, brand_name) {


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

        var check_item_existance_qry = "SELECT itbs_id,itm_name FROM tbl_item_cart WHERE itbs_id='" + itbs_id + "'";
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

        var update_tbl_cart = "UPDATE tbl_item_cart SET si_price='" + $("#txt_item_price").val() + "',si_qty='" + $("#txt_item_quantity").val() + "',si_total='" + $("#itm_calc_real_total").val() + "',si_discount_rate='" + $("#txt_item_discount").val() + "',si_discount_amount='" + $("#itm_calc_dics_amount").val() + "',si_net_amount='" + $("#itm_calc_net_total").val() + "',si_foc='" + $("#txt_item_foc").val() + "',si_approval_status='" + si_approval_status + "',itm_commisionamt='" + $("#itm_calc_commision_amount").val() + "',si_tax_excluded_total='" + si_tax_excluded_total + "',si_tax_amount='" + $("#itm_calc_tax_amount").val() + "' WHERE itbs_id='" + itbs_id + "'";

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


function show_assigned_delivery_page() {

    showpage('divAssignedDelivery');
    get_Orders_for_delivery(1);
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

function showCustFollowUps() {

    var cday = currentdate();
    //$('#SelectfollowupLocations').val(0);
    var yyyy = new Date().getFullYear();
    $('#TextCustFollowUpFrom').scroller({
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

    $('#TextCustFollowUpTo').scroller({
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


    showpage('divFollowUps');

    $('#TextCustFollowUpFrom').val(cday);
    $('#TextCustFollowUpTo').val(cday);
    getCustFollowUps();
}

function getCustFollowUps() {

    var htm = "";
    var postObj = {
        filters: {
            user_id: $("#appuserid").val(),
            location_id: $("#SelectfollowupLocations").val(),
            dateFrom: dateformat($("#TextCustFollowUpFrom").val()),
            dateTo: dateformat($("#TextCustFollowUpTo").val()),
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };

    overlay("Loading Scheduled Customer Visits");
    disableBackKey();
    $("#divCustFollowList").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getCustFollowUps",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();

            if (msg.d == "") {
                bootbox.alert('<p style="color:red">No Customers Found</p>');
                return;
            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else if (msg.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Customers Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#divCustFollowList").html(htm);

                return;

            }
            else {

                var obj = JSON.parse(msg.d);

                $.each(obj.data, function (i, row) {


                    htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + String(row.cust_id) + ');">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + String(row.cust_name) + '<br />';
                    htm = htm + '<span style="color:gray"><small>' + String(row.cust_address) + ',' + String(row.cust_city) + '</small></span><br />';
                    htm = htm + '<span class="text-danger"><small>Follow up on : </small></span><span style="color:gray"><small>' + formatDate(row.cust_followup_date) + '</small></span><br />';
                    //htm = htm + '<span class="text-danger"><small>Salesman : </small></span><span style="color:gray"><small>' + row.first_name + ' ' + row.last_name + '</small></span>';
                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-eye"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';



                });

                $("#divCustFollowList").html(htm);


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

function showDues() {
    showpage('divDueView');
    getDueCustomers();
}

function getDueCustomers() {

    $("#divListofDueCustomers").html("");

    var htm = "";
    var shtm = "";
    var bhtm = "";
    var postObj = {
        filters: {
            user_id: $("#appuserid").val(),
            seller_id: $("#select_due_seller").val(),
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };

    overlay("loading customers with due.");
    disableBackKey();
    $("#divCustFollowList").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getDuePayments",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();

            if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
                return;
            }

            var obj = JSON.parse(msg.d);

            var current_user_value = $("#select_due_seller").val();
            var dhtm = '<option value="0">ALL USERS</option>';

            $.each(obj.user, function (i, row) {

                dhtm = dhtm + '<option value="' + row.user_id + '">' + row.name + '</option>';
            });
            $("#select_due_seller").html(dhtm);
            if (current_user_value != "0") { $("#select_due_seller").val(current_user_value); }

            if (msg.d == "") {

                bootbox.alert('<p style="color:red">No Customers Found</p>');
                return;

            }            
            else if (obj.drowsCount == "0") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/happy.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Dues found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#divListofDueCustomers").html(htm);

                var dhtm = "";
                dhtm = '<div id="div16" class="panel panel-success"><div class="panel-heading">';
                dhtm = dhtm + 'No Customers <div class="pull-right">Total Due : <span class="" id="Span2">0.00 AED</span></div></div></div>';
                $("#dueheader").html(dhtm);
                return;

            }
            else {

                var total_customers = 0;
                var total_oustanding = 0;
                var obj = JSON.parse(msg.d);

                $.each(obj.data, function (i, row) {

                    if (row.cust_name != null) {

                        htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:loadCustomerDueDetails(' + row.cust_id + ');">';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + row.cust_name + '<br />';
                        htm = htm + '<span class="text-success"><small>' + row.cust_address + ',' + row.cust_city + '</small></span><br />';
                        htm = htm + '<span class="text-danger"><small>Due Amount : ' + format_currency_value(row.total_balance) + '</small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-eye"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                        total_customers = i + 1;
                        total_oustanding = parseFloat(total_oustanding) + parseFloat(row.total_balance);
                    }
                    else {

                        htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                        htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                        htm = htm + '<div class="avatar">';
                        htm = htm + '<img src="assets/img/happy.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                        htm = htm + '</div> </div>';
                        htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br />No Dues found !';
                        htm = htm + '<span class="text-success"><small></small></span>';
                        htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';
                    }


                });

                $("#divListofDueCustomers").html(htm);
                total_oustanding = format_currency_value(total_oustanding);
                var dhtm = "";
                dhtm = '<div id="div16" class="panel panel-danger"><div class="panel-heading">';
                dhtm = dhtm + '' + total_customers + ' Customers <div class="pull-right">Total Due : <span class="" id="Span2">' + total_oustanding + ' </span></div></div></div>';
                $("#dueheader").html(dhtm);

            }


        },
        error: function (xhr, status) {

            closeOverlay();
            enableBackKey();
            ajaxerroralert();
            onBackMove();
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
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid ' + bordercolor + '" onclick="javascript:load_item_details_to_edit(' + String(res.rows.item(i).itbs_id) + ');">';
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

    //$("#lbl_ord_cust_name").html(res.rows.item(0).cust_name + ' </br> <small> ' + res.rows.item(0).cust_address+','+res.rows.item(0).cust_city +' </small>');
    $("#lbl_ord_cust_name").html('');

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

        htm = htm + '<option value="0" selected>New Order</option>';
        htm = htm + '<option value="2">Delivered</option>';

        $("#Select_order_status").html(htm)
        $("#SelectOrderPayMethod").prop('disabled', false);
        $("#txt_current_payment_with_order").prop('disabled', false);
        //if ($("#ss_direct_delivery").val() == "0") { $("#Select_order_status").val('0') } else { $("#Select_order_status").val('2') }
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

                                sync_data_to_server();
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


                                                //successalert('ORDER SAVED SUCCESSFULLY');
                                                //$("#div_finalize_order").hide();
                                                //$("#hdnCurrentDiv").val('homepage');
                                                //show_Customer_Details($("#customer_id").val());
                                                sync_data_to_server();


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

// credit note

function swapCrediPaymentMethods() {

    var pay_type = $("#SelectCreditNotePayment").val();
    $('#cr_not_cheque_date').val("");
    if (pay_type == 0) {

        $("#creditNoteChequeDiv").hide();
    }
    else {
        $(function () {

            var yyyy = new Date().getFullYear();

            $('#cr_not_cheque_date').scroller({
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
        });
        $("#creditNoteChequeDiv").show();
    }
}

function show_credit_note_page() {

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    if ($("#Select_Access_Branch").val() == "0") { validation_alert('Please select a warehouse to continue!'); return; }
    $("#SelectCreditNotePayment").val('0');
    $("#txt_credit_amt").val('');
    $("#cr_note_chq_no").val('');
    $("#cr_not_cheque_date").val('');
    $("#cr_note_bank").val('');
    $("#txtspecial_credit_note").val('');
    swapCrediPaymentMethods();
    getSessionID();
    showpage('div_Credit_Note');
}

function show_view_credit_notes() {

    $("#div_list_credit_notes").html('');
    showpage('div_view_credit_notes');
    get_credit_note_history(1);
}

function get_credit_note_history(page) {

    var htm = "";
    var postObj = {
        filters: {
            cust_id: $("#customer_id").val(),
            user_id: $("#appuserid").val(),
            page: page,
        }
    };

    overlay("Loading Customer's Credit Notes");
    disableBackKey();
    $("#div_list_credit_notes").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_credit_note_history",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (response) {
            closeOverlay();
            enableBackKey();

            if (response.d == "") {
                bootbox.alert('<p style="color:red">No Credit Notes Found</p>');
                return;
            }
            else if (response.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Credit Notes Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_credit_notes").html(htm);

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

                    //var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 7 ? "DEBIT NOTE" : row.action_type == 6 ? "CREDIT NOTE" : "" + '';
                    //htm = htm + '<br /><span style="color:#337ab7"><small>Action Type : <b>' + action + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action By : <b>' + row.name + '</b></small></span></div>';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '"><b style="color:337ab7">Details</b> : ' + String(row.narration) + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(obj.totalRows);
                var perPage = parseInt(obj.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr_c" onclick="javascript:get_credit_note_history(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr_c" onclick="javascript:get_credit_note_history(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Credit Notes Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_credit_notes").html(htm);

                if (page > 1) {
                    $("#btnPrev_lod_tr_c").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_tr_c").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_tr_c").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_tr_c").hide();
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

function save_credit_note() {

    fixquotes();
    var dialogregistration = "";
    var cash_amount = "";
    var chequeamount = "";
    var cheque_bank = "";
    var cheque_number = "";
    var cheque_date = "";
    var payment = 0;

    if ($("#txt_credit_amt").val() == "") { validation_alert("Enter the Amount to be credited"); $("#txt_credit_amt").focus(); return false; }
    if (isNaN($("#txt_credit_amt").val())) { validation_alert("Return amount should be a valid number!"); return false; }

    if ($("#SelectCreditNotePayment").val() == "1") {
        if ($("#cr_note_chq_no").val() == "") { validation_alert("Enter the Cheque number"); $("#cr_note_chq_no").focus(); return false; }
        if ($("#cr_not_cheque_date").val() == "") { validation_alert("Enter the Cheque Date"); $("#cr_not_cheque_date").focus(); return false; }
        if ($("#cr_note_bank").val() == "") { validation_alert("Enter the Bank Name"); $("#cr_note_bank").focus(); return false; }
    }

    if ($("#txtspecial_credit_note").val() == "") { validation_alert("Enter Remarks"); $("#txtspecial_credit_note").focus(); return false; }

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {
                return;

            } else {


                dialogregistration = bootbox.dialog({
                    message: '<div align=center id="simage" style="margin-top:0px;margin-bottom:0px"><p class="text-center" style="color:#337ab7;margin-top:0px;margin-bottom:0px"><i class="ti-exchange-vertical blink-image"></i><i class="ti-mobile blink-image"></i>  Processing credit entry </p></div>',
                    closeButton: false
                });

                if ($("#SelectCreditNotePayment").val() == "0") {

                    cash_amount = format_decimal_accuray(parseFloat($("#txt_credit_amt").val()));
                    chequeamount = 0;
                    cheque_bank = 0;
                    cheque_number = 0;
                    cheque_date = 0;
                }
                else if ($("#SelectCreditNotePayment").val() == "1") {

                    cash_amount = 0;
                    chequeamount = format_decimal_accuray(parseFloat($("#txt_credit_amt").val()));
                    cheque_bank = $("#cr_note_bank").val();
                    cheque_number = $("#cr_note_chq_no").val();
                    cheque_date = dateformat($("#cr_not_cheque_date").val());

                }
                else {


                }
                payment = cash_amount + chequeamount;
                var narration = "" + $("#txt_credit_amt").val() + " credited to customer balance: Note:" + $("#txtspecial_credit_note").val();

                var postObj = {

                    data: {

                        cust_id: $("#customer_id").val(),
                        user_id: $("#appuserid").val(),
                        branch_id: $("#Select_Access_Branch").val(),
                        cash_amt: cash_amount,
                        cheque_amt: chequeamount,
                        cheque_no: cheque_number,
                        cheque_date: cheque_date,
                        cheque_bank: cheque_bank,
                        narration: $("#txtspecial_credit_note").val(),
                        time_zone: $("#br_time_zone").val(),
                        payment: payment,
                        session_id: current_session_id,
                    }
                };

                disableBackKey();


                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/save_credit_note",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 20000,
                    success: function (response) {

                        dialogregistration.find(dialogregistration.modal('hide'));
                        enableBackKey();

                        if (response.d == "") {

                            validation_alert("An error occured! Please try again");
                        }
                        else if (response.d == "FAILED") {

                            validation_alert("An error occured! Please try again");
                        }
                        else if (response.d == "SUCCESS" || response.d == "EXIST") {

                            var logfailed = bootbox.dialog({
                                message: '<p class="text-center" style="color:green"><i class="ti-info"></i> Amount successfully credited to customer</p>',
                                closeButton: false
                            });

                            setTimeout(function () {
                                logfailed.find(logfailed.modal('hide'));
                                onBackKeyDown();
                                Get_Customer_Details();
                            }, 1500);
                        }
                        else { validation_alert("An error occured! Please try again"); }


                    },
                    error: function (xhr, status) {

                        closeOverlay();
                        enableBackKey();
                        ajaxerroralert();

                    }
                });






            }
        }
    });

}

function show_old_outstanding_page() {

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    if ($("#Select_Access_Branch").val() == "0") { validation_alert('Please select a warehouse to continue!'); return; }
    if ($("#is_new_registration").val() == "1") { validation_alert('The customer is not in the database. Please sync & try again!'); return; }
    $("#textOrderDate").val("");
    $("#txtinvoiceno").val("");
    $("#textNetamt").val("");
    $("#txtBalanceamt").val("");
    $('#txtspecialnote').val("");

    var yyyy = new Date().getFullYear();
    var dd = new Date().getDate();
    var mm = new Date().getMonth() + 1;

    $('#textOrderDate').scroller({
        preset: 'date',
        maxDate: new Date(yyyy + ',' + mm + ',' + dd),
        setText: 'Select',
        invalid: {},
        theme: 'android-ics',
        display: 'modal',
        mode: 'scroller',
        //dateFormat :'yy/mm/dd'
        dateFormat: 'dd-mm-yy'
    });

    getSessionID();
    showpage('divOutstanding');
}

function save_old_oustanding_order_offline() {

    fixquotes();
    if ($("#textOrderDate").val() == "") { validation_alert("Please enter the invoice date!"); return; }
    if ($.trim($("#txtinvoiceno").val()) == "" || $.trim($("#txtinvoiceno").val()) == null) { validation_alert("Please enter the Invoice Number / Order ID of old order for reference"); return; }
    if ($("#textNetamt").val() == "") { validation_alert("Please enter the bill amount"); return; }
    if ($("#txtBalanceamt").val() == "") { validation_alert("Please enter the balance amount"); return; }

    var bill_amount = parseFloat($("#textNetamt").val());
    var bal_amount = parseFloat($("#txtBalanceamt").val());
    if (bill_amount < bal_amount) { validation_alert("Balance amount cannot be greater than net amount!"); return; }

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {
                return;

            } else {
                overlay("Processing old Order entry..");
                disableBackKey();

                var postObj = {

                    sl_mstr: {

                        cust_id: $("#customer_id").val(),
                        branch: $("#Select_Access_Branch").val(),
                        invoice_id: $.trim($("#txtinvoiceno").val()),
                        user_id: $("#appuserid").val(),
                        time_zone: $("#ss_default_time_zone").val(),
                        session_id: current_session_id,
                        sm_netamount: $("#textNetamt").val(),
                        total_balance: $("#txtBalanceamt").val(),
                        sm_date: dateformat($("#textOrderDate").val()),
                        sm_specialnote: $("#txtspecialnote").val(),
                    }
                };

                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/Save_Old_outstanding_entry",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 20000,
                    success: function (resp) {

                        enableBackKey();
                        closeOverlayImmediately();
                        var obj = JSON.parse(resp.d);

                        if (obj.result == "SUCCESS" || obj.result == "EXIST") {

                            successalert("Old order saved Sccessfully!");
                            onBackKeyDown();
                            Get_Customer_Details();

                        }
                        else if (obj.result == "REPEAT") { validation_alert("This invoice already exists in the database!"); }
                        else { validation_alert("An error occured in the server! Please try again."); }


                    },
                    error: function (e) {

                        closeOverlayImmediately();
                        enableBackKey();
                        ajaxerroralert();

                    }
                });
            }
        }
    });


}

// overview

function showOverview() {

    $(function () {

        var yyyy = new Date().getFullYear();

        $('#txtOverviewFrom').scroller({
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

        $('#txtOverviewTo').scroller({
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
    });

    $("#divOverviewSales").html("");
    var cday = currentdate();
    $("#txtOverviewFrom").val(cday);
    $("#txtOverviewTo").val(cday);
    showpage('divTotalOverview');
    overlay("loading users & warehouses");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            } else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#SelectSalesOverviewBranch").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#SelectSalesOverviewUser").html(uhtm);

                getOverview();
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });

}

function reset_Sl_overview_Filter() {

    var cday = currentdate();
    $('#txtOverviewFrom').val(cday);
    $('#txtOverviewTo').val(cday);
    $('#SelectSalesOverviewBranch').val(0);
    $('#SelectSalesOverviewUser').val(0);
    getOverview();
}

function getOverview() {
    var postObj = {
        filters: {}
    };
    postObj.filters.admin_id = $("#appuserid").val();
    postObj.filters.user_id = $("#SelectSalesOverviewUser").val();
    postObj.filters.branch = $("#SelectSalesOverviewBranch").val();
    if ($.trim($("#txtOverviewFrom").val()) != "") {
        postObj.filters.dateFrom = $("#txtOverviewFrom").val();
    }
    if ($.trim($("#txtOverviewTo").val()) != "") {
        postObj.filters.dateTo = $("#txtOverviewTo").val();
    }
    if ($.trim($("#txtOverviewFrom").val()) == $.trim($("#txtOverviewTo").val())) {
        $("#lblDateBetween").text($("#txtOverviewFrom").val());
    }
    else {
        $("#lblDateBetween").text($("#txtOverviewFrom").val() + ' to ' + $("#txtOverviewTo").val());
    }

    overlay("Loading sales overview");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getOverView",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();

            var msgObj = JSON.parse(msg.d);
            $("#divOverviewSales").html("");
            $.each(msgObj.overview, function (i, sellerObj) {
                //console.log(sellerObj);
                var htm = '<div class="panel panel-success">';
                htm += '<div class="panel-heading">';
                htm += sellerObj.seller_name;
                //htm += '<i class="ti-location-pin" style="float: right;" onclick="javascript:showCustomersOnMap(' + sellerObj.seller_id + ');"></i>';
                htm += '</div>';
                htm += '<div class="panel-body">';
                htm += '<table class="table">';
                htm += '<tbody>';
                htm += '<tr class="info" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'AllOrders\',\'' + sellerObj.seller_name + '\');">';
                htm += '<td>Orders(' + sellerObj.order_count + ')</td>';
                htm += '<td>' + sellerObj.total_sale.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '<tr class="warning" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'AllReciepts\',\'' + sellerObj.seller_name + '\');">';
                htm += '<td>Total receipt</td>';
                htm += '<td>' + sellerObj.total_receipt.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '<tr class="danger" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'AllOutstandings\',\'' + sellerObj.seller_name + '\');">';
                htm += '<td>Total outstanding(' + sellerObj.outstanding_count + ')</td>';
                htm += '<td>' + sellerObj.total_outstanding.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '<tr class="danger" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'ExceededOutstanding\',\'' + sellerObj.seller_name + '\');">';
                htm += '<td>Exceeded outstanding(' + sellerObj.exceeded_outstanding_count + ')</td>';
                htm += '<td>' + sellerObj.exceeded_outstanding.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '<tr class="" style="background:#dfd2ef;">';
                htm += '<td>Commision(Total)</td>';
                htm += '<td>' + sellerObj.total_commision.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '<tr class="" style="background:#dfd2ef;">';
                htm += '<td>Commision(Delivered)</td>';
                htm += '<td>' + sellerObj.delivered_commision.toFixed(2) + '</td>';
                htm += '</tr>';
                htm += '</tbody>';
                htm += '</table>';
                htm += '</div>';
                htm += '<div class="panel-footer">';
                htm += '<a href="#" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'newOnly\',\'' + sellerObj.seller_name + '\');">new(' + sellerObj.new_order_count + ')</a>&nbsp';
                htm += '<a href="#" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'processedOnly\',\'' + sellerObj.seller_name + '\');">Processed(' + sellerObj.processed_order_count + ')</a>&nbsp';
                htm += '<a href="#" onClick="javascript:slOverviewExpanded(\'' + sellerObj.seller_id + '\',\'deliveredOnly\',\'' + sellerObj.seller_name + '\');">Delivered(' + sellerObj.delivered_order_count + ')</a>&nbsp';
                htm += '</div>';
                htm += '</div>';
                $("#divOverviewSales").html(htm);
            })
        },
        error: function (xhr, status) {
            closeOverlay();
            enableBackKey();
            ajaxerroralert();

        }
    });
}

function showProductOverview() {

    var yyyy = new Date().getFullYear();
    $('#txtPOFrom').scroller({
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

    $('#txtPOTo').scroller({
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

    var cday = currentdate();
    $("#txtPOFrom").val(cday);
    $("#txtPOTo").val(cday);
    showpage('divProductOverview');
    //var htm = "";
    //var db = getDB();
    //db.transaction(function (tx) {


    //    var selectUser = "select branch_id,branch_name from tbl_branch";
    //    tx.executeSql(selectUser, [], function (tx, res) {
    //        var len = res.rows.length;

    //        if (len > 0) {

    //            if (len > 1) {
    //                htm = htm + '<option value="0" selected>SELECT BRANCH / WAREHOUSE</option>';
    //            }
    //            for (var i = 0; i < len; i++) {
    //                htm = htm + '<option value="' + String(res.rows.item(i).branch_id) + '">' + String(res.rows.item(i).branch_name) + '</option>';
    //            }
    //            $("#SelectSalesOverviewBranch").html(htm);
    //            if (len == 1) { fetch_branch_details(); }
    //        }
    //        else {

    //            htm = htm + '<option value="0" selected>NO BRANCH / WAREHOUSE AVAILABLE</option>';
    //        }

    //    });


    //}, function (e) {
    //    alert("ERROR: " + e.message);
    //});
    getProductOverview();
    getBrandsAndCategories(function (brands, categories, Salesman) {
        $("#selBrand").html("<option value='0'>ALL BRANDS</option>")
        $.each(brands, function (i, brand) {
            $("#selBrand").append("<option value='" + brand.brand_id + "'>" + brand.brand_name + "</option>")
        })
        $("#selCategory").html("<option value='0'>ALL CATEGORIES</option>")
        $.each(categories, function (i, category) {
            $("#selCategory").append("<option value='" + category.cat_id + "'>" + category.cat_name + "</option>")
        })
        //$("#selSales").html("<option value='0'>--All Salesmen--</option>")
        //$.each(Salesman, function (i, Salesman) {
        //    $("#selSales").append("<option value='" + Salesman.user_id + "'>" + Salesman.first_name + " " + Salesman.last_name + "</option>")
        //})
    }, function () {

    });
}

function resetProductOverviewFilter() {



    //$("#selSales").val(0);
    $("#selBrand").val(0);
    $("#selCategory").val(0);
    var cday = currentdate();
    $("#txtPOFrom").val(cday);
    $("#txtPOTo").val(cday);
    getProductOverview();
}

function getProductOverview() {
    var postObj = {
        filters: {}
    };

    if ($.trim($("#txtPOFrom").val()) != "") {
        postObj.filters.dateFrom = $("#txtPOFrom").val();
    }
    if ($.trim($("#txtPOTo").val()) != "") {
        postObj.filters.dateTo = $("#txtPOTo").val();
    }
    if ($("#selBrand").val() != "0") {
        postObj.filters.brand = $("#selBrand").val();
    }
    if ($("#appuserid").val() != "0") {
        postObj.filters.user_id = $("#appuserid").val();
    }
    //if ($("#appuserid").val() != "0") {
    //    postObj.filters.salesman = $("#appuserid").val();
    //}
    if ($("#branchid").val() != "") {
        postObj.filters.branchid = $("#branchid").val();
    }
    if ($("#selCategory").val() != "0") {
        postObj.filters.category = $("#selCategory").val();
    }

    postObj.filters.password = $("#ss_user_password").val();
    postObj.filters.device_id = $("#ss_user_deviceid").val();

    overlay("loading product-sales overview");
    disableBackKey();
    $("#tblPOBrands tbody").html("");
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getProductOverview",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 25000,
        success: function (msg) {

            closeOverlay();
            enableBackKey();

            if (msg.d == "BLOCKED") {

                validation_alert("This Device / User has been blocked! Please contact admin.");
                onBackKeyDown();
                return;
            }

            var msgObj = JSON.parse(msg.d);
            console.log(msgObj);
            $("#lblTotalSales").text(msgObj.net_sales);
            $.each(msgObj.overview, function (i, brand) {
                var tr = document.createElement('tr');
                tr.innerHTML = '<td>' + brand.brand + '</td><td><div class="pull-right">' + brand.tot_sales + ' (' + brand.sales_percentage + '%)</div></td>';
                if (brand.sales_count != 0) {
                    tr.onclick = function () {
                        showBrandOverview(this, brand.brand_id, postObj.filters)
                    };
                }
                //$("#tblPOBrands tbody").append('<tr class="" onclick="showBrandOverview(this,'+brand.brand_id+','+JSON.stringify(postObj.filters)+')"><td>'+brand.brand+'</td><td><div class="pull-right">'+brand.tot_sales+'('+brand.sales_percentage+'%)</div></td></tr>');
                $("#tblPOBrands tbody").append(tr);

            });
        },
        error: function (xhr, status) {

            enableBackKey();
            onBackMove();
            closeOverlay();

            ajaxerroralert();
        }
    });
}

// to show brand overview
function showBrandOverview(tr, brandId, filters) {
    $(tr).addClass("info");
    console.log(filters);
    setTimeout(function () {
        $(tr).removeClass("info");
        getBrandOverview(brandId, filters);
        showpage('divBrandOverview');
    }, 100);
}

// function to get brand overview
function getBrandOverview(brandId, filters) {
    var postObj = {
        filters: {}
    };
    if (filters) {
        postObj.filters = filters;
    }
    postObj.filters.brand = brandId;
    if ($("#branchid").val() != "") {
        postObj.filters.branchid = $("#branchid").val();
    }
    if ($("#appuserid").val() != "0") {
        postObj.filters.salesman = $("#appuserid").val();
    }
    overlay("Loading Brandwise Prodcut overview");
    disableBackKey();
    $("#tblItemsOverview tbody").html("");
    $("#spanBrandName").text("");
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getBrandOverview",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();
            var msgObj = JSON.parse(msg.d);
            //console.log(msgObj);
            $("#lblBrandTotalSales").text(msgObj.net_sales);
            $("#spanBrandName").text(msgObj.brand + (msgObj.category ? "(" + msgObj.category + ")" : ""));

            $.each(msgObj.overview, function (i, item) {
                $("#tblItemsOverview tbody").append('<tr class=""><td>' + item.item + '</td><td><div class="pull-right">' + item.tot_sales + ' (' + item.sales_percentage + '%)</div></td></tr>');
            });
        },
        error: function (xhr, status) {

            closeOverlay();
            enableBackKey();
            ajaxerroralert();
        }
    });
}

function getBrandsAndCategories(onSuccess, onError) {
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getBrandsAndCategories",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"user_id":"' + $("#appuserid").val() + '"}',
        crossDomain: true,
        timeout: 15000,
        success: function (msg) {
            var msgObj = JSON.parse(msg.d);
            //alert(msgObj);
            onSuccess(msgObj.brands, msgObj.categories, msgObj.Salesman);

        },
        error: function (xhr, status) {
            onError();
        }
    });
}

// debit note
function swapDebitPaymentMethods() {

    var pay_type = $("#SelectDebitNotePayment").val();
    $('#txt_debit_cheque_date').val("");
    if (pay_type == 0) {

        $("#div_debit_chque").hide();
    }
    else {
        $(function () {

            var yyyy = new Date().getFullYear();

            $('#txt_debit_cheque_date').scroller({
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
        });
        $("#div_debit_chque").show();
    }
}

function show_view_debit_notes() {

    $("#div_list_debit_note").html('');
    showpage('div_view_debit_notes');
    get_debit_note_history(1);
}

function get_debit_note_history(page) {

    var htm = "";
    var postObj = {
        filters: {
            cust_id: $("#customer_id").val(),
            user_id: $("#appuserid").val(),
            page: page,
        }
    };

    overlay("Loading Customer's Debit Notes");
    disableBackKey();
    $("#div_list_debit_note").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_debit_note_history",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 20000,
        success: function (response) {
            closeOverlay();
            enableBackKey();

            if (response.d == "") {
                bootbox.alert('<p style="color:red">No Debit Notes Found</p>');
                return;
            }
            else if (response.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Debit Notes Found';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_list_debit_note").html(htm);

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

                    //var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 7 ? "DEBIT NOTE" : row.action_type == 6 ? "CREDIT NOTE" : "" + '';
                    //htm = htm + '<br /><span style="color:#337ab7"><small>Action Type : <b>' + action + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action By : <b>' + row.name + '</b></small></span></div>';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '"><b style="color:337ab7">Details</b> : ' + String(row.narration) + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(obj.totalRows);
                var perPage = parseInt(obj.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr_d" onclick="javascript:get_debit_note_history(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr_d" onclick="javascript:get_debit_note_history(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Debit Notes Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_debit_note").html(htm);

                if (page > 1) {
                    $("#btnPrev_lod_tr_d").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_tr_d").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_tr_d").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_tr_d").hide();
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

function show_debit_note_page() {

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    if ($("#Select_Access_Branch").val() == "0") { validation_alert('Please select a warehouse to continue!'); return; }
    $("#SelectDebitNotePayment").val('0');
    $("#txt_debit_amount").val('');
    $("#txt_debit_cheque_num").val('');
    $("#txt_debit_cheque_date").val('');
    $("#txt_debit_cheque_bank").val('');
    $("#txt_debit_spcl_note").val('');
    swapDebitPaymentMethods();
    getSessionID();
    showpage('div_debit_note');

}

function save_debit_note() {

    fixquotes();
    var dialogregistration = "";
    var cash_amount = "";
    var chequeamount = "";
    var cheque_bank = "";
    var cheque_number = "";
    var cheque_date = "";
    var payment = 0;

    if ($("#txt_debit_amount").val() == "") { validation_alert("Enter the Amount to be Debited"); $("#txt_debit_amount").focus(); return false; }
    if (isNaN($("#txt_debit_amount").val())) { validation_alert("Debit amount should be a valid number!"); return false; }

    if ($("#SelectDebitNotePayment").val() == "1") {
        if ($("#txt_debit_cheque_num").val() == "") { validation_alert("Enter the Cheque number"); $("#cr_note_chq_no").focus(); return false; }
        if ($("#txt_debit_cheque_date").val() == "") { validation_alert("Enter the Cheque Date"); $("#cr_not_cheque_date").focus(); return false; }
        if ($("#txt_debit_cheque_bank").val() == "") { validation_alert("Enter the Bank Name"); $("#cr_note_bank").focus(); return false; }
    }

    if ($("#txt_debit_spcl_note").val() == "") { validation_alert("Enter Remarks"); $("#txt_debit_spcl_note").focus(); return false; }


    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {
                return;

            } else {


                dialogregistration = bootbox.dialog({
                    message: '<div align=center id="simage" style="margin-top:0px;margin-bottom:0px"><p class="text-center" style="color:#337ab7;margin-top:0px;margin-bottom:0px"><i class="ti-exchange-vertical blink-image"></i><i class="ti-mobile blink-image"></i>  Processing debit entry </p></div>',
                    closeButton: false
                });

                if ($("#SelectDebitNotePayment").val() == "0") {

                    cash_amount = format_decimal_accuray(parseFloat($("#txt_debit_amount").val()));
                    chequeamount = 0;
                    cheque_bank = 0;
                    cheque_number = 0;
                    cheque_date = 0;
                }
                else if ($("#SelectDebitNotePayment").val() == "1") {

                    cash_amount = 0;
                    chequeamount = format_decimal_accuray(parseFloat($("#txt_debit_amount").val()));
                    cheque_bank = $("#txt_debit_cheque_bank").val();
                    cheque_number = $("#txt_debit_cheque_num").val();
                    cheque_date = dateformat($("#txt_debit_cheque_date").val());

                }
                else {


                }
                payment = cash_amount + chequeamount;
                var narration = "" + $("#txt_debit_amount").val() + " given to customer : Note:" + $("#txt_debit_spcl_note").val();

                var postObj = {

                    data: {

                        cust_id: $("#customer_id").val(),
                        user_id: $("#appuserid").val(),
                        branch_id: $("#Select_Access_Branch").val(),
                        cash_amt: cash_amount,
                        cheque_amt: chequeamount,
                        cheque_no: cheque_number,
                        cheque_date: cheque_date,
                        cheque_bank: cheque_bank,
                        narration: $("#txtspecial_credit_note").val(),
                        time_zone: $("#br_time_zone").val(),
                        payment: payment,
                        session_id: current_session_id,
                    }
                };

                disableBackKey();


                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/save_debit_note",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 20000,
                    success: function (response) {

                        dialogregistration.find(dialogregistration.modal('hide'));
                        enableBackKey();

                        if (response.d == "") {

                            validation_alert("An error occured! Please try again");
                        }
                        else if (response.d == "FAILED") {

                            validation_alert("An error occured! Please try again");
                        }
                        else if (response.d == "SUCCESS" || response.d == "EXIST") {

                            var logfailed = bootbox.dialog({
                                message: '<p class="text-center" style="color:green"><i class="ti-info"></i> Amount successfully debited!</p>',
                                closeButton: false
                            });

                            setTimeout(function () {
                                logfailed.find(logfailed.modal('hide'));
                                onBackKeyDown();
                                Get_Customer_Details();
                            }, 1500);
                        }
                        else { validation_alert("An error occured! Please try again"); }


                    },
                    error: function (xhr, status) {

                        closeOverlay();
                        enableBackKey();
                        ajaxerroralert();

                    }
                });






            }
        }
    });

}

function show_Order_details(ord_id) {

    $("#order_id").val(ord_id);
    $("#cust_wallet_amount").val("0");
    fetch_full_order_details();
}

function fetch_full_order_details() {

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

                    if (parseFloat(row.new_creditamt) != 0) {
                        htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Amount</div>';
                        htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + row.max_creditamt + " To " + row.new_creditamt + '</div>';
                    }

                    if (parseFloat(row.new_creditperiod) != 0) {
                        htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Cr Period</div>';
                        htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: From ' + row.max_creditperiod + " To " + row.new_creditperiod + '</div>';
                    }
                    if (parseInt(row.new_custtype) != 0) {

                        var oldClass = row.cust_type == 1 ? "A" : (row.cust_type == 2 ? "B" : "C");
                        var newClass = row.new_custtype == 1 ? "A" : (row.new_custtype == 2 ? "B" : "C");

                        htm = htm + '<div class="col-xs-4" Style="color:red;font-size:12px;font-weight:bold">Class</div>';
                        htm = htm + '<div class="col-xs-8" Style="color:red;font-size:12px;font-weight:bold">: Changed From ' + oldClass + " To " + newClass + '</div>';
                    }
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

                    if (row.sm_delivery_status == "3") { $("#Div_order_approval").show(); } else { $("#Div_order_approval").hide(); }

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

                    needDisplay = row.veh_first_name == null ? "none" : "block";
                    htm = htm + '<div class="row"  style="display:' + needDisplay + '">';
                    htm = htm + '<div class="col-xs-4" >Vehicle</div>';
                    htm = htm + '<div class="col-xs-8" style="color:#337ab7">: ' + row.veh_first_name + " " + row.veh_last_name + '</div>';
                    htm = htm + '</div>';

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
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid ' + bordercolor + '">';
                        htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:' + bordercolor + '">#' + itm_num + ' - <b>' + String(res.rows.item(i).itm_name) + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
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

function showSalesReturnPage() {

    if ($("#cust_current_status").val() == "2") { validation_alert('The customer registration has been rejected for this customer!'); return; }
    if ($("#Select_Access_Branch").val() == "0") { validation_alert('Please select a warehouse to continue!'); return; }
    else { clear_return_cart(); showpage('div_common_sales_return'); load_return_brands_and_categories(); $("#txt_serach_for_return_items").val(""); $("#div_searached_return_items").html(''); getSessionID(); }
}

function clear_return_cart() {

    var db = getDB();
    db.transaction(function (tx) {

        var delete_cart_qry = "DELETE FROM tbl_return_cart";
        tx.executeSql(delete_cart_qry, [], function (tx, res) {

        });

    }, function (e) {

        alert(e.message);

    });

}

function load_return_brands_and_categories() {

    getBrandsAndCategories(function (brands, categories, Salesman) {
        $("#selBrand").html("<option value='0'>ALL BRANDS</option>")
        $.each(brands, function (i, brand) {
            $("#select_return_brand").append("<option value='" + brand.brand_id + "'>" + brand.brand_name + "</option>")
        })
        $("#selCategory").html("<option value='0'>ALL CATEGORIES</option>")
        $.each(categories, function (i, category) {
            $("#select_return_category").append("<option value='" + category.cat_id + "'>" + category.cat_name + "</option>")
        })
        
    }, function () {

    });


}

function restore_return_categories() {

    var db = getDB();
    db.transaction(function (tx) {

        var chtm = "";
        var cat_qry = "";
        chtm = chtm + '<option value="x">All Categories</option>';

        if ($("#select_return_brand").val() == "x") {

            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='1' and branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_category_id";
        }
        else {
            cat_qry = "SELECT itm_category_id,cat_name FROM tbl_itembranch_stock WHERE itm_type='1' and itm_brand_id='" + $("#select_return_brand").val() + "' and branch_id='" + $("#Select_Access_Branch").val() + "' GROUP BY itm_category_id";
        }

        tx.executeSql(cat_qry, [], function (tx, res) {
            var len = res.rows.length;
            if (len > 0) {

                for (var i = 0; i < len; i++) {

                    chtm = chtm + '<option value="' + String(res.rows.item(i).itm_category_id) + '">' + String(res.rows.item(i).cat_name) + '</option>';
                }
                $("#select_return_category").html(chtm);

            }
            else { }
        });

    }, function (e) {

        alert(e.message);

    });

}

function search_return_item(page) {

    if ($("#txt_serach_for_return_items").val() == "" || $("#txt_serach_for_return_items").val() == null) {

        bootbox.alert('Please enter a search keyword!');
        return;
    }

    overlay("searching for items");
    fixquotes();

    var postObj = {
        filters: {

            custid: $("#customer_id").val(),
            brand: $("#select_return_brand").val(),
            category: $("#select_return_category").val(),
            searchTerm: $("#txt_serach_for_return_items").val(),
            branch_id: $("#Select_Access_Branch").val(),
            page: page
        }
    };

    // myApp.showPreloader('Loading Orders');
    disableBackKey();

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/search_return_item",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 15000,
        success: function (resp) {

            closeOverlay();
            enableBackKey();
            var htm = "";
            if (resp.d == "") {

                bootbox.alert('<p style="color:red">No Results Found</p>');
                return;

            }
            else if (resp.d == "N") {

                htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                htm = htm + '<div class="avatar">';
                htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                htm = htm + '</div> </div>';
                htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No Delivered Orders found with this item name. Please check the name you searched.';
                htm = htm + '<span class="text-success"><small></small></span>';
                htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                $("#div_searached_return_items").html(htm);
                return;

            }
            else {

                var color = "";
                var response = JSON.parse(resp.d);
                $.each(response.data, function (i, row) {

                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:load_return_item_to_popup(\'' + row.itbs_id + '\',\'' + row.itm_name + '\',\'' + row.itm_code + '\',\'' + row.sm_invoice_no + '\',\'' + row.sm_id + '\',\'' + row.si_qty + '\',\'' + row.si_foc + '\',\'' + row.si_discount_rate + '\',\'' + row.sm_date + '\',\'' + row.total_qty + '\',\'' + row.si_price + '\',\'' + row.returned + '\',\'' + row.return_price + '\')">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var image = "assets/img/sales-return.png";
                    htm = htm + '<div class="avatar"> <img src="' + image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">' + row.itm_name + '';
                    if (row.sm_invoice_no == "") {
                        htm = htm + '<br /><span style="color:#337ab7"><small>Bill No:(<b>' + row.sm_id + '</b>)</small></span>';
                    }
                    else {
                        htm = htm + '<br /><span style="color:#337ab7"><small>Bill No: #<b>' + row.sm_invoice_no + ' (' + row.sm_id + ')</b></small></span>';
                    }
                    htm = htm + '<br /><span style="color:#337ab7"><small>QTY: <b>' + row.si_qty + '</b> , FOC: <b>' + row.si_foc + '</b> , DISC: <b>' + row.si_discount_rate + '</b> %</small></span></br>';
                    htm = htm + '<span class="text-danger"><small>TOTAL QTY: <b>' + row.total_qty + '</b></small></span>';
                    htm = htm + '<br><span class="text-danger"><small>SOLD PRICE : <b>' + format_currency_value(row.si_price) + '</b>/unit</small></span></div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.sm_date + '</small></br>';
                    if (row.returned > 0) {
                        htm = htm + '<small class="text-danger"><b>' + row.returned + ' </b> RETURNED</small><br>';
                    }
                    htm = htm + '<small class="text-success"><b>' + (row.total_qty - row.returned) + ' </b> RETURNABLE</small>';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                if (response.totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_retord" onclick="javascript:search_return_item(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_retord" onclick="javascript:search_return_item(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
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

function calculate_return_total() {

    var qty = parseInt($("#txt_item_quantity").val());
    if (qty == "" || qty == null || isNaN(qty))
    { qty = 0; }
    else {
        qty = parseInt($("#txt_item_quantity").val());
    }

    if (qty > parseInt($("#return_max_qty").val())) {

        $("#txt_item_quantity").val($("#return_max_qty").val());
        qty = $("#return_max_qty").val();
    }

    var price = $("#txt_item_price").val();
    if (price == "" || price == null || isNaN(price)) { price = 0; }
    price = format_decimal_accuray(parseFloat(price));
    var total = qty * price;
    total = format_decimal_accuray(total);
    $("#itm_calc_net_total").val(total);
    $("#lbl_itmpop_itm_total").html('NET TOTAL : ' + format_currency_value(total) + '');

}

function load_return_item_to_popup(itbs_id, itm_name, itm_code, sm_invoice_no, sm_id, si_qty, si_foc, si_discount_rate, sm_date, total_qty, si_price, returned, return_price) {

    if (ispopupshown == 0) {
        popuploaded();
        dialog = bootbox.dialog({
            message: '<div class="content" style="margin-bottom:2px;">' +
    '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
    '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/sales-return.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
    '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>' + itm_name + '</b><br />' +
    '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">Bill No : ' + sm_invoice_no + ' (' + sm_id + ')</small></span><br />' +
    '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_code">ORD DATE : ' + sm_date + '</small></span><br />' +
    '<span class="text-danger"><small id="lbl_itmpop_itm_stock">PAST RETURNS : ' + returned + ' QTY</small></span></div></div>' +
    '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
    '<table>' +
    '<tr>' +
    '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">ITEM QTY</label><input type="number" id="txt_item_quantity" style="font-size:17px" onkeyup = "javascript:calculate_return_total();" class="form-control border-input integer" value="1" placeholder="Enter quantity"></div></td>' +
    '<td>&nbsp</td>' +
    '<td style="width:50%"><div class="form-group"><label style="float:left;color:#337ab7;font-size:12px">PRICE</label><input type="number" id="txt_item_price" style="font-size:17px" value="' + return_price + '" onkeyup = "javascript:calculate_return_total();" class="form-control border-input float" placeholder="Enter price"></div></td>' +
    '</tr>' +
    '</table>' +
    '<select id="SelectReturnItemType" class="form-control border-input"><option value="x" selected>Select Return Type</option><option value="0">Damaged</option><option value="1">Expired</option><option value="2">No Damage & Ready to use</option></select>' +
    '<div class="row" style="background-color:#fff;border-radius:0px;padding-bottom:5px;padding-top:5px;">' +
    '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;"><div class="avatar"><img src="assets/img/money.png" alt="Circle Image" class="img-circle img-no-padding img-responsive"></div> </div>' +
    '<div class="col-xs-10" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_price">UNIT PRICE : ' + format_currency_value(si_price) + '<br />' +
    '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_total_qty">TOTAL QTY SOLD (QTY + FOC) : <b>' + total_qty + '</b></small></span><br />' +
    '<span class="text-danger"><small id="lbl_itmpop_itm_total_without_tax">EFFECTIVE PRICE (with Disc,FOC etc.) : <b>' + format_currency_value(return_price) + ' </b>/Unit</small></span><br />' +
    '<span class="text-info" style="color:#337ab7"><small>QTY: <b>' + si_qty + '</b> , FOC: <b>' + si_foc + '</b> , DISC: <b>' + si_discount_rate + '</b> %</small></span><br />' +
    '<span class="text-danger"><small style="font-size:15px"><b id="lbl_itmpop_itm_total">NET TOTAL : 0 </b></small></span></div></div>' +
    '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +
    '<table>' +
    '<tr>' +
    '<td style="width:50%"><button class="btn btn-info" style="width:100%;border-radius:2px;background-color:#337ab7;color:#fff;border:none;height:40px" onclick="add_item_to_return_cart(\'' + itbs_id + '\',\'' + itm_name + '\',\'' + sm_id + '\',\'' + itm_code + '\',\'' + si_discount_rate + '\')">ADD</button></td>' +
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
    calculate_return_total();
    $("#order_id").val(sm_id);
    $("#itm_calc_dics_amount").val(si_discount_rate);
    $("#return_max_qty").val((total_qty - returned));

}

function add_item_to_return_cart(itbs_id, itm_name, sm_id, itm_code, si_discount_rate) {

    var qty = $("#txt_item_quantity").val();
    if (qty == "0" || qty == "" || qty == null || isNaN(qty)) {
        validation_alert("Enter a valid quantity for return");
        return;
    }
    var price = $("#txt_item_price").val();
    if (price == "" || price == null || isNaN(price)) {
        validation_alert("Enter a valid price for return");
        return;
    }
    if ($("#SelectReturnItemType").val() == "x") {
        validation_alert("Select Return Type");
        return;
    }

    var db = getDB();
    db.transaction(function (tx) {

        var check_item_existance_qry = "SELECT itbs_id,itm_name FROM tbl_return_cart WHERE itbs_id='" + itbs_id + "' and sm_id='" + sm_id + "'";

        tx.executeSql(check_item_existance_qry, [], function (tx, res) {
            if (res.rows.length > 0) { // check for item existance
                validation_alert(res.rows.item(0).itm_name + ' from same order already exists in the return cart'); // item exists
                modalClose();

            }
            else { // add item to cart

                var insert_tbl_cart = "INSERT INTO tbl_return_cart(sm_id,itbs_id,itm_code,itm_name,si_price,si_discount_rate,sri_qty,sri_total,sri_type) VALUES ('" + $("#order_id").val() + "','" + itbs_id + "','" + itm_code + "','" + itm_name + "','" + $("#txt_item_price").val() + "','" + $("#itm_calc_dics_amount").val() + "','" + $("#txt_item_quantity").val() + "','" + $("#itm_calc_net_total").val() + "','" + $("#SelectReturnItemType").val() + "')";

                tx.executeSql(insert_tbl_cart, [], function (tx, res) {
                    successalert(itm_name + " has been added to return cart!");
                    //$("#txt_serach_for_return_items").val("");
                    //$("#div_searached_return_items").html('');
                    onBackKeyDown();
                    modalClose();
                });

            }
        });

    }, function (e) {

        alert(e.message);

    });

}

function load_return_edit_popup(itbs_id, sm_id) {

    if (ispopupshown == 0) {
        popuploaded();

        var db = getDB();
        db.transaction(function (tx) {

            var htm = '';
            var selectTrans = "select * from tbl_return_cart where itbs_id=" + itbs_id + " and sm_id=" + sm_id + " ";
            tx.executeSql(selectTrans, [], function (tx, res) {
                var transDate = '';
                var len = res.rows.length;
                if (len == 0) {

                    closeOverlay();
                    return;
                }
                if (len > 0) {


                }

            });



        });


    }

}

function show_return_cart_page() {

    showpage('div_return_cart');
    $("#return_cartList").html("");
    $("#txtsearch_in_return_cart").val("");
    list_items_in_return_cart(1);
}

function list_items_in_return_cart(page) {


    var searchString = $("#txtsearch_in_return_cart").val();

    var perPage = 10;
    var totalRows = 0;
    var totPages = 1;
    var lowerBound = ((page - 1) * perPage);
    var upperBound = parseInt(perPage) + parseInt(lowerBound) - 1;
    var htm = '';

    var db = getDB();
    db.transaction(function (tx) {


        var qryCount = "SELECT count(*) as cnt FROM tbl_return_cart where itm_name like '%" + searchString + "%'";
        tx.executeSql(qryCount, [], function (tx, res) {

            totalRows = res.rows.item(0).cnt;
            totPages = Math.ceil(totalRows / perPage);
            var selectItems = "select * from tbl_return_cart " +
            " where itm_name like '%" + searchString + "%' limit " + perPage + " offset " + lowerBound;

            tx.executeSql(selectItems, [], function (tx, res) {

                var transDate = '';
                var len = res.rows.length;

                if (len == 0) {
                    $("#lbl_total_return_values").html('( No Items)');
                    //htm = htm + '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" >';
                    //htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    //htm = htm + '<div class="avatar">';
                    //htm = htm + '<img src="assets/img/noresults.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    //htm = htm + '</div> </div>';
                    //htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;"><br> No items found in return cart!';
                    //htm = htm + '<span class="text-success"><small></small></span>';
                    //htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    // $("#rt_cart_serach_box").hide();

                    $("#return_cartList").html(htm);

                    return;
                }
                if (len > 0) {

                    if (len == 1) { $("#lbl_total_return_values").html('( ' + len + ' Item)'); } else { $("#lbl_total_return_values").html('( ' + len + ' Items)'); }

                    // $("#rt_cart_serach_box").show();

                    var foc_color = "#337ab7";
                    var price_color = "#337ab7";
                    var discount_color = "#337ab7";
                    var bordercolor = "#337ab7";

                    for (var i = 0; i < len; i++) {

                        var color = 0;
                        var image = "";
                        var itm_num = ((perPage * (page - 1)) + (i + 1))
                        if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                        htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 3px 3px -3px #222;-moz-box-shadow: 0 3px 3px -3px #222;box-shadow: 0 3px 3px -3px #222;padding-bottom:5px;padding-top:5px;border:0.5px solid ' + bordercolor + '">';
                        htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:' + bordercolor + '"><i class="ti-cut" onclick="javascript:remove_item_from_return_cart(' + String(res.rows.item(i).itbs_id) + ',' + String(res.rows.item(i).sm_id) + ');" style="color:red"></i> #' + itm_num + ' - <b>' + String(res.rows.item(i).itm_name) + '</b><br /><hr style="margin-top:1px;margin-bottom:2px" />';
                        htm = htm + '<table style="width:100%;font-size:12px;color:#635c5c;text-align:left;" class=""><tbody>';
                        htm = htm + '<tr><td style="color:' + price_color + '"> Price : <b>' + format_currency_value(res.rows.item(i).si_price) + ' </b></td><td>Qty : <b>' + String(res.rows.item(i).sri_qty) + '</b></td><td style="color:#337ab7">Total : <b>' + format_currency_value(res.rows.item(i).sri_total) + '</b></td></tr>';
                        // htm = htm + '<tr><td style="color:' + discount_color + '">Discount : <b>' + String(res.rows.item(i).si_discount_rate) + '%</b></td><td style="color:' + foc_color + '">FOC : <b>' + String(res.rows.item(i).si_foc) + '</b></td><td style="color:#337ab7">Total : <b>' + format_currency_value(res.rows.item(i).si_net_amount) + '</b></td></tr>       ';
                        htm = htm + '</tbody></table>';
                        htm = htm + ' </div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                    }

                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_crt_ret" onclick="javascript:list_items_in_return_cart(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_crt_ret" onclick="javascript:list_items_in_return_cart(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';

                    $("#return_cartList").html(htm);

                    $('body,html').animate({
                        scrollTop: 0
                    }, 800);


                    if (page > 1) {
                        $("#btnPrev_crt_ret").show();
                    }
                    if (page < totPages) {
                        $("#btnNext_crt_ret").show();
                    }
                    if (totPages == 1) {
                        $("#btnNext_crt_ret").hide();
                    }
                    if (totPages == page) {
                        $("#btnNext_crt_ret").hide();
                    }

                }

            });

        });


        var selecttotals = "select SUM(sri_total) as net_return_total from tbl_return_cart";
        tx.executeSql(selecttotals, [], function (tx, res) {

            var len = res.rows.length;
            if (len == 0) {

            }
            if (len > 0) {
                if (res.rows.item(0).net_return_total == null) {

                    $("#btnrtn_continue_to_last_step").hide();
                    $("#lbl_return_amount").html('<br /><small style="color:#635c5c"> NO ITEMS FOUND IN THE CART</small>');
                }
                else {
                    $("#btnrtn_continue_to_last_step").show();
                    $("#lbl_return_amount").html('RETURN NET TOTAL : ' + format_currency_value(res.rows.item(0).net_return_total) + '');
                    $("#order_total").val(format_decimal_accuray(res.rows.item(0).net_return_total));

                }
            }

        });

    });


}

function remove_item_from_return_cart(itbs_id, sm_id) {

    var db = getDB();
    db.transaction(function (tx) {

        var delete_from_tbl_cart = "DELETE FROM tbl_return_cart WHERE itbs_id='" + itbs_id + "' and sm_id='" + sm_id + "'";
        tx.executeSql(delete_from_tbl_cart, [], function (tx, res) {

            validation_alert("Item has been removed from return cart!");
            list_items_in_return_cart(1);


        });

    }, function (e) {

        alert(e.message);

    });
}

function complete_sales_return() {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to Continue ?',
        callback: function (result) {
            if (result == false) {

                return;
            } else {

                var orderAdded = bootbox.dialog({
                    message: '<div align=center id="simage"><img class="avatar border-white" src="assets/img/overlayLoad.gif" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:#337ab7"><i class="ti-rss-alt"></i> Processing Return</p></div>',
                    closeButton: false
                });

                var return_Items = "";
                var db = getDB();
                db.transaction(function (tx) {

                    var ret_Items = "";

                    var htm = '';
                    var selectTrans = "select * from tbl_return_cart";
                    tx.executeSql(selectTrans, [], function (tx, res) {

                        var len = res.rows.length;
                        if (len == 0) {

                            return;
                        }
                        if (len > 0) {


                            ret_Items = "[";
                            for (var i = 0; i < len; i++) {
                                ret_Items = ret_Items + "{ ";
                                ret_Items = ret_Items + '' +
                                    '"itbs_id" :"' + String(res.rows.item(i).itbs_id) + '",' +
                                    '"sm_id" :"' + String(res.rows.item(i).sm_id) + '",' +
                                    '"itm_code" :"' + String(res.rows.item(i).itm_code) + '",' +
                                    '"itm_name" :"' + String(res.rows.item(i).itm_name) + '",' +
                                    '"si_price" :"' + String(res.rows.item(i).si_price) + '",' +
                                    '"si_discount_rate" :"' + String(res.rows.item(i).si_discount_rate) + '",' +
                                    '"sri_qty" :"' + String(res.rows.item(i).sri_qty) + '",' +
                                    '"sri_total" :"' + String(res.rows.item(i).sri_total) + '",' +
                                    '"sri_type" :"' + String(res.rows.item(i).sri_type);

                                if (i == (len - 1)) {

                                    ret_Items = ret_Items + '" }';

                                } else {

                                    ret_Items = ret_Items + '" },';
                                }
                            }
                            ret_Items = ret_Items + "]";
                            return_Items = ret_Items;

                            var postObj = {

                                return_order: {

                                    cust_id: $("#customer_id").val(),
                                    branchid: $("#Select_Access_Branch").val(),
                                    return_Items: return_Items,
                                    item_count: len,
                                    user_id: $("#appuserid").val(),
                                    branch_time_zone: $("#br_time_zone").val(),
                                    session_id: current_session_id
                                }
                            };

                            var cart = htm;
                            disableBackKey();

                            $.ajax({
                                type: "POST",
                                url: "" + getUrl() + "/sales_return",
                                data: JSON.stringify(postObj),
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                crossDomain: true,
                                timeout: 52000,
                                success: function (resp) {

                                    enableBackKey();
                                    onBackMove();
                                    onBackMove();
                                    var obj = JSON.parse(resp.d);

                                    if (obj.result == "SUCCESS" || obj.result == "EXIST") {

                                        $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Return Sccessful , ' + format_currency_value(obj.credited_amount) + ' has been reflected in customer balance</p>');
                                        Get_Customer_Details();
                                        setTimeout(function () {
                                            orderAdded.find(orderAdded.modal('hide'));
                                        }, 2000);
                                    }
                                    else {

                                        $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-down"></i> Return failed , Please try again</p>');

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


                            //end of ajax
                        }

                    });



                });






            }
        }

    })

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
            page: page,
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

                    var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 7 ? "DEBIT NOTE" : row.action_type == 6 ? "CREDIT NOTE" : "" + '';
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
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr_c" onclick="javascript:get_customer_transactions(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr_c" onclick="javascript:get_customer_transactions(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Transactions Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_all_cust_transactions").html(htm);

                if (page > 1) {
                    $("#btnPrev_lod_tr_c").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_tr_c").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_tr_c").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_tr_c").hide();
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

function load_items_for_edit() {

    var sm_type = $("#current_sm_type").val();
    if (sm_type == "2") { get_old_bill_order_values_for_edit(); }
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

            if ($("#order_current_status").val() != "4") { validation_alert("Cancelled order cannot be edited! Please change the status and try again."); } else { validation_alert("Cancelled order cannot be edited! Please change the status and try again."); }
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

    overlay("fetching items for order.");

    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_item_list",
        data: "{'branch_id':'" + $("#order_branch_id").val() + "'}",
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
                closeOverlay();

                var insert_qry_tbl_itembranch_stock = "INSERT INTO tbl_itembranch_stock (itm_type,brand_name,cat_name,branch_id,tp_tax_percentage,tp_cess,itbs_id,itm_id,itm_brand_id,itm_category_id,itm_name,itbs_stock,itm_code,itm_mrp,itm_class_one,itm_class_two,itm_class_three,itm_commision,itm_rating) VALUES ";
                // ITEM BRANCH STOCK DATA - 
                var itembranch_stock = "";
                //******************************************************************************************************
                $.each(obj.dt_item_branchstock, function (i, row) {

                    itembranch_stock = itembranch_stock + " ('" + row.itm_type + "','" + row.brand_name + "','" + row.cat_name + "','" + row.branch_id + "','" + row.tp_tax_percentage + "','" + row.tp_cess + "','" + row.itbs_id + "','" + row.itm_id + "','" + row.itm_brand_id + "','" + row.itm_category_id + "','" + row.itm_name + "','" + row.itbs_stock + "','" + row.itm_code + "','" + row.itm_mrp + "','" + row.itm_class_one + "','" + row.itm_class_two + "','" + row.itm_class_three + "','" + row.itm_commision + "','" + row.itm_rating + "'),";

                });

                itembranch_stock = itembranch_stock.replace(/,\s*$/, "");

                var db = getDB();
                db.transaction(function (tx) {

                    tx.executeSql("delete from tbl_itembranch_stock");
                    var query = insert_qry_tbl_itembranch_stock + itembranch_stock;
                    if (itembranch_stock != "") {
                        tx.executeSql(query, [], function (tx, res) {


                            if ($("#ss_new_item").val() == "1") { $("#newitemheader").show(); } else { $("#newitemheader").hide(); }

                            $("#Selectitmtypes_for_add").val(1);
                            $("#txtsearchProducts_for_add").val("");
                            // clear_Cart_Items();
                            load_brands_categories_to_combo_for_add_product();
                            list_items_for_sale_for_add_product(1);

                        });
                    }

                },
                function (e) {

                    alert(e.message);
                }
                );

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
                                        onBackKeyDown();

                                        $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Order edited successfully!</p>');

                                        setTimeout(function () {
                                            orderAdded.find(orderAdded.modal('hide'));
                                            fetch_full_order_details();
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
                    orderAdded.find(orderAdded.modal('hide'));
                    alert("ERROR: " + e.message);
                });



            }
        }

    })

}



function show_Offline_Contents_from_sidemenu() { // set home page as current div

    var div_id = $("#hdnCurrentDiv").val();
    $("#" + div_id + "").hide();
    $("#hdnCurrentDiv").val('homepage');
    show_Offline_Contents();
}



function sync_data_to_server() {

    var db = getDB();
    db.transaction(function (tx) {

        // 6 . SALES MASTER
        var selectSales_master = "select * from tbl_sales_master WHERE sm_sync_status='0'";
        tx.executeSql(selectSales_master, [], function (tx, res) {

            var htm = "";

            var len = res.rows.length;
            if (len == 0) {
                new_order_count = 0;
                sales_master_data = "";
            }
            if (len > 0) {

                new_order_count = len;
                sales_master_data = '[';
                for (var i = 0; i < len; i++) {
                    sales_master_data = sales_master_data + "{ ";
                    sales_master_data = sales_master_data + '' +
                        '"sm_id" :"' + String(res.rows.item(i).sm_id) + '",' +
                        '"sessionId" :"' + String(res.rows.item(i).sessionId) + '",' +
                        '"sm_date" :"' + String(res.rows.item(i).sm_date) + '",' +
                        '"sm_cash_amt" :"' + String(res.rows.item(i).sm_cash_amt) + '",' +
                        '"sm_wallet_amt" :"' + String(res.rows.item(i).sm_wallet_amt) + '",' +
                        '"sm_chq_amt" :"' + String(res.rows.item(i).sm_chq_amt) + '",' +
                        '"sm_chq_date" :"' + String(res.rows.item(i).sm_chq_date) + '",' +
                        '"sm_bank" :"' + String(res.rows.item(i).sm_bank) + '",' +
                        '"sm_chq_no" :"' + String(res.rows.item(i).sm_chq_no) + '",' +
                        '"branch_tax_method" :"' + String(res.rows.item(i).branch_tax_method) + '",' +
                        '"branch_tax_inclusive" :"' + String(res.rows.item(i).branch_tax_inclusive) + '",' +
                        '"branch" :"' + String(res.rows.item(i).branch) + '",' +
                        '"sm_userid" :"' + String(res.rows.item(i).sm_userid) + '",' +
                        '"cust_id" :"' + String(res.rows.item(i).cust_id) + '",' +
                        '"sm_delivery_status" :"' + String(res.rows.item(i).sm_delivery_status) + '",' +
                        '"sm_specialnote" :"' + String(res.rows.item(i).sm_specialnote) + '",' +
                        '"sm_latitude" :"' + String(res.rows.item(i).sm_latitude) + '",' +
                        '"sm_longitude" :"' + String(res.rows.item(i).sm_longitude) + '",' +
                        '"sm_order_type" :"' + String(res.rows.item(i).sm_order_type) + '",' +
                        '"sm_payment_type" :"' + String(res.rows.item(i).sm_payment_type) + '",' +
                        '"sm_total" :"' + String(res.rows.item(i).sm_total) + '",' +
                        '"sm_discount_rate" :"' + String(res.rows.item(i).sm_discount_rate) + '",' +
                        '"sm_discount_amount" :"' + String(res.rows.item(i).sm_discount_amount) + '",' +
                        '"sm_netamount" :"' + String(res.rows.item(i).sm_netamount) + '",' +
                        '"total_balance" :"' + String(res.rows.item(i).total_balance) + '",' +
                        '"total_paid" :"' + String(res.rows.item(i).total_paid) + '",' +
                        '"sm_tax_amount" :"' + String(res.rows.item(i).sm_tax_amount) + '",' +
                        '"sm_action_type" :"' + String(res.rows.item(i).sm_action_type) + '",' +
                        '"customer_status" :"' + String(res.rows.item(i).customer_status) + '",' +
                        '"sm_price_class" :"' + String(res.rows.item(i).sm_price_class) + '",' +
                        '"is_new_registration" :"' + String(res.rows.item(i).is_new_registration) + '",' +
                        '"sm_type" :"' + String(res.rows.item(i).sm_type);
                    if (i == (len - 1)) { sales_master_data = sales_master_data + '" }'; } else { sales_master_data = sales_master_data + '" },'; }
                }
                sales_master_data = sales_master_data + "]";

            }

            // SALES ITEMS
            var selectsalesitems = "select * from tbl_sales_items";
            tx.executeSql(selectsalesitems, [], function (tx, res) {

                var len = res.rows.length;

                if (len == 0) {
                    sales_items_count = 0;
                    sales_item_data = "";
                }
                if (len > 0) {

                    sales_items_count = len;
                    sales_item_data = '[';
                    for (var i = 0; i < len; i++) {
                        sales_item_data = sales_item_data + "{ ";
                        sales_item_data = sales_item_data + '' +
                            '"sm_id" :"' + String(res.rows.item(i).sm_id) + '",' +
                            '"itbs_id" :"' + String(res.rows.item(i).itbs_id) + '",' +
                            '"itm_name" :"' + String(res.rows.item(i).itm_name) + '",' +
                            '"si_org_price" :"' + String(res.rows.item(i).si_org_price) + '",' +
                            '"si_price" :"' + String(res.rows.item(i).si_price) + '",' +
                            '"si_qty" :"' + String(res.rows.item(i).si_qty) + '",' +
                            '"si_discount_rate" :"' + String(res.rows.item(i).si_discount_rate) + '",' +
                            '"si_foc" :"' + String(res.rows.item(i).si_foc) + '",' +
                            '"si_approval_status" :"' + String(res.rows.item(i).si_approval_status) + '",' +
                            '"itm_type" :"' + String(res.rows.item(i).itm_type) + '",' +
                            '"si_itm_type" :"' + String(res.rows.item(i).si_itm_type);
                        if (i == (len - 1)) { sales_item_data = sales_item_data + '" }'; } else { sales_item_data = sales_item_data + '" },'; }
                    }
                    sales_item_data = sales_item_data + "]";

                }

                //************************** AJAX STARTS ******************************************

                var postObj = {

                    sync_data: {

                        user_id: $("#appuserid").val(),

                        new_order_count: new_order_count,
                        sales_items_count: sales_items_count,
                        sales_master_data: sales_master_data,
                        sales_item_data: sales_item_data,
                        time_zone: $("#ss_default_time_zone").val(),
                        ss_decimal_accuracy: $("#ss_decimal_accuracy").val(),
                        last_device_db_updated: $("#db_last_updated_date").val(),

                    }
                };

                //  console.log(JSON.stringify(postObj));

                //**************************AJAX ENDS******************************************
                var sync_started = bootbox.dialog({
                    message: '<div align=center id="simage"><img class="avatar border-white" src="assets/img/overlayLoad.gif" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:#337ab7"><i class="ti-rss-alt"></i> Processing your order..</p></div>',
                    closeButton: false
                });
                disableBackKey();

                $.ajax({

                    type: "POST",
                    url: "" + getUrl() + "/upload_and_sync",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 210000,
                    success: function (msg) {
                        enableBackKey();

                        if (msg.d == "") {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i>Unable to proces order! Please try again. </p>');
                            setTimeout(function () {

                                sync_started.find(sync_started.modal('hide'));
                            }, 2000);

                        }
                        else if (msg.d == "FAILED") {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i>Unable to process order! Please try again. </p>');
                            setTimeout(function () {
                                sync_started.find(sync_started.modal('hide'));
                            }, 2000);
                        }
                        else {

                            $("#simage").html('<img class="avatar border-white" src="assets/img/success-icon-10.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:green"><i class="ti-thumb-up"></i> Order placed successfully!</p>');

                            var db = getDB();
                            db.transaction(function (tx) {

                                tx.executeSql("DELETE from tbl_sales_master");
                                tx.executeSql("DELETE from tbl_sales_items");

                            }, function (e) {

                                validation_alert(e.message);
                            });

                            setTimeout(function () {
                                sync_started.find(sync_started.modal('hide'));
                                $("#div_finalize_order").hide();
                                $("#hdnCurrentDiv").val('homepage');
                                showMyOrders(1);
                            }, 2000);

                        }

                    },
                    error: function (xhr, status) {

                        enableBackKey();
                        $("#simage").html('<img class="avatar border-white" src="assets/img/rejected.png" style="width:50px;height:50px;" alt="..."/><p class="text-center" style="color:red"><i class="ti-info"></i>No Internet access..Please try again. </p>');

                        setTimeout(function () {

                            sync_started.find(sync_started.modal('hide'));
                        }, 2000);
                    }
                });

            });

        });






    }, function (e) { alert(e.message); });


}

function load_popup_for_status() {

    var sm_type = $("#current_sm_type").val();
    if (sm_type == "2") { validation_alert("Order status cannot be changed for older entry"); return; }
    else {
        var order_status = $("#order_current_status").val();
        var htm = "";
        if (order_status != "3" && order_status != "5") {

            dialog = bootbox.dialog({
                message: '<div class="content" style="margin-bottom:2px;">' +
        '<div class="row" style="background-color:#fff;border-radius:0px;-webkit-box-shadow: 0 4px 4px -4px #222;-moz-box-shadow: 0 4px 4px -4px #222;box-shadow: 0 4px 4px -4px #222;padding-bottom:5px;padding-top:5px;">' +
        '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;" id="lbl_itmpop_itm_name"><b>CHANGE ORDER STATUS</b><br />' +
        '<span class="text-info" style="color:#337ab7"><small id="lbl_itmpop_itm_brand">ORD ID : #' + $("#order_id").val() + '</small></span><br />' +
        '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />' +

        '<select id="Select_Status_to_update" class="form-control border-input"></select>' +
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

            if (order_status == "2") {

                htm = htm + '<option value="2" selected>Delivered</option>';
                htm = htm + '<option value="0">New Order</option>';
                htm = htm + '<option value="4">Cancelled</option>';
            }
            else if (order_status == "0") {

                htm = htm + '<option value="0" selected>New Order</option>';
                htm = htm + '<option value="2">Delivered</option>';
                htm = htm + '<option value="4">Cancelled</option>';
            }
            else if (order_status == "1" || order_status == "6") {

                if (order_status == "1") { htm = htm + '<option value="1" selected>Processed</option>'; }
                else { htm = htm + '<option value="6" selected>Pending</option>'; }
                htm = htm + '<option value="4">Cancelled</option>';
            }
            else {

                htm = htm + '<option value="4" selected>Cancelled</option>';
                htm = htm + '<option value="0" >New Order</option>';
            }

            $("#Select_Status_to_update").html(htm);

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

function update_order_status() {

    if ($("#Select_Status_to_update").val() == $("#order_current_status").val()) { modalClose(); return; }
    if ($("#is_online_action").val() == "1") { update_order_status_online(); } else { update_order_status_offline(); }
}


function update_order_status_online() {

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to Continue ?',
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

                        var obj = JSON.parse(resp.d);

                        if (obj.result == "SUCCESS") {

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

            fetch_customer_sales_details_for_payment();

        }
        else { validation_alert("Payment cannot performed for offline orders!"); }
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
                delivery_status_image = obj.data[0].sm_delivery_status == 0 && obj.data[0].sm_packed == 0 ? "assets/img/neww.png" : obj.data[0].sm_delivery_status == 0 && obj.data[0].sm_packed == 1 ? "assets/img/packed.png" : obj.data[0].sm_delivery_status == 1 ? "assets/img/processes.jpg" : obj.data[0].sm_delivery_status == 2 ? "assets/img/delivered.png" : obj.data[0].sm_delivery_status == 3 ? "assets/img/underReview.jpg" : obj.data[0].sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : obj.data[0].sm_delivery_status == 5 ? "assets/img/rejected.png" : obj.data[0].sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
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
        $("#cust_wallet_used_amount").val('0');
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
    var total_payment = parseFloat($('#total_outstanding_payment').val());

    if (total_payment == 0) { validation_alert("Payment cannot be Zero!"); return; }

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
                        closeOverlayImmediately();
                        var obj = JSON.parse(msg.d);

                        if (obj.result == "FAILED") {
                            validation_alert("Transaction failed! Please try again.");
                            return;
                        }
                        else if (obj.result == "SUCCESS") {

                            
                            onBackKeyDown();
                            successalert("Payment Updated Succesfully");
                            //Get_Customer_Details();
                            fetch_full_order_details();

                        }
                        else {

                            validation_alert("Transaction failed! Please try again.");
                            return;
                        }
                    },
                    error: function (xhr, status) {

                        closeOverlayImmediately();
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
    else { validation_alert("Unavailable for offline orders"); }
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
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr" onclick="javascript:get_order_transactions(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr" onclick="javascript:get_order_transactions(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No transactions Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_order_activities").html(htm);

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

    BluetoothPrintManager.isBLEnabled(function (isEnabled) {
        if (!isEnabled) {
            // if not enabled request bluetooth
            BluetoothPrintManager.requestBluetoothService();
            return;
        }
        else {
            //check if connected
           
            if (is_connected) {
                printOrder();
                return;
            }
            // if blue tooth enabled, get selected printers id
            var id = $("#selPrintDevices").val();            
            if (id == "0") {

                validation_alert("Go to settings and connect a printer");
                return;
            }
            // try to connect with the selected printer
            BluetoothPrintManager.connect(id, function (response) {
                printOrder();
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

    //validation_alert("Print functionality is temporarily unavailable"); return; // <option value="1" selected>Bluetooth Printer</option>

    if (ispopupshown == 0) {

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

//******** viewing all transaction

function show_view_all_transactions() {

    showpage('div_all_transactions');
    var yyyy = new Date().getFullYear();
    $('#txt_common_trans_From').scroller({
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

    $('#txt_common_trans_fromTo').scroller({
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

    var cday = currentdate();
    $('#txt_common_trans_From').val(cday);
    $('#txt_common_trans_fromTo').val(cday);
    get_users_and_warehouses();
}

function resetTransactionFilter() {

    var cday = currentdate();
    $('#txt_common_trans_From').val(cday);
    $('#txt_common_trans_fromTo').val(cday);
    $('#Select_all_trans_branch').val(0);
    $('#Select_all_trans_user').val(0);
    $('#Select_tr_type').val(0);

    get_all_transactions(1);
}

function get_all_transactions(page) {

    var htm = "";
    var postObj = {
        filters: {

            admin_id: $("#appuserid").val(),
            dateFrom: dateformat($("#txt_common_trans_From").val()),
            dateTo: dateformat($("#txt_common_trans_fromTo").val()),
            user_id: $("#Select_all_trans_user").val(),
            branch_id: $("#Select_all_trans_branch").val(),
            trans_type: $("#Select_tr_type").val(),
            page: page,
        }
    };

    overlay("Loading Transactions");
    disableBackKey();
    $("#div_list_all_activities").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_all_transactions",
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

                $("#div_list_all_activities").html(htm);

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

                    var action = row.action_type == 1 ? "SALES" : row.action_type == 2 ? "PURCHASE" : row.action_type == 3 ? "SALES RETURN" : row.action_type == 4 ? "PURCHASE RETURN" : row.action_type == 5 ? "WITHDRAWAL" : row.action_type == 7 ? "DEBIT NOTE" : row.action_type == 6 ? "CREDIT NOTE" : "" + '';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action Type : <b>' + action + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Customer : <b>' + row.cust_name + '</b></small></span>';
                    htm = htm + '<br /><span style="color:#337ab7"><small>Action By : <b>' + row.name + '</b></small></span></div>';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#000;font-size:12px;background-color:' + color + '"><b style="color:337ab7">Details</b> : ' + String(row.narration) + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(obj.totalRows);
                var perPage = parseInt(obj.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_tr" onclick="javascript:get_all_transactions(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_tr" onclick="javascript:get_all_transactions(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No transactions Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_all_activities").html(htm);

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
            enableBackKey();
            ajaxerroralert();
            onBackMove();
        }
    });
}

function get_users_and_warehouses() {

    overlay("loading users & warehouses");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#Select_all_trans_branch").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_all_trans_user").html(uhtm);

                get_all_transactions(1);
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });




}

//******** REPORT - New Registrations

function show_New_Registrations() {

    showpage('div_registration_activity');
    var yyyy = new Date().getFullYear();
    $('#txt_date_reg_from').scroller({
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

    $('#txt_date_reg_to').scroller({
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

    var cday = currentdate();
    $('#txt_date_reg_from').val(cday);
    $('#txt_date_reg_to').val(cday);
    Get_users_and_locations();
}

function reset_Registration_Filter() {

    var cday = currentdate();
    $('#txt_common_trans_From').val(cday);
    $('#txt_common_trans_fromTo').val(cday);
    $('#Select_reg_location').val(0);
    $('#Select_regd_user').val(0);
    $('#Select_reg_type').val(0);
    get_New_Registrations(1);
}

function Get_users_and_locations() {

    overlay("Loading users and locations");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_locations",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {
                validation_alert("No Data Found");
                onBackKeyDown();
                return;
            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL LOCATIONS</option>';
                $.each(obj.dt_location, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.location_id) + '">' + String(row.location_name) + '</option>';
                });
                $("#Select_reg_location").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_regd_user").html(uhtm);

                get_New_Registrations(1);
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });




}

function get_New_Registrations(page) {

    overlay("Loading Customer List ");
    disableBackKey();

    var postObj = {

        filters: {

            admin_id: $("#appuserid").val(),
            dateFrom: dateformat($("#txt_date_reg_from").val()),
            dateTo: dateformat($("#txt_date_reg_to").val()),
            user_id: $("#Select_regd_user").val(),
            location_id: $("#Select_reg_location").val(),
            page: page,
            type: $('#Select_reg_type').val(),
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_New_Registrations",
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
                var is_new_registration = "";
                var area = $("#ss_currency").val();
                var tax_head = 0;
                $.each(response.customer_list, function (i, row) {

                    is_new_registration = row.is_new_registration;
                    if (is_new_registration == "1") { is_new_registration = '<b style="color:red">[NEW]</b>' } else { is_new_registration = ""; }
                    var color = 0;
                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_Customer_Details(' + String(row.cust_id) + ');">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + is_new_registration + ' ' + String(row.cust_name) + '<br />';
                    if (row.cust_reg_id != "" && row.cust_reg_id != null && row.cust_reg_id != undefined && row.cust_reg_id != "0") {

                        htm = htm + '<span class="text-info"><small>CUSTOMER ID: <b>' + String(row.cust_reg_id) + '</b></small></span><br />';
                    }
                    if (area == "AED") { tax_head = "TRN NO"; } else if (area == "Rs") { tax_head = "GSTIN"; } else { }
                    if (row.cust_tax_reg_id != "" && row.cust_tax_reg_id != null && row.cust_tax_reg_id != undefined && row.cust_tax_reg_id != "0") {

                        htm = htm + '<span class="text-info"><small>' + tax_head + ': <b>' + String(row.cust_tax_reg_id) + '</b></small></span><br />';
                    }
                    htm = htm + '<span class="text-info"><small>DATE: <b>' + String(row.joined_date) + '</b></small></span><br />';
                    htm = htm + '<span class="text-success"><small>' + String(row.cust_address) + ',' + String(row.cust_city) + '</small></span>';

                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';


                });

                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_reg" onclick="javascript:get_New_Registrations(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_reg" onclick="javascript:get_New_Registrations(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Customers Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_reg_customer_list").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);


                if (page > 1) {
                    $("#btnPrev_lod_reg").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_reg").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_reg").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_reg").hide();
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

//*** delayed deliveries

function reset_Delayorder_Filter() {

    $('#Select_delay_location').val(0);
    $('#Select_delay_user').val(0);
    get_delayed_orders(1);
}

function showDelayedDeliveries() {

    showpage('div_delayed_deliveries');
    $("#Select_delay_location").val('0');
    $("#Select_delay_user").val('0');

    overlay("loading users and locations");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_locations",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {
                validation_alert("No Data Found");
                onBackKeyDown();
                return;
            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL LOCATIONS</option>';
                $.each(obj.dt_location, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.location_id) + '">' + String(row.location_name) + '</option>';
                });
                $("#Select_delay_location").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_delay_user").html(uhtm);

                get_delayed_orders(1);
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });
}

function get_delayed_orders(page) {

    var htm = "";
    overlay("Loading Delayed Orders ");
    disableBackKey();
    $("#div_list_delayed_orders").html(htm);
    var postObj = {

        filters: {

            admin_id: $("#appuserid").val(),
            page: page,
            user_id: $("#Select_delay_user").val(),
            location_id: $("#Select_delay_location").val(),
            time_zone: $("#ss_default_time_zone").val(),
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_delayed_orders",
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
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_dly" onclick="javascript:get_delayed_orders(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_dly" onclick="javascript:get_delayed_orders(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_delayed_orders").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_lod_dly").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_dly").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_dly").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_dly").hide();
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

// function to show Stock
function showStock() {


    showpage('divStock');
    overlay("loading warehouses");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#SelectAppBranchStock").html(bhtm);


                getStock();
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });


}

// funnction to get stock details
function getStock() {
    var postObj = {
        filters: {
            branch: $("#SelectAppBranchStock").val()
        }
    };
    $("#tblStock tbody").html("");
    overlay("loading item stock status");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getStock",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify(postObj),
        dataType: "json",
        crossDomain: true,
        timeout: 10000,
        success: function (msg) {
            closeOverlay();
            enableBackKey();
            var items = JSON.parse(msg.d).items;
            $("#tblStock tbody").html("");
            $.each(items, function (i, item) {
                var htm = "<tr class='" + (item.stock_status == 0 ? "danger" : (item.stock_status == 1 ? "warning" : "success")) + "'>";
                htm += "<td>" + item.name + "</td>";
                htm += "<td>" + item.stock + " (" + item.reorder + ")</td>";
                htm += "</tr>";
                $("#tblStock tbody").append(htm);
            });
        },
        error: function (xhr, status) {
            $("#tblStock tbody").html("");
            enableBackKey();
            onBackMove();
            closeOverlay();

        }
    });
}

//function to show user locations
function showUserLocs() {

    var yyyy = new Date().getFullYear();
    $('#txtUserLocFromDate').scroller({
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

    $('#txtUserLocToDate').scroller({
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


    var cday = currentdate();
    $("#txtUserLocFromDate").val(cday);
    $("#txtUserLocToDate").val(cday);


    overlay('loading user list')
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlay();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                //onBackKeyDown();
            }
            else {

                showpage("divUserLocs");
                $("#divUserLocsMap").height(parseInt($(window).height() - (parseInt($("#divUserLocsfilter").outerHeight(true)) + 70)));
                initialize('divUserLocsMap');

                var obj = JSON.parse(msg.d);

                var uhtm = "";
                uhtm = uhtm + '<option value="0">Select a user</option>';
                $.each(obj.dt_users, function (i, row) {
                    if (row.user_type == "2" || row.user_type == "3") {
                        uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                    }
                });
                $("#selUsers").html(uhtm);

                // getUserLocs();
            }
        },
        error: function (xhr, status) {
            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });

}

var markers = [];

function clearMarkers() {
    $.each(markers, function (i, marker) {
        marker.setMap(null);
    });
}

function getUserLocs() {

    $("#lblDistance").val(0);
    clearMarkers();
    var user_id = $("#selUsers").val();

    if ($("#selUsers").val() == "0") { validation_alert("Please select a user"); $("#Div_track_count").html(''); return; }

    var dateFrom = $("#txtUserLocFromDate").val();
    var dateTo = $("#txtUserLocToDate").val();
    overlay("Loading user locations");
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getUserLocs",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        data: '{"admin_id":"' + $("#appuserid").val() + '","user_id":"' + user_id + '","fromDate":"' + dateFrom + '","toDate":"' + dateTo + '"}',
        timeout: 20000,
        success: function (msg) {
            closeOverlayImmediately();

            
            $("#lblDistance").text(JSON.parse(msg.d).distance_travelled);
            var order = JSON.parse(msg.d).order;
            //console.log(order); Approx. Distance travelled : <label id="Label1">0</label> KM
            var locs = JSON.parse(msg.d).routes;
            var count = 0;
            if ($("#Select_view_type").val() == "0") {

                $.each(locs, function (i, markerObj) {

                    $("#Div_distance").show();
                    count = count + 1;
                    // alert(markerObj.lat, markerObj.lng);
                    var myLatlng = new google.maps.LatLng(markerObj.lat, markerObj.lng);
                    var marker = new google.maps.Marker({
                        position: myLatlng,
                        map: map
                    });
                    if (i == locs.length - 1) {
                        console.log("last-" + (i + 1));
                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.80|0|ce4704|12|b|L');
                        marker.setZIndex(1000);

                        map.setCenter(myLatlng);
                    }
                    else {
                        // console.log("loc-"+(i + 1));
                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.80|0|f9cc02|9|b|' + (i + 1));
                    }
                    markers.push(marker);
                    (function (marker, data) {
                        cus_infowindow == undefined;
                        cus_infowindow = new google.maps.InfoWindow({});
                        marker.addListener('click', function () {
                            if (data.cust_name == "null" || data.cust_name == 0 || data.cust_name == " " || data.cust_name == null || data.cust_name == "NULL" || data.cust_name == undefined) {

                                cus_infowindow.setContent('<div style="overflow: auto;">No Nearby Customer , ' + data.date + '</div>');

                            } else {
                                cus_infowindow.setContent('<div style="overflow: auto;" onClick="javascript:show_Customer_Details(' + data.cust_id + ')">' + data.cust_name + ',' + data.date + '</div>');


                            }
                            cus_infowindow.open(map, marker);
                        });
                    })(marker, markerObj);
                });
                $("#Div_track_count").html('Total Check-Ins : <label>'+ count +'</label>');

            }
            else if ($("#Select_view_type").val() == "1") {

                $("#Div_distance").hide();
                $.each(order, function (i, markerObj) {
                    count = count + parseInt(markerObj.order_count);
                    // alert(markerObj.lat, markerObj.lng);
                    var myLatlng = new google.maps.LatLng(markerObj.lat, markerObj.lng);
                    var marker = new google.maps.Marker({
                        position: myLatlng,
                        map: map
                    });
                    
                    marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.80|0|6edf66|9|b|' + (markerObj.order_count));
                    
                    markers.push(marker);
                    (function (marker, data) {
                        cus_infowindow == undefined;
                        cus_infowindow = new google.maps.InfoWindow({});
                        marker.addListener('click', function () {
                            if (data.cust_name == "null" || data.cust_name == 0 || data.cust_name == " " || data.cust_name == null || data.cust_name == "NULL" || data.cust_name == undefined) {

                                cus_infowindow.setContent('<div style="overflow: auto;">No Nearby Customer , ' + data.date + '</div>');

                            } else {
                                cus_infowindow.setContent('<div style="overflow: auto;" onClick="javascript:show_Customer_Details(' + data.cust_id + ')">' + data.cust_name + ', [ ' + data.order_count + ' Orders ]</div>');


                            }
                            cus_infowindow.open(map, marker);
                        });
                    })(marker, markerObj);
                });

                $("#Div_track_count").html('Total Orders : <label>' + count + '</label>');

            }
            if (count == 0) { validation_alert("No Orders found for this user"); }

        },
        error: function (error) {

            closeOverlay();
            ajaxerroralert();
            console.log(error);
        }
    });
}

// *********** manage old oustanding bills

function showOldOutstandingsPage() {

    var yyyy = new Date().getFullYear();
    $('#txt_date_outstanding_from').scroller({
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

    $('#txt_date_outstanding_to').scroller({
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

    var cday = currentdate();
    $('#txt_date_outstanding_from').val(cday);
    $('#txt_date_outstanding_to').val(cday);

    overlay("loading users and locations");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                //onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#Select_outstanding_branch").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_outstanding_user").html(uhtm);
                showpage('div_report_old_bills');
                get_all_oustanding_bills(1);
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });

}

function reset_all_oustanding_bills() {

    var cday = currentdate();
    $('#txt_date_outstanding_from').val(cday);
    $('#txt_date_outstanding_to').val(cday);
    $('#Select_outstanding_branch').val(0);
    $('#Select_outstanding_user').val(0);
    get_all_oustanding_bills(1);
}

function get_all_oustanding_bills(page) {

    var htm = "";
    overlay("Loading Old Outstanding Entries ");
    disableBackKey();
    $("#div_list_all_oustanding_bills").html(htm);
    var postObj = {

        filters: {

            admin_id: $("#appuserid").val(),
            page: page,
            user_id: $("#Select_outstanding_user").val(),
            branch_id: $("#Select_outstanding_branch").val(),
            orders_from: dateformat($("#txt_date_outstanding_from").val()),
            orders_to: dateformat($("#txt_date_outstanding_to").val()),
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_all_oustanding_bills",
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
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_oold" onclick="javascript:get_all_oustanding_bills(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_oold" onclick="javascript:get_all_oustanding_bills(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Outstanding Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_all_oustanding_bills").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);


                if (page > 1) {
                    $("#btnPrev_lod_oold").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_oold").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_oold").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_oold").hide();
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

function clr_old_order_edt_fields() {

    $("#text_edit_old_date").val('');
    $("#text_edit_old_inv_id").val('');
    $("#text_edit_old_inv_netamount").val('');
    $("#text_edit_old_inv_spclnote").val('');

}

function get_old_bill_order_values_for_edit() {

    overlay("Loading old order details");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_old_bill_order_values_for_edit",
        data: "{'sm_id':'" + $("#order_id").val() + "'}",
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
                closeOverlay();

                var yyyy = new Date().getFullYear();
                var dd = new Date().getDate();
                var mm = new Date().getMonth() + 1;

                $('#text_edit_old_date').scroller({
                    preset: 'date',
                    maxDate: new Date(yyyy + ',' + mm + ',' + dd),
                    setText: 'Select',
                    invalid: {},
                    theme: 'android-ics',
                    display: 'modal',
                    mode: 'scroller',
                    //dateFormat :'yy/mm/dd'
                    dateFormat: 'dd-mm-yy'
                });


                $("#text_edit_old_date").val(obj.data[0].sm_date);
                //var itm_name = obj.data[0].itm_name;
                var invoice_id = (obj.data[0].itm_name.split("#"))[0];
                $("#text_edit_old_inv_id").val(invoice_id);
                $("#text_edit_old_inv_netamount").val(obj.data[0].sm_netamount);
                $("#text_edit_old_inv_spclnote").val(obj.data[0].sm_specialnote);
                showpage('div_edit_old_outstanding');
            }
        },
        error: function (xhr, status) {

            enableBackKey();
            closeOverlayImmediately();
            ajaxerroralert();

        }
    });

}

function update_old_oustanding_order() {

    fixquotes();
    if ($("#text_edit_old_date").val() == "") { validation_alert("Please enter the invoice date!"); return; }
    if ($.trim($("#text_edit_old_inv_id").val()) == "" || $.trim($("#text_edit_old_inv_id").val()) == null) { validation_alert("Please enter the Invoice Number / Order ID of old order for reference"); return; }
    if ($("#text_edit_old_inv_netamount").val() == "") { validation_alert("Please enter the bill amount"); return; }

    var bill_amount = parseFloat($("#text_edit_old_inv_netamount").val());

    bootbox.confirm({
        size: 'small',
        message: 'Are you sure to continue ?',
        callback: function (result) {
            if (result == false) {
                return;

            } else {
                overlay("Processing old Order entry..");
                disableBackKey();

                var postObj = {

                    editedorder: {

                        sm_id: $("#order_id").val(),
                        order_branch_id: $("#order_branch_id").val(),
                        invoice_id: $.trim($("#text_edit_old_inv_id").val()),
                        user_id: $("#appuserid").val(),
                        time_zone: $("#ss_default_time_zone").val(),
                        sm_netamount: $("#text_edit_old_inv_netamount").val(),
                        sm_date: dateformat($("#text_edit_old_date").val()),
                        sm_specialnote: $("#text_edit_old_inv_spclnote").val(),
                    }
                };

                $.ajax({
                    type: "POST",
                    url: "" + getUrl() + "/update_old_oustanding_order",
                    data: JSON.stringify(postObj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    crossDomain: true,
                    timeout: 20000,
                    success: function (resp) {

                        enableBackKey();
                        closeOverlayImmediately();
                        var obj = JSON.parse(resp.d);

                        if (obj.result == "SUCCESS" || obj.result == "EXIST") {

                            successalert("Old order updated Sccessfully!");
                            onBackKeyDown();
                            fetch_full_order_details();

                        }
                        else if (obj.result == "REPEAT") { validation_alert("This invoice already exists in the database!"); }
                        else { validation_alert("An error occured in the server! Please try again."); }


                    },
                    error: function (e) {

                        closeOverlayImmediately();
                        enableBackKey();
                        ajaxerroralert();

                    }
                });
            }
        }
    });


}

// edited orders

function reset_edited_order_list() {

    var cday = currentdate();
    $('#text_edited_from').val(cday);
    $('#text_edited_to').val(cday);
    $('#Select_edited_branch').val(0);
    $('#Select_edited_user').val(0);
    get_edited_order_list(1);
}

function show_edited_orders() {

    var yyyy = new Date().getFullYear();
    $('#text_edited_from').scroller({
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

    $('#text_edited_to').scroller({
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

    var cday = currentdate();
    $('#text_edited_from').val(cday);
    $('#text_edited_to').val(cday);

    overlay("loading users and warehouses");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#Select_edited_branch").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_edited_user").html(uhtm);
                showpage('div_edited_order_list');
                get_edited_order_list(1);
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });
}

function get_edited_order_list(page) {

    var htm = "";
    overlay("Loading Edited Orders ");
    disableBackKey();
    $("#div_list_all_edited_orders").html(htm);
    var postObj = {

        filters: {

            admin_id: $("#appuserid").val(),
            page: page,
            user_id: $("#Select_edited_user").val(),
            branch_id: $("#Select_edited_branch").val(),
            orders_from: dateformat($("#text_edited_from").val()),
            orders_to: dateformat($("#text_edited_to").val()),
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/get_edited_order_list",
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

                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:expand_Edited_Order(' + row.sm_id + ')">';
                    htm = htm + '<div class="col-xs-12" style="margin-top:7px;margin-bottom:5px;color:#337ab7;background-color:' + color + '">' + String(row.cust_name) + '</div><div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    var delivery_status_image = "";
                    //alert(row.sm_delivery_status + '|' + row.sm_packed);
                    delivery_status_image = row.sm_delivery_status == 0 && row.sm_packed == 0 ? "assets/img/neww.png" : row.sm_delivery_status == 0 && row.sm_packed == 1 ? "assets/img/packed.png" : row.sm_delivery_status == 1 ? "assets/img/processes.jpg" : row.sm_delivery_status == 2 ? "assets/img/delivered.png" : row.sm_delivery_status == 3 ? "assets/img/underReview.jpg" : row.sm_delivery_status == 4 ? "assets/img/cancelled.jpg" : row.sm_delivery_status == 5 ? "assets/img/rejected.png" : row.sm_delivery_status == 6 ? "assets/img/time.png" : "" + '';
                    //alert(delivery_status_image);
                    htm = htm + '<div class="avatar"> <img src="' + delivery_status_image + '" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    if (row.sm_invoice_no == "") {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No:(' + row.sm_id + ')';
                    }
                    else {
                        htm = htm + '</div> </div><div class="col-xs-6" style="margin-top:7px;margin-bottom:5px;">Bill No: #' + row.sm_invoice_no + ' (' + row.sm_id + ')';

                    }
                    htm = htm + '<br /><span style="color:#337ab7"><small>Bill Amount : ' + format_currency_value(row.sm_netamount) + '</small></span></br></div><div class="col-xs-4 text-right" style="margin-top:15px;"><small>' + row.sm_date + '</small></br>';
                    htm = htm + '</div></div>';
                    htm = htm + '<hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';

                });

                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_ed_orders" onclick="javascript:get_edited_order_list(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_ed_orders" onclick="javascript:get_edited_order_list(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Edited Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_all_edited_orders").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);


                if (page > 1) {
                    $("#btnPrev_lod_ed_orders").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_ed_orders").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_ed_orders").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_ed_orders").hide();
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

function expand_Edited_Order(sm_id) {

    $("#order_id").val(sm_id);
    getEditOrderHistory();
}

function getEditOrderHistory() {

    var htm = "";
    var postObj = {
        filters: {
            orderid: $("#order_id").val()
        }
    };

    overlay("Loading editing details");
    disableBackKey();
    $("#divListEditedOrderItemDetails").html("");

    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getEditOrderHistory",
        data: JSON.stringify(postObj),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 10000,
        success: function (msg) {
            //alert(msg.d);
            //return;
            closeOverlay();
            enableBackKey();



            if (msg.d == "") {

                bootbox.alert('<p style="color:red">No Order Editing Found</p>');
                return;

            }
            else if (msg.d == "N") {

                bootbox.alert('<p style="color:red">No Order Editings Found</p>');
                onBackMove();

                return;

            }
            else {

                var obj = JSON.parse(msg.d);
                var totrows = obj.count;
                totrows = parseInt(totrows);
                totrows = totrows - 1;

                $.each(obj.data, function (i, row) {

                    if (row.edit_action == 1) {

                        htm = htm + '<div class="content card" style="border:1px solid #a9a9a9">';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<div class="stats">';
                        htm = htm + ' <i class="ti-shopping-cart" style="color:#337ab7"></i><b style="color:#000">' + String(row.itm_name) + '</b><br>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<hr>';
                        htm = htm + '<div class="stats">';

                        if (row.new_si_price != row.si_price) {
                            htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Price : ' + parseFloat(row.new_si_price) + ' (from ' + parseFloat(row.si_price) + ')</p>';
                        }
                        if (row.new_si_qty != row.si_qty) {
                            htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Quantity : ' + parseFloat(row.new_si_qty) + ' (from ' + parseFloat(row.si_qty) + ')</p>';
                        }
                        if (row.new_si_foc != row.si_foc) {
                            htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>FOC : ' + parseFloat(row.new_si_foc) + ' (from ' + parseFloat(row.si_foc) + ')</p>';
                        }
                        if (row.new_si_discount_rate != row.si_discount_rate) {
                            htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Discount : ' + parseFloat(row.new_si_discount_rate) + ' (from ' + parseFloat(row.si_discount_rate) + ')</p>';
                        }
                        if (row.new_si_net_amount != row.si_net_amount) {
                            htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Total : ' + parseFloat(row.new_si_net_amount) + ' (from ' + parseFloat(row.si_net_amount) + ')</p>';
                        }

                        htm = htm + '<p class="category" style="color:gray"><i class="ti-pencil" style="color:#337ab7"></i>' + String(row.first_name) + ' ' + String(row.last_name) + '</p>';
                        htm = htm + '<p class="category" style="color:gray"><i class="ti-calendar" style="color:#337ab7"></i>' + formatDate(row.edited_date) + '</p>';

                        htm = htm + '</div>';
                        htm = htm + '</div>';

                        htm = htm + '</div>';
                    }
                    else if (row.edit_action == 2) {

                        htm = htm + '<div class="content card" style="border:1px solid #a9a9a9">';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<div class="stats">';
                        htm = htm + ' <i class="ti-shopping-cart" style="color:red"></i><b style="color:#000">' + String(row.itm_name) + '</b><br>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<hr>';
                        htm = htm + '<div class="stats">';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Price : ' + parseFloat(row.si_price) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Quantity : ' + parseFloat(row.si_qty) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>FOC : ' + parseFloat(row.si_foc) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Discount : ' + parseFloat(row.si_discount_rate) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Total : ' + parseFloat(row.si_net_amount) + '</p>';
                        htm = htm + '<p class="category" style="color:gray"><i class="ti-pencils" style="color:red">DELETED </i> by  ' + String(row.first_name) + ' ' + String(row.last_name) + '</p>';
                        htm = htm + '<p class="category" style="color:gray"><i class="ti-calendar" style="color:gray"></i>' + formatDate(row.edited_date) + '</p>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';

                    }
                    else {

                        htm = htm + '<div class="content card" style="border:1px solid #a9a9a9">';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<div class="stats">';
                        htm = htm + ' <i class="ti-shopping-cart" style="color:green"></i><b style="color:#000">' + String(row.itm_name) + '</b><br>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                        htm = htm + '<div class="footer">';
                        htm = htm + '<hr>';
                        htm = htm + '<div class="stats">';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Price : ' + parseFloat(row.si_price) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Quantity : ' + parseFloat(row.si_qty) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>FOC : ' + parseFloat(row.si_foc) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Discount : ' + parseFloat(row.si_discount_rate) + '</p>';
                        htm = htm + '<p class="category"><i class="fa fa-circle text-danger"></i>Total : ' + parseFloat(row.si_net_amount) + '</p>';
                        htm = htm + '<p class="category" style="color:gray"><i class="ti-pencils" style="color:green">NEW TEM </i> by  ' + String(row.first_name) + ' ' + String(row.last_name) + '</p>';
                        htm = htm + '<p class="category" style="color:gray"><i class="ti-calendar" style="color:gray"></i>' + formatDate(row.edited_date) + '</p>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                        htm = htm + '</div>';
                    }


                });

                $("#divListEditedOrderItemDetails").html(htm);
                showpage('divEditedOrderDetails');

            }


        },
        error: function (xhr, status) {

            closeOverlay();
            enableBackKey();
            ajaxerroralert();
            onBackMove();
        }
    });

}


// order clearance
function showClearancePage() {

    var db = getDB();
    db.transaction(function (tx) {

        var select_transactions = "select id from tbl_transactions WHERE trans_sync_status='0'";
        tx.executeSql(select_transactions, [], function (tx, res) {
            var len = res.rows.length;
            if (len == 0) { credit_debit_count = 0; }
            if (len > 0) { credit_debit_count = len; }

            var selectSales_master = "select sm_id from tbl_sales_master WHERE sm_sync_status='0'";
            tx.executeSql(selectSales_master, [], function (tx, res) {

                var len = res.rows.length;
                if (len == 0) { new_order_count = 0; }
                if (len > 0) { new_order_count = len; }

                if (credit_debit_count == 0 && new_order_count == 0) {

                    show_due_clearnce_page();
                }
                else {

                    validation_alert("There is offline order/credit/debit entries. Please sync to Clear Orders");
                    show_Offline_Contents();
                }

            });

        });

    }, function (e) { alert(e.message); });
}

function show_due_clearnce_page() {

    showpage('div_due_clearnce_page');
    $("#divListCustomerwithBalance").html('');
    getCustomerswithBalance(1);
}

function getCustomerswithBalance(page) {

    overlay("Loading Customer List ");
    disableBackKey();

    var postObj = {

        filters: {

            user_id: $("#appuserid").val(),
            page: page,
            password: $("#ss_user_password").val(),
            device_id: $("#ss_user_deviceid").val()
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/getCustomerswithBalance",
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
            else if (resp.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                onBackKeyDown();
            }
            else {
                var color = "";
                var response = JSON.parse(resp.d);
                var is_new_registration = "";
                var area = $("#ss_currency").val();
                var tax_head = 0;
                $.each(response.customer_list, function (i, row) {

                    is_new_registration = row.is_new_registration;
                    if (is_new_registration == "1") { is_new_registration = '<b style="color:red">[NEW]</b>' } else { is_new_registration = ""; }
                    var color = 0;
                    if (i % 2 == 0) { color = "#f6f6f6"; } else { color = "#fff"; }
                    htm = htm + '<div class="row" style="background-color:' + color + ';border-radius:0px;-webkit-box-shadow: 0 6px 6px -6px #222;-moz-box-shadow: 0 6px 6px -6px #222;box-shadow: 0 6px 6px -6px #222;padding-bottom:5px;padding-top:5px;" onclick="javascript:show_orders_for_clearance(' + String(row.cust_id) + ');">';
                    htm = htm + '<div class="col-xs-2" style="margin-top:5px;margin-bottom:5px;">';
                    htm = htm + '<div class="avatar">';
                    htm = htm + '<img src="assets/img/Icon-store-round-150x150.png" alt="Circle Image" class="img-circle img-no-padding img-responsive">';
                    htm = htm + '</div> </div>';
                    htm = htm + '<div class="col-xs-8" style="margin-top:7px;margin-bottom:5px;">' + is_new_registration + ' ' + String(row.cust_name) + '<br />';
                    if (row.cust_reg_id != "" && row.cust_reg_id != null && row.cust_reg_id != undefined && row.cust_reg_id != "0") {

                        htm = htm + '<span class="text-info"><small>CUSTOMER ID: <b>' + String(row.cust_reg_id) + '</b></small></span><br />';
                    }


                    htm = htm + '<span class="text-success"><small>' + String(row.cust_address) + ',' + String(row.cust_city) + '</small></span><br />';
                    htm = htm + '<span class="text-danger"><small>ORDER BALANCE TO CLEAR : <b>' + format_currency_value(row.balance_to_clear) + '</b></small></span><br />';
                    htm = htm + '<span class="text-info"><small>AVAILABLE CREDIT BALANCE : <b>' + format_currency_value(row.available_to_clear) + '</b></small></span>';
                    htm = htm + ' </div><div class="col-xs-2 text-right" style="margin-top:15px;"><i class="ti-angle-right"></i></div></div><hr style="margin-bottom:2px;margin-top:2px;opacity:0" />';


                });

                var totalRows = parseInt(response.totalRows);
                var perPage = parseInt(response.perPage);
                var totPages = Math.ceil(totalRows / perPage);

                if (totPages > 1) {
                    htm = htm + '<div class="row" style="margin-top:10px;">';
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_2clr" onclick="javascript:getCustomerswithBalance(' + parseInt(page - 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_2clr" onclick="javascript:getCustomerswithBalance(' + parseInt(page + 1) + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Customers Found</div>';
                    htm = htm + ' </div>';
                }

                $("#divListCustomerwithBalance").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_lod_2clr").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_2clr").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_2clr").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_2clr").hide();
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

function show_orders_for_clearance(cust_id) {

    showpage('div_show_order_clrnce');
    Get_Orders_for_payment_clearance(1, cust_id);
    $("#div_list_orders_to_be_cleared").html('');
}

function Get_Orders_for_payment_clearance(page, cust_id) {

    overlay("Loading Orders to be Cleared! ");
    disableBackKey();

    var postObj = {

        filters: {

            user_id: $("#appuserid").val(),
            cust_id: cust_id,
            page: page,
        }
    };


    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_Orders_for_payment_clearance",
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
                console.log(JSON.parse(resp.d));
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
                    htm = htm + '<div class="col-xs-6"><button id="btnPrev_lod_odc" onclick="javascript:Get_Orders_for_payment_clearance(' + parseInt(page - 1) + ',' + cust_id + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius: 5px;border:none; display:none" class="btn btn-info"> < PREV </button></div>';
                    htm = htm + '<div class="col-xs-6"><button id="btnNext_lod_odc" onclick="javascript:Get_Orders_for_payment_clearance(' + parseInt(page + 1) + ',' + cust_id + ');" style="background-color: #337ab7; color: #f8f8f8; width: 98%; border-radius:5px; border:none; " class="btn btn-info"> NEXT > </button></div>';
                    htm = htm + ' </div>';
                }

                if (totalRows == 0) {
                    htm = htm + '<div class="row" style="margin-top:10px;text-align:center;color:#337ab7">';
                    htm = htm + '<div class="col-xs-12"> No Orders Found</div>';
                    htm = htm + ' </div>';
                }

                $("#div_list_orders_to_be_cleared").html(htm);
                $('body,html').animate({
                    scrollTop: 0
                }, 800);



                if (page > 1) {
                    $("#btnPrev_lod_odc").show();
                }
                if (page < parseInt(totPages)) {
                    $("#btnNext_lod_odc").show();
                }
                if (parseInt(totPages) == 1) {
                    $("#btnNext_lod_odc").hide();
                }
                if (parseInt(totPages) == page) {
                    $("#btnNext_lod_odc").hide();
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

function show_sales_overview() {

    var yyyy = new Date().getFullYear();
    $('#txt_date_overview_from').scroller({
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

    $('#txt_date_overview_to').scroller({
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

    var cday = currentdate();
    $('#txt_date_overview_from').val(cday);
    $('#txt_date_overview_to').val(cday);

    overlay("loading users and warehouses");
    disableBackKey();
    $.ajax({
        type: "POST",
        url: "" + getUrl() + "/Get_users_and_warehouses",
        data: "{'user_id':'" + $("#appuserid").val() + "','password':'" + $("#ss_user_password").val() + "','device_id':'" + $("#ss_user_deviceid").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 30000,
        success: function (msg) {

            closeOverlayImmediately();
            enableBackKey();

            if (msg.d == "N") {

                validation_alert("No Data Found");
                onBackKeyDown();
                return;

            }
            else if (msg.d == "BLOCKED") {

                validation_alert("This Device is not authorized! Please Reset your device using the Admin control panel.");
                //onBackKeyDown();
            }
            else {

                var obj = JSON.parse(msg.d);

                var bhtm = "";
                bhtm = bhtm + '<option value="0">ALL BRANCHES</option>';
                $.each(obj.dt_warehouse, function (i, row) {

                    bhtm = bhtm + '<option value="' + String(row.branch_id) + '">' + String(row.branch_name) + '</option>';
                });
                $("#select_over_view_branch_id").html(bhtm);


                var uhtm = "";
                uhtm = uhtm + '<option value="0">ALL USERS</option>';
                $.each(obj.dt_users, function (i, row) {

                    uhtm = uhtm + '<option value="' + String(row.user_id) + '">' + String(row.name) + '</option>';
                });
                $("#Select_sl_ovrvie_user_id").html(uhtm);

                showpage('div_sales_overview');
                get_sales_overview();
            }
        },
        error: function (xhr, status) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();
        }
    });

  


}

function get_sales_overview() {

    overlay("Generating sales overview");
    disableBackKey();
    $.ajax({

        type: "POST",
        url: "" + getUrl() + "/Sales_Overview",
        data: "{'branch_id':'" + $("#select_over_view_branch_id").val() + "','user_id':'" + $("#appuserid").val() + "','date_from':'" + dateformat($("#txt_date_overview_from").val()) + "','date_to':'" + dateformat($("#txt_date_overview_to").val()) + "','seller_id':'" + $("#Select_sl_ovrvie_user_id").val() + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        crossDomain: true,
        timeout: 35000,
        success: function (msg) {

            closeOverlay();
            enableBackKey();
            var obj = JSON.parse(msg.d);
            // console.log(obj);

            // SETTING VALUES BLOCKWISE - obj.checkin_count[0].checkin_count
            //* FOR CHECKIN 
            //lbl_main_over_total_visit
            $("#lbl_main_over_total_visit").html(obj.check_in[0].checkin_count + ' nos.');

            // COMMSION INFO

            $("#lbl_txt_ovr_other_commision").html(format_currency_value(obj.dt_order[0].sold_commision));
            $("#lbl_txt_ovr_delivered_commision").html(format_currency_value(obj.dt_order[0].delivered_commision));
            $("#lbl_txt_ovr_review_commision").html(format_currency_value(obj.dt_order[0].tobeconfirm_commision));

            // RETURN
            $("#lbl_slover_return_count").html(obj.dt_cr_dr_rt[0].returned_count + ' nos.');
            $("#lbl_slover_return_amount").html(format_currency_value(obj.dt_cr_dr_rt[0].total_returned));

            // CREDIT DEBIT WALLET-USE
            $("#lbl_sloverview_credit_count").html(obj.dt_cr_dr_rt[0].credit_count + ' nos.');
            $("#lbl_sloverview_credit_amt").html(format_currency_value(obj.dt_cr_dr_rt[0].total_credit));

            $("#lbl_sloverview_debit_count").html(obj.dt_cr_dr_rt[0].debit_count + ' nos.');
            $("#lbl_sloverview_debit_amount").html(format_currency_value(obj.dt_cr_dr_rt[0].total_debit));

            $("#lbl_sloverview_wallet_count").html(obj.dt_cr_dr_rt[0].withdrawn_count + ' times.');
            $("#lbl_sloverview_wallet_used").html(format_currency_value(obj.dt_cr_dr_rt[0].wallet_withdrawn));


            $("#lbl_main_over_total_sales").html(format_currency_value(obj.dt_order[0].total_sale));
            var cash_in_hand = (parseFloat(obj.dt_cr_dr_rt[0].tot_cash_amount) + parseFloat(obj.dt_cr_dr_rt[0].tot_cheque_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit)
            $("#lbl_main_over_total_collection").html(format_currency_value(cash_in_hand));

            var tot_cash_amt = (parseFloat(obj.dt_cr_dr_rt[0].tot_cash_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit_as_cash)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit_as_cash);
            var tot_cheque_amt = (parseFloat(obj.dt_cr_dr_rt[0].tot_cheque_amount) + parseFloat(obj.dt_cr_dr_rt[0].total_credit_as_cheque)) - parseFloat(obj.dt_cr_dr_rt[0].total_debit_as_cheque);

            $("#lbl_ovr_in_totcash").html('CASH : ' + format_currency_value(tot_cash_amt));
            $("#lbl_ovr_in_totcheque").html(' |  CHEQUE : ' + format_currency_value(tot_cheque_amt));

            // ACTIVE ORDERS
            $("#lbl_slover_active_order_count").html(obj.dt_order[0].active_order_count + ' nos.');
            $("#lbl_slover_active_total_sale").html(format_currency_value(obj.dt_order[0].active_total_sale));
            $("#lbl_slover_active_active_total_receipt").html(format_currency_value(obj.dt_order[0].active_total_receipt));
            $("#lbl_slover_active_outstanding_count").html(obj.dt_order[0].active_outstanding_count + ' nos.');
            $("#lbl_slover_active_total_outstanding").html(format_currency_value(obj.dt_order[0].active_total_outstanding));

            // TOTOAL SUMMARY
            $("#lbl_slover_totordercount").html(obj.dt_order[0].order_count + ' nos.');
            $("#lbl_slover_tot_netamt").html(format_currency_value(obj.dt_order[0].total_sale));
            $("#lbl_slover_tot_pay_collected").html(format_currency_value(obj.dt_order[0].total_receipt));
            $("#lbl_slover_totorder_with_bal").html(obj.dt_order[0].outstanding_count + ' nos.');
            $("#lbl_slover_tot_bal_amt").html(format_currency_value(obj.dt_order[0].total_outstanding));
            $("#lbl_slover_active_exceeded_outstanding_count").html(obj.dt_order[0].exceeded_outstanding_count + ' nos.');
            $("#lbl_slover_active_exceeded_outstanding").html(format_currency_value(obj.dt_order[0].exceeded_outstanding));
            $("#lbl_old_bill_entry").html(obj.dt_order[0].old_order_count + ' nos.');

            // STATUS WISE
            //new
            $("#lbl_sl_ovr_new_cnt").html(obj.dt_order[0].new_order_count + ' nos.');
            $("#lbl_sl_ovr_new_amt").html(format_currency_value(obj.dt_order[0].new_order_netamt));
            $("#lbl_sl_ovr_new_paid").html(format_currency_value(obj.dt_order[0].new_order_paid));
            $("#lbl_sl_ovr_new_bal").html(format_currency_value(obj.dt_order[0].new_order_balance));
            //packed
            $("#lbl_sl_ovr_pak_cnt").html(obj.dt_order[0].packed_order_count + ' nos.');
            $("#lbl_sl_ovr_pak_amt").html(format_currency_value(obj.dt_order[0].packed_netamt));
            $("#lbl_sl_ovr_pak_paid").html(format_currency_value(obj.dt_order[0].packed_paid));
            $("#lbl_sl_ovr_pak_bal").html(format_currency_value(obj.dt_order[0].packed_balance));
            //processed
            $("#lbl_sl_ovr_pro_cnt").html(obj.dt_order[0].processed_order_count + ' nos.');
            $("#lbl_sl_ovr_pro_amt").html(format_currency_value(obj.dt_order[0].processed_netamt));
            $("#lbl_sl_ovr_pro_paid").html(format_currency_value(obj.dt_order[0].processed_paid));
            $("#lbl_sl_ovr_pro_bal").html(format_currency_value(obj.dt_order[0].processed_balance));
            //delivered
            $("#lbl_sl_ovr_del_cnt").html(obj.dt_order[0].delivered_order_count + ' nos.');
            $("#lbl_sl_ovr_del_amt").html(format_currency_value(obj.dt_order[0].delivered_order_netamt));
            $("#lbl_sl_ovr_del_paid").html(format_currency_value(obj.dt_order[0].delivered_order_paid));
            $("#lbl_sl_ovr_del_bal").html(format_currency_value(obj.dt_order[0].delivered_order_balance));
            //pending
            $("#lbl_sl_ovr_pen_cnt").html(obj.dt_order[0].pending_order_count + ' nos.');
            $("#lbl_sl_ovr_pen_amt").html(format_currency_value(obj.dt_order[0].pending_netamt));
            $("#lbl_sl_ovr_pen_paid").html(format_currency_value(obj.dt_order[0].pending_paid));
            $("#lbl_sl_ovr_pen_bal").html(format_currency_value(obj.dt_order[0].pending_balance));
            //cancelled
            $("#lbl_sl_ovr_can_cnt").html(obj.dt_order[0].cancelled_order_count + ' nos.');
            $("#lbl_sl_ovr_can_amt").html(format_currency_value(obj.dt_order[0].cancelled_netamt));
            $("#lbl_sl_ovr_can_paid").html(format_currency_value(obj.dt_order[0].cancelled_paid));
            //rejected
            $("#lbl_sl_ovr_rej_cnt").html(obj.dt_order[0].rejected_order_count + ' nos.');
            $("#lbl_sl_ovr_rej_amt").html(format_currency_value(obj.dt_order[0].rejected_netamt));
            // $("#lbl_sl_ovr_rej_paid").html(format_currency_value(obj.dt_order[0].rejected_paid));

            //to be confirm
            $("#lbl_sl_ovr_rev_cnt").html(obj.dt_order[0].toBeConfirmed_order_count + ' nos.');
            $("#lbl_sl_ovr_rev_amt").html(format_currency_value(obj.dt_order[0].toBeConfirmed_netamt));


            // OLD PAYMENTS

            $("#lbl_pay_info_lbl").html('( Payments recieved for orders placed before ' + $("#txt_date_overview_from").val() + ')');
            $("#lbl_sl_ovr_old_paycnt").html(obj.dt_past_paid[0].pre_pay_count + ' nos.');
            $("#lbl_sl_ovr_old_payamt").html(format_currency_value(obj.dt_past_paid[0].old_payments));

            $("#lbl_main_sl_ovr_hdr").html('Based on orders placed between ' + $("#txt_date_overview_from").val() + ' and ' + $("#txt_date_overview_to").val() + ' Only ');
            // customer info

            $("#lbl_sl_ovrview_new_reg_total").html(obj.dt_new_reg[0].total_reg + ' nos.');
            $("#lbl_sl_ovrview_new_reg_pend").html(obj.dt_new_reg[0].pending_customer + ' nos.');
            $("#lbl_sl_ovrview_new_reg_approved").html(obj.dt_new_reg[0].approved_customer + ' nos.');
            $("#lbl_sl_ovrview_new_reg_rejected").html(obj.dt_new_reg[0].rejected_customer + ' nos.');

        },
        error: function (e) {

            closeOverlayImmediately();
            enableBackKey();
            ajaxerroralert();

        }

    });

}

function reset_SlOverview_Filter() {

    var cday = currentdate();
    $('#txt_date_overview_from').val(cday);
    $('#txt_date_overview_to').val(cday);

    $("#Select_sl_ovrvie_user_id").val("0");
    $("#select_over_view_branch_id").val("0");
    get_sales_overview();
}