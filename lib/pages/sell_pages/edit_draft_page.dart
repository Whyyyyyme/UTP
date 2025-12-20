import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/sell/sell_form.dart'; // ✅ pastikan nama file bener

class EditDraftPage extends StatefulWidget {
  const EditDraftPage({super.key});

  @override
  State<EditDraftPage> createState() => _EditDraftPageState();
}

class _EditDraftPageState extends State<EditDraftPage> {
  late final SellController sell;
  late final MainNavController nav;

  String? id;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();

    sell = Get.find<SellController>();
    nav = Get.find<MainNavController>();

    final args = Get.arguments as Map?;
    id = args?["id"]?.toString();

    // ✅ kalau id kosong, kasih dummy future biar aman
    if (id == null || id!.isEmpty) {
      _loadFuture = Future.value();
    } else {
      // ✅ ini yang paling aman (ada cache di controller kamu)
      _loadFuture = sell.prepareEditDraft(id!);
      // kalau kamu tidak punya prepareEditDraft, pakai:
      // _loadFuture = sell.startEditDraft(id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (id == null || id!.isEmpty) {
      return const Scaffold(body: Center(child: Text("Draft id tidak ada")));
    }

    return FutureBuilder<void>(
      future: _loadFuture, // ✅ tidak re-run tiap rebuild
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Gagal load draft: ${snapshot.error}")),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Edit Draft',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value != 'delete') return;

                  final confirm = await showDeleteDraftDialog();
                  if (confirm != true) return;

                  await sell.deleteDraftById(id!);

                  // ✅ paling aman: balik ke home, lalu buka shopProfile
                  Get.offAllNamed(Routes.home);
                  nav.changeTab(4);
                  Get.toNamed(
                    Routes.shopProfile,
                    arguments: {'initialTabIndex': 0},
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Hapus draft',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SellFormBody(
            onAfterSave: () {
              Get.offAllNamed(Routes.home);
              nav.changeTab(4);
              Get.toNamed(
                Routes.shopProfile,
                arguments: {'initialTabIndex': 0},
              );
            },
          ),
        );
      },
    );
  }
}

Future<bool?> showDeleteDraftDialog() {
  return Get.dialog<bool>(
    AlertDialog(
      title: const Text('Hapus draft?'),
      content: const Text('Draft yang dihapus tidak bisa dikembalikan.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}
