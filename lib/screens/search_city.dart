import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/constands.dart'
    as k; // Update the path as per your project

class SearchCity extends StatefulWidget {
  const SearchCity({Key? key}) : super(key: key);

  @override
  _SearchCityState createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {
  bool isLoaded = false;
  String? cityName;
  num temperature = 0;
  num pressure = 0;
  num humidity = 0;
  num cloudCover = 0;
  String? mainCondition;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestLocationPermission().then((_) => getCurrentLocation());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getCurrentLocation,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.blue.shade200,
            Colors.blue.shade400,
            Colors.blue.shade600,
          ])),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLoaded ? buildWeatherInfo() : buildLoadingScreen(),
          ),
        ),
      ),
    );
  }

  Widget buildWeatherInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSearchBar(),
        buildWeatherDetails(),
        buildAdditionalInfo(),
      ],
    );
  }

  Widget buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'City Not Available',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: getCurrentLocation,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return SafeArea(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search City',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onFieldSubmitted: (String name) {
          setState(() {
            cityName = name;
            fetchWeatherDataByCityName(name);
            isLoaded = false;
            controller.clear();
          });
        },
      ),
    );
  }

  Widget buildWeatherDetails() {
    return Column(
      children: [
        Text(
          cityName ?? '',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Temperature: ${temperature.toStringAsFixed(0)}°C',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Lottie.asset(getWeatherAnimation()),
        Text(mainCondition ?? ''),
      ],
    );
  }

  Widget buildAdditionalInfo() {
    return Column(
      children: [
        buildInfoBox('Pressure', '$pressure hPa'),
        buildInfoBox('Humidity', '$humidity %'),
        buildInfoBox('Cloud Cover', '$cloudCover %'),
      ],
    );
  }

  Widget buildInfoBox(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      getCurrentLocation();
    } else {
      // Handle permission denial (e.g., show a dialog explaining why the app needs the permission)
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      fetchWeatherDataByLocation(position);
    } catch (e) {
      // Handle location errors (e.g., show an error message to the user)
      setState(() {
        isLoaded = false;
      });
    }
  }

  Future<void> fetchWeatherDataByCityName(String cityName) async {
    final uri = '${k.domain}q=$cityName&appid=${k.apiKey}';
    final url = Uri.parse(uri);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        updateUI(decodedData);
      } else {
        // Handle API response errors (e.g., show an error message to the user)
        setState(() {
          isLoaded = false;
        });
      }
    } catch (e) {
      // Handle network errors (e.g., show an error message to the user)
      setState(() {
        isLoaded = false;
      });
    }
  }

  Future<void> fetchWeatherDataByLocation(Position position) async {
    final uri =
        '${k.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${k.apiKey}';
    final url = Uri.parse(uri);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        updateUI(decodedData);
      } else {
        // Handle API response errors (e.g., show an error message to the user)
        setState(() {
          isLoaded = false;
        });
      }
    } catch (e) {
      // Handle network errors (e.g., show an error message to the user)
      setState(() {
        isLoaded = false;
      });
    }
  }

  void updateUI(dynamic decodedData) {
    setState(() {
      isLoaded = true;
      if (decodedData != null) {
        cityName = decodedData['name'];
        temperature =
            decodedData['main']['temp'] - 273.15; // Convert Kelvin to Celsius
        pressure = decodedData['main']['pressure'];
        humidity = decodedData['main']['humidity'];
        cloudCover = decodedData['clouds']['all'];
        mainCondition = decodedData['weather'][0]['main'];
      }
    });
  }

  String getWeatherAnimation() {
    if (mainCondition == null) return 'assets/images/sunny.json';

    switch (mainCondition!.toLowerCase()) {
      case 'clouds':
      case 'smoke':
      case 'haze':
      case 'fog':
        return 'assets/images/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/images/rainy.json';
      case 'thunderstorm':
        return 'assets/images/thunder.json';
      case 'clear':
        return 'assets/images/sunny.json';
      default:
        return 'assets/images/unknown.json';
    }
  }
}
