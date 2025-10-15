class OAuthDto {
  final String idToken;

  OAuthDto({required this.idToken});

  factory OAuthDto.fromJson(Map<String, dynamic> json) {
    return OAuthDto(idToken: json['idToken'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'idToken': idToken};
  }

  @override
  String toString() {
    return 'OAuthDto(idToken: $idToken)';
  }
}
