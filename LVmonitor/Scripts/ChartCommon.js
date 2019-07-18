jQuery.extend({
    getValues: function (url) {
        var result = null;
        $.ajax({
            url: url,
            type: 'get',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (data) {
                result = data;
            }
        });
        return result;
    }
});

//function printChart(canId) {
//    var dataUrl = document.getElementById(canId).toDataURL(); //attempt to save base64 string to server using this var
//    var windowContent = '<!DOCTYPE html>';
//    windowContent += '<html>'
//    windowContent += '<head><title>Print canvas</title></head>';
//    windowContent += '<body>'
//    windowContent += '<img src="' + dataUrl + '">';
//    windowContent += '</body>';
//    windowContent += '</html>';
//    var printWin = window.open('', '', 'width=340,height=260');
//    printWin.document.open();
//    printWin.document.write(windowContent);
//    printWin.document.close();
//    printWin.focus();
//    printWin.print();
//    printWin.close();
//}


//$(document).ready(function () {

//    var c = document.getElementById("cnvChart");
//    var ctx = c.getContext("2d");
//    var tData = $.getValues("/Analytics/DevResponseChartData");
//    var myLineChart = new Chart(ctx, {
//        type: 'line',
//        data: tData
//    });



//    //var c = document.getElementById("MultiLineChart");
//    //var ctx = c.getContext("2d");
//    //var tData = $.getValues("/Analytics/DevResponseChartData2");
//    //var myLineChart = new Chart(ctx, {
//    //    type: 'line',
//    //    data: tData
//    //});

//});