var MagicButtons = $.klass({
  initialize: function() {
    if( this.element.find('.magic').size() > 0 ) {
      this.element.find('.magic').hide();
    }
  },
  onmouseover: $.delegate({
    'p': function(mousedElement, event) {
      if( mousedElement.find('.magic').size() > 0 ) {
        mousedElement.find('.magic').show();
      }
    }
  }),
  onmouseout: $.delegate({
    'p': function(mousedElement, event) {
      if( mousedElement.find('.magic').size() > 0 ) {
        mousedElement.find('.magic').hide();
      }
    }
  })
});
