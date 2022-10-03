import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  @override
  _Cart createState() => _Cart();
}

class _Cart extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart"),),
      body: Center(
        child: Text("Cart"),
      ),
    );
  }
}
