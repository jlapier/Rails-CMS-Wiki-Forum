/*
 * all lowpro behaviors
 */


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


TextareaExpander = $.klass({
  initialize: function(pixelsToGrowBy, maxHeight) {
    this.pixelsToGrowBy = (typeof pixelsToGrowBy == 'undefined') ? 20 : pixelsToGrowBy;
    this.maxHeight = (typeof maxHeight == 'undefined') ? 999 : maxHeight;
    // run it once to blow up any textareas on first page load
    this.onkeypress();
  },

  onkeypress: function(e) {
    var curr_h = this.element.height();
    var scroll_h = this.element[0].scrollHeight;
    while(curr_h < scroll_h && curr_h < this.maxHeight) {
      this.element.css( { 'height': (curr_h + this.pixelsToGrowBy) + 'px' });
      curr_h = this.element.height();
      scroll_h = this.element[0].scrollHeight;
    }
  }
});


ShowHideLink = $.klass({
  initialize: function(options) {
    options = options || {};
    this.showEffect = options.show_effect;
    this.hideEffect = options.hide_effect;
    this.showEffectParams = options.show_effect_params;
    this.hideEffectParams = options.hide_effect_params;
    this.showClassName = $.string(this.element[0].href).toQueryParams()['show'];
    this.hideClassName = $.string(this.element[0].href).toQueryParams()['hide'];
    this.toggleClassName = $.string(this.element[0].href).toQueryParams()['toggle'];
    this.hideMe = options.hide_me;
    this.doNotStop = options.do_not_stop || false;
    this.myToggleClass = options.my_toggle_class;
  },

  onclick: function(e) {
    if(this.hideClassName) {
      //$('.'+this.hideClassName).invoke(this.hideEffect || 'hide', this.hideEffectParams);
      $('.'+this.hideClassName).hide();
    }
    if(this.showClassName) {
      //$('.'+this.showClassName).invoke(this.showEffect || 'show', this.showEffectParams);
      $('.'+this.showClassName).show();
    }
    if(this.toggleClassName) {
      $('.'+this.toggleClassName).toggle();
    }
    if(this.hideMe) {
      this.element.hide();
    }
    this.element.blur();
    
    return this.doNotStop;
  }
});

ecDynamicForm = $.klass({
  initialize: function(options) {
    this.formElement = options.formElement;
    this.resourceType = this.formElement.attr('id').replace('_dynamic_form', '');
    this.resourceInputs = this.formElement.find(':input[id^="'+this.resourceType+'"]');
    this.resourcePlural = this.element.attr('id');
    this.originalAction = this.formElement.attr('action');
    this.formElement.remove();
  },
  onclick: $.delegate({
    '.new': function(clickedElement, event) {
      event.preventDefault();
      $('#'+this.formElement.attr('id')).remove();
      this.formElement.clearForm();
      this.formElement.attr('action', this.originalAction);
      this.formElement.find(':input[name="_method"]').attr('value', 'post');
      this.formElement.insertAfter(clickedElement);
      this.formElement.attach(Remote.Form);
      this.formElement.show();
    },
    '.cancel': function(clickedElement, event) {
      event.preventDefault();
      this.formElement.clearForm();
      this.formElement.attr('action', this.originalAction);
      this.formElement.find(':input[name="_method"]').attr('value', 'post');
      $('#'+this.formElement.attr('id')).remove();
    },
    '.edit': function(clickedElement, event) {
      event.preventDefault();
      $('#'+this.formElement.attr('id')).remove();
      
      var resourceContainer = clickedElement.parents('.' + this.resourceType);
      var resourceId = /\d+/.exec(resourceContainer.attr('id'))[0];
      
      // append resourceId to current form action
      this.formElement.attr("action", this.originalAction + "/" + resourceId);
      this.formElement.find(':input[name="_method"]').attr('value', 'put');
      
      // clear form input values
      this.formElement.clearForm();
      // move form to resource
      this.formElement.insertBefore(clickedElement);
      
      this.resourceInputs.each(function() {
        if( this.type != 'submit' ) {
          // get resource attr names from form input ids
          var resourceAttrContainer = resourceContainer.find('.'+this.id);
          // get resource attr vals from w/in resource container
          this.value = $.trim(resourceAttrContainer.text());
        }
      });
      
      this.formElement.attach(Remote.Form);
      this.formElement.show();
    }
  })
});

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
