class Weather {
  final String condition;
  final String description;
  final String icon;
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double windDeg;
  final double tempMin;
  final double tempMax;

  Weather({
    required this.condition,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.tempMin,
    required this.tempMax,
  });

  static Weather fromJson(Map<String, dynamic> json) {
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
      tempMax: mainData['temp_max'],
    );  
  }
}