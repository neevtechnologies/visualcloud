(function($) {
  $.widget("canvas.dockArea", {
    options: {
    },
    _create: function() {
      var self = this;
      options = self.options;
      element = self.element;
      element.droppable({
        //Scope indicates where it should be dropped
        scope: 'element'
      });
      self._trigger('onCreate');
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
