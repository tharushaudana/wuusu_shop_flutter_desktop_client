import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';

class GridSource extends DataGridSource {
  final List columnNames;
  final BuildContext context;
  List<dynamic> _items = [];
  List<dynamic> _paginatedItems = [];

  @override
  List<DataGridRow> get rows => _paginatedItems
      .map<DataGridRow>((e) => DataGridRow(cells: [
            for (String columnName in columnNames)
              DataGridCell(
                  columnName: columnName,
                  value: columnName == 'product'
                      ? {
                          'itemcode': e[columnName]['itemcode'],
                          'description': e[columnName]['description'],
                        }
                      : columnName == 'supplier'
                          ? e[columnName]['name']
                          : e[columnName])
          ]))
      .toList();

  GridSource({
    required this.columnNames,
    required this.context,
    required List<dynamic> items,
  }) {
    _items.clear();
    _items.addAll(items);
    //_paginatedItems.clear();
    //_paginatedItems.addAll(items);
  }

  add(Map item) {
    //### Insert into Begin
    _items.insertAll(0, [item]);
    notifyListeners();
  }

  update(Map item) {
    int index = findIndex(item['id']);
    if (index == -1) return;
    _items[index] = item;
    notifyListeners();
  }

  delete(id) {
    int index = findIndex(id);
    if (index == -1) return;
    _items.removeAt(index);
    notifyListeners();
  }

  Map? getItem(id) {
    int index = findIndex(id);
    if (index > -1) return _items[index];
    return null;
  }

  int findIndex(id) {
    return _items.indexWhere((element) => element['id'] == id);
  }

  /*@override
  Future<void> handleLoadMoreRows() async {
    await Future.delayed(Duration(seconds: 5));
    _items.add({
      'id': '10',
      'product': {'itemcode': 'ITC01', 'description': 'TP'},
      'supplier': {'name': 'Tha'},
      'qty': 10,
      'created_at': 'sdfdfg'
    });
    notifyListeners();
  }*/

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    /*int startIndex = newPageIndex * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    if (startIndex < _orders.length && endIndex <= _orders.length) {
      _paginatedOrders =
          _orders.getRange(startIndex, endIndex).toList(growable: false);
      buildPaginatedDataGridRows();
      notifyListeners();
    } else {
      _paginatedOrders = [];
    }*/

    if (newPageIndex == 0) {
      _paginatedItems.addAll(_items);
      notifyListeners();
    }

    if (newPageIndex == 1) {
      _paginatedItems.clear();
      notifyListeners();
    }

    return true;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>(
      (e) {
        if (e.columnName == 'product') {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                String msg =
                    "Item Code: ${e.value['itemcode']}\nDescription: ${e.value['description']}";
                Alert.show("Product Details", msg, context);
              },
              child: Container(
                color: Colors.amber.withOpacity(0.8),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.value['itemcode'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "click here",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (e.columnName == 'supplier') {
          return Container(
            color: Colors.amber.withOpacity(0.5),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.value.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (e.columnName == 'qty') {
          return Container(
            color: Colors.amber.withOpacity(0.2),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }
      },
    ).toList());
  }
}
