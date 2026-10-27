import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class AlertaRepository {
  AlertaRepository({AlertaApiClient? api}) : _api = api ?? ApiService.instance;

  final AlertaApiClient _api;

  Future<List<dynamic>> listar({bool forceRefresh = false}) =>
      _api.alertas(forceRefresh: forceRefresh);

  Future<Map<String, dynamic>> marcarComoLido(Object id) =>
      _api.atualizarAlerta(id, {'lido': true});
}
