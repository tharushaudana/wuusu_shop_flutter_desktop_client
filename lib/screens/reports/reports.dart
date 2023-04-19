import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/reports/tabs/sales/sales.dart';

class ReportsScreen extends StatefulWidget {
  final ApiCall apiCall;

  ReportsScreen({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late TabbedViewController _controller;

  @override
  void initState() {
    super.initState();

    List<TabData> tabs = [];

    tabs.add(
      TabData(
        closable: false,
        text: 'Sales',
        content: Sales(
          apiCall: widget.apiCall,
        ),
        keepAlive: true,
      ),
    );

    tabs.add(
      TabData(
        closable: false,
        text: 'Quotations',
        content: Text("quotations"),
        keepAlive: true,
      ),
    );

    tabs.add(
      TabData(
        closable: false,
        text: 'Material Lists',
        content: Text("mlists"),
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
