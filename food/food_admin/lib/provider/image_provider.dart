import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Imageprovider extends ChangeNotifier {
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  String? _selectedItem;
  String? get selectedItem => _selectedItem;

  List<String> category = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool toggleFav = false;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    namecontroller.dispose();
    pricecontroller.dispose();
    detailcontroller.dispose();
  }

  Future<void> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File convertedImage = File(image.path);
      _selectedImage = convertedImage;
      log('Image selected');
      notifyListeners();
    } else {
      log('Image not selected');
    }
  }

  Future<void> sendData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('product-image')
        .child(const Uuid().v4())
        .putFile(_selectedImage!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    // log(downloadUrl);

    Map<String, dynamic> productdata = {
      'productId': const Uuid().v4(),
      'productImage': downloadUrl,
      'productName': namecontroller.text,
      'productPrice': pricecontroller.text,
      'productDetail': detailcontroller.text,
      'productCategory': _selectedItem,
      'toggleFav': toggleFav,
    };

    await FirebaseFirestore.instance
        .collection('product-details')
        .add(productdata);
    _isLoading = false;
    notifyListeners();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    Fluttertoast.showToast(
      msg: 'Product has been added successfully!!!',
      backgroundColor: Colors.green,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      fontSize: 16,
    );
    namecontroller.clear();
    pricecontroller.clear();
    detailcontroller.clear();
    _selectedImage = null;
    notifyListeners();
  }

  void dropdown(String? item) {
    _selectedItem = item;
    notifyListeners();
  }
}
