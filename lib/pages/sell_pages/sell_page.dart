import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';
import 'package:prelovedly/widgets/sell/sell_form.dart';
import 'package:prelovedly/routes/app_routes.dart';

class JualPage extends StatefulWidget {
  const JualPage({super.key});

  @override
  State<JualPage> createState() => _JualPageState();
}

class _JualPageState extends State<JualPage> {
  late final SellController sell;
  late final MainNavController nav;

  @override
  void initState() {
    super.initState();
    sell = Get.find<SellController>();
    nav = Get.find<MainNavController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sell.prepareCreate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Jual',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SellFormBody(
        onAfterSave: () {
          // ✅ paling aman balik ke root home (yang punya navbar)
          Get.offAllNamed(Routes.home);

          // ✅ pindah tab ke Profile
          nav.changeTab(4);
        },
      ),
    );
  }
}
