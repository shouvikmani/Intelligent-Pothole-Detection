var map;
function initMap() {

  var pittsburgh = new google.maps.LatLng(40.4406, -79.9759);

  map = new google.maps.Map(document.getElementById('map'), {
    center: pittsburgh,
    zoom: 14,
    mapTypeControl: false
  });

  // Map Styles
  var styledMapType = new google.maps.StyledMapType(
      [{
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#212121"
        	}]
        }, {
        	"elementType": "labels.icon",
        	"stylers": [{
        		"visibility": "off"
        	}]
        }, {
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#757575"
        	}]
        }, {
        	"elementType": "labels.text.stroke",
        	"stylers": [{
        		"color": "#212121"
        	}]
        }, {
        	"featureType": "administrative",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#757575"
        	}]
        }, {
        	"featureType": "administrative.country",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#9e9e9e"
        	}]
        }, {
        	"featureType": "administrative.land_parcel",
        	"stylers": [{
        		"visibility": "off"
        	}]
        }, {
        	"featureType": "administrative.locality",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#bdbdbd"
        	}]
        }, {
        	"featureType": "poi",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#757575"
        	}]
        }, {
        	"featureType": "poi.park",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#181818"
        	}]
        }, {
        	"featureType": "poi.park",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#616161"
        	}]
        }, {
        	"featureType": "poi.park",
        	"elementType": "labels.text.stroke",
        	"stylers": [{
        		"color": "#1b1b1b"
        	}]
        }, {
        	"featureType": "road",
        	"elementType": "geometry.fill",
        	"stylers": [{
        		"color": "#2c2c2c"
        	}]
        }, {
        	"featureType": "road",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#8a8a8a"
        	}]
        }, {
        	"featureType": "road.arterial",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#373737"
        	}]
        }, {
        	"featureType": "road.highway",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#3c3c3c"
        	}]
        }, {
        	"featureType": "road.highway.controlled_access",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#4e4e4e"
        	}]
        }, {
        	"featureType": "road.local",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#616161"
        	}]
        }, {
        	"featureType": "transit",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#757575"
        	}]
        }, {
        	"featureType": "water",
        	"elementType": "geometry",
        	"stylers": [{
        		"color": "#000000"
        	}]
        }, {
        	"featureType": "water",
        	"elementType": "labels.text.fill",
        	"stylers": [{
        		"color": "#3d3d3d"
        	}]
    }]);

    map.mapTypes.set('styled_map', styledMapType);
    map.setMapTypeId('styled_map');

}

function loadCSVData(path, callback) {
    $.ajax({
      type: "GET",
      url: path,
      dataType: "text",
      success: function(data) {
          callback($.csv.toObjects(data));
      }
   });
}

var routePath;
var heatmap;

function plotTripRoute(data) {
    if (routePath != null) {
        routePath.setMap(null);
    }
    if (heatmap != null) {
        heatmap.setMap(null);
    }
    routeCoordinates = [];
    for (var i = 0; i < data.length; i++) {
        routeCoordinates.push({
           lat: Number(data[i]['latitude']),
           lng: Number(data[i]['longitude'])
        });
    }
    routePath = new google.maps.Polyline({
        path: routeCoordinates,
        geodesic: true,
        strokeColor: '#00BFFF',
        strokeOpacity: 1.0,
        strokeWeight: 5
    });
    routePath.setMap(map);
}

function plotTripHeatmap(data) {
    if (routePath != null) {
        routePath.setMap(null);
    }
    if (heatmap != null) {
        heatmap.setMap(null);
    }
    var heatmapData = [];
    for (var i = 0; i < data.length; i++) {
        heatmapData.push(
            {
                location: new google.maps.LatLng(Number(data[i]['latitude']),
                Number(data[i]['longitude'])),
                weight: data[i][selectedChannel]
            }
        );
    }
    heatmap = new google.maps.visualization.HeatmapLayer({
        data: heatmapData
    });
    heatmap.setMap(map);
}

var trips = [
    {'name': '2/22 Trip 1', 'path': '../data/trip1_02-22-17_sensors.csv'},
    {'name': '2/22 Trip 2', 'path': '../data/trip2_02-22-17_sensors.csv'},
    {'name': '2/22 Trip 3', 'path': '../data/trip3_02-22-17_sensors.csv'},
    {'name': '3/26 Trip 1', 'path': '../data/03_26_trip1_sensors.csv'},
    {'name': '3/26 Trip 2', 'path': '../data/03_26_trip2_sensors.csv'},
    {'name': '4/02 Trip 1', 'path': '../data/04_02_trip1_sensors.csv'}
]

function plotTrip() {
    if (selectedChannel == 'route') {
        loadCSVData(selectedTrip['path'], plotTripRoute);
    } else {
        loadCSVData(selectedTrip['path'], plotTripHeatmap);
    }
}

function setSelectedTrip(newTripIndex) {
    selectedTrip = trips[newTripIndex]
    plotTrip();
}

function setSelectedChannel(newChannel) {
    selectedChannel = newChannel;
    plotTrip();
}

var selectedTrip = trips[3];
var selectedChannel = 'route';
plotTrip();
