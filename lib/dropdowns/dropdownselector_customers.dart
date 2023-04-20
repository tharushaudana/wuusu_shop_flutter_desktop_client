import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/funcs.dart';

class DropDownSelectorCustomers extends StatefulWidget {
  final ApiCall apiCall;
  final DropDownSelectorController controller;
  final onSelected;
  bool multiSelectMode = false;

  DropDownSelectorCustomers({
    required this.apiCall,
    required this.controller,
    required this.multiSelectMode,
    required this.onSelected,
  });

  @override
  State<StatefulWidget> createState() => _DropDownSelectorCustomersState();
}

class _DropDownSelectorCustomersState extends State<DropDownSelectorCustomers> {
  bool isDisposed = false;
  bool isFetching = false;

  final TextEditingController searchController = TextEditingController();

  List items = [];

  int? selectedItemIndex;
  List selectedItemsIndexes = [];

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  fetch(BuildContext context) async {
    safeCall(() => setState(() => isFetching = true));

    try {
      Map? data = await widget.apiCall.get("/customers").call();

      safeCall(() {
        items = data!['customers'];
        setState(() => isFetching = false);
      });
    } catch (e) {
      safeCall(() {
        items = [];
        setState(() => isFetching = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    widget.controller.onReset(() {
      safeCall(() {
        widget.onSelected(null);
        setState(() {
          selectedItemIndex = null;
          selectedItemsIndexes = [];
        });
      });
    });

    fetch(context);
  }

  @override
  void dispose() {
    isDisposed = true;
    searchController.dispose();
    super.dispose();
  }

  triggerCallback() {
    if (!widget.multiSelectMode) {
      widget.onSelected(items[selectedItemIndex!]);
    } else {
      widget.onSelected(selectedItemsIndexes.map((i) => items[i]).toList());
    }
  }

  getSelectedItemLabels() {
    List labels = [];

    for (int index in selectedItemsIndexes) {
      labels.add(items[index]['name']);
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        value: !widget.multiSelectMode
            ? selectedItemIndex
            : selectedItemsIndexes.isEmpty
                ? null
                : selectedItemsIndexes.last,
        hint: Text(
          isFetching ? 'Loading Customers...' : 'Select a Customer',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        items: isFetching
            ? []
            : [
                for (int i = 0; i < items.length; i++)
                  DropdownMenuItem(
                    enabled: !widget.multiSelectMode,
                    value: i,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: StatefulBuilder(
                        builder: (context, menuState) {
                          return Row(
                            children: [
                              widget.multiSelectMode
                                  ? Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Checkbox(
                                        value: selectedItemsIndexes.contains(i),
                                        onChanged: (value) {
                                          if (value == true) {
                                            setState(() {
                                              selectedItemsIndexes.add(i);
                                            });
                                            menuState(() {});
                                            triggerCallback();
                                          } else {
                                            setState(() {
                                              selectedItemsIndexes.remove(i);
                                            });
                                            menuState(() {});
                                            triggerCallback();
                                          }
                                        },
                                      ),
                                    )
                                  : Container(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    items[i]['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            selectedItemIndex = value as int;
          });
          triggerCallback();
        },
        selectedItemBuilder: !widget.multiSelectMode
            ? null
            : (context) {
                return items.map(
                  (item) {
                    return Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        getSelectedItemLabels().join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    );
                  },
                ).toList();
              },
        buttonStyleData: const ButtonStyleData(
          height: 40,
          width: 140,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownSearchData: isFetching
            ? null
            : DropdownSearchData(
                searchController: searchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: searchController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            hintText: 'Search...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      !widget.multiSelectMode
                          ? TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dcontext) {
                                    return AddCustomerDialog(
                                      apiCall: widget.apiCall,
                                      onAdded: (customer) {
                                        setState(() {
                                          items.insert(0, customer);
                                          selectedItemIndex = 0;
                                        });

                                        widget.onSelected(customer);
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text("New"),
                            )
                          : Container()
                    ],
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  //Map? mitem = Map.from(item.value);
                  Map mitem = items[int.parse(item.value.toString())];
                  return (mitem['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchValue.toLowerCase()));
                },
              ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            searchController.clear();
          }
        },
      ),
    );
  }
}

class AddCustomerDialog extends StatefulWidget {
  final ApiCall apiCall;
  final onAdded;

  AddCustomerDialog({
    required this.apiCall,
    required this.onAdded,
  });

  @override
  State<StatefulWidget> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  bool isDisposed = false;

  bool isDoing = false;

  String nameInput = "";
  String addressInput = "";
  String phoneInput = "";
  String emailInput = "";

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  doAdd(Map customer) async {
    safeCall(() {
      setState(() {
        isDoing = true;
      });
    });

    try {
      Map? data =
          await widget.apiCall.post('/customers').object(customer).call();

      safeCall(() {
        widget.onAdded(data!['customer']);
        Navigator.of(context).pop();
      });
    } catch (e) {
      safeCall(() {
        setState(() {
          isDoing = false;
        });

        Alert.show("Unable to Add", e.toString(), context);
      });
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Customer"),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              onChanged: (value) => setState(() {
                nameInput = value;
              }),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: nameInput,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      offset: nameInput.length,
                    ),
                  ),
                ),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                hintText: 'Enter Name here',
                labelText: 'Name',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              onChanged: (value) => setState(() {
                addressInput = value;
              }),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: addressInput,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      offset: addressInput.length,
                    ),
                  ),
                ),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                hintText: 'Enter Address here',
                labelText: 'Address',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              onChanged: (value) => setState(() {
                phoneInput = value;
              }),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: phoneInput,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      offset: phoneInput.length,
                    ),
                  ),
                ),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                hintText: 'Enter Phone Number here',
                labelText: 'Phone',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              onChanged: (value) => setState(() {
                emailInput = value;
              }),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: emailInput,
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      offset: emailInput.length,
                    ),
                  ),
                ),
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                hintText: 'Enter Email here',
                labelText: 'Email',
                errorText: emailInput.isEmpty
                    ? null
                    : !Funcs.isValidEmail(emailInput)
                        ? "invalid email!"
                        : null,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            FilledButton(
              onPressed: nameInput.trim().isEmpty ||
                      (emailInput.isNotEmpty &&
                          !Funcs.isValidEmail(emailInput)) ||
                      isDoing
                  ? null
                  : () {
                      doAdd({
                        'name': nameInput.trim(),
                        'address': addressInput.trim(),
                        'phone': phoneInput.trim(),
                        'email': emailInput.trim(),
                      });
                    },
              child: !isDoing
                  ? const Text(
                      "Done",
                      overflow: TextOverflow.ellipsis,
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
      ),
      actions: [
        TextButton(
          onPressed: isDoing
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(
            "Close",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
