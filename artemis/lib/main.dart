import 'dart:convert';

import 'package:artemis/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';

import 'network_utility.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> _suggestions = [
    'Afeganistan',
    'Albania',
    'Algeria',
    'Australia',
    'Brazil',
    'German',
    'Madagascar',
    'Mozambique',
    'Portugal',
    'Zambia'
  ];
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  LatLng start = const LatLng(45.521563, -122.677433);
  LatLng stop = const LatLng(45.521563, -120.677433);

  LocationData? currentLocation;
  late List<String> dropDownData = [];

  void getCurrentLocation() async {
    Location location = Location();
    LocationData loc = await location.getLocation();
    setState(() {
      currentLocation = loc;
    });
    // return LatLng(currentLocation.latitude!, currentLocation.longitude!);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  String? finalText;
  List<LatLng> polyLineCoordinate = [];

  void placeAutoComplete(String query) async {
    finalText = query;
    print("Finaltezt: ${finalText}");
    print("Inside placeAuto");
    Uri uri = Uri.https(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json',
        {"input": query, "key": "AIzaS yA6-HFCC67e9IbqOhgRw3N2MDYPdMN_TcY"});

    String? response = await NetworkUtility.fetchUrl(uri);
    // List<DropdownMenuItem<String>> tempDropDownValues = [];

    if (response != null) {
      // print(jsonDecode(response)["predictions"][0]["description"]);
      // print(jsonDecode(response)["predictions"]);
      // Iterable l = json.decode(response)["predictions"];
      // List<String> posts = List<String>.from(l.map((addr) => print(addr)));
      List addrs = json.decode(response)["predictions"] as List;
      List<String> responses = [];

      for (var i = 0;
          i < min((json.decode(response)["predictions"] as List).length, 4);
          i++) {
        print(json.decode(response)["predictions"][i]["description"]);
        responses.add(json.decode(response)["predictions"][i]["description"]);
      }
      setState(() {
        dropDownData = responses;
      });
    }
  }

  void getRoutes() async {
    PolylinePoints polylinePoints = PolylinePoints();

    finalText = finalText!.replaceAll(' ', '+');
    finalText = "Redmond+Transit+Center+-+Bay+6";

    Uri uri = Uri.https("maps.googleapis.com", "/maps/api/directions/json", {
      "origin": "225+Northeastern+University,+225+Terry+Ave+N,+Seattle,+WA",
      "destination": finalText,
      "alternatives": "true",
      "mode": "driving",
      "key": "AIzaS yA6-HFCC67e9IbqOhgRw3N2MDYPdMN_TcY"
    });
    String? resp = await RouteGenerator.fetchUrl(uri);
    if (resp != null) {
      print(json.decode(resp)["routes"][0]["legs"][0]["steps"][0]);
      // print(json.decode(resp)["routes"][0]["legs"][0]["start_location"]);
      List steps = json.decode(resp)["routes"][0]["legs"][0]["steps"] as List;

      for (int i = 0; i < steps.length; i++) {
        print(steps[i]["end_location"]);
      }
    }
  }

  TextEditingController _controller = TextEditingController();
  String? _dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: currentLocation == null
            ? Text("Loading Artemis.....")
            : Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                          markerId: MarkerId("start"),
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!)),
                      Marker(
                        markerId: MarkerId("stop"),
                        position: stop,
                      )
                    },
                  ),
                  Positioned(
                    top: 50,
                    left: 10,
                    right: 10,
                    // padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (text) {
                        placeAutoComplete(text);
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Destination",
                        hintText: "Navigate to your destination",
                        focusColor: Colors.black,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white60,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 40,
                    right: 0,
                    // margin: EdgeInsets.only(top: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dropDownData.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Colors.white60,
                          title: Text('${dropDownData[index]}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
