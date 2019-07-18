//function UpdateMonitor() {
//    UpdateMonList2("MonList", "#divMonitor");
//    //UpdateMonList("HisList", "#divMonitorHistory");
//}

function UpdateMonitor() {
    var u = '/monitor/monlist/';
    $.ajax(
    {
        url: u,
        type: 'get',
        cache: false,
        dataType: "html",
        success: successFunc,
        error: errorFunc
    });
}

function successFunc(){//(data, textStatus, jqXHR) {
    //$('#divMonitor').html(data);
    alert('OK.');
}

function errorFunc() {
    alert('MVC controller call failed.');
}


function UpdateMonList() {
    var u = '/Monitor/MonList/';
    $.ajax({
        cache: false,
        type: 'get',
        url: u,
        dataType: "html",
        success: function (data, textStatus, jqXHR) {
            $('#divMonitor').html(data);
            UpdateHisList();
        },
        error: function () { alert('MVC controller call failed.'); }
    });
}

function UpdateHisList() {
    var u = '/Monitor/HisList/';
    $.ajax({
        cache: false,
        type: 'get',
        url: u,
        dataType: "html",
        success: function (data, textStatus, jqXHR) {
            $('#divMonitorHistory').html(data);
        },
        error: function () { alert('MVC controller call failed.'); }
    });
}


//function UpdateMonList(action, div) {
//    var u = '/Monitor/' + action + '/';
//    $.ajax({
//        cache: false,
//        type: 'get',
//        url: u,
//        dataType: "html",
//        success: function (data, div) {
//            $(div).html(data);
//        },
//        error: function () {alert('MVC controller call failed.');}
//    });
//}
