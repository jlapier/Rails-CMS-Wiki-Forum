// use to give the preview of details for an event below a calendar
var updateEventDescription = function(event, jsEvent) {
  $("#event_quick_description").empty();
  $("#event_quick_description").append(
    $("<h3/>").append(
      $('<a/>', { text : event.title+' ('+event.eventType+')', href : event.url })
    )
  ).append(event.details);
  $("#event_quick_description").show();
  $("#event_mini_description").empty();
  $("#event_mini_description").append(
      $('<div/>', { style : 'float:right' }).append(
        $('<a/>', { text : 'X', onclick : '$("#event_mini_description").hide()' })
      )
  ).append(event.brief);
  $("#event_mini_description").show();
  $("#event_mini_description").position({
    my: "left top", at: "center bottom", of: $(jsEvent.target) });
}


jQuery(function($) {
  $('ul.events').attach(Collapsible);
  $('a.show_hide_link').attach(ShowHideLink);
  $('a.view_events').attach(EventView);
  $('div.links').attach(MagicButtons);
  $('div.links').attach(ecDynamicForm, {
    formElement: $('#link_dynamic_form')
  });
});

/*
http://www.learningjquery.com/2007/08/clearing-form-data
*/
$.fn.clearForm = function() {
  return this.each(function() {
    var type = this.type, tag = this.tagName.toLowerCase();
    if (tag == 'form')
      return $(':input',this).clearForm();
    if (type == 'text' || type == 'password' || tag == 'textarea')
      this.value = '';
    else if (type == 'checkbox' || type == 'radio')
      this.checked = false;
    else if (tag == 'select')
      this.selectedIndex = -1;
  });
};
