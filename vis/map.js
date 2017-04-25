var map;
function initMap() {

  var pittsburgh = new google.maps.LatLng(40.4480, -79.9476);

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
var markers;

function plotTripRoute(data) {
    if (routePath != null) {
        routePath.setMap(null);
    }
    if (heatmap != null) {
        heatmap.setMap(null);
    }
    if (markers != null) {
        clearMarkers();
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

function plotTripPotholes(data) {
    if (routePath != null) {
        // Plot new trip (sometimes necessary)
        plotTripRoute(data);
    }
    if (heatmap != null) {
        heatmap.setMap(null);
    }
    if (markers != null) {
        clearMarkers();
    }
    markers = []
    for (var i = 0; i < data.length; i++) {
        if (data[i]['potholes'] == "True") {
            lat = data[i]['latitude'];
            lng = data[i]['longitude'];
            var markerLocation = new google.maps.LatLng(lat, lng);
            var marker = new google.maps.Marker({
                position: markerLocation,
                icon: {
                    path: google.maps.SymbolPath.CIRCLE,
                    strokeColor: '#FFFFFF',
                    fillColor: '#FF0000',
                    fillOpacity: 1,
                    scale: 8,
                    strokeWeight: 2
                }
            });
            markers.push(marker);
            marker.setMap(map);
        }
    }
}

function plotTripHeatmap(data) {
    if (routePath != null) {
        routePath.setMap(null);
    }
    if (markers != null) {
        clearMarkers();
    }

    allValues = [];
    for (var i = 0; i < data.length; i++) {
        allValues.push(Number(data[i][selectedChannel]));
    }
    max = Math.max(...allValues);
    min = Math.min(...allValues);

    markers = [];
    intervalLength = 10;   // (2 seconds)
    pointsTillNextInterval = intervalLength;
    valuesInInterval = [];
    for (var i = 0; i < data.length; i++) {
        pointsTillNextInterval--;
        valuesInInterval.push(Number(data[i][selectedChannel]));
        if (pointsTillNextInterval == 0) {
            averageValue = average(valuesInInterval);
            normalizedValue = normalize(averageValue, min, max);
            color = perc2color(normalizedValue);
            lat = data[i]['latitude'];
            lng = data[i]['longitude'];
            var marker = new google.maps.Marker({
                position: new google.maps.LatLng(lat, lng),
                icon: {
                    path: google.maps.SymbolPath.CIRCLE,
                    strokeColor: '#FFFFFF',
                    fillColor: color,
                    fillOpacity: 1,
                    scale: 8,
                    strokeWeight: 2
                }
            });
            markers.push(marker);
            marker.setMap(map);
            pointsTillNextInterval = intervalLength;
            valuesInInterval = [];
        }
    }
}

function clearMarkers() {
    for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(null);
    }
    markers = [];
}

function average(values) {
    var sum = 0;
    for (var i = 0; i < values.length; i++) {
        sum = sum + values[i];
    }
    return sum/values.length;
}

function normalize(value, min, max) {
    return ((value - min) / (max - min)) * 100;
}

// Source: https://gist.github.com/mlocati/7210513
// Input: Number between 0 and 100
// Output: Color between red and green
function perc2color(perc) {
	var r, g, b = 0;
	if(perc < 50) {
		r = 255;
		g = Math.round(5.1 * perc);
	}
	else {
		g = 255;
		r = Math.round(510 - 5.10 * perc);
	}
	var h = r * 0x10000 + g * 0x100 + b * 0x1;
	return '#' + ('000000' + h.toString(16)).slice(-6);
}

var trips = [
    {'name': '2/22 Trip 1', 'path': '../data/Final_Route/t1_combined.csv'},
    {'name': '2/22 Trip 2', 'path': '../data/Final_Route/t2_combined.csv'},
    {'name': '2/22 Trip 3', 'path': '../data/Final_Route/t3-cc25_combined.csv'},
    {'name': '3/26 Trip 1', 'path': '../data/Final_Route/t4-25ub_combined.csv'},
    {'name': '3/26 Trip 2', 'path': '../data/Final_Route/t5-avoid_combined.csv'},
    {'name': '4/02 Trip 1', 'path': '../data/Final_Route/t6-random_combined.csv'}
]

function plotTrip() {
    if (selectedChannel == 'route') {
        loadCSVData(selectedTrip['path'], plotTripRoute);
    } else if (selectedChannel == 'potholes') {
        loadCSVData(selectedTrip['path'], plotTripPotholes);
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

//Defaults
var selectedTrip = trips[0];
var selectedChannel = 'route';
plotTrip();
