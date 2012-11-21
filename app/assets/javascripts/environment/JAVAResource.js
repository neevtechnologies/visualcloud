(function($) {
  $.widget("environment.JAVAResource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('java-configuration', droppedPosition);
    }
  });
})(jQuery);

//JAVA configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#java-configuration .instance-config-submit').click(function(){
    var xpos = $('#java-configuration').data('xpos');
    var ypos = $('#java-configuration').data('ypos');
    var editElement = $('#java-configuration').data('editElement');
    var label = $('input#java_label').val().trim();
    var parents_list = $('#java_parents_list').val();
    var amiId = parseInt($('#java_ami_id').val());
    var InstanceTypeId = parseInt($('select#java_instance_type_id').val());
    var config_attributes = {roles:['app','java'], parents_list:parents_list};
    if ( validateJAVAConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'JAVA', amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label, amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      $('#java-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for JAVA configuration
function validateJAVAConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#java-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
