class WeatherSnapshot {
  WeatherSnapshot({
    required this.city,
    required this.country,
    required this.localTime,
    required this.condition,
    required this.iconUrl,
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKph,
    required this.uv,
    required this.pressureMb,
    required this.visibilityKm,
    required this.hourly,
    required this.daily,
  });

  final String city;
  final String country;
  final String localTime;
  final String condition;
  final String iconUrl;
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final double windKph;
  final double uv;
  final double pressureMb;
  final double visibilityKm;
  final List<HourlyPoint> hourly;
  final List<DailyForecast> daily;

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final condition = current['condition'] as Map<String, dynamic>? ?? {};

    return WeatherSnapshot(
      city: location['name']?.toString() ?? '-',
      country: location['country']?.toString() ?? '-',
      localTime: location['localtime']?.toString() ?? '-',
      condition: condition['text']?.toString() ?? '-',
      iconUrl: condition['icon']?.toString() ?? '',
      tempC: _toDouble(current['temp_c']),
      feelsLikeC: _toDouble(current['feelslike_c']),
      humidity: _toInt(current['humidity']),
      windKph: _toDouble(current['wind_kph']),
      uv: _toDouble(current['uv']),
      pressureMb: _toDouble(current['pressure_mb']),
      visibilityKm: _toDouble(current['vis_km']),
      hourly: _extractNext12Hours(json),
      daily: _extract7Days(json),
    );
  }

  static List<HourlyPoint> _extractNext12Hours(Map<String, dynamic> json) {
    final now = DateTime.now();
    final forecast = json['forecast'] as Map<String, dynamic>?;
    final forecastDay = forecast?['forecastday'] as List<dynamic>? ?? [];

    final allHours = <HourlyPoint>[];
    for (final day in forecastDay) {
      final dayMap = day as Map<String, dynamic>;
      final hourEntries = dayMap['hour'] as List<dynamic>? ?? [];
      for (final item in hourEntries) {
        final entry = item as Map<String, dynamic>;
        final timeRaw = entry['time']?.toString() ?? '';
        final parsedTime = DateTime.tryParse(timeRaw);
        if (parsedTime == null) {
          continue;
        }
        allHours.add(
          HourlyPoint(
            time: parsedTime,
            tempC: _toDouble(entry['temp_c']),
            humidity: _toInt(entry['humidity']).toDouble(),
          ),
        );
      }
    }

    final nextHours =
        allHours.where((entry) => !entry.time.isBefore(now)).take(12).toList();
    if (nextHours.isNotEmpty) {
      return nextHours;
    }

    return allHours.take(12).toList();
  }

  static List<DailyForecast> _extract7Days(Map<String, dynamic> json) {
    final forecast = json['forecast'] as Map<String, dynamic>?;
    final forecastDay = forecast?['forecastday'] as List<dynamic>? ?? [];

    final daily = <DailyForecast>[];
    for (final dayItem in forecastDay) {
      final dayMap = dayItem as Map<String, dynamic>;
      final dayData = dayMap['day'] as Map<String, dynamic>? ?? {};
      final condition = dayData['condition'] as Map<String, dynamic>? ?? {};
      final hourEntries = dayMap['hour'] as List<dynamic>? ?? [];
      final date = DateTime.tryParse(dayMap['date']?.toString() ?? '');
      if (date == null) {
        continue;
      }

      final hourly = <HourlyPoint>[];
      for (final item in hourEntries) {
        final entry = item as Map<String, dynamic>;
        final hourTime = DateTime.tryParse(entry['time']?.toString() ?? '');
        if (hourTime == null) {
          continue;
        }
        hourly.add(
          HourlyPoint(
            time: hourTime,
            tempC: _toDouble(entry['temp_c']),
            humidity: _toInt(entry['humidity']).toDouble(),
          ),
        );
      }

      daily.add(
        DailyForecast(
          date: date,
          condition: condition['text']?.toString() ?? '-',
          iconUrl: condition['icon']?.toString() ?? '',
          maxTempC: _toDouble(dayData['maxtemp_c']),
          minTempC: _toDouble(dayData['mintemp_c']),
          avgHumidity: _toInt(dayData['avghumidity']),
          maxWindKph: _toDouble(dayData['maxwind_kph']),
          chanceOfRain: _toInt(dayData['daily_chance_of_rain']),
          hourly: hourly,
        ),
      );
    }

    return daily;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class HourlyPoint {
  const HourlyPoint({
    required this.time,
    required this.tempC,
    required this.humidity,
  });

  final DateTime time;
  final double tempC;
  final double humidity;

  String get hourLabel {
    final hour = time.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.iconUrl,
    required this.maxTempC,
    required this.minTempC,
    required this.avgHumidity,
    required this.maxWindKph,
    required this.chanceOfRain,
    required this.hourly,
  });

  final DateTime date;
  final String condition;
  final String iconUrl;
  final double maxTempC;
  final double minTempC;
  final int avgHumidity;
  final double maxWindKph;
  final int chanceOfRain;
  final List<HourlyPoint> hourly;

  String get dayLabel {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }
}
