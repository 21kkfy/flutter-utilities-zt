import 'dart:math';
import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as dev;

/// ! DO NOT REMOVE, CRASHES iOS!!!!!!!!!! import 'dart:typed_data';
// ignore: unnecessary_import, unused_import
import 'dart:typed_data';

import 'package:stepfront_utilities/src/app_colors.dart';
// ! DO NOT REMOVE, CRASHES iOS!!!!!!!!!! import 'dart:typed_data';

abstract class SFMapService {
  GoogleMapController? mapController; //contrller for Google map

  late LatLng startLocation = const LatLng(56.2639, 9.5018);
  double distance = 0.0;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  String googleAPIKey = "";

  /// Abstract classes, similar to Interfaces, can't be initialized. The apiKey must come from the
  /// subclass, in the subclass call the super constructor.
  /// More on super constructors:
  /// https://www.geeksforgeeks.org/super-constructor-in-dart/
  SFMapService(String apiKey) {
    /* 
    dotenv.load(fileName: ".env");
    googleAPIKey = dotenv.env['API_KEY']!; */
    googleAPIKey = apiKey;
  }

  /// getDirections
  getDirections(List<LatLng> latLngs, {Color? color}) async {
    List<LatLng> polylineCoordinates = [];

    List<PolylineResult> resultList = [];

    for (int i = 0; i < latLngs.length - 1; i++) {
      LatLng coords = latLngs[i];
      LatLng nextCoords = latLngs[i + 1];
      try {
        if (i == 0) {
          resultList.add(await polylinePoints.getRouteBetweenCoordinates(
            googleAPIKey,
            PointLatLng(startLocation.latitude, startLocation.longitude),
            PointLatLng(coords.latitude, coords.longitude),
            travelMode: TravelMode.driving,
          ));
        } else {
          resultList.add(await polylinePoints.getRouteBetweenCoordinates(
            googleAPIKey,
            PointLatLng(coords.latitude, coords.longitude),
            PointLatLng(nextCoords.latitude, nextCoords.longitude),
            travelMode: TravelMode.driving,
          ));
        }
      } catch (e) {
        dev.log(e.toString());
      }
    }

    for (PolylineResult result in resultList) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    distance = totalDistance;

    //add to the list of poly line coordinates
    _addPolyline(polylineCoordinates);
  }

  /// Adds a polyline to the map with given [polylineCoordinates].
  ///
  /// The method creates a polyline with [PolylineId] poly and adds it to the [polylines] map.
  ///
  /// The [polylineCoordinates] parameter is a list of [LatLng] objects that define the vertices of the polyline.
  ///
  /// The color of the polyline is set to [AppColors.darkBlue] and the width of the polyline is set to 8.
  ///
  /// Example usage:
  /// ```dart
  /// List<LatLng> coords = [
  /// LatLng(55.6760968, 12.5683371),
  /// LatLng(55.6840938, 12.5859567),
  /// ];
  /// addPolyLine(coords);
  /// ```
  _addPolyline(List<LatLng> polylineCoordinates, {Color? color}) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: color ?? AppColors.green,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }

  /// Calculates the distance between two points on Earth using their latitude and longitude values.
  ///
  /// The method takes in four parameters: [lat1], [lon1], [lat2], and [lon2], which represent the latitude and longitude values
  /// of the two points in degrees.
  ///
  /// The method uses the Haversine formula to calculate the distance between the two points.
  ///
  /// Returns the distance between the two points in kilometers.
  ///
  /// Example usage:
  /// ```dart
  /// double distance = calculateDistance(55.6760968, 12.5683371, 55.6840938, 12.5859567);
  /// print("Distance between two points: $distance km");
  /// double calculateDistance(lat1, lon1, lat2, lon2)
  /// ```
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Set<Marker>> buildAllMarkers(List<LatLng> coords) async {
    Set<Marker> markers = {};
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457
    });

    // END-USER LOCATION
    // Start location should be end-user's GPS lat & long
    startLocation = LatLng(position.latitude, position.longitude);
    // end location, should be set inside the latest cleaning_detail_view
    // Where the end-user clicks on LocationIcon,
    // get latitude & longitude using GetX
    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: startLocation, //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'Starting Point',
        snippet: 'Start Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    /// Add the route markers to the worker marker and return it.
    markers.addAll(await getAllOtherMapMarkers(coords));
    return markers;
  }

  /// This method should prepare all of the markers
  /// that ISN'T end-user's marker and add it to markers
  /// that will later be displayed on Google Map.
  Future<Set<Marker>> getAllOtherMapMarkers(List<LatLng> coords);

  /// This method should return all of the coordinates inside the data models
  /// passed to it as a List<LatLng> to be used in various methods.
  List<LatLng> getAllLatLngs(List<Object> objects);

  Future<GoogleMap> getMap(List<LatLng> latLngs);

  Future<double> _getTotalDistance(LatLng lastLatLng) async {
    List<LatLng> polylineCoordinates = [];
    LatLng targetLocation = lastLatLng;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(targetLocation.latitude, targetLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      dev.log(result.errorMessage.toString());
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    return totalDistance;
  }

  /// This method calculates the average LatLng value
  /// to center the camera on all the given markers.<br>
  /// @param startLocation and totalDistance(meters)
  /// return center of all markers on the map.
  /// TODO: Could possibly add an optional param to get distance until
  /// specific marker.
  Future<CameraPosition> getAsyncCameraPosition(
      LatLng startLocation, List<LatLng> latLngs) async {
    LatLng calculatedCameraPosition;
    double sumLat = 0.0;
    double sumLng = 0.0;

    /// Add coords other than startLocation
    for (LatLng latLng in latLngs) {
      sumLat += latLng.latitude;
      sumLng += latLng.longitude;
    }

    /// Add startLocation coords.
    sumLat += startLocation.latitude;
    sumLng += startLocation.longitude;

    /// +1 because startLocation has been added.
    sumLat /= (latLngs.length + 1);
    sumLng /= (latLngs.length + 1);

    calculatedCameraPosition = LatLng(sumLat, sumLng);
    double totalDistance = await _getTotalDistance(latLngs.last);
    return CameraPosition(
      target: calculatedCameraPosition,
      zoom: _getZoomForCamera(totalDistance),
    );
  }

  /// might be removed idk
  Future<Marker> createMarker(
      int markerIndex, LatLng dropLocation, Color color);

  /// Calculates and returns the zoom level required for the camera based on the [totalDistance] of the route.
  ///
  /// If the [totalDistance] is less than 1000 meters, the zoom level is set to 12.
  /// If the [totalDistance] is between 1000 and 2000 meters, the zoom level is set to 8.
  /// If the [totalDistance] is between 2000 and 3000 meters, the zoom level is set to 5.
  /// For distances greater than 3000 meters, the zoom level is set to 10.
  ///
  /// The method also logs the [totalDistance] and the corresponding [zoom] value using the Flutter [dev.log] function.
  ///
  /// Example usage:
  /// ```dart
  /// double totalDistance = 2500;
  /// double zoomLevel = getZoomForCamera(totalDistance);
  /// ```
  double _getZoomForCamera(double totalDistance) {
    double zoom;
    // 1000 meters
    if (totalDistance < 1000) {
      zoom = 12;
    } else if (totalDistance > 1000 && totalDistance < 2000) {
      zoom = 8;
    } else if (totalDistance > 2000 && totalDistance < 3000) {
      zoom = 5;
    } else {
      zoom = 10;
    }
    dev.log("${totalDistance.toString()}_${zoom.toString()}");
    return zoom;
  }
}
