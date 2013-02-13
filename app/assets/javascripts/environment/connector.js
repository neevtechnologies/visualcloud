//Makes the element a source as well as target for connections
function makeSourceAndTarget(element){

  var sourceElement = $(element).find('.connection-source');
  jsPlumb.makeSource(sourceElement, {
    parent: element,
    anchor: "Continuous",
    endpoint: "Blank",
    connector: [ "Straight" ],
    connectorStyle: { strokeStyle:"#C6C6C6", lineWidth:2 },
    maxConnections:-1
  });

  jsPlumb.makeTarget(element, {
    anchor:"Continuous",
    endpoint: "Blank",
    beforeDrop:function(connection){
      return allowParent(connection);
    }
  });

}


//Makes connections between instances
function makeNodes(instances){
    for(var key in instances){
        var element = 'instance-'+key;
        makeSourceAndTarget(element);
    }
}

function makeConnections(instances){
    for(var key in instances){
        var element = 'instance-'+key;
        //Add connection endpoint to element
        var instance = instances[key];
        var parents = instance.parents ;
        for(var i=0; i < parents.length; i++) {
          jsPlumb.connect({source: 'instance-'+parents[i], target: element});
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

function allowParent(conn){

  //If an existing connection exists, do not attempt new connections
  if(jsPlumb.getConnections({target: $('#'+conn.targetId), source: $('#'+conn.sourceId)}).length != 0)
    return false;

  var sourceInstanceOptions =$('#'+conn.sourceId).instance("option");
  var targetInstanceOptions = $('#'+conn.targetId).instance("option");
  var parents_list = targetInstanceOptions.configAttributes.parents_list;
  if(parents_list != null){
    var parents = parents_list.split(',');
    for(i=0; i<parents.length; i++) {
      if (parents[i] == sourceInstanceOptions.resourceType){
        return true;
      }
    }
  }
  return false;
}

$(document).ready(function(){
  // bind click listener; delete connections on click
  jsPlumb.bind("click", function(conn) {
    jsPlumb.detach(conn);
  });
  jsPlumb.bind("jsPlumbConnection", function(conn) {
    conn.connection.addOverlay([ "Arrow", { location:1,width:8,length:15} ]);
  });
});
