import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/materials/datagrid.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/materials/gridsource.dart';
import 'package:wuusu_shop_client/screens/inventory/tabs/materials/rightmenu.dart';

class Materials extends StatefulWidget {
  final ApiCall apiCall;

  Materials({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _MaterialsState();
}

class _MaterialsState extends State<Materials> {
  bool isFetching = false;

  bool isDisposed = false;

  final List columnNames = [
    'id',
    'description',
    'unit',
  ];

  final List inputData = [
    ["description", "Description", "string"],
    ["unit", "Unit", "string"],
  ];

  late GridSource gridSource;

  String searchValue = "";

  bool isRightSideMenuOpened = false;
  Map? materialToUpdate;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  fetch(BuildContext context) async {
    safeCall(() => setState(() => isFetching = true));

    try {
      Map? data = await widget.apiCall.get("/materials").call();

      safeCall(() {
        gridSource = GridSource(
          columnNames: columnNames,
          context: context,
          items: data!['materials'],
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

        //Alert.show("Fetching Failed", e.toString(), context);
      });
    }

    safeCall(() => addFilters(searchValue));
  }

  doAdd(Map material, menu) async {
    try {
      Map? data =
          await widget.apiCall.post('/materials').object(material).call();

      safeCall(() {
        menu.onAddResult(data!['material']);
        gridSource.add(data['material']);
      });
    } catch (e) {
      safeCall(() {
        menu.onAddResult(null);
        Alert.show("Unable to Add", e.toString(), context);
      });
    }
  }

  doUpdate(Map material, menu) async {
    try {
      Map? data = await widget.apiCall
          .patch('/materials/${material['id']}')
          .object(material)
          .call();
      safeCall(() {
        menu.onUpdateResult(data!['material']);
        gridSource.update(data['material']);
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
      Map? data = await widget.apiCall.delete('/materials/$id').call();
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

    if (value.trim().isNotEmpty) {
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
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  materialToUpdate = gridSource.getItem(id);
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
                  const SizedBox(
                    height: 10,
                  ),
                  !isFetching
                      ? Text('Showing ${gridSource.itemCount()} Items')
                      : Container()
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
                            materialToUpdate = null;
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
                    material: materialToUpdate,
                  ),
          ),
        ],
      ),
    );
  }
}
