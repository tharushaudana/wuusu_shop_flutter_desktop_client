import 'dart:convert';
import 'package:http/http.dart' as http;

final String API_URL = "https://indev.ctec.lk/wuusu_shop_ctec/public/api";

class ApiCall {
  ApiCall() {}

  ApiRequest post(String path) {
    return ApiRequest(path: path, method: "POST");
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

  ApiRequest({required this.path, required this.method});

  ApiRequest param(String name, String value) {
    this._params[name] = value;
    return this;
  }

  ApiRequest data(String name, String value) {
    this._data[name] = value;
    return this;
  }

  call({required success, required error}) {
    Request request = Request(
        path: path,
        params: this._params,
        headers: this._headers,
        data: this._data);

    request.call(method, (http.StreamedResponse? response) async {
      if (response == null) {
        error("Request failed! Unknown error.");
        return;
      }

      String str = await response.stream.bytesToString();

      try {
        Map map = json.decode(str);

        if (map["status"] == "success") {
          success(map["data"]);
        } else if (map["status"] == "error") {
          error(map["message"]);
        } else {
          error("Undefinded status!");
        }
      } catch (e) {
        error("Response can't decode!");
      }
    });
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

  Future<void> call(method, cb) async {
    switch (method) {
      case "POST":
        this.makePost(cb);
        break;
    }
  }

  //### POST
  Future<void> makePost(cb) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(params.isEmpty
              ? API_URL + path
              : API_URL + path + "?" + Uri(queryParameters: params).query));

      request.fields.addAll(data);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      cb(response);
    } catch (e) {
      cb(null);
    }
  }
}
