import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/screens/stock/tabs/stockadds/stockadds.dart';

class StockScreen extends StatefulWidget {
  final ApiCall apiCall;

  StockScreen({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late TabbedViewController _controller;

  @override
  void initState() {
    super.initState();

    List<TabData> tabs = [];

    tabs.add(
      TabData(
        closable: false,
        text: 'Stock Adds',
        content: StockAdds(
          apiCall: widget.apiCall,
        ),
        keepAlive: true,
      ),
    );

    tabs.add(
      TabData(
        closable: false,
        text: 'Stock Uses',
        content: Text("stock uses"),
        keepAlive: true,
      ),
    );

    tabs.add(
      TabData(
        closable: false,
        text: 'Suppliers',
        content: Text("suppliers"),
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
