$(document).ready(function () {
    //UpdateAgo()
    setTimeout(UpdateAgo, 60000);
});

function UpdateAgo() {
    $(".ago-off").each(function (index, el) {
        var time = $(el).text().replace("h", "").replace("m", "").replace("c", "");
        var min = 0;
        if (time.indexOf(':') < 0)
            min = +time + 1;
        else {
            var a = time.split(':');
            min = (+a[0]) * 60 + (+a[1]) + 1;
        }
        var h = Math.floor(min / 60);
        var m = min % 60;
        //var out = "";
        //if (h > 0) {
        //    h = h < 10 ? '0' + h : h;
        //    m = m < 10 ? '0' + m : m;
        //    out = h + ':' + m;
        //}
        //else
        //    out = m;
        h = h < 10 ? '0' + h : h;
        m = m < 10 ? '0' + m : m;
        $(el).text(h + 'h:' + m +"m");
    });
    setTimeout(UpdateAgo, 60000);
}

//function UpdateAgo() {
//    var d = new Date()
//    //var offB = d.getTimezoneOffset();
//    //var offS = $('#LvmUtcOff').val();

//    //var tzDifference = timeZoneFromDB * 60 + targetTime.getTimezoneOffset();
//    ////convert the offset to milliseconds, add to targetTime, and make a new Date
//    //var offsetTime = new Date(targetTime.getTime() + tzDifference * 60 * 1000);

//    $(".ago-off").each(function (index, el) {
//        var offId = el.id;
//        offId = "#" + offId.substring(4, offId.length);
//        var offtxt = $(offId).text();
//        var offtime = new Date(offtxt);
//        //var dif = Math.ceil(Math.abs(d - offtime) / 60000);
//        var dif = dateDiffInMin(offtime, d)
//        var hours = Math.floor(dif / 60);
//        var minutes = dif % 60;
//        var out = hours > 0 ? hours + ":" + minutes : minutes;
//        $(el).text(out);
//    });
//    setTimeout(UpdateAgo, 60000);
//}


//// a and b are javascript Date objects
//function dateDiffInMin(a, b) {
////var _MS_PER_DAY = 1000 * 60 * 60 * 24;
//    var _MS_PER_MIN = 1000 * 60;
//    // Discard the time and time-zone information.
//    var utc1 = new Date(a.getUTCFullYear(), a.getUTCMonth(), a.getUTCDate(), a.getUTCHours(), a.getUTCMinutes(), a.getUTCSeconds());
//    var utc2 = new Date(b.getUTCFullYear(), b.getUTCMonth(), b.getUTCDate(), b.getUTCHours(), b.getUTCMinutes(), b.getUTCSeconds());
//    return Math.floor((utc2 - utc1) / _MS_PER_MIN);
//}