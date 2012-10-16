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

      //Make the dropped element draggable
      element.draggable({
        containment: 'parent'
      });

      //Show edit config modal on click
      element.click(function(){
        showInstanceEditForm(element.attr('id'));
      });

      //Add the inner HTML template
      element.html($('.' + options.resourceType + '-instance').html());
      element.find($('.instance-label')).html(options.label);

      //Listen to global onElementDrop event. Expecting the droppable widget to trigger this event
      //element.bind('onElementDrop', $.proxy(self, 'onElementDrop') );

      self._trigger('onCreate');
    },
    getAttributes: function(){
      var options = this.options;
      var element = this.element;
      var stage = element.parent();
      var ypos = element.position().top - stage.position().top ;
      var xpos = element.position().left - stage.position().left ;
      return {xpos: xpos, ypos: ypos, label: options.label, ami_id: options.amiId, instance_type_id: options.InstanceType, resource_type: options.resourceType };
    },
    destroy: function() {
      this.element.remove();
    }


  });
})(jQuery);
