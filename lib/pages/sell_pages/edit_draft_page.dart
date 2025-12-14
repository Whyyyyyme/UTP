import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/main_nav_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/sell/Sell_form.dart';

class EditDraftPage extends StatelessWidget {
  const EditDraftPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sell = Get.find<SellController>();
    final nav = Get.find<MainNavController>();

    final args = Get.arguments as Map?;
    final id = args?["id"]?.toString();

    if (id == null || id.isEmpty) {
      return const Scaffold(body: Center(child: Text("Draft id tidak ada")));
    }

    return FutureBuilder(
      future: sell.startEditDraft(id), // pastikan ini Future<void>
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

                  await sell.deleteDraft();

                  // ✅ paksa balik ke ShopProfile
                  nav.changeTab(
                    4,
                  ); // tab Profile (kalau kamu pakai navbar index 4)

                  // kalau ShopProfile masih ada di stack, balik sampai ketemu
                  if (Get.routing.route?.settings.name != Routes.shopProfile) {
                    bool found = false;

                    Get.until((route) {
                      if (route.settings.name == Routes.shopProfile) {
                        found = true;
                        return true;
                      }
                      return false;
                    });

                    // kalau ternyata tidak ada di stack, push baru
                    if (!found) {
                      // balik dulu ke Home yang punya navbar, baru push ShopProfile
                      Get.offAllNamed(Routes.home);
                      Get.toNamed(Routes.shopProfile);
                    }
                  }
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

          // ✅ sekarang body cuma form body, bukan scaffold lagi
          body: SellFormBody(
            onAfterSave: () {
              Get.back(); // balik ke ShopProfile
              nav.changeTab(4);
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
