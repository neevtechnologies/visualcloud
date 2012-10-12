//Graph area

(function($) {
  $.widget("graph.graphArea", {
    options: {
      onElementDrop: function(event, params){
        //Triggers global event for any subscribers listening to this event globally
        //$.event.trigger('onElementDrop', params);

        //Triggers onElementDrop event on draggable that was dropped on this droppable
        params.args.draggable.trigger('onElementDrop', params);

      }
    },
    elements: [],
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
    addInstanceToStage: function(instanceElement){
      instanceElement.appendTo(this.element);
      this.elements.push(instanceElement);
    },
    save: function(){
      elements = this.elements;
      for(var i = 0; i < elements.length; i++)
      {
        console.log(elements[i]);
      }
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
