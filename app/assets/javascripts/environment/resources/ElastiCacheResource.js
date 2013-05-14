var ElastiCacheResource = function(options){
  this.baseResource = new BaseResource(options);
};

ElastiCacheResource.prototype.showInstanceDialog = function(){
  var dialog = $('#'+this.baseResource.dialogId);
  var instanceOptions = this.baseResource.instanceOptions;
  //third parameter, element id is required for setting the label on the icon
  addSlider("ElastiCache-slider", instanceOptions.InstanceType, this.baseResource.element.attr('id'));
  $('#ElastiCache_instance_type_id').html(instanceOptions.InstanceType);
  dialog.find('#ElastiCache_node_count').val(instanceOptions.configAttributes.node_count);
  this.setOutputAttributes(this.baseResource.instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

ElastiCacheResource.prototype.saveConfigAttributes = function(configAttributes){
  this.baseResource.instanceOptions.configAttributes = configAttributes;
}

ElastiCacheResource.prototype.saveStatus = function(status){
  //this.baseResource.instanceOptions.status = status;
}

ElastiCacheResource.prototype.setOutputAttributes = function(configAttributes){
  /* ElastiCache Resources in Cloudformation don't support Output params
   * Need to find an alternative way to fetch outputs
   * */
  //var dialog = $('#'+this.baseResource.dialogId);
}

ElastiCacheResource.prototype.visibilityOfConnectorPoint = function(instanceDivId){
  $('#connection-source-'+instanceDivId).hide();
}
