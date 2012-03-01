ShowHideLink = $.klass({
  initialize: function(options) {
    options = options || {};
    this.showEffect = options.show_effect;
    this.hideEffect = options.hide_effect;
    this.showEffectParams = options.show_effect_params;
    this.hideEffectParams = options.hide_effect_params;
    if(this.element.length > 0) {
      this.showClassName = $.string(this.element[0].href).toQueryParams()['show'];
      this.hideClassName = $.string(this.element[0].href).toQueryParams()['hide'];
      this.toggleClassName = $.string(this.element[0].href).toQueryParams()['toggle'];
    }
    this.hideMe = options.hide_me;
    this.doNotStop = options.do_not_stop || false;
    this.myHighlightClass = options.my_highlight_class;
    this.callAfter = options.call_after;
  },

  onclick: function(e) {
    console.log('clicked')
    console.log(this.toggleClassName);
    if(this.toggleClassName) {
      console.log($('.'+this.toggleClassName));
      $('.'+this.toggleClassName).toggle();
      console.log('okay toggled');
      if(this.hideClassName) {
        console.log('got to hide');
        $('.'+this.hideClassName).not('.'+this.toggleClassName).hide();
      }
      if(this.showClassName) {
        $('.'+this.showClassName).not('.'+this.toggleClassName).show();
      }
    } else if(this.showClassName) {
      $('.'+this.showClassName).show();
      if(this.hideClassName) {
        $('.'+this.hideClassName).not('.'+this.showClassName).hide();
      }
    } else if(this.hideClassName) {
      $('.'+this.hideClassName).hide();
    }
    if(this.myHighlightClass) {
      this.element.toggleClass(this.myHighlightClass);
      $('.'+this.myHighlightClass).not(this.element).removeClass(this.myHighlightClass);
    }
    if(this.callAfter) {
      eval(this.callAfter);
    }
    if(this.hideMe) {
      console.log('hide me;');
      this.element.hide();
    }
    this.element.blur();
    return this.doNotStop;
  }
});
