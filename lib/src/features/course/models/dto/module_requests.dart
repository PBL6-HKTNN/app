class CreateModuleRequest {
  final String title;
  final int order;
  final String courseId;

  const CreateModuleRequest({
    required this.title,
    required this.order,
    required this.courseId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'order': order,
    'courseId': courseId,
  };
}

class UpdateModuleRequest extends CreateModuleRequest {
  const UpdateModuleRequest({
    required super.title,
    required super.order,
    required super.courseId,
  });
}
