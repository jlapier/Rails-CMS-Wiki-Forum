var Collapsible = $.klass({
  initialize: function() {
    this.element.find('.open').each(function(i, e) {
      $(e).siblings().show();
    });
    this.element.find('.closed').each(function(i, e) {
      $(e).siblings().hide();
    });
  },
  onclick: $.delegate({
    '.collapsible': function(clickedElement, event) {
      collapsed = clickedElement.parent().find(':hidden').size();
      if( collapsed > 0 ) {
        event.preventDefault();
      }
      clickedElement.siblings().toggle();
      clickedElement.toggleClass('open closed');
    }
  })
});
