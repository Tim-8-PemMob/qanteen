import 'package:flutter/material.dart';

class StandContainer extends StatelessWidget {
  const StandContainer({
    Key? key,
    required this.image,
    required this.namaStand,
    required this.nmrStand,
  }) : super(key: key);

  final String image;
  final String nmrStand;
  final String namaStand;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.redAccent[400],
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(image),
              backgroundColor: Color.fromARGB(139, 255, 255, 255),
            ),
          ),
          ListTile(
            leading: Text(
              nmrStand,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            trailing: Text(
              namaStand,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
