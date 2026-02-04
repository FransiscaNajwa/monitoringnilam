import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'main.dart';
import 'dashboard.dart';
import 'network.dart';
import 'cctv.dart';
import 'alerts.dart';
import 'profile.dart';
import 'models/camera_model.dart';
import 'models/device_model.dart';
import 'models/mmt_model.dart';
import 'models/tower_model.dart';
import 'services/api_service.dart';
import 'services/device_storage_service.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ipAddressController;
  late ApiService apiService;
  Timer? _nameDebounce;
  bool _isCheckingName = false;
  String? _nameError;

  String _selectedDeviceType = 'Tower';
  String _selectedLocation = 'Tower 1 - CY2';

  final List<String> deviceTypes = ['Tower', 'CCTV', 'MMT'];

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _nameController = TextEditingController();
    _ipAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameDebounce?.cancel();
    _nameController.dispose();
    _ipAddressController.dispose();
    super.dispose();
  }

  // Location data sesuai dengan tower points dan special locations
  final Map<String, Map<String, dynamic>> locationData = {
    // CY2 Towers
    'Tower 1 - CY2': {'lat': -7.209459, 'lng': 112.724717, 'cy': 'CY2'},
    'Tower 2 - CY2': {'lat': -7.209191, 'lng': 112.725250, 'cy': 'CY2'},
    'Tower 3 - CY2': {'lat': -7.208561, 'lng': 112.724946, 'cy': 'CY2'},
    'Tower 4 - CY2': {'lat': -7.208150, 'lng': 112.724395, 'cy': 'CY2'},
    'Tower 5 - CY2': {'lat': -7.208262, 'lng': 112.724161, 'cy': 'CY2'},
    'Tower 6 - CY2': {'lat': -7.208956, 'lng': 112.724173, 'cy': 'CY2'},
    // CY1 Towers
    'Tower 7 - CY1': {'lat': -7.207690, 'lng': 112.723693, 'cy': 'CY1'},
    'Tower 8 - CY1': {'lat': -7.207567, 'lng': 112.723945, 'cy': 'CY1'},
    'Tower 9 - CY1': {'lat': -7.207156, 'lng': 112.724302, 'cy': 'CY1'},
    'Tower 10 - CY1': {'lat': -7.204341, 'lng': 112.722956, 'cy': 'CY1'},
    'Tower 11 - CY1': {'lat': -7.204080, 'lng': 112.722354, 'cy': 'CY1'},
    'Tower 12A - CY1': {'lat': -7.204228, 'lng': 112.722045, 'cy': 'CY1'},
    'Tower 12 - CY1': {'lat': -7.204460, 'lng': 112.721970, 'cy': 'CY1'},
    'Tower 13 - CY1': {'lat': -7.205410, 'lng': 112.722386, 'cy': 'CY1'},
    'Tower 14 - CY1': {'lat': -7.206786, 'lng': 112.723023, 'cy': 'CY1'},
    'Tower 15 - CY1': {'lat': -7.207566, 'lng': 112.723469, 'cy': 'CY1'},
    'Tower 16 - CY1': {'lat': -7.207342, 'lng': 112.723059, 'cy': 'CY1'},
    'Tower 17 - CY1': {'lat': -7.209240, 'lng': 112.723915, 'cy': 'CY1'},
    // CY3 Towers
    'Tower 18 - CY3': {'lat': -7.210090, 'lng': 112.724321, 'cy': 'CY3'},
    'Tower 19 - CY3': {'lat': -7.210336, 'lng': 112.723639, 'cy': 'CY3'},
    'Tower 20 - CY3': {'lat': -7.210082, 'lng': 112.723303, 'cy': 'CY3'},
    'Tower 21 - CY3': {'lat': -7.209070, 'lng': 112.722914, 'cy': 'CY3'},
    'Tower 22 - CY3': {'lat': -7.208501, 'lng': 112.722942, 'cy': 'CY3'},
    'Tower 23 - CY3': {'lat': -7.208017, 'lng': 112.722195, 'cy': 'CY3'},
    'Tower 24 - CY3': {'lat': -7.207314, 'lng': 112.722005, 'cy': 'CY3'},
    'Tower 25 - CY3': {'lat': -7.207213, 'lng': 112.722232, 'cy': 'CY3'},
    'Tower 26 - CY3': {'lat': -7.207029, 'lng': 112.722613, 'cy': 'CY3'},
    // Special Locations
    'Gate In/Out': {'lat': -7.2099123, 'lng': 112.7244489, 'cy': 'Special'},
    'Parking': {'lat': -7.209907, 'lng': 112.724877, 'cy': 'Special'},
  };

  String _getDeviceNameExample(String deviceType) {
    switch (deviceType) {
      case 'Tower':
        return 'T-CY1-07';
      case 'CCTV':
        return 'Cam-CY1-01';
      case 'MMT':
        return 'MMT-CY1-01';
      default:
        return '';
    }
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'Tower':
        return Icons.router;
      case 'CCTV':
        return Icons.videocam;
      case 'MMT':
        return Icons.table_chart;
      default:
        return Icons.device_unknown;
    }
  }

  void _onNameChanged(String value) {
    _nameDebounce?.cancel();
    _nameDebounce = Timer(const Duration(milliseconds: 450), () {
      _checkNameAvailability(value);
    });
  }

  Future<void> _checkNameAvailability(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      setState(() {
        _nameError = null;
        _isCheckingName = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCheckingName = true;
      _nameError = null;
    });

    try {
      final results = await Future.wait([
        apiService.getAllTowers(),
        apiService.getAllCameras(),
        apiService.getAllMMTs(),
        DeviceStorageService.getDevices(),
      ]);

      final towers = results[0] as List<Tower>;
      final cameras = results[1] as List<Camera>;
      final mmts = results[2] as List<MMT>;
      final addedDevices = results[3] as List<AddedDevice>;

      final existingNames = <String>{
        ...towers.map((t) => t.towerId.toLowerCase()),
        ...cameras.map((c) => c.cameraId.toLowerCase()),
        ...mmts.map((m) => m.mmtId.toLowerCase()),
        ...addedDevices.map((d) => d.name.toLowerCase()),
      };

      final isTaken = existingNames.contains(name.toLowerCase());
      if (!mounted) return;
      setState(() {
        _isCheckingName = false;
        _nameError = isTaken ? 'Nama device sudah dipakai' : null;
      });
      _formKey.currentState?.validate();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingName = false;
      });
    }
  }

  void _submitForm() async {
    await _checkNameAvailability(_nameController.text);
    if (_nameError != null) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final locationInfo = locationData[_selectedLocation];
      final latitude = locationInfo?['lat'] ?? 0.0;
      final longitude = locationInfo?['lng'] ?? 0.0;
      final containerYard = locationInfo?['cy'] ?? '';

      // Auto-fill fields sesuai template
      String deviceId = _nameController.text;
      String status = 'UP';
      String type = 'Fixed';
      int deviceCount = 1;
      String traffic = '0';
      String uptime = '0%';
      String areaType = 'Warehouse';

      // Buat device baru dengan UUID
      final newDevice = AddedDevice(
        id: const Uuid().v4(),
        type: _selectedDeviceType,
        name: deviceId,
        ipAddress: _ipAddressController.text,
        locationName: _selectedLocation,
        latitude: latitude,
        longitude: longitude,
        containerYard: containerYard,
        createdAt: DateTime.now(),
      );

      // Simpan ke storage
      await DeviceStorageService.addDevice(newDevice);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Device Berhasil Ditambahkan!'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Device ID:', deviceId),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tipe Device:', _selectedDeviceType),
                  const SizedBox(height: 8),
                  _buildInfoRow('Lokasi:', _selectedLocation),
                  const SizedBox(height: 8),
                  _buildInfoRow('IP Address:', _ipAddressController.text),
                  const SizedBox(height: 8),
                  _buildInfoRow('Status:', status),
                  const SizedBox(height: 8),
                  _buildInfoRow('Type:', type),
                  const SizedBox(height: 8),
                  _buildInfoRow('Container Yard:', containerYard),
                  if (_selectedDeviceType == 'Tower') ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Device Count:', deviceCount.toString()),
                    const SizedBox(height: 8),
                    _buildInfoRow('Traffic:', traffic),
                    const SizedBox(height: 8),
                    _buildInfoRow('Uptime:', uptime),
                  ],
                  if (_selectedDeviceType == 'CCTV') ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Area Type:', areaType),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('Tambah Device Lagi'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembah ke Dashboard'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedDeviceType = 'Tower';
      _selectedLocation = 'Tower 1 - CY2';
      _nameController.clear();
      _ipAddressController.clear();
      _nameError = null;
      _isCheckingName = false;
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF1976D2),
      child: Row(
        children: [
          const Text(
            'Terminal Nilam',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildHeaderOpenButton(
            '+ Add Device',
            const AddDevicePage(),
            isActive: true,
          ),
          const SizedBox(width: 12),
          _buildHeaderOpenButton('Dashboard', const DashboardPage()),
          const SizedBox(width: 12),
          _buildHeaderOpenButton('Tower', const NetworkPage()),
          const SizedBox(width: 12),
          _buildHeaderOpenButton('CCTV', const CCTVPage()),
          const SizedBox(width: 12),
          _buildHeaderOpenButton('Alerts', const AlertsPage()),
          const SizedBox(width: 12),
          _buildHeaderButton('Logout', () => _showLogoutDialog(context)),
          const SizedBox(width: 12),
          // Profile Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1976D2),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text, VoidCallback onPressed,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderOpenButton(String text, Widget openPage,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => openPage),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout',
            style: TextStyle(color: Colors.black87, fontSize: 20)),
        content: const Text('Apakah Anda yakin ingin logout?',
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tambah Device Baru',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== TIPE DEVICE =====
                        const Text(
                          'Tipe Device',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: DropdownButton<String>(
                            value: _selectedDeviceType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedDeviceType = newValue;
                                  _nameController.clear();
                                  _nameError = null;
                                  _isCheckingName = false;
                                });
                              }
                            },
                            items: deviceTypes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getDeviceIcon(value),
                                      color: const Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== NAMA DEVICE =====
                        const Text(
                          'Nama Device',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          onChanged: _onNameChanged,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama device',
                            helperText:
                                'Contoh: ${_getDeviceNameExample(_selectedDeviceType)}',
                            suffixIcon: _isCheckingName
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : (_nameController.text.isNotEmpty &&
                                        _nameError == null)
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Device tidak boleh kosong';
                            }
                            if (_nameError != null) {
                              return _nameError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ===== IP ADDRESS =====
                        const Text(
                          'IP Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ipAddressController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan IP address',
                            helperText:
                                'Format: xxx.xxx.xxx.xxx (Contoh: 10.2.71.60)',
                            prefixIcon: const Icon(Icons.router),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'IP Address tidak boleh kosong';
                            }
                            final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                            if (!ipRegex.hasMatch(value)) {
                              return 'Format IP Address tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ===== LOKASI (DROPDOWN dari Tower Coordinates) =====
                        const Text(
                          'Lokasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            isExpanded: true,
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedLocation = newValue;
                                });
                              }
                            },
                            items: locationData.keys
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(value)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ===== SUBMIT BUTTON =====
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text(
                                  'Tambah Device',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
