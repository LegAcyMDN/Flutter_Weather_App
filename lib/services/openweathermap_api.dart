import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';

class OpenWeatherMapApi {
  OpenWeatherMapApi({
    required this.apiKey,
    this.units = 'metric',
    this.lang = 'fr',
  });

  static const String baseUrl = 'https://api.openweathermap.org';

  final String apiKey;
  final String units;
  final String lang;

  String getIconUrl(String icon) {
    return 'https://openweathermap.org/img/wn/$icon@4x.png';
  }

  Future<Iterable<Location>> searchLocations(
    String query, {
    int limit = 5,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/geo/1.0/direct?appid=$apiKey&q=$query&limit=$limit'),
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Location.fromJson(json)).toList();
    }

    throw Exception('Impossible de récupérer les données de localisation (HTTP ${response.statusCode})');
  }

  Future<Weather> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/weather?appid=$apiKey&lat=$lat&lon=$lon&units=$units&lang=$lang',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Weather.fromJson(jsonData);
    }

    throw Exception(
        'Impossible de récupérer les données météo (HTTP ${response.statusCode})');
    }

  Future<String> getCityName(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/geo/1.0/reverse?appid=$apiKey&lat=$lat&lon=$lon&limit=1'
        ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> jsonData =json.decode(response.body);
      if (jsonData.isEmpty) {
        return jsonData[0]['name'];
      }
      throw Exception('Aucune ville trouvée pour ces coordonnées.');
    }

    throw Exception('Impossible de récupérer le nom de la ville (HTTP ${response.statusCode})');
  }

  Future<List<Weather>> getFiveDayForecast(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/data/2.5/forecast?appid=$apiKey&lat=$lat&lon=$lon&units=$units&lang=$lang',
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> forecastList = jsonData['list'];

      return forecastList.map((json) {
        final weatherData = json['weather'][0];
        final mainData = json['main'];
        final windData = json['wind'];

        return Weather(
          condition: weatherData['main'], 
          description: weatherData['description'], 
          icon: weatherData['icon'], 
          temperature: mainData['temp'], 
          humidity: mainData['humidity'], 
          pressure: mainData['pressure'], 
          windSpeed: windData['speed'], 
          windDeg: windData['deg'], 
          tempMin: mainData['temp_min'], 
          tempMax: mainData['temp_max']
        );
      }).toList();
    }

    throw Exception('Impossible de récupérer les prévisions météo (HTTP ${response.statusCode})');
  }
}
