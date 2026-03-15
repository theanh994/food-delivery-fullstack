import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // --- LOGIC: MỞ LIÊN KẾT NGOÀI (Gọi điện, Email) ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      // AppBar Tím thẫm theo HTML
      appBar: AppBar(
        backgroundColor: AppTheme.darkPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.bronzeGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "HỖ TRỢ & LIÊN HỆ",
          style: TextStyle(color: AppTheme.ivoryWhite, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HERO SECTION ---
            _buildHero(),

            // --- NỘI DUNG CHÍNH ---
            Transform.translate(
              offset: const Offset(0, -20),
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
                    _sectionTitle("LIÊN HỆ NHANH"),
                    const SizedBox(height: 15),
                    
                    // Nút Gọi Hotline
                    _buildContactCard(
                      icon: Icons.call,
                      title: "Gọi Hotline",
                      sub: "Hỗ trợ 24/7 (Phí 1.000đ/phút)",
                      onTap: () => _launchURL("tel:19001234"),
                    ),
                    
                    // Nút Messenger
                    _buildContactCard(
                      icon: Icons.chat_bubble,
                      title: "Nhắn tin Messenger",
                      sub: "Phản hồi trong 5-10 phút",
                      onTap: () => _launchURL("https://m.me/epicure"),
                    ),
                    
                    // Nút Email
                    _buildContactCard(
                      icon: Icons.mail,
                      title: "Gửi Email",
                      sub: "support@epicure.vn",
                      onTap: () => _launchURL("mailto:support@epicure.vn"),
                    ),

                    const SizedBox(height: 40),
                    _sectionTitle("CÂU HỎI THƯỜNG GẶP"),
                    const SizedBox(height: 15),

                    // --- FAQ SECTION (ExpansionTiles) ---
                    _buildFAQItem(
                      "Phí ship tính thế nào?",
                      "Phí giao hàng được tính dựa trên khoảng cách từ nhà hàng đến vị trí của bạn. Epicure thường xuyên có các mã miễn phí vận chuyển cho đơn hàng từ 200k."
                    ),
                    _buildFAQItem(
                      "Làm sao để hủy đơn?",
                      "Bạn có thể hủy đơn trực tiếp trên ứng dụng trong vòng 2 phút kể từ khi đặt. Sau thời gian này, vui lòng liên hệ Hotline để được hỗ trợ."
                    ),
                    _buildFAQItem(
                      "Tôi muốn hợp tác làm tài xế?",
                      "Rất hoan nghênh bạn! Vui lòng truy cập trang 'Đối tác' hoặc gửi thông tin qua email tuyển dụng để chúng tôi liên hệ tư vấn."
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

  // Widget Hero Header
  Widget _buildHero() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppTheme.darkPurple,
      child: Stack(
        children: [
          Positioned(
            top: -20, left: -20,
            child: CircleAvatar(radius: 50, backgroundColor: AppTheme.bronzeGold.withValues(alpha: 0.1)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("CHÀO BẠN,", style: TextStyle(color: AppTheme.bronzeGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text("Epicure có thể giúp gì\ncho bạn?", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget Thẻ liên hệ
  Widget _buildContactCard({required IconData icon, required String title, required String sub, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.bronzeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppTheme.bronzeGold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget FAQ (ExpansionTile)
  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        iconColor: AppTheme.bronzeGold,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5));
  }
}