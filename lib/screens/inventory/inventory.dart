import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/materials/materials.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/products/products.dart';

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

    tabs.add(
      TabData(
        closable: false,
        text: 'Products',
        content: Products(
          apiCall: widget.apiCall,
        ),
        keepAlive: true,
      ),
    );

    tabs.add(
      TabData(
        closable: false,
        text: 'Materials',
        content: Materials(
          apiCall: widget.apiCall,
        ),
        keepAlive: true,
      ),
    );

    _controller = TabbedViewController(tabs);
  }

  @override
  Widget build(BuildContext context) {
    TabbedView tabbedView = TabbedView(controller: _controller);
    Widget w = TabbedViewTheme(
      data: Provider.of<ThemeModeNotifier>(context).isDarkMode
          ? TabbedViewThemeData.dark()
          : TabbedViewThemeData.mobile(colorSet: Colors.amber),
      child: tabbedView,
    );

    return Container(width: double.infinity, height: double.infinity, child: w);
  }
}
