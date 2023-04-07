import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';

class TabMaterials extends StatefulWidget {
  final ApiCall apiCall;

  TabMaterials({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _TabMaterialsState();
}

class _TabMaterialsState extends State<TabMaterials> {
  @override
  Widget build(Object context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Text("materials"),
    );
  }
}
