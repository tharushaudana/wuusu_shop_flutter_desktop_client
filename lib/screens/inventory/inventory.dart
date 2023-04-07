import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/screens/inventory/tab_materials.dart';
import 'package:wuusu_shop_client/screens/inventory/tab_products.dart';

class InventoryScreen extends StatefulWidget {
  final ApiCall apiCall;

  InventoryScreen({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late TabbedViewController _controller;

  @override
  void initState() {
    super.initState();

    List<TabData> tabs = [];

    tabs.add(TabData(
        closable: false,
        text: 'Products',
        content: Padding(
            child: TabProducts(
              apiCall: widget.apiCall,
            ),
            padding: EdgeInsets.all(10)),
        keepAlive: true));

    tabs.add(TabData(
        closable: false,
        text: 'Materials',
        content: Padding(
            child: TabMaterials(
              apiCall: widget.apiCall,
            ),
            padding: EdgeInsets.all(10)),
        keepAlive: true));

    _controller = TabbedViewController(tabs);
  }

  @override
  Widget build(BuildContext context) {
    TabbedView tabbedView = TabbedView(controller: _controller);
    Widget w = TabbedViewTheme(
        child: tabbedView,
        data: Provider.of<ThemeModeNotifier>(context).isDarkMode
            ? TabbedViewThemeData.dark()
            : TabbedViewThemeData.mobile());

    return Container(width: double.infinity, height: double.infinity, child: w);
  }
}
