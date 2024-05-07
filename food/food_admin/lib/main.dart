import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_admin/firebase_options.dart';
import 'package:food_admin/models/admin_model.dart';
import 'package:food_admin/provider/admin_provider.dart';
import 'package:food_admin/provider/image_provider.dart';
import 'package:food_admin/screens/admin_page.dart';
import 'package:food_admin/screens/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(AdminModelAdapter());
  await Hive.openBox<AdminModel>('admin');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Imageprovider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Foodie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AdminProvider>(
        builder: (context, value, child) {
          value.checkLoggedIn(context);
          return value.fetchdata != null
              ? const AdminPage()
              : const LoginPage();
        },
      ),
    );
  }
}
