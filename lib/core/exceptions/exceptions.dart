class CustomException implements Exception {
  final String type;
  final int status;
  final String title;
  final String detail;

  CustomException({
    required this.type,
    required this.status,
    required this.title,
    required this.detail,
  });

  factory CustomException.fromJson(Map<String, dynamic> json) {
    return CustomException(
      type: json['type'] as String,
      status: json['status'] as int,
      title: json['title'] as String,
      detail: json['detail'] as String,
    );
  }

  @override
  String toString() => detail;

  Map<String, dynamic> toJson() => {
        'type': type,
        'status': status,
        'title': title,
        'detail': detail,
      };
}