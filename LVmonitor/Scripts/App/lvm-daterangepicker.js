$(document).ready(function () {

    //$('#DateFromTo').daterangepicker(
    //    {
    //    timePicker: true,
    //    timePickerIncrement: 30,
    //    locale: {
    //        format: 'MM/DD/YYYY h:mm A'
    //    }
    //}
    //);

    //alert($('#DateFromTo').daterangepicker().val())
    //alert($('#DateFromTo').data('daterangepicker').startDate._d)
    //var stDate = $('#DateFromTo').data('daterangepicker').startDate._d;
    //var enDate = $('#DateFromTo').data('daterangepicker').endDate._d;

    //var rDS = $('#DateFromTo').daterangepicker().val().replace(/^\s\s*/, '').replace(/\s\s*$/, '').split('-');

    //function IsDate() { return Object.prototype.toString.call(date) === '[object Date]' }

    var rD = $('#DateFromTo').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    //alert(rD.length);
    var IsSel = rD.length > 0;
    if (IsSel) {
        var rDS = rD.split('-');
        //alert(rDS.length + " = " + rDS[0] + "=" + rDS[1]);
        IsSel = rDS[0].trim() != rDS[1];
    }
    var start = IsSel ? rDS[0] : moment().subtract(29, 'days');
    var end = IsSel ? rDS[1] : moment();
    //var start = moment().subtract(29, 'days');
    //var end = moment();

    //var start = $('#DateFromTo').data('daterangepicker').startDate._d;
    //var end = $('#DateFromTo').data('daterangepicker').endDate._d;

    //function cb(start, end) {
    //    //alert(start.format('MMMM D, YYYY hh:mm'));
    //    $('#DateFromTo').html(start.format('MM/DD/YYYY h:mm A') + ' - ' + end.format('MM/DD/YYYY h:mm A'));
    //}

    $('#DateFromTo').daterangepicker({
        alwaysShowCalendars: true,
        showDropdowns: true,
        linkedCalendars: false,
        autoApply: true,
        //timePicker: true,
        //timePickerIncrement: 10,
        //locale: { format: 'MM/DD/YYYY h:mm A' },
        locale: { format: 'MM/DD/YYYY' },
        startDate: start,
        endDate: end,
        ranges: {
            'Today': [moment(), moment()],
            'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(29, 'days'), moment()],
            'Last 90 Days': [moment().subtract(89, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
    })//, cb);

    //cb(start, end);

    //$('#DateFromTo').daterangepicker();

});
