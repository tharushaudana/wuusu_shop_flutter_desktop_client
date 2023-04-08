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
              columnName == 'price_sale'
                  ? DataGridCell(
                      columnName: columnName,
                      value: [
                        e['price_sale'],
                        e['recomanded_price_sale'],
                        e['recomanded_profit_percent']
                      ],
                    )
                  : DataGridCell(
                      columnName: columnName,
                      value: e[columnName],
                    ),
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
        if (e.columnName == 'itemcode') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (e.columnName == 'qty') {
          return Container(
            color: e.value > 0
                ? Colors.green.withOpacity(0.5)
                : Colors.red.withOpacity(0.5),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        } else if (e.columnName == 'price_sale') {
          return MouseRegion(
            cursor: e.value[1] == null
                ? SystemMouseCursors.alias
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: e.value[1] == null
                  ? null
                  : () {
                      String msg = "Recomanded Price: Rs.${e.value[1]}";

                      if (e.value[2] != null) {
                        msg += "\nRecomanded Profit: ${e.value[2]}%";
                      }

                      Alert.show("Details", msg, context);
                    },
              child: Container(
                  color: e.value[1] == null
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Rs.${e.value[0]}"),
                      e.value[1] != null
                          ? const Text(
                              "click here",
                              style: TextStyle(fontSize: 10),
                            )
                          : Container()
                    ],
                  )),
            ),
          );
        } else if (e.columnName == 'profit_percent') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text("${e.value}%"),
          );
        } else if ([
          'max_retail_price',
          'received_rate',
          'price_matara',
          'price_akuressa'
        ].contains(e.columnName)) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text("Rs.${e.value}"),
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
