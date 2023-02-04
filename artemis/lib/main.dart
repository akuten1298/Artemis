import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'network_utility.dart';

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
  late List<DropDownValueModel> dropDownData;

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

  void placeAutoComplete(String query) async {
    Uri uri = Uri.https(
        "maps.googleapis.com",
        'maps/api/place/autocomplete/json',
        {"input": query, "key": "AIzaS yA6-HFCC67e9IbqOhgRw3N2MDYPdMN_TcY"});

    String? response = await NetworkUtility.fetchUrl(uri);
    List<DropDownValueModel> tempDropDownValues = [];

    if (response != null) {
      // print(jsonDecode(response)["predictions"][0]["description"]);
      // print(jsonDecode(response)["predictions"]);
      // Iterable l = json.decode(response)["predictions"];
      // List<String> posts = List<String>.from(l.map((addr) => print(addr)));
      List addrs = json.decode(response)["predictions"] as List;
      for (var i = 0;
          i < (json.decode(response)["predictions"] as List).length;
          i++) {
        print(json.decode(response)["predictions"][i]["description"]);
        tempDropDownValues.add(DropDownValueModel(
            name: json.decode(response)["predictions"][i]["description"],
            value: json.decode(response)["predictions"][i]["description"]));
      }
      // print(tempDropDownValues);
      setState(() {
        dropDownData = tempDropDownValues;
      });
    }
  }

  void getRoutes(String dest) async {
    Uri uri = Uri.https("maps.googleapis.com", "/maps/api/directions/json", {
      "origin": "McDonald's,+3rd+Avenue,+Seattle,+WA",
      "destination":
          "225+Northeastern+University,+225+Terry+Ave+N,+Seattle,+WA",
      "alternatives": "true",
      "mode": "driving",
      "key": "AIzaS yA6-HFCC67e9IbqOhgRw3N2MDYPdMN_TcY"
    });
  }

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: currentLocation == null
              ? Text("Loading Artemis.....")
              : Stack(
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
                      left: 0,
                      right: 0,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          suffixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Color.fromARGB(151, 137, 135, 135),
                          contentPadding: const EdgeInsets.only(
                              left: 25.0, bottom: 8.0, top: 12.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(25.7),
                          ),
                        ),
                        onChanged: (text) {
                          // Use the text to filter the data and update the UI
                          placeAutoComplete(text);
                        },
                      ),
                    ),
                  ],
                )),
    );
  }
}
