import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../providers/auth_provider.dart';

class ReviewScreen extends StatefulWidget {
  final int orderId;
  final int foodId;
  final String foodName;
  const ReviewScreen({super.key, required this.orderId, required this.foodId, required this.foodName});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();

  Future<void> _submitReview() async {
    final userId = context.read<AuthProvider>().currentUser!.id;
    final res = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/add_review.php"),
      body: jsonEncode({
        "order_id": widget.orderId,
        "customer_id": userId,
        "food_id": widget.foodId,
        "rating": _rating,
        "comment": _commentController.text
      }),
    );
    
    if (jsonDecode(res.body)['status'] == 'success') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi đánh giá!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đánh giá món ăn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(widget.foodName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text("Trải nghiệm của bạn thế nào?"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border, size: 40, color: AppTheme.bronzeGold),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(hintText: "Bình luận của bạn...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: const Text("GỬI ĐÁNH GIÁ"),
            )
          ],
        ),
      ),
    );
  }
}