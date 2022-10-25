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
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(image),
                ),
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red[700]),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    print("add recommendation to cart");
                  },
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 3),
        //   child: Text(
        //     textAlign: TextAlign.center,
        //     name,
        //     style: TextStyle(
        //       fontSize: 20,
        //       color: Colors.black,

        //     ),
        //   ),
        // )
      ],
    );
  }
}
