import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  final storage = FlutterSecureStorage();

  save(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  delete(String key) async {
    return await storage.delete(key: key);
  }
}
