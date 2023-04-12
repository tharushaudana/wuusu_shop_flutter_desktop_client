import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/screens/stock/tabs/stockadds/datagrid.dart';
import 'package:wuusu_shop_client/screens/stock/tabs/stockadds/gridsource.dart';
import 'package:wuusu_shop_client/screens/stock/tabs/stockadds/rightmenu.dart';

class StockAdds extends StatefulWidget {
  final ApiCall apiCall;

  StockAdds({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _StockAddsState();
}

class _StockAddsState extends State<StockAdds> {
  bool isFetching = false;

  bool isDisposed = false;

  final List columnNames = [
    'id',
    'product',
    'supplier',
    'qty',
    'created_at',
  ];

  late GridSource gridSource;

  String searchValue = "";

  bool isRightSideMenuOpened = false;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  fetch(BuildContext context) async {
    safeCall(() => setState(() => isFetching = true));

    try {
      Map? data =
          await widget.apiCall.get("/stock/records").param("page", 1).call();

      safeCall(() {
        gridSource = GridSource(
          columnNames: columnNames,
          context: context,
          items: data!['items'],
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

  doAdd(Map record, menu) async {
    try {
      Map? data =
          await widget.apiCall.post('/stock/records').data("", record).call();
      safeCall(() {
        menu.onAddResult(data!['record']);
        gridSource.add(data['record']);
      });
    } catch (e) {
      safeCall(() {
        menu.onAddResult(null);
        Alert.show("Unable to Add", e.toString(), context);
      });
    }
  }

  addFilters(String value) {
    gridSource.clearFilters();

    if (value.trim().isNotEmpty) {
      gridSource.addFilter(
        'product',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
      gridSource.addFilter(
        'supplier',
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
              padding: const EdgeInsets.all(10),
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
            width: !isRightSideMenuOpened ? 51 : 300,
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
                            isRightSideMenuOpened = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                : RightMenu(
                    apiCall: widget.apiCall,
                    onClickAdd: (record, menu) {
                      doAdd(record, menu);
                    },
                    onClose: () {
                      setState(() {
                        isRightSideMenuOpened = false;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
