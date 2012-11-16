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
function makeSourceAndTarget(element){
    var sourceAndTargetEndPointAttributes = {
        anchor: "TopLeft",
        endpoint: ["Dot", {radius: 7}],
        connectorStyle: { lineWidth:3, strokeStyle:'#007730' },
        connector:[ "Flowchart"],
        isSource: true,
        isTarget: true, 
        maxConnections: -1
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
        instanceEndpoints[key] = makeSourceAndTarget(element);
        var instance = instances[key];
        var parents = instance.parents ;
        for(var i=0; i < parents.length; i++)
        {
            instanceEndpoints[parents[i]] = makeSourceAndTarget('instance-'+parents[i]);
          //if(sourceEndPoint && targetEndPoint)
            jsPlumb.connect({source: instanceEndpoints[parents[i]], target: instanceEndpoints[key] });
        }
    }
}


function getParentDomIds(element){
  connections = jsPlumb.getConnections({target: element});
  var parentDomIds = [];
  for(var i=0; i < connections.length; i++)
    parentDomIds.push(connections[i].source.attr('id'));
  return parentDomIds;
};

$(document).ready(function(){
  // bind click listener; delete connections on click            
  jsPlumb.bind("click", function(conn) {
    jsPlumb.detach(conn);
  });
});
