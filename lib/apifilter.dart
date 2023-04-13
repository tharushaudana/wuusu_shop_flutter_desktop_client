import 'dart:convert';

class ApiFilter {
  Map filterData = {};

  setIn(String colname, List values) {
    _addFilterAttribute('in');
    filterData['in'][colname] = values;
  }

  setEqual(String colname, value) {
    _addFilterAttribute('equal');
    filterData['equal'][colname] = value.toString();
  }

  setDate({
    required String colname,
    required String dstart,
    String? dend = 'default',
  }) {
    _addFilterAttribute('date');

    if (dend == 'default') {
      filterData['date'][colname] = [dstart];
    } else {
      filterData['date'][colname] = [dstart, dend];
    }
  }

  dynamic get(String attr, String colname) {
    return filterData[attr][colname];
  }

  bool isEmpty() {
    return filterData.isEmpty;
  }

  String toJsonStr() {
    return json.encode(filterData);
  }

  remove(String attr, String colname) {
    if (filterData.isNotEmpty &&
        filterData.containsKey(attr) &&
        filterData[attr][colname] != null) {
      Map map = filterData[attr];

      map.remove(colname);

      if (map.isNotEmpty) {
        filterData[attr] = map;
      } else {
        filterData.remove(attr);
      }
    }
  }

  _addFilterAttribute(String name) {
    if (filterData[name] is Map) return;
    filterData[name] = {};
  }
}
