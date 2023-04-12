import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_suppliers.dart';

class RightMenu extends StatefulWidget {
  final ApiCall apiCall;
  final onClickAdd;
  final onClose;

  List inputValues = [];

  RightMenu({
    required this.apiCall,
    required this.onClickAdd,
    required this.onClose,
  });

  @override
  State<StatefulWidget> createState() => _RightMenuState();
}

class _RightMenuState extends State<RightMenu> {
  final _formKey = GlobalKey<FormState>();

  bool isDoing = false;

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

    setState(() {
      isDoing = false;
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
          Text(
            "Add Stock",
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
                const Text("Product:"),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  child: DropDownSelectorProducts(
                    apiCall: widget.apiCall,
                    controller: dropDownSelectorControllerProducts,
                    multiSelectMode: false,
                    onSelected: (product) {
                      setState(() {
                        product_id = product == null ? null : product['id'];
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Supplier:"),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  child: DropDownSelectorSuppliers(
                    apiCall: widget.apiCall,
                    controller: dropDownSelectorControllerSuppliers,
                    multiSelectMode: false,
                    onSelected: (supplier) {
                      setState(() {
                        supplier_id = supplier == null ? null : supplier['id'];
                      });
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
                  onPressed: !isDoing &&
                          (product_id != null &&
                              supplier_id != null &&
                              (int.tryParse(qtyInput) != null &&
                                  int.tryParse(qtyInput)! > 0))
                      ? () {
                          Map record = {
                            'product_id': product_id,
                            'supplier_id': supplier_id,
                            'qty': int.parse(qtyInput)
                          };

                          setState(() => isDoing = true);

                          widget.onClickAdd(record, this);
                        }
                      : null,
                  child: !isDoing
                      ? const Text(
                          "Add",
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextButton(
                  onPressed: !isDoing
                      ? () {
                          widget.onClose();
                        }
                      : null,
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
