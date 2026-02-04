import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class DeviceStorageService {
  static const String _storageKey = 'added_devices';

  // Simpan device baru
  static Future<void> addDevice(AddedDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final devicesList = await getDevices();

    devicesList.add(device);

    final jsonList = devicesList.map((d) => jsonEncode(d.toJson())).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }

  // Ambil semua device
  static Future<List<AddedDevice>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    return jsonList
        .map((json) => AddedDevice.fromJson(jsonDecode(json)))
        .toList();
  }

  // Hapus device berdasarkan ID
  static Future<void> removeDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final devicesList = await getDevices();

    devicesList.removeWhere((d) => d.id == deviceId);

    final jsonList = devicesList.map((d) => jsonEncode(d.toJson())).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }

  // Bersihkan semua device
  static Future<void> clearAllDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
