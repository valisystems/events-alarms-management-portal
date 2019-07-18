//execute on document ready
$(function () {

    //function that the hub can call when it receives a notification.
    $.connection.notificationHub.client.displayNotification = function (Msg) {
        if (Msg == "update") {
            //window.location = "/monitor/";
            var url = window.parent.location.href;
            if (url.indexOf('.') > -1) {
                url = url.substring(0, url.lastIndexOf('/') + 1);
            }
            window.parent.location = url;
        }

            //UpdateMonitor();

        //var u = '/monitor/monlist/1';
        //$.ajax(
        //{
        //    url: u,
        //    type: 'get',
        //    cache: false,
        //    dataType: "html",
        //    success: function (data, textStatus, jqXHR) {
        //        $('#divMonitor').html(data);
        //    },
        //    error: function () {
        //        alert('MVC controller call failed.');
        //    }
        //});

    };

    window.notifyApp = {
        hubConnector: $.connection.hub.start()  //start the connection and store object returned globally for access in child views
    };

});




//  //a helper function to encode HTML values.
//  function htmlEncode(value) {
//      return $('<div />').text(value).html();
//  }

////execute on document ready
//$(function () {

//    //function that the hub can call when it receives a notification.
//    $.connection.notificationHub.client.displayNotification = function (title, message, alertType) {

//        //Create the bootstrap alert html
//        var alertHtml = '<div class="alert alert-' + htmlEncode(alertType) + ' alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert"><span>×</span></button><strong>' + htmlEncode(title) + '</strong> ' + htmlEncode(message) + '</div>';

//        $(alertHtml)
//          .hide()                           //hide the newly created element (this is required for fadeIn to work)
//          .appendTo('#alert-placeholder')   //add it to the palceholder in the page
//          .fadeIn(500);                     //little flair to grab user attention
//    };

//    window.notifyApp = {
//        hubConnector: $.connection.hub.start()  //start the connection and store object returned globally for access in child views
//    };

//});

