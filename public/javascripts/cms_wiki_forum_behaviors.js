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
      $('.'+this.hideClassName).show();
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