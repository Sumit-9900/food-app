import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_client/provider/cart_provider.dart';
import 'package:food_client/provider/favorite_product_provider.dart';
import 'package:food_client/provider/product_provider.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.name,
    required this.des,
    required this.price,
    required this.image,
    required this.id,
  });

  final String id;
  final String name;
  final String des;
  final String price;
  final String image;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          Consumer<FavoriteProductProvider>(
            builder: (context, value, child) {
              return IconButton(
                onPressed: () async {
                  value.addFavoriteProducts(
                    {
                      'id': widget.id,
                      'name': widget.name,
                      'des': widget.des,
                      'price': '\$${widget.price}',
                      'image': widget.image,
                    },
                    widget.id,
                  );
                },
                icon: value.docIds.contains(widget.id)
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_outline),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Consumer<ProductProvider>(
          builder: (context, value, child) {
            return Consumer<CartProvider>(
              builder: (context, value1, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height / 2.3,
                        width: MediaQuery.of(context).size.width,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          SizedBox(
                            width: 250,
                            height: 67,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.name,
                                style: Style.text10,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              value.decrement();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.minus,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: Text(
                                value.count.toString(),
                                style: Style.text1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              value.increment();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: SizedBox(
                          height: 160,
                          child: Text(
                            widget.des,
                            style: Style.text2,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Text(
                              'Delivery Time',
                              style: Style.text10,
                            ),
                            const SizedBox(width: 30),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.clock),
                                const SizedBox(width: 5.0),
                                Text(
                                  '30min',
                                  style: Style.text4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Price',
                                  style: Style.text10,
                                ),
                                Text(
                                  '\$${widget.price}',
                                  style: Style.text10,
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                value1.addProductToCart(
                                  {
                                    'count': value.count,
                                    'des': widget.des,
                                    'id': widget.id,
                                    'image': widget.image,
                                    'name': widget.name,
                                    'price': widget.price,
                                  },
                                  widget.id,
                                );
                              },
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width / 1.8,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Add to Cart',
                                      style: Style.text7,
                                    ),
                                    const Icon(
                                      CupertinoIcons.cart,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
