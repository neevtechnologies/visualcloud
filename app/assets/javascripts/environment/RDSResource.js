(function($) {
  $.widget("environment.RDSResource", {
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
    validate: function(label, size){
      if(label == "")
      {
        addMessagesToDiv($('#'+ this.options.resourceName +'-config-error-messages'), getErrorMessage('Label cannot be empty'));
        return false;
      }
      else if(!(/[1-9]\d+|[5-9]/.test(size)) || !(!isNaN(parseFloat(size)) && isFinite(size) ))
      {
        addMessagesToDiv($('#'+ this.options.resourceName +'-config-error-messages'), getErrorMessage('Size should be a number more than 5 (5 GB).'));
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
          var InstanceTypeId = parseInt($('#'+ resourceName +'_instance_type_id').html());
          var size = $('input#'+ resourceName +'_size').val().trim();
          var username = $('input#'+ resourceName +'_master_user_name').val().trim();
          var password = $('input#'+ resourceName +'_master_password').val().trim();
          var parents_list = $('#'+ resourceName +'_parents_list').val().trim();
          var multiAZ = $('input#'+ resourceName +'_multiAZ')[0].checked
          var labelIcon = getInstanceTypeLabel(rdsInstanceTypes,InstanceTypeId);
          var config_attributes = {size:size,master_user_name:username,master_password:password,parents_list:parents_list,multiAZ:multiAZ, label: labelIcon};
          if ( self.validate(label, size) ){
            if (editElement == null) {
              var newInstance = addInstanceCloneToGraph();
              newInstance.instance({xpos: xpos, ypos: ypos, label: label, resourceType: resourceName, InstanceType: InstanceTypeId, configAttributes: config_attributes});
            }
            else {
              var existingInstance = $('#'+editElement);
              existingInstance.instance("option", {label: label, InstanceType: InstanceTypeId, configAttributes: config_attributes});
            }
            $('#'+ resourceName +'-configuration').modal('hide');
          }
          return false;
        });
      });
    }
  });
})(jQuery);

