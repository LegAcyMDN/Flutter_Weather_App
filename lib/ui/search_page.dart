import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/services/openweathermap_api.dart';
import 'package:weather_app/ui/weather_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  Future<Iterable<Location>>? locationsSearchResults;

  @override
  Widget build(BuildContext context) {
    final openWeatherMapApi = context.read<OpenWeatherMapApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Entrez le nom de la ville',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (query.isNotEmpty) {
                  locationsSearchResults = openWeatherMapApi.searchLocations(query);
                } else {
                  locationsSearchResults = null; // Réinitialiser si le champ est vide
                }
              });
            }, 
            child: const Text('Rechercher'),
          ),
          if (query.isEmpty)
            const Text('Saisissez une ville dans la barre de rechecher.')
          else
            Expanded(
              child: FutureBuilder(
                future: openWeatherMapApi.searchLocations(query),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Une erreur est survenue.\n${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const Text('Aucun résultat pour cette recherche.');
                  }

                  final locations = snapshot.data!;

                  return ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations.elementAt(index);
                      return ListTile(
                        title: Text(location.name),
                        subtitle: Text(location.country),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => WeatherPage(
                                locationName: location.name, 
                                latitude: location.lat, 
                                longitude: location.lon,
                              )
                            )
                          );
                        },
                      );
                    }
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}