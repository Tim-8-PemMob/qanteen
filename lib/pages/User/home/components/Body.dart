import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/model/stand_model.dart';
import 'package:qanteen/pages/User/home/components/SizeConfig.dart';
import 'banner.dart';
import 'categories_container.dart';
import 'home_header.dart';
import 'stand_container.dart';

Future<List<StandModel>> getStandFireStore() async {
  var listStand = List<StandModel>.empty(growable: true);
  await FirebaseFirestore.instance.collection("Stands").get().then((data) {
    for (var doc in data.docs) {
      StandModel standModel = StandModel(
          id: doc.id.toString(),
          name: doc.data()["name"],
          image: doc.data()['image']);
      listStand.add(standModel);
    }
  });
  return listStand;
}

class Body extends StatefulWidget {
  _Body createState() => _Body();
}

class _Body extends State<Body> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * (1 / 375),
            ),
            HomeHeader(),
            HomeBanner(),
            SizedBox(
              height: getProportionateScreenWidth(10),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(15),
              ),
              child: Row(
                children: [
                  Text(
                    "Rekomendasi Menu",
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * (15 / 375)),
              child: Row(
                children: [
                  categoriesContainer(
                    image: "assets/geprek.jpg",
                    name: "Ayam Geprek",
                  ),
                  categoriesContainer(
                    image: "assets/geprek.jpg",
                    name: "Nasi Goreng",
                  ),
                  categoriesContainer(
                    image: "assets/geprek.jpg",
                    name: "Nasi Hangus",
                  ),
                  categoriesContainer(
                    image: "assets/geprek.jpg",
                    name: "Stand 3",
                  ),
                  categoriesContainer(
                    image: "assets/geprek.jpg",
                    name: "Stand 4",
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(15),
              ),
              child: Row(
                children: [
                  Text(
                    "Pilih Stand",
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: getProportionateScreenWidth(10),
            ),
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (10 / 375)),
                // height: 500,
                child: FutureBuilder(
                  future: getStandFireStore(),
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else if (data != null && data.isNotEmpty) {
                      // reference();
                      // addMenu();
                      return GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 230,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return StandContainer(
                            image: data[index].image,
                            namaStand: data[index].name,
                            nmrStand: index.toString(),
                            standId: data[index].id,
                          );
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("Stands Makanan Kosong"));
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }
}
