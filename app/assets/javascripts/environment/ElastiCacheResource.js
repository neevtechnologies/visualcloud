(function($) {
  $.widget("environment.ElastiCacheResource", {
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
    validate: function(label,node_count){
      if(label == "")
      {
        addMessagesToDiv($('#'+ this.options.resourceName +'-config-error-messages'), getErrorMessage('Label cannot be empty'));
        return false;
      }
      if(!(node_count.match(/^[0-9]+$/)))
        {
        addMessagesToDiv($('#'+ this.options.resourceName +'-config-error-messages'), getErrorMessage('Node Count should be integer'));
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
          var parents_list = $('#'+ resourceName +'_parents_list').val().trim();
          var cache_security_group_names = $('#'+ resourceName +'_cache_security_group_names').val().trim();
          var node_count = $('#'+ resourceName +'_node_count').val().trim();
          var InstanceTypeId = parseInt($('#'+ resourceName +'_instance_type_id').html());
          var cache_security_group = $('#'+ resourceName +'_security_group').val().trim();
          var labelIcon = getInstanceTypeLabel(elastiCacheInstanceTypes,InstanceTypeId);
          //Change cache_security_group_names to accept multiple values from UI
          var config_attributes = {parents_list: parents_list, cache_security_group_names: [cache_security_group_names], node_count: node_count, label: labelIcon,cache_security_group:cache_security_group};
          if ( self.validate(label,node_count) ){
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
