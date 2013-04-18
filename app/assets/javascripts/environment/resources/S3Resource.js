var S3Resource = function(options){
  this.baseResource = new BaseResource(options);
};

S3Resource.prototype.showInstanceDialog = function(){
  var dialog = $('#'+this.baseResource.dialogId);
  var instanceOptions = this.baseResource.instanceOptions;
  dialog.find('#S3_cloudfront').prop("checked",instanceOptions.configAttributes.cloudFront);
  dialog.find('#S3_access_control').val(instanceOptions.configAttributes.access_control);
  this.setOutputAttributes(instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

S3Resource.prototype.saveConfigAttributes = function(configAttributes){
  this.baseResource.instanceOptions.configAttributes = configAttributes;
}

S3Resource.prototype.setOutputAttributes = function(configAttributes){
  var dialog = $('#'+this.baseResource.dialogId);
  dialog.find('#S3_bucket_name').html("Bucket Name : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'bucket_name')+"</code>");
  dialog.find('#S3_dns_name').html("DNS Name : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'dns_name')+"</code>");
}

S3Resource.prototype.visibilityOfConnectorPoint = function(instanceDivId){
  $('#connection-source-'+instanceDivId).hide();
}