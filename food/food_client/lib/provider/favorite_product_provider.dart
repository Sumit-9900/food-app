import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? usr = auth.currentUser;

class FavoriteProductProvider extends ChangeNotifier {
  FavoriteProductProvider() {
    listenToFavorites();
  }

  List<String> favoriteProductIds = [];
  bool toggle = false;
  List<String> docIds = [];

  Future<void> addFavoriteProducts(Map<String, dynamic> data, String id) async {
    if (favoriteProductIds.contains(id)) {
      favoriteProductIds.remove(id);
      toggle = true;
      notifyListeners();

      final data = await firestore
          .collection('products')
          .doc(usr!.uid)
          .collection('favorite_products')
          .get();
      for (var doc in data.docs) {
        if (doc.data()['id'] == id) {
          await doc.reference.delete();
        }
      }

      await getData();

      Fluttertoast.showToast(
        msg: 'Product removed from Favorite!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    } else {
      favoriteProductIds.add(id);
      toggle = false;
      notifyListeners();

      await firestore
          .collection('products')
          .doc(usr!.uid)
          .collection('favorite_products')
          .add(data);

      await getData();

      Fluttertoast.showToast(
        msg: 'Product added to Favorite!!!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
  }

  Future<void> getData() async {
    final data = await firestore
        .collection('products')
        .doc(usr!.uid)
        .collection('favorite_products')
        .get();

    for (var doc in data.docs) {
      docIds.add(doc['id']);
    }
    notifyListeners();
  }

  void listenToFavorites() {
    firestore
        .collection('products')
        .doc(usr!.uid)
        .collection('favorite_products')
        .snapshots()
        .listen((snapshot) {
      docIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
      notifyListeners();
    });
  }
}
