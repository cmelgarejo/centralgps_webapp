var __centralgps__ = {
  globalmessages : {
    _cls_title_sure    : "CLS_TITLE_SURE",
    _cls_removed       : "CLS_REMOVED",
    _cls_confirm_text  : "CLS_CONFIRM_TEXT",
    _cls_cancel_text   : "CLS_CANCEL_TEXT",
    _cls_title_done    : "CLS_TITLE_DONE",
    _cls_text_done     : "CLS_TEXT_DONE",
    __err_conn_refused : "__ERR_CONNECTION_REFUSED",
    __err_status_500   : "__ERR_STATUS_500",
    __online_title     : "__ONLINE_TITLE",
    __online_text      : "__ONLINE_TEXT",
    __geolocation_message_title        : "__GEOLOCATION_MESSAGE_TITLE",
    __geolocation_permission_denied    : "__GEOLOCATION_PERMISSION_DENIED",
    __geolocation_position_unavailable : "__GEOLOCATION_POSITION_UNAVAILABLE",
    __geolocation_timeout              : "__GEOLOCATION_TIMEOUT",
  },
  globalvars : {
    __root_url : "/",
  }
};

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
    case 500: msg = __centralgps__.globalmessages.__err_status_500;
      break;
    default: msg = __centralgps__.globalmessages.__err_conn_refused;
      break;
  }
  console.log(event);
  $.notify({title: settings.url, text:msg, image: '<i class="md-error"></i>'}, 'error');
});


function hostReachable() {
  $.get(__centralgps__.globalvars.__root_url + "ping", //?r="+Math.floor((1+Math.random()) * 0x10000),
    function() {
      $.notify({text:__centralgps__.globalmessages.__online_text, image: '<i class="md-done"></i>'}, 'success');
  });
}

$(document).ready(function(){
  $.notify.defaults({ style: 'metro', autoHide: false, className: 'base', arrowShow: true, arrowSize: 10 })
  if ($('[data-action="clear-localstorage"]')[0]) {
      var cls = $('[data-action="clear-localstorage"]');
      cls.on('click', function(e) {
          e.preventDefault();
          swal({
              title: __centralgps__.globalmessages._cls_title_sure,
              text: __centralgps__.globalmessages._cls_removed,
              type: "warning",
              showCancelButton: true,
              confirmButtonColor: "#DEADDEAD",
              confirmButtonText: __centralgps__.globalmessages._cls_confirm_text,
              cancelButtonText: __centralgps__.globalmessages._cls_cancel_text,
              closeOnConfirm: false
          }, function(){
              localStorage.clear();
              swal(__centralgps__.globalmessages._cls_title_done, __centralgps__globalmessages._cls_text_done, "success");
          });
      });
  }
});
