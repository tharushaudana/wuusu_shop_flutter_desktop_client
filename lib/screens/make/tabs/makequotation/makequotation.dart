import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makequotation/rightmenu.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makequotation/datagrid.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makequotation/gridsource.dart';

class MakeQuotation extends StatefulWidget {
  final ApiCall apiCall;
  final onClose;
  Map? itemToEdit;

  MakeQuotation({
    required this.apiCall,
    required this.onClose,
    this.itemToEdit,
  });

  @override
  State<StatefulWidget> createState() => _MakeQuotationState();
}

class _MakeQuotationState extends State<MakeQuotation> {
  bool isDisposed = false;

  bool isDoing = false;
  Map? doneResult;

  final List columnNames = [
    'id',
    'itemcode',
    'description',
    'unitprice',
    'qty',
    'discount',
    'total',
  ];

  late GridSource gridSource;

  String title = "";
  String? validuntil;
  int? customer_id;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  doCreate(Map quotation) async {
    safeCall(() {
      setState(() {
        isDoing = true;
      });
    });

    try {
      Map? data =
          await widget.apiCall.post('/quotations').object(quotation).call();

      safeCall(() {
        setState(() {
          doneResult = data!['quotation'];
        });
      });
    } catch (e) {
      safeCall(() {
        setState(() => isDoing = false);
        Alert.show("Unable to Create", e.toString(), context);
      });
    }
  }

  doEdit(Map quotation) async {
    safeCall(() {
      setState(() {
        isDoing = true;
      });
    });

    try {
      Map? data = await widget.apiCall
          .patch('/quotations/${widget.itemToEdit!['invoice_id']}')
          .object(quotation)
          .call();

      safeCall(() {
        setState(() {
          doneResult = widget.itemToEdit;
        });
      });
    } catch (e) {
      safeCall(() {
        setState(() => isDoing = false);
        Alert.show("Unable to Edit", e.toString(), context);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    List items = [];

    if (widget.itemToEdit != null) {
      title = widget.itemToEdit!['title'] ?? "";
      validuntil = widget.itemToEdit!['validuntil'];
      customer_id = widget.itemToEdit!['customer']['id'];

      items = (widget.itemToEdit!['quotation_data'] as List)
          .map((row) => {
                'id': row['product_id'],
                'itemcode': row['itemcode'],
                'description': row['description'],
                'unitprice': row['unitprice'],
                'qty': row['qty'],
                'discount': row['discount'],
                'total': double.parse(
                    ((double.parse(row['unitprice']) * int.parse(row['qty'])) -
                            double.parse(row['discount']))
                        .toStringAsFixed(2)),
              })
          .toList();
    }

    gridSource = GridSource(
      columnNames: columnNames,
      context: context,
      items: items,
    );
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
      child: doneResult != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Task Done.",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('INVOICE ID: ${doneResult!['invoice_id']}'),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Spacer(),
                    FilledButton(
                      onPressed: () {
                        PdfViewer.show(
                          context: context,
                          apiCall: widget.apiCall,
                          invoice_id: doneResult!['invoice_id'],
                          theme: 'ctec',
                        );
                      },
                      child: Text("View PDF"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onClose();
                      },
                      child: Text(
                        "Close",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.itemToEdit == null
                                  ? "Create Quotation"
                                  : "Edit Quotation : ${widget.itemToEdit!['invoice_id']}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Alert.showConfirm(
                                  "Close This Section",
                                  "Are you sure?",
                                  context,
                                  (dialog) {
                                    widget.onClose();
                                    dialog.close();
                                  },
                                );
                              },
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        widget.itemToEdit == null
                            ? TextFormField(
                                onChanged: (value) {
                                  title = value;
                                },
                                initialValue: title,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(left: 10, right: 10),
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
                                  hintText: 'Enter quotation title here.',
                                  label: Text("Quotation Title"),
                                ),
                              )
                            : Container(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: double.infinity,
                            height: double.infinity,
                            child: DataGrid(
                              onClickDelete: (id) {
                                gridSource.delete(id);
                                setState(() {});
                              },
                              columnNames: columnNames,
                              source: gridSource,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Spacer(),
                            FilledButton(
                              onPressed: customer_id == null ||
                                      validuntil == null ||
                                      gridSource.rows.isEmpty ||
                                      isDoing
                                  ? null
                                  : () {
                                      Map quotation = {};

                                      quotation['customer_id'] = customer_id;
                                      quotation['validuntil'] = validuntil;

                                      if (title.trim().isNotEmpty) {
                                        quotation['title'] = title.trim();
                                      }

                                      List quotation_data = gridSource.rows
                                          .map((DataGridRow row) => {
                                                'product_id':
                                                    row.getCells()[0].value,
                                                'qty': row.getCells()[4].value,
                                                'discount':
                                                    row.getCells()[5].value,
                                              })
                                          .toList();

                                      quotation['quotation_data'] =
                                          json.encode(quotation_data);

                                      if (widget.itemToEdit == null) {
                                        doCreate(quotation);
                                      } else {
                                        quotation.remove('customer_id');
                                        doEdit(quotation);
                                      }
                                    },
                              child: !isDoing
                                  ? const Text(
                                      "Done",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Container(
                                      width: 20,
                                      height: 20,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(50),
                    border: const Border(
                      left: BorderSide(
                        width: 1,
                        color: Colors.amber,
                      ),
                      top: BorderSide(
                        width: 1,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  child: RightMenu(
                    onClickAdd: (item) {
                      Map map = {
                        'id': item['product']['id'],
                        'itemcode': item['product']['itemcode'],
                        'description': item['product']['description'],
                        'unitprice': item['product']['price_sale'],
                        'qty': item['qty'],
                        'discount': item['discount'],
                        'total': double.parse(
                            ((double.parse(item['product']['price_sale']) *
                                        item['qty']) -
                                    item['discount'])
                                .toStringAsFixed(2)),
                      };

                      if (gridSource.findIndex(item['product']['id']) == -1) {
                        gridSource.add(map);
                      } else {
                        gridSource.update(map);
                      }

                      setState(() {});
                    },
                    onCustomerSelected: (customer) {
                      setState(() {
                        customer_id = customer['id'];
                      });
                    },
                    onValidUntilSelected: (date) {
                      setState(() {
                        validuntil = date;
                        print(validuntil);
                      });
                    },
                    apiCall: widget.apiCall,
                    hideCustomerSelector: widget.itemToEdit != null,
                    hideValidUntil: widget.itemToEdit != null,
                  ),
                ),
              ],
            ),
    );
  }
}
