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
  final List sideMenuItems = [
    ["Inventory", Icons.house],
    ["Stock", Icons.list],
    ["Reports", Icons.document_scanner],
    ["Make", Icons.create],
    ["Users", Icons.group]
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenu(
              user: {'name': 'Tharusha Udana', 'id': '01'},
              sideMenuItems: sideMenuItems,
              onItemClick: (int i) {
                print(i);
              },
              onLogoutClick: () {
                test();
              }),
          Text("hello")
        ],
      )),
    );
  }
}

class SideMenu extends StatefulWidget {
  final Map user;
  final List sideMenuItems;
  final onItemClick;
  final onLogoutClick;

  SideMenu(
      {required this.user,
      required this.sideMenuItems,
      required this.onItemClick,
      required this.onLogoutClick});

  @override
  State<StatefulWidget> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool isSideMenuHovered = false;
  int hoveredSideMenuItem = -1;
  int selectedSideMenuItem = -1;

  bool isLogoutItemHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isSideMenuHovered ? 200 : 70,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(100),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 50,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${widget.user['id']}',
                        style: TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            for (int i = 0; i < widget.sideMenuItems.length; i++)
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    hoveredSideMenuItem = i;
                  });
                },
                onExit: (event) {
                  setState(() {
                    hoveredSideMenuItem = -1;
                  });
                },
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (selectedSideMenuItem != i) widget.onItemClick(i);
                    setState(() {
                      selectedSideMenuItem = i;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: selectedSideMenuItem == i
                          ? Colors.blue
                          : Colors.grey.withOpacity(selectedSideMenuItem != i &&
                                  hoveredSideMenuItem == i
                              ? 1
                              : 0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(children: [
                      Icon(
                        widget.sideMenuItems[i][1],
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            widget.sideMenuItems[i][0],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            Spacer(),
            //### LOGOUT ITEM
            MouseRegion(
              onEnter: (event) => setState(() {
                isLogoutItemHovered = true;
              }),
              onExit: (event) => setState(() {
                isLogoutItemHovered = false;
              }),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  widget.onLogoutClick();
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color:
                          Colors.red.withOpacity(isLogoutItemHovered ? 1 : 0.5),
                      borderRadius: BorderRadius.circular(50)),
                  child: Row(children: [
                    Icon(Icons.logout),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "Logout",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
