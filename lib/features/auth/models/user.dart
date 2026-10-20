// M1 Registrasi dan Login (FR-AUTH)
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.username = '',
    this.email = '',
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  final String id;
  final String name;
  final String username;
  final String email;
  final String? avatarUrl;

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'avatar_url': avatarUrl,
      };
}
