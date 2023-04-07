import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';

class TabProducts extends StatefulWidget {
  final ApiCall apiCall;

  TabProducts({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _TabProductsState();
}

class _TabProductsState extends State<TabProducts> {
  bool isFetching = false;

  List<dynamic> products = [];
  late ProductsDataSource productsDataSource;

  late Map<String, double> columnWidths = {
    'id': double.nan,
    'itemcode': double.nan,
    'description': double.nan,
    'unit': double.nan,
    'qty': double.nan,
    'minqty': double.nan,
    'price_sale': double.nan,
    'max_retail_price': double.nan,
    'received_rate': double.nan,
    'profit_percent': double.nan,
    'price_matara': double.nan,
    'price_akuressa': double.nan,
  };

  String searchValue = "";

  bool isRightSideMenuOpened = false;
  Map? productToUpdate;

  fetch(BuildContext context) async {
    setState(() {
      isFetching = true;
    });

    try {
      Map? data = await widget.apiCall.get("/products").call();

      productsDataSource =
          ProductsDataSource(context: context, products: data!['products']);

      setState(() {
        isFetching = false;
        //products = data!['products'];
        //print(products);
      });
    } catch (e) {
      productsDataSource = ProductsDataSource(context: context, products: []);

      setState(() {
        isFetching = false;
      });

      Alert.show("Fetching failed!", e.toString(), context);
    }

    addFilters(searchValue);
  }

  addFilters(String value) {
    productsDataSource.clearFilters();

    if (value.trim().length > 0) {
      productsDataSource.addFilter(
        'itemcode',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
      productsDataSource.addFilter(
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
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
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
                      margin: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      height: double.infinity,
                      child: isFetching
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : SfDataGrid(
                              source: productsDataSource,
                              frozenColumnsCount: 2,
                              allowSorting: true,
                              allowMultiColumnSorting: true,
                              allowColumnsResizing: true,
                              onColumnResizeUpdate:
                                  (ColumnResizeUpdateDetails details) {
                                setState(() {
                                  columnWidths[details.column.columnName] =
                                      details.width;
                                });
                                return true;
                              },
                              columns: <GridColumn>[
                                GridColumn(
                                  columnName: 'id',
                                  width: columnWidths['id']!,
                                  label: Container(
                                    padding: EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'ID',
                                    ),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'itemcode',
                                  width: columnWidths['itemcode']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('ITCODE'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'description',
                                  width: columnWidths['description']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Description'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'unit',
                                  width: columnWidths['unit']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Unit'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'qty',
                                  width: columnWidths['qty']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Available QTY'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'minqty',
                                  width: columnWidths['minqty']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Minimum QTY'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'price_sale',
                                  width: columnWidths['price_sale']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Price Sale'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'max_retail_price',
                                  width: columnWidths['max_retail_price']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Maximum Retail Price'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'received_rate',
                                  width: columnWidths['received_rate']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Received Rate'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'profit_percent',
                                  width: columnWidths['profit_percent']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Profit Percentage'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'price_matara',
                                  width: columnWidths['price_matara']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Price Matara'),
                                  ),
                                ),
                                GridColumn(
                                  columnName: 'price_akuressa',
                                  width: columnWidths['price_akuressa']!,
                                  label: Container(
                                    padding: EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    child: Text('Price Akuressa'),
                                  ),
                                ),
                              ],
                              stackedHeaderRows: <StackedHeaderRow>[
                                StackedHeaderRow(
                                  cells: [
                                    StackedHeaderCell(
                                        columnNames: [
                                          'id',
                                          'itemcode',
                                          'description',
                                          'unit'
                                        ],
                                        child: Container(
                                            color: Colors.blue.withOpacity(1),
                                            child: Center(
                                                child:
                                                    Text('Product Details')))),
                                    StackedHeaderCell(
                                        columnNames: ['qty', 'minqty'],
                                        child: Container(
                                            color: Colors.blue.withOpacity(0.5),
                                            child: Center(
                                                child: Text('Stock Details')))),
                                    StackedHeaderCell(
                                        columnNames: [
                                          'price_sale',
                                          'max_retail_price',
                                          'received_rate',
                                          'profit_percent',
                                          'price_matara',
                                          'price_akuressa'
                                        ],
                                        child: Container(
                                            color: Colors.blue.withOpacity(0.2),
                                            child: Center(
                                                child: Text('Price Details')))),
                                  ],
                                )
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: !isRightSideMenuOpened ? 50 : 300,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(50),
              border: Border(
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
                        icon: Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            productToUpdate = null;
                            isRightSideMenuOpened = true;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  )
                : DialogAdd(
                    apiCall: widget.apiCall,
                    onDone: () {
                      fetch(context);
                    },
                    onClose: () {
                      setState(() {
                        isRightSideMenuOpened = false;
                      });
                    },
                    product: productToUpdate,
                  ),
          )
        ],
      ),
    );
  }
}

class DialogAdd extends StatefulWidget {
  final ApiCall apiCall;
  final Map? product;
  final onDone;
  final onClose;

  DialogAdd({
    required this.apiCall,
    required this.product,
    required this.onDone,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _DialogAddState();
}

class _DialogAddState extends State<DialogAdd> {
  final _formKey = GlobalKey<FormState>();

  List inputs = [
    ["itemcode", "Item Code", "string", ""],
    ["description", "Description", "string", ""],
    ["unit", "Unit", "string", ""],
    ["minqty", "Minimum Qty", "number", ""],
    ["max_retail_price", "Maximum Retail Price", "number", ""],
    ["saler_discount_rate", "Saler Discount Rate", "number", ""],
    ["profit_percent", "Profit Percentage", "number", ""],
    ["price_matara", "Price Matara", "number", ""],
    ["price_akuressa", "Price Akuressa", "number", ""],
  ];

  bool isValidated = false;

  bool isDoing = false;

  doAdd(Map product) async {
    setState(() {
      isDoing = true;
    });

    try {
      await widget.apiCall.post('/products').data("", product).call();

      setState(() {
        isDoing = false;
      });

      widget.onDone();
      widget.onClose();
    } catch (e) {
      setState(() {
        isDoing = false;
      });

      Alert.show("Unable to Add", e.toString(), context);
    }
  }

  doUpdate(Map product) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product == null
                ? "Add New Product"
                : "Update Product #${widget.product!['itemcode']}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: isDoing
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView.builder(
                      itemCount: inputs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(top: 10),
                          child: TextFormField(
                            onChanged: (value) => setState(() {
                              setState(() {
                                isValidated = _formKey.currentState!.validate();
                              });
                              inputs[index][3] = value;
                            }),
                            initialValue: inputs[index][3],
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 10),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0)),
                              ),
                              label: Text(
                                inputs[index][1],
                                overflow: TextOverflow.ellipsis,
                              ),
                              hintText: '${inputs[index][1]} here...',
                            ),
                            validator: (value) {
                              if (value.toString().trim().length == 0)
                                return "this field is required!";
                              if (inputs[index][2] == 'number' &&
                                  double.tryParse(value.toString()) == null)
                                return "invalid value!";
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: !isDoing && isValidated
                      ? () {
                          Map product = {};

                          inputs.forEach((item) {
                            product[item[0]] = item[3];
                          });

                          doAdd(product);
                        }
                      : null,
                  child: Text(
                    widget.product == null ? "Add" : "Update",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: !isDoing
                      ? () {
                          widget.onClose();
                        }
                      : null,
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.deepOrange),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ProductsDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> _data = [];

  @override
  List<DataGridRow> get rows => _data;

  ProductsDataSource({required this.context, required List<dynamic> products}) {
    _data = products
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell(columnName: 'id', value: e['id']),
              DataGridCell(columnName: 'itemcode', value: e['itemcode']),
              DataGridCell(columnName: 'description', value: e['description']),
              DataGridCell(columnName: 'unit', value: e['unit']),
              DataGridCell(columnName: 'qty', value: e['qty']),
              DataGridCell(columnName: 'minqty', value: e['minqty']),
              DataGridCell(columnName: 'price_sale', value: [
                e['price_sale'],
                e['recomanded_price_sale'],
                e['recomanded_profit_percent']
              ]),
              DataGridCell(
                  columnName: 'max_retail_price', value: e['max_retail_price']),
              DataGridCell(
                  columnName: 'received_rate', value: e['received_rate']),
              DataGridCell(
                  columnName: 'profit_percent', value: e['profit_percent']),
              DataGridCell(
                  columnName: 'price_matara', value: e['price_matara']),
              DataGridCell(
                  columnName: 'price_akuressa', value: e['price_akuressa']),
            ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      if (e.columnName == 'itemcode')
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(
            e.value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      else if (e.columnName == 'qty')
        return Container(
          color: e.value > 0
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      else if (e.columnName == 'price_sale')
        return MouseRegion(
          cursor: e.value[1] == null
              ? SystemMouseCursors.alias
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: e.value[1] == null
                ? null
                : () {
                    String msg = "Recomanded Price: Rs.${e.value[1]}";
                    if (e.value[2] != null)
                      msg += "\nRecomanded Profit: ${e.value[2]}%";
                    Alert.show("Details", msg, context);
                  },
            child: Container(
                color: e.value[1] == null
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Rs.${e.value[0]}"),
                    e.value[1] != null
                        ? Text(
                            "click here",
                            style: TextStyle(fontSize: 10),
                          )
                        : Container()
                  ],
                )),
          ),
        );
      else if (e.columnName == 'profit_percent')
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text("${e.value}%"),
        );
      else if ([
        'max_retail_price',
        'received_rate',
        'price_matara',
        'price_akuressa'
      ].contains(e.columnName))
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text("Rs.${e.value}"),
        );
      else
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
    }).toList());
  }
}
