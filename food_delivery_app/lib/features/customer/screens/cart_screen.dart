import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/address_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_noti.dart';
import '../../../core/utils/format_utils.dart'; // Thêm dòng này vào nhóm import

import '../../../data/models/cart_item.dart';
import '../widgets/edit_cart_item_sheet.dart';
import '../../../providers/food_provider.dart';
import '../../order/screens/order_success_screen.dart'; 

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _voucherController = TextEditingController();

  // Tự động lấy danh sách địa chỉ khi vào giỏ hàng ---
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      Future.microtask(() => 
        context.read<AddressProvider>().fetchAddresses(user.id)
      );
    }
  }

  // Hàm hiển thị bảng chọn địa chỉ
  void _showAddressSelector() {
    final addressProv = context.read<AddressProvider>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chọn địa chỉ giao hàng", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              addressProv.addresses.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("Bạn chưa lưu địa chỉ nào")),
                  )
                : Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addressProv.addresses.length,
                      itemBuilder: (context, index) {
                        final addr = addressProv.addresses[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: AppTheme.bronzeGold),
                          title: Text(addr['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(addr['address_detail']),
                          onTap: () {
                            // Khi chọn: Điền vào ô nhập và đóng bảng
                            setState(() {
                              _addressController.text = addr['address_detail'];
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: AppTheme.darkPurple),
                title: const Text("Quản lý sổ địa chỉ"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/address_book');
                },
              )
            ],
          ),
        );
      },
    );
  }

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

                        // Nâng cấp phần tiêu đề Địa chỉ có thêm nút chọn nhanh ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader(Icons.location_on, "Địa chỉ giao hàng"),
                            TextButton(
                              onPressed: _showAddressSelector,
                              child: const Text("Chọn từ sổ địa chỉ", 
                                style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: _inputStyle("Nhập địa chỉ nhận hàng hoặc chọn từ sổ địa chỉ..."),
                        ),

                        const SizedBox(height: 20),
                        _buildSectionHeader(Icons.notes, "Ghi chú cho Tài xế / Quán"),
                        TextField(
                          controller: _noteController,
                          decoration: _inputStyle("VD: Tới nơi gọi mình nhé..."),
                        ),

                        const SizedBox(height: 24),

                        // Trong Column của SingleChildScrollView:
                        _buildSectionHeader(Icons.confirmation_number_outlined, "Ưu đãi & Voucher"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherController,
                                decoration: _inputStyle("Nhập mã giảm giá...").copyWith(
                                  prefixIcon: const Icon(Icons.sell_outlined, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                bool success = await cart.applyVoucher(_voucherController.text.trim());
                                if (mounted) {
                                  if (success) {
                                    AppNoti.show(context, "Đã áp dụng mã giảm giá!", type: NotiType.success);
                                  } else {
                                    AppNoti.show(context, "Mã không hợp lệ hoặc không đủ điều kiện", type: NotiType.error);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                              child: const Text("ÁP DỤNG", style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        if (cart.appliedVoucherCode != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 5),
                                Text("Đang sử dụng mã: ${cart.appliedVoucherCode}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    cart.removeVoucher();
                                    _voucherController.clear();
                                  },
                                  child: const Text("Xóa", style: TextStyle(color: Colors.red, fontSize: 12)),
                                )
                              ],
                            ),
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
              errorBuilder: (_, _, _) => Container(color: Colors.grey[200], width: 70, height: 70, child: const Icon(Icons.fastfood, color: Colors.grey)),
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
                    Text(FormatUtils.formatMoney(item.totalItemPrice), 
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
        children: [
          _summaryRow("Tạm tính", FormatUtils.formatMoney(cart.subtotal)),
          _summaryRow("Phí giao hàng", FormatUtils.formatMoney(cart.shippingFee)),
          
          // NẾU CÓ GIẢM GIÁ THÌ HIỆN DÒNG MÀU XANH
          if (cart.discountAmount > 0)
            _summaryRow(
              "Giảm giá Voucher", 
              "-${FormatUtils.formatMoney(cart.discountAmount)}", 
              isDiscount: true // <--- Bật màu xanh lá
            ),
          
          const Divider(),
          _summaryRow(
            "Tổng thanh toán", 
            FormatUtils.formatMoney(cart.totalAmount), 
            isTotal: true // <--- Bật màu tím và chữ to
          ),
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
              AppNoti.show(context, "Vui lòng nhập địa chỉ", type: NotiType.error);
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
                // MỚI:
                AppNoti.show(context, "Đơn hàng của bạn đang được chuẩn bị!", type: NotiType.success);
                
                // Điều hướng sang màn hình Thành công (hoặc Chi tiết đơn hàng vừa tạo)
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId))
                );
              } else {
                AppNoti.show(context, "Đặt hàng thất bại. Vui lòng thử lại!", type: NotiType.error);
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple, minimumSize: const Size(double.infinity, 56)),
          child: orderProv.isPlacingOrder 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("Đặt hàng ngay • ${FormatUtils.formatMoney(cart.totalAmount)}", 
                style: const TextStyle(color: AppTheme.bronzeGold, fontSize: 16, fontWeight: FontWeight.bold)),
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
  
  Widget _summaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // Nhãn (Tạm tính, Phí ship, Giảm giá...)
          Text(
            label, 
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, 
              fontSize: isTotal ? 18 : 14,
              // Nếu là giảm giá thì nhãn cũng hiện màu xanh nhẹ
              color: isDiscount ? Colors.green.shade700 : Colors.black87,
            )
          ),
          
          // Giá trị tiền
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: isTotal ? 20 : 14, 
              // ĐỔI MÀU DỰA TRÊN LOẠI DÒNG:
              // 1. Tổng tiền -> Tím thẫm
              // 2. Giảm giá -> Xanh lá
              // 3. Mặc định -> Đen
              color: isTotal 
                  ? AppTheme.darkPurple 
                  : (isDiscount ? Colors.green.shade700 : Colors.black),
            )
          ),
        ],
      ),
    );
  }
}