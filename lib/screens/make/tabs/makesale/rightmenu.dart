import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/controller.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselector_products.dart';

class RightMenu extends StatefulWidget {
  final ApiCall apiCall;
  final onClickAdd;

  RightMenu({
    required this.apiCall,
    required this.onClickAdd,
  });

  @override
  State<StatefulWidget> createState() => _RightMenuState();
}

class _RightMenuState extends State<RightMenu> {
  DropDownSelectorController dropDownSelectorControllerProducts =
      DropDownSelectorController();

  Map? product;
  String qtyInput = "";
  String discountInput = "";

  clear() {
    setState(() {
      product = null;
      qtyInput = "";
      discountInput = "";
    });

    dropDownSelectorControllerProducts.reset();
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
            "Add Item",
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
                    onSelected: (mproduct) {
                      setState(() {
                        product = mproduct;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
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
                    errorText: qtyInput.isEmpty
                        ? null
                        : int.tryParse(qtyInput) == null
                            ? "invalid value!"
                            : int.tryParse(qtyInput)! <= 0
                                ? "quantity must be more than 0"
                                : null,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) => setState(() {
                    discountInput = value;
                  }),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: discountInput,
                      selection: TextSelection.fromPosition(
                        TextPosition(
                          offset: discountInput.length,
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
                    hintText: 'Enter Discount here',
                    labelText: 'Discount',
                    errorText: discountInput.isEmpty
                        ? null
                        : double.tryParse(discountInput) == null
                            ? "invalid value!"
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
                  onPressed: product == null ||
                          int.tryParse(qtyInput) == null ||
                          int.tryParse(qtyInput) == 0 ||
                          (discountInput.trim().isNotEmpty &&
                              double.tryParse(discountInput) == null)
                      ? null
                      : () {
                          Map item = {
                            'product': product,
                            'qty': int.parse(qtyInput),
                            'discount': discountInput.isEmpty
                                ? 0
                                : double.parse(discountInput)
                          };

                          widget.onClickAdd(item);

                          clear();
                        },
                  child: Text(
                    "Add",
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
