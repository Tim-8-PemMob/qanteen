import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'banner.dart';
import 'categories_container.dart';
import 'home_header.dart';
import 'icon_btn_with_counter.dart';
import 'search_field.dart';
import 'stand_container.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * (1 / 375),
            ),
            HomeHeader(),
            HomeBanner(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * (15 / 375)),
              child: Row(
                children: [
                  categoriesContainer(
                    image: "assets/restaurant.png",
                    name: "All",
                  ),
                  categoriesContainer(
                    image: "assets/restaurant.png",
                    name: "Stand 1",
                  ),
                  categoriesContainer(
                    image: "assets/restaurant.png",
                    name: "Stand 2",
                  ),
                  categoriesContainer(
                    image: "assets/restaurant.png",
                    name: "Stand 3",
                  ),
                  categoriesContainer(
                    image: "assets/restaurant.png",
                    name: "Stand 4",
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * (10 / 375)),
              // height: 500,
              child: GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  StandContainer(
                    image: "assets/stand1.png",
                    namaStand: "Tomato",
                    nmrStand: "Stand 1",
                  ),
                  StandContainer(
                    image: "assets/stand2.png",
                    namaStand: "Brokoli",
                    nmrStand: "Stand 2",
                  ),
                  StandContainer(
                    image: "assets/stand3.png",
                    namaStand: "Pepaya",
                    nmrStand: "Stand 3",
                  ),
                  StandContainer(
                    image: "assets/stand4.png",
                    namaStand: "Mangga",
                    nmrStand: "Stand 4",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
