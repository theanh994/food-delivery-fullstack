import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/food_provider.dart';
import '../../../providers/cart_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/shimmer_loading.dart';
import 'food_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi vào trang
    Future.microtask(() => context.read<FoodProvider>().fetchMenu());
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chào mừng trở lại!", style: TextStyle(color: Colors.grey)),
                            Text("Tiệm đồ ăn Violet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.notifications_none, color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Hãy chọn món bạn muốn...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Banner (Tĩnh)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDoSYG1kKMdLjXOpMstXd1efJZsisGws6EGSJ0jzPbTlv2cwyRfwCpVxeWirXGdRcellKGmGBuR87AyDk3YZZ7uNbi2v_lJ1_VooyaoLE6q6OPZtHyTH27m9bI05NGUB3IUKuPRQy7u4as9v66Mo9BGn_SMzWCelZUZk1VVVI3XDwEqiPJ9x6ZJ4eI5JqWZ8P_0moOy9MhXgUNtOghYvYE78yiWJkDSRbREuQ0wOUVmHJlzYXzeB-lpEpLXftZEJdBLp1PKki2CrqAK"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 3. Categories
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: foodProvider.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: foodProvider.categories.length + 1,
                    itemBuilder: (context, index) {
                      bool isAll = index == 0;
                      int catId = isAll ? 0 : foodProvider.categories[index - 1].id;
                      String name = isAll ? "Tất cả" : foodProvider.categories[index - 1].name;
                      bool isSelected = foodProvider.selectedCategoryId == catId;

                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ChoiceChip(
                          label: Text(name),
                          selected: isSelected,
                          onSelected: (_) => foodProvider.selectCategory(catId),
                          selectedColor: AppTheme.bronzeGold,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      );
                    },
                  ),
              ),
            ),

            // 4. Product Grid
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: foodProvider.isLoading
                  ? SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                      delegate: SliverChildBuilderDelegate((_, __) => const FoodSkeleton(), childCount: 4),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => FoodCard(
                          food: foodProvider.foods[index],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(food: foodProvider.foods[index]))),
                        ),
                        childCount: foodProvider.foods.length,
                      ),
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Nếu giỏ hàng trống thì không hiện nút
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            backgroundColor: AppTheme.darkPurple,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            elevation: 10,
            label: Row(
              children: [
                // Hình tròn nhỏ hiển thị số lượng món
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.bronzeGold,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${cart.totalItems}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hiển thị tổng tiền tạm tính
                Text(
                  "Xem giỏ hàng • ${cart.subtotal.toInt()}đ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            icon: const Icon(Icons.shopping_bag, color: AppTheme.bronzeGold),
          );
        },
      ),
      // Căn lề nút nằm ở chính giữa phía dưới màn hình
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}