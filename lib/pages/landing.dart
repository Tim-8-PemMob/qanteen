import 'package:flutter/material.dart';
import 'package:qanteen/pages/index.dart';
import 'package:qanteen/pages/login.dart';
import 'package:qanteen/pages/signup.dart';
import 'package:qanteen/pages/slider.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  int _currentPage = 0;
  PageController _controller = PageController();

  List<Widget> _pages = [
    SliderPage(
        title: "Mudah",
        description: "Pesan makanan dengan menggunakan layanan otomatis",
        image: "assets/easy.png"),
    SliderPage(
        title: "Cepat",
        description: "Pesan makanan Anda tanpa perlu mengantri lama",
        image: "assets/fast.png"),
    SliderPage(
        title: "Hemat",
        description: "Dapatkan berbagai diskon untuk penggguna pertama",
        image: "assets/discount.jpg"),
  ];

  _onchanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: _onchanged,
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (context, int index) {
              return _pages[index];
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_pages.length, (int index) {
                    return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 10,
                        width: (index == _currentPage) ? 30 : 10,
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: (index == _currentPage)
                                ? Color(0xFFC21010)
                                : Color(0xFFC21010).withOpacity(0.5)));
                  })),
              InkWell(
                onTap: () {
                  _controller.nextPage(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeInOutQuint);
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  duration: Duration(milliseconds: 300),
                  height: 70,
                  width: (_currentPage == (_pages.length - 1)) ? 200 : 75,
                  decoration: BoxDecoration(
                      color: Color(0xFFC21010),
                      borderRadius: BorderRadius.circular(35)),
                  child: (_currentPage == (_pages.length - 1))
                      ? SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomePage()),
                              );
                            },
                            child: const Text('Start!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC21010),
                              shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.navigate_next,
                          size: 50,
                          color: Colors.white,
                        ),
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  Widget FlutterButton(
      {required String name,
      Color? color,
      Color? textColor,
      Color? backgroundColor,
      required BuildContext context,
      required Widget page}) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC21010),
        shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(80)),
        textStyle: TextStyle(fontSize: 20, color: color));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: style,
              onPressed: () {
                // temporary
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Index()), (Route<dynamic> route) => false);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => page));
              },
              child: Text(
                name,
                style: TextStyle(
                    color: textColor, backgroundColor: backgroundColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.4),
              child: Center(
                child: Image.asset(
                  'assets/food-stall.png',
                  height: 200,
                  width: 200,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Text(
                    "Selamat Datang di Qanteen",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC21010),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  ),
                  Column(
                    children: [
                      Text("Pesan Makanan anda"),
                      Text("Lebih cepat dan lebih mudah"),
                      Padding(padding: const EdgeInsets.only(bottom: 50)),
                    ],
                  ),
                  FlutterButton(
                    name: 'Login',
                    textColor: Colors.white,
                    context: context,
                    page: LoginPage(),
                  ),
                  FlutterButton(
                    name: 'SignUp',
                    textColor: Colors.white,
                    context: context,
                    page: SignUpPage(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
