import '../models/tower_model.dart';

// Helper untuk cek status DOWN/WARNING
// Tidak ada lagi hardcoded tower numbers - semua data langsung dari database
bool isDownStatus(String status) {
  final normalized = status.toUpperCase();
  return normalized == 'DOWN' || normalized == 'WARNING';
}

// Fungsi ini sekarang hanya return towers tanpa modifikasi
// Semua status langsung dari database
List<Tower> applyForcedTowerStatus(List<Tower> towers) {
  return towers;
}
