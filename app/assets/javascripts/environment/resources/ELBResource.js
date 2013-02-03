var ELBResource = function(options){
  this.baseResource = new BaseResource(options);
  this.setLabelURL(options.configAttributes);
};

ELBResource.prototype.showInstanceDialog = function(){
  this.setOutputAttributes(this.baseResource.instanceOptions.configAttributes);
  this.baseResource.showInstanceDialog();
};


ELBResource.prototype.setOutputAttributes = function(configAttributes){
  var dialog = $('#'+this.baseResource.dialogId);
  this.setLabelURL(configAttributes);
  dialog.find('#ELB_dns_name').html("DNS Name : <code class='fnt_size'>"+configAttributes.get('dns_name')+"</code>");
}

ELBResource.prototype.setLabelURL = function(configAttributes){
  if(configAttributes.dns_name != undefined){
    var url = "http://" + configAttributes.dns_name ;
    this.baseResource.element.find('.instance-label').find('a').attr("href", url);
    this.baseResource.element.find('.instance-label').find('a').attr("target", "_blank");
  }
}
