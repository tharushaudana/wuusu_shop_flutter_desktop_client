import 'dart:convert';

class ApiFilter {
  Map filterData = {};

  setIn(String colname, List values) {
    _addFilterAttribute('in', false);
    filterData['in'][colname] = values;
  }

  setEqual(String colname, value) {
    _addFilterAttribute('equal', false);
    filterData['equal'][colname] = value.toString();
  }

  setLike(String colname, value) {
    _addFilterAttribute('like', false);
    filterData['like'][colname] = value.toString();
  }

  setDate({
    required String colname,
    required String dstart,
    String? dend = 'default',
  }) {
    _addFilterAttribute('date', false);

    if (dend == 'default') {
      filterData['date'][colname] = [dstart];
    } else {
      filterData['date'][colname] = [dstart, dend];
    }
  }

  addDatePast(String colname) {
    _addFilterAttribute('datepast', true);
    (filterData['datepast'] as List).add(colname);
  }

  addDateNotPast(String colname) {
    _addFilterAttribute('datenotpast', true);
    (filterData['datenotpast'] as List).add(colname);
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
    /*if (filterData.isNotEmpty &&
        filterData.containsKey(attr) &&
        filterData[attr][colname] != null) {
      Map map = filterData[attr];

      map.remove(colname);

      if (map.isNotEmpty) {
        filterData[attr] = map;
      } else {
        filterData.remove(attr);
      }
    }*/

    if (filterData.isNotEmpty && filterData.containsKey(attr)) {
      if (filterData[attr] is Map && filterData[attr][colname] != null) {
        Map map = filterData[attr];

        map.remove(colname);

        if (map.isNotEmpty) {
          filterData[attr] = map;
        } else {
          filterData.remove(attr);
        }
      } else if (filterData[attr] is List) {
        List list = filterData[attr];

        list.remove(colname);

        if (list.isNotEmpty) {
          filterData[attr] = list;
        } else {
          filterData.remove(attr);
        }
      }
    }
  }

  _addFilterAttribute(String name, bool isList) {
    if (isList) {
      if (filterData[name] is List) return;
      filterData[name] = [];
    } else {
      if (filterData[name] is Map) return;
      filterData[name] = {};
    }
  }
}
