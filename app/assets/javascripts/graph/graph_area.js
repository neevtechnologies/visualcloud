(function($) {
  $.widget("canvas.graphArea", {
    options: {
    },
    _create: function() {
      var self = this;
      options = self.options;
      element = self.element;
      element.droppable({
        //Scope indicates where it should be dropped
        scope: 'element',
        drop: function(event, ui){
          console.log('dropped');
          console.log(ui.helper);
          ui.draggable.element("onDrop", event, this);
          //This should add a clone to droppable . Move it to each resource if need be
          //$(this).append(ui.draggable.clone());
        }
      });
      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
