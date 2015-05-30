function get_page(resource) {
  Pace.track(function(){
    $.get(resource, function(html){$('#_centralgps_container').html(html);})
    .fail(function(html){ $('#_centralgps_container').html(html.responseText);});
  });
 return false;
}


function on_submit_form(event) {
 event.preventDefault();
 $that = this;
 Pace.track(function(){
   $.ajax($that.getAttribute('action'), $($that).serialize(),
   function(data, status, xhr) {
     $($that).find(':button:disabled').prop('disabled',false);
     $($that).find('#password').val("");
     if(data.status) {
       //window.location = data.res;
     } else {
       if(data.msg == "nxdomain") data.msg = _msg;
       $($that).find('#alert').html("<div class='alert alert-danger alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
         + data.msg + "</div>")
     }
   });
  });
}

$( document ).ajaxError(function( event, request, settings ) {
  var msg = "";
  switch(event.status)
  {
    case 500: msg = __centralgps__.__err_status_500;
      break;
    default: msg = __centralgps__.__err_conn_refused;
      break;
  }
  console.log(event)
  Snarl.addNotification({
    title: settings.url, text: msg, icon: '<i class="md md-error"></i>'
  });
});


function hostReachable() {
  $.get(__centralgps__.__root_url + "/ping", //?r="+Math.floor((1+Math.random()) * 0x10000),
    function() { Snarl.addNotification({
        title: __centralgps__.__online_title,
        text:  __centralgps__.__online_text,
        icon: '<i class="md-done"></i>'
      });
  });
}
