class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://pam-2026-p7-ifs23024.fluxy.sbs:8080';  // ← hapus / di akhir

  static const String plants = '/plants';
  static String plantById(String id) => '/plants/$id';

  static const String spaceObjects = '/space-objects';
  static String spaceObjectById(String id) => '/space-objects/$id';
}