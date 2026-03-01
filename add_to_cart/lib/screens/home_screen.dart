import 'package:add_to_cart/data/snacks_data.dart';
import 'package:add_to_cart/models/snack_item.dart';
import 'package:add_to_cart/routes/app_routes.dart';
import 'package:add_to_cart/state/cart_store.dart';
import 'package:add_to_cart/utils/formatters.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String query = '';
  final Set<String> favorites = <String>{};

  List<String> get categories {
    final unique =
        allSnacks.map((item) => item.category).toSet().toList()..sort();
    return ['All', ...unique];
  }

  List<SnackItem> get filteredSnacks {
    return allSnacks.where((item) {
      final categoryMatch =
          selectedCategory == 'All' || item.category == selectedCategory;
      final queryMatch =
          query.trim().isEmpty ||
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(query.toLowerCase());
      return categoryMatch && queryMatch;
    }).toList();
  }

  Future<void> _openCart() async {
    await Navigator.pushNamed(context, AppRoutes.cart);
    if (mounted) {
      setState(() {});
    }
  }

  void _addToCart(SnackItem item) {
    setState(() {
      CartStore.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(milliseconds: 850),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 360;
    final isWide = screenWidth >= 900;

    final dealsHeight = isNarrow ? 196.0 : 172.0;
    final dealCardWidth = isNarrow ? 148.0 : 180.0;
    final maxGridExtent = isWide ? 280.0 : (isNarrow ? 220.0 : 240.0);
    final productAspectRatio = isNarrow ? 0.64 : (isWide ? 0.86 : 0.75);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 1200 ? 1200.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _TopPromoBar(colors: colors)),
                    SliverToBoxAdapter(
                      child: _HeaderSection(
                        cartCount: CartStore.count,
                        onOpenCart: () {
                          _openCart();
                        },
                        onSearch: (value) => setState(() => query = value),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: _HeroBanner(colors: colors, isNarrow: isNarrow),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 14, 12, 0),
                        child: _SectionTitle(
                          title: 'Top categories',
                          subtitle: 'Find your favorites quickly',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final selected = selectedCategory == category;
                            return ChoiceChip(
                              selected: selected,
                              label: Text(category),
                              onSelected: (_) {
                                setState(() => selectedCategory = category);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: _SectionTitle(
                          title: 'Daily Deals',
                          subtitle: 'Limited-time discounts',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: dealsHeight,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                          scrollDirection: Axis.horizontal,
                          itemCount: allSnacks.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = allSnacks[index];
                            return _DealCard(
                              item: item,
                              colors: colors,
                              width: dealCardWidth,
                              isNarrow: isNarrow,
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                        child: _SectionTitle(
                          title: 'Featured Products',
                          subtitle: '${filteredSnacks.length} items available',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                      sliver: SliverGrid.builder(
                        itemCount: filteredSnacks.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: maxGridExtent,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: productAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredSnacks[index];
                          final isFavorite = favorites.contains(item.name);
                          return _ProductCard(
                            item: item,
                            isNarrow: isNarrow,
                            isFavorite: isFavorite,
                            onFavoriteToggle: () {
                              setState(() {
                                if (isFavorite) {
                                  favorites.remove(item.name);
                                } else {
                                  favorites.add(item.name);
                                }
                              });
                            },
                            onAdd: () => _addToCart(item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          CartStore.count == 0
              ? null
              : SizedBox(
                width: 270,
                child: FloatingActionButton.extended(
                  tooltip: 'Open cart',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onPressed: _openCart,
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text(
                    '${CartStore.count} items • ${formatCurrency(CartStore.total)}',
                  ),
                ),
              ),
    );
  }
}

class _TopPromoBar extends StatelessWidget {
  final ColorScheme colors;

  const _TopPromoBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: colors.primary,
      child: Text(
        'Rs 2500+ order pay → shipping free',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int cartCount;
  final VoidCallback onOpenCart;
  final ValueChanged<String> onSearch;

  const _HeaderSection({
    required this.cartCount,
    required this.onOpenCart,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isNarrow ? 16 : 18,
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.storefront_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ),
              SizedBox(width: isNarrow ? 6 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Snack Bazaar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (!isCompact)
                      const Text(
                        'Deliver to Abbottabad',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                  ],
                ),
              ),
              if (isCompact)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person_outline),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Login',
                )
              else
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: Size(isNarrow ? 44 : 56, 36),
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 8 : 12,
                    ),
                  ),
                  child: const Text('Login'),
                ),
              IconButton(
                tooltip: 'Open cart',
                onPressed: onOpenCart,
                icon: Badge.count(
                  count: cartCount,
                  isLabelVisible: cartCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Looking for products? Start here...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final ColorScheme colors;
  final bool isNarrow;

  const _HeroBanner({required this.colors, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: isNarrow ? 208 : 180),
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E2A4D), Color(0xFF5D4DA8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(34),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Fresh arrivals',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dry Fruit Range',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isNarrow ? 22 : 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Premium quality snacks at unbeatable prices',
            maxLines: isNarrow ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  final SnackItem item;
  final ColorScheme colors;
  final double width;
  final bool isNarrow;

  const _DealCard({
    required this.item,
    required this.colors,
    required this.width,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(isNarrow ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${item.discountPercent}% OFF',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: isNarrow ? 10 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(flex: 2),
          CircleAvatar(
            radius: isNarrow ? 15 : 18,
            backgroundColor: colors.primaryContainer,
            child: Icon(item.icon, color: colors.onPrimaryContainer),
          ),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isNarrow ? 13 : 14,
            ),
          ),
          Text(
            formatCurrency(item.price),
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: isNarrow ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final SnackItem item;
  final bool isNarrow;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.item,
    required this.isNarrow,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 8 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${item.discountPercent}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: isNarrow ? 18 : 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavorite ? const Color(0xFFE91E63) : Colors.black45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: CircleAvatar(
                  radius: isNarrow ? 28 : 34,
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    item.icon,
                    size: isNarrow ? 24 : 30,
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            SizedBox(height: isNarrow ? 6 : 8),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isNarrow ? 13 : 14,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isNarrow ? 11 : 12,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: isNarrow ? 4 : 6),
            Row(
              children: [
                Text(
                  formatCurrency(item.price),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: isNarrow ? 13 : 14,
                  ),
                ),
                if (!isNarrow) ...[
                  const SizedBox(width: 6),
                  Text(
                    formatCurrency(item.oldPrice),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: isNarrow ? 6 : 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: isNarrow ? 16 : 18,
                ),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
