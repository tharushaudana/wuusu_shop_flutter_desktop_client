import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

final String API_URL = "https://indev.ctec.lk/wuusu_shop_ctec/public/api";

class ApiCall {
  String? _token = null;

  ApiCall() {}

  setToken(String token) {
    this._token = token;
  }

  ApiRequest get(String path) {
    return ApiRequest(path: path, method: "GET", token: _token);
  }

  ApiRequest post(String path) {
    return ApiRequest(path: path, method: "POST", token: _token);
  }

  ApiRequest patch(String path) {
    return ApiRequest(path: path, method: "PATCH", token: _token);
  }

  ApiRequest delete(String path) {
    return ApiRequest(path: path, method: "DELETE", token: _token);
  }
}

class ApiRequest {
  final String path;
  final String method;

  Map<String, String> _headers = {
    "Accept": "application/vnd.api+json",
    //"Content-Type": "application/vnd.api+json",
  };

  Map<String, String> _params = {};

  Map<String, String> _data = {};

  ApiRequest({required this.path, required this.method, token}) {
    if (token != null) {
      _headers["Authorization"] = 'Bearer $token';
    }
  }

  ApiRequest param(String name, dynamic value) {
    _params[name] = value.toString();
    return this;
  }

  ApiRequest data(String name, dynamic value) {
    if (value is String) {
      _data[name] = value;
      return this;
    } else if (value is Map) {
      Map map = value;
      map.forEach((mkey, mvalue) => _data[mkey] = mvalue.toString());
      return this;
    }

    return this;
  }

  ApiRequest object(Map map) {
    map.forEach((mkey, mvalue) => _data[mkey] = mvalue.toString());
    return this;
  }

  /*Future<Map?> call() async {
    Map? data = await _call();
    return data;
  }*/

  Future<Map?> call() async {
    http.StreamedResponse? response = await _call();

    String str = await response!.stream.bytesToString();

    //print(str);

    Map jmap = {};

    try {
      jmap = json.decode(str);
    } catch (e) {
      throw ApiException("Invalid response. Can't decode!");
    }

    if (jmap["status"] == "success") {
      return jmap["data"];
    } else if (jmap["status"] == "error") {
      Map? errors = jmap["errors"];

      if (errors == null) throw ApiException(jmap["message"]);

      throw ApiException(errors[errors.keys.first][0]
          .toString()); //### throw first error of errors.
    } else {
      throw ApiException("Invalid response. Can't find expected status!");
    }
  }

  Future<Uint8List?> callForBytes() async {
    http.StreamedResponse? response = await _call();
    return response!.stream.toBytes();
  }

  Future<http.StreamedResponse?> _call() async {
    Request request = Request(
        path: path,
        params: this._params,
        headers: this._headers,
        data: this._data);

    http.StreamedResponse? response = await request.call(method);

    if (response == null) {
      throw ApiException("Request failed. Unknown error!");
    }

    return response;
  }

  /*Future<Map?> _call() async {
    Request request = Request(
        path: path,
        params: this._params,
        headers: this._headers,
        data: this._data);

    http.StreamedResponse? response = await request.call(method);

    if (response == null) {
      throw ApiException("Request failed. Unknown error!");
    }

    String str = await response.stream.bytesToString();

    //print(str);

    Map jmap = {};

    try {
      jmap = json.decode(str);
    } catch (e) {
      throw ApiException("Invalid response. Can't decode!");
    }

    if (jmap["status"] == "success") {
      return jmap["data"];
    } else if (jmap["status"] == "error") {
      Map? errors = jmap["errors"];

      if (errors == null) throw ApiException(jmap["message"]);

      throw ApiException(errors[errors.keys.first][0]
          .toString()); //### throw first error of errors.
    } else {
      throw ApiException("Invalid response. Can't find expected status!");
    }
  }*/
}

class Request {
  final String path;
  final Map<String, String> params;
  final Map<String, String> headers;
  final Map<String, String> data;

  Request(
      {required this.path,
      required this.params,
      required this.headers,
      required this.data});

  Future<http.StreamedResponse?> call(method) async {
    switch (method) {
      case "GET":
        return this.makeGet();
      case "POST":
        return this.makePost();
      case "PATCH":
        return this.makePatch();
      case "DELETE":
        return this.makeDelete();
    }
  }

  //### GET
  Future<http.StreamedResponse?> makeGet() async {
    headers['Content-Type'] = 'application/vnd.api+json';

    try {
      var request = http.Request('GET', getRequestUri());

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      return null;
    }
  }

  //### POST
  Future<http.StreamedResponse?> makePost() async {
    headers['Content-Type'] = 'application/vnd.api+json';

    try {
      var request = http.MultipartRequest('POST', getRequestUri());

      request.fields.addAll(data);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      return null;
    }
  }

  //### PATCH
  Future<http.StreamedResponse?> makePatch() async {
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    try {
      var request = http.Request('PATCH', getRequestUri());

      request.bodyFields = data;

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      return null;
    }
  }

  //### DELETE
  Future<http.StreamedResponse?> makeDelete() async {
    //headers['Content-Type'] = 'application/vnd.api+json'; //### using this without passing data, will come error from server

    try {
      var request = http.Request('DELETE', getRequestUri());

      //request.bodyFields = data;

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response;
    } catch (e) {
      return null;
    }
  }

  Uri getRequestUri() {
    return Uri.parse(params.isEmpty
        ? API_URL + path
        : API_URL + path + "?" + Uri(queryParameters: params).query);
  }
}

class ApiException implements Exception {
  String msg;

  ApiException(this.msg) {}

  @override
  String toString() {
    return msg;
  }
}
