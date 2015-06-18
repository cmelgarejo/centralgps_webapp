var bootgrid_labels;

var __centralgps__ = {
  CRUD: {},
  globalmessages : {
    _delete_record_title_sure    : "CLS_TITLE_SURE",
    _delete_record_removed       : "CLS_REMOVED",
    _delete_record_confirm_text  : "CLS_CONFIRM_TEXT",
    _delete_record_cancel_text   : "CLS_CANCEL_TEXT",
    _delete_record_title_done    : "CLS_TITLE_DONE",
    _delete_record_text_done     : "CLS_TEXT_DONE",
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
  },
  bootgrid_labels : {
      all:       "BOOTGRID_LABEL_ALL",
      infos:     "BOOTGRID_LABEL_INFOS",
      loading:   "BOOTGRID_LABEL_LOADING",
      noResults: "BOOTGRID_LABEL_NORESULTS",
      refresh:   "BOOTGRID_LABEL_REFRESH",
      search:    "BOOTGRID_LABEL_SEARCH",
  }
};

function get_page(resource) {
  Pace.track(function(){
    $.get(resource, function(html) {
      $('#_centralgps_container').html(html);
      $(document).ready(function(){
        Waves.attach('.btn', ['waves-button', 'waves-float']); Waves.init();
      });
    }).fail(function(html){ $('#_centralgps_container').html(html.responseText);});
  });
 return false;
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
  var notify = { title: settings.url, text:msg, image: '<i class="md-error"></i>'};
  console.log(notify);
  //$.notify(notify, 'error');
});


function hostReachable() {
  $.get(__centralgps__.globalvars.__root_url + "ping", //?r="+Math.floor((1+Math.random()) * 0x10000),
    function() {
      $.notify({text:__centralgps__.globalmessages.__online_text, image: '<i class="md-done"></i>'}, 'success');
  });
}

$(document).ready(function(){
  $.notify.defaults({ style: 'metro', autoHideTimeout: 5000, className: 'base', arrowShow: true, arrowSize: 10 })
  if ($('[data-action="clear-localstorage"]')[0]) {
      var cls = $('[data-action="clear-localstorage"]');
      cls.on('click', function(e) {
          e.preventDefault();
          swal({
              title: __centralgps__.globalmessages._delete_record_title_sure,
              text: __centralgps__.globalmessages._delete_record_removed,
              type: "error",
              showCancelButton: true,
              confirmButtonColor: "red",
              confirmButtonText: __centralgps__.globalmessages._delete_record_confirm_text,
              cancelButtonText: __centralgps__.globalmessages._delete_record_cancel_text,
              closeOnConfirm: false
          }, function(){
              localStorage.clear();
              swal(__centralgps__.globalmessages._delete_record_title_done, __centralgps__.globalmessages._delete_record_text_done, "error");
          });
      });
  }
});


function simpleGridCommandFormatter(column, row)
{
    return "<button type='button' class='btn btn-default cmd-edit' data-row-id='" + row.id + "'><span class='md md-edit'></span></button> " +
        "<button type='submit' class='btn btn-danger cmd-delete' data-row-id='" + row.id + "'><span class='md md-delete'></span></button>";
}

function post_on_submit_form(event) {
 event.preventDefault();
 var $that = this;
 Pace.track(function(){
   //console.log($that);
   $($that).find(':button:not(:disabled)').prop('disabled',true);
   $($that).find('#alert').html("");
   $.post($that.getAttribute('action'), $($that).serialize(),
     function(data, txtStatus, jqXHR) {
       $($that).find(':button:disabled').prop('disabled',false);
       if(data.status) {
         $($that).find('#alert').html("<div class='alert alert-success alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
           + data.msg + "</div>")
         //window.location = data.res;
       } else {
         if(data.msg == "nxdomain") data.msg = _msg;
         $($that).find('#alert').html("<div class='alert alert-danger alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
           + data.msg + "</div>")
       }
     });
  });
}

function bootgrid_delete(grid, delete_url, record) {
  var $that = this;
  Pace.track(function(){
    var _text = __centralgps__.globalmessages._delete_record_removed
      .replace("#{RECORD}", record.id)
      .replace("undefined", "")
      .replace("  ", " ");
    swal({
        title: __centralgps__.globalmessages._delete_record_title_sure,
        text: _text,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "red",
        confirmButtonText: __centralgps__.globalmessages._delete_record_confirm_text,
        cancelButtonText: __centralgps__.globalmessages._delete_record_cancel_text,
        closeOnConfirm: false
    }, function(){
      $.ajax({
        url: delete_url,
        method: "DELETE",
        headers: { "X-CSRF-TOKEN" : record.token},
        data: record
      }).done(function(data, status) {
          if(data.status) {
            swal(__centralgps__.globalmessages._delete_record_title_done, data.msg, "success");
            grid.bootgrid('reload');
          } else {
            if(data.msg == "nxdomain") data.msg = _msg;
            swal(__centralgps__.globalmessages._delete_record_title_done, data.msg, "error");
          }
      }).fail(function(data, status, jqXHR) {
        swal(__centralgps__.globalmessages._delete_record_title_done, status, "error");
      });
    });
  });
}

function gridSetup_CRUD(){
  __centralgps__.CRUD.grid = $(__centralgps__.CRUD.grid_name).bootgrid({
    css: { dropDownMenuItems: __centralgps__.CRUD.grid_css_dropDownMenuItems },
    labels: __centralgps__.bootgrid_labels,
    ajaxSettings: {method: __centralgps__.CRUD.grid_method, cache: false },
    requestHandler: function(req){ req.searchColumn = __centralgps__.CRUD.grid_search_column; return req; },
    formatters: { "commands": __centralgps__.CRUD.grid_crud_formatter }
  }).on("loaded.rs.jquery.bootgrid", function() {
    Waves.attach('.btn', ['waves-button', 'waves-float']); Waves.init();
    /* Executes after data is loaded and rendered */
    __centralgps__.CRUD.grid.find(".cmd-edit").on("click", function(e) {
      get_page(__centralgps__.CRUD.edit_url + '?id=' + $(this).data("row-id"));
    }).end().find(".cmd-delete").on("click", function(e) {
      bootgrid_delete(__centralgps__.CRUD.grid, __centralgps__.CRUD.delete_url,
        { id: $(this).data("row-id"), token: __centralgps__.CRUD.delete_token });
    });
  });
}

function showError(message) {
  $(document).find('#alert').html("<div class='alert alert-danger alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
    + message + "</div>")
}
