import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';
import '../../data/providers/product_provider.dart';
import '../products/product_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(productControllerProvider.notifier);
      await notifier.loadProducts();
      await notifier.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final notifier = ref.read(productControllerProvider.notifier);
            await notifier.loadProducts();
            await notifier.loadCategories();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text('Ecoka'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(productControllerProvider.notifier)
                                      .searchProductsLocal('');
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        ref
                            .read(productControllerProvider.notifier)
                            .searchProductsLocal(value.trim());
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildCategoriesSection()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sản phẩm nổi bật',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildProductsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final productState = ref.watch(productControllerProvider);
    final categories = productState.categories;

    if (categories.isEmpty) {
      return const SizedBox.square();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Danh mục sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildAllCategoryItem(),
              ...categories.map(_buildCategoryItem),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCategoryItem() {
    final productState = ref.watch(productControllerProvider);
    final isSelected = productState.selectedCategoryId == null;

    return GestureDetector(
      onTap: () {
        ref.read(productControllerProvider.notifier).filterByCategory(null);
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.apps,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tất cả',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final productState = ref.watch(productControllerProvider);
    final isSelected = productState.selectedCategoryId == category.categoryId;

    return GestureDetector(
      onTap: () {
        ref
            .read(productControllerProvider.notifier)
            .filterByCategory(category.categoryId);
      },
      child: SizedBox(
        width: 95,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _getCategoryIcon(category.categoryName),
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  category.categoryName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppTheme.primaryColor : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    final productState = ref.watch(productControllerProvider);

    if (productState.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (productState.error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(productState.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final notifier = ref.read(productControllerProvider.notifier);
                  await notifier.loadProducts();
                  await notifier.loadCategories();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (productState.products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('Không có sản phẩm nào')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = productState.products[index];
          return _buildProductCard(product);
        }, childCount: productState.products.length),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.productId),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: product.fullMainImageUrl.isNotEmpty
                    ? Image.network(
                        product.fullMainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '${product.displayPrice.toStringAsFixed(0)} ₫',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (product.hasDiscount)
                      Text(
                        '${product.displayOriginalPrice.toStringAsFixed(0)} ₫',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase().trim();

    if (name.contains('bã mía')) {
      return Icons.eco_outlined;
    } else if (name.contains('lục bình')) {
      return Icons.inventory_2_outlined;
    } else if (name.contains('sợi chuối')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('tre')) {
      return Icons.park_outlined;
    }

    return Icons.category_outlined;
  }
}
