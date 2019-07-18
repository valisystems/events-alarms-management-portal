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
});
