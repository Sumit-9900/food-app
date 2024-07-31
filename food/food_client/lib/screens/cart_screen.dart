import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/provider/stripe_provider.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? usr = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    final provider1 = Provider.of<CartProvider>(context, listen: false);
    provider1.getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(usr!.uid)
            .collection('cartproducts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == null) {
            return const Center(
              child: Text('Cart is empty'),
            );
          } else {
            List docs = snapshot.data!.docs;
            return Container(
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
                            'Food Cart',
                            style: Style.text,
                          ),
                        ),
                      ),
                    ),
                    docs.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Text(
                                'Cart is Empty!!!',
                                style: Style.text1,
                              ),
                            ),
                          )
                        : Expanded(
                            child: Consumer<ProductProvider>(
                              builder: (context, value, child) {
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final id = docs[index]['id'];
                                    return Card(
                                      elevation: 2.0,
                                      child: Container(
                                        height: 130,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25.0,
                                            vertical: 15.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    docs[index]['count']
                                                        .toString(),
                                                    style: Style.text4,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15.0),
                                              Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.network(
                                                    docs[index]['image'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15.0),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 118,
                                                    child: Text(
                                                      docs[index]['name'],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Style.text4,
                                                    ),
                                                  ),
                                                  Consumer<CartProvider>(
                                                    builder: (context, value,
                                                        child) {
                                                      return Row(
                                                        children: [
                                                          Text(
                                                            '\$${docs[index]['price']}',
                                                            style: Style.text4,
                                                          ),
                                                          IconButton(
                                                            color: Colors.red,
                                                            onPressed:
                                                                () async {
                                                              value
                                                                  .deleteProductFromCart(
                                                                      id);
                                                            },
                                                            icon: const Icon(
                                                                Icons.delete),
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
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                    Consumer<CartProvider>(
                      builder: (context, value, child) {
                        return Material(
                          elevation: 2.0,
                          child: Container(
                            height: 140,
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 15.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Price',
                                      style: Style.text10,
                                    ),
                                    Text(
                                      '\$${value.total}',
                                      style: Style.text10,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Consumer<StripeProvider>(
                                  builder: (context, value1, child) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await value1.displayPaymentSheet(
                                            value.total.toInt());
                                      },
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Pay Now',
                                            style: Style.text3,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
