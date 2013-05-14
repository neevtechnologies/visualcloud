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
  this.showStatus(instanceOptions.configAttributes,instanceOptions.status);
  this.setOutputAttributes(instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};

EC2Resource.prototype.saveConfigAttributes = function(configAttributes){
  this.baseResource.instanceOptions.configAttributes = configAttributes;
}

EC2Resource.prototype.saveStatus = function(status){
  this.baseResource.instanceOptions.status = status;
}

EC2Resource.prototype.setOutputAttributes = function(configAttributes){
  var dialog = $('#' + this.baseResource.dialogId);
  this.setLabelURL(configAttributes);
  dialog.find('#' + this.baseResource.resourceType + '_private_ip').html("Private IP : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'private_ip')+"</code>");
  dialog.find('#' + this.baseResource.resourceType + '_public_ip').html("Public IP : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'public_ip')+"</code>");
  dialog.find('#' + this.baseResource.resourceType + '_public_dns').html("Public DNS : <code class='fnt_size'>"+getConfigAttribute(configAttributes,'public_dns_name')+"</code>");
}

EC2Resource.prototype.showStatus = function(configAttributes, status){
  var dialog = $('#' + this.baseResource.dialogId);
  if(configAttributes.hasOwnProperty("private_ip") == true){
    var image_details = {};
    image_details = get_status_image_of_instance(status);
    dialog.find('#' + this.baseResource.resourceType + '_status').html('<img src="'+image_details.image_src+'" rel="tooltip"  title="'+image_details.image_title+'" height="25px" width="25px"/>');
    if(status == "running" || status == "pending"){
      dialog.find('#' + this.baseResource.resourceType + '_stop').show();
      dialog.find('#' + this.baseResource.resourceType + '_start').hide();
    }
    else{
      dialog.find('#' + this.baseResource.resourceType + '_stop').hide();
      dialog.find('#' + this.baseResource.resourceType + '_start').show();
    }
    dialog.find('#' + this.baseResource.resourceType + '_status').show();
    dialog.find('#' + this.baseResource.resourceType + '_status').css('width','30px');
    dialog.find('#' + this.baseResource.resourceType + '_status').css('margin-left','370px');
    dialog.find('#' + this.baseResource.resourceType + '_status').css('margin-top','-30px');
  }
  else{
    dialog.find('#' + this.baseResource.resourceType + '_status').hide();
    dialog.find('#' + this.baseResource.resourceType + '_start').hide();
    dialog.find('#' + this.baseResource.resourceType + '_stop').hide();
  }
}

EC2Resource.prototype.setLabelURL = function(configAttributes){
  if(configAttributes.public_dns_name != undefined){
    var url = "http://" + configAttributes.public_dns_name ;
    this.baseResource.element.find('.instance-label').find('a').attr("href", url);
    this.baseResource.element.find('.instance-label').find('a').attr("target", "_blank");
  }
}
