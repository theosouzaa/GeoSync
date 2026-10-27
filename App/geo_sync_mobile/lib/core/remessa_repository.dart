import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class RemessaRepository {
  RemessaRepository({RemessaApiClient? api})
    : _api = api ?? ApiService.instance;

  final RemessaApiClient _api;

  Future<List<dynamic>> minhas({bool forceRefresh = false}) =>
      _api.minhasRemessas(forceRefresh: forceRefresh);

  Future<List<dynamic>> autorizadas({bool forceRefresh = false}) =>
      _api.minhasRemessas(forceRefresh: forceRefresh);

  Future<List<dynamic>> disponiveis() => _api.remessasDisponiveis();

  Future<Map<String, dynamic>> detalhes(Object id) => _api.remessa(id);

  Future<Map<String, dynamic>> aceitar(Object id) => _api.aceitarRemessa(id);

  Future<Map<String, dynamic>> atualizarStatus(Object id, String status) =>
      _api.atualizarStatusRemessa(id, status);

  Future<List<dynamic>> historico(Object id) => _api.historicoRemessa(id);

  Future<Map<String, dynamic>> registrarOcorrencia(
    Object id, {
    required String descricao,
    String categoria = 'Outro',
    String? fotoBase64,
    double? latitude,
    double? longitude,
    String? nomeResponsavel,
    DateTime? ocorridaEm,
  }) => _api.registrarOcorrenciaRemessa(
    id,
    descricao: descricao,
    categoria: categoria,
    fotoBase64: fotoBase64,
    latitude: latitude,
    longitude: longitude,
    nomeResponsavel: nomeResponsavel,
    ocorridaEm: ocorridaEm,
  );

  Future<Map<String, dynamic>> registrarComprovante(
    Object id, {
    required String destinatario,
    required String assinaturaBase64,
    String? fotoBase64,
    String? observacao,
    required double latitude,
    required double longitude,
    DateTime? entregueEm,
  }) => _api.registrarComprovanteEntrega(
    id,
    destinatario: destinatario,
    assinaturaBase64: assinaturaBase64,
    fotoBase64: fotoBase64,
    observacao: observacao,
    latitude: latitude,
    longitude: longitude,
    entregueEm: entregueEm,
  );

  Future<List<dynamic>> localizacoes(Object remessaId) =>
      _api.localizacoesPorRemessa(remessaId);

  Future<Map<String, dynamic>> ultimaLocalizacao(Object remessaId) =>
      _api.ultimaLocalizacaoPorRemessa(remessaId);
}
