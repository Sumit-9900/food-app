import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_admin/pages/admin_page.dart';
import 'package:food_admin/provider/admin_provider.dart';
import 'package:food_admin/style/textstyle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    usercontroller.dispose();
    passcontroller.dispose();
    super.dispose();
  }

  void onTap(AdminProvider adminProvider) {
  if (_formkey.currentState!.validate()) {
    _formkey.currentState!.save();
    adminProvider.login().then((_) {
      final user = adminProvider.user;
      final pass = adminProvider.pass;

      if (user.trim() != usercontroller.text.trim() ||
          pass.trim() != passcontroller.text.trim()) {
        Fluttertoast.showToast(
          msg: 'The Username or Password are Invalid!!!',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
        Fluttertoast.showToast(
          msg: 'Login Successful!!!',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
          fontSize: 16,
        );

        usercontroller.clear();
        passcontroller.clear();
      }
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Something went wrong: $error',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        fontSize: 16,
      );
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  top: 35,
                  left: MediaQuery.of(context).size.width / 4.5,
                  child: Text(
                    'Let\'s start with\n Admin',
                    style: Style.text,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(
                          MediaQuery.of(context).size.width,
                          120,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 4,
                  left: MediaQuery.of(context).size.width / 8,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 1.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: usercontroller,
                              enabled: true,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Please enter the Username';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Ionicons.person),
                                hintText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: passcontroller,
                              enabled: true,
                              obscureText: true,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Please enter the Password';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.password_outlined),
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Consumer<AdminProvider>(
                            builder: (context, adminProvider, child) {
                              return GestureDetector(
                                onTap: adminProvider.isLoading
                                    ? null
                                    : () => onTap(adminProvider),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: adminProvider.isLoading
                                          ? const CircularProgressIndicator
                                              .adaptive()
                                          : Text(
                                              'Login',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
