import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;

class CartProvider extends ChangeNotifier {
  CartProvider() {
    listenToCartChanges();
  }

  List<String> ids = [];
  double total = 0.0;
  Future<void> addProductToCart(Map<String, dynamic> data, String id) async {
    if (!ids.contains(id)) {
      ids.add(id);
      await firestore
          .collection('products')
          .doc(user!.uid)
          .collection('cart_products')
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
        .collection('products')
        .doc(user!.uid)
        .collection('cart_products')
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

  void storeOrdersToFirestore(Map<String, dynamic> data) async {
    await firestore.collection('order_details').add(data);
  }

  void listenToCartChanges() {
    auth.authStateChanges().listen((User? usr) {
      if (usr != null) {
        user = usr;
        firestore
            .collection('products')
            .doc(user!.uid)
            .collection('cart_products')
            .snapshots()
            .listen((snapshot) {
          total = 0.0;
          for (var doc in snapshot.docs) {
            total += (double.parse(doc['price'] ?? 0) * (doc['count'] ?? 0));
          }
          notifyListeners();
        });
      }
    });
  }
}
