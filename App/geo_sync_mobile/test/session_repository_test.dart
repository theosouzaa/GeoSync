import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_session.dart';
import 'package:mobile/core/auth_response_parser.dart';
import 'package:mobile/core/api_error_formatter.dart';
import 'package:mobile/core/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthResponseParser', () {
    test('extrai os dados de login e token em respostas aninhadas', () {
      final response = {
        'data': {
          'token': 'abc123',
          'user': {
            'name': 'Maria',
            'email': 'maria@example.com',
          },
        },
      };

      expect(AuthResponseParser.data(response), {
        'token': 'abc123',
        'user': {
          'name': 'Maria',
          'email': 'maria@example.com',
        },
      });
      expect(AuthResponseParser.token(response), 'abc123');
    });

    test('retorna null quando não há token em resposta válida', () {
      final response = {'message': 'login invalido'};
      expect(AuthResponseParser.token(response), isNull);
    });
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSession.encerrarSessao();
  });

  group('SessionRepository', () {
    test('sincroniza nome, email e foto da sessão local a partir do payload do usuário', () async {
      await AppSession.iniciarSessao(
        token: 'token-123',
        tipoUsuario: 'Cliente',
        email: 'maria@antiga.com',
        nome: 'Maria Antiga',
      );

      await const SessionRepository().sincronizarDadosLocais({
        'user': {
          'name': 'Maria Nova',
          'email': 'maria@nova.com',
          'foto': '/storage/fotos/maria.jpg',
        },
      });

      expect(AppSession.nome, 'Maria Nova');
      expect(AppSession.email, 'maria@nova.com');
      expect(AppSession.fotoPerfil, '/storage/fotos/maria.jpg');
    });
  });

  group('ApiErrorFormatter', () {
    test('mascara erros internos do servidor sem expor detalhes técnicos', () {
      final formatted = ApiErrorFormatter.messageFrom(
        {'message': 'SQLSTATE[42S22] ...'},
        500,
      );

      expect(
        formatted,
        'O servidor encontrou um erro ao processar a solicitação. Tente novamente mais tarde.',
      );
    });
  });
}
