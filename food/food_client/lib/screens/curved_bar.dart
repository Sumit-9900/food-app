import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_client/screens/cart_screen.dart';
import 'package:food_client/screens/favorites_screen.dart';
import 'package:food_client/screens/home_screen.dart';
import 'package:food_client/screens/profile_screen.dart';
import 'package:ionicons/ionicons.dart';

class CurvedBar extends StatefulWidget {
  const CurvedBar({super.key});

  @override
  State<CurvedBar> createState() => _CurvedBarState();
}

class _CurvedBarState extends State<CurvedBar> {
  List<Widget> pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 60.0,
        items: const [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.favorite_outline,
            color: Colors.white,
          ),
          Icon(
            Ionicons.cart_outline,
            color: Colors.white,
          ),
          Icon(
            Ionicons.person_outline,
            color: Colors.white,
          )
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: pages[currentIndex],
    );
  }
}
