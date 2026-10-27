import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class MotoristaRepository {
  MotoristaRepository({MotoristaApiClient? api})
    : _api = api ?? ApiService.instance;

  final MotoristaApiClient _api;

  Future<List<dynamic>> documentos() => _api.documentos();

  Future<Map<String, dynamic>> enviarDocumento({
    required String tipo,
    required String caminhoArquivo,
  }) => _api.enviarDocumento(tipo: tipo, caminhoArquivo: caminhoArquivo);

  Future<Map<String, dynamic>> atualizarVeiculo(Map<String, dynamic> veiculo) =>
      _api.atualizarVeiculo(veiculo);
}
