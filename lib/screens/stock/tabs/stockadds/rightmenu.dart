import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/apicall.dart';
import 'package:wuusu_shop_client/dropdowns/dropdownselecter_products.dart';

class RightMenu extends StatefulWidget {
  final ApiCall apiCall;
  final List inputData;
  final Map? material;
  final onClickAdd;
  final onClickUpdate;
  final onClose;

  List inputValues = [];

  RightMenu({
    required this.apiCall,
    required this.inputData,
    required this.material,
    required this.onClickAdd,
    required this.onClickUpdate,
    required this.onClose,
  }) {
    inputValues.clear();
    for (List e in inputData) {
      inputValues.add(getAttrOfCurrentMaterial(e[0]));
    }
  }

  String getAttrOfCurrentMaterial(String name) {
    return material == null ? "" : material![name];
  }

  @override
  State<StatefulWidget> createState() => _RightMenuState();
}

class _RightMenuState extends State<RightMenu> {
  final _formKey = GlobalKey<FormState>();

  bool isValidated = false;
  bool isDoing = false;

  onAddResult(Map? object) {
    if (object != null) {
      setState(() {
        for (int i = 0; i < widget.inputValues.length; i++) {
          widget.inputValues[i] = "";
        }
        isValidated = false;
      });
    }

    setState(() {
      isDoing = false;
    });
  }

  onUpdateResult(Map? object) {
    setState(() {
      isDoing = false;
    });

    if (object != null) widget.onClose();
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
            height: 10,
          ),
          Expanded(
            child: isDoing
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropDownSelectorProducts(
                              apiCall: widget.apiCall,
                              multiSelectMode: false,
                              onSelected: (e) {
                                print(e);
                              },
                            ),
                          ),
                        ],
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
                  onPressed: !isDoing && isValidated
                      ? () {
                          Map material = {};

                          for (int i = 0; i < widget.inputValues.length; i++) {
                            material[widget.inputData[i][0]] =
                                widget.inputValues[i];
                          }

                          if (widget.material == null) {
                            setState(() => isDoing = true);
                            widget.onClickAdd(material, this);
                          } else {
                            setState(() => isDoing = true);
                            material['id'] = widget.material!['id'];
                            widget.onClickUpdate(material, this);
                          }
                        }
                      : null,
                  child: Text(
                    widget.material == null ? "Add" : "Update",
                    overflow: TextOverflow.ellipsis,
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
                    "Cancel",
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
