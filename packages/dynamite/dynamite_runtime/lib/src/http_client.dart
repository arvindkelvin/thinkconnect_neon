import 'dart:convert';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:universal_io/io.dart';

export 'package:cookie_jar/cookie_jar.dart';

extension DynamiteHttpClientResponseBody on HttpClientResponse {
  Future<Uint8List> get bodyBytes async {
    final data = await expand((final element) => element).toList();

    return Uint8List.fromList(data);
  }

  Future<String> get body => transform(utf8.decoder).join();

  Future<dynamic> get jsonBody => transform(utf8.decoder).transform(json.decoder).first;

  Map<String, String> get responseHeaders {
    final responseHeaders = <String, String>{};
    headers.forEach((final name, final values) {
      responseHeaders[name] = values.last;
    });

    return responseHeaders;
  }
}

class DynamiteResponse<T, U> {
  DynamiteResponse(
    this.data,
    this.headers,
  );

  final T data;

  final U headers;

  @override
  String toString() => 'DynamiteResponse(data: $data, headers: $headers)';
}

class DynamiteApiException implements Exception {
  DynamiteApiException(
    this.statusCode,
    this.headers,
    this.body,
  );

  final int statusCode;

  final Map<String, String> headers;

  final String body;

  @override
  String toString() => 'DynamiteApiException(statusCode: $statusCode, headers: $headers, body: $body)';
}

abstract class DynamiteAuthentication {
  String get id;
  Map<String, String> get headers;
}

class DynamiteHttpBasicAuthentication extends DynamiteAuthentication {
  DynamiteHttpBasicAuthentication({
    required this.username,
    required this.password,
  });

  final String username;

  final String password;

  @override
  String get id => 'basic_auth';
  @override
  Map<String, String> get headers => {
        'Authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}',
      };
}

class DynamiteClient {
  DynamiteClient(
    this.baseURL, {
    this.baseHeaders,
    final String? userAgent,
    final HttpClient? httpClient,
    this.cookieJar,
    this.authentications = const [],
  }) : httpClient = (httpClient ?? HttpClient())..userAgent = userAgent;

  final String baseURL;

  final Map<String, String>? baseHeaders;

  final HttpClient httpClient;

  final CookieJar? cookieJar;

  final List<DynamiteAuthentication> authentications;

  Future<HttpClientResponse> doRequest(
    final String method,
    final String path,
    final Map<String, String> headers,
    final Uint8List? body,
  ) async {
    final uri = Uri.parse('$baseURL$path');
    final request = await httpClient.openUrl(method, uri);
    for (final header in {...?baseHeaders, ...headers}.entries) {
      request.headers.add(header.key, header.value);
    }
    if (body != null) {
      request.add(body.toList());
    }
    if (cookieJar != null) {
      request.cookies.addAll(await cookieJar!.loadForRequest(uri));
    }

    final response = await request.close();
    if (cookieJar != null) {
      await cookieJar!.saveFromResponse(uri, response.cookies);
    }

    return response;
  }
}
