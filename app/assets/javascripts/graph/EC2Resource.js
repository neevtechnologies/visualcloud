(function($) {
  $.widget("graph.EC2Resource", {
    onElementDrop: function(){
      console.log('EC2 received element drop');
      $('#ubuntuec2-configuration').modal('show');
    }
  });
})(jQuery);
