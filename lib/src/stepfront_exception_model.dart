class ZTExceptionModel implements Exception {
  final int? code;
  final String? message;
  final String? type;
  final String? title;
  final int? status;
  final String? detail;

  ZTExceptionModel({
    this.code,
    this.message,
    this.type,
    this.title,
    this.status,
    this.detail,
  });
  static ZTExceptionModel fromString(String exceptionString) {
    // Remove curly braces and split the string by commas
    List<String> parts =
        exceptionString.replaceAll('{', '').replaceAll('}', '').split(', ');

    // Create a new map and populate it with the key-value pairs from the string
    Map<String, dynamic> exceptionData = {};
    for (String part in parts) {
      List<String> keyValue = part.split(': ');
      String key = keyValue[0].trim();
      dynamic value = keyValue[1].trim();
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
      exceptionData[key] = value;
    }

    /// print("TEST123: ${exceptionData.toString()}");
    print("TEST123: ${exceptionData["status"]}");
    return ZTExceptionModel(
      code: exceptionData["code"] ?? 0,
      message: exceptionData["message"] ?? "",
      type: exceptionData["type"] ?? "Exception",
      title: exceptionData["title"] ?? "Title",
      status: int.parse(exceptionData["status"] ?? 0),
      detail: exceptionData["detail"] ?? "Couldn't get details from back-end",
    );
  }

  @override
  String toString() => '$type: $title (status $status) - $detail';
}
