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
      [
          {
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#242f3e"
              }
            ]
          },
          {
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#746855"
              }
            ]
          },
          {
            "elementType": "labels.text.stroke",
            "stylers": [
              {
                "color": "#242f3e"
              }
            ]
          },
          {
            "featureType": "administrative.locality",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#d59563"
              }
            ]
          },
          {
            "featureType": "poi",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#d59563"
              }
            ]
          },
          {
            "featureType": "poi.park",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#263c3f"
              }
            ]
          },
          {
            "featureType": "poi.park",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#6b9a76"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#38414e"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "geometry.stroke",
            "stylers": [
              {
                "color": "#212a37"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#9ca5b3"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#746855"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "geometry.stroke",
            "stylers": [
              {
                "color": "#1f2835"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#f3d19c"
              }
            ]
          },
          {
            "featureType": "transit",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#2f3948"
              }
            ]
          },
          {
            "featureType": "transit.station",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#d59563"
              }
            ]
          },
          {
            "featureType": "water",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#17263c"
              }
            ]
          },
          {
            "featureType": "water",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#515c6d"
              }
            ]
          },
          {
            "featureType": "water",
            "elementType": "labels.text.stroke",
            "stylers": [
              {
                "color": "#17263c"
              }
            ]
          }
      ]);

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

var routes = [];
var markers = [];

function plotTripPotholes(data) {
    if (selectedChannel != 'both') {
        clearRoutes();
    }
    clearMarkers();

    for (var i = 0; i < data.length; i++) {
        if (data[i][' classification'] == "1.0") {
            lat = data[i][' latitude'];
            lng = data[i][' longitude'];
            var markerLocation = new google.maps.LatLng(lat, lng);
            var marker = new google.maps.Marker({
                position: markerLocation,
                icon: {
                    path: google.maps.SymbolPath.CIRCLE,
                    strokeColor: '#FFFFFF',
                    fillColor: '#FF0000',
                    fillOpacity: 1,
                    scale: 6,
                    strokeWeight: 2
                }
            });
            markers.push(marker);
            marker.setMap(map);
        }
    }
}

function plotTripRoadConditions(data) {
    clearRoutes();
    if (selectedChannel != 'both') {
        clearMarkers();
    }

    var intervals = []
    var intervalClassifications = {};
    for (var i = 0; i < data.length; i++) {
        intervals.push(data[i]['interval'])
        intervalClassifications[data[i]['interval']] = data[i][' classification'];
    }

    var routeCoordinates = [];
    var lastInterval = intervals[0];
    for (var i = 0; i < data.length; i++) {
        var currentInterval = data[i]['interval'];
        if (lastInterval != currentInterval) {
            var classification = intervalClassifications[lastInterval];
            var classColor = getRouteColor(classification);
            var routePath = new google.maps.Polyline({
                path: routeCoordinates,
                geodesic: true,
                strokeColor: classColor,
                strokeOpacity: 1.0,
                strokeWeight: 5
            });
            routes.push(routePath);
            routePath.setMap(map);
            routeCoordinates = [];
            lastInterval = currentInterval;
        }
        routeCoordinates.push({
           lat: Number(data[i][' latitude']),
           lng: Number(data[i][' longitude'])
        });
    }
}

function getRouteColor(classification) {
    if (classification == "0.0") {
        return "#00FF00";
    } else {
        return "#FF0000";
    }
}

function clearRoutes() {
    for (var i = 0; i < routes.length; i++) {
        routes[i].setMap(null);
    }
    routes = [];
}

function clearMarkers() {
    for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(null);
    }
    markers = [];
}

var trips = [
    {'name': 'Trip 1', 'potholes': 'data/trip1_potholesIntervals.csv', 'roadConditions': 'data/trip1_roadConditionsIntervals.csv'}
]

function plotTrip() {
    if (selectedChannel == 'potholes') {
        loadCSVData(selectedTrip['potholes'], plotTripPotholes);
    } else if (selectedChannel == 'roadConditions') {
        loadCSVData(selectedTrip['roadConditions'], plotTripRoadConditions);
    } else if (selectedChannel == 'both') {
        loadCSVData(selectedTrip['roadConditions'], plotTripRoadConditions);
        loadCSVData(selectedTrip['potholes'], plotTripPotholes);
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
var selectedChannel = 'roadConditions';
plotTrip();
