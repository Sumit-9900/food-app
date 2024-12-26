import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_client/screens/curved_bar_screen.dart';
import 'package:food_client/screens/login_screen.dart';
import 'package:food_client/screens/signup_screen.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  bool isLoading = false;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;
  FirebaseAuth auth = FirebaseAuth.instance;

  User? getCurrentUser() => auth.currentUser;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  void pageIndex(int value) {
    _currentPage = value;
    notifyListeners();
  }

  void signUp(BuildContext context,
      {required String email,
      required String password,
      required String name}) async {
    if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
      try {
        isLoading = true;
        notifyListeners();

        final userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        addDetails(name: name, email: email);

        if (userCredential.user != null && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CurvedBarScreen(),
            ),
          );
          Fluttertoast.showToast(
            msg: 'SignUp Successfully!!!',
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            fontSize: 16,
          );
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.code,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter the details!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
    isLoading = false;
    notifyListeners();
  }

  void addDetails({required String name, required String email}) async {
    if (getCurrentUser() != null) {
      await firestore.collection('user_details').doc(getCurrentUser()!.uid).set(
        {
          'username': name,
          'email': email,
          'userImage': '',
        },
      );
    }
  }

  void logIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    if (email.isNotEmpty || password.isNotEmpty) {
      try {
        isLoading = true;
        notifyListeners();

        final userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CurvedBarScreen(),
            ),
          );
          Fluttertoast.showToast(
            msg: 'LogIn Successfully!!!',
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
            fontSize: 16,
          );
        }
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.code,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter the details!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
    isLoading = false;
    notifyListeners();
  }

  void resetPassword(String email) async {
    if (email.isNotEmpty) {
      try {
        isLoading = true;
        notifyListeners();

        await auth.sendPasswordResetEmail(email: email);
        Fluttertoast.showToast(
          msg: 'Password reset email sent Successfully!!!',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: e.code,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter the E-mail!!!',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> logOut(BuildContext context) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
    Fluttertoast.showToast(
      msg: 'LogOut Successfully!!!',
      backgroundColor: Colors.green,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      fontSize: 16,
    );
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      if (getCurrentUser() != null) {
        final userDoc =
            firestore.collection('products').doc(getCurrentUser()!.uid);
        final userDocData = await userDoc.get();

        if (userDocData.exists) {
          final imagePath = userDocData.data()?['userImage'];
          if (imagePath != null && imagePath.isNotEmpty) {
            try {
              await storage.refFromURL(imagePath).delete();
              debugPrint("User image deleted successfully.");
            } catch (e) {
              debugPrint("Failed to delete user image: $e");
            }
          }
        }

        // Delete user details and subcollections
        await firestore
            .collection('user_details')
            .doc(getCurrentUser()!.uid)
            .delete();
        await deleteSubcollections(userDoc, 'cart_products');
        await deleteSubcollections(userDoc, 'favorite_products');
        await userDoc.delete();

        await getCurrentUser()!.delete();

        Fluttertoast.showToast(
          msg: 'User Deleted Successfully!!!',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error deleting user: $e");
    }
  }

  Future<void> deleteSubcollections(
      DocumentReference userDocRef, String collectionName) async {
    final subcollectionRef = userDocRef.collection(collectionName);
    final subcollectionDocs = await subcollectionRef.get();

    for (final doc in subcollectionDocs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File convertedImage = File(image.path);
      _selectedImage = convertedImage;
      log('Image selected');
      sendImage();
      notifyListeners();
    } else {
      log('Image not selected');
    }
  }

  Future<void> sendImage() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child('profile-pic')
        .child(getCurrentUser()!.uid)
        .putFile(_selectedImage!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('user_details')
        .doc(getCurrentUser()!.uid)
        .set(
      {
        'userImage': downloadUrl,
      },
      SetOptions(merge: true),
    );
  }
}
