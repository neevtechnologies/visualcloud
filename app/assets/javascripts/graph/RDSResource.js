(function($) {
  $.widget("graph.RDSResource", {
    onElementDrop: function(params){
      console.log('RDS received element drop');
      //Look in app/views/graphs/_dialogs.html.erb to see all dialogs
      //or to add a dialog for a new resource type
      var droppedPosition = params.args.position
      showConfigurationForm('rds-configuration', droppedPosition);
    }
  });
})(jQuery);

//configuration request and response handling
$(document).ready(function(){
  //Add event listeners to Submit button of instance configuration popin
  $('div#rds-configuration .instance-config-submit').click(function(){
    var xpos = $('#rds-configuration').data('xpos');
    var ypos = $('#rds-configuration').data('ypos');
    $('input#rds_xpos').val(xpos);
    $('input#rds_ypos').val(ypos);
    return true;
  });

});
