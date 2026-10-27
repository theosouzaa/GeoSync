import 'package:flutter/foundation.dart';

class ApiErrorFormatter {
  const ApiErrorFormatter._();

  static String messageFrom(dynamic data, [int? statusCode]) {
    if (statusCode != null && statusCode >= 500) {
      final detalhe = data is Map ? data['message'] : data;
      debugPrint('[API] erro $statusCode do servidor: $detalhe');
      return 'O servidor encontrou um erro ao processar a solicitação. Tente novamente mais tarde.';
    }

    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        return data['message'] as String;
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return '${entry.key}: ${value.first}';
          }
          if (value is String && value.isNotEmpty) {
            return '${entry.key}: $value';
          }
        }
      }
    }

    return 'Não foi possível concluir a solicitação.';
  }
}
