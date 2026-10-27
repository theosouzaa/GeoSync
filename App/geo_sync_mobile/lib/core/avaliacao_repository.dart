import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class AvaliacaoRepository {
  AvaliacaoRepository({AvaliacaoApiClient? api})
    : _api = api ?? ApiService.instance;

  final AvaliacaoApiClient _api;

  Future<List<dynamic>> listar() => _api.avaliacoes();

  Future<Map<String, dynamic>> resumo() => _api.resumoAvaliacoes();
}