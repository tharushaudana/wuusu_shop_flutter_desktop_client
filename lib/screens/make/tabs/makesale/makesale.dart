import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makesale/rightmenu.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makesale/datagrid.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makesale/gridsource.dart';

class MakeSale extends StatefulWidget {
  final ApiCall apiCall;
  final onClose;

  MakeSale({
    required this.apiCall,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _MakeSaleState();
}

class _MakeSaleState extends State<MakeSale> {
  bool isDisposed = false;

  final List columnNames = [
    'id',
    'itemcode',
    'description',
    'unitprice',
    'qty',
    'discount',
    'total',
  ];

  late GridSource gridSource;

  String title = "";

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  @override
  void initState() {
    super.initState();

    gridSource = GridSource(
      columnNames: columnNames,
      context: context,
      items: [],
    );
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Create Sale",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          Alert.showConfirm(
                            "Close This Section",
                            "Are you sure?",
                            context,
                            (dialog) {
                              widget.onClose();
                              dialog.close();
                            },
                          );
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      title = value;
                    },
                    //initialValue: email
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                      ),
                      hintText: 'Enter sale title here.',
                      label: Text("Sale Title"),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      height: double.infinity,
                      child: DataGrid(
                        onClickDelete: (id) {
                          gridSource.delete(id);
                        },
                        columnNames: columnNames,
                        source: gridSource,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 300,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(50),
              border: const Border(
                left: BorderSide(
                  width: 1,
                  color: Colors.amber,
                ),
                top: BorderSide(
                  width: 1,
                  color: Colors.amber,
                ),
              ),
            ),
            child: RightMenu(
              onClickAdd: (item) {
                Map map = {
                  'id': item['product']['id'],
                  'itemcode': item['product']['itemcode'],
                  'description': item['product']['description'],
                  'unitprice': item['product']['price_sale'],
                  'qty': item['qty'],
                  'discount': item['discount'],
                  'total': double.parse(
                      ((double.parse(item['product']['price_sale']) *
                                  item['qty']) -
                              item['discount'])
                          .toStringAsFixed(2)),
                };

                if (gridSource.findIndex(item['product']['id']) == -1) {
                  gridSource.add(map);
                } else {
                  gridSource.update(map);
                }
              },
              apiCall: widget.apiCall,
            ),
          ),
        ],
      ),
    );
  }
}
