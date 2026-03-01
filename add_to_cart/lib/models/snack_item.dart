import 'package:flutter/material.dart';

class SnackItem {
  final String name;
  final String category;
  final String subtitle;
  final double price;
  final double oldPrice;
  final int discountPercent;
  final IconData icon;

  const SnackItem({
    required this.name,
    required this.category,
    required this.subtitle,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.icon,
  });
}
