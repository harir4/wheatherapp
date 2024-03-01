import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wheatherapp/models/constraints.dart' as k;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoaded = false;
  num? temp;
  num? cover;
  num? sunrise;
  num? sunset;
  String description = "";
  String city = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true);
    if (position != null) {
      print('lat:${position.latitude},long:${position.longitude}');
      getCurrentCityWeather(position);
    } else {
      print('Data Unavailable');
    }
  }

  getCurrentCityWeather(Position pos) async {
    var url =
        '${k.domain}lat=${pos.latitude}&lon=${pos.longitude}&appid=${k.apiKey}';
    var uri = Uri.parse(url);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodedData = jsonDecode(data);
      updateUI(decodedData);
      print(data);
      print(decodedData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  updateUI(var decodedData) {
    setState(() {
      if (decodedData == null) {
        temp = 0;
        cover = 0;
        sunrise = 0;
        sunset = 0;
      } else {

        temp = decodedData['main']['temp'] - 273;
        cover = decodedData['clouds']['all'];
        city = decodedData['name'];
        sunrise = decodedData  ['sys']['sunrise'];
        sunset = decodedData['sys']['sunset'];
        description=decodedData['weather'][0]['description'];
        description=decodedData['weather'][3]['main'];


      }
    });
  }

  @override
  Widget build(BuildContext context) {

    DateTime now = new DateTime.now();
    String date = DateFormat.yMMMMEEEEd().format(now);

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image(
                  fit: BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.height,
                  image: AssetImage(
                      'images/HD-wallpaper-red-and-black-clouds-during-night-time.jpg')),
              Padding(
                padding: const EdgeInsets.only(top: 80, left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontStyle: FontStyle.italic),
                    ),
                    Text(
                      date.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Icon(
                      Icons.cloud,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      description,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 70,
                    ),

                    SizedBox(
                      height: 40,
                    ),
                    Text(
                     ' ${temp?.toInt()}°C'
                      ,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 100,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
