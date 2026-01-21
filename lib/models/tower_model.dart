class Tower {
  final int id;
  final String towerId;
  final String location;
  final String ipAddress;
  final int deviceCount;
  final String status;
  final int traffic;
  final int uptime;
  final String containerYard;
  final String createdAt;

  Tower({
    required this.id,
    required this.towerId,
    required this.location,
    required this.ipAddress,
    required this.deviceCount,
    required this.status,
    required this.traffic,
    required this.uptime,
    required this.containerYard,
    required this.createdAt,
  });

  factory Tower.fromJson(Map<String, dynamic> json) {
    return Tower(
      id: json['id'] ?? 0,
      towerId: json['tower_id'] ?? '',
      location: json['location'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      deviceCount: json['device_count'] ?? 0,
      status: json['status'] ?? 'Unknown',
      traffic: json['traffic'] ?? 0,
      uptime: json['uptime'] ?? 0,
      containerYard: json['container_yard'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tower_id': towerId,
      'location': location,
      'ip_address': ipAddress,
      'device_count': deviceCount,
      'status': status,
      'traffic': traffic,
      'uptime': uptime,
      'container_yard': containerYard,
      'created_at': createdAt,
    };
  }
}
