import 'package:flutter/material.dart';

import '../../domain/weather_models.dart';
import 'forecast_chart_card.dart';
import 'metric_pill.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({required this.snapshot, super.key});

  final WeatherSnapshot snapshot;

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  int selectedDayIndex = 0;
  final Set<int> expandedDayIndexes = <int>{};
  final Map<int, GlobalKey> _forecastItemKeys = <int, GlobalKey>{};

  GlobalKey _itemKey(int index) {
    return _forecastItemKeys.putIfAbsent(index, GlobalKey.new);
  }

  void _scrollToForecastIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemContext = _itemKey(index).currentContext;
      if (itemContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        itemContext,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  DailyForecast? get selectedDay {
    if (widget.snapshot.daily.isEmpty) {
      return null;
    }
    if (selectedDayIndex < 0 || selectedDayIndex >= widget.snapshot.daily.length) {
      return widget.snapshot.daily.first;
    }
    return widget.snapshot.daily[selectedDayIndex];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final day = selectedDay;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.snapshot.city}, ${widget.snapshot.country}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.snapshot.condition,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colors.primary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.snapshot.tempC.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Local time: ${widget.snapshot.localTime}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ConditionChip(
                                icon: _conditionIcon(widget.snapshot.condition),
                                label: widget.snapshot.condition,
                              ),
                              _ConditionChip(
                                icon: Icons.access_time_rounded,
                                label: 'Updated live',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.snapshot.iconUrl.isNotEmpty)
                      Image.network(
                      widget.snapshot.iconUrl.startsWith('http')
                        ? widget.snapshot.iconUrl
                        : 'https:${widget.snapshot.iconUrl}',
                        width: 72,
                        height: 72,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.cloud, size: 56),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MetricPill(
                      label: 'Feels like',
                      value: '${widget.snapshot.feelsLikeC.toStringAsFixed(1)}°C',
                      icon: Icons.thermostat,
                      accentColor: const Color(0xFFEF6C00),
                    ),
                    MetricPill(
                      label: 'Humidity',
                      value: '${widget.snapshot.humidity}%',
                      icon: Icons.water_drop_outlined,
                      accentColor: const Color(0xFF0288D1),
                    ),
                    MetricPill(
                      label: 'Wind',
                      value: '${widget.snapshot.windKph.toStringAsFixed(1)} kph',
                      icon: Icons.air,
                      accentColor: const Color(0xFF00897B),
                    ),
                    MetricPill(
                      label: 'UV Index',
                      value: widget.snapshot.uv.toStringAsFixed(1),
                      icon: Icons.wb_sunny_outlined,
                      accentColor: const Color(0xFFF9A825),
                    ),
                    MetricPill(
                      label: 'Pressure',
                      value: '${widget.snapshot.pressureMb.toStringAsFixed(1)} mb',
                      icon: Icons.speed,
                      accentColor: const Color(0xFF6D4C41),
                    ),
                    MetricPill(
                      label: 'Visibility',
                      value: '${widget.snapshot.visibilityKm.toStringAsFixed(1)} km',
                      icon: Icons.visibility_outlined,
                      accentColor: const Color(0xFF3949AB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (day != null) ...[
          ForecastChartCard(
            title: '${day.dayLabel} Temperature',
            subtitle: 'Hourly trend for selected forecast day',
            points: day.hourly,
            valueSelector: (item) => item.tempC,
            lineColor: colors.primary,
            unit: '°C',
            icon: Icons.show_chart,
          ),
          const SizedBox(height: 14),
          ForecastChartCard(
            title: '${day.dayLabel} Humidity',
            subtitle: 'Hourly moisture curve for selected day',
            points: day.hourly,
            valueSelector: (item) => item.humidity,
            lineColor: colors.tertiary,
            unit: '%',
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 14),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Forecast',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < widget.snapshot.daily.length; index++) ...[
                  Container(
                    key: _itemKey(index),
                    child: Column(
                      children: [
                        _DailyForecastTile(
                          day: widget.snapshot.daily[index],
                          isSelected: selectedDayIndex == index,
                          isExpanded: expandedDayIndexes.contains(index),
                          onTap: () {
                            setState(() {
                              selectedDayIndex = index;
                            });
                          },
                          onExpandToggle: () {
                            final willExpand = !expandedDayIndexes.contains(index);
                            setState(() {
                              selectedDayIndex = index;
                              if (expandedDayIndexes.contains(index)) {
                                expandedDayIndexes.remove(index);
                              } else {
                                expandedDayIndexes.add(index);
                              }
                            });
                            if (willExpand) {
                              _scrollToForecastIndex(index);
                            }
                          },
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                          child: expandedDayIndexes.contains(index)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _ExpandedForecastDay(
                                    day: widget.snapshot.daily[index],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (index != widget.snapshot.daily.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _conditionIcon(String condition) {
    final value = condition.toLowerCase();
    if (value.contains('rain') || value.contains('drizzle')) {
      return Icons.umbrella_outlined;
    }
    if (value.contains('cloud')) {
      return Icons.cloud_outlined;
    }
    if (value.contains('snow')) {
      return Icons.ac_unit;
    }
    if (value.contains('storm') || value.contains('thunder')) {
      return Icons.flash_on;
    }
    return Icons.wb_sunny_outlined;
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  const _DailyForecastTile({
    required this.day,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    required this.onExpandToggle,
  });

  final DailyForecast day;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onExpandToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer.withValues(alpha: 0.40)
              : colors.primaryContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                day.dayLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (day.iconUrl.isNotEmpty)
              Image.network(
                day.iconUrl.startsWith('http') ? day.iconUrl : 'https:${day.iconUrl}',
                width: 34,
                height: 34,
                errorBuilder:
                    (_, __, ___) => Icon(Icons.cloud_outlined, color: colors.primary),
              )
            else
              Icon(Icons.cloud_outlined, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                day.condition,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${day.maxTempC.toStringAsFixed(0)}° / ${day.minTempC.toStringAsFixed(0)}°',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Rain ${day.chanceOfRain}%  •  Hum ${day.avgHumidity}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onExpandToggle,
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedForecastDay extends StatelessWidget {
  const _ExpandedForecastDay({required this.day});

  final DailyForecast day;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.dayLabel} Hourly Forecast',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ForecastChartCard(
            title: 'Temperature',
            subtitle: 'Hourly temperature details',
            points: day.hourly,
            valueSelector: (item) => item.tempC,
            lineColor: colors.primary,
            unit: '°C',
            icon: Icons.thermostat,
          ),
          const SizedBox(height: 10),
          ForecastChartCard(
            title: 'Humidity',
            subtitle: 'Hourly humidity details',
            points: day.hourly,
            valueSelector: (item) => item.humidity,
            lineColor: colors.tertiary,
            unit: '%',
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 8),
          Text(
            'Hourly Values',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final hour in day.hourly)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _HourlyValueChip(hour: hour),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyValueChip extends StatelessWidget {
  const _HourlyValueChip({required this.hour});

  final HourlyPoint hour;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hour.hourLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.thermostat, size: 14, color: Color(0xFFEF6C00)),
              const SizedBox(width: 4),
              Text('${hour.tempC.toStringAsFixed(1)}°C'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 14, color: Color(0xFF0288D1)),
              const SizedBox(width: 4),
              Text('${hour.humidity.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }
}
