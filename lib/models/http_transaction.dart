class HttpTransaction {
  final String id;
  final HttpRequestData request;
  final HttpResponseData? response;
  final DateTime startTime;
  final Duration? duration;

  HttpTransaction({
    required this.id,
    required this.request,
    this.response,
    required this.startTime,
    this.duration,
  });
}

class HttpRequestData {
  final String method;
  final String url;
  final String? body;
  final Map<String, String> headers;

  HttpRequestData({
    required this.method,
    required this.url,
    this.body,
    this.headers = const {},
  });
}

class HttpResponseData {
  final int statusCode;
  final String? body;
  final Map<String, String> headers;
  final DateTime timestamp;

  HttpResponseData({
    required this.statusCode,
    this.body,
    this.headers = const {},
    required this.timestamp,
  });
}
