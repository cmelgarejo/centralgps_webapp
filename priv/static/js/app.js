function excelExportHtml(table, includeCss) {
    if (includeCss) {
        var styles = [];

        //grab all styles defined on the page
        $("style").each(function (index, domEle) {
            styles.push($(domEle).html());
        });

        //grab all styles referenced by stylesheet links on the page
        var ajaxCalls = [];
        $("[rel=stylesheet]").each(function () {
            ajaxCalls.push($.get(this.href, '', function (data) {
                styles.push(data);
            }));
        });

        return $.when.apply(null, ajaxCalls)
                .then(function () {
                    return "<html><style type='text/css'>" + styles.join("\n") + "</style>\n" + table.outerHTML + "</html>";
                });
    }
    else {
        return $.when({ owcHtml: table.outerHTML })
                .then(function (result) {
                    return "<html>" + result.owcHtml + "</html>";
                });
    }
}

var __centralgps__ = {
  selects: [],
  mapbox: { accessToken: 'pk.eyJ1IjoiY2VudHJhbGdwcyIsImEiOiJjZWE3NTUzOWM5ZmZiZTAzYmE1NTM4ZGEwOTFiMzE4OSJ9.TLvKAlHfThCDEc-DaMzglQ', id: 'centralgps.f62d543f' },
  venue: { form: {} },
  roadmap: { form: {} },
  asset : { position: {} },
  monitor: {},
  CRUD: {},
  timeline: {},
  globalmessages : {
    generic : {
      _view : "View",
      _edit : "Edit",
      _delete : "Delete",
      _all : "All",
    },
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
    no_results_text: "CHOSEN_NO_RESULTS_TEXT",
    placeholder_text_multiple: "CHOSEN_PLACEHOLDER_TEXT_MULTIPLE",
    default_single_text: "CHOSEN_DEFAULT_SINGLE_TEXT",
  },
  bootgrid: {
    labels : {
        all:       "BOOTGRID_LABEL_ALL",
        infos:     "BOOTGRID_LABEL_INFOS",
        loading:   "BOOTGRID_LABEL_LOADING",
        noResults: "BOOTGRID_LABEL_NORESULTS",
        refresh:   "BOOTGRID_LABEL_REFRESH",
        search:    "BOOTGRID_LABEL_SEARCH",
    },
    showExport: false,
    exportDataType: 'basic', // basic, all, selected
    exportOptions: {}
  }
};

function get_page(resource) {
  Pace.track(function get_page_Pace() {
    $.get(resource, function get_page_replace_container(html) {
      clearInterval(__centralgps__.asset.refresh_interval); //kill the interval
      $('#_centralgps_container').html(html);
      $(document).ready(function get_page_applyWaves(){
        Waves.attach('.btn', ['waves-button', 'waves-float']); Waves.init();
      });
      $(document).ready(function get_page_applyElevateZoom(){
        setTimeout(function () {
          //$(".zoomable").elevateZoom({scrollZoom: true, zoomWindowPosition: 14, tint:true, tintColour:'black', tintOpacity:0.5});
        }, 500);
      });
    }).fail(function get_page_fail(html){
      var notify = { title: resource, text: html.responseText, image: '<i class="md-error"></i>'};
      $.notify(notify, 'error');
    });
  });
  return false;
}

function put_page(resource, grid, record) {
  Pace.track(function put_page_Pace(){
    $.ajax({
      url: resource,
      method: "PUT",
      headers: { "X-CSRF-TOKEN" : record.token },
      data: record
    }).done(function bootgrid__Done(data, status) {
        if(data.status) {
          grid.bootgrid('reload');
        } else {
          if(data.msg == "nxdomain") data.msg = _msg;
        }
    }).fail(function put_page_fail(html){
      var notify = { title: resource, text: html.responseText, image: '<i class="md-error"></i>'};
      $.notify(notify, 'error');
    });
  });
  return false;
}

$( document ).ajaxError(document_ajaxError);

function document_ajaxError( event, request, settings ) {
  var msg = "";
  switch(event.status)
  {
    case 500: msg = __centralgps__.globalmessages.__err_status_500;
      break;
    default: msg = __centralgps__.globalmessages.__err_conn_refused;
      break;
  }
  var notify = { title: settings.url, text:msg, image: '<i class="md-error"></i>'};
  $.notify(notify, 'error');
}


function hostReachable() {
  $.get(__centralgps__.globalvars.__root_url + "ping", //?r="+Math.floor((1+Math.random()) * 0x10000),
    function notify_hostReachable() {
      $.notify({text:__centralgps__.globalmessages.__online_text, image: '<i class="md-done"></i>'}, 'success');
  });
}

$(document).ready(function document_defaults(){
  $.notify.defaults({ style: 'metro', autoHideTimeout: 5000, className: 'base', arrowShow: true, arrowSize: 10 })
  if ($('[data-action="clear-localstorage"]')[0]) {
      var cls = $('[data-action="clear-localstorage"]');
      cls.on('click', function document_defaults_cls_click(e) {
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
          }, function document_defaults_localStorage_clear(){
              localStorage.clear();
              swal(__centralgps__.globalmessages._delete_record_title_done, __centralgps__.globalmessages._delete_record_text_done, "error");
          });
      });
  }
});


function gridCommandFormatter(column, row)
{
  //TODO: hacer de alguna manera, llamar a algun campo de forma generica y hacer que sea el que aparezca como informacion de borrado.
  var additional_row_info = '';
  if (__centralgps__.CRUD.grid_command_columns != null) {
    __centralgps__.CRUD.grid_command_columns.forEach(function gridCommandFormatter_aditionalInfo(k) {
      additional_row_info += " data-" + k + " = '" + row[k] + "' ";
    });
  }
  return "<button type='button' class='btn btn-default cmd-edit'  data-row-id='" + row.id + "' " + additional_row_info + " title=" + __centralgps__.globalmessages.generic._edit +   "><span class='zmdi zmdi-edit'></span></button> " +
         "<button type='submit' class='btn btn-danger cmd-delete' data-row-id='" + row.id + "' " + additional_row_info + " title=" + __centralgps__.globalmessages.generic._delete + "><span class='zmdi zmdi-delete'></span></button>";
}

function gridImageFormatter(column, row)
{
  var id = row[column.id];
  var image = (id != null && row[column.id] != '') ? row[column.id] : "images/_placeholder.png";
  return "<img class='zoomable' src='" + __centralgps__.api_base_url + "/" + image + "' data-zoom-image='" + __centralgps__.api_base_url + "/" + image + "' style='width:50px'/>";
}

function gridCheckFormatter(column, row)
{
  var is_checked = (row[column.id] == true) ? "checked" : "";
  return "<div class='checkbox col-sm-6 col-md-6'><label><input disabled type='checkbox' " + is_checked + "><i class='input-helper'></i></label></div>";
}

function bootgrid_delete(grid, delete_url, record) {
  var $that = this;
  Pace.track(function bootgrid_delete_Pace(){
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
    }, function bootgrid_delete_ajaxOnConfirm(){
      $.ajax({
        url: delete_url,
        method: "DELETE",
        headers: { "X-CSRF-TOKEN" : record.token},
        data: record
      }).done(function bootgrid_delete_Done(data, status) {
          if(data.status) {
            swal(__centralgps__.globalmessages._delete_record_title_done, data.msg, "success");
            grid.bootgrid('reload');
          } else {
            if(data.msg == "nxdomain") data.msg = _msg;
            swal(__centralgps__.globalmessages._delete_record_title_done, data.msg, "error");
          }
      }).fail(function bootgrid_delete_Fail(data, status, jqXHR) {
        swal(__centralgps__.globalmessages._delete_record_title_done, status, "error");
      });
    });
  });
}

function gridSetup_CRUD(gridFormatters, params){
  gridFormatters = (gridFormatters != null) ? gridFormatters : {};
  if(!gridFormatters.commands) gridFormatters.commands = gridCommandFormatter;
  if (!__centralgps__.CRUD.grid_command_columns) __centralgps__.CRUD.grid_command_columns = [];
  params = (params != null) ? params : __centralgps__.CRUD.grid_command_columns;
  __centralgps__.CRUD.grid = $(__centralgps__.CRUD.grid_name).bootgrid({
    css: { dropDownMenuItems: __centralgps__.CRUD.grid_css_dropDownMenuItems },
    labels: __centralgps__.bootgrid.labels,
    ajaxSettings: {method: __centralgps__.CRUD.grid_method, cache: false },
    requestHandler: gridSetup_CRUD_requestHandler,
    formatters: gridFormatters,
    caseSensitive: false
  }).on("loaded.rs.jquery.bootgrid", function gridSetup_CRUD_onLoadedBootgrid() {
    Waves.attach('.btn', ['waves-button', 'waves-float']); Waves.init();
    /* Executes after data is loaded and rendered */
    __centralgps__.CRUD.grid.find(".cmd-edit").on("click", function gridSetup_CRUD_editOnClick(e) {
      var editParams = generateCRUDGridObject($(this), params);
      var query_string = '?';
      $.map(editParams, function map_to_querystring(v, k) { query_string += '&' + k + '=' + v });
      get_page(__centralgps__.CRUD.edit_url + query_string);
    }).end().find(".cmd-view").on("click", function gridSetup_CRUD_viewOnClick(e) {
      var detailParams = generateCRUDGridObject($(this), params);
      var query_string = '?';
      $.map(detailParams, function map_to_querystring(v, k) { query_string += '&' + k + '=' + v });
      get_page(__centralgps__.CRUD.view_url + query_string);
    }).end().find(".cmd-detail").on("click", function gridSetup_CRUD_detailOnClick(e) {
      var detailParams = generateCRUDGridObject($(this), params);
      var query_string = '?';
      $.map(detailParams, function map_to_querystring(v, k) { if (k != "detail_url") query_string += '&' + k + '=' + v; });
      var detail_url = __centralgps__.CRUD.detail_url;
      if(detailParams.detail_url != null) detail_url = detailParams.detail_url;
      get_page(detail_url + query_string);
    }).end().find(".cmd-delete").on("click", function gridSetup_CRUD_deleteOnClick(e) {
      var deleteParams = generateCRUDGridObject($(this), params);
      bootgrid_delete(__centralgps__.CRUD.grid, __centralgps__.CRUD.delete_url, deleteParams);
    }).end().find(".cmd-move-up").on("click", function gridSetup_CRUD_moveUp_OnClick(e) {
      var moveUpParams = generateCRUDGridObject($(this), __centralgps__.CRUD.grid_command_columns);
      var query_string = '?';
      $.map(moveUpParams, function map_to_querystring(v, k) { query_string += '&' + k + '=' + v });
      put_page(__centralgps__.CRUD.order_url + query_string, __centralgps__.CRUD.grid, moveUpParams);
    }).end().find(".cmd-move-down").on("click", function gridSetup_CRUD_moveDown_OnClick(e) {
      var moveDownParams = generateCRUDGridObject($(this), __centralgps__.CRUD.grid_command_columns);
      var query_string = '?';
      $.map(moveDownParams, function map_to_querystring(v, k) { query_string += '&' + k + '=' + v });
      put_page(__centralgps__.CRUD.order_url + query_string, __centralgps__.CRUD.grid, moveDownParams);
    });
  });
  bootgrid_appendSearchControl(); /*this appends the clear control to all active bootgrids.*/
  //bootgrid_appendExportControls(); /*this appends the export control to all active bootgrids.*/
  bootgrid_appendPrintControls(__centralgps__.CRUD.grid_name); /*this appends the print control to all active bootgrids.*/
  return __centralgps__.CRUD.grid;
}

function gridSetup_CRUD_requestHandler(req) {
  req.searchColumn = __centralgps__.CRUD.grid_search_column;
  return req;
}

function generateCRUDGridObject(row, params) {
  var objectParams = {}
  params.forEach(function loadGridObject(k) {
    objectParams[k] = row.data(k);
  });
  /*Check if this necesary parameters exist*/
  objectParams.id    = (objectParams.id == null) ?  row.data("row-id") : objectParams.id;
  objectParams.token = (objectParams.token == null) ? __centralgps__.CRUD.form_token : objectParams.token;
  return objectParams;
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
    //  console.log(response);
    //  console.log(status);
    //  console.log(jqForm);
    //  console.log(xhr);
    if(status == 'success') {
      if(response.status) {
        showSuccess(response.msg);
        setTimeout(function ajaxformOnResponse_getPage() {
          get_page(__centralgps__.CRUD.index_url);
        }, 2000);
      } else {
        showError(response.msg);
      }
    }
    else
      showError(xhr);
    jqForm.find(':button:disabled').prop('disabled',false);
    return false;
}

function __ajaxForm(form, options) {
  options = typeof options !== 'undefined' ? options : {};
  options.target = typeof options.target !== 'undefined' ? options.target : 'form#alert';
  options.dataType = typeof options.dataType !== 'undefined' ? options.dataType : 'json';
  options.beforeSubmit = typeof options.beforeSubmit !== 'undefined' ? options.beforeSubmit : ajaxformOnRequest;
  options.success = typeof options.success !== 'undefined' ? options.success : ajaxformOnResponse;
  options.error = typeof options.error !== 'undefined' ? options.error : ajaxformOnResponse;
  //console.log(options);
  // var options = {
  //     target:        target,   // target element(s) to be updated with server response
  //     beforeSubmit:  ajaxformOnRequest,  // pre-submit callback
  //     success:       ajaxformOnResponse,  // post-submit callback
  //     dataType:      dataType,
  //     // other available options:
  //     //url:       url         // override for form's 'action' attribute
  //     //type:      type        // 'get' or 'post', override for form's 'method' attribute
  //     clearForm: clearForm,         // clear all form fields after successful submit
  //     //resetForm: true        // reset the form after successful submit
  //     // $.ajax options can be used here too, for example:
  //     //timeout:   3000
  // };
  $(form).ajaxSubmit(options);
  return false;
}

function randomHexColor() {
  return '#' + Math.floor(Math.random()*16777215).toString(16);
}

function chosenLoadSelect(select, items, value_obj, text_obj, fnChange, default_value, default_text, selected_value) {
  var $select = $(select);
  if (select.substring(0,1) != '#')
    $select = $('#' + select);
  $select.find('option').remove();
  if(items != null) {
    var listitems = '';
    $.each(items, function chosenLoadSelect_buildSelectOptions(key, value){
        var selected = (selected_value != null) ? (value[value_obj] == selected_value ? 'selected' : '')  :  '';
        listitems += '<option value=' + value[value_obj] + ' ' + selected + '>' + value[text_obj] + '</option>';
    });
    if(default_text != null)
      listitems += '<option value=' + default_value + '>' + default_text + '</option>';
    $select.append(listitems);
    $select.chosen({
      no_results_text: __centralgps__.chosen.no_results_text,
      default_single_text: __centralgps__.chosen.no_results_text,
      search_contains: true,
      allow_single_deselect: true,
      //disable_search_threshold: 5,
      width: "100%" }).change(fnChange);
  }
  $select.trigger('chosen:updated');
}

function bootgrid_appendSearchControl() {
  $('.grid-container table').each(function bootgrid_appendSearchControl_build(i, t) {
    if (!$('#' + t.id + "-search-field-clear").length)
      $('#' + t.id + '-header .input-group').append("<span id='" + t.id + "-search-field-clear' class='input-group-addon' style='vertical-align:middle;cursor:pointer'><i class='zmdi zmdi-close' onclick=\"bootgrid_clearSearch('" + t.id + "')\"></i></span>");
  });
}
function bootgrid_clearSearch(grid_name) {
  grid_name = '#' + grid_name + '-header .search-field.form-control';
  $(grid_name).val(null).keyup();
}
var TYPE_NAME = {
    json: 'JSON',
    xml: 'XML',
    png: 'PNG',
    csv: 'CSV',
    txt: 'TXT',
    sql: 'SQL',
    doc: 'MS-Word',
    excel: 'Ms-Excel',
    powerpoint: 'Ms-Powerpoint',
    pdf: 'PDF'
};
function bootgrid_appendExportControls() {
  $('.grid-container > .bootgrid-header > .row > .actionBar > .actions').each(function buildExportControls(i, t) {
    t = $(t);
    var parent_grid_header = (t.parent().parent().parent()).first();
    var parent_grid_tableExport_filename = (t.parent().parent().parent().parent()).first().data('export-filename');
    if(t) {
      var exportTypes = ['json', 'xml', 'csv', 'txt', 'excel'], menu = "";
      $.each(exportTypes, function (i, type) {
          if (TYPE_NAME.hasOwnProperty(type)) {
              menu += (['<li data-type="' + type + '" onclick="exportData(this, \'',
                      parent_grid_header[0].id.trim().replace("-header",""), '\',\'', parent_grid_tableExport_filename.trim(), '\')">',
                      '<a href="javascript:void(0)">',
                          TYPE_NAME[type],
                      '</a>',
                  '</li>'].join(''));
          }
      });
      $(['<div class="dropdown btn-group">',
        '<button class="btn btn-default dropdown-toggle waves-effect waves-button waves-float" type="button" data-toggle="dropdown" aria-expanded="false">',
        '<span class="dropdown-text"><span class="glyphicon glyphicon-export icon-share"></span>',
        '<span class="caret"></span>',
        '</button>',
        '<ul class="dropdown-menu pull-left" role="menu">',
        menu,
        '</ul>',
        '</div>'].join('')).appendTo(t);
    }
  });
}
function bootgrid_appendPrintControls() {
  $('.grid-container > .bootgrid-header > .row > .actionBar > .actions').each(function buildExportControls(i, t) {
    t = $(t);
    var parent_grid_container = (t.parent().parent().parent().parent()).first();
    var parent_grid_tableExport_filename = (t.parent().parent().parent().parent()).first().data('export-filename');
    var grid_to_print = parent_grid_container[0].id;//.replace('-header','');
    $(['<button class="btn btn-default dropdown-toggle waves-effect waves-button waves-float" type="button"',
        'onclick="print_a_div(\'', grid_to_print, '\', \'' ,parent_grid_tableExport_filename, '\')">',
        '<span class="dropdown-text"><span class="glyphicon glyphicon-print icon-print"></span>',
        '</button>'].join('')).appendTo(t);
  });
}

function print_a_div(divName, fileName) {
  $("div[id^='collapse']").collapse('show');
  var printContents = document.head.outerHTML + document.getElementById(divName).innerHTML;
  printContents = printContents.replace('pace.', 'no-pace');
  printContents = printContents.replace('<title>Checkpoint::App</title>', '<title>' + fileName + moment().format() + '</title>');
  $("div[id^='collapse']").collapse('hide');
  var w = window.open();
  w.document.write(printContents);
  setTimeout(function() { w.print(); w.close(); }, 100);
}

function exportData(option, grid, fileName) {
    if(fileName == null) fileName = grid;
    grid = '#' + grid;
    var type = $(option).data('type');
    switch(type)
    {
      case "excel":
        var tbl = excelExportHtml($(grid)[0], true).then(function(table) {
          // console.log($(table));console.log(table);
          // $(table).tableExport($.extend({}, __centralgps__.bootgrid.exportOptions, {
          //     type: type,
          //     escape: false,
          //     fileName: (fileName + moment().format())
          // }));
          // var blob = new Blob(table, {type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=utf-8"});
          // saveAs(blob, "Report.xls");

        })
        break;
      default:
        $(grid).tableExport($.extend({}, __centralgps__.bootgrid.exportOptions, {
            type: type,
            escape: false,
            fileName: (fileName + moment().format())
        }));
        doExport = function () {

        };
        if (__centralgps__.bootgrid.exportDataType === 'all' && __centralgps__.bootgrid.exportOptions) {
            doExport();
        } else if (__centralgps__.bootgrid.exportDataType === 'selected') {
            var data = $(grid).bootgrid("getCurrentRows"),
            selectedData = $(grid).bootgrid("getSelectedRows");
            $(grid).bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false})
              .bootgrid('clear')
              .bootgrid('append', selectedData);
            doExport();
            $(grid).bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false})
              .bootgrid('clear')
              .bootgrid('append', data);
        } else {
            doExport();
        }
        break;
    }
    return false;
}

function exportToExcel(){
    var htmls = "";
    var uri = 'data:application/vnd.ms-excel;base64,';
    var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>';
    var base64 = function(s) {
        return window.btoa(unescape(encodeURIComponent(s)))
    };

    var format = function(s, c) {
        return s.replace(/{(\w+)}/g, function(m, p) {
            return c[p];
        })
    };

    htmls = "YOUR HTML AS TABLE"

    var ctx = {
        worksheet : 'Worksheet',
        table : htmls
    }


    var link = document.createElement("a");
    link.download = "export.xls";
    link.href = uri + base64(format(template, ctx));
    link.click();
    document.remove(link);
}

//Binds the div with a loader, and then returns the name of the loadscreen so you can take care of it later.
function addLoadScreen(target) {
  // add the overlay with loading image to the page
  removeLoadScreen(target);
  var loadScreenName = 'loading_' + target.replace("#","").replace(".","");
  var over =
  '<div id="' + loadScreenName + '" class="loading_overlay">' +
    '<div class="loading_center">' +
      '<div class="la-ball-clip-rotate-pulse">' +
        '<div></div>' +
        '<div></div>' +
      '</div>' +
    '</div>';
  '</div>';
  $(over).appendTo(target);
  return loadScreenName;
}

function removeLoadScreen(target) {
  var loadScreenName = '#loading_' + target.replace("#","").replace(".","");
  $(loadScreenName).detach();
}

function isNumber (o) {
  return ! isNaN (o-0) && o !== null && o !== "" && o !== false;
}
