(function($) {
  $.widget("environment.ECResource", {
    onElementDrop: function(params){
      //Look in app/views/graphs/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('ec-configuration', droppedPosition);
    }
  });
})(jQuery);

//EC configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#ec-configuration .instance-config-submit').click(function(){
    var xpos = $('#ec-configuration').data('xpos');
    var ypos = $('#ec-configuration').data('ypos');
    var editElement = $('#ec-configuration').data('editElement');
    var label = $('input#ec_label').val().trim();
    if ( validateECConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'EC'});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label});
      }
      $('#ec-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for EC configuration
function validateECConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#ec-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
