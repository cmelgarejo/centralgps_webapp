"use strict";
var current_marker = new L.marker([0,0], {icon: marker, draggable:'true'});
var current_marker_popup = new L.Popup();
var current_marker_circle = current_marker_circle = L.circle([0,0], 0, {
    color: 'blue',
    fillColor: '#0034ff',
    fillOpacity: 0.5
});

var _dt_format = 'YYYY-MM-DD HH:mm:ss';
var _venue_icon = L.AwesomeMarkers.icon({
    markerColor: 'orange', icon: 'bookmark'
});

function roadmapPoint_popupContent() {
  return {name: $('#name').val(), description: $('#description').val(),
    mean_arrival_time: $('#mean_arrival_time').val(), mean_leave_time: $('#mean_leave_time').val()};
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
  if(!$("#id").length && __centralgps__.roadmap.form.map != null) {
    __centralgps__.roadmap.form.map.setView([position.coords.latitude, position.coords.longitude], 18);
    $("#lat").val(position.coords.latitude);
    $("#lon").val(position.coords.longitude);
    setCurrentRoadmapPointPos();
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

var marker = L.AwesomeMarkers.icon({
    markerColor: 'blue'
});

var available_venues = [];
function _updateVenueMap() {
  Pace.ignore(function(){
    $.get('/monitor/venues', function(response, status, xhr) {
      if (response.status == true) {
        available_venues = response.rows;
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
      chosenLoadSelect('venue_id_select', available_venues, 'id', 'name', fnChosen_VenueOnChange, null, null, $('#venue_id').val());
      fnChosen_VenueOnChange(null, { selected: $('#venue_id').val()})
    });
  });
}

function fnChosen_VenueOnChange(event, object) {
  $('#venue_id').val(object.selected);
  available_venues.forEach(function findVenue(v, vidx, arr) {
    if(object.selected == v.id) {
      $("#lat").val(v.lat);
      $("#lon").val(v.lon);
      $('#venue_id').val(v.id);
    }
  });
  setCurrentRoadmapPointPos();
}

var available_forms  = [];
function _updateForms() {
  Pace.ignore(function(){
    $.get('/checkpoint/forms/json', function(response, status, xhr) {
      if (response.status == true) {
        available_forms = response.rows;
      } else {
        console.log('._updateForms: ' + response.msg);
      }
      chosenLoadSelect('form_id_select', available_forms, 'id', 'description', fnChosen_FormsOnChange, null, null, $('#form_id').val());
      fnChosen_FormsOnChange(null, { selected: $('#venue_id').val()})
    });
  });
}

function fnChosen_FormsOnChange(event, object) {
  $('#form_id').val(object.selected);
}

var _rpt;
function setRoadmapPointTemplate(rpt) {
  _rpt = rpt ? rpt : '<b>{{&name}}</b> <br/>{{&description}} <br/><i>{{mean_arrival_time}} - {{mean_leave_time}}</i>';
  Mustache.parse(_rpt);
}

function loadMap(_roadmap_layer_name, _venue_layer_name, edit_roadmap_points) {
  // try {
    if(!edit_roadmap_points) edit_roadmap_points = false;
    setRoadmapPointTemplate();
    __centralgps__.roadmap.form = { map: null, roadmap_layer_name: null, venue_layer_name: null, map_overlays: {} };
    if(_venue_layer_name) __centralgps__.roadmap.form.venue_layer_name = _venue_layer_name;
    __centralgps__.roadmap.form.roadmap_layer_name = _roadmap_layer_name;
    __centralgps__.roadmap.form.map = L.map('_roadmap_map').setView([0, 0], 2);
    L.Icon.Default.imagePath = '../images';
    __centralgps__.roadmap.form.map_layers = {
      "OpenStreetMap": new L.TileLayer.OpenStreetMap().addTo(__centralgps__.roadmap.form.map),
      "Mapbox": new L.TileLayer.MapBox({ accessToken: __centralgps__.mapbox.accessToken, id: __centralgps__.mapbox.id , maxZoom: 17}),
  	};
    if(_venue_layer_name) __centralgps__.roadmap.form.map_overlays[_venue_layer_name] = new L.LayerGroup().addTo(__centralgps__.roadmap.form.map);
    __centralgps__.roadmap.form.map_overlays[_roadmap_layer_name] = new L.LayerGroup().addTo(__centralgps__.roadmap.form.map);
    L.control.layers(__centralgps__.roadmap.form.map_layers, __centralgps__.roadmap.form.map_overlays)
      .addTo(__centralgps__.roadmap.form.map);
    // L.Control.measureControl().addTo(__centralgps__.roadmap.form.map);
    __centralgps__.roadmap.form.map.addControl(new L.Control.Scale());
    __centralgps__.roadmap.form.map.addControl(new L.Control.OSMGeocoder({
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
    _updateForms();
    if(_venue_layer_name) _updateVenueMap();
    if(edit_roadmap_points) {
      current_marker = new L.marker([0,0], {icon: marker, draggable:'true'}).bindPopup(current_marker_popup);
      current_marker_circle = L.circle([0,0], 0, {
          color: 'blue',
          fillColor: '#0034ff',
          fillOpacity: 0.5
      });
      __centralgps__.roadmap.form.map.addLayer(current_marker);
      __centralgps__.roadmap.form.map.addLayer(current_marker_circle);
      __centralgps__.roadmap.form.map.on('click', onMapClick);
      $("#detection_radius").on('keyup', function() {
        current_marker_circle.setRadius($(this).val());
      });
      $('#name').change(setCurrentRoadmapPointPos());
      $('#name').on('keyup', setCurrentRoadmapPointPos());

      $('#description').change(setCurrentRoadmapPointPos());
      $('#description').on('keyup', setCurrentRoadmapPointPos());

      $("#lat").change(setCurrentRoadmapPointPos());
      $("#lat").on('keyup', setCurrentRoadmapPointPos());

      $("#lon").change(setCurrentRoadmapPointPos());
      $("#lon").on('keyup', setCurrentRoadmapPointPos());

      $("#mean_arrival_time").change(setCurrentRoadmapPointPos());
      $("#mean_arrival_time").on('keyup', setCurrentRoadmapPointPos());

      $("#mean_leave_time").change(setCurrentRoadmapPointPos());
      $("#mean_leave_time").on('keyup', setCurrentRoadmapPointPos());
      current_marker.on('dragend', current_marker_dragEnd);
      setCurrentRoadmapPointPos()
    }
}

function setCurrentRoadmapPointPos() {
  if(current_marker && current_marker_circle) {
    current_marker.setLatLng([$('#lat').val(), $('#lon').val()]);
    current_marker_circle.setLatLng([$('#lat').val(), $('#lon').val()]);
    var latlng = current_marker.getLatLng();
    if(latlng != null && latlng.lat != 0 && latlng.lng != 0) {
      __centralgps__.roadmap.form.map.setView(latlng, 18);
      current_marker_popup.setContent(Mustache.render(_rpt, roadmapPoint_popupContent())).update();
      current_marker.openPopup();
    }
  }
}

function onMapClick(e) {
  $("#lat").val(e.latlng.lat);
  $("#lon").val(e.latlng.lng);
  setCurrentRoadmapPointPos();
};
function current_marker_dragEnd(event){
  var p = event.target.getLatLng();
  $("#lat").val(p.lat);
  $("#lon").val(p.lng);
  setCurrentRoadmapPointPos();
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
  $.each($('input, select'), function(a, b) {
    var input = $(b).val();
    if(input) {
      if (!$(b).parent().hasClass('fg-toggled')) {
        $(b).parent().addClass('fg-toggled');
      }
    }
  });
});

/*** Roadmap Points ***/
function activateGrid() {
  var $grid = $('#grid');
  $grid.bootgrid({
    css: { dropDownMenuItems: __centralgps__.CRUD.grid_css_dropDownMenuItems },
    labels: __centralgps__.bootgrid.labels,
    caseSensitive: false
  });
  bootgrid_appendSearchControl(); //this appends the clear control to all active bootgrids.
  bootgrid_appendExportControls(); //this appends the clear control to all active bootgrids
}
function getRoadmapPoints(roadmap_id) {
  try {
    $.get('/client/roadmap/point/json?roadmap_id=' + roadmap_id,
      function(response, status, xhr) {
        if (response.status == true) {
          var point_list = [], map_point_list = [];
          var _marker_icon = L.AwesomeMarkers.icon({
              markerColor: 'green',
              icon: 'star'
          });
          //console.log(response.rows);
          response.rows.forEach(function(rp, idx, arr) {
            //var text = Mustache.render(_mark_text, { venue: m.venue, action: m.action, reason: m.reason, comment: m.comment });
            var html_popup = Mustache.render(_rpt, {name: rp.name, description: rp.description,
              mean_arrival_time: rp.mean_arrival_time, mean_leave_time: rp.mean_leave_time});
            point_list.push({ id: rp.id, name: rp.name, point_order: rp.point_order, mean_arrival_time: rp.mean_arrival_time,
              mean_leave_time: rp.mean_leave_time, lat: rp.lat, lon: rp.lon, description: rp.description});
            map_point_list.push([rp.lat, rp.lon]);
            __centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.roadmap_layer_name]
              .addLayer(L.marker([rp.lat, rp.lon], { roadmap_point: { id: rp.id }, zIndexOffset: 108, icon: _marker_icon })
              .bindPopup(html_popup));
          });
          var polyline = L.polyline(map_point_list, {color: 'white', noClip: true}).addTo(__centralgps__.roadmap.form.map_overlays[__centralgps__.roadmap.form.roadmap_layer_name]);
          __centralgps__.roadmap.form.map.fitBounds(polyline.getBounds());
          __centralgps__.roadmap.form.map.setZoom(__centralgps__.roadmap.form.map.getZoom()); //force a refresh event.
          __centralgps__.roadmap.form.map.removeLayer(polyline);
          __centralgps__.roadmap.form.map.setZoom(__centralgps__.roadmap.form.map.getZoom()); //force a refresh event.
        } else {
          console.log('getRoadmapPoints: ' + response.msg + ' - roadmap_id: ' + roadmap_id);
        }
    });
  } catch(err) {
    console.log(err);
  }
}
