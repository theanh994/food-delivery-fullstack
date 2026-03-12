import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/cart_item.dart';
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
  final TextEditingController _noteController = TextEditingController();
  List<String> _errorGroups = []; // Để lưu danh sách các nhóm đang bị thiếu lựa chọn

  // 1. KHO LƯU TRỮ LỰA CHỌN: { "Tên nhóm": ["Lựa chọn A", "Lựa chọn B"] }
  final Map<String, List<String>> _userSelections = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaultOptions();
  }

  // Tự động chọn option đầu tiên nếu nhóm đó là Bắt buộc (Required)
  void _initializeDefaultOptions() {
    for (var group in widget.food.optionGroups) {     
        _userSelections[group.name] = [];
    }
  }

  // 2. LOGIC TÍNH GIÁ DỰA TRÊN OPTION ĐANG CHỌN
  double _calculateCurrentPrice() {
    double total = widget.food.price;
    for (var group in widget.food.optionGroups) {
      final selectedNames = _userSelections[group.name] ?? [];
      for (var selectedName in selectedNames) {
        // Tìm item trong group để lấy extraPrice
        final optionItem = group.options.firstWhere((item) => item.name == selectedName);
        total += optionItem.extraPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _calculateCurrentPrice();

    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      body: Stack(
        children: [
          // --- PHẦN NỘI DUNG CUỘN ---
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(),
                _buildFoodInfo(totalPrice),
                
                // --- PHẦN RENDER TÙY CHỌN ĐỘNG (DYNAMIC OPTIONS) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: widget.food.optionGroups.map((group) {
                      return _buildOptionGroup(group);
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 200), // Khoảng trống cho Bottom Bar
              ],
            ),
          ),

          // --- NÚT QUAY LẠI (BACK BUTTON) ---
          Positioned(
            top: 40,
            left: 20,
            child: _circleButton(Icons.arrow_back, () => Navigator.pop(context)),
          ),

          // --- BOTTOM BAR: SỐ LƯỢNG & THÊM VÀO GIỎ ---
          _buildBottomBar(totalPrice),
        ],
      ),
    );
  }

  // Widget hiển thị từng nhóm tùy chọn (Size, Topping, Đường...)
  Widget _buildOptionGroup(dynamic group) {
    bool isError = _errorGroups.contains(group.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Row(
          children: [
            Text(group.name.toUpperCase(), 
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold, 
                // Nếu lỗi thì hiện màu đỏ, không thì hiện màu xám/đen
                color: isError ? Colors.red : Colors.grey, 
                letterSpacing: 1.2
              )),
            if (group.isRequired)
              const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: group.options.map<Widget>((option) {
            bool isSelected = _userSelections[group.name]?.contains(option.name) ?? false;
            
            return ChoiceChip(
              label: Text("${option.name} ${option.extraPrice > 0 ? '(+${option.extraPrice.toInt()}đ)' : ''}"),
              selected: isSelected,
              selectedColor: AppTheme.bronzeGold,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  if (group.isMultiSelect) {
                    // Logic chọn nhiều (Checkbox)
                    if (selected) {
                      _userSelections[group.name]!.add(option.name);
                    } else {
                      _userSelections[group.name]!.remove(option.name);
                    }
                  } else {
                    // Logic chọn một (Radio)
                    _userSelections[group.name] = [option.name];
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget Ảnh Header
  Widget _buildHeaderImage() {
    return Hero(
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
    );
  }

  // Widget Thông tin cơ bản
  Widget _buildFoodInfo(double currentPrice) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.ivoryWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.food.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                Text("${currentPrice.toInt()}đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
              ],
            ),
            const SizedBox(height: 15),
            Text(widget.food.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Widget Thanh toán dưới cùng
  Widget _buildBottomBar(double totalPrice) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Ghi chú cho quán...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _quantitySelector(),
                const SizedBox(width: 15),
                Expanded(child: _addButton(totalPrice)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantitySelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null), icon: const Icon(Icons.remove)),
          Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _addButton(double totalPrice) {
    return ElevatedButton(
      onPressed: () {
        // 1. Log để kiểm tra trong Debug Console
        debugPrint("--- BẮT ĐẦU KIỂM TRA GIỎ HÀNG ---");
        
        setState(() => _errorGroups = []); 
        bool hasError = false;

        // 2. Duyệt qua từng nhóm tùy chọn
        for (var group in widget.food.optionGroups) {
          debugPrint("Nhóm: ${group.name} | Bắt buộc: ${group.isRequired}");

          if (group.isRequired) {
            final selectedItems = _userSelections[group.name] ?? [];
            debugPrint("Số lượng đã chọn của nhóm ${group.name}: ${selectedItems.length}");

            if (selectedItems.isEmpty) {
              _errorGroups.add(group.name);
              hasError = true;
            }
          }
        }

        // 3. Xử lý nếu có lỗi
        if (hasError) {
          debugPrint("KẾT QUẢ: Có lỗi! Không cho thêm vào giỏ.");
          ScaffoldMessenger.of(context).clearSnackBars(); // Xóa thông báo cũ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Vui lòng chọn các mục bắt buộc (*)"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating, // Hiện nổi lên cho dễ thấy
            ),
          );
          setState(() {}); // Render lại để hiện tiêu đề màu đỏ
          return; // DỪNG HÀM TẠI ĐÂY
        }

        // 4. Nếu không lỗi thì mới chạy tiếp code bên dưới
        debugPrint("KẾT QUẢ: Thành công! Đang thêm vào giỏ...");
        // ... (Giữ nguyên phần logic add to Cart của bạn)
        
        List<SelectedOption> selections = [];
        _userSelections.forEach((groupName, items) {
          if (items.isNotEmpty) {
            selections.add(SelectedOption(groupName: groupName, selectedItems: items));
          }
        });

        context.read<CartProvider>().addToCart(
          widget.food,
          totalPrice,
          selections,
          _quantity,
          _noteController.text.isNotEmpty ? _noteController.text : null,
        );

        Navigator.pop(context);
      },
      // ...
      child: Text("THÊM • ${(totalPrice * _quantity).toInt()}đ", style: const TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
    );
  }

  // --- FIX CẢNH BÁO withOpacity ---
  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      // Dùng .withValues thay cho .withOpacity
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}