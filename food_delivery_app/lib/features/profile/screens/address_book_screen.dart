import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});
  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser!.id;
    Future.microtask(() => context.read<AddressProvider>().fetchAddresses(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Địa chỉ của tôi")),
      body: Consumer<AddressProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.addresses.length,
            itemBuilder: (context, index) {
              final addr = prov.addresses[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.bronzeGold),
                  title: Text(addr['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(addr['address_detail']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => prov.deleteAddress(int.parse(addr['id'].toString()), context.read<AuthProvider>().currentUser!.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.bronzeGold,
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog() {
    final titleC = TextEditingController();
    final detailC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm địa chỉ mới"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleC, decoration: const InputDecoration(hintText: "Tên gợi nhớ (VD: Nhà riêng)")),
          TextField(controller: detailC, decoration: const InputDecoration(hintText: "Địa chỉ chi tiết")),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () {
            context.read<AddressProvider>().addAddress(context.read<AuthProvider>().currentUser!.id, titleC.text, detailC.text);
            Navigator.pop(context);
          }, child: const Text("Thêm")),
        ],
      )
    );
  }
}