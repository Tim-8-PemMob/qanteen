import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconBtnWithCounter extends StatelessWidget {
  IconBtnWithCounter({
    Key? key,
    required this.iconSrc,
    this.numOfItems,
    required this.press,
  }) : super(key: key);

  final IconData iconSrc;
  int? numOfItems;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: BorderRadius.circular(50),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding:
                EdgeInsets.all(MediaQuery.of(context).size.width * (10 / 375)),
            height: MediaQuery.of(context).size.width * (46 / 375),
            width: MediaQuery.of(context).size.width * (46 / 375),
            decoration: BoxDecoration(
              color: kCupertinoModalBarrierColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              child: Icon(
                iconSrc,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: -3,
            child: Container(
              height: MediaQuery.of(context).size.width * (12 / 375),
              width: MediaQuery.of(context).size.width * (12 / 375),
              decoration: BoxDecoration(
                color: Color(0xFFFF4848),
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: Colors.white),
              ),
              child: Center(
                child: Text(
                  "$numOfItems",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * (10 / 375),
                      height: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}