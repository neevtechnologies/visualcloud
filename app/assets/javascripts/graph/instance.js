(function($) {
  $.widget("graph.instance", {
    options: {
      xpos: null,
      ypos: null,
      amiId: null,
      InstanceType: null,
      resourceType: '',
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
      element.find($('.instance-label')).html(options.label);

      //Make the dropped element draggable
      element.draggable({
        containment: element.parent()
      });

      //Align the element on the stage
      element.position({
        my: 'left top',
        at: 'left top',
        of: element.parent(),
        offset: (options.xpos).toString() + ' ' + (options.ypos).toString() 
      });

      //Show edit config modal on click
      element.click(function(){
        showInstanceEditForm(element.attr('id'));
      });

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
      return {xpos: xpos, ypos: ypos, label: options.label, ami_id: options.amiId, instance_type_id: options.InstanceType, resource_type: options.resourceType };
    },
    destroy: function() {
      this.element.remove();
    }


  });
})(jQuery);
