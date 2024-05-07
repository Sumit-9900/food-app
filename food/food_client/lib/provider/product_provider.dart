import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _count = 1;
  int? get count => _count;

  List productDetails = [];
  List icecream = [];
  List pizza = [];
  List salad = [];
  List burger = [];
  List updatedList = [];
  var element;
  int gotindex = 0;

  ProductProvider() {
    init();
  }

  void init() {
    icecream.clear();
    pizza.clear();
    salad.clear();
    burger.clear();
    updatedList.clear();
    gotindex = 0;
    updatedList = icecream;
  }

  void addDetails(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    icecream.clear();
    pizza.clear();
    salad.clear();
    burger.clear();

    for (int i = 0; i < snapshot.data!.docs.length; i++) {
      element = snapshot.data!.docs.elementAt(i).data();
      productDetails.add(element);
      if (productDetails[i]['productCategory'] == 'Ice-cream') {
        icecream.add(element);
      }
      if (productDetails[i]['productCategory'] == 'Pizza') {
        pizza.add(element);
      }
      if (productDetails[i]['productCategory'] == 'Salad') {
        salad.add(element);
      }
      if (productDetails[i]['productCategory'] == 'Burger') {
        burger.add(element);
      }
    }
    // notifyListeners();
  }

  void onTap(int index) {
    for (int i = 0; i < 4; i++) {
      int ind = i;
      if (ind == index) {
        gotindex = ind;
      }
    }

    if (index == 0) {
      updatedList = icecream;
    } else if (index == 1) {
      updatedList = pizza;
    } else if (index == 2) {
      updatedList = salad;
    } else if (index == 3) {
      updatedList = burger;
    }
    updatedList.clear();
    notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 1) {
      _count--;
      notifyListeners();
    }
  }
}
