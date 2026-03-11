import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkPurple,
        elevation: 0.5,
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sản phẩm đã chọn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        // Danh sách món ăn
                        ...cart.items.values.map((item) => _buildCartItem(item, cart)).toList(),

                        const SizedBox(height: 24),
                        _buildSectionHeader(Icons.location_on, "Địa chỉ giao hàng"),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: _inputStyle("Nhập địa chỉ nhận hàng..."),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionHeader(Icons.notes, "Ghi chú cho Tài xế / Quán"),
                        TextField(
                          controller: _noteController,
                          decoration: _inputStyle("VD: Tới nơi gọi mình nhé..."),
                        ),

                        const SizedBox(height: 24),
                        _buildSummary(cart),
                      ],
                    ),
                  ),
                ),
                _buildBottomCTA(cart, auth, orderProv),
              ],
            ),
    );
  }

  Widget _buildCartItem(item, cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item.imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (item.itemNote != null) Text(item.itemNote!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item.price.toInt()}đ", style: const TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
                    _buildQtySelector(item, cart),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtySelector(item, cart) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          IconButton(onPressed: () => cart.decrementQuantity(item.foodId), icon: const Icon(Icons.remove, size: 16, color: AppTheme.darkPurple)),
          Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => cart.incrementQuantity(item.foodId), icon: const Icon(Icons.add, size: 16, color: AppTheme.darkPurple)),
        ],
      ),
    );
  }

  Widget _buildSummary(cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _summaryRow("Tạm tính", "${cart.subtotal.toInt()}đ"),
          _summaryRow("Phí giao hàng", "${cart.shippingFee.toInt()}đ"),
          const Divider(),
          _summaryRow("Tổng thanh toán", "${cart.totalAmount.toInt()}đ", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(cart, auth, orderProv) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey, width: 0.1))),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: orderProv.isPlacingOrder ? null : () async {
            if (_addressController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập địa chỉ")));
              return;
            }
            bool success = await orderProv.placeOrder(
              customerId: auth.currentUser!.id,
              address: _addressController.text,
              note: _noteController.text,
              cart: cart,
            );
            if (success && mounted) {
              _showSuccessDialog();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple, minimumSize: const Size(double.infinity, 56)),
          child: orderProv.isPlacingOrder 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Đặt hàng ngay • ${cart.totalAmount.toInt()}đ"),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildEmptyCart() => const Center(child: Text("Giỏ hàng trống"));
  Widget _buildSectionHeader(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [Icon(icon, size: 18, color: AppTheme.darkPurple), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
  InputDecoration _inputStyle(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
  );
  Widget _summaryRow(String label, String value, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 20 : 14, color: isTotal ? AppTheme.darkPurple : Colors.black)),
    ]),
  );

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Đặt hàng thành công! Đơn hàng của bạn đang được xử lý.", textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () {
          Navigator.pop(context); // Đóng dialog
          Navigator.pushReplacementNamed(context, '/customer_home');
        }, child: const Text("OK"))],
      ),
    );
  }
}