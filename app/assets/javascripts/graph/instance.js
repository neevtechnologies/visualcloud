(function($) {
  $.widget("graph.instance", {
    _create: function() {
      var self = this;
      var options = self.options;
      var element = self.element;


      element.draggable({
        helper: 'clone',
        appendTo: 'body'
      });

      //Adding the draggable class so the droppable will accept this element
      element.addClass('resourceDraggable' );
      //Adding styles for this type of resource
      element.addClass('resource' + options.name );
      //Listen to global onElementDrop event. Expecting the droppable widget to trigger this event
      element.bind('onElementDrop', $.proxy(self, 'onElementDrop') );

      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }


  });
})(jQuery);
