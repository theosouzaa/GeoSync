import 'package:mobile/app_session.dart';
import 'package:mobile/core/auth_response_parser.dart';

class SessionRepository {
  const SessionRepository();

  Future<void> iniciarSessaoFromResponse(Map<String, dynamic> response) async {
    final payload = AuthResponseParser.data(response);
    final token = AuthResponseParser.token(payload);
    final user = AuthResponseParser.user(payload);

    if (token == null || token.isEmpty) {
      return;
    }

    await AppSession.iniciarSessao(
      token: token,
      tipoUsuario: '${user['tipo'] ?? user['type'] ?? AppSession.tipoUsuario}',
      email: user['email'] as String?,
      nome: user['name'] ?? user['nome'],
      fotoPerfil: user['foto'] ?? user['photo'],
    );
  }

  Future<void> sincronizarDadosLocais(Map<String, dynamic> response) async {
    final payload = AuthResponseParser.data(response);
    final user = AuthResponseParser.user(payload);

    final nome = '${user['name'] ?? user['nome'] ?? AppSession.nome}'.trim();
    final email = '${user['email'] ?? AppSession.email}'.trim();
    if (nome.isNotEmpty || email.isNotEmpty) {
      await AppSession.atualizarDadosUsuario(
        nome: nome.isEmpty ? AppSession.nome : nome,
        email: email.isEmpty ? AppSession.email : email,
      );
    }

    final foto = user['foto'] ?? user['photo'] ?? user['profile_photo'];
    if (foto is String && foto.isNotEmpty) {
      await AppSession.definirFotoPerfil(foto);
    }
  }
}
