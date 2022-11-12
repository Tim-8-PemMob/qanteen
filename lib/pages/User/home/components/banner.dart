import 'package:carousel_slider/carousel_slider.dart';
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
      child: CarouselSlider(
        options: CarouselOptions(
            height: double.maxFinite,
            viewportFraction: 0.95,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut),
        items: [
          "assets/carousel_slider/gbr4.jpg",
          "assets/carousel_slider/gbr5.jpg",
          "assets/carousel_slider/gbr3.jpg"
        ].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                    color: Colors.amber,
                    image:
                        DecorationImage(image: AssetImage(i), fit: BoxFit.fill),
                    borderRadius: BorderRadius.circular(10)),
                //
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
