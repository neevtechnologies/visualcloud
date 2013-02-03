(function($) {
  $.widget("graph.resourceElement", {
    options: {
      name: 'EC2',
      roles: [],
      resourceTypeId: null,
      resourceClass: null,
      widgetType: null,
      largeIcon: null
    },
    onElementDrop: function(event, params){
      var self = this;
      var options = self.options;
      var element = self.element;
      //Triggering the onElementDrop listener of any specification widgets if any
      if(element[options.widgetType] != undefined){
      element[options.widgetType]("onElementDrop", params,{resourceName: options.name, roles: options.roles});
    }},
    _create: function() {
      var self = this;
      var options = self.options;
      var element = self.element;
      options.widgetType = self.getWidgetType();

      //Binding a more specific resource type widget to element
      if(element[options.widgetType] != undefined)
        element[options.widgetType]({resourceName: options.name, roles: options.roles});

      element.draggable({
        helper: function(event){
          return element.find('img').clone();
        },
        appendTo: 'body'
      });

      //Adding the draggable class so the droppable will accept this element
      element.addClass('resourceDraggable' );
      //Listen to global onElementDrop event. Expecting the droppable widget to trigger this event
      element.bind('onElementDrop', $.proxy(self, 'onElementDrop') );

      self._trigger('onCreate');
    },
    getWidgetType: function(){
      if (this.options.resourceClass == 'EC2')
        return 'EC2TypeResource' ;
      else
        return this.options.name + 'Resource' ;
    },
    destroy: function() {
      this.element.remove();
    }
  });
})(jQuery);
