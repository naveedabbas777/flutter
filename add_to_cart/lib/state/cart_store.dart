import 'package:add_to_cart/models/snack_item.dart';

class CartStore {
  static final Map<SnackItem, int> _items = <SnackItem, int>{};

  static Map<SnackItem, int> get items => _items;

  static int get count =>
      _items.values.fold(0, (sum, quantity) => sum + quantity);

  static double get total => _items.entries.fold(
    0,
    (sum, entry) => sum + (entry.key.price * entry.value),
  );

  static void add(SnackItem item) {
    _items[item] = (_items[item] ?? 0) + 1;
  }

  static void increment(SnackItem item) {
    _items[item] = (_items[item] ?? 0) + 1;
  }

  static void decrement(SnackItem item) {
    final current = _items[item] ?? 0;
    if (current <= 1) {
      _items.remove(item);
      return;
    }
    _items[item] = current - 1;
  }

  static void clear() {
    _items.clear();
  }
}
