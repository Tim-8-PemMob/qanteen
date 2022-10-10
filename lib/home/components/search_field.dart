import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class searchField extends StatelessWidget {
  const searchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6, //60% of the width
      height: 50,
      decoration: BoxDecoration(
        color: kCupertinoModalBarrierColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onChanged: (value) {
          // search value
        },
        decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: "Cari Makanan/ Stan...",
            prefixIcon: Icon(Icons.search)),
        scrollPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (20 / 375),
          vertical: MediaQuery.of(context).size.width * (9 / 375),
        ),
      ),
    );
  }
}
