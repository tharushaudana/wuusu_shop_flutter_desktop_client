import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/apifilter.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_customers.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_suppliers.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_users.dart';

class FilterMenu extends StatefulWidget {
  final ApiCall apiCall;
  final ApiFilter filter;
  final onClickFilter;
  final onClose;

  FilterMenu({
    required this.apiCall,
    required this.filter,
    required this.onClickFilter,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  DropDownSelectorController dropDownSelectorControllerCustomers =
      DropDownSelectorController();
  DropDownSelectorController dropDownSelectorControllerUsers =
      DropDownSelectorController();

  DateRangePickerController dateRangePickerController =
      DateRangePickerController();

  String invoiceIdInput = "";
  String titleInput = "";
  String validUntilSelectedValue = "none";

  bool isDateRangeMode = false;

  reset() {
    dropDownSelectorControllerCustomers.reset();
    dropDownSelectorControllerUsers.reset();
    clearDateSelects();
    widget.onClickFilter();
  }

  clearDateSelects() {
    setState(() {
      invoiceIdInput = "";
      titleInput = "";
      validUntilSelectedValue = "none";
      dateRangePickerController.selectedRange = null;
      dateRangePickerController.selectedDate = null;
    });

    widget.filter.remove("equal", "invoice_id");
    widget.filter.remove("like", "title");
    widget.filter.remove('datepast', 'validuntil');
    widget.filter.remove('datenotpast', 'validuntil');
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
            "Filter Quotations",
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
              TextFormField(
                onChanged: (value) => setState(() {
                  invoiceIdInput = value;

                  if (invoiceIdInput.trim().isNotEmpty) {
                    widget.filter.setEqual("invoice_id", invoiceIdInput.trim());

                    titleInput = "";

                    widget.filter.remove("like", "title");
                    widget.filter.remove('in', 'customer_id');
                    widget.filter.remove('in', 'user_id');
                    widget.filter.remove('date', 'created_at');
                  } else {
                    widget.filter.remove("equal", "invoice_id");
                  }
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
                  hintText: 'Enter invoice id here',
                  labelText: 'Invoice ID',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              invoiceIdInput.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          onChanged: (value) => setState(() {
                            titleInput = value;

                            if (titleInput.trim().isNotEmpty) {
                              widget.filter.setLike("title", '%$titleInput%');
                            } else {
                              widget.filter.remove("like", "title");
                            }
                          }),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: titleInput,
                              selection: TextSelection.fromPosition(
                                TextPosition(
                                  offset: titleInput.length,
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
                            hintText: 'Enter title contents here',
                            labelText: 'Title',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("By Customers:"),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          child: DropDownSelectorCustomers(
                            apiCall: widget.apiCall,
                            controller: dropDownSelectorControllerCustomers,
                            multiSelectMode: true,
                            onSelected: (List? products) {
                              if (products == null || products.isEmpty) {
                                widget.filter.remove('in', 'customer_id');
                              } else {
                                widget.filter.setIn('customer_id',
                                    products.map((e) => e['id']).toList());
                              }

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
                                widget.filter.remove('in', 'user_id');
                              } else {
                                widget.filter.setIn('user_id',
                                    suppliers.map((e) => e['id']).toList());
                              }

                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("By ValidUntil:"),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            hint: Text(
                              'Select Item',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: ['none', 'Expired only', 'Not expired only']
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: validUntilSelectedValue,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                validUntilSelectedValue = value as String;
                              });

                              switch (value) {
                                case 'none':
                                  widget.filter
                                      .remove('datepast', 'validuntil');
                                  widget.filter
                                      .remove('datenotpast', 'validuntil');
                                  break;
                                case 'Expired only':
                                  widget.filter
                                      .remove('datenotpast', 'validuntil');
                                  widget.filter.addDatePast('validuntil');
                                  break;
                                case 'Not expired only':
                                  widget.filter
                                      .remove('datepast', 'validuntil');
                                  widget.filter.addDateNotPast('validuntil');
                                  break;
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              height: 40,
                              width: 140,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
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
                                        dateRangePickerController.selectedDate =
                                            null;
                                      } else {
                                        dateRangePickerController
                                            .selectedRange = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        TextButton(
                          onPressed:
                              dateRangePickerController.selectedDate != null ||
                                      dateRangePickerController.selectedRange !=
                                          null
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
                    )
                  : Container(),
            ],
          ),
          Expanded(
            child: invoiceIdInput.isEmpty
                ? ListView(
                    children: [
                      SfDateRangePicker(
                        controller: dateRangePickerController,
                        onSelectionChanged: (
                          DateRangePickerSelectionChangedArgs args,
                        ) {
                          setState(() {});

                          if (args.value is PickerDateRange) {
                            PickerDateRange range =
                                args.value as PickerDateRange;
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
                        },
                        allowViewNavigation: true,
                        selectionMode: isDateRangeMode
                            ? DateRangePickerSelectionMode.range
                            : DateRangePickerSelectionMode.single,
                      )
                    ],
                  )
                : Container(),
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
