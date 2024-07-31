import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/favorite_product_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/provider/user_provider.dart';
import 'package:food_client/screens/detail_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> imagePath = [
    'assets/images/ice-cream.png',
    'assets/images/pizza.png',
    'assets/images/salad.png',
    'assets/images/burger.png',
  ];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final provider1 = Provider.of<UserProvider>(context, listen: false);
    final provider2 =
        Provider.of<FavoriteProductProvider>(context, listen: false);
    provider2.getData();
    provider.init();
    provider1.getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 20.0,
          ),
          child: Consumer<ProductProvider>(
            builder: (context, value, child) {
              return Consumer<FavoriteProductProvider>(
                builder: (context, value1, child) {
                  return StreamBuilder(
                    stream: firestore.collection('product-details').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        value.addDetails(snapshot);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser!.uid)
                                  .collection('details')
                                  .doc(auth.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Hello Name,',
                                    style: Style.text1,
                                  );
                                } else {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        snapshot.data!.data() != null
                                            ? 'Hello ${snapshot.data!.data()!['username']},'
                                            : 'Hello Name,',
                                        style: Style.text1,
                                      ),
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(auth.currentUser!.uid)
                                            .collection('profileImage')
                                            .doc(auth.currentUser!.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: NetworkImage(
                                                'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                              ),
                                            );
                                          } else {
                                            final data = snapshot.data!.data();
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 12.0,
                                              ),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: NetworkImage(
                                                  data != null
                                                      ? data['userImage']
                                                      : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 30.0),
                            Text(
                              'Delicious Food',
                              style: Style.text,
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              'Discover and Get Great Food',
                              style: Style.text2,
                            ),
                            const SizedBox(height: 15.0),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imagePath.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        value.onTap(index);
                                      },
                                      child: Card(
                                        elevation: 2.0,
                                        child: Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: index == value.gotindex
                                                ? Colors.black
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Image.asset(
                                            imagePath[index],
                                            color: index == value.gotindex
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            SizedBox(
                              height: 230,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: value.updatedList.length,
                                itemBuilder: (context, index) {
                                  String id =
                                      value.updatedList[index]['productId'];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            id: id,
                                            name: value.updatedList[index]
                                                ['productName'],
                                            des: value.updatedList[index]
                                                ['productDetail'],
                                            price:
                                                '${value.updatedList[index]['productPrice']}',
                                            image: value.updatedList[index]
                                                ['productImage'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 2.0,
                                      child: Container(
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      value.updatedList[index]
                                                          ['productImage'],
                                                      fit: BoxFit.cover,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              6,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 2,
                                                    top: 2,
                                                    child: IconButton(
                                                      onPressed: () async {
                                                        value1
                                                            .addFavoriteProducts(
                                                                {
                                                              'id': id,
                                                              'name': value
                                                                          .updatedList[
                                                                      index][
                                                                  'productName'],
                                                              'des': value.updatedList[
                                                                      index][
                                                                  'productDetail'],
                                                              'price':
                                                                  '${value.updatedList[index]['productPrice']}',
                                                              'image': value
                                                                          .updatedList[
                                                                      index][
                                                                  'productImage'],
                                                            },
                                                                id);
                                                      },
                                                      icon: value1.docIds
                                                              .contains(id)
                                                          ? const Icon(
                                                              Icons.favorite)
                                                          : const Icon(Icons
                                                              .favorite_outline),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                value.updatedList[index]
                                                    ['productName'],
                                                style: Style.text8,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                value.updatedList[index]
                                                    ['productDetail'],
                                                style: Style.text2,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '\$${value.updatedList[index]['productPrice']}',
                                                style: Style.text8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            value.updatedList.isEmpty
                                ? Center(
                                    child: Text(
                                      'No Items are\n present!!!',
                                      style: Style.text,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      itemCount: value.updatedList.length,
                                      itemBuilder: (context, index) {
                                        String id = value.updatedList[index]
                                            ['productId'];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailScreen(
                                                  id: id,
                                                  name: value.updatedList[index]
                                                      ['productName'],
                                                  des: value.updatedList[index]
                                                      ['productDetail'],
                                                  price:
                                                      '\$${value.updatedList[index]['productPrice']}',
                                                  image:
                                                      value.updatedList[index]
                                                          ['productImage'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 2.0,
                                            child: Container(
                                              height: 150,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
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
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      value.updatedList[index]
                                                          ['productImage'],
                                                      fit: BoxFit.cover,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.2,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
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
                                                                value.updatedList[
                                                                        index][
                                                                    'productName'],
                                                                style:
                                                                    Style.text8,
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
                                                                value.updatedList[
                                                                        index][
                                                                    'productDetail'],
                                                                style:
                                                                    Style.text2,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              '\$${value.updatedList[index]['productPrice']}',
                                                              style:
                                                                  Style.text8,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 1,
                                                        top: 10,
                                                        child: IconButton(
                                                          onPressed: () async {
                                                            value1
                                                                .addFavoriteProducts(
                                                                    {
                                                                  'id': id,
                                                                  'name': value
                                                                              .updatedList[
                                                                          index]
                                                                      [
                                                                      'productName'],
                                                                  'des': value.updatedList[
                                                                          index]
                                                                      [
                                                                      'productDetail'],
                                                                  'price':
                                                                      '${value.updatedList[index]['productPrice']}',
                                                                  'image': value
                                                                              .updatedList[
                                                                          index]
                                                                      [
                                                                      'productImage'],
                                                                },
                                                                    id);
                                                          },
                                                          icon: value1.docIds
                                                                  .contains(id)
                                                              ? const Icon(Icons
                                                                  .favorite)
                                                              : const Icon(Icons
                                                                  .favorite_outline),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                          ],
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
