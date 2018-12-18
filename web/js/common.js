var htm = "";
var queryParams = {};

//var url = "http://lifelinecrm.org";

//function to load menu
function loadMenu() {
    htm+='<div class="menu_section">';
    htm+='<h3>General</h3>';
    htm+='<ul class="nav side-menu">';
    htm += '<li><a href="/dashboard.aspx"><i class="fa fa-home"></i> <label style="font-size:12px;">Home</label> <span class="fa fa-chevron-down"></span></a>';
    htm+='</li>';
    htm += '<li><a><i class="fa fa-user"></i> <label style="font-size:12px;">Customer</label> <span class="fa fa-chevron-down"></span></a>';
    htm+='<ul class="nav child_menu">';
    htm += '<li><a href="../managecustomers.aspx"><label style="font-size:12px;">New Customer</label></a></li>';
    htm += '<li><a href="../customers.aspx"> <label style="font-size:12px;">Customers</label></a></li>';
    //htm += '<li><a href="../customerbooking.aspx"> <label style="font-size:12px;">Bookings</label></a></li>';
    //htm+='<li><a href="customerconfirmation.html">Customer Confirmation</a></li>';
    //htm += '<li><a href="../manageSlaesPerson.aspx"><label style="font-size:12px;">Assign Customer</label></a></li>';
    htm+='</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-truck"></i><label style="font-size:12px;"> Purchase</label> <span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../inventory/vendors.aspx"><label style="font-size:12px;">Suppliers</label></a></li>';
    htm += '<li><a href="../purchase/purchaseentry.aspx"><label style="font-size:12px;">New Entry</label></a></li>';
    htm += '<li><a href="../purchase/listPurchaseEntries.aspx"><label style="font-size:12px;">Purchases</label></a></li>';
    // htm += '<li><a href="../sales/editorder.aspx">Edit Order</a></li>';
    // htm += '<li><a href="../sales/orderconfirmation.aspx">Confirm Order</a></li>';
    htm += '</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-shopping-cart"></i><label style="font-size:12px;"> Sales</label> <span class="fa fa-chevron-down"></span></a>';
    htm+='<ul class="nav child_menu">';
    htm += '<li><a href="../sales/neworder.aspx"><label style="font-size:12px;">New Bill</label></a></li>';
    htm += '<li><a href="../sales/orders.aspx"><label style="font-size:12px;">Bills</label></a></li>';
   // htm += '<li><a href="../sales/editorder.aspx">Edit Order</a></li>';
   // htm += '<li><a href="../sales/orderconfirmation.aspx">Confirm Order</a></li>';
    htm+='</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-sitemap"></i> <label style="font-size:12px;">Warehouse</label><span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../inventory/warehouse.aspx"><label style="font-size:12px;">Warehouses</label></a></li>';
    htm += ' <li><a href="../inventory/warehousemanagement.aspx"><label style="font-size:12px;">Items Management</label></a></li>';
    htm += ' <li><a href="../inventory/stockTransfer.aspx"><label style="font-size:12px;">Stock Transfer</label></a></li>';
    htm += '</ul>';
    htm += '</li>';


    htm += '<li><a><i class="fa fa-cubes"></i> <label style="font-size:12px;">Inventory</label><span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../inventory/itembrand.aspx"><label style="font-size:12px;">Item Brand</label></a></li>';
    htm += '<li><a href="../inventory/itemcategory.aspx"><label style="font-size:12px;">Item Category</label></a></li>';
    htm += '<li><a href="../inventory/itemmaster.aspx"><label style="font-size:12px;">Item Master</label></a></li>';
    //htm += '<li><a href="../inventory/offers.aspx"><label style="font-size:12px;">Offer</label></a></li>';
    htm += '<li><a href="../inventory/sales_commission.aspx"><label style="font-size:12px;">Sales Commission</label></a></li>';
    htm+='</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-money"></i> <label style="font-size:12px;">Income</label><span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../incomExpense/income.aspx"><label style="font-size:12px;">New Entry</label></a></li>';
    htm += '<li><a href="../incomExpense/listIncomeEntries.aspx"><label style="font-size:12px;">Incomes</label></a></li>';
    htm += '</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-asterisk"></i> <label style="font-size:12px;">Expense</label><span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../incomExpense/expense.aspx"><label style="font-size:12px;">New Entry</label></a></li>';
    htm += '<li><a href="../incomExpense/listExpenseEntries.aspx"><label style="font-size:12px;">Expenses</label></a></li>';
   
    htm += '</ul>';
    htm += '</li>';

    htm += '<li><a><i class="fa fa-wrench"></i><label style="font-size:12px;">OP Center</label> <span class="fa fa-chevron-down"></span></a>';
    htm+='<ul class="nav child_menu">';
    htm += ' <li><a href="../opcenter/userTypes.aspx"><label style="font-size:12px;">User Types</label></a></li>';
    htm += '<li><a href="../opcenter/users.aspx"><label style="font-size:12px;">Users</label></a></li>';
    htm += '<li><a href="../opcenter/trackUsers.aspx"><label style="font-size:12px;">Route Mapping</label></a></li>';
    //htm += '<li><a href="../opcenter/leaveManagement.aspx"><label style="font-size:12px;">Leave Management</label></a></li>';
    
    htm+='</ul>';
    htm+='</li>';
    htm += '<li><a><i class="fa fa-gears"></i> <label style="font-size:12px;">Settings</label> <span class="fa fa-chevron-down"></span></a>';
    htm+='<ul class="nav child_menu">';
    htm += '<li><a href="../settings.aspx"><label style="font-size:12px;">Settings</label></a></li>';
    htm += '<li><a href="../inventory/manageTax.aspx"><label style="font-size:12px;">Manage Tax</label></a></li>';
    htm+='</ul>';
    htm+='</li>';
    htm += '<li><a><i class="fa fa-file-text-o"></i><label style="font-size:12px;">Reports</label><span class="fa fa-chevron-down"></span></a>';
    htm += '<ul class="nav child_menu">';
    htm += '<li><a href="../reports/SalesOverview.aspx"><label style="font-size:12px;">Sales Overview</label></a></li>';
    htm += '<li><a href="../reports/profitAndLossReport.aspx"><label style="font-size:12px;">Profit & Loss Report</label></a></li>';
    htm += '<li><a href="../reports/PandLreport.aspx"><label style="font-size:12px;">Transaction Report</label></a></li>';
    htm += '<li><a href="../reports/customerDetails.aspx"><label style="font-size:12px;">Customer Report</label></a></li>';
    htm += '<li><a href="../reports/salesreportsadvance.aspx"><label style="font-size:12px;">Advanced Sales Reports</label></a></li>';
    htm += '<li><a href="../reports/CustomerOutstandingReport.aspx"><label style="font-size:12px;">Customer Outstanding Report</label></a></li>';
    htm += '<li><a href="../reports/servicereports.aspx"><label style="font-size:12px;">Item Report</label></a></li>';
    htm += '<li><a href="../reports/productOverview.aspx"><label style="font-size:12px;">Product Overview</label></a></li>';
    //htm += '<li><a href="../reports/itemreportgraphical.aspx"><label style="font-size:12px;">Graphical Item Report</label></a></li>';
    htm += '<li><a href="../reports/salesReturnReportAdvnc.aspx"><label style="font-size:12px;">Sales Return Report</label></a></li>';
    htm += '<li><a href="../reports/creditNoteReport.aspx"><label style="font-size:12px;">Credit Note Report</label></a></li>';
    //htm += '<li><a href="../reports/SaleOrderCancelRejectRpt.aspx"><label style="font-size:12px;">Cancel Reject Report</label></a></li>';
    htm += '<li><a href="../reports/purchaseReports.aspx"><label style="font-size:12px;">Purchase Reports</label></a></li>';
    htm += '<li><a href="../reports/stockTransferReport.aspx"><label style="font-size:12px;">Stock Transfer Reports</label></a></li>';
    htm += '<li><a href="../reports/stockReport.aspx"><label style="font-size:12px;">Stock Report</label></a></li>';
    htm += '<li><a href="../reports/EditHistoryReport.aspx"><label style="font-size:12px;">Edit History Report</label></a></li>';
    htm+='</ul>';
    htm+='</li>';
    htm += '<li><a href="../login.aspx"><i class="fa fa-power-off"></i><label style="font-size:12px;">Log Out</label><span class="fa fa-chevron-down"></span></a></li>';
    htm+='</ul>';
    htm+='</div>';
    
    var menuParents = document.getElementsByClassName('main_menu_side hidden-print main_menu');
    if (menuParents.length > 0) {
        menuParents[0].innerHTML = htm;
    }

    var invoicedetails = document.getElementsByClassName('navbar nav_title');
    if (invoicedetails.length > 0) {
        invoicedetails[0].innerHTML = "<a href='../dashboard.aspx' class='site_title'><i class='fa fa-file-text'></i><span>Invoice Me</span></a>";
    }

    var sidemenudata = document.getElementsByClassName("profile clearfix");
    var username = $.cookie("invntrystaffFirstName") + " " + $.cookie("invntrystaffLastName");
    if (sidemenudata.length > 0) {
        sidemenudata[0].innerHTML = '<div class="profile_info"><span>Welcome,</span><h2>' + username + '</h2></div>';
    }

    var sidebarmenudata = document.getElementsByClassName('sidebar-footer hidden-small');
    if (sidebarmenudata.length > 0) {
        sidebarmenudata[0].innerHTML = '';
    }
 
    var topmenudata = document.getElementsByClassName('nav navbar-nav navbar-right');
    if (topmenudata.length > 0) {
        topmenudata[0].innerHTML = '';
        }
  
    //$(".drop").html(htm);
}

//onload events
    document.addEventListener("DOMContentLoaded", function (event) {
    //document.body.prepend('<div class="loader-overlay"><div class="loader loader-lg loader-blue-grey"></div></div>');
    var p = document.createElement("div");
    p.innerHTML = '<div class="loader-overlay" style="position:fixed"><div class="loader loader-lg loader-blue-grey"></div></div>';
    document.body.insertBefore(p, document.body.firstChild);
    setQueryParams();
    loadMenu();
    $(document).ajaxStart(function () {
        $(".loader-overlay").css("display", "flex");
    });
    $(document).ajaxStop(function () {
        $(".loader-overlay").hide();
    });

    
});


//$(document).ready(function () {

//});

//window.onload = function () {
//    loadMenu();
//};
// end onload events


//loader image starts here
function loading() {
    
  //NProgress.start();
 //document.getElementById('loading').style.display = '';
}
function Unloading() {
  //document.getElementById('loading').style.display = 'none';
 //NProgress.done();
}
//loader image ends here


//Start:Validations-----------------------------------------------------------------------

function checkEmail(email) {


    var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

    if (!filter.test(email)) {
        return false;
    }
}

function checkCharacter(inputtxt) {
    var letters = /^[A-Za-z]+$/;
    if (inputtxt.match(letters)) {

        return true;
    }
    else {

        return false;
    }
}


function checkNumeric(inputtxt) {
    var numbers = /^[0-9]+$/;
    if (inputtxt.match(numbers)) {

        return true;
    }
    else {
        return false;
    }
}

//Stop:Validations-----------------------------------------------------------------------




function setQueryParams() {
    queryParams = {};
    var queryStringArray = location.search.replace(/[`~!@#$^*()|+\?;:'",.<>\{\}\[\]\\\/]/gi, '').split("&");
    console.log(queryStringArray);
    for (var i = 0; i < queryStringArray.length; i++) {
        queryParams[queryStringArray[i].split("=")[0]] = queryStringArray[i].split("=")[1];
        
    }
}

function getQueryString(key) {
    console.log(queryParams);
    return queryParams[key];
}


//  function to get highlighted text-align
function getHighlightedValue(searchQuery, value) {
    console.log('value')
    console.log(value);
    //console.log(searchQuery);
    var regex = new RegExp('(' + searchQuery + ')', 'gi');
    var highlightedtext = "<a style='color:#4A2115;font-weight:bold' >" + searchQuery + "</a>";
    return value.toString().replace(regex, "<a style='color:#4A2115;' >$1</a>");
}


