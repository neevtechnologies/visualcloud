(function($) {
  $.widget("graph.EC2Resource", {
    onElementDrop: function(){
      console.log('EC2 received element drop');
      //Look in app/views/graphs/_dialogs.html.erb to add or list all dialogs
      $('#ec2-configuration').modal('show');
    }
  });
})(jQuery);