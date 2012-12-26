(function($) {
  $.widget("environment.S3Resource", {
    options: {
      resourceName: null
    },
    onElementDrop: function(params){
      //Look in app/views/environments/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedElement = params.args.helper ;
      var stage = params.droppable;
      var droppedPosition = {} ;
      droppedPosition.top = droppedElement.position().top - stage.position().top ;
      droppedPosition.left = droppedElement.position().left - stage.position().left ;
      showConfigurationForm(this.options.resourceName +'-configuration', droppedPosition);
    },
    validate: function(label){
      if(label == "")
      {
        addMessagesToDiv($('#'+ this.options.resourceName +'-config-error-messages'), getErrorMessage('Label cannot be empty'));
        return false;
      }      
      else
       return true;
    },
    _create: function(){
      var resourceName = this.options.resourceName ;
      var self = this;
      $(document).ready(function(){
        //Add event listeners to Submit button of instance configuration popin
        $('div#'+ resourceName +'-configuration .instance-config-submit').click(function(){
          var xpos = $('#'+ resourceName +'-configuration').data('xpos');
          var ypos = $('#'+ resourceName +'-configuration').data('ypos');
          var editElement = $('#'+ resourceName +'-configuration').data('editElement');
          var label = $('input#'+ resourceName +'_label').val().trim();
          var accessControl = $('select#'+ resourceName +'_access_control').val().trim();          
          var parents_list = $('#'+ resourceName +'_parents_list').val().trim();
          var config_attributes = {parents_list:parents_list};
          if ( self.validate(label) ){
            if (editElement == null) {
              var newInstance = addInstanceCloneToGraph();
              newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: resourceName, accessControl: accessControl, configAttributes: config_attributes});
            }
            else {
              var existingInstance = $('#'+editElement);
              existingInstance.instance("option", {label: label, accessControl: accessControl, configAttributes: config_attributes});
            }
            $('#'+ resourceName +'-configuration').modal('hide');
          }
          return false;
        });
      });
    }
  });
})(jQuery);



