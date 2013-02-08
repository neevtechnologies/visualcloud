var MysqlResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

MysqlResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

MysqlResource.prototype.saveConfigAttributes = function(configAttributes){
  this.EC2Resource.saveConfigAttributes(configAttributes);
}

MysqlResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}
