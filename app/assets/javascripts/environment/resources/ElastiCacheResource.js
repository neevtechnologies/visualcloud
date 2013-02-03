var ElastiCacheResource = function(options){
  this.baseResource = new BaseResource(options);
};

ElastiCacheResource.prototype.showInstanceDialog = function(){
  var dialog = $('#'+this.baseResource.dialogId);
  var instanceOptions = this.baseResource.instanceOptions;
  //TODO: Refactor 'callToAddSlider'. It should take instanceType and sliderDiv as params
  callToAddSlider('ElastiCache' , instanceOptions.InstanceType, this.baseResource.element.attr('id'));
  $('#ElastiCache_instance_type_id').html(instanceOptions.InstanceType);
  dialog.find('#ElastiCache_node_count').val(instanceOptions.configAttributes.node_count);
  this.setOutputAttributes(this.baseResource.instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

ElastiCacheResource.prototype.setOutputAttributes = function(configAttributes){
  /* ElastiCache Resources in Cloudformation don't support Output params
   * Need to find an alternative way to fetch outputs
   * */
  //var dialog = $('#'+this.baseResource.dialogId);
}
