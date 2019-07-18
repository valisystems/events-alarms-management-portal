//var d = {"BaseName":"Di-189139DA1","EventType":"Normal","SensorID":"ctl_55399"}
function LvmPostJson(u, d) {
    $.ajax({
        type: "POST",
        url: u,
        data: JSON.stringify(d),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (msg) {
            // Do something on success
        }
    });
}