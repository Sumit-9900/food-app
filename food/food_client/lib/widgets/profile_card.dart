import 'package:flutter/material.dart';
import 'package:food_client/utils/textstyle.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.icon,
    required this.name,
    this.des = '',
    this.onTap,
  });

  final Icon icon;
  final String name;
  final String? des;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        child: Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Style.text8,
                  ),
                  if (des != null && des!.isNotEmpty)
                    Text(
                      des!,
                      style: Style.text8,
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
