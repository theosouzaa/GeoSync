import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class PagamentoRepository {
  PagamentoRepository({PagamentoApiClient? api})
    : _api = api ?? ApiService.instance;

  final PagamentoApiClient _api;

  Future<List<dynamic>> listar({bool forceRefresh = false}) =>
      _api.pagamentos(forceRefresh: forceRefresh);
}