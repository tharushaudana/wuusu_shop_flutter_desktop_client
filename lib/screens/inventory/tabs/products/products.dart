import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/products/datagrid.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/products/gridsource.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/products/rightmenu.dart';

class Products extends StatefulWidget {
  final ApiCall apiCall;

  Products({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  bool isFetching = false;

  bool isDisposed = false;

  final List columnNames = [
    'id',
    'itemcode',
    'description',
    'unit',
    'qty',
    'minqty',
    'price_sale',
    'max_retail_price',
    'received_rate',
    'profit_percent',
    'price_matara',
    'price_akuressa'
  ];

  final List inputData = [
    ["itemcode", "Item Code", "string"],
    ["description", "Description", "string"],
    ["unit", "Unit", "string"],
    ["minqty", "Minimum Qty", "number"],
    ["max_retail_price", "Maximum Retail Price", "number"],
    ["saler_discount_rate", "Saler Discount Rate", "number"],
    ["profit_percent", "Profit Percentage", "number"],
    ["price_matara", "Price Matara", "number"],
    ["price_akuressa", "Price Akuressa", "number"],
  ];

  late GridSource gridSource;

  String searchValue = "";

  bool isRightSideMenuOpened = false;
  Map? productToUpdate;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  fetch(BuildContext context) async {
    safeCall(() => setState(() => isFetching = true));

    try {
      Map? data = await widget.apiCall.get("/products").call();

      safeCall(() {
        gridSource = GridSource(
          columnNames: columnNames,
          context: context,
          items: data!['products'],
        );

        setState(() => isFetching = false);
      });
    } catch (e) {
      safeCall(() {
        gridSource = GridSource(
          columnNames: columnNames,
          context: context,
          items: [],
        );

        setState(() => isFetching = false);

        Alert.show("Fetching Failed", e.toString(), context);
      });
    }

    safeCall(() => addFilters(searchValue));
  }

  doAdd(Map product, menu) async {
    try {
      Map? data =
          await widget.apiCall.post('/products').data("", product).call();
      safeCall(() {
        menu.onAddResult(data!['product']);
        gridSource.add(data['product']);
      });
    } catch (e) {
      safeCall(() {
        menu.onAddResult(null);
        Alert.show("Unable to Add", e.toString(), context);
      });
    }
  }

  doUpdate(Map product, menu) async {
    try {
      Map? data = await widget.apiCall
          .patch('/products/${product['id']}')
          .data("", product)
          .call();
      safeCall(() {
        menu.onUpdateResult(data!['product']);
        gridSource.update(data['product']);
      });
    } catch (e) {
      safeCall(() {
        menu.onUpdateResult(null);
        Alert.show("Unable to Update", e.toString(), context);
      });
    }
  }

  doDelete(id, dialog) async {
    dialog.showProgressIndicator(true);

    try {
      Map? data = await widget.apiCall.delete('/products/$id').call();
      safeCall(() {
        dialog.close();
        gridSource.delete(id);
      });
    } catch (e) {
      safeCall(() {
        dialog.close();
        Alert.show("Unable to Delete!", e.toString(), context);
      });
    }
  }

  addFilters(String value) {
    gridSource.clearFilters();

    if (value.trim().length > 0) {
      gridSource.addFilter(
        'itemcode',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
      gridSource.addFilter(
        'description',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetch(context);
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
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      searchValue = value;
                      addFilters(value);
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
                      hintText: 'Search...',
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      height: double.infinity,
                      child: isFetching
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : DataGrid(
                              columnNames: columnNames,
                              source: gridSource,
                              onClickUpdate: (id) {
                                setState(() {
                                  productToUpdate = gridSource.getItem(id);
                                  isRightSideMenuOpened = true;
                                });
                              },
                              onClickDelete: (id) {
                                Alert.showConfirm(
                                  'Delete Product #$id',
                                  "Are you sure?",
                                  context,
                                  (dialog) {
                                    doDelete(id, dialog);
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: !isRightSideMenuOpened ? 50 : 300,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(50),
              border: const Border(
                left: BorderSide(
                  width: 1,
                  color: Colors.amber,
                ),
              ),
            ),
            child: !isRightSideMenuOpened
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: !isFetching
                            ? () {
                                fetch(context);
                              }
                            : null,
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            productToUpdate = null;
                            isRightSideMenuOpened = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                : RightMenu(
                    inputData: inputData,
                    onClickAdd: (product, menu) {
                      doAdd(product, menu);
                    },
                    onClickUpdate: (product, menu) {
                      doUpdate(product, menu);
                    },
                    onClose: () {
                      setState(() {
                        isRightSideMenuOpened = false;
                      });
                    },
                    product: productToUpdate,
                  ),
          ),
        ],
      ),
    );
  }
}
