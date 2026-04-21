import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

void main() => runApp(MaterialApp(home: WeatherScreen()));

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String temp = "--";
  String condition = "Loading...";
  Color bgColor = Colors.blue; 
  IconData weatherIcon = Icons.wb_sunny;
  String city = "Jakarta";
  TextEditingController cityController = TextEditingController(text: "Jakarta");

  Future<void> fetchWeather() async {
    final url = "${Config.baseUrl}?q=$city&appid=${Config.openWeatherMapApiKey}&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temp = data['main']['temp'].round().toString();
        condition = data['weather'][0]['main'];

        if (condition == "Rain") {
          bgColor = Colors.blueGrey;
          weatherIcon = Icons.umbrella;
        } else if (condition == "Clear") {
          bgColor = Colors.blue;
          weatherIcon = Icons.wb_sunny;
        } else {
          bgColor = Colors.grey;
          weatherIcon = Icons.cloud;
        }
      });
    } else {
      setState(() {
        condition = "Error fetching weather";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(city.toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 20),
            Icon(weatherIcon, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text("$temp°", style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(condition.toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: TextField(
                controller: cityController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "City",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    city = value;
                  });
                  fetchWeather();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}