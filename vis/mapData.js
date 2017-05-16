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
    {'name': 'Trip 1', 'potholes': 'data/trip1_potholesIntervals.csv', 'roadConditions': 'data/trip1_roadConditionsIntervals.csv'},
    {'name': 'Trip 2', 'potholes': 'data/trip2_potholesIntervals.csv', 'roadConditions': 'data/trip2_roadConditionsIntervals.csv'},
    {'name': 'Trip 3', 'potholes': 'data/trip3_potholesIntervals.csv', 'roadConditions': 'data/trip3_roadConditionsIntervals.csv'},
    {'name': 'Trip 4', 'potholes': 'data/trip4_potholesIntervals.csv', 'roadConditions': 'data/trip4_roadConditionsIntervals.csv'},
    {'name': 'Trip 5', 'potholes': 'data/trip5_potholesIntervals.csv', 'roadConditions': 'data/trip5_roadConditionsIntervals.csv'},
    {'name': 'Trip 6', 'potholes': 'data/trip6_potholesIntervals.csv', 'roadConditions': 'data/trip6_roadConditionsIntervals.csv'},
    {'name': 'Trip 7', 'potholes': 'data/trip7_potholesIntervals.csv', 'roadConditions': 'data/trip7_roadConditionsIntervals.csv'},
    {'name': 'Trip 8', 'potholes': 'data/trip8_potholesIntervals.csv', 'roadConditions': 'data/trip8_roadConditionsIntervals.csv'},
    {'name': 'Trip 9', 'potholes': 'data/trip9_potholesIntervals.csv', 'roadConditions': 'data/trip9_roadConditionsIntervals.csv'},
    {'name': 'Trip 10', 'potholes': 'data/trip10_potholesIntervals.csv', 'roadConditions': 'data/trip10_roadConditionsIntervals.csv'},
    {'name': 'Trip 11', 'potholes': 'data/trip11_potholesIntervals.csv', 'roadConditions': 'data/trip11_roadConditionsIntervals.csv'}
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

function plotAllTrips() {
    for (var i = 0; i < trips.length; i++) {
        selectedTrip = trips[i];
        plotTrip();
    }
}

function setSelectedTrip(newTripIndex) {
    if (newTripIndex == "-1") {
        showAllTrips = true;
        clearRoutes();
        clearMarkers();
        plotAllTrips();
    } else {
        showAllTrips = false;
        selectedTrip = trips[newTripIndex];
        clearRoutes();
        clearMarkers();
        plotTrip();
    }
}

function setSelectedChannel(newChannel) {
    selectedChannel = newChannel;
    if (showAllTrips == true) {
        clearRoutes();
        clearMarkers();
        plotAllTrips();
    } else {
        clearRoutes();
        clearMarkers();
        plotTrip();
    }
}

//Defaults
var showAllTrips = true;
var selectedTrip = trips[0];
var selectedChannel = 'both';
plotAllTrips();
