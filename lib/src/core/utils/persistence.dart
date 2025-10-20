import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for persistence using both secure and non-secure storage.
class PersistenceUtils {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Writes a string value securely (for sensitive data).
  static Future<void> writeSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Reads a string value securely (for sensitive data).
  static Future<String?> readSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Deletes a secure value (for sensitive data).
  static Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Deletes all secure values (for sensitive data).
  static Future<void> deleteAllSecure() async {
    await _secureStorage.deleteAll();
  }

  /// Writes a string value non-securely (for non-sensitive data).
  static Future<void> writeString(String key, String value) async {
    final prefs = await _sharedPrefs;
    await prefs.setString(key, value);
  }

  /// Reads a string value non-securely (for non-sensitive data).
  static Future<String?> readString(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getString(key);
  }

  /// Deletes a non-secure value (for non-sensitive data).
  static Future<void> deleteString(String key) async {
    final prefs = await _sharedPrefs;
    await prefs.remove(key);
  }

  /// Deletes all non-secure values (for non-sensitive data).
  static Future<void> deleteAll() async {
    final prefs = await _sharedPrefs;
    await prefs.clear();
  }

  /// Writes a boolean value non-securely.
  static Future<void> writeBool(String key, bool value) async {
    final prefs = await _sharedPrefs;
    await prefs.setBool(key, value);
  }

  /// Reads a boolean value non-securely.
  static Future<bool?> readBool(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getBool(key);
  }

  /// Writes an integer value non-securely.
  static Future<void> writeInt(String key, int value) async {
    final prefs = await _sharedPrefs;
    await prefs.setInt(key, value);
  }

  /// Reads an integer value non-securely.
  static Future<int?> readInt(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getInt(key);
  }

  /// Writes a double value non-securely.
  static Future<void> writeDouble(String key, double value) async {
    final prefs = await _sharedPrefs;
    await prefs.setDouble(key, value);
  }

  /// Reads a double value non-securely.
  static Future<double?> readDouble(String key) async {
    final prefs = await _sharedPrefs;
    return prefs.getDouble(key);
  }
}
