import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/model/stand_model.dart';
import 'package:qanteen/pages/User/home/components/SizeConfig.dart';
import 'banner.dart';
import 'categories_container.dart';
import 'home_header.dart';
import 'stand_container.dart';

class Body extends StatefulWidget {
  _Body createState() => _Body();
}

class _Body extends State<Body> {
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

  Future<List<dynamic>> maxRandomMenuPerStands(int randomGet) async {
    List listMenuRandom = [];
    var key = FirebaseFirestore.instance.collection("Menus").doc().id;
    while (listMenuRandom.isEmpty) {
      await FirebaseFirestore.instance
          .collection("Stands")
          .get()
          .then((res) async {
        for (var data in res.docs) {
          await FirebaseFirestore.instance
              .collection("Stands")
              .doc(data.id)
              .collection("Menus")
              .where(FieldPath.documentId, isGreaterThanOrEqualTo: key)
              .limit(randomGet)
              .get()
              .then((value) {
            for (var menu in value.docs) {
              Map menuMap = new Map();
              menuMap['standId'] = data.id;
              menuMap['menuId'] = menu.id;
              menuMap['standName'] = data.data()['name'];
              menuMap['menuTotal'] = menu.data()['total'];
              menuMap['menuImg'] = menu.data()['image'];
              menuMap['menuName'] = menu.data()['name'];
              menuMap['menuPrice'] = menu.data()['price'];
              listMenuRandom.add(menuMap);
            }
          });
        }
      });
    }
    return listMenuRandom;
  }

  String capitalizeAllWord(String value) {
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }

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
            FutureBuilder(
              future: maxRandomMenuPerStands(2),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Text("..."),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Row(children: [
                    Expanded(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height / 6,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.width *
                                      (15 / 375)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return categoriesContainer(
                                    image: snapshot.data![index]['menuImg'],
                                    name:
                                        "${snapshot.data![index]['menuName']}",
                                    standId: snapshot.data![index]['standId'],
                                    menuId: snapshot.data![index]['menuId'],
                                    standName: snapshot.data![index]
                                        ['standName'],
                                  );
                                },
                              ),
                            ))),
                  ]);
                } else {
                  return const Center(
                    child: Text("Terjadi Error"),
                  );
                }
              },
            ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   padding: EdgeInsets.symmetric(
            //       vertical: MediaQuery.of(context).size.width * (15 / 375)),
            //   child:
            // ),
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
                      return GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 260,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return StandContainer(
                            image: data[index].image,
                            namaStand: capitalizeAllWord(data[index].name),
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
