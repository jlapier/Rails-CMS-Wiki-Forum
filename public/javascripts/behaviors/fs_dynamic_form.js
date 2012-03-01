/*
$('#file_attachments').attach(fsDynamicForm, {
  formElement: $('#new_description')
});
*/
fsDynamicForm = $.klass({
  initialize: function(options) {
    this.formElement = options.formElement;
    this.formElement.attach(Remote.Form);
    this.resourceType = this.formElement.attr('id').replace('_dynamic_form', '');
    this.resourceInputs = this.formElement.find(':input[id^="'+this.resourceType+'"]');
    this.resourcePlural = this.element.attr('id');
  },
  onclick: $.delegate({
    '.cancel_dynamic_form': function(clickedElement, event) {
      event.preventDefault();
      this.formElement.hide();
    },
    '.file_attachment_dynamic_form_link': function(clickedElement, event) {      
      event.preventDefault();
      
      var resourceContainer = clickedElement.parents('.' + this.resourceType);
      var resourceId = /\d+/.exec(resourceContainer.attr('id'))[0];
      
      // append resourceId to current form action
      this.formElement.attr("action", "/" + this.resourcePlural + "/" + resourceId);
      
      // clear form input values
      this.formElement.clearForm();
      // move form to resource
      this.formElement.insertBefore(clickedElement);
      
      this.resourceInputs.each(function() {
        // get resource attr names from form input ids
        var resourceAttrContainer = resourceContainer.find('.'+this.id);
        // get resource attr vals from w/in resource container
        this.value = $.trim(resourceAttrContainer.text());
      });
      
      this.formElement.show();
    }
  })
});
