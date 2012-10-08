function bind_elements(){
  $( "#accordion" ).accordion({ fillSpace: true, collapsible: true })
  $('div[id|="element"]').element();
  $('.graph-area').graphArea();
  $('.graph-droppables-dock').dockArea();
};
