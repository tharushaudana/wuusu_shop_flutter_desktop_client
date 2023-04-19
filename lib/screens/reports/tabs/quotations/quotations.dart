import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/apifilter.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_suppliers.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/reports/tabs/quotations/datagrid.dart';
import 'package:wuusu_shop_client/screens/reports/tabs/quotations/filtermenu.dart';
import 'package:wuusu_shop_client/screens/reports/tabs/quotations/gridsource.dart';

class Quotations extends StatefulWidget {
  final ApiCall apiCall;

  Quotations({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _QuotationsState();
}

class _QuotationsState extends State<Quotations> {
  bool isFetching = false;

  bool isDisposed = false;

  final List columnNames = [
    'invoice_id',
    'customer',
    'title',
    'validuntil',
    'created_at',
    'updated_at',
  ];

  late GridSource gridSource;

  String searchValue = "";

  ApiFilter filter = ApiFilter();

  int currentMenuIndex = 0;

  int currentPage = 1;
  int? totalPages;
  int? totalItems;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  loadPage(int page) async {
    if (page <= 0 || (totalPages != null && page > totalPages!)) return [];

    try {
      Map? data = await widget.apiCall
          .get("/quotations")
          .param("page", page)
          .param("filter", filter.toJsonStr())
          .call();

      List records = data!['items'];

      currentPage = page;
      totalPages = data['total_pages'];
      totalItems = data['total_items'];

      safeCall(() {
        setState(() {}); // for update current item count in screen
      });

      return records;
    } catch (e) {
      safeCall(() {
        Alert.show("Fetching Failed", e.toString(), context);
      });

      throw Exception();
    }
  }

  fetch(BuildContext context) async {
    safeCall(() => setState(() => isFetching = true));

    try {
      List records = await loadPage(1);

      safeCall(() {
        gridSource = GridSource(
          onLoadMore: () async {
            return await loadPage(currentPage + 1);
          },
          columnNames: columnNames,
          context: context,
          items: records,
        );

        setState(() => isFetching = false);
      });
    } catch (e) {
      safeCall(() {
        gridSource = GridSource(
          onLoadMore: () async {
            return await loadPage(currentPage + 1);
          },
          columnNames: columnNames,
          context: context,
          items: [],
        );

        setState(() => isFetching = false);
      });
    }

    safeCall(() => addFilters(searchValue));
  }

  addFilters(String value) {
    gridSource.clearFilters();

    if (value.trim().isNotEmpty) {
      gridSource.addFilter(
        'invoice_id',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
      gridSource.addFilter(
        'customer',
        FilterCondition(
          type: FilterType.contains,
          filterBehavior: FilterBehavior.stringDataType,
          value: value.toString(),
        ),
      );
      gridSource.addFilter(
        'title',
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
                              onClickViewPdf: (invoice_id) {
                                PdfViewer.show(
                                  context: context,
                                  apiCall: widget.apiCall,
                                  invoice_id: invoice_id,
                                  theme: 'ctec',
                                );
                              },
                              onClickDelete: (invoice_id) {},
                              columnNames: columnNames,
                              source: gridSource,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  totalItems != null
                      ? Text(
                          'Showing ${gridSource.itemCount()} of $totalItems Items')
                      : Container()
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: currentMenuIndex == 0 ? 51 : 300,
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
            child: IndexedStack(
              index: currentMenuIndex,
              children: [
                Column(
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
                      onPressed: !isFetching
                          ? () {
                              setState(() {
                                currentMenuIndex = 1;
                              });
                            }
                          : null,
                      color: filter.isEmpty()
                          ? Theme.of(context).iconTheme.color
                          : Colors.blue,
                      icon: const Icon(Icons.filter_alt_outlined),
                    ),
                  ],
                ),
                FilterMenu(
                  apiCall: widget.apiCall,
                  filter: filter,
                  onClickFilter: () {
                    fetch(context);
                  },
                  onClose: () {
                    setState(() {
                      currentMenuIndex = 0;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
