import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/menu.dart';

class StandContainer extends StatelessWidget {
  const StandContainer({
    Key? key,
    required this.image,
    required this.namaStand,
    required this.nmrStand,
    required this.standId,
  }) : super(key: key);

  final String image;
  final String nmrStand;
  final String namaStand;
  final String standId;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 270,
        width: 200,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(104, 82, 82, 82),
              offset: const Offset(
                5.0,
                5.0,
              ),
              blurRadius: 10.0,
              spreadRadius: 3.0,
            ), //BoxShadow
            BoxShadow(
              color: Colors.white,
              offset: const Offset(0.0, 0.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Menu(standId: standId)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      namaStand,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.heart),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(CupertinoIcons.cart),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
