import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final String temperature;
  const HourlyForecastCard({super.key, required this.text, required this.icon, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return  Card(
                    elevation: 6,
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                          SizedBox(height: 8),
                          Icon(icon, size: 32),
                          SizedBox(height: 8),
                          Text(
                            temperature,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}