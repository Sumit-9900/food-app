import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_admin/pages/add_product_page.dart';
import 'package:food_admin/style/textstyle.dart';
import 'package:food_admin/widgets/mydrawer.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List of Products',
          style: Style.text,
        ),
      ),
      drawer: const MyDrawer(),
      body: SafeArea(
        child: StreamBuilder(
          stream: firestore.collection('product-details').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData || snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          snapshot.data!.docs[index]['productImage'],
                        ),
                      ),
                      title: Text(snapshot.data!.docs[index]['productName']),
                      subtitle: Text(
                        '\$${snapshot.data!.docs[index]['productPrice']}',
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          firestore
                              .collection('product-details')
                              .doc(snapshot.data!.docs[index].id)
                              .delete();
                          await storage
                              .refFromURL(
                                  snapshot.data!.docs[index]['productImage'])
                              .delete();
                          Fluttertoast.showToast(
                            msg: 'Product has been Deleted!!!',
                            backgroundColor: Colors.red,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                            fontSize: 16,
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'No Product Available!!!',
                    style: Style.text,
                  ),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
