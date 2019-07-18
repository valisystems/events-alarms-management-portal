//execute on document ready
$(function () {

    //function that the hub can call when it receives a notification.
    $.connection.notificationHub.client.displayNotification = function (Msg) {
        if (Msg == "urldebug") {
            var url = window.parent.location.href;
            window.parent.location = url;

            //var Url = window.parent.location.href;
            //Url = Url.substring(0, Url.indexOf("/UrlDebug/"));
            //Url = Url + "/UrlDebug/GetTbl";
            //$.ajax(
            //{
            //    url: Url,
            //    type: 'get',
            //    cache: false,
            //    dataType: "html",
            //    success: function (data, textStatus, jqXHR) { $('#tblUrlDebug').html(data); },
            //    error: function () { alert('MVC controller call failed.'); }
            //});

        }
    };

    window.notifyApp = {
        hubConnector: $.connection.hub.start()  //start the connection and store object returned globally for access in child views
};

});

function CopyLinkToClipboard() {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($('#spanLink').text()).select();
    document.execCommand("copy");
    $temp.remove();
}
