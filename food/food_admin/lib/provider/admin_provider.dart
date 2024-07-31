import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String>? adminData;

  String _user = '';
  String get user => _user;

  String _pass = '';
  String get pass => _pass; 

  Future<void> login() async {
    QuerySnapshot<Map<String, dynamic>> snapshots =
        await firestore.collection('admin').get();

    _user = snapshots.docs[0]['username'];
    _pass = snapshots.docs[0]['password'];

    notifyListeners();
  }

  Future<void> checkLoggedIn() async {
    QuerySnapshot<Map<String, dynamic>> snapshots =
        await firestore.collection('admin').get();

    _user = snapshots.docs[0]['username'];
    _pass = snapshots.docs[0]['password'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('admindata', [user, pass]);

    adminData = prefs.getStringList('admindata');

    notifyListeners();
  }

  void logout() {
    adminData = null;
  }
}
