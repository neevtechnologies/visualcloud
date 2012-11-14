(function($) {
  $.widget("graph.RailsComponent", {
    onElementDrop: function(params){        
      //Look in app/views/graphs/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm('rails-configuration', droppedPosition);
    }
  });
})(jQuery);

//EC2 configuration submit
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#rails-configuration .instance-config-submit').click(function(){
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
}
