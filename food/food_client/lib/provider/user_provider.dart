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
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  DocumentReference? docRef;
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

  // Future<void> getDetails() async {
  //   await firestore
  //       .collection('users')
  //       .doc(getCurrentUser()!.uid)
  //       .collection('details')
  //       .doc(getCurrentUser()!.uid)
  //       .get();
  // }

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
    if (auth.currentUser != null) {
      User? currentUser = auth.currentUser;

      // Delete Firestore document first
      if (docRef != null) {
        String docid = docRef!.id;
        await firestore.collection('user_details').doc(docid).delete();
      }

      // Delete Firebase user
      await currentUser!.delete();

      // Navigate to sign-up screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignUpScreen(),
          ),
        );
      }

      Fluttertoast.showToast(
        msg: 'User Deleted Successfully!!!',
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'requires-recent-login':
        errorMessage = 'Please log in again to delete your account.';
        break;
      default:
        errorMessage = 'An unexpected error occurred: ${e.code}';
    }
    Fluttertoast.showToast(
      msg: errorMessage,
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 3,
      fontSize: 16,
    );
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
        .child(const Uuid().v4())
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
