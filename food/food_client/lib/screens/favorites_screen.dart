import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/favorite_product_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/screens/detail_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  User? usr = FirebaseAuth.instance.currentUser;
  bool tapped = false;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    Provider.of<FavoriteProductProvider>(context, listen: false).getData();
    provider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 50.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Material(
                elevation: 2.0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Text(
                      'Food Favorites',
                      style: Style.text,
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(usr!.uid)
                    .collection('favoriteproducts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data == null) {
                    return const Center(
                      child: Text('No Favorites added!!!'),
                    );
                  } else {
                    return Expanded(
                      child: Consumer<FavoriteProductProvider>(
                        builder: (context, value, child) {
                          List docs = snapshot.data!.docs;
                          return docs.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Favorites added!!!',
                                    style: Style.text10,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    String id = docs[index]['id'];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(
                                              id: id,
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  docs[index]['image'],
                                                  fit: BoxFit.cover,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.2,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                ),
                                              ),
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5.0,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 23,
                                                          width: 170,
                                                          child: Text(
                                                            docs[index]['name'],
                                                            style: Style.text8,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Text(
                                                          '\$${docs[index]['price']}',
                                                          style: Style.text8,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Consumer<ProductProvider>(
                                                    builder: (context, value1,
                                                        child) {
                                                      return Positioned(
                                                        right: 1,
                                                        top: 10,
                                                        child: IconButton(
                                                          onPressed: () async {
                                                            value
                                                                .addFavoriteProducts(
                                                                    {
                                                                  'id': id,
                                                                  'name': docs[
                                                                          index]
                                                                      ['name'],
                                                                  'des': docs[
                                                                          index]
                                                                      ['des'],
                                                                  'price':
                                                                      '\$${docs[index]['price']}',
                                                                  'image': docs[
                                                                          index]
                                                                      ['image'],
                                                                },
                                                                    id);
                                                          },
                                                          icon: value.docIds
                                                                  .contains(id)
                                                              ? const Icon(
                                                                  Icons
                                                                      .favorite,
                                                                )
                                                              : const Icon(Icons
                                                                  .favorite_outline),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
