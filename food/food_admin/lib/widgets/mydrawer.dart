import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_admin/pages/login_page.dart';
import 'package:food_admin/provider/admin_provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          return Column(
            children: [
              const DrawerHeader(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/images/boy.png'),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(Ionicons.fast_food_outline),
                  title: Text('Orders'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              GestureDetector(
                onTap: () {
                  adminProvider.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                  Fluttertoast.showToast(
                    msg: 'Logout Successfull!!!',
                    backgroundColor: Colors.green,
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 3,
                    fontSize: 16,
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
