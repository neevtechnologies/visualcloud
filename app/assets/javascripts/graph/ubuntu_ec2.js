(function($) {
  $.widget("instances.ubuntuec2", {
    options: {
    },
    _create: function() {
      var self = this;
      options = self.options;
      element = self.element;
      element.draggable({
        revert: 'invalid',
        //Scope indicates where it should be dropped
        scope: 'element'
      });
      element.addClass("ubuntu-ec2-element");
      self._trigger('onCreate');
    },
    onDrop: function(event, ui){
      console.log('onDrop called in ubuntu instance');
      $('#ubuntuec2-configuration').modal('show');
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
