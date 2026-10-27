import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/motorista_repository.dart';
import 'package:mobile/core/perfil_repository.dart';
import 'package:mobile/core/api_contracts.dart';

class FakePerfilApiClient implements PerfilApiClient {
  @override
  Future<Map<String, dynamic>> me() async => {'name': 'Ana', 'email': 'ana@example.com'};

  @override
  Future<Map<String, dynamic>> atualizarPerfil(Map<String, dynamic> data) async => data;

  @override
  Future<Map<String, dynamic>> uploadFotoPerfil(Uint8List bytes, {String filename = 'perfil.jpg'}) async => {'ok': true, 'filename': filename};

  @override
  Future<void> removerFotoPerfil() async {}

  @override
  Future<void> logout() async {}
}

class FakeMotoristaApiClient implements MotoristaApiClient {
  @override
  Future<List<dynamic>> documentos() async => const [
    {'tipo': 'cnh', 'status': 'pendente'},
  ];

  @override
  Future<Map<String, dynamic>> enviarDocumento({ required String tipo, required String caminhoArquivo }) async => {
    'tipo': tipo,
    'arquivo': caminhoArquivo,
    'status': 'enviado',
  };

  @override
  Future<Map<String, dynamic>> atualizarVeiculo(Map<String, dynamic> veiculo) async => veiculo;
}

void main() {
  test('PerfilRepository encapsula perfil e foto do usuário', () async {
    final repo = PerfilRepository(api: FakePerfilApiClient());

    expect(await repo.dados(), {'name': 'Ana', 'email': 'ana@example.com'});
    expect(await repo.atualizar({'name': 'Ana Souza'}), {'name': 'Ana Souza'});
    expect(await repo.subirFoto(Uint8List(2), filename: 'perfil.png'), {'ok': true, 'filename': 'perfil.png'});
    await repo.removerFoto();
    await repo.sair();
  });

  test('MotoristaRepository encapsula documentos e veículo do motorista', () async {
    final repo = MotoristaRepository(api: FakeMotoristaApiClient());

    expect(await repo.documentos(), isNotEmpty);
    expect(
      await repo.enviarDocumento(tipo: 'cnh', caminhoArquivo: '/tmp/cnh.pdf'),
      {'tipo': 'cnh', 'arquivo': '/tmp/cnh.pdf', 'status': 'enviado'},
    );
    expect(
      await repo.atualizarVeiculo({'placa': 'ABC1D23'}),
      {'placa': 'ABC1D23'},
    );
  });
}
