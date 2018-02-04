$(function() {
  $('#welcome_modal').dialog({
    autoOpen: false
  });

  $('#welcome_modal_opener').on('click', function() {
    $('#welcome_modal').dialog('open');
  });
});
