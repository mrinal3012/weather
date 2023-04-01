import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  // var dateString = format.format(DateTime.now());




  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    print(
        "print the ppppppppppppppppppppppppppppppppppppp ${position!.latitude} and ${position!.longitude}");
    getWeatherData();
  }

  Position? position;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=c34a399ff7836c2b1a2465b746217cfe&units=metric"));
    var forecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=c34a399ff7836c2b1a2465b746217cfe&units=metric"));

    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weather.body));
      forecastMap = Map<String, dynamic>.from(jsonDecode(forecast.body));
    });
  }

  @override
  void initState() {
    determinePosition();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return weatherMap==null ? Center(child: CircularProgressIndicator()):Scaffold(
    appBar: AppBar(
    title: Text("${weatherMap!["name"]}"),
    ),
    body: Column(
    children: [
    Expanded(child: Column(children: [

      // Text("Last update: ${Jiffy.now().jm as String}"),
      Text(DateFormat.yMMMMEEEEd().format(DateTime.parse(
        "${DateTime.now()}"
      ))),

      // Text( DateFormat.yMd('en_US').parse('1/10/2012');
      // DateFormat('Hms', 'en_US').parse('14:23:01');),

      Text("${weatherMap!["timezone"]}"),
      SizedBox(height: 20,),
      Text("${weatherMap!["name"]}"),
      Text("${weatherMap!["main"]["temp"]}"),
      Text("${weatherMap!["main"]["temp_min"]}"),
      Text("${weatherMap!["main"]["temp_max"]}"),
      Text("${weatherMap!["main"]["pressure"]}"),
      Text("${weatherMap!["main"]["humidity"]}"),
      SizedBox(height: 20,),
      Text("${weatherMap!["weather"][0]["id"]}"),
      Text("${weatherMap!["weather"][0]["main"]}"),
      Text("${weatherMap!["weather"][0]["description"]}"),
      Text("${weatherMap!["weather"][0]["icon"]}"),
      Text("${weatherMap!["base"]}"),
      Text("${weatherMap!["visibility"]}"),





    ],)),

    Expanded(child:
    ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 100,
          width: 150,child: Column(children: [
            Text("${forecastMap!["cod"]}"),
            Text("${forecastMap!["list"][index]["dt"]}"),
            Text("${forecastMap!["list"][index]["main"]["temp"]}"),

            Text("${forecastMap!["list"][index]["weather"][0]["id"]}"),
            Text("${forecastMap!["list"][index]["weather"][0]["main"]}"),
            Text("${forecastMap!["list"][index]["weather"][0]["description"]}"),
            // Text("${forecastMap!["list"][index]["weather"][0]["icon"]}"),
          Image.network("https://openweathermap.org/img/wn/${forecastMap!["list"][index]["weather"][0]["icon"]}@2x.png"),

          Text(DateFormat.Hm().format(DateTime.parse(
              "${forecastMap!["list"][index]["dt_txt"]}"
          ))),

        ],),),
      ) ,)
    ),
    ],
    ),
    );
  }
}
