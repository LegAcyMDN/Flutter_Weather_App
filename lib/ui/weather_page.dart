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
  String? cityName;
  late Future<List<Weather>> forecast;

  @override
  void initState() {
    super.initState();
    fetchCityName;
    forecast = fetchForecast();
  }

  Future<void> fetchCityName() async {
    try {
      final openWeatherMapApi = context.read<OpenWeatherMapApi>();
      final name = await openWeatherMapApi.getCityName(widget.latitude, widget.longitude);
      if (mounted) {
        setState(() {
          cityName = name;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom de la ville: $e');
    }
  }

  Future<List<Weather>> fetchForecast() async {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();
    return await openWeatherMapApi.getFiveDayForecast(widget.latitude, widget.longitude);
  }

  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName ?? 'Chargement...'),
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
                Text(
                  'Humidité: ${weatherData.humidity}%',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Pression: ${weatherData.pressure} hPa',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Vitesse du vent: ${weatherData.windSpeed} m/s',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Direction du vent: ${weatherData.windDeg}°',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Température min: ${weatherData.tempMin} °C',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Température max: ${weatherData.tempMax} °C',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Image.network(openWeatherMapApi.getIconUrl(weatherData.icon)),
                const SizedBox(height: 16),
                const Text(
                  'Prévisions pour les 5 jours à venir:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),     
                const SizedBox(height: 8),
                FutureBuilder<List<Weather>>(
                  future: forecast,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Une erreur est survenue.\n${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Aucune prévision disponible.'));
                    }

                    final forecastData = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: forecastData.length,
                      itemBuilder: (context, index) {
                        final forecastWeather = forecastData[index];
                        return ListTile(
                          title: Text('${forecastWeather.condition} - ${forecastWeather.temperature} °C'),
                          subtitle: Text('Humidité: ${forecastWeather.humidity}%'),
                          trailing: Image.network(openWeatherMapApi.getIconUrl(forecastWeather.icon)),
                        );
                      },
                    );
                  },
                ),           
              ],
            ),
          );
        }
      ),
    );
  }
}