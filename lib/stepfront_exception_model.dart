class SFExceptionModel implements Exception {
  final String type;
  final String title;
  final int status;
  final String detail;

  SFExceptionModel({
    required this.type,
    required this.title,
    required this.status,
    required this.detail,
  });
  static SFExceptionModel fromString(String exceptionString) {
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
    return SFExceptionModel(
      type: exceptionData["type"] ?? "Exception",
      title: exceptionData["title"] ?? "Title",
      status: int.parse(exceptionData["status"] ?? 0),
      detail: exceptionData["detail"] ?? "Couldn't get details from back-end",
    );
  }

  @override
  String toString() => '$type: $title (status $status) - $detail';
}
