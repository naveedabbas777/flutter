import 'package:flutter/material.dart';

import '../data/weather_api_service.dart';
import '../domain/weather_models.dart';
import 'widgets/info_card.dart';
import 'widgets/search_bar_card.dart';
import 'widgets/weather_dashboard.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController cityController = TextEditingController(
    text: 'Lahore',
  );
  final WeatherApiService _service = WeatherApiService();

  WeatherSnapshot? snapshot;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await _service.fetchByCity(cityController.text);
      setState(() {
        snapshot = data;
      });
    } on WeatherException catch (error) {
      setState(() {
        snapshot = null;
        errorMessage = error.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primaryContainer.withValues(alpha: 0.92),
              const Color(0xFFEAF8F2),
              const Color(0xFFF6FCF9),
              Colors.white,
            ],
            stops: const [0.0, 0.35, 0.7, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: colors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Weather Insights',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SearchBarCard(
                controller: cityController,
                isLoading: isLoading,
                onSearch: _fetchWeather,
              ),
              const SizedBox(height: 18),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (errorMessage.isNotEmpty)
                InfoCard(
                  title: 'Unable to fetch weather',
                  subtitle: errorMessage,
                  icon: Icons.error_outline,
                )
              else if (snapshot != null)
                WeatherDashboard(snapshot: snapshot!)
              else
                const InfoCard(
                  title: 'No data yet',
                  subtitle: 'Search any city to see weather insights.',
                  icon: Icons.cloud_outlined,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
