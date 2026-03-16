import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';
import '../../../core/utils/app_noti.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});
  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _typeC = TextEditingController();
  final _plateC = TextEditingController();
  File? _licenseImage;
  File? _portraitImage; // Thêm ảnh chân dung

  // Hàm chọn ảnh có menu chọn Camera hoặc Gallery
  Future<void> _pickImage(bool isLicense) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện (Để test)'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => isLicense ? _licenseImage = File(picked.path) : _portraitImage = File(picked.path));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) setState(() => isLicense ? _licenseImage = File(picked.path) : _portraitImage = File(picked.path));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_typeC.text.isEmpty || _plateC.text.isEmpty || _licenseImage == null || _portraitImage == null) {
      AppNoti.show(context, "Vui lòng điền đủ thông tin và tải lên cả 2 ảnh", type: NotiType.error);
      return;
    }
    
    final user = context.read<AuthProvider>().currentUser!;
    bool ok = await context.read<DriverProvider>().submitProfile(
      userId: user.id, 
      type: _typeC.text, 
      plate: _plateC.text, 
      license: _licenseImage!,
      portrait: _portraitImage!, // Gửi thêm ảnh chân dung
    );

    if (ok && mounted) {
      AppNoti.show(context, "Hồ sơ đã được gửi thành công!", type: NotiType.success);
      Navigator.pushReplacementNamed(context, '/driver_pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<DriverProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(backgroundColor: AppTheme.darkPurple, title: const Text("ĐĂNG KÝ ĐỐI TÁC")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin phương tiện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            TextField(controller: _typeC, decoration: _inputStyle("Loại xe (VD: Honda Wave)")),
            const SizedBox(height: 15),
            TextField(controller: _plateC, decoration: _inputStyle("Biển số xe")),
            
            const SizedBox(height: 30),
            const Text("Hình ảnh hồ sơ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(child: _buildUploadBox("Ảnh chân dung", _portraitImage, () => _pickImage(false))),
                const SizedBox(width: 15),
                Expanded(child: _buildUploadBox("Bằng lái xe", _licenseImage, () => _pickImage(true))),
              ],
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPurple,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              child: isLoading 
                ? const CircularProgressIndicator(color: AppTheme.bronzeGold) 
                : const Text("GỬI HỒ SƠ NGAY", style: TextStyle(color: AppTheme.bronzeGold, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, File? image, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.darkPurple.withValues(alpha: 0.2)),
            ),
            child: image == null 
              ? const Icon(Icons.add_a_photo, color: AppTheme.darkPurple, size: 40)
              : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(image, fit: BoxFit.cover)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true, fillColor: Colors.white
  );
}