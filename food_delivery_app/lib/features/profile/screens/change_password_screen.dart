import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthProvider>().currentUser!;
      bool success = await context.read<AuthProvider>().changePassword(
        user.id, 
        _oldPassController.text, 
        _newPassController.text
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công!"), backgroundColor: Colors.green));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu cũ không đúng!"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryWhite,
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField("Mật khẩu hiện tại", _oldPassController, true),
              _buildField("Mật khẩu mới", _newPassController, true),
              _buildField("Xác nhận mật khẩu mới", _confirmPassController, true),
              const SizedBox(height: 10),
              const Text("Mật khẩu phải có ít nhất 6 ký tự.", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: context.watch<AuthProvider>().isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkPurple),
                  child: context.watch<AuthProvider>().isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CẬP NHẬT MẬT KHẨU", style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isPass) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkPurple)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPass,
            validator: (val) {
              if (val == null || val.isEmpty) return "Vui lòng nhập";
              if (label.contains("Xác nhận") && val != _newPassController.text) return "Mật khẩu không khớp";
              return null;
            },
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ],
      ),
    );
  }
}