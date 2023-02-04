import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  LatLng start = const LatLng(45.521563, -122.677433);
  LatLng stop = const LatLng(45.521563, -120.677433);

  LocationData? currentLocation;

  Location getCurrentLocation() {
    Location location = Location();
    location.getLocation().then((location) => currentLocation = location);
    return location;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: {
            Marker(
                markerId: MarkerId("start"),
                position: getCurrentLocation() as LatLng),
            Marker(
              markerId: MarkerId("stop"),
              position: stop,
            )
          },
        ),
      ),
    );
  }
}
