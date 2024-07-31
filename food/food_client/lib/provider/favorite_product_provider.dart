import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? usr = auth.currentUser;

class FavoriteProductProvider extends ChangeNotifier {
  List<String> favoriteProductIds = [];
  bool toggle = false;
  List<String> docIds = [];

  Future<void> addFavoriteProducts(Map<String, dynamic> data, String id) async {
    if (favoriteProductIds.contains(id)) {
      favoriteProductIds.remove(id);
      toggle = true;
      final data = await firestore
          .collection('users')
          .doc(usr!.uid)
          .collection('favoriteproducts')
          .get();
      for (var doc in data.docs) {
        if (doc.data()['id'] == id) {
          await doc.reference.delete();
        }
      }
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
      await firestore
          .collection('users')
          .doc(usr!.uid)
          .collection('favoriteproducts')
          .add(data);
      Fluttertoast.showToast(
        msg: 'Product added to Favorite!!!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
    notifyListeners();
  }

  Future<void> getData() async {
    final data = await firestore
        .collection('users')
        .doc(usr!.uid)
        .collection('favoriteproducts')
        .get();

    for (var doc in data.docs) {
      docIds.add(doc['id']);
    }
    notifyListeners();
  }
}
