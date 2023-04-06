import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/screens/inventory/tab_materials.dart';
import 'package:wuusu_shop_client/screens/inventory/tab_products.dart';

class InventoryScreen extends StatefulWidget {
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
        content: Padding(child: TabProducts(), padding: EdgeInsets.all(10)),
        keepAlive: true));

    tabs.add(TabData(
        closable: false,
        text: 'Materials',
        content: Padding(child: TabMaterials(), padding: EdgeInsets.all(10)),
        keepAlive: true));

    _controller = TabbedViewController(tabs);
  }

  @override
  Widget build(BuildContext context) {
    TabbedView tabbedView = TabbedView(controller: _controller);
    Widget w =
        TabbedViewTheme(child: tabbedView, data: TabbedViewThemeData.mobile());

    return Container(width: double.infinity, height: double.infinity, child: w);
  }
}
