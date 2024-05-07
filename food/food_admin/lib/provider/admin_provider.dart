import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_admin/models/admin_model.dart';
import 'package:food_admin/screens/admin_page.dart';
import 'package:food_admin/screens/login_page.dart';
import 'package:hive/hive.dart';

class AdminProvider extends ChangeNotifier {
  AdminModel? _fetchdata;

  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void disposeController() {
    usercontroller.dispose();
    passcontroller.dispose();
    log('user and pass controller disposed');
    super.dispose();
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    var user;
    var pass;
    if (usercontroller.text.trim().isEmpty ||
        passcontroller.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Enter the Username and Password!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    } else if (usercontroller.text.trim().isNotEmpty ||
        passcontroller.text.trim().isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> snapshots =
          await firestore.collection('admin').get();
      for (var snapshot in snapshots.docs) {
        user = snapshot['username'];
        pass = snapshot['password'];
      }
      if (user != usercontroller.text.trim()) {
        Fluttertoast.showToast(
          msg: 'The Username is Invalid!!!',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      } else if (pass != passcontroller.text.trim()) {
        Fluttertoast.showToast(
          msg: 'The Password is Invalid!!!',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      } else {
        if (context.mounted) {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => const AdminPage(),
          );
          Navigator.of(context).pushReplacement(route);
          Fluttertoast.showToast(
            msg: 'Login Successfull!!!',
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            fontSize: 16,
          );
        }
      }
    }
    usercontroller.clear();
    passcontroller.clear();
    notifyListeners();
  }

  AdminModel? get fetchdata => _fetchdata;
  Future<void> checkLoggedIn(BuildContext context) async {
    var user;
    var pass;
    var adminbox = Hive.box<AdminModel>('admin');
    QuerySnapshot<Map<String, dynamic>> snapshots =
        await firestore.collection('admin').get();
    for (var snapshot in snapshots.docs) {
      user = snapshot['username'];
      pass = snapshot['password'];
    }
    var data = AdminModel(username: user, password: pass);
    await adminbox.put('admindata', data);

    _fetchdata = adminbox.get('admindata');
    if (_fetchdata != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminPage(),
        ),
      );
      notifyListeners();
    }
  }

  void logout(BuildContext context) {
    _fetchdata = null;
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
  }
}
