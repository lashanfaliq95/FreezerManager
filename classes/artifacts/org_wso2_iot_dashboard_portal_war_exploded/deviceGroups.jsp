<%--Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.--%>

<%--WSO2 Inc. licenses this file to you under the Apache License,--%>
<%--Version 2.0 (the "License"); you may not use this file except--%>
<%--in compliance with the License.--%>
<%--You may obtain a copy of the License at--%>

<%--http://www.apache.org/licenses/LICENSE-2.0--%>

<%--Unless required by applicable law or agreed to in writing,--%>
<%--software distributed under the License is distributed on an--%>
<%--"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY--%>
<%--KIND, either express or implied. See the License for the--%>
<%--specific language governing permissions and limitations--%>
<%--under the License.--%>
<%@include file="includes/authenticate.jsp" %>
<%
    String id = request.getParameter("id");
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Device Groups</title>
    <link href="css/bootstrap.min.css" rel="stylesheet"/>
    <link href="css/material-icons.css" rel="stylesheet"/>
    <link href="css/material-dashboard.css" rel="stylesheet"/>
    <link href="css/font-awesome.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.2.0/dist/leaflet.css"
          integrity="sha512-M2wvCLH6DSRazYeZRIm1JnYyh22purTM+FDB5CsyxtQJYeKq83arPe5wgbNmcFXGqiSH2XR8dT/fJISVA1r/zQ=="
          crossorigin=""/>
    <link href="css/MarkerCluster.css" rel="stylesheet">
    <link href="css/MarkerCluster.Default.css" rel="stylesheet">
    <link href="css/updates.css" rel="stylesheet"/>

</head>
<body>
<div class="wrapper">
    <div class="sidebar" data-color="blue" data-image="images/sidebar-1.jpg" style="width: 270px">
        <div class="logo">
            <a href="./devices.jsp" class="simple-text">
                <strong>Device</strong>Portal
            </a>
        </div>

    </div>
    <div class="main-panel">
        <div class="content" style="margin-top:5px ; padding: 0 0">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-md-12">
                        <div class="card card-plain">
                            <div class="card-header" data-background-color="blue">
                                <%@ include file="pages/deviceGroup-page-segments/navBar.jsp" %>
                                <table style="width:100%">
                                    <tr>
                                        <th>
                                            <h4 class="title" style="font-size: 30px; padding-left: 10px;">Group Summary</h4>
                                        </th>
                                    </tr>
                                </table>
                            </div>
                            <div class="tab-content">
                                <div id="groupView" class="tab-pane fade in active ">
                                    <%@ include file="pages/deviceGroup-page-segments/groupSummary.jsp" %>
                                </div>
                                <div id="tableview" class="tab-pane fade " >
                                    <%@ include file="pages/deviceGroup-page-segments/tableTab.jsp" %>
                                </div>
                                <div id="mapView" class="tab-pane fade  ">
                                    <%@ include file="pages/deviceGroup-page-segments/mapTab.jsp" %>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
</body>
<script src="js/jquery.min.js" type="text/javascript"></script>
<script src="js/bootstrap.min.js" type="text/javascript"></script>
<script src="js/material.min.js" type="text/javascript"></script>
<script src="js/nouislider.min.js" type="text/javascript"></script>
<script src="js/bootstrap-datepicker.js" type="text/javascript"></script>
<script src="js/material-kit.js" type="text/javascript"></script>
<script src="js/bootstrap-notify.js" type="text/javascript"></script>
<script src="js/material-dashboard.js" type="text/javascript"></script>
<script src="js/chartist.min.js"></script>
<script type="text/javascript" src="js/libs/jquery.bootpag.js"></script>
<script src="js/moment.min.js" type="text/javascript"></script>
<script src="js/daterangepicker.js" type="text/javascript"></script>
<script src="https://unpkg.com/leaflet@1.2.0/dist/leaflet.js"
        integrity="sha512-lInM/apFSqyy1o6s89K4iQUKg6ppXEgsVxT35HbzUupEVRh2Eu9Wdl4tHj7dZO0s1uvplcYGmt3498TtHq+log=="
        crossorigin=""></script>
<script src="js/leaflet.markercluster.js" type="text/javascript"></script>

<script type="text/javascript">

    var deviceType="FreezerManager";

    var typepParameter1="temperature";
    var displayName1="Temperature";
    var units1="&#8451";

    var typeParameter2="humidity";
    var displayName2="Humidity";
    var units2="%";

    var typeParameter3="powerConsumption";
    var displayName3="Power Consumption";
    var units3="<Strong>kJ<Strong>";


    document.getElementById("prameter1").innerHTML = displayName1;
    document.getElementById("prameter2").innerHTML = displayName2;
    document.getElementById("prameter3").innerHTML = displayName3;

    //fixed the issue with map not rendering in tabbed view and pop up model
    $("a[href='#mapView']").on('shown.bs.tab', function (e) {
        mymap.invalidateSize();
        //hide the search bar on map view
        $('#hide').hide();
    });

    $('#newDeviceModal').on('show.bs.modal', function () {
        setTimeout(function () {
            map.invalidateSize();
        }, 200);
    });
    $("a[href='#tableview']").on('shown.bs.tab', function (e) {
        //show the search bar on table view
        $('#hide').show();
        $(e.currentTarget.hash).find('.ct-chart').each(function (el, tab) {
            tab.__chartist__.update();
        });
    });

    $(document).ready(function () {
        getAllDevices();//add all devices to map



    });

    function getAllDevices() {
        var success = function (data) {
            devices = JSON.parse(data).devices;
            deviceCount = JSON.parse(data).count;//find the number of devices
            //used bootpag library to implement the pagination
            $('#nav').bootpag({
                total: Math.ceil(deviceCount / 10),
                page: 1,
                maxVisible: 6,
                href: "#pro-page-{{number}}",
                leaps: false,
                next: 'next',
                prev: null
            }).on('page', function (event, num) {
                var offset = (num - 1) * 10;
                var limit = num * 10;
                getDevices(offset, limit);
            });

            var i;

            for (i = 0; i < devices.length; i++) {
                if("<%=id%>" === devices[i].properties[0].value){//check if the device is in the specific group
                    addToMap(devices[i], i, devices[i].properties[1].value, devices[i].properties[2].value);
                    devicesTemp.push(devices[i]);
                    if(devices[i].enrolmentInfo.status==='ACTIVE'){//active devices
                        activeDevices.push(devices[i].deviceIdentifier);
                    }else{
                        inactiveDevices.push(devices[i].deviceIdentifier);
                    }

                }

            }

            $('#navActive').bootpag({
                total: Math.ceil(activeDevices.length/5),
                page: 1,
                maxVisible: 10,
                href: "#pro-page-{{number}}",
                leaps: false,
                next: 'next',
                prev: null
            }).on('page', function (event, num) {
               $('#active-devices tr').hide().slice((num-1)*10, ((num-1)*10)+10).css('display','table-row');
            });

            $('#navInactive').bootpag({
                total: Math.ceil(inactiveDevices.length/5),
                page: 1,
                maxVisible: 10,
                href: "#pro-page-{{number}}",
                leaps: false,
                next: 'next',
                prev: null
            }).on('page', function (event, num) {
                $('#inactive-devices tr').hide().slice((num-1)*10, ((num-1)*10)+10).css('display','table-row');
            });

            getDevices(0, 10);//load first page
        };
        $.ajax({
            type: "POST",
            url: "invoker/execute",
            data: {"uri": "/devices/?type="+deviceType+"&requireDeviceInfo=true&offset=0&limit=100", "method": "get"},
            success: success
        });
    }

    function getDevices(offset, limit) {
        var getsuccess = function (data) {
            deviceCount = JSON.parse(data).count;//find the number of devices
            var devicesListing = $('#devices-listing');
            var activeDevicesListing=$('#active-devices');
            var inactiveDevicesListing=$('#inactive-devices');
            var myRow;

            if (activeDevices && activeDevices.length > 0) {
                activeDevicesListing.find('tbody').empty();
            } else {
                myRow = "<tr><td colspan=\"6\" style=\"padding-top: 30px;\"><strong>No Devices Found</strong></td></tr>";
                activeDevicesListing.find('tbody').replaceWith(myRow);
            }

            if (inactiveDevices && inactiveDevices.length > 0) {
                inactiveDevicesListing.find('tbody').empty();

            } else {
                myRow = "<tr><td colspan=\"6\" style=\"padding-top: 30px;\"><strong>No Devices Found</strong></td></tr>";
                inactiveDevicesListing.find('tbody').replaceWith(myRow);
            }

            if (devicesTemp && devicesTemp.length > 0) {
                devicesListing.find('tbody').empty();
                getDevice(devicesTemp[0], 0, devicesTemp[0].properties[0].value, devicesTemp[0].properties[1].value);
            } else {
               myRow = "<tr><td colspan=\"6\" style=\"padding-top: 30px;\"><strong>No Devices Found</strong></td></tr>";
                devicesListing.find('tbody').replaceWith(myRow);
            }




        };
        $.ajax({
            type: "POST",
            url: "invoker/execute",
            data: {
                "uri": "/devices/?type="+deviceType+"&requireDeviceInfo=true&offset=" + offset + "&limit=" + limit,
                "method": "get"
            },
            success: getsuccess
        });
    }
    var sumTemp=0;
    var sumHumid=0;
    var sumPower=0;
    var averageTemp;
    var averageHumid;
    var averagePower;

    function getDevice(dev, index, lat, long) {
        var devicesListing = $('#devices-listing');
        var activeDevicesListing=$('#active-devices');
        var inactiveDevicesListing=$('#inactive-devices');

        var lastKnownSuccess = function (data) {
            var records = JSON.parse(data);
            var record = JSON.parse(data).records[0];

            var parameterOne = null;
            var parameterTwo = null;
            var parameterThree = null;

            if (record) {
                parameterOne = record.values[typepParameter1];
                parameterTwo = record.values[typeParameter2];
                parameterThree = record.values[typeParameter3];
                sumTemp += parameterOne;
                sumHumid += parameterTwo;
                sumPower += parameterThree;
            }

            var myRow;

            if (parameterOne == null || parameterTwo == null || parameterThree == null) {
                myRow = "<tr onclick=\"window.location.href='details.jsp?id=" + dev.deviceIdentifier + "'\" style='cursor: pointer'><a href='#" + dev.deviceIdentifier + "'><td><div class=\"card card-stats\" style='width: 75%'> <div class=\"card-header\" data-background-color=\"purple\"> <i class=\"material-icons\">dock</i> </div> <div class=\"card-content\"> <p class=\"category\">Device</p> <h3 class=\"title\" >" + dev.name + "</h3> </div> </div>\n"
                    + "</td><td>"
                    + "<div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"red\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalParameterOneChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\">N/A</h4><p class=\"category\" id=\"historicalTempAlert" + dev.deviceIdentifier + "\"></div></div>\n</td><td><div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"orange\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalparameterTwoChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\">N/A</h4><p class=\"category\" id=\"historicalHumidAlert" + dev.deviceIdentifier + "\"></div></div>\n</td><td>"
                    + "<div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"green\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalparameterThreeChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\">N/A</h4><p class=\"category\" id=\"historicalparameterThreeAlert" + dev.deviceIdentifier + "\"></div></div>\n</td>"
                    + "</a></tr>";

            }
            else {
                myRow = "<tr onclick=\"window.location.href='details.jsp?id=" + dev.deviceIdentifier + "'\" style='cursor: pointer'><a href='#" + dev.deviceIdentifier + "'><td><div class=\"card card-stats\" style='width: 75%'> <div class=\"card-header\" data-background-color=\"purple\"> <i class=\"material-icons\">dock</i> </div> <div class=\"card-content\"> <p class=\"category\">Device</p> <h3 class=\"title\" >" + dev.name + "</h3> </div> </div>\n"
                    + "</td><td>"
                    + "<div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"red\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalParameterOneChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\"> " + (parameterOne)+ (units1) + "</h4><p class=\"category\" id=\"historicalTempAlert" + dev.deviceIdentifier + "\"></div></div>\n</td><td><div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"orange\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalparameterTwoChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\"> " + (parameterTwo) +(units2)+ "</h4><p class=\"category\" id=\"historicalHumidAlert" + dev.deviceIdentifier + "\"></div></div>\n</td><td>"
                    + "<div class=\"card\"><div class=\"card-header card-chart\" data-background-color=\"green\" style=\"height: 90px;min-height: unset;\"><div class=\"ct-chart\" id=\"HistoricalparameterThreeChart" + dev.deviceIdentifier + "\"></div></div><div class=\"card-content\"><h4 class=\"title\"> " + (parameterThree)+ (units3)+ "</h4><p class=\"category\" id=\"historicalparameterThreeAlert" + dev.deviceIdentifier + "\"></div></div>\n</td>"
                    + "</a></tr>";

            }
            rows.push(myRow);
            devicesListing.find('tbody').append(myRow);
            initDashboardPageCharts(dev.deviceIdentifier);
            redrawGraphs(records, dev.deviceIdentifier);

            if(($.inArray(dev.deviceIdentifier, activeDevices)) !== -1){//if device is active
                myRow="<tr><td>"+dev.deviceIdentifier+"</td><td>"+parameterOne+"</td><td>"+parameterTwo+"</td><td>"+parameterThree+"</td><tr>";
                activeDevicesListing.find('tbody').append(myRow)
            }

            if(($.inArray(dev.deviceIdentifier, inactiveDevices)) !== -1){//if device is active
                myRow="<tr><td>"+dev.deviceIdentifier+"</td><td>"+parameterOne+"</td><td>"+parameterTwo+"</td><td>"+parameterThree+"</td><tr>";
                inactiveDevicesListing.find('tbody').append(myRow)
            }
            $('#active-devices tr').slice(10, activeDevices.length*2).hide();
            $('#inactive-devices tr').slice(10,inactiveDevices.length*2).hide();

            if(index===(devicesTemp.length-1)){

                averageTemp= sumTemp/ devicesTemp.length;
                averageHumid= sumHumid/ devicesTemp.length;
                averagePower= sumPower/ devicesTemp.length;


                $("#card1").html("<span class=\"text-success\">" + averageTemp.toFixed(2) + " </span> "+units1);
                $("#card2").html("<span class=\"text-success\">" + averageHumid.toFixed(2) + " </span> "+units2);
                $("#card3").html("<span class=\"text-success\">" + averagePower.toFixed(2) + " </span> "+units3);
                $("#card4").html("<span class=\"text-success\">" + devicesTemp.length + " </span> ");

            }

            var newIndex = index + 1;

            if (devicesTemp.length > newIndex) {
                getDevice(devicesTemp[newIndex], newIndex, devicesTemp[newIndex].properties[0].value, devicesTemp[newIndex].properties[1].value);
            }

            //function to implement the regex search bar
            var $rows = $('#devices-listing tbody tr');
            $('#search').keyup(function () {
                var val = '^(?=.*\\b' + $.trim($(this).val()).split(/\s+/).join('\\b)(?=.*\\b') + ').*$',
                    reg = RegExp(val, 'i'),
                    text;

                $rows.show().filter(function () {
                    text = $(this).text().replace(/\s+/g, ' ');
                    return !reg.test(text);
                }).hide();

            });
        };

        $.ajax({
            type: "POST",
            url: "invoker/execute",
            data: {
                "uri": "/events/last-known/"+deviceType+"/" + devicesTemp[index].deviceIdentifier + "?limit=5",
                "method": "get"
            },
            success: lastKnownSuccess

        });

    }


</script>
<script src="pages/deviceGroup-page-scripts/summaryMap.js" type="text/javascript"></script>
<script src="pages/deviceGroup-page-scripts/tableCharts.js" type="text/javascript"></script>
<script src="pages/deviceGroup-page-scripts/functions.js" type="text/javascript"></script>
</html>
