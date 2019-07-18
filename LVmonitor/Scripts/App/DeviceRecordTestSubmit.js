function LvmSendRecord() {
    var u = $("#Url").val();
    $.ajax({
        cache: false,
        type: "post",
        //url: '@Url.Action("StateProvByCountryId", "Facility")',
        url: u,
        //data: { "id": selVal },
        datatype: "json",
        traditional: true,
        success: function (data) {  },
        error: function (xhr, ajaxOptions, thrownError) {
            alert('Sending Record Error!');
        }
    });
}
