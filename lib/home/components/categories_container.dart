import 'package:flutter/material.dart';

class categoriesContainer extends StatelessWidget {
  const categoriesContainer({
    Key? key,
    required this.image,
    required this.name,
  }) : super(key: key);

  final String image;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 20),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
            ),
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
