import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/provider/stripe_provider.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:food_client/widgets/app_bar.dart';
import 'package:food_client/widgets/cardd.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  String orderId = '';

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 50.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: StreamBuilder(
            stream: firestore
                .collection('products')
                .doc(user!.uid)
                .collection('cart_products')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == null) {
                return Center(
                  child: Text('No Data!!!', style: Style.text1),
                );
              }
              List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
              return Column(
                children: [
                  const Appbar(title: 'Food Cart'),
                  _cartCard(docs),
                  _cartTotal(context, docs),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _cartCard(List<QueryDocumentSnapshot> docs) {
    return Expanded(
      child: docs.isEmpty
          ? Center(
              child: Text('Your cart is empty!!!', style: Style.text1),
            )
          : ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                return Cardd(index: index, docs: docs);
              },
            ),
    );
  }

  Widget _cartTotal(BuildContext context, List<QueryDocumentSnapshot> docs) {
    return Material(
      elevation: 2.0,
      child: Container(
        height: 140,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 15.0,
        ),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: Style.text10,
                    ),
                    Text(
                      '\$${cartProvider.total.round()}',
                      style: Style.text10,
                    )
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Consumer<StripeProvider>(
                  builder: (context, stripeProvider, child) {
                    return GestureDetector(
                      onTap: () async {
                        await stripeProvider
                            .displayPaymentSheet(cartProvider.total.toInt());
                        if (stripeProvider.data == null && context.mounted) {
                          showOrderSuccessDialog(context);
                          cartProvider.storeOrdersToFirestore({
                            'order_id': orderId,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
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
            );
          },
        ),
      ),
    );
  }

  void showOrderSuccessDialog(BuildContext context) {
    orderId = generateOrderId();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Order Placed Successfully',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'with Order ID $orderId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String generateOrderId() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();

    // Generate a random 6-character alphanumeric string
    String randomString =
        List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    // Get the current timestamp in milliseconds since epoch
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Combine timestamp and random string for a unique order ID
    return 'ORD-$timestamp-$randomString';
  }
}
