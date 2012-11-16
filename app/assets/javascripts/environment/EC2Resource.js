(function($) {
  $.widget("environment.EC2Resource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('ec2-configuration', droppedPosition);
    }
  });
})(jQuery);

//EC2 configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#ec2-configuration .instance-config-submit').click(function(){
    var xpos = $('#ec2-configuration').data('xpos');
    var ypos = $('#ec2-configuration').data('ypos');
    var editElement = $('#ec2-configuration').data('editElement');
    var label = $('input#ec2_label').val().trim();
    var amiId = parseInt($('select#ec2_ami_id').val());
    var InstanceTypeId = parseInt($('select#ec2_instance_type_id').val());
    var web_server = '0';
    var app_server = '0';
    var db_server = '0';
    if($('input#ec2_web').is(':checked'))
        web_server = '1';
    if($('input#ec2_app').is(':checked'))
        app_server = '1';
    if($('input#ec2_db').is(':checked'))
        db_server = '1';
    var config_attributes = {app_server:app_server,web_server:web_server,db_server:db_server};
    if ( validateEC2Config(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'EC2', amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label, amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      $('#ec2-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for EC2 configuration
function validateEC2Config(label){
    if(label == "")
    {
      addMessagesToDiv($('#ec2-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
