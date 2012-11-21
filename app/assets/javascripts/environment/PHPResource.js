(function($) {
  $.widget("environment.PHPResource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('php-configuration', droppedPosition);
    }
  });
})(jQuery);

//PHP configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#php-configuration .instance-config-submit').click(function(){
    var xpos = $('#php-configuration').data('xpos');
    var ypos = $('#php-configuration').data('ypos');
    var editElement = $('#php-configuration').data('editElement');
    var label = $('input#php_label').val().trim();
    var parents_list = $('#php_parents_list').val();
    var amiId = parseInt($('#php_ami_id').val());
    var InstanceTypeId = parseInt($('select#php_instance_type_id').val());
    var config_attributes = {roles:['app','app-php'], parents_list:parents_list};
    if ( validatePHPConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'PHP', amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label, amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      $('#php-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for PHP configuration
function validatePHPConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#php-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
