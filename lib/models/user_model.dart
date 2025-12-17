class UserModel {
  final String id;
  final String email;
  final String nama;
  final String username;
  final String bio;
  final String alamat;
  final String noTelp;
  final String fotoProfilUrl;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.username,
    required this.bio,
    required this.alamat,
    required this.noTelp,
    required this.fotoProfilUrl,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'],
      email: map['email'],
      nama: map['nama'],
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      alamat: map['alamat'] ?? '',
      noTelp: map['no_telp'] ?? '',
      fotoProfilUrl: map['foto_profil_url'] ?? '',
      role: map['role'] ?? 'pembeli',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'nama': nama,
      'username': username,
      'bio': bio,
      'alamat': alamat,
      'no_telp': noTelp,
      'foto_profil_url': fotoProfilUrl,
    };
  }

  void operator [](String other) {}
}
