import 'package:flutter/material.dart';
import 'package:food_admin/provider/details_provider.dart';
import 'package:provider/provider.dart';

class DropDown extends StatefulWidget {
  const DropDown({
    super.key,
    required this.category,
  });

  final List<String> category;

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFececf8),
        ),
      ),
      child: Consumer<DetailsProvider>(
        builder: (context, detailsProvider, child) {
          return DropdownButton(
            underline: const Text(''),
            isExpanded: true,
            value: detailsProvider.selectedItem,
            hint: const Text('Select Category'),
            dropdownColor: const Color(0xFFececf8),
            items: widget.category.map<DropdownMenuItem<String>>(
              (String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              },
            ).toList(),
            onChanged: (String? item) {
              detailsProvider.dropdown(item);
            },
          );
        },
      ),
    );
  }
}
