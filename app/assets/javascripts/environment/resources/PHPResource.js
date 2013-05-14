var PHPResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

PHPResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

PHPResource.prototype.saveConfigAttributes = function(configAttributes){
  this.EC2Resource.saveConfigAttributes(configAttributes);
}

PHPResource.prototype.saveStatus = function(status){
  this.EC2Resource.saveStatus(status);
}

PHPResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}

PHPResource.prototype.visibilityOfConnectorPoint = function(instanceDivId){
  $('#connection-source-'+instanceDivId).show();
}
