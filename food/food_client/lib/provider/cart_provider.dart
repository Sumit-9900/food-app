import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;

class CartProvider extends ChangeNotifier {
  List<String> ids = [];
  List<String> docIds = [];
  double total = 0.0;
  List cartProduct = [];
  Future<void> addProductToCart(Map<String, dynamic> data, String id) async {
    if (!ids.contains(id)) {
      ids.add(id);
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('cartproducts')
          .add(data);
      Fluttertoast.showToast(
        msg: 'Product added to Cart!!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Product already added to Cart!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
  }

  Future<void> deleteProductFromCart(String id) async {
    final data = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('cartproducts')
        .get();

    for (var doc in data.docs) {
      if (doc.data()['id'] == id) {
        await doc.reference.delete();
      }
    }
    Fluttertoast.showToast(
      msg: 'Product deleted from Cart!!',
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      fontSize: 16,
    );
  }

  Future<void> getProduct() async {
    if (user != null) {
      final data = await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('cartproducts')
          .get();

      total = 0;
      for (var doc in data.docs) {
        total += (double.parse(doc['price'] ?? 0) * (doc['count'] ?? 0));
      }
    }
    notifyListeners();
  }
}
