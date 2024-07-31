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

FirebaseAuth auth = FirebaseAuth.instance;

class UserProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController1 = TextEditingController();
  TextEditingController passController1 = TextEditingController();
  TextEditingController forgotemail = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  FocusNode namefocusNode = FocusNode();
  FocusNode emailfocusNode = FocusNode();
  FocusNode passfocusNode = FocusNode();
  FocusNode emailfocusNode1 = FocusNode();
  FocusNode passfocusNode1 = FocusNode();
  FocusNode forgotfocusNode = FocusNode();
  DocumentReference? docRef;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;
  UserCredential? userCredential;
  User? usr = auth.currentUser;
  String namee = '';
  String emaill = '';
  int _currentPage = 0;
  int get currentPage => _currentPage;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    emailController1.dispose();
    passController1.dispose();
    passfocusNode.dispose();
    namefocusNode.dispose();
    emailfocusNode.dispose();
    forgotemail.dispose();
    forgotfocusNode.dispose();
  }

  void pageIndex(int value) {
    _currentPage = value;
    notifyListeners();
  }

  Future<void> getDetails() async {
    await firestore
        .collection('users')
        .doc(usr!.uid)
        .collection('details')
        .doc(usr!.uid)
        .get();
  }

  void signUp(BuildContext context) async {
    if (emailController.text.isNotEmpty ||
        passController.text.isNotEmpty ||
        nameController.text.isNotEmpty) {
      try {
        isLoading = true;
        notifyListeners();

        namee = nameController.text.trim();
        emaill = emailController.text.trim();

        userCredential = await auth.createUserWithEmailAndPassword(
          email: emaill,
          password: passController.text.trim(),
        );

        addDetails();

        // log('UserCredentail :- ${userCredential!.user!.uid}');
        if (userCredential != null &&
            userCredential!.user != null &&
            context.mounted) {
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
    nameController.clear();
    emailController.clear();
    passController.clear();
    namefocusNode.unfocus();
    emailfocusNode.unfocus();
    passfocusNode.unfocus();
  }

  void addDetails() async {
    if (usr == null) {
      return;
    }
    await firestore
        .collection('users')
        .doc(userCredential!.user!.uid)
        .collection('details')
        .doc(userCredential!.user!.uid)
        .set({
      'username': namee,
      'email': emaill,
    });
    // log('UserUID :-${user!.uid}');
  }

  void logIn(BuildContext context) async {
    if (emailController1.text.isNotEmpty || passController1.text.isNotEmpty) {
      try {
        isLoading = true;
        notifyListeners();

        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController1.text,
          password: passController1.text,
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
    emailController1.clear();
    passController1.clear();
    emailfocusNode1.unfocus();
    passfocusNode1.unfocus();
  }

  Future<void> resetPassword() async {
    if (forgotemail.text.isNotEmpty) {
      try {
        await auth.sendPasswordResetEmail(email: forgotemail.text);
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
    forgotemail.clear();
    forgotfocusNode.unfocus();
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
        await currentUser!.delete();
        String docid = docRef!.id;
        // log(docid);
        await firestore.collection('user').doc(docid).delete();
      }
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
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: e.code,
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    }
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File convertedImage = File(image.path);
      _selectedImage = convertedImage;
      log('Image selected');
      // log(selectedImage.toString());
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
    // log(downloadUrl);

    // log('ImageUID :- ${user!.uid}');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(usr!.uid)
        .collection('profileImage')
        .doc(usr!.uid)
        .set({
      'userImage': downloadUrl,
    });
  }
}
