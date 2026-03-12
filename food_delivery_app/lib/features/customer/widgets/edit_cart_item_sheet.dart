import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/food_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';

class EditCartItemSheet extends StatefulWidget {
  final CartItem cartItem;
  final FoodModel food; // Cần food model gốc để lấy danh sách optionGroups

  const EditCartItemSheet({super.key, required this.cartItem, required this.food});

  @override
  State<EditCartItemSheet> createState() => _EditCartItemSheetState();
}

class _EditCartItemSheetState extends State<EditCartItemSheet> {
  late int _quantity;
  late Map<String, List<String>> _userSelections;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
    _noteController = TextEditingController(text: widget.cartItem.note);
    
    // Đổ dữ liệu cũ đã chọn vào Map
    _userSelections = {};
    for (var group in widget.food.optionGroups) {
      final oldSelection = widget.cartItem.selectedOptions.firstWhere(
        (s) => s.groupName == group.name,
        orElse: () => SelectedOption(groupName: group.name, selectedItems: []),
      );
      _userSelections[group.name] = List.from(oldSelection.selectedItems);
    }
  }

  double _calculateCurrentPrice() {
    double total = widget.food.price;
    for (var group in widget.food.optionGroups) {
      final selectedNames = _userSelections[group.name] ?? [];
      for (var name in selectedNames) {
        final item = group.options.firstWhere((o) => o.name == name);
        total += item.extraPrice;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double currentPrice = _calculateCurrentPrice();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chỉnh sửa tùy chọn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          
          // Render các nhóm tùy chọn (Giống hệt FoodDetail nhưng thu gọn)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: widget.food.optionGroups.map((group) => _buildOptionGroup(group)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: "Ghi chú mới...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              _quantitySelector(),
              const SizedBox(width: 16),
              Expanded(child: _updateButton(currentPrice)),
            ],
          ),
        ],
      ),
    );
  }

  // Tái sử dụng Widget render group
  Widget _buildOptionGroup(dynamic group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: group.options.map<Widget>((option) {
            bool isSelected = _userSelections[group.name]?.contains(option.name) ?? false;
            return ChoiceChip(
              label: Text(option.name),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (group.isMultiSelect) {
                    val ? _userSelections[group.name]!.add(option.name) : _userSelections[group.name]!.remove(option.name);
                  } else {
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

  Widget _quantitySelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null), icon: const Icon(Icons.remove)),
          Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _updateButton(double currentPrice) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: () {
        List<SelectedOption> selections = [];
        _userSelections.forEach((name, items) {
          if (items.isNotEmpty) selections.add(SelectedOption(groupName: name, selectedItems: items));
        });

        // Tạo Unique ID mới sau khi sửa
        selections.sort((a, b) => a.groupName.compareTo(b.groupName));
        String optionsKey = selections.map((e) => e.toString()).join('|');
        String newUniqueId = "${widget.food.id}|$optionsKey|${_noteController.text}";

        CartItem newItem = CartItem(
          uniqueId: newUniqueId,
          foodId: widget.food.id,
          name: widget.food.name,
          basePrice: widget.food.price,
          totalItemPrice: currentPrice,
          selectedOptions: selections,
          imageUrl: widget.cartItem.imageUrl,
          quantity: _quantity,
          note: _noteController.text,
        );

        context.read<CartProvider>().updateCartItem(widget.cartItem.uniqueId, newItem);
        Navigator.pop(context);
      },
      child: const Text("CẬP NHẬT", style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
    );
  }
}