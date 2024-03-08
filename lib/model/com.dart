class Com {
  final int id;
  final String name;
  final String lip;
  final int lport;
  final int port;
  final String key;

  Com({
    required this.id,
    required this.name,
    required this.lip,
    required this.lport,
    required this.port,
    required this.key
  });

  factory Com.fromSqflite(Map<String, dynamic> com) =>
      Com(
        id: com['id']?.toInt() ?? 0,
        name: com['name'] ?? '',
        lip: com['lip'] ?? '',
        lport: com['lport'] ?? 0,
        port: com['port'] ?? 0,
        key: com['key'] ?? '0',
      );
}