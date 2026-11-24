import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportfolio_mobile/config.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/models/project.dart';

/// Exception thrown when an API request fails.
///
/// [statusCode] is the HTTP status, or `0` when the server could not be
/// reached at all (no network, wrong `API_BASE_URL`, server not running).
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// A short message for a SnackBar, taken from DRF's error body when it has
  /// one: `{"detail": "..."}` or `{"field": ["..."]}`.
  String get readableMessage {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
        final detail = decoded['detail'];
        if (detail is String) return detail;
        final entry = decoded.entries.first;
        final value = entry.value;
        final text = value is List && value.isNotEmpty ? value.first : value;
        return '${entry.key}: $text';
      }
    } on FormatException {
      // Not JSON (e.g. Django's HTML error page): fall through.
    }
    return message.isEmpty || message.length > 120
        ? 'HTTP $statusCode'
        : message;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
///
/// Reads are public; writes send `Authorization: Token <key>`. Every failure
/// (non-2xx or unreachable server) is thrown as an [ApiException], never
/// returned as `null`, so callers handle errors in one `on ApiException`.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Token $token',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // ---- Projects (Tutorial 10) ----

  Future<List<Project>> getProjects() =>
      _getList('/api/v1/projects/', Project.fromJson);

  Future<Project> createProject(Project project, {required String token}) =>
      _postObject(
        '/api/v1/projects/',
        project.toJson(),
        Project.fromJson,
        token: token,
      );

  // ---- Experiences (Tugas 9) ----

  Future<List<Experience>> getExperiences() =>
      _getList('/api/v1/experiences/', Experience.fromJson);

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) => _postObject(
    '/api/v1/experiences/',
    experience.toJson(),
    Experience.fromJson,
    token: token,
  );

  /// `PATCH /api/v1/experiences/<id>/` with every editable field.
  Future<Experience> updateExperience(
    String id,
    Experience experience, {
    required String token,
  }) async {
    final response = await _send(
      () => _client.patch(
        _uri('/api/v1/experiences/$id/'),
        headers: _authHeaders(token),
        body: jsonEncode(experience.toJson()),
      ),
    );
    return Experience.fromJson(_decodeObject(response));
  }

  Future<void> deleteExperience(String id, {required String token}) => _send(
    () => _client.delete(
      _uri('/api/v1/experiences/$id/'),
      headers: _authHeaders(token),
    ),
  );

  // ---- Auth ----

  Future<String> obtainToken(String username, String password) async {
    final response = await _send(
      () => _client.post(
        _uri('/api/v1/auth/token/'),
        headers: _jsonHeaders,
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    return _decodeObject(response)['token'] as String;
  }

  Future<void> logout({required String token}) => _send(
    () => _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: _authHeaders(token),
    ),
  );

  // ---- Helpers ----

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final response = await _send(
      () => _client.get(
        _uri(path),
        headers: const {'Accept': 'application/json'},
      ),
    );
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<T> _postObject<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic> json) fromJson, {
    required String token,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri(path),
        headers: _authHeaders(token),
        body: jsonEncode(body),
      ),
    );
    return fromJson(_decodeObject(response));
  }

  static Map<String, dynamic> _decodeObject(http.Response response) =>
      jsonDecode(response.body) as Map<String, dynamic>;

  /// Runs [request] and turns both network failures and non-2xx responses
  /// into [ApiException].
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Tidak bisa terhubung ke server (${e.message}).');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
