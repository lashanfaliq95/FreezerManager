/*
* Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
* WSO2 Inc. licenses this file to you under the Apache License,
* Version 2.0 (the "License"); you may not use this file except
* in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied. See the License for the
* specific language governing permissions and limitations
* under the License.
*/

realtimeAnalytics = {
    initDashboardPageCharts: function (wsEndpoint) {
        /* ----------==========     Realtime Chart One initialization    ==========---------- */
        var realtimeChartOneLabelRef = [new Date()];
        var realtimeChartOneLabel = ['0s'];
        var realtimeChartOneSeries = [0];

         realtimeAnalytics.createLiFo(realtimeChartOneLabelRef, 10);
         realtimeAnalytics.createLiFo(realtimeChartOneLabel, 10);
         realtimeAnalytics.createLiFo(realtimeChartOneSeries, 10);

        dataRealtimeChartOneChart = {
            labels: realtimeChartOneLabel,
            series: [
                realtimeChartOneSeries
            ]
        };

        optionsRealtimeChartOneChart = {
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0
            }),
            showArea: true,
            responsive:true,
            maintainAspectRatio : false,
            chartPadding: {
                top: 20,
                right: 0,
                bottom: 0,
                left: 0
            },



        };

        var realtimeChartOne = new Chartist.Line('#RealTimeChartOne', dataRealtimeChartOneChart, optionsRealtimeChartOneChart);
        md.startAnimationForLineChart(realtimeChartOne);

        /* ----------==========     Realtime Chart Two initialization    ==========---------- */
        var realtimeChartTwoLabelRef = [new Date()];
        var realtimeChartTwoLabel = ['0s'];
        var realtimeChartTwoSeries = [0];

        realtimeAnalytics.createLiFo(realtimeChartTwoLabelRef, 10);
        realtimeAnalytics.createLiFo(realtimeChartTwoLabel, 10);
        realtimeAnalytics.createLiFo(realtimeChartTwoSeries, 10);

        dataRealtimeChartTwoChart = {
            labels: realtimeChartTwoLabel,
            series: [
                realtimeChartTwoSeries
            ]
        };

        optionsRealtimeChartTwoChart = {
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0.2
            }),
            showArea: true,
            maintainAspectRatio : false,
            responsive:false,
            chartPadding: {
                top: 20,
                right: 0,
                bottom: 0,
                left: 10
            }
        };

        var realtimeChartTwo = new Chartist.Line('#RealTimeChartTwo', dataRealtimeChartTwoChart, optionsRealtimeChartTwoChart);
        md.startAnimationForLineChart(realtimeChartTwo);

        /* ----------==========     Realtime Chart Three initialization    ==========---------- */
        var realtimeChartThreeLabelRef = [new Date()];
        var realtimeChartThreeLabel = ['0s'];
        var realtimeChartThreeSeries = [0];

        realtimeAnalytics.createLiFo(realtimeChartThreeLabelRef, 10);
        realtimeAnalytics.createLiFo(realtimeChartThreeLabel, 10);
        realtimeAnalytics.createLiFo(realtimeChartThreeSeries, 10);

        dataRealtimeChartThreeChart = {
            labels: realtimeChartThreeLabel,
            series: [
                realtimeChartThreeSeries
            ]
        };

        optionsRealtimeChartThreeChart = {
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0
            }),
            showArea: true,
            chartPadding: {
                top: 20,
                right: 0,
                bottom: 0,
                left: 10
            }
        };

        var realtimeChartThree = new Chartist.Line('#RealTimeChartThree', dataRealtimeChartThreeChart, optionsRealtimeChartThreeChart);
        md.startAnimationForLineChart(realtimeChartThree);

        ////////////////////////////////////
        var d = new Date();
        var ChartDataOne = [
            // First series
            {
                label: "Series 1",
                values: [ {time: d.getTime()/1000, y:0}]
            }
        ];
        var chartOne =  $('#lineChart').epoch({
            type: 'time.line',
            data: ChartDataOne,
            axes: [ 'bottom', 'left','right'],
            margins: { left: 40 ,top: 50}
        });

        var ChartDataTwo = [
            // First series
            {
                label: "Series 1",
                values: [ {time: d.getTime()/1000, y:0}]
            }
        ];
        var chartTwo =  $('#lineChart1').epoch({
            type: 'time.line',
            data: ChartDataTwo,
            axes: [ 'bottom', 'left','right'],
            margins: { left: 40 ,top: 50}
        });

        var ChartDataThree = [
            // First series
            {
                label: "Series 1",
                values: [ {time: d.getTime()/1000, y:0}]
            }
        ];
        var chartThree =  $('#lineChart2').epoch({
            type: 'time.line',
            data: ChartDataThree,
            axes: [ 'bottom', 'left','right'],
            margins: { left: 40 ,top: 50}
        });




        if (wsEndpoint) {
            connect(wsEndpoint);
        } else {
            updateGraphs();
        }
        var ws;

        // close websocket when page is about to be unloaded
        // fixes broken pipe issue
        window.onbeforeunload = function () {
            disconnect();
        };

        //websocket connection
        function connect(target) {
            if ('WebSocket' in window) {
                ws = new WebSocket(target);
            } else if ('MozWebSocket' in window) {
                console.log('realtime mozsocket');
                ws = new MozWebSocket(target);
            } else {
                console.log('WebSocket is not supported by this browser.');
            }
            if (ws) {

                ws.onmessage = function (event) {
                    console.log('data');
                    var data = event.data;
                    var dataPoint = JSON.parse(data).event.payloadData;
                    var varOne=dataPoint[typeParameter1];
                    var varTwo=dataPoint[typeParameter2];
                    var varThree=dataPoint[typeParameter3];




                    var currentTime = new Date();
                    var sinceText = timeDifference(currentTime, new Date(dataPoint.timeStamp), false) + " ago";
                    updateStatusCards(sinceText,varOne, varTwo, varThree);

                    var lastUpdatedTime = realtimeChartOneLabelRef[realtimeChartOneLabelRef.length - 1];
                    var lastUpdatedText = "<i class=\"material-icons\">access_time</i> updated "+timeDifference(currentTime, lastUpdatedTime)+" ago";

                    realtimeChartOneLabel.push('0s');
                    realtimeChartOneLabelRef.push(currentTime);
                    realtimeAnalytics.calcTimeDiff(realtimeChartOneLabel, realtimeChartOneLabelRef);
                    realtimeChartOneSeries.push(varOne);
                    $("#realtimeChartOneLastUpdated").html(lastUpdatedText);

                    realtimeChartTwoLabel.push('0s');
                    realtimeChartTwoLabelRef.push(currentTime);
                    realtimeAnalytics.calcTimeDiff(realtimeChartTwoLabel, realtimeChartTwoLabelRef);
                    realtimeChartTwoSeries.push(varTwo);
                    $("#realtimeChartTwoLastUpdated").html(lastUpdatedText);

                    realtimeChartThreeLabel.push('0s');
                    realtimeChartThreeLabelRef.push(currentTime);
                    realtimeAnalytics.calcTimeDiff(realtimeChartThreeLabel, realtimeChartThreeLabelRef);
                    realtimeChartThreeSeries.push(varThree);
                    $("#realtimeChartThreeLastUpdated").html(lastUpdatedText);


                    //////////////////////////////////////////

                    var newBarChartDataOne = [{x: d.getTime()/1000, y:varOne}];
                    console.log(d.getTime());
                    chartOne.push(newBarChartDataOne);

                    var newBarChartDataTwo = [{x: d.getTime()/1000, y:varTwo}];
                    console.log(d.getTime());
                    chartTwo.push(newBarChartDataTwo);

                    var newBarChartDataThree = [{x: d.getTime()/1000, y:varThree}];
                    console.log(d.getTime());
                    chartThree.push(newBarChartDataThree);

                    updateGraphs();
                };

            }

            //refresh graphs on click on the chart
            $('.card').click(function() {
                updateGraphs();

            });

            $("#menu-toggle").click(function () {
                setTimeout(updateGraphs, 200);
            });

        }

        function updateGraphs(){
            realtimeChartOne.update();
            realtimeChartTwo.update();
            realtimeChartThree.update();

        }

        function disconnect() {
            if (ws != null) {
                ws.close();
                ws = null;
            }
        }
    },

    createLiFo : function(arr, length){
        arr.push = function (){
            if (this.length >= length) {
                this.shift();
            }
            return Array.prototype.push.apply(this,arguments);
        };
    },

    calcTimeDiff: function (arr, arrRef) {
        var now = new Date();
        for (var i = 0; i < arr.length; i++) {
            arr[i] = timeDifference(now, arrRef[i], true);
        }
    },

};