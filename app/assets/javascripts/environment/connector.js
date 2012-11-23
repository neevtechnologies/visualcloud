//Makes the element a source for connections
function makeSource(element){
    var sourceEndPointAttributes = {
        anchor: "BottomLeft",
        endpoint: ["Dot", {radius: 7}],
        connector:[ "Bezier", { curviness:50 }],
        isSource: true,
        maxConnections: -1
    };
    jsPlumb.addEndpoint(element, sourceEndPointAttributes);
};

//Makes the element a target for connections
function makeTarget(element){
    var targetEndPointAttributes = {
        anchor: "TopLeft",
        endpoint: ["Dot", {radius: 7}],
        isTarget: true
    };
    jsPlumb.addEndpoint(element, targetEndPointAttributes);
};

//Makes the element a source as well as target for connections
function makeSourceAndTarget(element , parents_list){
    var sourceAndTargetEndPointAttributes = {
        anchor: "BottomLeft",
        endpoint: ["Dot", {radius: 4}],
        connectorStyle: { lineWidth:3, strokeStyle:'#666' },
        connector:[ "Straight"],        
        isSource: true,
        isTarget: true, 
        maxConnections: -1,
        connectorOverlays:[[ "Arrow", { width:8, length:15}]],
        beforeDrop:function(conn) { return check_for_parent_exist(conn,parents_list); }
    };
    return jsPlumb.addEndpoint(element, sourceAndTargetEndPointAttributes);
};


//Makes connections between instances
function makeConnections(instances){
    var instanceEndpoints = {} ;
    for(var key in instances){
        var element = 'instance-'+key;
        //Make the dropped element draggable - Using JS plumb draggable
        //jsPlumb.draggable(element, {containment: element.parent()})

        //Add connection endpoint to element
        var instance = instances[key];
        var parents_list = instance.configAttributes.parents_list;
        instanceEndpoints[key] = makeSourceAndTarget(element,parents_list);
        var parents = instance.parents ;
        for(var i=0; i < parents.length; i++)
          jsPlumb.connect({source: 'instance-'+parents[i], target: element,connector:[ "Straight"],anchor:"BottomLeft",endpoint: ["Dot", {radius: 4}] ,overlays:[[ "Arrow", { width:8, length:15}]]});
    }
}


function getParentDomIds(element){
  connections = jsPlumb.getConnections({target: element});
  var parentDomIds = [];
  for(var i=0; i < connections.length; i++)
    parentDomIds.push(connections[i].source.attr('id'));
  return parentDomIds;
};

function check_for_parent_exist(conn, parents_list){
  var instanceOptions = $('#'+conn.sourceId).instance("option");
  var result = false;
  if(parents_list != null){
    var parents = parents_list.split(',');
    for(var i=0; i<parents.length; i++) {
       if (parents[i] == instanceOptions.resourceType){
           result = true;
           break;
       }
   }
 }
return result;
}

$(document).ready(function(){
  // bind click listener; delete connections on click            
  jsPlumb.bind("click", function(conn) {
    jsPlumb.detach(conn);
  });
//modifying the default settings
  jsPlumb.importDefaults({
	PaintStyle : {
		lineWidth:3,
		strokeStyle: '#666'
	}
  });
});
