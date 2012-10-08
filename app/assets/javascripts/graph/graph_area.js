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
          ui.draggable.element("onDrop");
        }
      });
      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
