import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/screens/home.dart';
import 'package:wuusu_shop_client/storage.dart';
//import 'package:window_utils/window_utils.dart';
import './screens/login.dart';
import 'apicall.dart';

void main() {
  //WindowUtils.setSize(Size(400, 300));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ApiCall apiCall = ApiCall();
  Storage storage = Storage();

  Future<bool> checkIsLogged() async {
    String? s = await storage.read("token");
    if (s != null) return true;
    return false;
  }

  @override
  Widget build(BuildContext bcontext) {
    return SizedBox(
      width: 400,
      height: 300,
      child: Scaffold(
          body: FutureBuilder(
        future: checkIsLogged(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            bool? logged = snapshot.data;

            if (logged == true) {
              return HomeScreen(
                apiCall: apiCall,
                user: {},
              );
            } else {
              return LoginScreen();
            }
          }
        },
      )),
    );
  }
}
