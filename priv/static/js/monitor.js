//TODO: leaflet: change .forEach to .eachLayer from the lib.
"use strict";

var marker_icon_colors = ['red', 'blue', 'green', 'purple', 'orange', 'darkred', 'lightred', 'beige', 'darkblue', 'darkgreen', 'cadetblue', 'darkpurple', 'white', 'pink', 'lightblue', 'lightgreen', 'gray', 'black', 'lightgray'];
var _dt_format_m = 'YYYY-MM-DD HH:mm:ss';
var _dt_format_h = 'DD/MM/YYYY HH:mm:ss';
var asset_icon = L.icon({
    iconUrl: 'images/marker-32.png',
    iconRetinaUrl: 'images/marker-512.png',
    iconSize: [18, 18]
});
var venue_icon = L.AwesomeMarkers.icon({
    markerColor: 'green', icon: 'flag'
});
Pace.options = {
  ajax: false
}
if(typeof($) === "undefined") {
  //console.log(window.location);
  window.location = "/";
}
// Lefalet shortcuts for common tile providers - is it worth adding such 1.5kb to Leaflet core?
L.TileLayer.Common = L.TileLayer.extend({
	initialize: function (options) {
		L.TileLayer.prototype.initialize.call(this, this.url, options);
	}
});
(function() {
	var osmAttr = '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>';
	L.TileLayer.OpenStreetMap = L.TileLayer.Common.extend({
		url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
		options: {attribution: osmAttr}
	});
  L.TileLayer.MapBox = L.TileLayer.Common.extend({
		url: 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}',
	});
}());
function _browser_geo_success(position) {
  //console.log("my.pos: ["+ position.coords.latitude+ "," + position.coords.longitude+ "]")
  __centralgps__.asset.map.setView([position.coords.latitude, position.coords.longitude], 12);
}
function _browser_geo_error(positionError) {
  var msg;
  switch(positionError.code) {
    case 1: msg = __centralgps__.globalmessages.__geolocation_permission_denied; break;
    case 2: msg = __centralgps__.globalmessages.__geolocation_position_unavailable; break;
    case 3: msg = __centralgps__.globalmessages.__geolocation_timeout; break;
    default: msg = "";
  }
  $.notify({text:__centralgps__.globalmessages.__online_text, image: '<i class="md-done"></i>'}, 'success');
}
function initMonitor(language_code, layers) {
  try {
    __centralgps__.timeline.container = document.getElementById('timeline');
    __centralgps__.timeline.container_height = '150px'; //$(__centralgps__.timeline.container).height()
    __centralgps__.timeline.instance = null;
    __centralgps__.timeline.items = null;
    //TODO: ver que cornos pasa con el datetimepicker que tiene problema con los 'locale' :-/
    moment.locale(language_code);
    var _t = moment();
    $('.date-time-picker').datetimepicker({locale: language_code, format: _dt_format_h});
    $('#_history_asset_start_dt').val(_t.startOf('day').format(_dt_format_h));
    $('#_history_asset_finish_dt').val(_t.endOf('day').format(_dt_format_h));
    $('#_mark_asset_start_dt').val(_t.startOf('day').format(_dt_format_h));
    $('#_mark_asset_finish_dt').val(_t.endOf('day').format(_dt_format_h));
    $('#_roadmap_start_dt').val(_t.startOf('day').format(_dt_format_h));
    $('#_roadmap_finish_dt').val(_t.endOf('day').format(_dt_format_h));
    __centralgps__.asset = { position: { layer_name: null, no_pos: [] }, history: { layer_name: null }, roadmap: { layer_name: null}, checkpoint: { mark: { layer_name: null }, venue: { layer_name: null } }};
    __centralgps__.asset.history.layer_name          = layers.history;
    __centralgps__.asset.position.layer_name         = layers.position;
    __centralgps__.asset.checkpoint.venue.layer_name = layers.venue;
    __centralgps__.asset.checkpoint.mark.layer_name  = layers.mark;
    __centralgps__.asset.roadmap.layer_name  = layers.roadmap;
    __centralgps__.asset.map = L.map('_asset_map').setView([0, 0], 2);
    L.Icon.Default.imagePath = '../images';
    __centralgps__.asset.map_layers = {
      "OpenStreetMap": new L.TileLayer.OpenStreetMap().addTo(__centralgps__.asset.map),
      "Mapbox": new L.TileLayer.MapBox({ accessToken: __centralgps__.mapbox.accessToken, id: __centralgps__.mapbox.id , maxZoom: 17}),
  	};
    __centralgps__.asset.map_overlays = {};
    // __centralgps__.asset.map_overlays[layers.position] = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.position] = new L.MarkerClusterGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.mark]     = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.venue]   = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.history] = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.roadmap] = new L.LayerGroup().addTo(__centralgps__.asset.map);
    L.control.layers(__centralgps__.asset.map_layers, __centralgps__.asset.map_overlays)
      .addTo(__centralgps__.asset.map);
    L.Control.measureControl().addTo(__centralgps__.asset.map);
    L.edgeMarker({
        icon: L.icon({ // style markers
            iconUrl: L.Icon.Default.imagePath + '/edge-arrow-marker.png',
            clickable: true,
            iconSize: [32, 32],
            iconAnchor: [24, 24]
        }),
        layerGroup: __centralgps__.asset.map_overlays[__centralgps__.asset.position.layer_name] //__centralgps__.asset.position.layer // you can specify a certain L.layerGroup to create the edge markers from.
      }).addTo(__centralgps__.asset.map);
    __centralgps__.asset.map.addControl(new L.Control.Scale());
    __centralgps__.asset.map.addControl(new L.Control.OSMGeocoder({
        collapsed: true,
        position: 'bottomright',
        text: '',
        cssclass: 'zmdi zmdi-search',
    }));
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(_browser_geo_success,_browser_geo_error);
    } else {
      _browser_geo_error;
    }
    $('#asset_grid').bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false});
    $('#mark_grid').bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false, requestHandler: mark_grid_requestHandler,});
    $('#history_grid').bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false});
    $('#roadmap_grid').bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false});
    bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
    bootgrid_appendExportControls(); //this appends the clear control to all active bootgrids.
    updateAssetGrid();
    updateVenueMap();
    updateAssetMap();
    __centralgps__.asset.refresh_interval = setInterval(function() {
      Pace.ignore(function() {
        updateAssetMap();
        updateAssetGrid();
      });
    }, 30*1000);
  }
  catch(err) {
    console.log(err);
  }
}
function mark_grid_requestHandler() {
  console("oi, im tem");
  req.searchColumn = "mark_text";
  return req;
}
var _mark_text = '';
var _mark_html_popup = '';
function setMarkTemplate(mt, mhp) {
  _mark_text = mt;
  _mark_html_popup = mhp;
  Mustache.parse(_mark_text);
  Mustache.parse(_mark_html_popup);
}
function clearMarks() {
  __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name].clearLayers();
  $("#mark_grid").bootgrid({labels: __centralgps__.bootgrid.labels}).bootgrid('clear');
  $("#_asset_map").removeClass('timeline-toggle');
  if (__centralgps__.timeline.instance != null) {
    __centralgps__.timeline.instance.destroy();
    __centralgps__.timeline.instance = null;
  }
}
function updateMarks() {
  clearMarks();
  var init   = moment($('#_mark_asset_start_dt').val(), _dt_format_h).format(_dt_format_m);
  var finish = moment($('#_mark_asset_finish_dt').val(), _dt_format_h).format(_dt_format_m);
  var selected_asset = $('#_marks_asset_list option:selected');
  if(selected_asset.val() == -1) {//All records
    $.each($('#_marks_asset_list option'), function(k, v){
      v = $(v);
      if(v.val() != -1) {//if is NOT the All <option value="option">option</option>ion
        var my_color = randomHexColor(); //TODO: control if the color repeats
        getAssetMarks({id: v.val(), name: v.text(), color: my_color}, init, finish);
      }
    });
  }
  else
    getAssetMarks({id: selected_asset.val(), name: selected_asset.text(),
      color: randomHexColor()}, init, finish);
}

function keepSelection(event, object) {
  if (event) {
    __centralgps__.selects[event.currentTarget.id] = object.selected;
    $('select').trigger('chosen:close');
  }
}
function getSelection(select) {
  return __centralgps__.selects[select];
}

function getAssetMarks(selected_asset, init, finish) {
  addLoadScreen("#mark_grid_container");
  var query_string = '?asset_id=' + selected_asset.id +
        '&init_at=' + init +
        '&stop_at=' + finish;
  $.get('/monitor/assets/checkpoint/marks' + query_string,
    function(response, status, xhr) {
      try {
        if (response.status == true) {
          var mark_list = [], point_list = [], timeline_items = [];
          var _rand_marker_icon = L.AwesomeMarkers.icon({
              markerColor: marker_icon_colors[Math.floor(Math.random() * marker_icon_colors.length)],
              icon: 'check'
          });
          response.rows.forEach(function(m, idx, arr) {
            var asset_image = 'images/profile/_placeholder.png'
            __centralgps__.asset.list.forEach(function (asset) {
              if (selected_asset.id == asset.id) asset_image = asset.asset_image
            });
            var position_at = moment(m.position_at).format(_dt_format_h);
            var executed_at = moment(m.executed_at).format(_dt_format_h);
            var finished_at = null;
            var duration = '---'
            if(m.finished_at != null) {
              finished_at = moment(m.finished_at).format(_dt_format_h);
              duration = moment.duration(moment(m.executed_at).diff(moment(m.finished_at))).humanize();
            } else {
              duration = moment.duration(moment(m.executed_at).diff(moment())).humanize();
            }
            var mark_text = Mustache.render(_mark_text, { mark: m, executed_at: executed_at, finished_at: finished_at, duration: duration });
            var mark_html_popup = Mustache.render(_mark_html_popup, {asset_image: asset_image, selected_asset_name: selected_asset.name, position_at: position_at, mark_text: mark_text});
            mark_list.push({ token: m.token, asset_name: selected_asset.name, mark_text: mark_text,
              mark_html_popup: mark_html_popup, lat: m.lat, lon: m.lon, position_at: position_at, executed_at: executed_at, finished_at: finished_at });
            point_list.push([m.lat, m.lon]);
            timeline_items.push({id: m.token, content: (idx + 1).toString(), start: m.position_at, mark: {id: m.token}});
            //var mark =
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name]
              .addLayer(L.marker([m.lat, m.lon], { mark: { token: m.token }, zIndexOffset: 108, icon: _rand_marker_icon })
              .bindPopup(mark_html_popup, {maxWidth: 920, maxHeight: 300})
              .on('click', function(){ __centralgps__.timeline.instance.focus(m.token); __centralgps__.timeline.instance.setSelection(m.token) }));
          });
          $("#mark_grid").bootgrid('append', mark_list);
          var polyline = L.polyline(point_list, {color: selected_asset.color, noClip: false}).addTo(__centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name]);
          __centralgps__.asset.map.fitBounds(polyline.getBounds());
          __centralgps__.asset.map.setZoom (__centralgps__.asset.map.getZoom()); //force a refresh event.

          __centralgps__.timeline.items = new vis.DataSet(timeline_items);
          __centralgps__.timeline.instance = new vis.Timeline(__centralgps__.timeline.container, __centralgps__.timeline.items,
                                                { height: __centralgps__.timeline.container_height, stack: false });
          $("#_asset_map").addClass('timeline-toggle');
          __centralgps__.timeline.instance.on('select', function selectTimelineItem(properties) {
              __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name].getLayers().forEach(
                function setTimelineLatLng(layer) {
                  if (layer.options.mark != null && layer.options.mark.token == __centralgps__.timeline.items.get(properties.items[0]).mark.id) {
                    layer.openPopup();
                    __centralgps__.asset.map.setView(layer.getLatLng(), __centralgps__.asset.map.getZoom());
                  }
                }
              );
          });
          setTimeout(function () {
            $(".zoomable").elevateZoom({scrollZoom: true, zoomWindowPosition: 14, tint:true, tintColour:'black', tintOpacity:0.5});
          }, 500);
        } else {
          console.log(selected_asset.name + '.updateMarks: ' + response.msg + ' - query_string: ' + query_string);
        }
      } catch (e) {
        console.log(selected_asset.name + '.updateMarks: ' + e + ' - query_string: ' + query_string);
      } finally {
        removeLoadScreen("#mark_grid_container");
      }
  });
}
var _history_text = '';
var _history_html_popup = '';
function setHistoryTemplate(ht, hhp) {
  _history_text = ht;
  _history_html_popup = hhp;
  Mustache.parse(_history_text);
  Mustache.parse(_history_html_popup);
}
function clearHistory() {
  __centralgps__.asset.map_overlays[__centralgps__.asset.history.layer_name].clearLayers();
  $("#history_grid").bootgrid({labels: __centralgps__.bootgrid.labels}).bootgrid('clear');
  $("#_asset_map").removeClass('timeline-toggle');
  if (__centralgps__.timeline.instance != null) {
    __centralgps__.timeline.instance.destroy();
    __centralgps__.timeline.instance = null;
  }
}
function updateHistory() {
  clearHistory();
  var init   = moment($('#_history_asset_start_dt').val(), _dt_format_h).format(_dt_format_m);
  var finish = moment($('#_history_asset_finish_dt').val(), _dt_format_h).format(_dt_format_m);
  var selected_asset = $('#_history_asset_list option:selected');
  if(selected_asset.val() == -1) {//All records
    $.each($('#_history_asset_list option'), function(k, v){
      v = $(v);
      if(v.val() != -1) {//if is NOT the All <option value="option">option</option>ion
        var my_color = randomHexColor(); //TODO: control if the color repeats
        getAssetHistory({id: v.val(), name: v.text(), color: my_color}, init, finish);
      }
    });
  }
  else
    getAssetHistory({id: selected_asset.val(), name: selected_asset.text(),
      color: randomHexColor()}, init, finish);
}
function getAssetHistory(selected_asset, init, finish) {
  addLoadScreen("#history_grid_container");
  var query_string = '?asset_id=' + selected_asset.id +
        '&init_at=' + init +
        '&stop_at=' + finish;
  $.get('/monitor/assets/record' + query_string,
    function(response, status, xhr) {
      try {
        if (response.status == true) {
          var history_list = [], point_list = [], timeline_items = [];
          response.rows.forEach(function(h, idx, arr) {
            //TODO: do a template accesible and configurable from outside this func.
            var asset_image = 'images/profile/_placeholder.png'
            __centralgps__.asset.list.forEach(function (asset) {
              if (selected_asset.id == asset.id) asset_image = asset.asset_image
            });
            var history_at = moment(h.position_at).format(_dt_format_h);
            var history_text = Mustache.render(_history_text, { bearing: h.bearing, speed: h.speed, accuracy: h.accuracy });
            var history_html_popup = Mustache.render(_history_html_popup, {asset_image: asset_image, selected_asset_name: selected_asset.name, history_at: history_at, history_text: history_text});
            history_list.push({ asset_name: selected_asset.name, history_text: history_text,
              history_html_popup: history_html_popup, lat: h.lat, lon: h.lon, history_at: history_at,
              position_at: h.position_at, id: h.id });
            timeline_items.push({id: h.id, content: (idx + 1).toString(), start: h.position_at, history: { id: h.id }});
            point_list.push([h.lat, h.lon]);
            __centralgps__.asset.map_overlays[__centralgps__.asset.history.layer_name]
              .addLayer(L.marker([h.lat, h.lon], { history: {id: h.id}, zIndexOffset: 1080, icon: asset_icon })
              .bindPopup(history_html_popup)
              .on('click',
              function() {__centralgps__.timeline.instance.focus(h.id); __centralgps__.timeline.instance.setSelection(h.id)}))
          });
          $("#history_grid").bootgrid('append', history_list);
          var polyline = L.polyline(point_list, {color: selected_asset.color, noClip: false}).addTo(__centralgps__.asset.map_overlays[__centralgps__.asset.history.layer_name]);
          __centralgps__.asset.map.fitBounds(polyline.getBounds());
          __centralgps__.asset.map.setZoom(__centralgps__.asset.map.getZoom()); //force a refresh event.

          __centralgps__.timeline.items = new vis.DataSet(timeline_items);
          __centralgps__.timeline.instance = new vis.Timeline(__centralgps__.timeline.container, __centralgps__.timeline.items,
                                                { height: __centralgps__.timeline.container_height, stack: false });
          $("#_asset_map").addClass('timeline-toggle');
          __centralgps__.timeline.instance.on('select', function selectTimelineItem(properties) {
              __centralgps__.asset.map_overlays[__centralgps__.asset.history.layer_name].getLayers().forEach(
                function setTimelineLatLng(layer) {
                  if (layer.options.history != null && layer.options.history.id == __centralgps__.timeline.items.get(properties.items[0]).history.id) {
                    layer.openPopup();
                    __centralgps__.asset.map.setView(layer.getLatLng(), __centralgps__.asset.map.getZoom());
                  }
                }
              );
          });
        } else {
          console.log(selected_asset.name + '.getAssetHistory: ' + response.msg + ' - query_string: ' + query_string);
        }
      } catch (e) {
        console.log(selected_asset.name + '.getAssetHistory: ' + e + ' - query_string: ' + query_string);
      } finally {
        removeLoadScreen("#history_grid_container");
      }
  });
}
function updateAssetGrid() {
  addLoadScreen("#asset_grid_container");
  $.get('/monitor/assets', function(response, status, xhr) {
    if (response.status == true) {
      var asset_list = [];
      response.rows.forEach(function(a, aidx, arr) {
        var asset = { id: a.id, name: a.name, asset_image: a.asset_image };
        a.positions.forEach(function(p, pidx, arr) {
          asset.address = p.address;
          asset.position_at = moment(p.position_at).format(_dt_format_h);
        });
        //if(asset.position_at != null)
        asset_list.push(asset);
      });
      $("#asset_grid").bootgrid({labels: __centralgps__.bootgrid.labels, caseSensitive: false})
        .bootgrid('clear')
        .bootgrid('append', asset_list);
      __centralgps__.asset.list = asset_list;
      if(__centralgps__.asset.list.length > 0) {
        //check if there is changes in the length of the loaded asset list (+1 for [All])
        //if($('#_marks_asset_list').find('option').length != (__centralgps__.asset.list.length + 1))
          chosenLoadSelect('_marks_asset_list',   __centralgps__.asset.list, 'id', 'name', keepSelection, null, null, getSelection('_marks_asset_list'));
        //if($('#_history_asset_list').find('option').length != (__centralgps__.asset.list.length + 1))
          chosenLoadSelect('_history_asset_list', __centralgps__.asset.list, 'id', 'name', keepSelection, -1, __centralgps__.globalmessages.generic._all, getSelection('_history_asset_list'));
        //if($('#_roadmap_list').find('option').length != (__centralgps__.asset.list.length + 1))
          chosenLoadSelect('_roadmap_asset_list', __centralgps__.asset.list, 'id', 'name', keepSelection, -1, __centralgps__.globalmessages.generic._all, getSelection('_roadmap_asset_list'));
          //updateRoadmapCombo({ currentTarget: $('#_roadmap_asset_list')[0]}, { selected: $('#_roadmap_asset_list').val() });
      }
    } else {
      console.log('updateAssetGrid: ' + response.msg);
    }
    removeLoadScreen("#asset_grid_container")
  });
}

var fitBoundsZoomed = false;
function updateAssetMap() {
  $.get('/monitor/assets', function(response, status, xhr) {
    if (response.status == true) {
      var latlngbounds = [];
      if (__centralgps__.asset.map_overlays[__centralgps__.asset.position.layer_name].getLayers().length > 0) {
        response.rows.forEach(function(a, aidx, arr) {
          a.positions.forEach(function(p, pidx, arr) {
            __centralgps__.asset.map_overlays[__centralgps__.asset.position.layer_name].getLayers().forEach(function(pos) {
              if(a.id == pos.options.asset.id) {
                pos.options.asset = { id: a.id };
                if (pos.getRadius != null)
                  pos.setRadius(p.accuracy);
                else {
                  latlngbounds.push([p.lat, p.lon]);
                  //pos.getPopup().setContent('<b>' + a.name + '</b><br/>' + moment(p.position_at).format(_dt_format_h));
                  pos.getLabel().setContent('<div class="text-center"><img src="' +__centralgps__.api_base_url + '/' + a.asset_image + '" alt="" style="width:50px"><br/>' + a.name + "</br><i>" + moment(p.position_at).format(_dt_format_h) + "</i></div>",
                    { direction: 'auto', noHide: false });
                }
                pos.setLatLng([p.lat, p.lon]);
              }
            });
          });
        });
      } else {
        response.rows.forEach(function(a, aidx, arr) {
          if (response.rows.length - 1 == aidx)
            __centralgps__.asset.selected = a;
          a.positions.forEach(function(p, pidx, arr) {
            latlngbounds.push([p.lat, p.lon]);
            __centralgps__.asset.map_overlays[__centralgps__.asset.position.layer_name]
              .addLayer(L.marker([p.lat, p.lon], { asset: { id: a.id }, zIndexOffset: 108, icon: asset_icon })
                //.bindPopup('<b>' + a.name + '</b><br/>' + moment(p.position_at).format(_dt_format_h))
                .bindLabel('<div class="text-center"><img src="' + __centralgps__.api_base_url + '/' + a.asset_image + '" alt="" style="width:50px"><br/>' + a.name + "</br><i>" + moment(p.position_at).format(_dt_format_h) + "</i></div>", { direction: 'auto', noHide: false }));
            // __centralgps__.asset.map_overlays[__centralgps__.asset.position.layer_name]
            //   .addLayer(L.circle([p.lat, p.lon], p.accuracy, {
            //       asset: { id: a.id }, //we dont need more information for the detection radius circle
            //       color: 'blue',
            //       colorOpacity: 0.3,
            //       fillColor: '#3483cc',
            //       fillOpacity: 0.1
            //   })
            // );
          });
        });
      }
      if(!fitBoundsZoomed) {
        fitBoundsZoomed = true;
        __centralgps__.asset.map.fitBounds(latlngbounds);
      }
    } else {
      console.log('updateAssetMap: ' + response.msg);
    }
  });
}
function updateMarkMap(asset) {
  if (asset.xtra_info != null && asset.xtra_info.checkpoint) {
    var query_string = '?asset_id=' + asset.id +
          '&init_at=' + moment().startOf('day').format(_dt_format_m) +
          '&stop_at=' + moment().endOf('day').format(_dt_format_m);
    $.get('/monitor/assets/checkpoint/marks' + query_string,
      function(response, status, xhr) {
        if (response.status == true) {
          response.rows.forEach(function(m, idx, arr) {
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name]
              .addLayer(L.marker([m.lat, m.lon], { mark: m, zIndexOffset: 108 })
              .bindPopup('<b>'+ asset.name + '@' + m.venue + '</b><br/>' + m.action +
              ' - ' + m.reason  + '<br/>' + m.comment  + '<br/>'+
              moment(m.position_at).format(_dt_format_h)));
          });
        } else {
          console.log(asset.name + '.updateMarkMap: ' + response.msg + ' - query_string: ' + query_string);
        }
    });
  }
}
function updateVenueMap() {
  Pace.ignore(function(){
    $.get('/monitor/venues', function(response, status, xhr) {
      if (response.status == true) {
        if (__centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.venue.layer_name].getLayers().length > 0) {
          response.rows.forEach(function(v, aidx, arr) {
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.venue.layer_name].getLayers().forEach(function(venue) {
              if(v.id == venue.options.venue.id) {
                venue.options.venue = { id: v.id };
                venue.setLatLng([v.lat, v.lon]);
                if (venue.getRadius != null)
                  venue.setRadius(v.detection_radius);
                else {
                  var venue_image = 'images/checkpoint/venue/_placeholder.png'
                  if (venue.image_path != null) venue_image = venue.image_path;
                  venue.getPopup().setContent('<b>' + v.name + '</b><br/><img src=\"' + __centralgps__.api_base_url + '/' + '/' + venue_image + '\" class=\"thumbnail\" style="width:150px"/>');
                }
              }
            });
          });
        } else {
          response.rows.forEach(function(v, vidx, arr) {
            var venue_image = 'images/checkpoint/venue/_placeholder.png'
            if (v.image_path != null) venue_image = v.image_path;
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.venue.layer_name].
              addLayer(L.marker([v.lat, v.lon], { venue: { id: v.id }, zIndexOffset: 108, icon: venue_icon })
                .bindPopup('<b>' + v.name + '</b><br/><img src=\"' + __centralgps__.api_base_url + '/' + venue_image + '\" class=\"thumbnail\" style="width:150px"/>'))
            //__centralgps__.asset.map
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.venue.layer_name]
              .addLayer(L.circle([v.lat, v.lon], v.detection_radius, {
                  venue: { id: v.id }, //we dont need more information for the detection radius circle
                  color: 'green',
                  fillColor: '#34cc4c',
                  fillOpacity: 0.4
              })
            );
          });
        }
      } else {
        console.log('updateVenueMap: ' + response.msg);
      }
    });
  });
}

/*
Roadmaps
*/
var _roadmap_text = '';
var _roadmap_mark_text = '';
var _roadmap_html_popup = '';
function setRoadmapTemplate(rt, rmt, rhp) {
  _roadmap_text = rt;
  _roadmap_mark_text = rmt;
  _roadmap_html_popup = rhp;
  Mustache.parse(_roadmap_text);
  Mustache.parse(_roadmap_mark_text);
  Mustache.parse(_roadmap_html_popup);
}
function clearRoadmaps() {
  __centralgps__.asset.map_overlays[__centralgps__.asset.roadmap.layer_name].clearLayers();
  $("#roadmap_grid").bootgrid({labels: __centralgps__.bootgrid.labels}).bootgrid('clear');
  $("#_asset_map").removeClass('timeline-toggle');
  if (__centralgps__.timeline.instance != null) {
    __centralgps__.timeline.instance.destroy();
    __centralgps__.timeline.instance = null;
  }
}
function updateRoadmaps() {
  clearRoadmaps();
  var init   = moment($('#_roadmap_start_dt').val(), _dt_format_h).format(_dt_format_m);
  var finish = moment($('#_roadmap_finish_dt').val(), _dt_format_h).format(_dt_format_m);
  var selected_asset = $('#_roadmap_asset_list option:selected');
  var selected_roadmap = $('#_roadmap_list option:selected');
  getAssetRoadmapPoints({id: selected_asset.val(), name: selected_asset.text(),
    color: randomHexColor()}, {id: selected_roadmap.val(), name: selected_roadmap.text()}, init, finish);
}
function getAssetRoadmapPoints(selected_asset, selected_roadmap, init, finish) {
  addLoadScreen("#roadmap_grid_container");
  var query_string = '?asset_id=' + selected_asset.id +
        '&roadmap_id=' + selected_roadmap.id +
        '&init_at=' + init +
        '&stop_at=' + finish;
  $.get('/monitor/assets/roadmap' + query_string,
    function(response, status, xhr) {
      if (response.status == true) {
        var roadmap_list = [], point_list = [], timeline_items = [];
        var _rand_marker_icon = L.AwesomeMarkers.icon({
            MarkerColor: marker_icon_colors[Math.floor(Math.random() * marker_icon_colors.length)],
            icon: 'check'
        });
        response.rows.forEach(function(m, idx, arr) {
          //TODO: do a template accesible and configurable from outside this func.
          var asset_image = 'images/profile/_placeholder.png'
          __centralgps__.asset.list.forEach(function iterateAssets(asset) {
            if (selected_asset.id == asset.id) asset_image = asset.asset_image
          });
          var roadmap_at = m.position_at != null ? moment(m.position_at).format(_dt_format_h) : "-";
          var roadmap_text = Mustache.render(_roadmap_text, { name: m.name, description: m.description, mean_arrival_time: m.mean_arrival_time, mean_leave_time: m.mean_leave_time });
          var roadmap_mark_text = "", roadmap_html_popup = "";
          if (m.position_at != null) {
            point_list.push([m.lat, m.lon]);
            timeline_items.push({id: m.token, content: (idx + 1).toString(), start: m.position_at, roadmap: {position_at: m.position_at}});
            var roadmap = __centralgps__.asset.map_overlays[__centralgps__.asset.roadmap.layer_name]
              .addLayer(L.marker([m.lat, m.lon], { roadmap: { position_at: m.position_at }, zIndexOffset: 108, icon: _rand_marker_icon })
              .bindPopup(roadmap_html_popup)
              .on('click', function(){ __centralgps__.timeline.instance.focus(m.token); __centralgps__.timeline.instance.setSelection(m.token)}));
            roadmap_mark_text = Mustache.render(_roadmap_mark_text, { venue: m.venue, action: m.action, reason: m.reason, comment: m.comment });
            roadmap_html_popup = Mustache.render(_roadmap_html_popup, {asset_image: asset_image, selected_asset_name: selected_asset.name, roadmap_at: roadmap_at, roadmap_text: roadmap_text, roadmap_mark_text: roadmap_mark_text});
          }
          roadmap_list.push({ id: m.token, asset_name: selected_asset.name, roadmap_text: roadmap_text, roadmap_mark_text: roadmap_mark_text,
            roadmap_html_popup: roadmap_html_popup, lat: m.lat, lon: m.lon, roadmap_at: roadmap_at });
        });
        $("#roadmap_grid").bootgrid('append', roadmap_list);
        if(point_list.length > 0) {
          var polyline = L.polyline(point_list, {color: selected_asset.color, noClip: false}).addTo(__centralgps__.asset.map_overlays[__centralgps__.asset.roadmap.layer_name]);
          __centralgps__.asset.map.fitBounds(polyline.getBounds());
          __centralgps__.asset.map.setZoom(__centralgps__.asset.map.getZoom()); //force a refresh event.
          __centralgps__.timeline.items = new vis.DataSet(timeline_items);
          __centralgps__.timeline.instance = new vis.Timeline(__centralgps__.timeline.container, __centralgps__.timeline.items,
                                                { height: __centralgps__.timeline.container_height, stack: false });
          $("#_asset_map").addClass('timeline-toggle');
          __centralgps__.timeline.instance.on('select', function selectTimelineItem(properties) {
              __centralgps__.asset.map_overlays[__centralgps__.asset.roadmap.layer_name].getLayers().forEach(
                function setTimelineLatLng(layer) {
                  if (layer.options.roadmap != null && layer.options.roadmap.position_at == __centralgps__.timeline.items.get(properties.items[0]).roadmap.position_at) {
                    layer.openPopup();
                    __centralgps__.asset.map.setView(layer.getLatLng(), __centralgps__.asset.map.getZoom());
                  }
                }
              );
          });
        }
      } else {
        console.log(selected_asset.name + '.updateRoadmaps: ' + response.msg + ' - query_string: ' + query_string);
      }
      removeLoadScreen("#roadmap_grid_container");
  });
}
