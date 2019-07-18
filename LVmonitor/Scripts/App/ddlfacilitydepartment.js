$(document).ready(function () {
    $("#FacilityId").change(function () {
        var selVal = $(this).val();
        var Url = window.parent.location.href;
        Url = Url.substring(0, Url.indexOf("/Analytics/"));
        var UrlD = Url + "/Analytics/DepartmentByFacilityId";
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
                alert('Found error to load Department dropdown!');
            }
        });

    });
});
