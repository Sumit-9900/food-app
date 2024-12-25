import 'package:flutter/material.dart';
import 'package:food_client/utils/textstyle.dart';

class Appbar extends StatelessWidget {
  final String title;
  const Appbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Center(
          child: Text(
            title,
            style: Style.text,
          ),
        ),
      ),
    );
  }
}
