import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/searchResult.dart';

class searchField extends StatelessWidget {
  const searchField({
    Key? key,
  }) : super(key: key);

  String capitalizeAllWord(String value) {
    // TODO: Test untuk huruf pertama atau setelah spasi harus besar dan huruf lainnya harus kecil
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i].toLowerCase();
      }
    }
    return result;
  }

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
        onSubmitted: (value) async {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(context, MaterialPageRoute(builder: (builder) => SearchResult(search: capitalizeAllWord(value))));
        },
        decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: "Cari Makanan",
            prefixIcon: Icon(Icons.search)),
        scrollPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (20 / 375),
          vertical: MediaQuery.of(context).size.width * (9 / 375),
        ),
      ),
    );
  }
}
