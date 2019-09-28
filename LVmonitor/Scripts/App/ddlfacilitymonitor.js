$(document).ready(function () {
    $("#FacilityId").change(function () {
        var selVal = $(this).val();
        var ddlStPr = $("#MonitorId");
        //var Url = window.location.origin + "/AppAdmin/MonitorByFacilityId";
        var Url = window.parent.location.href;
        //Url = Url.substring(0, Url.indexOf("/AppAdmin/"));
        Url = Url + "/MonitorByFacilityId";
        $.ajax({
            cache: false,
            type: "post",
            //url: '@Url.Action("StateProvByCountryId", "Facility")',
            url: Url,
            data: { "id": selVal },
            datatype: "json",
            traditional: true,
            success: function (data) {
                ddlStPr.html('');
                $.each(data, function (id, option) {
                    //ddlStPr.append($('<option/>', { value: itemData.Value, text: itemData.Text }));
                    ddlStPr.append($('<option></option>').val(option.Value).html(option.Text));
                });
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert('Error to load Monitor!');
            }
        });
    });
});
