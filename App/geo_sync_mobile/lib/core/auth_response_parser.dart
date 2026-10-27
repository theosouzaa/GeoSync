class AuthResponseParser {
  const AuthResponseParser._();

  static Map<String, dynamic> data(Map<String, dynamic> response) {
    final payload = response['data'];
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return response;
  }

  static String? token(Map<String, dynamic> response) {
    const tokenKeys = {'token', 'access_token', 'accessToken', 'jwt'};

    String? findToken(dynamic value) {
      if (value is Map) {
        for (final key in tokenKeys) {
          final candidate = value[key];
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
        for (final nested in value.values) {
          final token = findToken(nested);
          if (token != null) return token;
        }
      }
      return null;
    }

    return findToken(response);
  }

  static Map<String, dynamic> user(Map<String, dynamic> response) {
    Map<String, dynamic>? findUser(dynamic value) {
      if (value is Map) {
        for (final key in ['user', 'usuario', 'account']) {
          final candidate = value[key];
          if (candidate is Map) {
            return Map<String, dynamic>.from(candidate);
          }
        }
        for (final nested in value.values) {
          final user = findUser(nested);
          if (user != null) return user;
        }
        if (value.containsKey('email') ||
            value.containsKey('name') ||
            value.containsKey('nome')) {
          return Map<String, dynamic>.from(value);
        }
      }
      return null;
    }

    return findUser(response) ?? <String, dynamic>{};
  }
}
