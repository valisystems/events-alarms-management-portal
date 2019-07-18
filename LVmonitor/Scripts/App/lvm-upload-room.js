$(document).ready(function () {

    //$('#btnUpload').click(function () {
    $('#fileUpload').change(function () {

        //document.getElementById("fileUpload").onchange

        // Checking whether FormData is available in browser
        if (window.FormData !== undefined) {

            var fileUpload = $("#fileUpload").get(0);
            var files = fileUpload.files;

            // Create FormData object
            var fileData = new FormData();

            // Looping over all files and add it to FormData object
            //for (var i = 0; i < files.length; i++) {
            //    fileData.append(files[i].name, files[i]);
            //}
            fileData.append(files[0].name, files[0]);

            var fid = $("#FacilityId").val();
            // Adding one more key to FormData object
            fileData.append('fid', fid);
            var Url = window.parent.location.href;
            Url = Url.substring(0, Url.indexOf("/Room/"));
            Url = Url + "/Room/UploadFile";
            $.ajax({
                url: Url,
                type: "POST",
                contentType: false, // Not to set any content header
                processData: false, // Not to process data
                data: fileData,
                success: function (result) {
                    alert(result);
                },
                error: function (err) {
                    alert(err.statusText);
                }
            });
        } else {
            alert("FormData is not supported.");
        }
    });
});
