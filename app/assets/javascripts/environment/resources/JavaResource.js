var JavaResource = function(options){
  this.EC2Resource = new EC2Resource(options);
};

JavaResource.prototype.showInstanceDialog = function(){
  var dialog = $('#'+this.EC2Resource.dialogId());
  var instanceOptions = this.EC2Resource.instanceOptions();
  dialog.find('#Java_version').val(instanceOptions.configAttributes.java_version);
  dialog.find('#Java_tomcat_version').val(instanceOptions.configAttributes.tomcat_version);
  this.EC2Resource.showInstanceDialog();
};

JavaResource.prototype.saveConfigAttributes = function(configAttributes){
  this.EC2Resource.saveConfigAttributes(configAttributes);
}

JavaResource.prototype.setOutputAttributes = function(configAttributes){
  this.EC2Resource.setOutputAttributes(configAttributes);
}
