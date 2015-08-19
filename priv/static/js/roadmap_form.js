"use strict";
var _venue_center_set = false;
var _dt_format = 'YYYY-MM-DD HH:mm:ss';
var _venue_icon = L.AwesomeMarkers.icon({
    markerColor: 'orange', icon: 'bookmark'
});
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
  if(!$("#id").length) {
    __centralgps__.roadmap.form.map.setView([position.coords.latitude, position.coords.longitude], 18);
    $("#lat").val(position.coords.latitude);
    $("#lon").val(position.coords.longitude);
    //setCurrentVenuePos();
  }
}
function _browser_geo_error(positionError) {
  var msg;
  switch(positionError.code) {
    case 1: msg = __centralgps__.globalmessages.__geolocation_permission_denied; break;
    case 2: msg = __centralgps__.globalmessages.__geolocation_position_unavailable; break;
    case 3: msg = __centralgps__.globalmessages.__geolocation_timeout; break;
    default: msg = "";
  }
  //$.notify({text:__centralgps__.globalmessages.__online_text, image: '<i class="md-done"></i>'}, 'success');
}
var venue_marker = L.AwesomeMarkers.icon({
    markerColor: 'green'
});

function _updateVenueMap() {
  Pace.ignore(function(){
    $.get('/monitor/venues', function(response, status, xhr) {
      if (response.status == true) {
        response.rows.forEach(function(v, vidx, arr) {
          if ( !$('#id').length || ($('#id').val() != v.id) ) //!0 == true
          __centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.venue_layer_name].
            addLayer(L.marker([v.lat, v.lon], { venue: v, zIndexOffset: 108, icon: _venue_icon })
              .bindPopup(v.name));
          __centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.venue_layer_name]
            .addLayer(L.circle([v.lat, v.lon], v.detection_radius, {
                venue: { id: v.id }, //we dont need more information for the detection radius circle
                color: 'green',
                fillColor: '#34cc4c',
                fillOpacity: 0.5
            })
          );
        });
      } else {
        console.log('._updateVenueMap: ' + response.msg);
      }
    });
  });
}

var _rpt;
function setRoadmapPointTemplate(rpt) {
  _rpt = rpt ? rpt : '<b>{{&name}}</b> <br/>{{&description}} <br/><i>{{mean_arrival_time}} - {{mean_leave_time}}</i>';
  Mustache.parse(_rpt);
}

function loadMap(_roadmap_layer_name, _venue_layer_name) {
  try {
    __centralgps__.roadmap.form = { map: null, roadmap_layer_name: null, venue_layer_name: null, map_overlays: {} };
    __centralgps__.roadmap.form.venue_layer_name = _venue_layer_name;
    __centralgps__.roadmap.form.roadmap_layer_name = _roadmap_layer_name;
    __centralgps__.roadmap.form.map = L.map('_roadmap_map').setView([0, 0], 2);
    L.Icon.Default.imagePath = '../images';
    __centralgps__.roadmap.form.map_layers = {
      "OpenStreetMap": new L.TileLayer.OpenStreetMap().addTo(__centralgps__.roadmap.form.map),
      "Mapbox": new L.TileLayer.MapBox({ accessToken: __centralgps__.mapbox.accessToken, id: __centralgps__.mapbox.id , maxZoom: 17}),
  	};
    __centralgps__.roadmap.form.map_overlays[_venue_layer_name] = new L.LayerGroup().addTo(__centralgps__.roadmap.form.map);
    __centralgps__.roadmap.form.map_overlays[_roadmap_layer_name] = new L.LayerGroup().addTo(__centralgps__.roadmap.form.map);
    L.control.layers(__centralgps__.roadmap.form.map_layers, __centralgps__.roadmap.form.map_overlays)
      .addTo(__centralgps__.roadmap.form.map);
    L.Control.measureControl().addTo(__centralgps__.roadmap.form.map);
    __centralgps__.roadmap.form.map.addControl(new L.Control.Scale());
    __centralgps__.roadmap.form.map.addControl(new L.Control.OSMGeocoder({
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
    _updateVenueMap();
    setRoadmapPointTemplate();
    //__centralgps__.roadmap.form.map.on('click', onMapClick);
  }
  catch(err) {
    console.log(err);
  }
}

function setCurrentVenuePos() {
  current_marker.setLatLng([$('#lat').val(), $('#lon').val()]);
  current_marker_circle.setLatLng([$('#lat').val(), $('#lon').val()]);
  __centralgps__.roadmap.form.map.setView(current_marker.getLatLng(), 18);
  current_marker_popup.setContent('<b>' + $('#name').val() + '<b>').update();
  current_marker.openPopup();
  _venue_center_set = true;
}

function onMapClick(e) {
  $("#lat").val(e.latlng.lat);
  $("#lon").val(e.latlng.lng);
  //setCurrentVenuePos();
};
function current_marker_dragEnd(event){
  var p = event.target.getLatLng();
  $("#lat").val(p.lat);
  $("#lon").val(p.lng);
  //setCurrentVenuePos();
}

$(document).ready(function() {
  $('.input-latlon').mask("L0#.0000000000000", {
    translation: {
      'L': {
        pattern: /(-)?/
      }
    }
  });
  $.applyDataMask('.input-mask');
  $("form").submit(function(){return __ajaxForm(this);});
  $('#code,#description,#detection_radius,#lat,#lon').change(function() {
    if (!$(this).parent().hasClass('fg-toggled')) {
      $(this).parent().addClass('fg-toggled');
    }
  });
  loadVenueTypes();
});
function loadVenueTypes() {
  $.get('/checkpoint/venue_types/json', function(response, status, xhr) {
    if (response.status == true) {
      var venue_type_list = [];
      response.rows.forEach(function(vt, aidx, arr) {
        venue_type_list.push({ id: vt.id, description: vt.description });
      });
      chosenLoadSelect('venue_type_select', venue_type_list, 'id', 'description', fnChosenOnChange, null, null, $('#venue_type_id').val());
    } else {
      console.log('loadVenueTypes: ' + response.msg);
    }
  });
}
function fnChosenOnChange() {
  $('#venue_type_id').val($(this).val());
}

/*** Roadmap Points ***/

function getRoadmapPoints(roadmap_id) {
  var $grid = $('#roadmap_point_grid');
  addLoadScreen($grid.get(0).id);
  $.get('/client/roadmaps/' + roadmap_id + '/json',
    function(response, status, xhr) {
      if (response.status == true) {
        var point_list = [], map_point_list = [];
        var _marker_icon = L.AwesomeMarkers.icon({
            markerColor: 'blue',
            icon: 'star'
        });
        response.rows.forEach(function(rp, idx, arr) {
          //var roadmap_point_text = Mustache.render(_mark_text, { venue: m.venue, action: m.action, reason: m.reason, comment: m.comment });
          var roadmap_point_html_popup = Mustache.render(_rpt, {name: rp.name, description: rp.description,
            mean_arrival_time: rp.mean_arrival_time, mean_leave_time: rp.mean_leave_time});
          point_list.push({ id: rp.id, name: rp.name, point_order: rp.point_order, mean_arrival_time: rp.mean_arrival_time,
            mean_leave_time: rp.mean_leave_time, lat: rp.lat, lon: rp.lon, description: rp.description});
          map_point_list.push([rp.lat, rp.lon]);
          __centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.roadmap_layer_name]
            .addLayer(L.marker([rp.lat, rp.lon], { roadmap_point: { id: rp.id }, zIndexOffset: 108, icon: _marker_icon })
            .bindPopup(roadmap_point_html_popup));
        });
        $grid.bootgrid({
          css: { dropDownMenuItems: __centralgps__.CRUD.grid_css_dropDownMenuItems },
          labels: __centralgps__.bootgrid.labels,
          caseSensitive: false
        }).bootgrid('append', point_list);
        var polyline = L.polyline(map_point_list, {color: 'white', noClip: true}).addTo(__centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.roadmap_layer_name]);
        __centralgps__.roadmap.form.map.fitBounds(polyline.getBounds());
        __centralgps__.roadmap.form.map.setZoom(__centralgps__.roadmap.form.map.getZoom()); //force a refresh event.
        __centralgps__.roadmap.form.map.removeLayer(polyline);
        __centralgps__.roadmap.form.map.setZoom(__centralgps__.roadmap.form.map.getZoom()); //force a refresh event.
      } else {
        console.log('getRoadmapPoints: ' + response.msg + ' - roadmap_id: ' + roadmap_id);
      }
      removeLoadScreen($grid.get(0).id);
      bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
      bootgrid_appendExportControls(); //this appends the clear control to all active bootgrids
  });
}
