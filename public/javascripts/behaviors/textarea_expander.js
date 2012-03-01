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

