import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/models/project.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

/// Unit test ApiClient dan model JSON dengan MockClient: URL, method, header,
/// body yang dikirim, dan cara error dilempar.
void main() {
  late http.Request last;
  ApiClient clientReturning(http.Response response) => ApiClient(
    baseUrl: 'http://test',
    client: MockClient((request) async {
      last = request;
      return response;
    }),
  );

  const experienceJson = {
    'id': 'exp-1',
    'title': 'Asisten Dosen',
    'description': 'PBP',
    'category': 'research',
    'started_at': '2026-09-01T03:00:00Z',
    'ended_at': '2026-12-31T00:00:00Z',
    'is_ongoing': false,
  };

  group('Experience JSON', () {
    test('fromJson memetakan snake_case dan tanggal', () {
      final e = Experience.fromJson(experienceJson);
      expect(e.id, 'exp-1');
      expect(e.categoryLabel, 'Research');
      expect(e.startedAt, DateTime.utc(2026, 9, 1, 3));
      expect(e.endedAt, DateTime.utc(2026, 12, 31));
      expect(e.isOngoing, isFalse);
      expect(formatDate(e.endedAt!), '31/12/2026');
    });

    test('category kosong memakai default model Django', () {
      final e = Experience.fromJson({
        'title': 'T',
        'description': 'D',
        'ended_at': null,
      });
      expect(e.category, 'full-time');
      expect(e.isOngoing, isTrue);
    });

    test(
      'toJson tidak mengirim id/started_at tapi tetap mengirim ended_at null',
      () {
        final json = Experience.fromJson({...experienceJson, 'ended_at': null})
            .toJson();
        expect(json, {
          'title': 'Asisten Dosen',
          'description': 'PBP',
          'category': 'research',
          'ended_at': null,
        });
      },
    );

    test('Project toJson memakai snake_case tanpa id', () {
      const project = Project(
        id: 'p',
        title: 'T',
        description: 'D',
        techStack: 'Dart',
        projectUrl: 'https://x.dev',
      );
      expect(project.toJson(), {
        'title': 'T',
        'description': 'D',
        'tech_stack': 'Dart',
        'project_url': 'https://x.dev',
        'project_image_url': '',
      });
    });
  });

  group('ApiClient experiences', () {
    test('GET publik tanpa header Authorization', () async {
      final api = clientReturning(
        http.Response(jsonEncode([experienceJson]), 200),
      );
      final list = await api.getExperiences();
      expect(list.single.title, 'Asisten Dosen');
      expect(last.method, 'GET');
      expect(last.url.toString(), 'http://test/api/v1/experiences/');
      expect(last.headers.containsKey('Authorization'), isFalse);
    });

    test('POST mengirim token dan body JSON', () async {
      final api = clientReturning(
        http.Response(jsonEncode(experienceJson), 201),
      );
      final created = await api.createExperience(
        Experience(
          title: 'Asisten Dosen',
          description: 'PBP',
          category: 'research',
          endedAt: DateTime.utc(2026, 12, 31),
        ),
        token: 'abc',
      );
      expect(created.id, 'exp-1');
      expect(last.method, 'POST');
      expect(last.headers['Authorization'], 'Token abc');
      expect(last.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(last.body), {
        'title': 'Asisten Dosen',
        'description': 'PBP',
        'category': 'research',
        'ended_at': '2026-12-31T00:00:00.000Z',
      });
    });

    test('PATCH dan DELETE memakai URL detail', () async {
      var api = clientReturning(http.Response(jsonEncode(experienceJson), 200));
      await api.updateExperience(
        'exp-1',
        const Experience(title: 'Baru', description: 'PBP'),
        token: 'abc',
      );
      expect(last.method, 'PATCH');
      expect(last.url.path, '/api/v1/experiences/exp-1/');
      expect(jsonDecode(last.body)['title'], 'Baru');

      api = clientReturning(http.Response('', 204));
      await api.deleteExperience('exp-1', token: 'abc');
      expect(last.method, 'DELETE');
      expect(last.url.path, '/api/v1/experiences/exp-1/');
      expect(last.headers['Authorization'], 'Token abc');
    });
  });

  group('ApiException', () {
    test('respons non-2xx dilempar, bukan dikembalikan null', () async {
      final api = clientReturning(
        http.Response('{"detail":"Invalid token."}', 401),
      );
      await expectLater(
        api.deleteExperience('x', token: 'old'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.readableMessage, 'readable', 'Invalid token.'),
        ),
      );
    });

    test('error validasi DRF diringkas jadi satu kalimat', () {
      const e = ApiException(
        400,
        '{"ended_at":["End date cannot be before."]}',
      );
      expect(e.readableMessage, 'ended_at: End date cannot be before.');
      expect(
        const ApiException(500, '<html>...</html>').readableMessage,
        '<html>...</html>',
      );
      expect(ApiException(500, 'x' * 200).readableMessage, 'HTTP 500');
    });

    test('server tidak bisa dihubungi menjadi ApiException(0)', () async {
      final api = ApiClient(
        baseUrl: 'http://test',
        client: MockClient((_) => throw http.ClientException('refused')),
      );
      await expectLater(
        api.getExperiences(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 0)),
      );
    });

    test('obtainToken mengembalikan token dari body', () async {
      final api = clientReturning(http.Response('{"token":"abc"}', 200));
      expect(await api.obtainToken('owner', 'secret'), 'abc');
      expect(jsonDecode(last.body), {
        'username': 'owner',
        'password': 'secret',
      });
    });
  });
}
