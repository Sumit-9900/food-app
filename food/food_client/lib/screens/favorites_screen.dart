import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/screens/detail_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:food_client/widgets/app_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 50.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const Appbar(title: 'Food Favorites'),
              StreamBuilder(
                stream: currentUser == null
                    ? null
                    : firestore
                        .collection('products')
                        .doc(currentUser.uid)
                        .collection('favorite_products')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data == null) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Center(
                        child: Text('No Data!!!', style: Style.text1),
                      ),
                    );
                  }
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  return _favoriteCard(docs);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _favoriteCard(List<QueryDocumentSnapshot<Object?>> docs) {
    return Expanded(
      child: docs.isEmpty
          ? Center(
              child: Text('No Favorites added!!!', style: Style.text1),
            )
          : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return _card(context, index, docs);
              },
            ),
    );
  }

  Widget _card(
      BuildContext context, int index, List<QueryDocumentSnapshot> docs) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              id: docs[index]['id'],
              name: docs[index]['name'],
              des: docs[index]['des'],
              price: '${docs[index]['price']}',
              image: docs[index]['image'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  docs[index]['image'],
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width / 2.2,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 5.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 23,
                          width: 170,
                          child: Text(
                            docs[index]['name'],
                            style: Style.text8,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 60,
                          width: 170,
                          child: Text(
                            docs[index]['des'],
                            style: Style.text2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '\$${docs[index]['price']}',
                          style: Style.text8,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
