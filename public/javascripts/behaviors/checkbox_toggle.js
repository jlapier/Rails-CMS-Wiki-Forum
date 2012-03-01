CheckBoxToggle = $.klass({
  initialize: function(toggle_selector) {
    this.toggle_selector = toggle_selector;
  },

  onclick: function() {
    var to_toggle = this.element[0].checked;
    $(this.toggle_selector + ' input[type=checkbox]').each(function(index) {
      $(this)[0].checked = to_toggle;
    });
  }
});

