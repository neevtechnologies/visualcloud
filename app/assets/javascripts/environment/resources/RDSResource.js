var RDSResource = function(options){
  this.baseResource = new BaseResource(options);
};

RDSResource.prototype.showInstanceDialog = function(){
  var dialog = $('#'+this.baseResource.dialogId);
  var instanceOptions = this.baseResource.instanceOptions;
  //third parameter, element id is required for setting the label on the icon
  addSlider("RDS-slider" , instanceOptions.InstanceType, this.baseResource.element.attr('id'));
  $('#RDS_instance_type_id').html(instanceOptions.InstanceType);
  dialog.find('#RDS_size').val(instanceOptions.configAttributes.size);
  dialog.find('#RDS_master_user_name').val(instanceOptions.configAttributes.master_user_name);
  dialog.find('#RDS_master_password').val(instanceOptions.configAttributes.master_password);
  dialog.find('#RDS_multiAZ').prop("checked",instanceOptions.configAttributes.multiAZ);
  this.setOutputAttributes(instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

RDSResource.prototype.saveConfigAttributes = function(configAttributes){
  this.baseResource.instanceOptions.configAttributes = configAttributes;
}

RDSResource.prototype.setOutputAttributes = function(configAttributes){
  var dialog = $('#'+this.baseResource.dialogId);
  dialog.find('#RDS_endpoint_ip').html("Endpoint IP : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'endpoint_address')+"</code>");
  dialog.find('#RDS_endpoint_port').html("Endpoint Port : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'endpoint_port')+"</code>");
}

RDSResource.prototype.visibilityOfConnectorPoint = function(instanceDivId){
  $('#connection-source-'+instanceDivId).hide();
}