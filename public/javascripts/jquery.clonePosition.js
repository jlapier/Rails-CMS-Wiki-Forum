/**
 * Copyright (c) 2009  Gary Haran => gary@talkerapp.com
 * Released under MIT license [...]
 */
(function($){
  $.fn.clonePosition = function(element, options){
    var options = $.extend({
      cloneWidth: true,
      cloneHeight: true,
      offsetLeft: 0,
      offsetTop: 0
    }, (options || {}));
    
    var offsets = $(element).offset();
    
    $(this).css({
      position: 'absolute',
      top:  (offsets.top  + options.offsetTop)  + 'px',
      left: (offsets.left + options.offsetLeft) + 'px'
    });
    
    if (options.cloneWidth)  $(this).width($(element).width());
    if (options.cloneHeight) $(this).height($(element).height());
    
    return this;
  }
})(jQuery);
