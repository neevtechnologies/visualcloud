var PHPResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

PHPResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

PHPResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}
