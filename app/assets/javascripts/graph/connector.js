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

function makeTarget(element){
    var targetEndPointAttributes = {
        anchor: "TopLeft",
        endpoint: ["Dot", {radius: 7}],
        isTarget: true
    };
    jsPlumb.addEndpoint(element, targetEndPointAttributes);
};

function makeSourceAndTarget(element){
    var sourceAndTargetEndPointAttributes = {
        anchor: "TopLeft",
        endpoint: ["Dot", {radius: 7}],
        //connector:[ "Bezier", { curviness:50 }],
        connectorStyle: { lineWidth:3, strokeStyle:'#007730' },
        connector:[ "Flowchart"],
        isSource: true,
        isTarget: true, 
        maxConnections: -1
    };
    jsPlumb.addEndpoint(element, sourceAndTargetEndPointAttributes);
};

function connect(source, target){
  jsPlumb.connect({source: source, target: target});
};

$(document).ready(function(){
  // bind click listener; delete connections on click            
  jsPlumb.bind("click", function(conn) {
    jsPlumb.detach(conn);
  });
});
