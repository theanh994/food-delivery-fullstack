import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../providers/auth_provider.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.name ?? "";
    _phoneController.text = user?.phone ?? "";
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _updateProfile() async {
    final user = context.read<AuthProvider>().currentUser;
    var request = http.MultipartRequest('POST', Uri.parse("${ApiEndpoints.baseUrl}/update_profile.php"));
    
    request.fields['user_id'] = user!.id.toString();
    request.fields['name'] = _nameController.text;
    request.fields['phone'] = _phoneController.text;

    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', _imageFile!.path));
    }

    final response = await request.send();
    
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      
      try {
        final data = jsonDecode(respStr);
        
        if (data['status'] == 'success') {
          if (!mounted) return;
          final newUser = UserModel.fromJson(data['data']);
          context.read<AuthProvider>().updateUser(newUser);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
          Navigator.pop(context);
        }
      } catch (e) {
        // Nếu Server trả về lỗi HTML (như bạn gặp), nó sẽ rơi vào đây thay vì crash app
        debugPrint("Lỗi Parse JSON: $respStr");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi phản hồi từ máy chủ!"), backgroundColor: Colors.orange)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa hồ sơ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40) : null,
                  ),
                  Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, backgroundColor: AppTheme.bronzeGold, child: Icon(Icons.edit, size: 18, color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ và tên")),
            const SizedBox(height: 20),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("LƯU THAY ĐỔI"),
            )
          ],
        ),
      ),
    );
  }
}