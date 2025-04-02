import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

String encryptionKey = dotenv.get('ASE_KEY'); // 必须是 16/24/32 字节

String encryptData(String text) {
  final key = encrypt.Key.fromUtf8(encryptionKey);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  return encrypter.encrypt(text, iv: iv).base64;
}

String decryptData(String encryptedText) {
  final key = encrypt.Key.fromUtf8(encryptionKey);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  return encrypter.decrypt64(encryptedText, iv: iv);
}

Future<bool> saveSecureData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  String encryptedValue = encryptData(value);
  return await prefs.setString(key, encryptedValue);
}

Future<String?> loadSecureData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  String? encryptedValue = prefs.getString(key);
  if (encryptedValue == null) return null;
  return decryptData(encryptedValue);
}
