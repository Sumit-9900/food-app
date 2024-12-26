import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/favorite_product_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/screens/detail_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().init();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    List<String> imagePath = [
      'assets/images/ice-cream.png',
      'assets/images/pizza.png',
      'assets/images/salad.png',
      'assets/images/burger.png',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 20.0,
          ),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return StreamBuilder(
                stream: firestore.collection('product-details').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (snapshot.data == null) {
                    return const Center(
                      child: Text('Data is null!!!'),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Some unexpected error occurred!!!'),
                    );
                  }
                  productProvider.addDetails(snapshot);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heading(firestore, auth),
                      const SizedBox(height: 20.0),
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
                      _category(imagePath, productProvider),
                      const SizedBox(height: 25.0),
                      _horizontallistView(productProvider),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _horizontallistView(ProductProvider provider) {
    return provider.updatedList.isEmpty
        ? Center(
            child: Text(
              'No Items are\n present!!!',
              style: Style.text,
              textAlign: TextAlign.center,
            ),
          )
        : Expanded(
            child: ListView.builder(
              itemCount: provider.updatedList.length,
              itemBuilder: (context, index) {
                final product = provider.updatedList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => DetailScreen(
                          id: product['productId'],
                          name: product['productName'],
                          des: product['productDetail'],
                          price: product['productPrice'],
                          image: product['productImage'],
                        ),
                      ),
                    );
                  },
                  child: _foodCard(provider, index, context),
                );
              },
            ),
          );
  }

  Widget _foodCard(ProductProvider provider, int index, BuildContext context) {
    final product = provider.updatedList[index];

    return Card(
      elevation: 2.0,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: product['productImage'],
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height / 6,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Consumer<FavoriteProductProvider>(
                      builder: (context, favoriteProvider, child) {
                        return IconButton(
                          onPressed: () async {
                            favoriteProvider.addFavoriteProducts({
                              'id': product['productId'],
                              'name': product['productName'],
                              'des': product['productDetail'],
                              'price': product['productPrice'],
                              'image': product['productImage'],
                            }, product['productId']);
                          },
                          icon: favoriteProvider.docIds
                                  .contains(product['productId'])
                              ? const Icon(Icons.favorite)
                              : const Icon(Icons.favorite_outline),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Text(
                product['productName'],
                style: Style.text8,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product['productDetail'],
                style: Style.text2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '\$${product['productPrice']}',
                style: Style.text8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _category(List<String> imagePath, ProductProvider provider) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePath.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: GestureDetector(
              onTap: () {
                provider.onTap(index);
              },
              child: Card(
                elevation: 2.0,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: index == provider.gotindex
                        ? Colors.black
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath[index],
                    color: index == provider.gotindex
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heading(FirebaseFirestore firestore, FirebaseAuth auth) {
    return StreamBuilder(
      stream: auth.currentUser == null
          ? null
          : firestore
              .collection('user_details')
              .doc(auth.currentUser!.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Container();
        } else if (!snapshot.hasData || snapshot.data == null) {
          debugPrint('No Data!!!');
          return Container();
        }

        final data = snapshot.data!.data();

        if (data == null) {
          return Container();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Hello ${data['username'] ?? 'Name'},', style: Style.text1),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(
                data['userImage'] != ''
                    ? data['userImage']
                    : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
              ),
            ),
          ],
        );
      },
    );
  }
}
