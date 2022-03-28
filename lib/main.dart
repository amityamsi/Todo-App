import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp=Firebase.initializeApp();


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  late AnimationController _controller;
  late AnimationController _expanses_controller;

  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _expanses_controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _expanses_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Stack(children: [
            Lottie.asset('assests/books.json',
                controller: _controller,
                reverse: true,
                fit: BoxFit.fill,
                repeat: true,
                // alignment: Alignment.topCenter,

                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward().whenComplete(() => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => HomePage())));
                }),
          ]),
        ));
  }
}

