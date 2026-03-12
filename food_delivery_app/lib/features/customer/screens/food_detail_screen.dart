import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/food_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/cart_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodModel food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  String _selectedSize = 'M';
  
  // Tách biệt các biến tùy chọn
  String _selectedIce = '50%';      // Chỉ dùng cho drink
  String _selectedSugar = '50%';    // Chỉ dùng cho drink
  String _selectedSpiciness = 'Không cay'; // Chỉ dùng cho food
  
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      body: Stack(
        children: [
          // 1. Nội dung cuộn
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Hero Section
                Stack(
                  children: [
                    Hero(
                      tag: 'food-${widget.food.id}',
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.food.imageUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // NÚT QUAY LẠI (Back Button) - Hiển thị rõ ràng trên ảnh
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _circleButton(Icons.arrow_back, () {
                              Navigator.pop(context); // Thoát mà không thêm vào giỏ
                            }),
                            const Text("EPICURE", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                            _circleButton(Icons.share, () {}),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.ivoryWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(widget.food.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                            Text("${widget.food.price.toInt()}đ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppTheme.bronzeGold, width: 3))),
                          child: Text(widget.food.description, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),

                        const SizedBox(height: 30),
                        _sectionTitle("CHỌN KÍCH CỠ (SIZE)"),
                        Row(
                          children: [
                            _optionCard("M", "Vừa", _selectedSize == 'M', () => setState(() => _selectedSize = 'M')),
                            const SizedBox(width: 15),
                            _optionCard("L", "Lớn (+5.000đ)", _selectedSize == 'L', () => setState(() => _selectedSize = 'L')),
                          ],
                        ),

                        // --- LOGIC HIỂN THỊ TÙY CHỌN RIÊNG BIỆT ---
                        if (widget.food.foodType.trim() == 'drink') ...[
                          const SizedBox(height: 25),
                          _sectionTitle("MỨC ĐÁ"),
                          Row(
                            children: ['0%', '50%', '100%'].map((ice) => _chipOption(ice, _selectedIce == ice, () => setState(() => _selectedIce = ice))).toList(),
                          ),
                          const SizedBox(height: 25),
                          _sectionTitle("MỨC ĐƯỜNG"),
                          Row(
                            children: ['0%', '25%', '50%', '100%'].map((sugar) => _chipOption(sugar, _selectedSugar == sugar, () => setState(() => _selectedSugar = sugar))).toList(),
                          ),
                        ] else if (widget.food.foodType.trim() == 'food') ...[
                          const SizedBox(height: 25),
                          _sectionTitle("MỨC ĐỘ CAY"),
                          Row(
                            children: ['Không cay', 'Cay vừa', 'Rất cay'].map((level) => 
                              _chipOption(level, _selectedSpiciness == level, () => setState(() => _selectedSpiciness = level))
                            ).toList(),
                          ),
                        ],

                        const SizedBox(height: 180), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "Ghi chú thêm (VD: Không hành...)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            IconButton(onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null), icon: const Icon(Icons.remove)),
                            Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // --- LOGIC GHÉP CHUỖI GHI CHÚ CHUẨN ---
                            String fullOptions = "Size: $_selectedSize";
                            
                            if (widget.food.foodType.trim() == 'drink') {
                              fullOptions += ", $_selectedIce Đá, $_selectedSugar Đường";
                            } else if (widget.food.foodType.trim() == 'food') {
                              fullOptions += ", $_selectedSpiciness";
                            }

                            if (_noteController.text.isNotEmpty) {
                              fullOptions += " (${_noteController.text})";
                            }

                            // Thêm vào giỏ
                            context.read<CartProvider>().addToCart(
                              widget.food, 
                              quantity: _quantity, 
                              note: fullOptions,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã thêm vào giỏ hàng!"), backgroundColor: Colors.green)
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Thêm vào giỏ • ${(widget.food.price * _quantity).toInt()}đ", 
                            style: const TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
  );

  Widget _optionCard(String title, String sub, bool isSelected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.bronzeGold : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? AppTheme.bronzeGold.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );

  Widget _chipOption(String label, bool isSelected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.bronzeGold,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    ),
  );
}