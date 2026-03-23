import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:monthly_management/services/edge_function_client.dart';

void main() {
  group('EdgeFunctionClient', () {
    group('error classification', () {
      test('detects 404 function-not-found error', () {
        const err =
            'FunctionException(status: 404, details: {code: NOT_FOUND})';
        expect(EdgeFunctionClient.isFunctionNotFoundError(err), isTrue);
      });

      test('rejects non-404 errors for function-not-found', () {
        const err =
            'FunctionException(status: 500, details: internal_error)';
        expect(EdgeFunctionClient.isFunctionNotFoundError(err), isFalse);
      });

      test('detects auth error from 401', () {
        const err =
            'FunctionException(status: 401, details: unauthorized)';
        expect(EdgeFunctionClient.isAuthError(err), isTrue);
      });

      test('detects auth error from JWT keyword', () {
        const err = 'Error: invalid jwt token';
        expect(EdgeFunctionClient.isAuthError(err), isTrue);
      });

      test('rejects non-auth errors', () {
        const err = 'Some other error happened';
        expect(EdgeFunctionClient.isAuthError(err), isFalse);
      });
    });

    group('buildErrorMessage', () {
      test('returns auth message for 403 JWT error', () {
        const err =
            'FunctionException(status: 403, details: invalid jwt)';
        final msg =
            EdgeFunctionClient.buildErrorMessage(err, hasApiKey: false);
        expect(msg, contains('Sessao expirada'));
      });

      test('returns edge function message with API key for 404', () {
        const err =
            'FunctionException(status: 404, details: {code: NOT_FOUND})';
        final msg =
            EdgeFunctionClient.buildErrorMessage(err, hasApiKey: true);
        expect(msg, contains('Verifique se a Edge Function'));
      });

      test('returns edge function message without API key for 404', () {
        const err =
            'FunctionException(status: 404, details: {code: NOT_FOUND})';
        final msg =
            EdgeFunctionClient.buildErrorMessage(err, hasApiKey: false);
        expect(msg, contains('Adicione uma API key OpenAI'));
      });

      test('returns raw message for generic errors', () {
        const err = 'Quota exceeded';
        final msg =
            EdgeFunctionClient.buildErrorMessage(err, hasApiKey: true);
        expect(msg, 'Quota exceeded');
      });

      test('returns fallback for empty error string', () {
        final msg =
            EdgeFunctionClient.buildErrorMessage('', hasApiKey: true);
        expect(msg, 'Falha ao processar pedido de IA.');
      });
    });

    group('invoke', () {
      test('posts JSON and returns parsed response', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.url.path, contains('/functions/v1/openai-chat'));
          expect(request.headers['Content-Type'], 'application/json');
          expect(request.headers['Authorization'], isNotEmpty);
          return http.Response(
            jsonEncode({'content': 'hello'}),
            200,
          );
        });

        final client = EdgeFunctionClient(httpClient: mockClient);
        final response = await client.invoke({'model': 'gpt-4o-mini'});

        expect(response.status, 200);
        expect((response.data as Map)['content'], 'hello');
      });

      test('returns error data for non-200 response', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'rate limited'}),
            429,
          );
        });

        final client = EdgeFunctionClient(httpClient: mockClient);
        final response = await client.invoke({'model': 'gpt-4o-mini'});

        expect(response.status, 429);
        expect((response.data as Map)['error'], 'rate limited');
      });

      test('handles non-JSON response body gracefully', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final client = EdgeFunctionClient(httpClient: mockClient);
        final response = await client.invoke({'model': 'gpt-4o-mini'});

        expect(response.status, 500);
        expect((response.data as Map)['error'], 'Internal Server Error');
      });

      test('respects configurable timeout', () async {
        final savedTimeout = EdgeFunctionClient.httpTimeout;
        EdgeFunctionClient.httpTimeout = const Duration(milliseconds: 50);

        final mockClient = http_testing.MockClient((request) async {
          await Future.delayed(const Duration(milliseconds: 200));
          return http.Response('{}', 200);
        });

        final client = EdgeFunctionClient(httpClient: mockClient);
        await expectLater(
          () => client.invoke({'model': 'test'}),
          throwsA(isA<TimeoutException>()),
        );

        EdgeFunctionClient.httpTimeout = savedTimeout;
      });

      test('uses custom function name in URL', () async {
        final mockClient = http_testing.MockClient((request) async {
          expect(request.url.path, contains('/functions/v1/custom-fn'));
          return http.Response(jsonEncode({'ok': true}), 200);
        });

        final client = EdgeFunctionClient(
          httpClient: mockClient,
          functionName: 'custom-fn',
        );
        final response = await client.invoke({});
        expect(response.status, 200);
      });
    });

    group('functionUrl', () {
      test('constructs correct URL from config', () {
        final client = EdgeFunctionClient();
        expect(
          client.functionUrl.toString(),
          contains('/functions/v1/openai-chat'),
        );
      });
    });
  });
}
