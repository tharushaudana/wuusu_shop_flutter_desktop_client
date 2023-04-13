import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/apifilter.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_suppliers.dart';

class FilterMenu extends StatefulWidget {
  final ApiCall apiCall;
  final ApiFilter filter;
  final onFilterChange;
  final onClose;

  FilterMenu({
    required this.apiCall,
    required this.filter,
    required this.onFilterChange,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  DropDownSelectorController dropDownSelectorControllerProducts =
      DropDownSelectorController();
  DropDownSelectorController dropDownSelectorControllerSuppliers =
      DropDownSelectorController();

  int? product_id;
  int? supplier_id;
  String qtyInput = "";

  onAddResult(Map? object) {
    if (object != null) {
      dropDownSelectorControllerProducts.reset();
      dropDownSelectorControllerSuppliers.reset();
      setState(() {
        qtyInput = "";
      });
    }
  }

  reset() {}

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
          Text(
            "Filter Stocks",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Column(
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
                    onSelected: (List products) {
                      if (products.isEmpty) {
                        widget.filter.remove('in', 'product_id');
                      } else {
                        widget.filter.setIn('product_id',
                            products.map((e) => e['id']).toList());
                      }

                      widget.onFilterChange(widget.filter);
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("By Suppliers:"),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  child: DropDownSelectorSuppliers(
                    apiCall: widget.apiCall,
                    controller: dropDownSelectorControllerSuppliers,
                    multiSelectMode: true,
                    onSelected: (List suppliers) {
                      if (suppliers.isEmpty) {
                        widget.filter.remove('in', 'supplier_id');
                      } else {
                        widget.filter.setIn('supplier_id',
                            suppliers.map((e) => e['id']).toList());
                      }

                      widget.onFilterChange(widget.filter);
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) => setState(() {
                    qtyInput = value;
                  }),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: qtyInput,
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          offset: qtyInput.length,
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
                    hintText: 'Enter Quantity here',
                    labelText: 'Quantity',
                    errorText: qtyInput.length == 0
                        ? null
                        : int.tryParse(qtyInput) == null
                            ? "invalid value!"
                            : int.tryParse(qtyInput)! <= 0
                                ? "quantity must be more than 0"
                                : null,
                  ),
                ),
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
                    onPressed: () {},
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
                  onPressed: () {
                    Alert.showConfirm(
                      "Reset Filter",
                      "Are you sure?",
                      context,
                      (menu) {
                        menu.close();
                        reset();
                      },
                    );
                  },
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
