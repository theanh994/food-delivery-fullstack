import 'dart:async'; // Cần để dùng Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/food_provider.dart';
import '../../../providers/cart_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/shimmer_loading.dart';
import 'food_detail_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart'; // Đảm bảo dùng helper tiền tệ

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // --- [MỚI] Controller cho ô tìm kiếm ---
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Chờ màn hình vẽ xong mới gọi API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().fetchMenu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- [MỚI] Hàm xử lý tìm kiếm có Debounce ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<FoodProvider>().searchFoods(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch để lắng nghe mọi thay đổi từ FoodProvider
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header Đã Tinh Chỉnh (Tích hợp Search Logic)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Chào mừng trở lại!", 
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text("Tiệm đồ ăn Violet", 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                    const SizedBox(height: 25),
                    
                    // --- THANH TÌM KIẾM CÓ LOGIC ---
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Hãy chọn món bạn muốn...",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.bronzeGold),
                        // Nút X để xóa nhanh từ khóa khi đang tìm kiếm
                        suffixIcon: _searchController.text.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<FoodProvider>().searchFoods("");
                              },
                            )
                          : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), 
                          borderSide: BorderSide.none
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Banner & 3. Categories (Sẽ ẩn đi khi đang tìm kiếm để tập trung vào kết quả)
            if (!foodProvider.isSearching) ...[
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
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
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
            ],

            // --- 4. PRODUCT GRID (CẬP NHẬT LOGIC SEARCH/NORMAL) ---
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: foodProvider.isLoading
                  ? SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                      delegate: SliverChildBuilderDelegate((_, __) => const FoodSkeleton(), childCount: 4),
                    )
                  : (foodProvider.isSearching && foodProvider.searchResults.isEmpty)
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text("Không tìm thấy món ăn bạn yêu cầu", style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Nếu đang search thì lấy từ searchResults, ngược lại lấy từ list foods của category
                              final listToShow = foodProvider.isSearching 
                                  ? foodProvider.searchResults 
                                  : foodProvider.foods;
                              
                              return FoodCard(
                                food: listToShow[index],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(food: listToShow[index]))),
                              );
                            },
                            childCount: foodProvider.isSearching 
                                ? foodProvider.searchResults.length 
                                : foodProvider.foods.length,
                          ),
                        ),
            ),
          ],
        ),
      ),

      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            backgroundColor: AppTheme.darkPurple,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            elevation: 10,
            label: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppTheme.bronzeGold, shape: BoxShape.circle),
                  child: Text("${cart.totalItems}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Text("Xem giỏ hàng • ${FormatUtils.formatMoney(cart.totalAmount)}", // Dùng helper tiền tệ
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            icon: const Icon(Icons.shopping_bag, color: AppTheme.bronzeGold),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}