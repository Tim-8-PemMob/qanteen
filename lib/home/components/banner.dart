import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * (10 / 375)),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                'https://img.freepik.com/free-photo/traditional-nasi-lemak-meal-composition_23-2149056831.jpg?w=740&t=st=1665115789~exp=1665116389~hmac=5f93b4ef7a6b26c999ca6a6106109ef58d7e843cb97a447d2dae6fc637e9a6e6'),
            fit: BoxFit.cover),
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).size.width * (5 / 375)),
                        width: 90,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.redAccent[400],
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Qanteen",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 10,
                                    offset: Offset(3, 3))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "DISKON 10%",
                    style: TextStyle(
                      color: Colors.redAccent[400],
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Text(
                      "Untuk semua Jenis Makanan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
