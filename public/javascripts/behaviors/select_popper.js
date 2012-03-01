/*
 * use like:
 *
 * $('.some_category_field').attach(SelectPopper, '#div_with_ul');
 * $('#div_with_ul').attach(SetSelector, '.some_category_field');
 *
 */

SelectPopper = $.klass({
  // provide array of select_options
  // TODO: detect a hash and use it to do option text/value
  initialize: function(select_options) {
    if(select_options.length > 0) {
      var _a_ul = $('<ul/>', { style : 'list-style-type: none; margin: 0' } );
      $.each(select_options, function(index, value) {
        $('<li/>', { text : value, style : "padding: 3px;" }).appendTo(_a_ul);
      });

      this.select_box = $('<div/>', { style : 'display:none; background: white; border: 1px solid #999;',
        "class" : "select_popper_box" } );
      _a_ul.appendTo(this.select_box);
      this.select_box.appendTo('body');
      this.select_box.attach(SetSelector, this.element);
    }
  },

  onfocus: function(e) {
    if(this.select_box) {
      this.select_box.clonePosition(this.element, { cloneHeight: false, offsetLeft: 1, offsetTop: this.element.height() });
      this.select_box.css('width', (this.element.offsetWidth - 2) + 'px');
      this.select_box.show();
    }
  },

  onblur: function(e) {
    if(this.select_box) {
      var _select_box = this.select_box;
      setTimeout(function() {
        _select_box.hide();
      }, 250);
    }
  }
});

SetSelector = $.klass({
  initialize: function(input_element) {
    this.select_field = $(input_element);
  },

  onclick: $.delegate({
    'li': function(click_target) {
      this.select_field.val(click_target.text());
      this.element.hide();
    }
  })
});

