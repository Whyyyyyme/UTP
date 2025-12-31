import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/view_model/wallet_orders_controller.dart';

class WithdrawPage extends GetView<WalletOrdersController> {
  const WithdrawPage({super.key});

  String rupiah(int v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    final banks = const [
      'BCA',
      'BRI',
      'BNI',
      'Mandiri',
      'CIMB',
      'Permata',
      'BSI',
    ];

    final formKey = GlobalKey<FormState>();
    final selectedBank = RxnString();
    final accountNumberC = TextEditingController();
    final passwordC = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final amount = controller.availableBalance.value;
        final err = controller.error.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text('Amount:', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                rupiah(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Destination Bank'),
                  const SizedBox(height: 6),
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: selectedBank.value,
                      items: banks
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: (v) => selectedBank.value = v,
                      decoration: const InputDecoration(
                        hintText: 'Select...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'This field is required'
                          : null,
                    );
                  }),
                  const SizedBox(height: 12),

                  const Text('Account Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: accountNumberC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Account Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  const Text('Secret Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: passwordC,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Secret Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'This field is required'
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            if (err != null)
              Text(
                err,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: amount <= 0
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false))
                          return;

                        await controller.withdrawAllSubmit(
                          bank: selectedBank.value ?? '',
                          accountNumber: accountNumberC.text,
                          secretPassword: passwordC.text,
                        );
                      },
                child: const Text('Claim Payout'),
              ),
            ),
          ],
        );
      }),
    );
  }
}
