import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/apifilter.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_suppliers.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_users.dart';

class FilterMenu extends StatefulWidget {
  final ApiCall apiCall;
  final ApiFilter filter;
  final onFilterChange;
  final onClickFilter;
  final onClose;

  FilterMenu({
    required this.apiCall,
    required this.filter,
    required this.onFilterChange,
    required this.onClickFilter,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  DropDownSelectorController dropDownSelectorControllerProducts =
      DropDownSelectorController();
  DropDownSelectorController dropDownSelectorControllerUsers =
      DropDownSelectorController();

  DateRangePickerController dateRangePickerController =
      DateRangePickerController();

  int? product_id;
  int? supplier_id;
  String qtyInput = "";

  bool isDateRangeMode = false;

  onAddResult(Map? object) {
    if (object != null) {
      dropDownSelectorControllerProducts.reset();
      dropDownSelectorControllerUsers.reset();
      setState(() {
        qtyInput = "";
      });
    }
  }

  reset() {
    dropDownSelectorControllerProducts.reset();
    dropDownSelectorControllerUsers.reset();
    clearDateSelects();
    widget.onClickFilter();
  }

  clearDateSelects() {
    setState(() {
      dateRangePickerController.selectedRange = null;
      dateRangePickerController.selectedDate = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filter Stocks",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("By Products:"),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                child: DropDownSelectorProducts(
                  apiCall: widget.apiCall,
                  controller: dropDownSelectorControllerProducts,
                  multiSelectMode: true,
                  onSelected: (List? products) {
                    if (products == null || products.isEmpty) {
                      widget.filter.remove('in', 'product_id');
                    } else {
                      widget.filter.setIn(
                          'product_id', products.map((e) => e['id']).toList());
                    }

                    widget.onFilterChange(widget.filter);

                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("By Users:"),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                child: DropDownSelectorUsers(
                  apiCall: widget.apiCall,
                  controller: dropDownSelectorControllerUsers,
                  multiSelectMode: true,
                  onSelected: (List? suppliers) {
                    if (suppliers == null || suppliers.isEmpty) {
                      widget.filter.remove('in', 'ref_id');
                    } else {
                      widget.filter.setIn(
                          'ref_id', suppliers.map((e) => e['id']).toList());
                    }

                    widget.onFilterChange(widget.filter);

                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Date Range:",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Checkbox(
                        value: isDateRangeMode,
                        onChanged: (value) {
                          setState(() {
                            isDateRangeMode = value as bool;

                            if (isDateRangeMode) {
                              dateRangePickerController.selectedDate = null;
                            } else {
                              dateRangePickerController.selectedRange = null;
                            }
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              TextButton(
                onPressed: dateRangePickerController.selectedDate != null ||
                        dateRangePickerController.selectedRange != null
                    ? () {
                        clearDateSelects();
                      }
                    : null,
                child: const Text(
                  "Clear",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                SfDateRangePicker(
                  controller: dateRangePickerController,
                  onSelectionChanged: (
                    DateRangePickerSelectionChangedArgs args,
                  ) {
                    setState(() {});

                    if (args.value is PickerDateRange) {
                      PickerDateRange range = args.value as PickerDateRange;
                      widget.filter.setDate(
                          colname: 'created_at',
                          dstart: DateFormat('yyyy-MM-dd')
                              .format(range.startDate as DateTime),
                          dend: range.endDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(range.endDate as DateTime)
                              : null);
                    } else if (args.value is DateTime) {
                      widget.filter.setDate(
                        colname: 'created_at',
                        dstart: DateFormat('yyyy-MM-dd')
                            .format(args.value as DateTime),
                      );
                    } else if (args.value == null) {
                      widget.filter.remove('date', 'created_at');
                    }

                    widget.onFilterChange(widget.filter);
                  },
                  allowViewNavigation: true,
                  selectionMode: isDateRangeMode
                      ? DateRangePickerSelectionMode.range
                      : DateRangePickerSelectionMode.single,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                    onPressed: !widget.filter.isEmpty()
                        ? () {
                            widget.onClickFilter();
                            widget.onClose();
                          }
                        : null,
                    child: const Text(
                      "Filter",
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: !widget.filter.isEmpty()
                      ? () {
                          reset();
                        }
                      : null,
                  child: const Text(
                    "Reset",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.onClose();
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.deepOrange),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
