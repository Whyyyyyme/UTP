import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/controller/register_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://bopcgcjsckvpfgncayts.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvcGNnY2pzY2t2cGZnbmNheXRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyODU4ODcsImV4cCI6MjA4MDg2MTg4N30.ZLbt-WQWEuCfPo_PWSmsMdgNTcdqB4DG-EDvo3-6bmQ',
  );

  Get.put(AuthController(), permanent: true);
  Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PreLovedly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
      initialRoute: Routes.login,
      getPages: AppPages.routes,
    );
  }
}
