import 'package:http/http.dart' as http;

/// Thin wrapper so Repository can be mocked in tests — never import http directly in Blocs/UI.
class AppHttpClient {
  final http.Client _client;
  const AppHttpClient(this._client);
  Future<http.Response> get(Uri url) => _client.get(url);
  Future<http.Response> post(Uri url, {Object? body, Map<String, String>? headers}) => _client.post(url, body: body, headers: headers);
}
