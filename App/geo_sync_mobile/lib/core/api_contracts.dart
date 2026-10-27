import 'dart:typed_data';

abstract class RemessaApiClient {
  Future<List<dynamic>> minhasRemessas({bool forceRefresh = false});
  Future<List<dynamic>> remessasDisponiveis();
  Future<Map<String, dynamic>> remessa(Object id);
  Future<Map<String, dynamic>> aceitarRemessa(Object id);
  Future<Map<String, dynamic>> atualizarStatusRemessa(Object id, String status);
  Future<List<dynamic>> historicoRemessa(Object id);
  Future<Map<String, dynamic>> registrarOcorrenciaRemessa(
    Object id, {
    required String descricao,
    String categoria,
    String? fotoBase64,
    double? latitude,
    double? longitude,
    String? nomeResponsavel,
    DateTime? ocorridaEm,
  });
  Future<Map<String, dynamic>> registrarComprovanteEntrega(
    Object id, {
    required String destinatario,
    required String assinaturaBase64,
    String? fotoBase64,
    String? observacao,
    required double latitude,
    required double longitude,
    DateTime? entregueEm,
  });
  Future<List<dynamic>> localizacoesPorRemessa(Object remessaId);
  Future<Map<String, dynamic>> ultimaLocalizacaoPorRemessa(Object remessaId);
}

abstract class PagamentoApiClient {
  Future<List<dynamic>> pagamentos({bool forceRefresh = false});
}

abstract class AvaliacaoApiClient {
  Future<List<dynamic>> avaliacoes();
  Future<Map<String, dynamic>> resumoAvaliacoes();
}

abstract class AlertaApiClient {
  Future<List<dynamic>> alertas({bool forceRefresh = false});
  Future<Map<String, dynamic>> atualizarAlerta(Object id, Map<String, dynamic> data);
}

abstract class PerfilApiClient {
  Future<Map<String, dynamic>> me();
  Future<Map<String, dynamic>> atualizarPerfil(Map<String, dynamic> data);
  Future<Map<String, dynamic>> uploadFotoPerfil(
    Uint8List bytes, {
    String filename = 'perfil.jpg',
  });
  Future<void> removerFotoPerfil();
  Future<void> logout();
}

abstract class MotoristaApiClient {
  Future<List<dynamic>> documentos();
  Future<Map<String, dynamic>> enviarDocumento({
    required String tipo,
    required String caminhoArquivo,
  });
  Future<Map<String, dynamic>> atualizarVeiculo(Map<String, dynamic> veiculo);
}
