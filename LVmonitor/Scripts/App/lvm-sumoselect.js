$(document).ready(function () {
    window.asd = $('.SlectBox').SumoSelect({ selectAll: true });


    $('#btnSubmit').on('click', function () {
        var obj = [], items = '';
        $('#DeviceTypeControlId option:selected').each(function (i) {
            obj.push($(this).val());
            $('#DeviceTypeControlId')[0].sumo.unSelectItem(i);
        });
        for (var i = 0; i < obj.length; i++) { items += ',' + obj[i] };
        $('#SelControlIds').val(items);

        obj = []; items = '';
        $('#DeviceActionTemplateId option:selected').each(function (i) {
            obj.push($(this).val());
            $('#DeviceActionTemplateId')[0].sumo.unSelectItem(i);
        });
        for (var i = 0; i < obj.length; i++) { items += ',' + obj[i] };
        $('#SelAcTempIds').val(items);

        //SelAcTempIds
        //alert(items);
    });

});


/*
    $('#btnSubmit').on('click', function () {
        var obj = [], items = '';
        $('.SlectBox option:selected').each(function (i) {
            obj.push($(this).val());
            $('.SlectBox')[0].sumo.unSelectItem(i);
        });
        //$('.opt.selected').each(function (i) {
        //    obj.push($(this).val());
        //    //$('.testSelAll')[0].sumo.unSelectItem(i);
        //});
        for (var i = 0; i < obj.length; i++) { items += ',' + obj[i] };
        $('#SelControlIds').val(items);
        //alert(items);
    });

*/