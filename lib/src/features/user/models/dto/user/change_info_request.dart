class ChangeInfoRequest {
  final String? bio;
  final String? name;

  ChangeInfoRequest({this.bio, this.name});
  Map<String, dynamic> toJson() {
    return {'bio': bio, 'name': name};
  }
}
