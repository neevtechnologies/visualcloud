var RailsResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

RailsResource.prototype.showInstanceDialog = function(){
  this.EC2Resource.showInstanceDialog();
};

RailsResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}
