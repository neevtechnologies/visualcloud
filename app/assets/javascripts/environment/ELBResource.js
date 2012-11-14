(function($) {
  $.widget("environment.ELBResource", {
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('elb-configuration', droppedPosition);
    }
  });
})(jQuery);

//ELB configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#elb-configuration .instance-config-submit').click(function(){
    var xpos = $('#elb-configuration').data('xpos'); 
    var ypos = $('#elb-configuration').data('ypos'); 
    var editElement = $('#elb-configuration').data('editElement');    
    var label = $('input#elb_label').val().trim();
    if ( validateELBConfig(label) ){
      if (editElement == null) {
        var newInstance = addInstanceCloneToGraph();
        newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: 'ELB'});
      }
      else {        
        var existingInstance = $('#'+editElement);
        existingInstance.instance("option", {label: label});
      }
      $('#elb-configuration').modal('hide');
    }
    return false;
  });

});

//Validation for ELB configuration
function validateELBConfig(label){
    if(label == "")
    {
      addMessagesToDiv($('#elb-config-error-messages'), getErrorMessage('Label cannot be empty'));
      return false;
    }
    else
     return true;
};
