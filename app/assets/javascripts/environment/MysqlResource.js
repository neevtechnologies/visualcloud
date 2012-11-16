(function($) {
  $.widget("environment.MysqlResource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('mysql-configuration', droppedPosition);
    }
  });
})(jQuery);

//Mysql configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#mysql-configuration .instance-config-submit').click(function(){
    var xpos = $('#mysql-configuration').data('xpos');
    var ypos = $('#mysql-configuration').data('ypos');
    var editElement = $('#mysql-configuration').data('editElement');
    var label = $('input#mysql_label').val().trim();
    var amiId = parseInt('1');
    var InstanceTypeId = parseInt('1');
    var config_attributes = {role:['mysql','db_server']};
    if ( validateMysqlConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'Mysql', amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label, amiId: amiId, InstanceType: InstanceTypeId, configAttributes: config_attributes});
      }
      $('#mysql-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for MySQL configuration
function validateMysqlConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#mysql-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
