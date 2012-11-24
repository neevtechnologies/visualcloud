(function($) {
  $.widget("environment.instance", {
    options: {
      xpos: null,
      ypos: null,
      amiId: null,
      InstanceType: null,
      instanceId: null,
      resourceType: '',
      configAttributes:{},
      label: ''
    },
    _setOption: function(key, value){
      if(key == 'label')
        this.element.find($('.instance-label')).html(value);
      //Sets the new options
      $.Widget.prototype._setOption.apply(this, arguments);
    },
    _create: function() {
      var self = this;
      var options = self.options;
      var element = self.element;
      //Add the inner HTML template      
      element.html($('.' + options.resourceType + '-instance').html());
     // element.find($('.instance-label')).html('<a href="#" target="_blank">' + options.label + '</a>');
      //element.find($('.instance-label')).html(options.label);
      element.find($('.instance-label')).html('<a id=instance-label-' + options.instanceId + ' href="#" >' + options.label + '</a>');

      //Align the element on the stage
      element.position({
        my: 'left top',
        at: 'left top',
        of: element.parent(),
        offset: (options.xpos).toString() + ' ' + (options.ypos).toString() 
      });

      jsPlumb.draggable(element, {containment: element.parent()});

      if(options.instanceId != null)
        element.attr('id', 'instance-' + options.instanceId );
      else{
      //jsPlumb.ready(function(){
        //Make the dropped element draggable - Using JS plumb draggable

        //Add connection endpoint to element
        makeSourceAndTarget(element,options.configAttributes.parents_list);
      //});
      }


      //Show edit config modal on click
      element.click(function(){
        showInstanceEditForm(element.attr('id'));        
      });
      //Do not open the dialog because it's an got to open the URL onclick
      element.find('.instance-label').click(function(e){e.stopPropagation();})

      //Listen to global onElementDrop event. Expecting the droppable widget to trigger this event
      //element.bind('onElementDrop', $.proxy(self, 'onElementDrop') );

      self._trigger('onCreate');
    },
    getAttributes: function(){
      var options = this.options;
      var element = this.element;
      var stage = element.parent();
      var ypos = element.offset().top - stage.offset().top ;
      var xpos = element.offset().left - stage.offset().left ;
      var dom_id = element.attr('id');
      var parent_dom_ids = getParentDomIds(element);
      return {xpos: xpos, ypos: ypos, label: options.label, ami_id: options.amiId, instance_type_id: options.InstanceType, resource_type: options.resourceType, config_attributes: options.configAttributes, parent_dom_ids: parent_dom_ids, dom_id: dom_id };
    },
    getConfigurationDialogId: function(){
      return this.options.resourceType.toLowerCase() + '-configuration' ;
    },
    destroy: function() {        
      this.element.remove();
    }


  });
})(jQuery);
