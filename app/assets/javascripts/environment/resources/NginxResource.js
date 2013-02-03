var NginxResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

NginxResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

NginxResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}
