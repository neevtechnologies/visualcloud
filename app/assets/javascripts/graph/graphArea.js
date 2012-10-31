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
    instances: [],
    instanceCount: 0,
    _create: function() {
      var self = this;
      var element = self.element;
      element.droppable({
        //The classes of draggables to be accepted
        accept: '.resourceDraggable',
        drop: function(event, ui){
          self._trigger('onElementDrop', event , { args: ui, droppable: $(this)} );
        }
      });
      self._trigger('onCreate');
    },
    addInstanceToStage: function(instanceElement){
      instanceElement.appendTo(this.element);
      //Give ID to the new element
      this.instanceCount++ ;
      instanceElement.attr('id', 'instance-' + this.instanceCount );
      this.instances.push(instanceElement);
    },
    save: function(graphName){
      var instances = this.instances;
      var instanceAttributes = [];
      for(var i = 0; i < instances.length; i++)
        instanceAttributes.push(instances[i].instance("getAttributes"));
      showLoading();
      $.ajax({
        url: $('#graph-save-frm').attr('action'),
        type: 'POST',
        dataType: "script",
        contentType: 'application/json',
        data: JSON.stringify({graph: {name: graphName}, instances: instanceAttributes}),
        complete: function(){
          hideLoading();
        }
      });
    },
    update: function(graphId){
      var instances = this.instances;
      var instanceAttributes = [];
      for(var i = 0; i < instances.length; i++)
        instanceAttributes.push(instances[i].instance("getAttributes"));
      showLoading();
      $.ajax({
        url: $('#graph-save-frm').attr('action')+'/'+graphId,
        type: 'PUT',
        dataType: "script",
        contentType: 'application/json',
        data: JSON.stringify({instances: instanceAttributes}),
        complete: function(){
          hideLoading();
        }
      });
    },
    destroy: function() {
      this.element.remove();
    }

  });
})(jQuery);
