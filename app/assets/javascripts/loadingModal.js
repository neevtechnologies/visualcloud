//Show the loading modal
function showLoading(message){
  if(message == "undefined")
    message = "Please Wait..." ;
  $('#loading-text').html(message);
  $('#loading').modal('show').css({
    width: 'auto',
    'margin-top': function () {
      return -($(this).height() / 2);
    },
    'margin-left': function () {
      return -($(this).width() / 2);
    }
  });
};

//Hide the loading modal
function hideLoading(){
  $('#loading').modal('hide');
};
