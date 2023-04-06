import 'package:flutter/material.dart';

class TabProducts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TabProductsState();
}

class _TabProductsState extends State<TabProducts> {
  @override
  Widget build(Object context) {
    print("object");
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: (value) => {},
                    //initialValue: email
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        hintText: 'Search...'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    print("click refresh");
                  },
                  icon: Icon(Icons.refresh),
                  color: Colors.blue,
                )
              ],
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: 10),
              width: double.infinity,
              height: double.infinity,
              child: Text("sdsd"),
            ))
          ],
        ));
  }
}
