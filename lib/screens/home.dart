import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';

class HomeScreen extends StatefulWidget {
  final ApiCall apiCall;
  final Map user;

  HomeScreen({required this.apiCall, required this.user});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  test() {}

  @override
  Widget build(Object context) {
    return Scaffold(
      body: Container(
        child: TextButton(
            onPressed: () {
              test();
            },
            child: Text("test")),
      ),
    );
  }
}
