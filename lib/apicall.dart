import 'dart:convert';
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
}

class ApiRequest {
  final String path;
  final String method;

  Map<String, String> _headers = {
    "Accept": "application/vnd.api+json",
    "Content-Type": "application/vnd.api+json",
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

  ApiRequest data(String name, String value) {
    _data[name] = value;
    return this;
  }

  Future<Map?> call() async {
    Map? data = await _call();
    return data;
  }

  Future<void> on({required success, required error}) async {
    try {
      Map? data = await _call();
      success(data);
    } catch (e) {
      error(e.toString());
    }
  }

  Future<Map?> _call() async {
    Request request = Request(
        path: path,
        params: this._params,
        headers: this._headers,
        data: this._data);

    http.StreamedResponse? response = await request.call(method);

    if (response == null) {
      throw Exception("Request failed! Unknown error.");
    }

    String str = await response.stream.bytesToString();

    try {
      Map map = json.decode(str);

      if (map["status"] == "success") {
        return map["data"];
      } else if (map["status"] == "error") {
        throw Exception(map["message"]);
      } else {
        throw Exception("Undefinded status!");
      }
    } catch (e) {
      throw Exception("Response can't decode!");
    }
  }
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
    }
  }

  //### GET
  Future<http.StreamedResponse?> makeGet() async {
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

  Uri getRequestUri() {
    return Uri.parse(params.isEmpty
        ? API_URL + path
        : API_URL + path + "?" + Uri(queryParameters: params).query);
  }
}
