(function($) {
  $.widget("graph.RDSResource", {
    onElementDrop: function(){
      console.log('RDS received element drop');
      //Look in app/views/graphs/_dialogs.html.erb to add or list all dialogs
      $('#rds-configuration').modal('show');
    }
  });
})(jQuery);
