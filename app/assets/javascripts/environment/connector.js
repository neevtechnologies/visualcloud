//Makes the element a source as well as target for connections
function makeSourceAndTarget(element , parents_list){
  var sourceAndTargetEndPointAttributes = {
    anchors: ["BottomLeft","TopLeft","TopCenter","BottomCenter"],
    endpoint: ["Dot", {radius: 4}],
    connectorStyle: { lineWidth:2, strokeStyle:'#666' },
    connector: [ "Flowchart"],
    isSource: true,
    isTarget: true,
    maxConnections: -1,
    connectorOverlays:[[ "Arrow", { width:8, length:15}]],
    beforeDrop:function(conn) { return allowParent(conn,parents_list); }
  };
  return jsPlumb.addEndpoint(element, sourceAndTargetEndPointAttributes);
}


//Makes connections between instances
function makeNodes(instances){
    for(var key in instances){
        var element = 'instance-'+key;
        var instance = instances[key];
        var parents_list = instance.configAttributes.parents_list;
        makeSourceAndTarget(element,parents_list);
    }
}

function makeConnections(instances){
    for(var key in instances){
        var element = 'instance-'+key;
        //Make the dropped element draggable - Using JS plumb draggable
        //jsPlumb.draggable(element, {containment: element.parent()})

        //Add connection endpoint to element
        var instance = instances[key];
        var parents = instance.parents ;
        for(var i=0; i < parents.length; i++) {
            sourceEndpoint = jsPlumb.selectEndpoints({source: 'instance-'+parents[i]}).get(0);
            targetEndpoint = jsPlumb.selectEndpoints({target: element}).get(0);
            jsPlumb.connect({source: sourceEndpoint, target: targetEndpoint});
        }
    }
}


function getParentDomIds(element){
  connections = jsPlumb.getConnections({target: element});
  var parentDomIds = [];
  for(var i=0; i < connections.length; i++)
    parentDomIds.push(connections[i].source.attr('id'));
  return parentDomIds;
}

function allowParent(conn, parents_list){
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
});
