import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/user_provider.dart';
import 'package:food_client/screens/terms_conditions_screen.dart';
import 'package:food_client/widgets/profile_card.dart';
import 'package:provider/provider.dart';

var auth = FirebaseAuth.instance;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer<UserProvider>(
          builder: (context, value, child) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('details')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final data1 = snapshot.data!.data();
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 4.5,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(
                                  MediaQuery.of(context).size.width,
                                  110,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width / 2.8,
                          top: MediaQuery.of(context).size.height / 7,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .collection('profileImage')
                                .doc(user!.uid)
                                .snapshots(),
                            builder: ((context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                  ),
                                );
                              } else {
                                final data = snapshot.data!.data();
                                return GestureDetector(
                                  onTap: () async {
                                    await value.pickImage();
                                  },
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(
                                      data != null
                                          ? data['userImage']
                                          : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 12.0,
                            right: 12.0,
                            top: MediaQuery.of(context).size.width / 1.4,
                          ),
                          child: Column(
                            children: [
                              ProfileCard(
                                icon: const Icon(Icons.person),
                                name: 'Name',
                                des: data1 != null
                                    ? data1['username']
                                    : 'No data',
                              ),
                              const SizedBox(height: 10),
                              ProfileCard(
                                icon: const Icon(Icons.email),
                                name: 'Email',
                                des: data1 != null ? data1['email'] : 'No data',
                              ),
                              const SizedBox(height: 10),
                              ProfileCard(
                                icon: const Icon(Icons.edit_document),
                                name: 'Terms and Condition',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TermsandConditionsScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              ProfileCard(
                                icon: const Icon(Icons.delete),
                                name: 'Delete Account',
                                onTap: () {
                                  value.deleteUser(context);
                                },
                              ),
                              const SizedBox(height: 10),
                              ProfileCard(
                                icon: const Icon(Icons.logout),
                                name: 'LogOut',
                                onTap: () {
                                  value.logOut(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
