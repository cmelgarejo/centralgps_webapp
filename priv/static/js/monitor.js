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
    markerColor: 'green'
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
    __centralgps__.asset = { position: { layer_name: null, no_pos: [] }, history: { layer_name: null }, checkpoint: { mark: { layer_name: null }, venue: { layer_name: null } }};
    __centralgps__.asset.history.layer_name          = layers.history;
    __centralgps__.asset.position.layer_name         = layers.position;
    __centralgps__.asset.checkpoint.venue.layer_name = layers.venue;
    __centralgps__.asset.checkpoint.mark.layer_name  = layers.mark;
    __centralgps__.asset.map = L.map('_asset_map').setView([0, 0], 2);
    L.Icon.Default.imagePath = '../images';
    __centralgps__.asset.map_layers = {
      "OpenStreetMap": new L.TileLayer.OpenStreetMap().addTo(__centralgps__.asset.map),
      "Mapbox": new L.TileLayer.MapBox({ accessToken: 'pk.eyJ1IjoiY2VudHJhbGdwcyIsImEiOiJjZWE3NTUzOWM5ZmZiZTAzYmE1NTM4ZGEwOTFiMzE4OSJ9.TLvKAlHfThCDEc-DaMzglQ', id: 'centralgps.f62d543f', maxZoom: 17}),
  	};
    __centralgps__.asset.map_overlays = {};
    // __centralgps__.asset.map_overlays[layers.position] = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.position] = new L.MarkerClusterGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.mark]     = new L.MarkerClusterGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.venue]   = new L.LayerGroup().addTo(__centralgps__.asset.map);
    __centralgps__.asset.map_overlays[layers.history] = new L.LayerGroup().addTo(__centralgps__.asset.map);
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
        cssclass: 'md md-search',
    }));
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(_browser_geo_success,_browser_geo_error);
    } else {
      _browser_geo_error;
    }
    $('#mark_grid').bootgrid({labels: __centralgps__.bootgrid_labels, caseSensitive: false});
    bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
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
  $("#mark_grid").bootgrid({labels: __centralgps__.bootgrid_labels}).bootgrid('clear');
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
  var selected_asset = $('#_marks_asset_list option:selected')
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
function getAssetMarks(selected_asset, init, finish) {
  var query_string = '?asset_id=' + selected_asset.id +
        '&init_at=' + init +
        '&stop_at=' + finish;
  $.get('/monitor/assets/checkpoint/marks' + query_string,
    function(response, status, xhr) {
      if (response.status == true) {
        var mark_list = [], point_list = [], timeline_items = [];
        var _rand_marker_icon = L.AwesomeMarkers.icon({
            markerColor: marker_icon_colors[Math.floor(Math.random() * marker_icon_colors.length)],
            icon: 'check'
        });
        response.rows.forEach(function(m, idx, arr) {
          //TODO: do a template accesible and configurable from outside this func.
          var asset_image = 'images/profile/_placeholder.png'
          __centralgps__.asset.list.forEach(function (asset) {
            if (selected_asset.id == asset.id) asset_image = asset.asset_image
          });
          var mark_at = moment(m.position_at).format(_dt_format_h);
          var mark_text = Mustache.render(_mark_text, { venue: m.venue, action: m.action, reason: m.reason, comment: m.comment });
          var mark_html_popup = Mustache.render(_mark_html_popup, {asset_image: asset_image, selected_asset_name: selected_asset.name, mark_at: mark_at, mark_text: mark_text});
          mark_list.push({ id: m.id, asset_name: selected_asset.name, mark_text: mark_text,
            mark_html_popup: mark_html_popup, lat: m.lat, lon: m.lon, mark_at: mark_at });
          point_list.push([m.lat, m.lon]);
          var mark = __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name]
            .addLayer(L.marker([m.lat, m.lon], { mark: { id: m.id }, zIndexOffset: 108, icon: _rand_marker_icon })
            .bindPopup(mark_html_popup));
          timeline_items.push({content: (idx + 1).toString(), start: m.position_at, mark: {id: m.id}});
        });
        $("#mark_grid").bootgrid('append', mark_list);
        var polyline = L.polyline(point_list, {color: selected_asset.color, noClip: false}).addTo(__centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name]);
        __centralgps__.asset.map.fitBounds(polyline.getBounds());
        __centralgps__.asset.map.setZoom(__centralgps__.asset.map.getZoom()); //force a refresh event.

        __centralgps__.timeline.items = new vis.DataSet(timeline_items);
        __centralgps__.timeline.instance = new vis.Timeline(__centralgps__.timeline.container, __centralgps__.timeline.items,
                                              { height: __centralgps__.timeline.container_height, stack: false });
        $("#_asset_map").addClass('timeline-toggle');
        __centralgps__.timeline.instance.on('select', function selectTimelineItem(properties) {
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.mark.layer_name].getLayers().forEach(
              function setTimelineLatLng(layer) {
                if (layer.options.mark != null && layer.options.mark.id == __centralgps__.timeline.items.get(properties.items[0]).mark.id) {
                  layer.openPopup();
                  __centralgps__.asset.map.setView(layer.getLatLng(), __centralgps__.asset.map.getZoom());
                }
              }
            );
        });
      } else {
        console.log(selected_asset.name + '.updateMarks: ' + response.msg + ' - query_string: ' + query_string);
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
  $("#history_grid").bootgrid({labels: __centralgps__.bootgrid_labels}).bootgrid('clear');
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
  var selected_asset = $('#_history_asset_list option:selected')
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
  var query_string = '?asset_id=' + selected_asset.id +
        '&init_at=' + init +
        '&stop_at=' + finish;
  $.get('/monitor/assets/record' + query_string,
    function(response, status, xhr) {
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
            position_at: h.position_at, id: h.id
          });
          timeline_items.push({content: (idx + 1).toString(), start: h.position_at, history: { id: h.id }});
          point_list.push([h.lat, h.lon]);
          __centralgps__.asset.map_overlays[__centralgps__.asset.history.layer_name]
            .addLayer(L.marker([h.lat, h.lon], { history: {id: h.id}, zIndexOffset: 1080, icon: asset_icon }) //_rand_marker_icon })
            .bindPopup(history_html_popup));
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
  });
}
function updateAssetGrid() {
  $.get('/monitor/assets', function(response, status, xhr) {
    if (response.status == true) {
      var asset_list = [];
      response.rows.forEach(function(a, aidx, arr) {
        var asset = { id: a.id, name: a.name, asset_image: a.asset_image };
        a.positions.forEach(function(p, pidx, arr) {
          asset.address = p.address;
          asset.position_at = moment(p.position_at).format(_dt_format_h);
        });
        if(asset.position_at != null)
        asset_list.push(asset);
      });
      $("#asset_grid").bootgrid({labels: __centralgps__.bootgrid_labels, caseSensitive: false})
        .bootgrid('clear')
        .bootgrid('append', asset_list);
      bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
      __centralgps__.asset.list = asset_list;
      //check if there is changes in the length of the loaded asset list (+1 for [All])
      if($('#_marks_asset_list').find('option').length != (__centralgps__.asset.list.length + 1))
        chosenLoadSelect('_marks_asset_list', __centralgps__.asset.list, 'id', 'name', null, -1, __centralgps__.globalmessages.generic._all);
      if($('#_history_asset_list').find('option').length != (__centralgps__.asset.list.length + 1))
        chosenLoadSelect('_history_asset_list', __centralgps__.asset.list, 'id', 'name', null, -1, __centralgps__.globalmessages.generic._all);
    } else {
      console.log('updateAssetGrid: ' + response.msg);
    }
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
                else
                  venue.getPopup().setContent('<b>' + v.name + '</b><br/><img src=\"' + __centralgps__.api_base_url + '/' + '/' + v.venue_image + '\" class=\"thumbnail\" style="width:150px"/>');
              }
            });
          });
        } else {
          response.rows.forEach(function(v, vidx, arr) {
            __centralgps__.asset.map_overlays[__centralgps__.asset.checkpoint.venue.layer_name].
              addLayer(L.marker([v.lat, v.lon], { venue: { id: v.id }, zIndexOffset: 108, icon: venue_icon })
                .bindPopup('<b>' + v.name + '</b><br/><img src=\"' + __centralgps__.api_base_url + '/' + v.venue_image + '\" class=\"thumbnail\" style="width:150px"/>'))
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
        console.log('.updateVenueMap: ' + response.msg);
      }
    });
  });
}
