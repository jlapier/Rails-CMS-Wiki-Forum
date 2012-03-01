var QuickZoom = $.klass({
  onmouseover: $.delegate({
    '.zoom': function(mousedElement, event) {
      mousedElement.addClass('enlarge');
    }
  }),
  onmouseout: $.delegate({
    '.enlarge': function(mousedElement, event) {
      mousedElement.removeClass('enlarge');
    }
  })
});
