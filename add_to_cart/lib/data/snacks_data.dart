import 'package:add_to_cart/models/snack_item.dart';
import 'package:flutter/material.dart';

const List<SnackItem> allSnacks = [
  SnackItem(
    name: 'Premium Panjiri 500g',
    category: 'Dry Fruits',
    subtitle: 'Roasted nuts and seeds blend',
    price: 599,
    oldPrice: 699,
    discountPercent: 14,
    icon: Icons.breakfast_dining_rounded,
  ),
  SnackItem(
    name: 'Protein Mix Nuts 500g',
    category: 'Nuts',
    subtitle: 'Almonds, walnuts, pistachio',
    price: 749,
    oldPrice: 799,
    discountPercent: 7,
    icon: Icons.local_cafe_rounded,
  ),
  SnackItem(
    name: 'Green Cardamom 100g',
    category: 'Spices',
    subtitle: 'Fresh aroma, premium quality',
    price: 469,
    oldPrice: 499,
    discountPercent: 6,
    icon: Icons.spa_rounded,
  ),
  SnackItem(
    name: 'Sidr Honey 250g',
    category: 'Honey',
    subtitle: 'Pure and naturally sweet',
    price: 1199,
    oldPrice: 1460,
    discountPercent: 18,
    icon: Icons.emoji_food_beverage_rounded,
  ),
  SnackItem(
    name: 'Fennel Seeds 400g',
    category: 'Seeds',
    subtitle: 'Fragrant digestive refresh',
    price: 349,
    oldPrice: 399,
    discountPercent: 13,
    icon: Icons.eco_rounded,
  ),
  SnackItem(
    name: 'Sunflower Seeds 500g',
    category: 'Seeds',
    subtitle: 'Lightly roasted crunchy bites',
    price: 499,
    oldPrice: 799,
    discountPercent: 37,
    icon: Icons.grass_rounded,
  ),
];
