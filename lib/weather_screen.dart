import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_card.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late double temp=0;
  late Future<Map<String, dynamic>> weatherFuture;

  @override
  initState() {
    super.initState();
    weatherFuture = getWeather();
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=London,uk&appid=${dotenv.env['OPEN_WEATHER_API_KEY']}',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['cod'] != '200') {
        throw "An unexpected error occured";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherFuture = getWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weatherFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (asyncSnapshot.hasError) {
            return Center(child: Text(asyncSnapshot.error.toString()));
          }

          final data = asyncSnapshot.data!;
          final currentTemp = data['list'][0]['main']['temp'].toString();
          final currentSkyCondition = data['list'][0]['weather'][0]['main'];
          final currentHumidity = data['list'][0]['main']['humidity']
              .toString();
          final currentWindSpeed = data['list'][0]['wind']['speed'].toString();
          final currentPressure = data['list'][0]['main']['pressure']
              .toString();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$currentTemp K',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSkyCondition == 'Clouds' ||
                                          currentSkyCondition == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '$currentSkyCondition',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,

                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlyTemp = hourlyForecast['main']['temp']
                          .toString();
                      final hourlySkyCondition =
                          hourlyForecast['weather'][0]['main'];
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      final formattedTime = DateFormat.j().format(time);

                      return HourlyForecastCard(
                        text: formattedTime.toString(),
                        icon:
                            hourlySkyCondition == 'Clouds' ||
                                hourlySkyCondition == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature: '$hourlyTemp K',
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 16,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$currentHumidity%',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '$currentWindSpeed m/s',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
