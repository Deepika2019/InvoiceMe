<%@ Page Language="C#" AutoEventWireup="true" CodeFile="rootMapping.aspx.cs" Inherits="opcenter_rootMapping" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Route Mapping | Invoice Me</title>
     <script src="../js/common.js" type="text/javascript"></script>
    <script type="text/javascript" src="../js/jquery-2.0.3.js"></script>

    <script type="text/javascript" src="../js/jquery.cookie.js"></script>
   <link rel="stylesheet" href="../mobiscroll/css/jquery.mobile-1.1.0.min.css" />
    <script src="../mobiscroll/js/mobiscroll-2.0rc3.full.min.js" type="text/javascript"></script>
    <link href="../mobiscroll/css/mobiscroll-2.0rc3.full.min.css" rel="stylesheet" type="text/css" />
    <!-- Bootstrap -->
    <link href="../css/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="../css/bootstrap/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- NProgress -->
    <link href="../css/bootstrap/nprogress.css" rel="stylesheet" />
    <!-- Custom Theme Style -->
    <link href="../css/bootstrap/custom.min.css" rel="stylesheet" />
    <!--My Style-->
    <link href="../css/bootstrap/mystyle.css" rel="stylesheet" type="text/css" />
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBzZubZF8B7uY6Ra5KTOszsnbL7Zb6yIfs&libraries=places&callback=initAutocomplete"
        async defer></script>

    <script type="text/javascript">
        var map;
        var markers = [];
        var routes = [];
        var markerInfo;
        var lastOpenedInfoWindow;
        var colorCodes = ["#073b8e", "#70a6ff", "#db3939", "#9b6363", "#25dbb0", "#3c665c", "#505655", "#0da805", "#ead00b", "#d8cc72", "#ef7f00", "#e0a1a1"]
        var users = [];
        var assignedUsers = [];
        var unassignedUsers = [];
        var name;
        var custId;
        var assignedCount = 0;
        var unassignedCount = 0;
        var visitedCount = 0;
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!

        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
        var cur_dat = yyyy + '-' + mm + '-' + dd;

        $(document).ready(function () {

            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © Invoice Me");
            //alert(cur_dat);
            $('#txtDateFrom').scroller({
                preset: 'date',
                endYear: yyyy + 100,
                setText: 'Next',
                invalid: {},
                theme: 'ios',
                display: 'modal',
                mode: 'scroller',
                dateFormat: 'yy-mm-dd'
                // dateFormat: 'dd-MM-yy'
            });

            $('#txtDateFrom').val(cur_dat);
            getSalesPersons(-1);

        });

        // for showing search results of users
        function getSalesPersons(salesId) {
            assignedUsers = [];
            loading();
            //return;
            $.ajax({
                type: "POST",
                url: "rootMapping.aspx/getSalesPersons",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    //console.log(msg);
                    users = JSON.parse(msg.d);
                    //console.log(users);
                    // var htm = "<option value='0'>All</option>";
                    $.each(users, function (index, user) {
                        htm += "<option value='" + user.id + "'>" + user.name + "</option>";
                        //console.log(user);
                    });
                    $("#selSalesPerson").html(htm);
                    if (salesId != -1) {
                        $("#selSalesPerson").val(salesId);
                    }

                    getCustomersLocations();

                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }

        function getCustomersLocations() {
            assignedCount = 0;
            unassignedCount = 0;
            visitedCount = 0;
            var from_date = $("#txtDateFrom").val();
            var user_id = $("#selSalesPerson").val();
            var json_req = { user_id: user_id, from_date: from_date };
            loading();
            //return;
            $.ajax({
                type: "POST",
                url: "rootMapping.aspx/getCustomersLocations",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(json_req),
                success: function (msg) {
                    Unloading();
                    var cust_details = JSON.parse(msg.d);
                    for (var i = 0; i < markers.length; i++) {

                        markers[i].setMap(null);
                    }
                    if (cust_details == "") {
                        for (var i = 0; i < markers.length; i++) {

                            markers[i].setMap(null);
                        }
                    } else {
                        console.log(cust_details);

                        $.each(cust_details, function (i, customer) {
                            var status = -1;
                            //  alert(customer.cust_id + "*" + customer.assigndate + "*" + customer.rt_visit_status);
                            if (customer.assigndate == from_date) {
                                //  alert(customer.cust_id + "*" + customer.rt_visit_status);
                                status = customer.rt_visit_status;

                            }
                            else {
                                status = -1;

                            }
                            name = customer.cust_name;
                            custId = customer.cust_id;
                            // alert(custId);
                            showCustomerLocations(customer.cust_latitude, customer.cust_longitude, status);
                            //console.log(customer.cust_name);

                        });
                        $("#txtvisitedassgnCount").text(visitedCount);
                        $("#txtunassgnCount").text(unassignedCount);
                        $("#txtassgnCount").text(assignedCount);
                    }
                    //  showOrderLocations(loc_details);
                    //showCustomerLocations();
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });

        }

        function showCustomerLocations(latitude, longitude, status) {
            //console.log(name);
            if (latitude != 0 || longitude != 0) {
                var loc = { lat: parseFloat(latitude), lng: parseFloat(longitude) };
                var marker = addMarker(loc);
                // console.log(marker);
                var marker_letter = name.substring(0, 2);
                // alert(marker_letter);
                if (status == -1) {
                    unassignedCount = unassignedCount + 1;
                    //if (document.getElementById("chkboxassign").checked == true) {
                    //    marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|2e7c51|13|b|' + marker_letter + '');
                    //} else {

                    //}
                    marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|b2b2b2|13|b|' + marker_letter + '');
                    google.maps.event.addDomListener(marker, 'click', function () {
                        addInfoWindow(marker, info_content, info_id, status, marker_letter);
                    });
                } else if (status == 0) {
                    assignedCount = assignedCount + 1;
                    marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|ff4141|13|b|' + marker_letter + '');
                    google.maps.event.addDomListener(marker, 'click', function () {
                        addInfoWindow(marker, info_content, info_id, status, marker_letter);
                    });
                } else if (status == 1) {
                    visitedCount = visitedCount+1
                    marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|2e7c51|13|b|' + marker_letter + '');
                    google.maps.event.addDomListener(marker, 'click', function () {
                        addInfoWindow(marker, info_content, info_id, status, marker_letter);
                    });
                }
                
                var info_content = '' + name;
                var info_id = '' + custId;
                // alert(info_content);
                markers.push(marker);


                // addInfoWindow(marker);
            }
        }

        function getIcon(text, fillColor, textColor, outlineColor) {
            if (!text) text = '•'; //generic map dot
            var iconUrl = "http://chart.googleapis.com/chart?cht=d&chdp=mapsapi&chl=pin%27i\\%27[" + text + "%27-2%27f\\hv%27a\\]h\\]o\\" + fillColor + "%27fC\\" + textColor + "%27tC\\" + outlineColor + "%27eC\\Lauto%27f\\&ext=.png";
            return iconUrl;
        }

        function addMarker(loc) {
            //   console.log(loc);
            var marker = new google.maps.Marker({
                position: loc,
                map: map
            });
            return marker;
        }

        function addInfoWindow(marker, content, id, status, marker_letter) {
            var contentstring;
            if (status == -1) {
                contentstring = '<div id="formMap"><table><tr><label>' + content + '</label></tr><tr></tr><tr><td>Assign:</td><td></td><td></td><td><input type="checkbox" id="chkboxassign" checked=""/></td></tr></table></div>';
            } else if (status == 0) {
                contentstring = '<div id="formMap"><table><tr><label>' + content + '</label></tr><tr><td>Already Assigned:</td></tr></table><td><button type="button" onclick="deletefuncn(' + id + ')">Remove</button></div>';
            } else if (status == 1) {
                contentstring = '<div id="formMap"><table><tr><label>' + content + '</label></tr><tr><td>Already visited</td></tr></table></div>';
            }
            markerInfo = new google.maps.InfoWindow({
                content: contentstring
            });
            google.maps.event.addListener(marker, "click", function (e) {
                closeLastOpenedInfoWindo();
                lastOpenedInfoWindow = markerInfo;
                markerInfo.open(map, marker);
                //assigning section starts
                var checkbox = document.getElementById("chkboxassign");
                if (assignedUsers.indexOf(id) == -1) {
                    document.getElementById("chkboxassign").checked = false;
                } else {
                    document.getElementById("chkboxassign").checked = true;
                }
                google.maps.event.addDomListener(checkbox, "click", function () {
                    if (this.checked) {
                        if ($.inArray(id, assignedUsers) == -1) {
                            assignedUsers.push(id);
                        }
                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|FFFF42|13|b|' + marker_letter + '');

                        // alert(lat + "" + lng);
                    }
                    else {
                        deleteMe(id);
                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|b2b2b2|13|b|' + marker_letter + '');
                    }
                });
                //assigning section ends

            });
            console.log(assignedUsers);
        }
        function deleteMe(me) {
            var i = assignedUsers.length;
            while (i--) if (assignedUsers[i] === me) assignedUsers.splice(i, 1);
        }
        function initAutocomplete() {
            var latitude = 25.276987;
            var longitude = 55.296249;
            //console.log($.cookie("cookie_Latitude"));
            //if ($.cookie("cookie_Latitude") != null) {
            //    latitude = parseFloat($.cookie("cookie_Latitude"));
            //}
            //if ($.cookie("cookie_Longitude") != null) {
            //    longitude = parseFloat($.cookie("cookie_Longitude"));
            //}
            //alert(latitude + "--" + longitude);
            map = new google.maps.Map(document.getElementById('mapContainer'), {
                center: { lat: latitude, lng: longitude },
                zoom: 3,
                mapTypeId: 'roadmap'
            });

            // Create the search box and link it to the UI element.
            var input = document.getElementById('pac-input');
            var searchBox = new google.maps.places.SearchBox(input);
            map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

            // Bias the SearchBox results towards current map's viewport.
            map.addListener('bounds_changed', function () {
                searchBox.setBounds(map.getBounds());
            });

            var markers = [];
            // Listen for the event fired when the user selects a prediction and retrieve
            // more details for that place.
            searchBox.addListener('places_changed', function () {
                var places = searchBox.getPlaces();

                if (places.length == 0) {
                    return;
                }

                // Clear out the old markers.
                markers.forEach(function (marker) {
                    marker.setMap(null);
                });
                markers = [];

                // For each place, get the icon, name and location.
                var bounds = new google.maps.LatLngBounds();
                places.forEach(function (place) {
                    if (!place.geometry) {
                        console.log("Returned place contains no geometry");
                        return;
                    }
                    var icon = {
                        url: place.icon,
                        size: new google.maps.Size(71, 71),
                        origin: new google.maps.Point(0, 0),
                        anchor: new google.maps.Point(17, 34),
                        scaledSize: new google.maps.Size(25, 25)
                    };

                    var marker = new google.maps.Marker({
                        map: map,
                        icon: icon,
                        title: place.name,
                        position: place.geometry.location,
                        draggable: true
                    });

                    google.maps.event.addListener(marker, 'dragend', function () {
                        window.parent.getLatLongAddressFromGoogle(marker.getPosition().lat(), marker.getPosition().lng());
                    });

                    // Create a marker for each place.
                    markers.push(marker);




                    if (place.geometry.viewport) {
                        // Only geocodes have viewport.
                        bounds.union(place.geometry.viewport);
                        getLatLongAddressFromGoogle(marker.getPosition().lat(), marker.getPosition().lng());
                    } else {
                        bounds.extend(place.geometry.location);
                    }
                });
                map.fitBounds(bounds);
            });
        }

        //function for locate the location
        function getLatLongAddressFromGoogle(lat, long) {
            latitude = lat;
            longitude = long;
            if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari, SeaMonkey
                xmlhttp = new XMLHttpRequest();
            }
            else {// code for IE6, IE5
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            xmlhttp.onreadystatechange = function () {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                    // console.log(xmlhttp.responseText);
                    var mapData = JSON.parse(xmlhttp.responseText);
                }
            }
            xmlhttp.open("GET", "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + "," + long + "&sensor=true", false);
            xmlhttp.send();
        }

        function closeLastOpenedInfoWindo() {
            if (lastOpenedInfoWindow) {
                lastOpenedInfoWindow.close();
            }
        }

        function saveAssignedData() {
         //   alert(assignedUsers.length);
            if (assignedUsers.length == 0) {
                alert("select any customer");
                return;
            }
            loading();
            //return;
            $.ajax({
                type: "POST",
                url: "rootMapping.aspx/saveAssignedData",
                data: "{'userId':'" + $("#selSalesPerson").val() + "','assign_date':'" + $("#txtDateFrom").val() + "','customers':" + JSON.stringify(assignedUsers) + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    Unloading();
                    if (msg.d == "Y") {
                        alert("Assigned successfully");
                        getSalesPersons($("#selSalesPerson").val());
                    }
                    // location.reload();
                    //console.log(msg.d);
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem..!");
                }
            });
            //  alert($("#assignDate").val());
        }

        function deletefuncn(cust_id) {
            var from_date = $("#txtDateFrom").val();
            var user_id = $("#selSalesPerson").val();
            var json_req = { user_id: user_id, from_date: from_date, cust_id: cust_id };
            var confirmVal = confirm("Do you want to cancel the assigning");
            if (confirmVal == true) {
                loading();
                //return;
                $.ajax({
                    type: "POST",
                    url: "rootMapping.aspx/deletefuncn",
                    data: JSON.stringify(json_req),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        Unloading();
                        if (msg.d == "Y") {
                            alert("Unassigned successfully");
                            getSalesPersons($("#selSalesPerson").val());
                        } else if (msg.d == "N") {
                            alert("can not be assigned");
                        }
                        // location.reload();
                        //console.log(msg.d);
                    },
                    error: function (xhr, status) {
                        Unloading();
                        alert("Internet Problem..!");
                    }
                });
            }
            else {
                return false;
            }
            // alert(id);
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
                            <a href="../index.html" class="site_title">
                                <!--<i class="fa fa-paw"></i>-->
                                <span>Invoice</span></a>
                        </div>

                        <div class="clearfix"></div>

                        <!-- menu profile quick info -->
                        <div class="profile clearfix">
                            <div class="profile_pic">
                                <img src="../images/img.jpg" alt="..." class="img-circle profile_img">
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
                                    <label style="font-weight: bold; font-size: 16px;">Route Mapping</label>
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
                        </div>
                        <div class="clearfix"></div>
                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">

                                    <div class="x_content">

                                        <form class="form-horizontal form-label-left input_mask">

                                            <div class="col-md-4 col-sm-6 col-xs-12 form-group has-feedback">
                                                <select id="selSalesPerson" class="form-control" style="text-indent: 25px;" onchange="getCustomersLocations();">
                                                </select>
                                                <span class="fa fa-search form-control-feedback left" aria-hidden="true"></span>
                                            </div>
                                            <div class="col-md-2 col-sm-6 col-xs-6 form-group has-feedback">
                                                <input type="text" class="form-control" id="txtDateFrom" onchange="getCustomersLocations();">
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="col-md-11 col-sm-12 col-xs-12">
                                        <span class="fa fa-map-marker" style="font-size: 26px; color: #a6a6a5;"></span><span style="margin-right: 15px">Unassigned(<label id="txtunassgnCount"></label>)</span>

                                        <span class="fa fa-map-marker" style="font-size: 26px; color: #ffe401;"></span><span style="margin-right: 15px">Selected</span>
                                        <span class="fa fa-map-marker" style="font-size: 26px; color: #cf1300;"></span><span style="margin-right: 15px">Assigned(<label id="txtassgnCount"></label>)</span>
                                        <span class="fa fa-map-marker" style="font-size: 26px; color: #26a200;"></span><span style="margin-right: 15px">Visited(<label id="txtvisitedassgnCount"></label>)</span>
                                    </div>
                                    <div class="col-md-1 col-sm-12 col-xs-12">
                                        <div class="btn btn-success mybtnstyl" onclick="saveAssignedData();">Update</div>
                                    </div>
                                </div>

                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <input id="pac-input" class="controls" type="text" placeholder="Search Box">
                                    <div class="col-md-12 col-sm-12 col-xs-12" id="mapContainer" style="height: 550px;">
                                    </div>

                                </div>
                                <input id="hdnLat" type="hidden" />
                                <input id="hdnLong" type="hidden" />
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

    <!-- Bootstrap -->
    <script src="../js/bootstrap/bootstrap.min.js"></script>
    <!-- FastClick -->
    <script src="../js/bootstrap/fastclick.js"></script>
    <!-- NProgress -->
    <script src="../js/bootstrap/nprogress.js"></script>
    <!-- iCheck -->
    <script src="../js/bootstrap/icheck.min.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="../js/bootstrap/custom.min.js"></script>
    <script src="../js/bootbox.min.js"></script>
</body>
</html>
