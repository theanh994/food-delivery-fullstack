import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_item.dart';
import '../widgets/edit_cart_item_sheet.dart';
import '../../../providers/food_provider.dart';
import '../../order/screens/order_success_screen.dart'; // THÊM DÒNG NÀY

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
              children:[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        const Text("Sản phẩm đã chọn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        
                        // Danh sách món ăn
                        ...cart.items.map((item) => _buildCartItem(item, cart)),

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

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn trên để nút Edit đẹp hơn
        children: [
          // 1. Ảnh món ăn
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl, 
              width: 70, height: 70, 
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], width: 70, height: 70, child: const Icon(Icons.fastfood, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          
          // 2. Nội dung thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- DÒNG TÊN MÓN & NÚT SỬA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    
                    // NÚT SỬA ĐƠN HÀNG (Mới thêm)
                    GestureDetector(
                      onTap: () {
                        // Lấy FoodModel gốc từ FoodProvider để biết món này có những options nào
                        final food = context.read<FoodProvider>().foods.firstWhere((f) => f.id == item.foodId);
                        
                        // Hiển thị BottomSheet chỉnh sửa
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Cho phép vuốt nếu nội dung dài
                          backgroundColor: Colors.transparent,
                          builder: (context) => EditCartItemSheet(cartItem: item, food: food),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.bronzeGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_note, color: AppTheme.bronzeGold, size: 20),
                      ),
                    ),
                  ],
                ),
                
                // Hiển thị các Options đã chọn
                if (item.selectedOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.selectedOptions.map((e) => "${e.groupName}: ${e.selectedItems.join(', ')}").join('\n'),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ),

                // Hiển thị Ghi chú bằng tay
                if (item.note != null && item.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text("Ghi chú: ${item.note!}", 
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ),
                  
                const SizedBox(height: 8),
                
                // --- DÒNG GIÁ TIỀN & BỘ TĂNG GIẢM ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${item.totalItemPrice.toInt()}đ", 
                      style: const TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: Colors.grey.shade300)
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => cart.decrementQuantity(item.uniqueId), 
                            icon: const Icon(Icons.remove, size: 16, color: AppTheme.darkPurple),
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            onPressed: () => cart.incrementQuantity(item.uniqueId), 
                            icon: const Icon(Icons.add, size: 16, color: AppTheme.darkPurple),
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Column(
        children:[
          _summaryRow("Tạm tính", "${cart.subtotal.toInt()}đ"),
          _summaryRow("Phí giao hàng", "${cart.shippingFee.toInt()}đ"),
          const Divider(),
          _summaryRow("Tổng thanh toán", "${cart.totalAmount.toInt()}đ", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(CartProvider cart, AuthProvider auth, OrderProvider orderProv) {
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
            int? orderId = await orderProv.placeOrder(
              customerId: auth.currentUser!.id,
              address: _addressController.text,
              note: _noteController.text,
              cart: cart,
            );
            if (mounted) {
              if (orderId != null) {
                // Nếu có orderId nghĩa là đặt hàng thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đặt hàng thành công!'), backgroundColor: Colors.green),
                );
                
                // Điều hướng sang màn hình Thành công (hoặc Chi tiết đơn hàng vừa tạo)
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId))
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đặt hàng thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple, minimumSize: const Size(double.infinity, 56)),
          child: orderProv.isPlacingOrder 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Đặt hàng ngay • ${cart.totalAmount.toInt()}đ", style: const TextStyle(color: AppTheme.bronzeGold, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() => const Center(child: Text("Giỏ hàng trống"));
  
  Widget _buildSectionHeader(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children:[Icon(icon, size: 18, color: AppTheme.darkPurple), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
  
  InputDecoration _inputStyle(String hint) => InputDecoration(
    hintText: hint, filled: true, fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
  );
  
  Widget _summaryRow(String label, String value, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
      Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 20 : 14, color: isTotal ? AppTheme.darkPurple : Colors.black)),
    ]),
  );

}