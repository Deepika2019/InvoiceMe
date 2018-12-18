<%@ Page Language="C#" AutoEventWireup="true" CodeFile="trackUsers.aspx.cs" Inherits="opcenter_trackUsers" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
    <title>Track Users | Invoice Me</title>
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
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBzZubZF8B7uY6Ra5KTOszsnbL7Zb6yIfs&libraries=places&callback=initialize"
        async defer></script>
    <%--<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=initialize"></script>--%>

    <script type="text/javascript">
        var map;
        var markers = [];
        var routes = [];
        var markerInfo;
        var cus_infowindow;
        var colorCodes = ["#073b8e", "#70a6ff", "#db3939", "#9b6363", "#25dbb0", "#3c665c", "#505655", "#0da805", "#ead00b", "#d8cc72", "#ef7f00", "#e0a1a1"]
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
            $("#txtDateFrom").val(cur_dat);
            $("#txtDateTo").val(cur_dat);
            var BranchId = $.cookie("invntrystaffBranchId");
            var CountryId = $.cookie("invntrystaffCountryId");
            $('.footerDivContent').html("Copyright " + new Date().getFullYear() + " © Invoice Me");
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
            $('#txtDateTo').scroller({
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
            loadTrackingDetails();
            //   resetFilter();
        });



        function loadTrackingDetails() {
            var filter = {
                dis_id: parseInt($("#selDistricts").val()),
                location_id: parseInt($("#SelLocations").val()),
                user_id: parseInt($("#selUsers").val()),
                state_id: parseInt($("#selState").val()),
                dateFrom: $("#txtDateFrom").val(),
                dateTo: $("#txtDateTo").val()
            }
            clearMarkers();
            $("#labelFilterParams").text("");
            $.ajax({
                type: "POST",
                url: "trackUsers.aspx/getTrackingDetails",
                data: JSON.stringify(filter),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var filterParams = "Date : " + filter.dateFrom.replace(/-/g, '/') + "-" + filter.dateTo.replace(/-/g, '/');
                    if (filter.user_id != 0) {
                        filterParams += ", User : " + $("#selUsers option:selected").text();
                    }
                    if (filter.location_id != 0) {
                        filterParams += ", Location : " + $("#SelLocations option:selected").text();
                    }
                    if (filter.dis_id != 0) {
                        filterParams += ", District : " + $("#selDistricts option:selected").text();
                    } if (filter.state_id != 0) {
                        filterParams += ", State : " + $("#selState option:selected").text();
                    }
                    $("#labelFilterParams").text(filterParams);
                    var trackObject = JSON.parse(msg.d);
                    console.log(JSON.parse(msg.d));

                    var remainCount = 0;
                    var orderCount = 0;
                    var VisitCount = 0;
                    var select_marker_type = $("#select_marker_type").val();

                    

                        if (select_marker_type == "3" || select_marker_type == "-1") {
                        $.each(trackObject.remain_data, function (i, remain) {
                            remainCount = remainCount + 1;
                            var myLatlng = new google.maps.LatLng(remain.latitude, remain.longitude);
                            var marker = new google.maps.Marker({
                                position: myLatlng,
                                map: map
                            });

                            (function (marker, data) {

                                // marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.75|0|BDB7B5|10|b|R');
                                marker.setIcon(' http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|B4B4B2');

                                cus_infowindow == undefined;
                                cus_infowindow = new google.maps.InfoWindow({});
                                marker.addListener('click', function () {
                                    var content = '<div style="overflow: auto;">';
                                    //  alert(data.name);
                                    content += '<b>' + data.name + '</b><br>';
                                    content += '<i>' + data.address + '</i><br>';
                                    content += '<i>' + data.cust_city + '</i><br>';
                                    content += '<a style="color: blue;text-decoration: underline;" href="/managecustomers.aspx?cusId=' + data.cust_id + '" target="_blank">View customer</a>';
                                    remainCount++;
                                    content += '</div>';
                                    cus_infowindow.setContent(content);
                                    //' + data.date + '
                                    cus_infowindow.open(map, marker);
                                });
                            })(marker, remain);
                            markers.push(marker);
                        })
                    }

                    
                        if (select_marker_type == "1" || select_marker_type == "0" || select_marker_type == "-1") {

                            $.each(trackObject.order_data, function (i, ord) {
                                orderCount = orderCount + 1;
                                var myLatlng = new google.maps.LatLng(ord.latitude, ord.longitude);
                                var marker = new google.maps.Marker({
                                    position: myLatlng,
                                    map: map
                                });

                                (function (marker, data) {
                                    if (orderCount == trackObject.order_data.length) {
                                        // alert(VisitCount);
                                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|008000|10|b|O');

                                    } else {
                                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.75|0|418AE7|10|b|' + orderCount + '');
                                    }
                                   

                                    cus_infowindow == undefined;
                                    cus_infowindow = new google.maps.InfoWindow({});
                                    marker.addListener('click', function () {
                                        var content = '<div style="overflow: auto;">';
                                        //  alert(data.name);
                                        content += '<b>' + data.name + '</b><br>';
                                        content += '<i>' + data.address + '</i><br>';
                                        content += '<i>' + data.cust_city + '</i><br>';
                                        content += 'Order Date : ' + data.checkDate + '<br>';
                                        content += 'Order Count : ' + data.custCount + '<br>';
                                        content += 'Salesman : ' + data.user + '';
                                        content += '<a style="color: blue;text-decoration: underline;" href="/managecustomers.aspx?cusId=' + data.cust_id + '" target="_blank">View customer</a>';
                                        content += '</div>';
                                        cus_infowindow.setContent(content);

                                        //' + data.date + '
                                        cus_infowindow.open(map, marker);
                                    });
                                })(marker, ord);
                                markers.push(marker);
                            })
                        }

                        if (select_marker_type == "2" || select_marker_type == "0" || select_marker_type == "-1") {

                            $.each(trackObject.checkin_data, function (i, checkIn) {
                                VisitCount = VisitCount + 1;
                                var myLatlng = new google.maps.LatLng(checkIn.latitude, checkIn.longitude);
                                var marker = new google.maps.Marker({
                                    position: myLatlng,
                                    map: map
                                });
                             //   alert(trackObject.checkin_data.length);
                                (function (marker, data) {
                                    if (VisitCount == trackObject.checkin_data.length) {
                                       // alert(VisitCount);
                                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=1|0|008000|10|b|V');

                                    } else {
                                        marker.setIcon('https://chart.googleapis.com/chart?chst=d_map_spin&chld=.75|0|EF7714|10|b|' + VisitCount + '');
                                    }
                                   

                                    cus_infowindow == undefined;
                                    cus_infowindow = new google.maps.InfoWindow({});
                                    marker.addListener('click', function () {
                                        var content = '<div style="overflow: auto;">';
                                        //  alert(data.name);
                                        content += '<b>' + data.name + '</b><br>';
                                        content += '<i>' + data.address + '</i><br>';
                                        content += '<i>' + data.cust_city + '</i><br>';
                                        
                                        content += 'Checked Date : ' + data.checkDate + '<br>';
                                        content += 'Visited Count : ' + data.chkCount + '<br>';
                                        content += 'Salesman : ' + data.user + '';
                                        content += '<a style="color: blue;text-decoration: underline;" href="/managecustomers.aspx?cusId=' + data.cust_id + '" target="_blank">View customer</a>';
                                        content += '</div>';
                                        cus_infowindow.setContent(content);
                                        //' + data.date + '
                                        cus_infowindow.open(map, marker);
                                    });
                                })(marker, checkIn);
                                markers.push(marker);
                            })
                        }


                    
                    
                    $("#lblRemainCount").text(remainCount);
                    $("#lblVisitCount").text(VisitCount+orderCount);
                    $("#lblOrderCount").text(orderCount);

                   
                },
                error: function (xhr, status) {
                    Unloading();
                    alert("Internet Problem");
                }
            });
        }



        // for loading google map api
        function loadMapsApi() {
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.src = 'http://maps.googleapis.com/maps/api/js?key=AIzaSyCWvHWrDDwowXKHTPzORjR5N5u_JRfO0o8&sensor=false';
            script.async = true;
            document.body.appendChild(script);
        }

        //map initialization, passing parameter:  id of the container where map is to be loaded
        function initialize() {
            var mapProp = {
                center: new google.maps.LatLng(9.9312, 76.2673),
                zoom: 8,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            map = new google.maps.Map(document.getElementById('mapContainer'), mapProp);
            //var latitude = 25.276987;
            //var longitude = 55.296249;
            //map = new google.maps.Map(document.getElementById('mapContainer'), {
            //    center: { lat: latitude, lng: longitude },
            //    zoom: 3,
            //    mapTypeId: 'roadmap'
            //});
        }

        // function to clear markers
        function clearMarkers() {
            $.each(markers, function (i, marker) {
                marker.setMap(null);
            });
        }
        //showing markers on map


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
                                    <label style="font-weight: bold; font-size: 16px;">Track Users</label>
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
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <strong>Filter</strong>
                                        <ul class="nav navbar-right panel_toolbox">
                                            <li>
                                                <a class="collapse-link"><i class="fa fa-chevron-up"></i></a>
                                            </li>
                                        </ul>

                                    </div>
                                    <div class="x_content">

                                        <form class="form-horizontal form-label-left input_mask">
                                            <div class="row">

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <label class="control-label" for="selUsers">
                                                        User
                                                    </label>
                                                    <select id="selUsers" runat="server" class="form-control border-input" style="background-color: #fff; font-size: 17px; color: #808080; margin-bottom: 1%;" onchange="loadTrackingDetails();">
                                                        <option value="0" selected>--User--</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <label class="control-label" for="">
                                                        Location
                                                    </label>
                                                    <select id="SelLocations" runat="server" class="form-control border-input" style="background-color: #fff; font-size: 17px; color: #808080; margin-bottom: 1%;" onchange="loadTrackingDetails();">
                                                        <option value="0" selected>--Location--</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <label class="control-label" for="">
                                                        District
                                                    </label>
                                                    <select id="selDistricts" runat="server" class="form-control border-input" style="background-color: #fff; font-size: 17px; color: #808080; margin-bottom: 1%;" onchange="loadTrackingDetails();">
                                                        <option value="0" selected>--District--</option>
                                                    </select>
                                                </div>

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group">

                                                    <label class="control-label" for="selState">
                                                        State
                                                    </label>
                                                    <select id="selState" runat="server" class="form-control border-input" style="background-color: #fff; font-size: 17px; color: #808080; margin-bottom: 1%;" onchange="loadTrackingDetails();">
                                                        <option value="0" selected>--State--</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <label class="control-label" for="txtDateFrom">
                                                        Date From
                                                    </label>
                                                    <input type="text" id="txtDateFrom" class="form-control" />
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                    <label class="control-label" for="txtDateTo">
                                                        Date To
                                                    </label>
                                                    <input type="text" id="txtDateTo" class="form-control" />
                                                </div>

                                            </div>
                                            <div class="row">

                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback" style="float:left">
                                                    <label class="control-label" for="">
                                                        Show
                                                    </label>
                                                    <select id="select_marker_type" runat="server" class="form-control border-input" style="background-color: #fff; font-size: 17px; color: #808080; margin-bottom: 1%;" onchange="loadTrackingDetails();">
                                                        <option value="-1">All</option>
                                                        <option value="0" selected>Orders & Check-Ins</option>
                                                        <option value="1" >Orders Only</option>
                                                       <%-- <option value="2" >Check-Ins Only</option>--%>
                                                        <option value="3" >Inactive Cutomers</option>
                                                    </select>
                                                    
                                                </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                      <span class="fa fa-map-marker" style="font-size: 26px; color: #a6a6a5; margin-left: 15px;"></span><span style="margin-right: 15px">No activity(<label id="lblRemainCount">0</label>)</span>
                                              </div>
                                         <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                                <span class="fa fa-map-marker" style="font-size: 26px; color: #EF7714;"></span><span style="margin-right: 15px">Visited(<label id="lblVisitCount">0</label>)</span>
                                             </div>
                                                <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                               
                                                     <span class="fa fa-map-marker" style="font-size: 26px; color: #418AE7;"></span><span style="margin-right: 15px">Order placed(<label id="lblOrderCount">0</label>)</span>

                                                </div>
                                                               <div class="col-md-2 col-sm-6 col-xs-12 form-group has-feedback">
                                               
                                                     <span class="fa fa-map-marker" style="font-size: 26px; color: #008000;"></span><span style="margin-right: 15px">Last Visited</span>

                                                </div>
                                                <div onclick="resetFilter()" class="btn btn-danger pull-right" style="margin-top:20px;">Reset</div>
                                                <div onclick="loadTrackingDetails()" class="btn btn-primary pull-right" style="margin-top:20px;">Search</div>
                                            </div>

                                       
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>


                        <div class="row">
                            <div class="col-md-12 col-sm-12 col-xs-12">
                                <div class="x_panel">
                                    <div class="x_title" style="margin-bottom: 0px;">
                                        <label>Filter parameters :-</label>
                                        <i>
                                            <label id="labelFilterParams"></label>
                                        </i>
                                    </div>
                                    <div class="x_content">
                                        <div class="col-md-12 col-sm-12 col-xs-12" id="mapContainer" style="height: 500px;">
                                        </div>
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
