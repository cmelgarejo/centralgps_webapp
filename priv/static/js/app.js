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
  Snarl.addNotification({
        title: 'Error requesting page, you might be offline',
        text: '<li>' + settings.url + '</li>',
    });
});


function hostReachable() {
  // Handle IE and more capable browsers
  var xhr = new ( window.ActiveXObject || XMLHttpRequest )( "Microsoft.XMLHTTP" );
  var status;
  // Open new request as a HEAD to the root hostname with a random param to bust the cache
  xhr.open( "GET", "//" + window.location.hostname + "/ping?rand=" + Math.floor((1 + Math.random()) * 0x10000), false );
  // Issue request and handle response
  try {
    xhr.send();
    return swal('offline!');
  } catch (error) {
    return swal('error');
  }
}
