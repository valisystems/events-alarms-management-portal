$(function () {
    $('body').on('click', '.modal-link', function (e) {
        e.preventDefault();
        $(this).attr('data-target', '#modal-container');
        $(this).attr('data-toggle', 'modal');
    });

    // Attach listener to .modal-close-btn's so that when the button is pressed the modal dialog disappears
    $('body').on('click', '.modal-close-btn', function () { $('#modal-container').modal('hide'); });

    //clear modal cache, so that new content can be loaded
    $('#modal-container').on('hidden.bs.modal', function () { $(this).removeData('bs.modal'); });

    $('#CancelModal').on('click', function () { return false; });


    //$('#lvm-btn-ok').click(function () {
    //    $('#modal-container').modal('hide');
    //    var url = '';
    //    $(".lvm-urlfield").each(function (index, el) {
    //        url += '&' + $(el).text();
    //    });
    //    url = encodeURI(url.substring(1).replace('&', '?'));
    //    $("#ActionUrl").text(url);
    //    $('#hdnIsUrlGen').val('1');
    //});

        //$('#UrlTypeId').change(function () {
        //    //alert($(this).val());
        //    var selval = $(this).val();
        //    $("#hdnUrlTypeId").val(selval);

        //    //$.get(url, function (data) {
        //    //    $('#gameContainer').html(data);

        //    //    $('#gameModal').modal('show');
        //    //});

        //    $('#lvm-url-fields').html("New FIELDS");

        //    //alert($("#hdnUrlTypeId").val());

        //    //$('#modal-container').modal('hide');
        //})
});

function LvmBtnOk_Click() {
    $('#modal-container').modal('hide');
    var url = '';var u = '';
    $(".lvm-urlfield").each(function (index, el) {
        var v = ''; 
        if ($(el).attr('type') == 'checkbox') { v = $(el).is(":checked") ? 'on' : 'off'; }
        else { v = $(el).val(); }
        var isv=!(!v || 0 === v.length);
        if ($(el).attr('id') == 'url') u = (isv ? v : '') + '?';
        else if (isv) url += '&' + $(el).attr('id') + '=' + v;
    });
    //url = encodeURI(url.substring(1).replace('&', '?'));
    url = u + encodeURI(url.substring(1));
    //$("#ActionUrl").val(url);
    //var AuId = $("#hdnActionUrl").val();
    $($("#hdnActionUrl").val()).val(url);
    $('#hdnUrlGen').val(url);
}


function UrlType_Change(val) {
    //alert($(this).val());
    //var selval = $(this).val();
    $("#hdnUrlTypeId").val(val);

    var Url = window.parent.location.href;
    Url = Url.substring(0, Url.indexOf("/DeviceActionTemplate/"));
    Url = Url + "/DeviceActionTemplate/UrlGenField/" + val;

    $.get(Url, function (data) {
        $('#lvm-url-fields').html(data);
        //$('#modal-container').modal('show');
    });

    //$('#lvm-url-fields').html(val + " New FIELDS");

    //alert($("#hdnUrlTypeId").val());

    //$('#modal-container').modal('hide');
}

