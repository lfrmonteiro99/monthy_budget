import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/supabase_public_config.dart';

/// Shared HTTP client for invoking Supabase Edge Functions.
///
/// Centralises URL construction, auth headers, timeout and error
/// classification that were previously duplicated across
/// [AiCoachService], [CommandChatService] and [MealPlannerAiService].
class EdgeFunctionClient {
  static const defaultFunctionName = 'openai-chat';

  /// HTTP request timeout shared across all edge-function callers.
  /// Mutable for testing; callers may adjust per-invocation.
  static Duration httpTimeout = const Duration(seconds: 15);

  final http.Client _httpClient;
  final String _functionName;

  EdgeFunctionClient({
    http.Client? httpClient,
    String functionName = defaultFunctionName,
  })  : _httpClient = httpClient ?? http.Client(),
        _functionName = functionName;

  // ---------------------------------------------------------------------------
  // Auth headers
  // ---------------------------------------------------------------------------

  /// Build standard auth headers for the Supabase edge function.
  Map<String, String> buildAuthHeaders() {
    final jwt = supabaseAnonKey.trim();
    if (jwt.isEmpty) {
      throw EdgeFunctionAuthException(
        'JWT indisponivel para autenticar chamada ao AI Coach.',
      );
    }
    return {
      'Authorization': 'Bearer $jwt',
      'apikey': supabaseAnonKey,
    };
  }

  // ---------------------------------------------------------------------------
  // URL construction
  // ---------------------------------------------------------------------------

  /// Full URL for the configured edge function.
  Uri get functionUrl =>
      Uri.parse('$supabaseUrl/functions/v1/$_functionName');

  // ---------------------------------------------------------------------------
  // Invoke
  // ---------------------------------------------------------------------------

  /// Post [body] to the edge function and return status + decoded data.
  Future<EdgeFunctionResponse> invoke(Map<String, dynamic> body) async {
    final headers = buildAuthHeaders();
    final response = await _httpClient
        .post(
          functionUrl,
          headers: {
            ...headers,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(httpTimeout);

    Object? data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {'error': response.body};
    }
    return EdgeFunctionResponse(status: response.statusCode, data: data);
  }

  // ---------------------------------------------------------------------------
  // Error classification (static, shared)
  // ---------------------------------------------------------------------------

  /// Whether the error indicates a missing edge function (404).
  static bool isFunctionNotFoundError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('functionexception') &&
        (raw.contains('status: 404') ||
            raw.contains('not_found') ||
            raw.contains('404'));
  }

  /// Whether the error indicates an auth / JWT problem.
  static bool isAuthError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('status: 401') ||
        raw.contains('status: 403') ||
        raw.contains('unauthorized') ||
        raw.contains('jwt') ||
        raw.contains('invalid token');
  }

  /// Build a user-facing error message from a raw edge-function error.
  static String buildErrorMessage(Object error, {required bool hasApiKey}) {
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (isAuthError(error)) {
      return 'Sessao expirada ou utilizador nao autenticado. '
          'Inicie sessao novamente para usar o AI Coach.';
    }
    if (isFunctionNotFoundError(error)) {
      if (hasApiKey) {
        return 'Serviço de IA indisponível no servidor. Verifique se a Edge Function '
            '"openai-chat" está publicada no projeto Supabase.';
      }
      return 'Serviço de IA indisponível no servidor. Adicione uma API key OpenAI '
          'em Definições > AI Coach ou publique a Edge Function "openai-chat".';
    }
    if (raw.isEmpty) return 'Falha ao processar pedido de IA.';
    return raw;
  }
}

/// Response from an edge function invocation.
class EdgeFunctionResponse {
  final int status;
  final Object? data;

  const EdgeFunctionResponse({required this.status, required this.data});
}

/// Thrown when auth headers cannot be constructed.
class EdgeFunctionAuthException implements Exception {
  final String message;
  const EdgeFunctionAuthException(this.message);

  @override
  String toString() => 'EdgeFunctionAuthException: $message';
}
