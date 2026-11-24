import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

/// In-memory stand-in for the Django API, served through [MockClient].
///
/// Mirrors the real rules: reads are public, writes need `Token abc`
/// (obtained with password `secret`), and [revokeToken] simulates deleting the
/// token in Django Admin so the next write gets 401.
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? experiences})
    : experiences = experiences ?? [sampleExperience()];

  final List<Map<String, dynamic>> projects = [
    {
      'id': '7a1c0c52-1f1b-4c4e-9a59-2f7a3c0c9b11',
      'title': 'MyPortfolio',
      'description': 'Website portofolio Django',
      'tech_stack': 'Django',
      'project_url': 'https://example.com/',
      'project_image_url': null,
      'star_count': 0,
    },
  ];
  final List<Map<String, dynamic>> experiences;
  final List<http.Request> requests = [];

  /// Set to make every request fail as if the server were down.
  bool offline = false;
  bool _tokenValid = true;
  int _nextId = 1;

  void revokeToken() => _tokenValid = false;

  static Map<String, dynamic> sampleExperience({
    String id = 'exp-1',
    String title = 'Asisten Dosen PBP',
    String? endedAt,
  }) => {
    'id': id,
    'title': title,
    'description': 'Membimbing lab Flutter.',
    'category': 'part-time',
    'started_at': '2026-09-01T03:00:00Z',
    'ended_at': endedAt,
    'is_ongoing': endedAt == null,
  };

  ApiClient client() =>
      ApiClient(baseUrl: 'http://test', client: MockClient(_handle));

  http.Response _json(Object? body, int status) =>
      http.Response(jsonEncode(body), status);

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    if (offline) throw http.ClientException('Connection refused');
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == '/api/v1/projects/') {
      return _json(projects, 200);
    }
    if (method == 'GET' && path == '/api/v1/experiences/') {
      return _json(experiences, 200);
    }
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] != 'secret') {
        return _json({
          'non_field_errors': ['Unable to log in.'],
        }, 400);
      }
      _tokenValid = true;
      return _json({'token': 'abc'}, 200);
    }

    if (!_tokenValid || request.headers['Authorization'] != 'Token abc') {
      return _json({'detail': 'Invalid token.'}, 401);
    }
    if (path == '/api/v1/auth/logout/') {
      _tokenValid = false;
      return http.Response('', 204);
    }
    if (method == 'POST' && path == '/api/v1/projects/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({...body, 'id': 'new-project'}, 201);
    }
    if (method == 'POST' && path == '/api/v1/experiences/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      // Seperti validate_title di Django: tag HTML dibuang dulu.
      final title = (body['title'] as String).replaceAll(RegExp('<[^>]*>'), '');
      if (title.trim().isEmpty) {
        return _json({
          'title': ['Title cannot be empty.'],
        }, 400);
      }
      final created = {
        ...body,
        'id': 'new-${_nextId++}',
        'started_at': DateTime.now().toUtc().toIso8601String(),
        'is_ongoing': body['ended_at'] == null,
      };
      experiences.insert(0, created);
      return _json(created, 201);
    }

    final match = RegExp(r'^/api/v1/experiences/([^/]+)/$').firstMatch(path);
    final index = match == null
        ? -1
        : experiences.indexWhere((e) => e['id'] == match.group(1));
    if (index == -1) return _json({'detail': 'Not found.'}, 404);
    if (method == 'PATCH') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final updated = {
        ...experiences[index],
        ...body,
        'is_ongoing': body['ended_at'] == null,
      };
      experiences[index] = updated;
      return _json(updated, 200);
    }
    if (method == 'DELETE') {
      experiences.removeAt(index);
      return http.Response('', 204);
    }
    return _json({'detail': 'Method not allowed.'}, 405);
  }
}

/// Phone-sized test surface (390 x 844), reset after each test.
void usePhoneScreen() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });
}

/// Scrolls [text] into view, taps the last match, and settles.
Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// Fills the [LoginScreen] fields and submits.
Future<void> logIn(WidgetTester tester, {String password = 'secret'}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    'owner',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}
