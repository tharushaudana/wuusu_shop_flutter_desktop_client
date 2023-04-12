import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';

class DropDownSelectorProducts extends StatefulWidget {
  final ApiCall apiCall;
  final DropDownSelectorController controller;
  final onSelected;
  bool multiSelectMode = false;

  DropDownSelectorProducts({
    required this.apiCall,
    required this.controller,
    required this.multiSelectMode,
    required this.onSelected,
  });

  @override
  State<StatefulWidget> createState() => _DropDownSelectorProductsState();
}

class _DropDownSelectorProductsState extends State<DropDownSelectorProducts> {
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
      Map? data = await widget.apiCall.get("/products").call();

      safeCall(() {
        items = data!['products'];
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
      widget.onSelected(null);
      setState(() {
        selectedItemIndex = null;
        selectedItemsIndexes = [];
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
      labels.add(items[index]['itemcode']);
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
          isFetching ? 'Loading Products...' : 'Select a Product',
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
                                    items[i]['itemcode'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    items[i]['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10),
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
                      alignment: AlignmentDirectional.center,
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
                searchMatchFn: (item, searchValue) {
                  //Map? mitem = Map.from(item.value);
                  Map mitem = items[int.parse(item.value.toString())];
                  return (mitem['itemcode']
                          .toString()
                          .toLowerCase()
                          .contains(searchValue.toLowerCase()) ||
                      mitem['description']
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
