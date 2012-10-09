//Graph area

(function($) {
  $.widget("graph.graphArea", {
    options: {
      onElementDrop: function(event, params){
        //Triggers global event for any subscribers listening to this event globally
        $.event.trigger('onElementDrop', params);
      }
    },
    _create: function() {
      var self = this;
      var element = self.element;
      element.droppable({
        //The classes of draggables to be accepted
        accept: '.resourceDraggable',
        drop: function(event, ui){
          console.log('Element dropped. Triggering event');
          self._trigger('onElementDrop', event , { args: ui, droppable: $(this)} );
        }
      });
      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
