(function($) {
  $.widget("graph.RDSResource", {
    onElementDrop: function(params){
      //Look in app/views/graphs/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      //var droppedPosition = params.args.position
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('rds-configuration', droppedPosition);
    }
  });
})(jQuery);

//configuration request and response handling
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#rds-configuration .instance-config-submit').click(function(){
    var xpos = $('#rds-configuration').data('xpos');
    var ypos = $('#rds-configuration').data('ypos');
    var editElement = $('#rds-configuration').data('editElement');
    var label = $('input#rds_label').val().trim();
    if ( validateRDSConfig(label) ) {
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'RDS'});
      }
      else {
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label});
      }
      $('#rds-configuration').modal('hide');
    }
    return false;
  });

});

function validateRDSConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#rds-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
}
