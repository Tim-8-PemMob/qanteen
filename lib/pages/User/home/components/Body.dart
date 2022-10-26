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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * (15 / 375)),
              child: Row(
                children: [
                  categoriesContainer(
                    image:
                        "https://assets.grab.com/wp-content/uploads/sites/9/2019/04/19001459/iamgeprek-blog-card.jpg",
                    name: "Ayam Geprek",
                  ),
                  categoriesContainer(
                    image:
                        "https://asset-a.grid.id/crop/0x0:0x0/700x465/photo/2019/08/07/1325166108.jpg",
                    name: "Nasi Goreng",
                  ),
                  categoriesContainer(
                    image:
                        "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80",
                    name: "Nasi Hangus",
                  ),
                  categoriesContainer(
                    image:
                        "https://cdns.klimg.com/merdeka.com/i/w/news/2021/09/08/1350400/670x335/resep-nasi-goreng-kampung-yang-enak-ala-rumahan-mudah-dibuat-rev-1.jpg",
                    name: "Stand 3",
                  ),
                  categoriesContainer(
                    image:
                        "https://images.unsplash.com/photo-1581184953963-d15972933db1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=665&q=80",
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
