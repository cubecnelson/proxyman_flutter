class HttpTransaction {
  final String id;
  HttpRequestData request;
  HttpResponseData? response;
  final DateTime startTime;
  final Duration? duration;

  HttpTransaction({
    required this.id,
    required this.request,
    this.response,
    required this.startTime,
    this.duration,
  });

  HttpTransaction copyWith({
    String? id,
    HttpRequestData? request,
    HttpResponseData? response,
    DateTime? startTime,
    Duration? duration,
  }) {
    return HttpTransaction(
      id: id ?? this.id,
      request: request ?? this.request,
      response: response ?? this.response,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}

class HttpRequestData {
  String method;
  String url;
  String? body;
  Map<String, String> headers;

  HttpRequestData({
    required this.method,
    required this.url,
    this.body,
    this.headers = const {},
  });

  HttpRequestData copyWith({
    String? method,
    String? url,
    String? body,
    Map<String, String>? headers,
  }) {
    return HttpRequestData(
      method: method ?? this.method,
      url: url ?? this.url,
      body: body ?? this.body,
      headers: headers ?? Map.from(this.headers),
    );
  }
}

class HttpResponseData {
  int statusCode;
  String? body;
  Map<String, String> headers;
  final DateTime timestamp;

  HttpResponseData({
    required this.statusCode,
    this.body,
    this.headers = const {},
    required this.timestamp,
  });

  HttpResponseData copyWith({
    int? statusCode,
    String? body,
    Map<String, String>? headers,
    DateTime? timestamp,
  }) {
    return HttpResponseData(
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      headers: headers ?? Map.from(this.headers),
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
