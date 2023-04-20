import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/main.dart';
import 'package:wuusu_shop_client/pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makequotation/makequotation.dart';
import 'package:wuusu_shop_client/screens/make/tabs/makesale/makesale.dart';

class MakeScreen extends StatefulWidget {
  final ApiCall apiCall;

  MakeScreen({required this.apiCall});

  @override
  State<StatefulWidget> createState() => _MakeScreenState();
}

class _MakeScreenState extends State<MakeScreen> {
  late TabbedViewController _controller;

  bool isDisposed = false;

  Widget? displayWidget;

  bool isFetching = false;

  String invoiceIdInput = "";

  Map? data;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  fetchInvoice() async {
    String type = invoiceIdInput.split('-')[0].toString();

    String path = "";

    if (type == "INV") {
      path = "/sales";
    } else if (type == "QUO") {
      path = "/quotations";
    } else {
      return;
    }

    safeCall(() => setState(() => isFetching = true));

    try {
      Map? idata = await widget.apiCall.get('$path/$invoiceIdInput').call();

      safeCall(() {
        setState(() {
          isFetching = false;
          data = idata;
        });
      });
    } catch (e) {
      safeCall(() {
        setState(() => isFetching = false);
        Alert.show("Fetching Failed", e.toString(), context);
      });
    }
  }

  bool isValidInvoiceID() {
    List secs = invoiceIdInput.split('-');

    return (secs[0].toString() == 'INV' || secs[0].toString() == 'QUO') &&
        secs.length == 3 &&
        (secs[1].toString().length == 8 && secs[2].toString().length == 4);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(displayWidget == null ? 10 : 0),
      color: Colors.amber.withOpacity(0.1),
      width: double.infinity,
      height: double.infinity,
      child: displayWidget ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        displayWidget = MakeSale(
                          onClose: () {
                            setState(() {
                              displayWidget = null;
                            });
                          },
                          apiCall: widget.apiCall,
                        );
                      });
                    },
                    child: Text("Sale"),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        displayWidget = MakeQuotation(
                          onClose: () {
                            setState(() {
                              displayWidget = null;
                            });
                          },
                          apiCall: widget.apiCall,
                        );
                      });
                    },
                    child: Text("Quotation"),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Edit/Delete or Pay:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) => setState(() {
                        invoiceIdInput = value;
                      }),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: invoiceIdInput,
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              offset: invoiceIdInput.length,
                            ),
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(3.0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(3.0),
                            ),
                          ),
                          hintText: 'Enter Invoice ID here',
                          labelText: 'Invoice ID',
                          errorText: invoiceIdInput.isEmpty
                              ? null
                              : isValidInvoiceID()
                                  ? null
                                  : 'invalid invoice id!'),
                    ),
                  ),
                  !isFetching
                      ? isValidInvoiceID()
                          ? TextButton(
                              onPressed: () {
                                fetchInvoice();
                              },
                              child: Text("Load"),
                            )
                          : Container()
                      : Container(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                ],
              ),
              data != null && !isFetching
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      child: data!['sale'] != null
                          ? Row(
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      displayWidget = MakeSale(
                                        onClose: () {
                                          setState(() {
                                            displayWidget = null;
                                          });
                                        },
                                        apiCall: widget.apiCall,
                                        itemToEdit: data!['sale'],
                                      );
                                    });
                                  },
                                  child: Text("Edit"),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                FilledButton(
                                  onPressed: () {},
                                  child: Text("Delete"),
                                ),
                              ],
                            )
                          : data!['quotation'] != null
                              ? Row(
                                  children: [
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          displayWidget = MakeQuotation(
                                            onClose: () {
                                              setState(() {
                                                displayWidget = null;
                                              });
                                            },
                                            apiCall: widget.apiCall,
                                            itemToEdit: data!['quotation'],
                                          );
                                        });
                                      },
                                      child: Text("Edit"),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          displayWidget = MakeSale(
                                            onClose: () {
                                              setState(() {
                                                displayWidget = null;
                                              });
                                            },
                                            apiCall: widget.apiCall,
                                            itemToSale: data!['quotation'],
                                          );
                                        });
                                      },
                                      child: Text("Sale"),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FilledButton(
                                      onPressed: () {},
                                      child: Text("Delete"),
                                    ),
                                  ],
                                )
                              : Container(),
                    )
                  : Container(),
            ],
          ),
    );
  }
}
