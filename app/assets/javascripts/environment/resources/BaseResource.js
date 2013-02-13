var BaseResource = function(options){
  this.dialogId = options.resourceType + '-configuration' ;;
  this.element = options.element;
  this.instanceOptions = options;
  this.resourceType = options.resourceType;
};

BaseResource.prototype.showInstanceDialog = function(){
  var editElement = this.element.attr('id');
  var dialogId = this.dialogId;
  var instanceOptions = this.instanceOptions;
  var dialog = $('#'+dialogId);

  //TODO: Can this be removed ?
  dialog.removeData(['editElement', 'xpos', 'ypos']);
  dialog.data('editElement', editElement);

  dialog.find('.instance_label').val(instanceOptions.label);
  dialog.find('#' + this.resourceType + '_delete').show();
  dialog.modal('show');
};
