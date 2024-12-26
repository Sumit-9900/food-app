import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/provider/stripe_provider.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:food_client/widgets/app_bar.dart';
import 'package:food_client/widgets/cardd.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

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
              const Appbar(title: 'Food Cart'),
              StreamBuilder(
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
                  return _cartCard(docs);
                },
              ),
              _cartTotal(context)
            ],
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

  Widget _cartTotal(BuildContext context) {
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
}
