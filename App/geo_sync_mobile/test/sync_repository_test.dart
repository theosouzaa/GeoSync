import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/sync_repository.dart';
import 'package:mobile/sync/sync_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SyncRepository expõe status da sincronização e contagem de pendentes', () async {
    final repo = SyncRepository(
      engine: SyncEngine(),
      pendentesFactory: () async => 3,
    );

    expect(repo.estado, isNotNull);
    expect(repo.estado.value.sincronizando, isFalse);
    expect(await repo.contarPendentes(), 3);
  });
}
