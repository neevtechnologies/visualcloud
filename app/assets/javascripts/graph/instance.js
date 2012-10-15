(function($) {
  $.widget("graph.instance", {
    options: {
      xpos: null,
      ypos: null,
      amiId: null,
      resourceType: '',
      label: ''
    },
    _create: function() {
      var self = this;
      var options = self.options;
      var element = self.element;

      //Make the dropped element draggable
      element.draggable({
        containment: 'parent'
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
      return {xpos: options.xpos, ypos: options.ypos, label: options.label, ami_id: options.amiId};
    },
    destroy: function() {
      this.element.remove();
    }


  });
})(jQuery);
