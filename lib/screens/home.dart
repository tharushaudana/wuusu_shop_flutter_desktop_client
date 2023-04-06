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
  bool isSideMenuHovered = false;

  final List sideMenuItems = [
    ["Inventory", Icons.house, false],
    ["Stock", Icons.list, false],
    ["Reports", Icons.document_scanner, false],
    ["Make", Icons.create, false],
    ["Users", Icons.group, false]
  ];

  test() async {
    try {
      Map? data =
          await widget.apiCall.get("/products").param("page", "2").call();
      print(data);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      body: Container(
          child: Row(
        children: [
          MouseRegion(
            onHover: (event) {
              setState(() {
                isSideMenuHovered = true;
              });
            },
            onExit: (event) {
              setState(() {
                isSideMenuHovered = false;
              });
            },
            child: Container(
              color: Colors.grey.withAlpha(100),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_3_outlined,
                        size: 50,
                      ),
                      isSideMenuHovered
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tharusha Udana",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "ID: 01",
                                  style: TextStyle(fontSize: 10),
                                )
                              ],
                            )
                          : Container()
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  for (int i = 0; i < sideMenuItems.length; i++)
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(40)),
                      child: Row(children: [
                        Icon(sideMenuItems[i][1]),
                        isSideMenuHovered
                            ? Text(sideMenuItems[i][0])
                            : Container()
                      ]),
                    )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
