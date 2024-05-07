import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/provider/favorite_product_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/provider/stripe_provider.dart';
import 'package:food_client/provider/user_provider.dart';
import 'package:food_client/screens/onboard_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:food_client/screens/curved_bar.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
  // await dotenv.load(fileName: '.env');
  // Stripe.publishableKey = dotenv.env['publishableKey']!;
  Stripe.publishableKey =
      'pk_test_51P6y0dSAg5DgXRL5JpekriF5ArEmhjqkQW0bZv9PeSlsY5prxjPnGm5v6I60PpHMfA6aPAxTpcDvMMBc7cPXGXXZ00XrDp9qDl';
  await Stripe.instance.applySettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
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
      home: FirebaseAuth.instance.currentUser != null
          ? const CurvedBar()
          : const OnBoardScreen(),
    );
  }
}
