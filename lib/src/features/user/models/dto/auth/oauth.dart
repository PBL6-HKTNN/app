class OAuthDto {
  final String token; // idToken
  final String provider;

  OAuthDto({required this.token, required this.provider});

  factory OAuthDto.fromJson(Map<String, dynamic> json) {
    return OAuthDto(
      token: json['token'] as String,
      provider: json['provider'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'provider': provider};
  }

  @override
  String toString() {
    return 'OAuthDto(token: $token, provider: $provider)';
  }
}
