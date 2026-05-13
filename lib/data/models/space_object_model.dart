class SpaceObjectModel {
  const SpaceObjectModel({
    this.id,
    required this.nama,
    required this.tipe,
    this.gambar = '',
    this.pathGambar = '',
    required this.deskripsi,
    required this.jarakDariBumi,
    required this.fakta,
  });

  final String? id;
  final String nama;
  final String tipe;
  final String gambar;
  final String pathGambar;
  final String deskripsi;
  final String jarakDariBumi;
  final String fakta;

  factory SpaceObjectModel.fromJson(Map<String, dynamic> json) {
    return SpaceObjectModel(
      id:            json['id']            as String? ?? '',
      nama:          json['nama']          as String? ?? '',
      tipe:          json['tipe']          as String? ?? '',
      gambar:        json['gambar']        as String? ?? '',
      pathGambar:    json['pathGambar']    as String? ?? '',
      deskripsi:     json['deskripsi']     as String? ?? '',
      jarakDariBumi: json['jarakDariBumi'] as String? ?? '',
      fakta:         json['fakta']         as String? ?? '',
    );
  }

  SpaceObjectModel copyWith({
    String? id, String? nama, String? tipe,
    String? gambar, String? pathGambar,
    String? deskripsi, String? jarakDariBumi, String? fakta,
  }) {
    return SpaceObjectModel(
      id:            id            ?? this.id,
      nama:          nama          ?? this.nama,
      tipe:          tipe          ?? this.tipe,
      gambar:        gambar        ?? this.gambar,
      pathGambar:    pathGambar    ?? this.pathGambar,
      deskripsi:     deskripsi     ?? this.deskripsi,
      jarakDariBumi: jarakDariBumi ?? this.jarakDariBumi,
      fakta:         fakta         ?? this.fakta,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SpaceObjectModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SpaceObjectModel(id: $id, nama: $nama, tipe: $tipe)';
}