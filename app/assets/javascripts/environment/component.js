(function($) {
  $.widget("graph.component", {
    options: {
      name: '',
      componentId: null
    },
    onElementDrop: function(event, params){
      var self = this;
      var options = self.options;
      var element = self.element;
      //Triggering the onElementDrop listener of any specification widgets if any
      if(element[options.name + 'Component'] != undefined)
        element[options.name + 'Component']("onElementDrop", params);
    },
    _create: function() {
      var self = this;
      var options = self.options;
      var element = self.element;

      //Binding a more specific resource type widget to element
      if(element[options.name + 'Component'] != undefined)
        element[options.name + 'Component']();

      element.draggable({
        helper: 'clone',
        appendTo: 'body'
      });

      //Adding the draggable class so the droppable will accept this element
      element.addClass('componentDraggable' );
      element.addClass('component' + options.name );
      //Listen to global onElementDrop event. Expecting the droppable widget to trigger this event
      element.bind('onElementDrop', $.proxy(self, 'onElementDrop') );

      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }


  });
})(jQuery);
