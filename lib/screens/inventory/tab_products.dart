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

  fetch(BuildContext context) async {
    setState(() {
      isFetching = true;
    });

    try {
      Map? data = await widget.apiCall.get("/products").call();

      productsDataSource = ProductsDataSource(products: data!['products']);

      setState(() {
        isFetching = false;
        //products = data!['products'];
        //print(products);
      });
    } catch (e) {
      productsDataSource = ProductsDataSource(products: []);

      setState(() {
        isFetching = false;
      });

      Alert.show("Fetching failed!", e.toString(), context);
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (value) => {},
                    //initialValue: email
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        hintText: 'Search...'),
                  ),
                ),
                IconButton(
                  onPressed: !isFetching
                      ? () {
                          fetch(context);
                        }
                      : null,
                  icon: Icon(Icons.refresh),
                  color: Colors.blue,
                )
              ],
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
                                ))),
                        GridColumn(
                            columnName: 'itemcode',
                            width: columnWidths['itemcode']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('ITCODE'))),
                        GridColumn(
                            columnName: 'description',
                            width: columnWidths['description']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Description',
                                  overflow: TextOverflow.ellipsis,
                                ))),
                        GridColumn(
                            columnName: 'unit',
                            width: columnWidths['unit']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Unit'))),
                        GridColumn(
                            columnName: 'qty',
                            width: columnWidths['qty']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Available QTY'))),
                        GridColumn(
                            columnName: 'minqty',
                            width: columnWidths['minqty']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Minimum QTY'))),
                        GridColumn(
                            columnName: 'price_sale',
                            width: columnWidths['price_sale']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Price Sale'))),
                        GridColumn(
                            columnName: 'max_retail_price',
                            width: columnWidths['max_retail_price']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Maximum Retail Price'))),
                        GridColumn(
                            columnName: 'received_rate',
                            width: columnWidths['received_rate']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Received Rate'))),
                        GridColumn(
                            columnName: 'profit_percent',
                            width: columnWidths['profit_percent']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Profit Percentage'))),
                        GridColumn(
                            columnName: 'price_matara',
                            width: columnWidths['price_matara']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Price Matara'))),
                        GridColumn(
                            columnName: 'price_akuressa',
                            width: columnWidths['price_akuressa']!,
                            label: Container(
                                padding: EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                child: Text('Price Akuressa'))),
                      ],
                      stackedHeaderRows: <StackedHeaderRow>[
                        StackedHeaderRow(cells: [
                          StackedHeaderCell(
                              columnNames: [
                                'id',
                                'itemcode',
                                'description',
                                'unit'
                              ],
                              child: Container(
                                  color: Colors.blue.withOpacity(1),
                                  child:
                                      Center(child: Text('Product Details')))),
                          StackedHeaderCell(
                              columnNames: ['qty', 'minqty'],
                              child: Container(
                                  color: Colors.blue.withOpacity(0.5),
                                  child: Center(child: Text('Stock Details')))),
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
                                  child: Center(child: Text('Price Details')))),
                        ])
                      ],
                    ),
            ))
          ],
        ));
  }
}

class ProductsDataSource extends DataGridSource {
  List<DataGridRow> _data = [];

  @override
  List<DataGridRow> get rows => _data;

  ProductsDataSource({required List<dynamic> products}) {
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
      if (e.columnName == 'price_sale')
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(e.value[0].toString()),
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
