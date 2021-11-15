import 'dart:async';
import 'dart:io';
import 'package:assignment/utils/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
  }
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  int? isSignedIn(){

  }

  startTime() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // int x = 0;
        // FirebaseAuth.instance
        //     .userChanges()
        //     .listen((User? user) {
        //   if (user == null) {
        //     print('User is currently signed out!');
        //     x = 0;
        //   } else {
        //     print('User is signed in!');
        //     x = 1;
        //   }
        // });
        String? token = localStorage.getString(MySharedPreference.token);

        if (token != null){
          var _duration = const Duration(seconds: 2);
          return Timer(_duration, navigationToHomePage);
        } else {
          var _duration = const Duration(seconds: 2);
          return Timer(_duration, navigationPage);
        }
      }else{
        var _duration = const Duration(seconds: 2);
        return Timer(_duration, noInternetPage);
      }
    } on SocketException catch (_) {
      print('not connected');
      var _duration = const Duration(seconds: 2);
      return Timer(_duration, noInternetPage);
    }

  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void navigationToHomePage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  void noInternetPage() {
    Navigator.of(context).pushReplacementNamed('/NoInternetPage');
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF87537),
        statusBarIconBrightness: Brightness.light));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    startTime();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.lightBlueAccent,
      body: SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  final Shader linearGradient = LinearGradient(
    // colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
    colors: <Color>[const Color(0xFF000000), const Color(0xFF000000).withOpacity(0.6)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  SplashView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            flex: 1,
            child: Center(
              child: SvgPicture.asset('images/egg.svg',height: 200,width: 150,),
            )
        ),
      ],
    );
  }
}

