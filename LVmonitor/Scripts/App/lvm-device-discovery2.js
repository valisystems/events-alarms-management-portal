$(function () {
    $("#ddlFacility").change(function () {
        var selVal = $(this).val();
        var ddlR = $("#ddlRoom");
        //var Url = window.location.origin ? window.location.origin + '/' : window.location.protocol + '/' + window.location.host + '/';
        var Url = window.parent.location.href;
        Url = Url.substring(0, Url.indexOf("/DeviceDiscovery/"));
        var UrlR = Url + "/DeviceDiscovery/RoomByFacilityId";
        $.ajax({
            cache: false,
            type: "post",
            url: UrlR,
            data: { "id": selVal },
            datatype: "json",
            traditional: true,
            success: function (data) {
                ddlR.html('');
                $.each(data, function (id, option) {
                    ddlR.append($('<option></option>').val(option.Value).html(option.Text));
                });
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert('Found error to load Room dropdown!');
            }
        });

        var UrlD = Url + "/DeviceDiscovery/DepartmentByFacilityId";
        ddlD = $("#ddlDepartment");
        $.ajax({
            cache: false,
            type: "post",
            url: UrlD,
            data: { "id": selVal },
            datatype: "json",
            traditional: true,
            success: function (data) {
                ddlD.html('');
                $.each(data, function (id, option) {
                    ddlD.append($('<option></option>').val(option.Value).html(option.Text));
                });
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert('Found error to load Department dropdown!');
            }
        });

    });


});


//function LvmBtnOk_Click() {
//    $('#modal-container').modal('hide');
//    var url = ''; var u = '';
//    $(".lvm-urlfield").each(function (index, el) {
//        var v = '';
//        if ($(el).attr('type') == 'checkbox') { v = $(el).is(":checked") ? 'on' : 'off'; }
//        else { v = $(el).val(); }
//        var isv = !(!v || 0 === v.length);
//        if ($(el).attr('id') == 'url') u = (isv ? v : '') + '?';
//        else if (isv) url += '&' + $(el).attr('id') + '=' + v;
//    });
//    //url = encodeURI(url.substring(1).replace('&', '?'));
//    url = u + encodeURI(url.substring(1));
//    //$("#ActionUrl").val(url);
//    //var AuId = $("#hdnActionUrl").val();
//    $($("#hdnActionUrl").val()).val(url);
//    $('#hdnUrlGen').val(url);
//}