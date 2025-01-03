import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/user_provider.dart';
import 'package:food_client/screens/terms_conditions_screen.dart';
import 'package:food_client/widgets/profile_card.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    return Scaffold(
      body: SingleChildScrollView(
        child: _profile(context, firestore, auth),
      ),
    );
  }

  Widget _profile(
      BuildContext context, FirebaseFirestore firestore, FirebaseAuth auth) {
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
              stream: firestore
                  .collection('user_details')
                  .doc(auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Error: ${snapshot.error}');
                  return Container();
                } else if (snapshot.data == null) {
                  debugPrint('No data');
                  return Container();
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
                  );
                } else {
                  final data = snapshot.data?.data();
                  return Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return GestureDetector(
                        onTap: () async {
                          await userProvider.pickImage();
                        },
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(
                            data != null
                                ? data['userImage'] != ''
                                    ? data['userImage']
                                    : 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
                                : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          _profileBody(context, firestore, auth),
        ],
      ),
    );
  }

  Widget _profileBody(
      BuildContext context, FirebaseFirestore firestore, FirebaseAuth auth) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: MediaQuery.of(context).size.width / 1.4,
      ),
      child: StreamBuilder(
        stream: firestore
            .collection('user_details')
            .doc(auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return Container();
          }

          final data = snapshot.data?.data();

          return Column(
            children: [
              ProfileCard(
                icon: const Icon(Icons.person),
                name: 'Name',
                des: data != null ? data['username'] : 'No Name',
              ),
              const SizedBox(height: 10),
              ProfileCard(
                icon: const Icon(Icons.email),
                name: 'Email',
                des: data != null ? data['email'] : 'No Email',
              ),
              const SizedBox(height: 10),
              ProfileCard(
                icon: const Icon(Icons.edit_document),
                name: 'Terms and Condition',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TermsandConditionsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Consumer<UserProvider>(builder: (context, userProvider, child) {
                return ProfileCard(
                  icon: const Icon(Icons.delete),
                  name: 'Delete Account',
                  onTap: () {
                    userProvider.deleteUser(context);
                  },
                );
              }),
              const SizedBox(height: 10),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return ProfileCard(
                    icon: const Icon(Icons.logout),
                    name: 'LogOut',
                    onTap: () {
                      userProvider.logOut(context);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
