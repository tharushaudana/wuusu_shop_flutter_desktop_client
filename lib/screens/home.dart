import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/screens/inventory/inventory.dart';
import 'package:wuusu_shop_client/screens/login.dart';
import 'package:wuusu_shop_client/screens/make/make.dart';
import 'package:wuusu_shop_client/screens/reports/reports.dart';
import 'package:wuusu_shop_client/screens/stock/stock.dart';
import 'package:wuusu_shop_client/storage.dart';

class HomeScreen extends StatefulWidget {
  final ApiCall apiCall;
  final Map user;

  HomeScreen({
    required this.apiCall,
    required this.user,
  });

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List sideMenuItems = [
    ["Inventory", Icons.house],
    ["Stock", Icons.list],
    ["Reports", Icons.document_scanner],
    ["Make", Icons.create],
    //["Users", Icons.group]
  ];

  int selectedSideMenuItem = -1;

  logout(BuildContext context) {
    Storage storage = Storage();

    storage.delete("token");

    openLoginScreen(context);
  }

  openLoginScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideMenu(
              //user: {'name': 'Tharusha Udana', 'id': '01'},
              user: widget.user,
              sideMenuItems: sideMenuItems,
              onItemClick: (int i) {
                setState(() {
                  selectedSideMenuItem = i;
                });
              },
              onLogoutClick: () {
                Alert.showConfirm(
                  "Close This Section",
                  "Are you sure?",
                  context,
                  (dialog) {
                    dialog.close();
                    logout(context);
                  },
                );
              },
            ),
            selectedSideMenuItem == -1
                ? Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.amber.withOpacity(0.2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "WUUSU FASHION DESKTOP",
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "version 1.0",
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: Colors.amber.withAlpha(100),
                          child: Text(
                            sideMenuItems[selectedSideMenuItem][0],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: selectedSideMenuItem == 0
                              ? InventoryScreen(
                                  apiCall: widget.apiCall,
                                )
                              : selectedSideMenuItem == 1
                                  ? StockScreen(
                                      apiCall: widget.apiCall,
                                    )
                                  : selectedSideMenuItem == 2
                                      ? ReportsScreen(
                                          apiCall: widget.apiCall,
                                        )
                                      : selectedSideMenuItem == 3
                                          ? MakeScreen(
                                              apiCall: widget.apiCall,
                                            )
                                          : Container(),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  final Map user;
  final List sideMenuItems;
  final onItemClick;
  final onLogoutClick;

  SideMenu({
    required this.user,
    required this.sideMenuItems,
    required this.onItemClick,
    required this.onLogoutClick,
  });

  @override
  State<StatefulWidget> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool isSideMenuHovered = false;
  int hoveredSideMenuItem = -1;
  int selectedSideMenuItem = -1;

  bool isThemeModeChangerHovered = false;

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
        width: isSideMenuHovered ? 200 : 71,
        decoration: BoxDecoration(
          color: Colors.amber.withAlpha(100),
          border: Border(
            right: BorderSide(width: 1, color: Colors.amber),
          ),
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
                          : Colors.amber.withOpacity(
                              selectedSideMenuItem != i &&
                                      hoveredSideMenuItem == i
                                  ? 1
                                  : 0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Spacer(),
            //### Theme Mode Change
            Consumer<ThemeModeNotifier>(
              builder: (context, notifier, child) => MouseRegion(
                onEnter: (event) => setState(() {
                  isThemeModeChangerHovered = true;
                }),
                onExit: (event) => setState(() {
                  isThemeModeChangerHovered = false;
                }),
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    notifier.toggleThemeMode();
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey
                          .withOpacity(isThemeModeChangerHovered ? 0.5 : 0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(children: [
                      Icon(
                        notifier.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            notifier.isDarkMode ? "Dark" : "Light",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
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
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
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
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
