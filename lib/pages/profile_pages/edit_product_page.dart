import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/widgets/sell/Sell_form.dart';

class EditProductPage extends StatelessWidget {
  const EditProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sell = Get.find<SellController>();
    final args = Get.arguments as Map?;
    final productId = (args?['id'] ?? '').toString();

    // load sekali
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (productId.isNotEmpty) {
        sell.editingProductId.value = productId;
        await sell.loadProductForEdit(productId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SellFormBody(
        onAfterSave: () => Get.back(),
        leftText: "Move to drafts",
        rightText: "Save",
        onLeftPressed: () => sell.moveProductToDraft(productId),
        onRightPressed: () => sell.updateProduct(productId),
      ),
    );
  }
}
