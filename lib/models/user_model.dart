class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String tanggalLahir;
  final String tinggiBadan;
  final String beratBadan;
  final String golonganDarah;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    this.tanggalLahir = '',
    this.tinggiBadan = '',
    this.beratBadan = '',
    this.golonganDarah = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      tanggalLahir: map['tanggalLahir'] ?? '',
      tinggiBadan: map['tinggiBadan'] ?? '',
      beratBadan: map['beratBadan'] ?? '',
      golonganDarah: map['golonganDarah'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'tanggalLahir': tanggalLahir,
      'tinggiBadan': tinggiBadan,
      'beratBadan': beratBadan,
      'golonganDarah': golonganDarah,
    };
  }
}
