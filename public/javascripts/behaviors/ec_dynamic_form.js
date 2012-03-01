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
