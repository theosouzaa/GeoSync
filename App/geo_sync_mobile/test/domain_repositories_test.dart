import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/alerta_repository.dart';
import 'package:mobile/core/avaliacao_repository.dart';
import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/core/pagamento_repository.dart';
import 'package:mobile/core/remessa_repository.dart';

class FakeRemessaApiClient implements RemessaApiClient {
  @override
  Future<List<dynamic>> minhasRemessas({bool forceRefresh = false}) async =>
      const [
        {'id': 1, 'status': 'pendente'},
      ];

  @override
  Future<List<dynamic>> remessasDisponiveis() async =>
      const [
        {'id': 2, 'status': 'disponivel'},
      ];

  @override
  Future<Map<String, dynamic>> remessa(Object id) async =>
      {'id': id, 'status': 'pendente'};

  @override
  Future<Map<String, dynamic>> aceitarRemessa(Object id) async =>
      {'id': id, 'status': 'aceita'};

  @override
  Future<Map<String, dynamic>> atualizarStatusRemessa(
    Object id,
    String status,
  ) async => {'id': id, 'status': status};

  @override
  Future<List<dynamic>> historicoRemessa(Object id) async => [
    {'id': id, 'evento': 'criado'},
  ];

  @override
  Future<Map<String, dynamic>> registrarOcorrenciaRemessa(
    Object id, {
    required String descricao,
    String categoria = 'Outro',
    String? fotoBase64,
    double? latitude,
    double? longitude,
    String? nomeResponsavel,
    DateTime? ocorridaEm,
  }) async => {'id': id, 'descricao': descricao, 'categoria': categoria};

  @override
  Future<Map<String, dynamic>> registrarComprovanteEntrega(
    Object id, {
    required String destinatario,
    required String assinaturaBase64,
    String? fotoBase64,
    String? observacao,
    required double latitude,
    required double longitude,
    DateTime? entregueEm,
  }) async => {'id': id, 'destinatario': destinatario};

  @override
  Future<List<dynamic>> localizacoesPorRemessa(Object remessaId) async => const [];

  @override
  Future<Map<String, dynamic>> ultimaLocalizacaoPorRemessa(
    Object remessaId,
  ) async => {'latitude': -23.5, 'longitude': -46.6};
}

class FakeAlertaApiClient implements AlertaApiClient {
  @override
  Future<List<dynamic>> alertas({bool forceRefresh = false}) async =>
      const [
        {'id': 10, 'lido': false},
      ];

  @override
  Future<Map<String, dynamic>> atualizarAlerta(
    Object id,
    Map<String, dynamic> data,
  ) async => {'id': id, ...data};
}

class FakePagamentoApiClient implements PagamentoApiClient {
  bool? ultimaAtualizacaoForcada;

  @override
  Future<List<dynamic>> pagamentos({bool forceRefresh = false}) async {
    ultimaAtualizacaoForcada = forceRefresh;
    return const [
      {'id': 5, 'valor': 25.0},
    ];
  }
}

class FakeAvaliacaoApiClient implements AvaliacaoApiClient {
  @override
  Future<List<dynamic>> avaliacoes() async => const [
    {'id': 8, 'nota': 5},
  ];

  @override
  Future<Map<String, dynamic>> resumoAvaliacoes() async => const {
    'media': 4.5,
  };
}

void main() {
  test('RemessaRepository encaminha ações do domínio para a API', () async {
    final api = FakeRemessaApiClient();
    final repo = RemessaRepository(api: api);

    expect(await repo.minhas(), isNotEmpty);
    expect(await repo.autorizadas(), isNotEmpty);
    expect(await repo.disponiveis(), isNotEmpty);
    expect(await repo.detalhes(42), {'id': 42, 'status': 'pendente'});
    expect(await repo.localizacoes(42), isEmpty);
    expect(await repo.ultimaLocalizacao(42), contains('latitude'));
    expect(
      await repo.registrarOcorrencia(42, descricao: 'Atraso'),
      {'id': 42, 'descricao': 'Atraso', 'categoria': 'Outro'},
    );
    expect(
      await repo.registrarComprovante(
        42,
        destinatario: 'Cliente',
        assinaturaBase64: 'assinatura',
        latitude: -23.5,
        longitude: -46.6,
      ),
      {'id': 42, 'destinatario': 'Cliente'},
    );
    expect(await repo.aceitar(42), {'id': 42, 'status': 'aceita'});
    expect(
      await repo.atualizarStatus(42, 'em_transito'),
      {'id': 42, 'status': 'em_transito'},
    );
    expect(await repo.historico(42), isNotEmpty);
  });

  test('AlertaRepository encapsula leitura e atualização de alertas', () async {
    final api = FakeAlertaApiClient();
    final repo = AlertaRepository(api: api);

    expect(await repo.listar(), isNotEmpty);
    expect(
      await repo.marcarComoLido(10),
      {'id': 10, 'lido': true},
    );
  });

  test('PagamentoRepository encaminha listagem e atualização forçada', () async {
    final api = FakePagamentoApiClient();
    final repo = PagamentoRepository(api: api);

    expect(await repo.listar(forceRefresh: true), isNotEmpty);
    expect(api.ultimaAtualizacaoForcada, isTrue);
  });

  test('AvaliacaoRepository encapsula avaliações e resumo', () async {
    final repo = AvaliacaoRepository(api: FakeAvaliacaoApiClient());

    expect(await repo.listar(), isNotEmpty);
    expect(await repo.resumo(), {'media': 4.5});
  });
}
