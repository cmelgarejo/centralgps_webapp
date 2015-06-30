var bootgrid_labels;

var __centralgps__ = {
  checkpoint: {},
  CRUD: {},
  globalmessages : {
    generic : {},
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
  chosen: {
    no_results_text: "CHOSEN_NO_RESULTS_TEXT"
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
      window.clearInterval(__centralgps__.asset.refresh_interval);
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
  //$.notify(notify, 'error');
  console.log(event);
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


function gridCommandFormatter(column, row)
{
  //TODO: hacer de alguna manera, llamar a algun campo de forma generica y hacer que sea el que apareca como informacion de borrado.
  return "<button type='button' class='btn btn-default cmd-edit' data-row-id='" + row.id + "'><span class='md md-edit'></span></button> " +
      "<button type='submit' class='btn btn-danger cmd-delete' data-row-id='" + row.id + "'><span class='md md-delete'></span></button>";
}

function gridImageFormatter(column, row)
{
  var image = (row[column.id] != '') ? row[column.id] : "images/_placeholder.png";
  return "<img src='" + image + "' style='width:50px'/>";
}

function gridCheckFormatter(column, row)
{
  var is_checked = (row[column.id] == true) ? "checked" : "";
  return "<input type=\"checkbox\" " + is_checked + " disabled/>";
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

function gridSetup_CRUD(gridFormatters){
  gridFormatters = typeof gridFormatters !== 'undefined' ? gridFormatters : {};
  gridFormatters["commands"] = gridCommandFormatter;
  __centralgps__.CRUD.grid = $(__centralgps__.CRUD.grid_name).bootgrid({
    css: { dropDownMenuItems: __centralgps__.CRUD.grid_css_dropDownMenuItems },
    labels: __centralgps__.bootgrid_labels,
    ajaxSettings: {method: __centralgps__.CRUD.grid_method, cache: false },
    requestHandler: function(req){ req.searchColumn = __centralgps__.CRUD.grid_search_column; return req; },
    formatters: gridFormatters,
    caseSensitive: false,
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
  bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
}

function showSuccess(message) {
  $(document).find('#alert').html("<div class='alert alert-success alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
    + message + "</div>")
}

function showError(message) {
  $(document).find('#alert').html("<div class='alert alert-danger alert-dismissible' role='alert'><button type='button' class='close' data-dismiss='alert' aria-label='X'><span aria-hidden='true'>×</span></button>"
    + message + "</div>")
}

// pre-submit callback
function ajaxformOnRequest(formData, jqForm, options) {
    // formData is an array; here we use $.param to convert it to a string to display it
    // but the form plugin does this for you automatically when it submits the data
    var queryString = $.param(formData);

    // jqForm is a jQuery object encapsulating the form element.  To access the
    // DOM element for the form do this:
    // var formElement = jqForm[0];

    jqForm.find(':button:not(:disabled)').prop('disabled',true);
    jqForm.find('#alert').html("");

    // here we could return false to prevent the form from being submitted;
    // returning anything other than false will allow the form submit to continue
    return true;
}

// post-submit callback
function ajaxformOnResponse(response, status, xhr, jqForm)  {
    // if the ajaxForm method was passed an Options Object with the dataType
    // property set to 'xml' then the first argument to the success callback
    // is the XMLHttpRequest object's responseXML property

    // if the ajaxForm method was passed an Options Object with the dataType
    // property set to 'json' then the first argument to the success callback
    // is the json data object returned by the server
    // console.log(response);
    // console.log(status);
    // console.log(jqForm);
    // console.log(xhr);
    if(response.status)
      showSuccess(response.msg);
    else
      showError(response.msg);
    setTimeout(function(){
      jqForm.find(':button:disabled').prop('disabled',false);
      if(response.status)
        get_page(__centralgps__.CRUD.index_url);
    }, 2000);
    return false;
}

function __ajaxForm(form, options) {
  options = typeof options !== 'undefined' ? options : {};
  options.target = typeof options.target !== 'undefined' ? options.target : 'form#alert';
  options.dataType = typeof options.dataType !== 'undefined' ? options.dataType : 'json';
  options.beforeSubmit = typeof options.beforeSubmit !== 'undefined' ? options.beforeSubmit : ajaxformOnRequest;
  options.success = typeof options.success !== 'undefined' ? options.success : ajaxformOnResponse;
  //console.log(options);
  // var options = {
  //       target:        target,   // target element(s) to be updated with server response
  //       beforeSubmit:  ajaxformOnRequest,  // pre-submit callback
  //       success:       ajaxformOnResponse,  // post-submit callback
  //       dataType:      dataType,
  //       // other available options:
  //       //url:       url         // override for form's 'action' attribute
  //       //type:      type        // 'get' or 'post', override for form's 'method' attribute
  //       clearForm: clearForm,         // clear all form fields after successful submit
  //       //resetForm: true        // reset the form after successful submit
  //       // $.ajax options can be used here too, for example:
  //       //timeout:   3000
  //   };
  $(form).ajaxSubmit(options);
  return false;
}

function randomHexColor() {
  return '#'+Math.floor(Math.random()*16777215).toString(16);
}

function chosenLoadSelect(select, items, value_obj, text_obj, fnChange, default_value, default_text, selected_value) {
  var $select = $('#' + select);
  $select.find('option').remove();
  var listitems = '';
  $.each(items, function(key, value){
      var selected = (selected_value != null) ? (value[value_obj] == selected_value ? 'selected' : '')  :  '';
      listitems += '<option value=' + value[value_obj] + ' ' + selected + '>' + value[text_obj] + '</option>';
  });
  //console.log(listitems);
  if(default_text != null && default_value != null)
    listitems += '<option value=' + default_value + '>' + default_text + '</option>';
  $select.append(listitems);
  $select.chosen({no_results_text: __centralgps__.chosen.no_results_text, width: "100%" }).change(fnChange);
}

function bootgrid_appendSearchControl() {
  $('.grid-container table').each(function(i, t) {
    if (!$('#' + t.id + "-search-field-clear").length)
      $('#' + t.id + '-header .input-group').append("<span id='" + t.id + "-search-field-clear' class='input-group-addon' style='vertical-align:middle;cursor:pointer'><i class='md md-close' onclick=\"bootgrid_clearSearch('" + t.id + "')\"></i></span>");
  });
}
function bootgrid_clearSearch(grid_name) {
  grid_name = '#' + grid_name + '-header .search-field.form-control';
  $(grid_name).val(null).keyup();
}
