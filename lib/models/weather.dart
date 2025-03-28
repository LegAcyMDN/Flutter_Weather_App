class Weather {
  final String condition;
  final String description;
  final String icon;
  final double temperature;

  Weather({
    required this.condition,
    required this.description,
    required this.icon,
    required this.temperature,
  });

  static Weather fromJson(Map<String, dynamic> json) {
    final weatherData = json['weather'][0];
    final mainData = json['main'];

    return Weather(
      condition: weatherData['main'],
      description: weatherData['description'],
      icon: weatherData['icon'],
      temperature: mainData['temp'],
    );  
  }
}