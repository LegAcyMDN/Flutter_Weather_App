import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/services/geolocation_service.dart';
import 'package:weather_app/ui/search_page.dart';
import 'package:weather_app/ui/weather_page.dart'; 

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<void> getLocationData() async {
    try {
      final position = await context.read<GeolocationService>().getCurrentPosition();
      if (mounted) {
        if (position != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherPage(
                locationName: 'Votre position actuelle',
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}