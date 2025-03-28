import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/search_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final String locationName;
  final double latitude;
  final double longitude;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        actions: [
          IconButton( 
            icon: const Icon(Icons.search), 
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<Weather>(
        future: openWeatherMapApi.getWeather(widget.latitude, widget.longitude), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue.\n${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          final weatherData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conditions: ${weatherData.condition}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Descriptions: ${weatherData.description}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Température: ${weatherData.temperature} °C',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Image.network(openWeatherMapApi.getIconUrl(weatherData.icon))                
              ],
            ),
          );
        }
      ),
    );
  }
}