class GoogleOAuthDto {
  final String idToken;
  final String accessToken;
  final String? serverAuthCode;
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleOAuthDto({
    required this.idToken,
    required this.accessToken,
    this.serverAuthCode,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'idToken': idToken,
    'accessToken': accessToken,
    'serverAuthCode': serverAuthCode,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };

  factory GoogleOAuthDto.fromJson(Map<String, dynamic> json) => GoogleOAuthDto(
    idToken: json['idToken'],
    accessToken: json['accessToken'],
    serverAuthCode: json['serverAuthCode'],
    email: json['email'],
    displayName: json['displayName'],
    photoUrl: json['photoUrl'],
  );
}
