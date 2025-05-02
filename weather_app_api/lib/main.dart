import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _city = '';
  double? _temperature;
  String? _description;
  String? _weatherIcon;
  bool _isLoading = false;

  Future<void> fetchWeather() async {
    final apiKey =
        '2acca7dadf9618f6d3edf45d5f91ab1a'; // ← Replace this with your real OpenWeatherMap API key
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _city = data['name'];
          _temperature = data['main']['temp'].toDouble();
          _description = data['weather'][0]['description'];
          _weatherIcon = data['weather'][0]['icon'];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('City not found!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget weatherInfo() {
    if (_temperature == null) {
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_weatherIcon != null)
          Image.network(
            'https://openweathermap.org/img/wn/${_weatherIcon!}@2x.png',
          ),
        Text(
          '$_city',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(
          '${_temperature!.toStringAsFixed(1)}°C',
          style: const TextStyle(fontSize: 50),
        ),
        Text('$_description', style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Weather App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              weatherInfo(),
          ],
        ),
      ),
    );
  }
}
