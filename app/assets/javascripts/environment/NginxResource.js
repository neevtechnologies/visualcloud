(function($) {
  $.widget("environment.NginxResource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('nginx-configuration', droppedPosition);
    }
  });
})(jQuery);

//Nginx configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#nginx-configuration .instance-config-submit').click(function(){
    var xpos = $('#nginx-configuration').data('xpos');
    var ypos = $('#nginx-configuration').data('ypos');
    var editElement = $('#nginx-configuration').data('editElement');
    var label = $('input#nginx_label').val().trim();
    var amiId = parseInt('1');
    var InstanceTypeId = parseInt('1');
    var config_attributes = {role:['nginx','web_server']};
    if ( validateNginxConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'Nginx', amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label, amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      $('#nginx-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for Nginx configuration
function validateNginxConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#nginx-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
