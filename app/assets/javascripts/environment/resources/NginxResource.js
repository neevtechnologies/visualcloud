var NginxResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

NginxResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

NginxResource.prototype.saveConfigAttributes = function(configAttributes){
  this.EC2Resource.saveConfigAttributes(configAttributes);
}

NginxResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}

NginxResource.prototype.visibilityOfConnectorPoint = function(instanceDivId){
  $('#connection-source-'+instanceDivId).show();
}