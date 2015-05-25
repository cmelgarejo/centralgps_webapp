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
