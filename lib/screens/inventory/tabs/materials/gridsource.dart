import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';

class GridSource extends DataGridSource {
  final List columnNames;
  final BuildContext context;
  List<dynamic> _items = [];

  @override
  List<DataGridRow> get rows => _items
      .map<DataGridRow>((e) => DataGridRow(cells: [
            for (String columnName in columnNames)
              DataGridCell(
                columnName: columnName,
                value: e[columnName],
              )
          ]))
      .toList();

  GridSource({
    required this.columnNames,
    required this.context,
    required List<dynamic> items,
  }) {
    _items.clear();
    _items.addAll(items);
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

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>(
      (e) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      },
    ).toList());
  }
}
