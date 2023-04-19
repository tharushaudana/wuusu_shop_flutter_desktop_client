import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataGrid extends StatefulWidget {
  final List columnNames;
  final DataGridSource source;
  final onClickViewPdf;
  final onClickDelete;

  DataGrid({
    required this.columnNames,
    required this.source,
    required this.onClickViewPdf,
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
      columnWidthMode: ColumnWidthMode.auto,
      frozenColumnsCount: 1,
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
                widget.onClickViewPdf(row.getCells()[0].value);
              },
              color: Colors.blue,
              icon: const Icon(Icons.document_scanner),
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
      loadMoreViewBuilder: (BuildContext context, LoadMoreRows loadMoreRows) {
        Future<String> loadRows() async {
          await loadMoreRows();
          return Future<String>.value('Completed');
        }

        return FutureBuilder<String>(
            initialData: 'loading',
            future: loadRows(),
            builder: (context, snapShot) {
              if (snapShot.data == 'loading') {
                return BlurryContainer(
                  blur: 5,
                  width: double.infinity,
                  height: 60,
                  elevation: 0,
                  color: Colors.transparent,
                  child: Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return SizedBox.fromSize(size: Size.zero);
              }
            });
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
    );
  }
}
