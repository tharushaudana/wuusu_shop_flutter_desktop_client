import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataGrid extends StatefulWidget {
  final List columnNames;
  final DataGridSource source;
  final onClickUpdate;
  final onClickDelete;

  DataGrid({
    required this.columnNames,
    required this.source,
    required this.onClickUpdate,
    required this.onClickDelete,
  });

  @override
  State<StatefulWidget> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  late Map<String, double> columnWidths = {};

  //### Ex: convert 'this_is_name' to 'This Is Name'
  String getColumnLabel(String columnName) {
    List slices = columnName.split('_');
    String name = "";
    for (int i = 0; i < slices.length; i++) {
      slices[i] =
          slices[i][0].toUpperCase() + slices[i].substring(1).toLowerCase();
    }
    return slices.join(' ');
  }

  @override
  void initState() {
    super.initState();
    for (var colName in widget.columnNames) {
      columnWidths[colName] = double.nan;
    }
  }

  @override
  Widget build(Object context) {
    return SfDataGrid(
      source: widget.source,
      columnWidthMode: ColumnWidthMode.lastColumnFill,
      frozenColumnsCount: 2,
      allowSorting: true,
      allowMultiColumnSorting: true,
      allowColumnsResizing: true,
      allowSwiping: true,
      swipeMaxOffset: 100.0,
      startSwipeActionsBuilder: (
        BuildContext context,
        DataGridRow row,
        int rowIndex,
      ) {
        return Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () {
                widget.onClickUpdate(row.getCells()[0].value);
              },
              color: Colors.blue,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                widget.onClickDelete(row.getCells()[0].value);
              },
              color: Colors.red,
              icon: const Icon(Icons.delete),
            ),
          ],
        );
      },
      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
        setState(() {
          columnWidths[details.column.columnName] = details.width;
        });
        return true;
      },
      columns: <GridColumn>[
        for (String columnName in widget.columnNames)
          GridColumn(
            columnName: columnName,
            width: columnWidths[columnName]!,
            label: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                getColumnLabel(columnName),
              ),
            ),
          )
      ],
      stackedHeaderRows: <StackedHeaderRow>[
        StackedHeaderRow(
          cells: [
            StackedHeaderCell(
              columnNames: ['id', 'itemcode', 'description', 'unit'],
              child: Container(
                color: Colors.blue.withOpacity(1),
                child: const Center(
                  child: Text('Product Details'),
                ),
              ),
            ),
            StackedHeaderCell(
              columnNames: ['qty', 'minqty'],
              child: Container(
                color: Colors.blue.withOpacity(0.5),
                child: const Center(
                  child: Text('Stock Details'),
                ),
              ),
            ),
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
                child: const Center(
                  child: Text('Price Details'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
