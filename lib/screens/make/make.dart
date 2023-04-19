import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makesale/makesale.dart';

class MakeScreen extends StatefulWidget {
  final ApiCall apiCall;

  MakeScreen({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _MakeScreenState();
}

class _MakeScreenState extends State<MakeScreen> {
  late TabbedViewController _controller;

  Widget? displayWidget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(displayWidget == null ? 10 : 0),
      color: Colors.amber.withOpacity(0.1),
      width: double.infinity,
      height: double.infinity,
      child: displayWidget ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        displayWidget = MakeSale(
                          onClose: () {
                            setState(() {
                              displayWidget = null;
                            });
                          },
                          apiCall: widget.apiCall,
                        );
                      });
                    },
                    child: Text("Sale"),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  FilledButton(
                    onPressed: () {},
                    child: Text("Quotation"),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Edit/Delete or Pay:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
    );
  }
}
