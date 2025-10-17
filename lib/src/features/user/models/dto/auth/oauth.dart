class OAuthDto {
  final String token; // idToken

  OAuthDto({required this.token});

  factory OAuthDto.fromJson(Map<String, dynamic> json) {
    return OAuthDto(token: json['token'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'token': token};
  }

  @override
  String toString() {
    return 'OAuthDto(token: $token)';
  }
}
