$(document).ready(function () {
    $("#FacilityId").change(function () {
        var selVal = $(this).val();
        var ddlR = $("#RoomId");
        //var Url = window.location.origin ? window.location.origin + '/' : window.location.protocol + '/' + window.location.host + '/';
        var Url = window.parent.location.href;
        Url = Url.substring(0, Url.indexOf("/Device/"));
        var UrlR = Url + "/Device/RoomByFacilityId";
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
                alert('Error to load Room dropdown!');
            }
        });

        var UrlD = Url + "/Device/DepartmentByFacilityId";
        ddlD = $("#DepartmentId");
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
                alert('Error to load Department dropdown!');
            }
        });

    });
});
