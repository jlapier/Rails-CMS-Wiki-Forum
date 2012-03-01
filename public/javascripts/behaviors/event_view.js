var EventView = $.klass({
  initialize: function() {
    $('.event_list').hide();
    $('.event_calendar').show();
  },
  onclick: function(e) {
    if( this.element.hasClass('calendar') ) {
      $('.event_list').hide();
      $('.event_calendar').show();
    } else if( this.element.hasClass('list') ) {
      $('.event_calendar').hide();
      $('.event_list').show();
    }
  }
});

