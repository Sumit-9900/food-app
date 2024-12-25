import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/screens/detail_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';

class Cardd extends StatelessWidget {
  final int index;
  final List<QueryDocumentSnapshot> docs;
  const Cardd({super.key, required this.index, required this.docs});

  @override
  Widget build(BuildContext context) {
    final doc = docs[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => DetailScreen(
              name: doc['name'],
              des: doc['des'],
              price: doc['price'],
              image: doc['image'],
              id: doc['id'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        child: Container(
          height: 130,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 15.0,
            ),
            child: Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      doc['count'].toString(),
                      style: Style.text4,
                    ),
                  ),
                ),
                const SizedBox(width: 15.0),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: doc['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 118,
                      child: Text(
                        doc['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Style.text4,
                      ),
                    ),
                    Consumer<CartProvider>(
                      builder: (context, value, child) {
                        final id = doc['id'];

                        return Row(
                          children: [
                            Text(
                              '\$${doc['price']}',
                              style: Style.text4,
                            ),
                            IconButton(
                              color: Colors.red,
                              onPressed: () async {
                                await value.deleteProductFromCart(id);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
