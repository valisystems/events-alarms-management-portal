//function SelectAllChk(a, b) {
//    var c = a.children;
//    var d = (a.type == "checkbox") ? a : a.children.item[0];
//    xState = d.checked;
//    elm = d.form.elements;
//    for (i = 0; i < elm.length; i++) if (elm[i].type == "checkbox" && elm[i].id != d.id && elm[i].id.endsWith(b)) {
//        if (elm[i].checked != xState) elm[i].click();
//    }
//}

$(function () {
    //$('#chkAllDd').toggle(
    //    function () {
    //        $('#tblDd .chkDd').prop('checked', true);
    //    },
    //    function () {
    //        $('#tblDd .chkDd').prop('checked', false);
    //    }
    //);

    $("#chkAllDd").change(function () {
        $(".chkDd").attr("checked", $(this).prop("checked"));
    });

    $('#btnUpdate').click(function () {
        var checkedVals = $('.chkDd:checkbox:checked').map(function () {return this.value;}).get();
        //$('#hdnSelId').val(checkedVals.join("_"));
        this.href += "_" + checkedVals.join("-") + "_" + $('#ddlDeviceType').val() + "_" + $('#ddlFacility').val() + "_" + $('#ddlDepartment').val() + "_" + $('#ddlRoom').val()
        //alert(this.href);
    });

    $('#btnApprove').click(function () {
        var checkedVals = $('.chkDd:checkbox:checked').map(function () { return this.value; }).get();
        //$('#hdnSelId').val(checkedVals.join("_"));
        this.href += "_" + checkedVals.join("-") + "_" + $('#ddlDeviceType').val() + "_" + $('#ddlFacility').val() + "_" + $('#ddlDepartment').val() + "_" + $('#ddlRoom').val()
        //alert(this.href);
    });

    $('#btnDelete').click(function () {
        var checkedVals = $('.chkDd:checkbox:checked').map(function () { return this.value; }).get();
        //$('#hdnSelId').val(checkedVals.join("_"));
        this.href += "_" + checkedVals.join("-") + "_" + $('#ddlDeviceType').val() + "_" + $('#ddlFacility').val() + "_" + $('#ddlDepartment').val() + "_" + $('#ddlRoom').val()
        //alert(this.href);
    });

        //$("#ddlFacility").change(function () {
        //    var selVal = $(this).val();
        //    var Url = window.parent.location.href;
        //    Url = Url.substring(0, Url.indexOf("/DeviceDiscovery/"));
        //    var UrlD = Url + "/DeviceDiscovery/DepartmentByFacilityId";
        //    ddlD = $("#ddlDepartment");
        //    $.ajax({
        //        cache: false,
        //        type: "post",
        //        url: UrlD,
        //        data: { "id": selVal },
        //        datatype: "json",
        //        traditional: true,
        //        success: function (data) {
        //            ddlD.html('');
        //            $.each(data, function (id, option) {
        //                ddlD.append($('<option></option>').val(option.Value).html(option.Text));
        //            });
        //        },
        //        error: function (xhr, ajaxOptions, thrownError) {
        //            alert('Found error to load Department dropdown!');
        //        }
        //    });
    //});

    $("#ddlFacility").change(function () {
        var selVal = $(this).val();
        var ddlR = $("#ddlRoom");
        //var Url = window.location.origin ? window.location.origin + '/' : window.location.protocol + '/' + window.location.host + '/';
        var Url = window.parent.location.href;
        Url = Url.substring(0, Url.indexOf("/DeviceDiscovery/"));
        var UrlR = Url + "/DeviceDiscovery/RoomByFacilityIdAll";
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

        var UrlD = Url + "/DeviceDiscovery/DepartmentByFacilityIdAll";
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