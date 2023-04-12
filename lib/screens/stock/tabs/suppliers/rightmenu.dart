import 'package:flutter/material.dart';

class RightMenu extends StatefulWidget {
  final List inputData;
  final Map? supplier;
  final onClickAdd;
  final onClickUpdate;
  final onClose;

  List inputValues = [];

  RightMenu({
    required this.inputData,
    required this.supplier,
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
    return supplier == null ? "" : supplier![name];
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
            widget.supplier == null
                ? "Add New Supplier"
                : "Update Supplier #${widget.supplier!['id']}",
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
                : Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView.builder(
                      itemCount: widget.inputValues.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: TextFormField(
                            onChanged: (value) => setState(() {
                              setState(() {
                                widget.inputValues[index] = value;
                                isValidated = _formKey.currentState!.validate();
                              });
                            }),
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: widget.inputValues[index],
                                selection: TextSelection.fromPosition(
                                  TextPosition(
                                    offset: widget.inputValues[index].length,
                                  ),
                                ),
                              ),
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(3.0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(3.0),
                                ),
                              ),
                              label: Text(
                                widget.inputData[index][1],
                                overflow: TextOverflow.ellipsis,
                              ),
                              hintText: '${widget.inputData[index][1]} here...',
                            ),
                            validator: (value) {
                              if (value.toString().trim().isEmpty) {
                                return "this field is required!";
                              }
                              if (widget.inputData[index][2] == 'number' &&
                                  double.tryParse(value.toString()) == null) {
                                return "invalid value!";
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
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
                          Map supplier = {};

                          for (int i = 0; i < widget.inputValues.length; i++) {
                            supplier[widget.inputData[i][0]] =
                                widget.inputValues[i];
                          }

                          if (widget.supplier == null) {
                            setState(() => isDoing = true);
                            widget.onClickAdd(supplier, this);
                          } else {
                            setState(() => isDoing = true);
                            supplier['id'] = widget.supplier!['id'];
                            widget.onClickUpdate(supplier, this);
                          }
                        }
                      : null,
                  child: Text(
                    widget.supplier == null ? "Add" : "Update",
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
