import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_admin/provider/details_provider.dart';
import 'package:food_admin/style/textstyle.dart';
import 'package:food_admin/widgets/dropdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  @override
  void dispose() {
    namecontroller.dispose();
    pricecontroller.dispose();
    detailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Item',
          style: Style.text,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<DetailsProvider>(
              builder: (context, detailsProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload the Item Picture',
                      style: Style.text1,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          detailsProvider.pickImage();
                        },
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black),
                            ),
                            child: detailsProvider.selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      detailsProvider.selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Item Name',
                      style: Style.text1,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: namecontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Item Name',
                          hintStyle: Style.text2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Item Price',
                      style: Style.text1,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: pricecontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          border: InputBorder.none,
                          hintText: 'Enter Item Price',
                          hintStyle: Style.text2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Item Detail',
                      style: Style.text1,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        maxLines: 6,
                        controller: detailcontroller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Item Detail',
                          hintStyle: Style.text2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Category',
                      style: Style.text1,
                    ),
                    DropDown(
                      category: detailsProvider.category,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        final name = namecontroller.text.trim();
                        final price = pricecontroller.text.trim();
                        final detail = detailcontroller.text.trim();
                        if (detailsProvider.selectedImage == null ||
                            name.isEmpty ||
                            price.isEmpty ||
                            detail.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Please enter all the details!!!',
                            backgroundColor: Colors.red,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                            fontSize: 16,
                          );
                        } else {
                          detailsProvider.sendData(name, price, detail);

                          Navigator.of(context).pop();
                          
                          Fluttertoast.showToast(
                            msg: 'Product has been added successfully!!!',
                            backgroundColor: Colors.green,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                            fontSize: 16,
                          );
                        }
                        namecontroller.clear();
                        pricecontroller.clear();
                        detailcontroller.clear();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: detailsProvider.isLoading == true
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  'Add Item',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
