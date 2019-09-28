$(document).ready(function () {
    $("#Lvm_Address_CountryId").change(function () {
        var selVal = $(this).val();
        var ddlStPr = $("#Lvm_Address_StateProvinceId");
        //var Url = window.location.origin + "/Facility/StateProvByCountryId";
        var Url = window.parent.location.href;
        Url = Url.substring(0, Url.indexOf("/Facility/"));
        Url = Url + "/Facility/StateProvByCountryId";
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
                alert('Error to load state / province!');
            }
        });
    });
});
