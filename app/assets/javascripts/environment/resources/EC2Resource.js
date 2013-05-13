var EC2Resource = function(options){
  this.baseResource = new BaseResource(options);
  this.setLabelURL(options.configAttributes);
};

EC2Resource.prototype.dialogId = function(){
  return this.baseResource.dialogId;
};

EC2Resource.prototype.instanceOptions = function(){
  return this.baseResource.instanceOptions;
};

EC2Resource.prototype.showInstanceDialog = function(){
  var editElementId = this.baseResource.element.attr('id');
  var dialogId = this.baseResource.dialogId;
  var instanceOptions = this.baseResource.instanceOptions;
  var dialog = $('#'+dialogId);

  dialog.find('#' + this.baseResource.resourceType + '_ami_id').val(instanceOptions.configAttributes.ami_id);
  //third parameter, element id is required for setting the label on the icon
  addSlider(this.baseResource.resourceType +"-slider", instanceOptions.InstanceType, editElementId);
  $('#' + this.baseResource.resourceType + '_instance_type_id').html(instanceOptions.InstanceType);
  dialog.find('#' + this.baseResource.resourceType + '_elasticIp').prop("checked",instanceOptions.configAttributes.elasticIp);
  this.setOutputAttributes(instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

EC2Resource.prototype.saveConfigAttributes = function(configAttributes){
  this.baseResource.instanceOptions.configAttributes = configAttributes;
}

EC2Resource.prototype.setOutputAttributes = function(configAttributes){
  var dialog = $('#' + this.baseResource.dialogId);
  this.setLabelURL(configAttributes);
  dialog.find('#' + this.baseResource.resourceType + '_private_ip').html("Private IP : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'private_ip')+"</code>");
  dialog.find('#' + this.baseResource.resourceType + '_public_ip').html("Public IP : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'public_ip')+"</code>");
  dialog.find('#' + this.baseResource.resourceType + '_public_dns').html("Public DNS : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'public_dns_name')+"</code>");
}

EC2Resource.prototype.setLabelURL = function(configAttributes){
  if(configAttributes.public_dns_name != undefined){
    var url = "http://" + configAttributes.public_dns_name ;
    this.baseResource.element.find('.instance-label').find('a').attr("href", url);
    this.baseResource.element.find('.instance-label').find('a').attr("target", "_blank");
  }
}
