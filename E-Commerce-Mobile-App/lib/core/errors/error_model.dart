class ErrorModel {
  final int status;
  final String errorMessage;


  ErrorModel({required this.status,  required this.errorMessage});

   factory ErrorModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ErrorModel(
        status: json['code'] ?? json['status'] ?? 0,
        errorMessage: json['message'] ?? json['Message'] ?? 'Unknown error',
      );
    } else if (json is String) {
      // Handle HTML/string responses
      return ErrorModel(
        status: 500,
        errorMessage: _extractErrorMessageFromHtml(json),
      );
    } else {
      return ErrorModel(
        status: 500,
        errorMessage: 'Unknown error format',
      );
    }
  }

  static String _extractErrorMessageFromHtml(String html) {
    // Simple extraction of error message from HTML
    final regex = RegExp(r'<title>(.*?)</title>');
    final match = regex.firstMatch(html);
    return match?.group(1) ?? 'Server error';
  }


}
