import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_admin/style/textstyle.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: Style.text,
        ),
      ),
      body: StreamBuilder(
        stream: firestore.collection('order_details').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.data == null) {
            return Center(
              child: Text('No Data!!!', style: Style.text1),
            );
          }
          final orderData = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: ListView.separated(
              itemCount: orderData.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Text(orderData[index]['order_id'], style: Style.text3);
              },
            ),
          );
        },
      ),
    );
  }
}
