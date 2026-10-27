import 'dart:typed_data';

import 'package:mobile/core/api_contracts.dart';
import 'package:mobile/services/api_service.dart';

class PerfilRepository {
  PerfilRepository({PerfilApiClient? api}) : _api = api ?? ApiService.instance;

  final PerfilApiClient _api;

  Future<Map<String, dynamic>> dados() => _api.me();

  Future<Map<String, dynamic>> atualizar(Map<String, dynamic> data) =>
      _api.atualizarPerfil(data);

  Future<Map<String, dynamic>> subirFoto(
    Uint8List bytes, {
    String filename = 'perfil.jpg',
  }) => _api.uploadFotoPerfil(bytes, filename: filename);

  Future<void> removerFoto() => _api.removerFotoPerfil();

  Future<void> sair() => _api.logout();
}
