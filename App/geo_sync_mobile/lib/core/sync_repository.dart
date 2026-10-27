import 'package:flutter/foundation.dart';
import 'package:mobile/sync/pending_queue.dart';
import 'package:mobile/sync/sync_engine.dart';

class SyncRepository {
  SyncRepository({
    SyncEngine? engine,
    Future<int> Function()? pendentesFactory,
  }) : _engine = engine ?? SyncEngine.instance,
       _pendentesFactory = pendentesFactory ?? (() => PendingQueue.instance.contar());

  final SyncEngine _engine;
  final Future<int> Function() _pendentesFactory;

  ValueNotifier<SyncState> get estado => _engine.estado;

  Future<SyncReport> sincronizar({bool forcarCompleta = false}) =>
      _engine.sincronizar(forcarCompleta: forcarCompleta);

  Future<List<Map<String, dynamic>>> remessasLocais() =>
      _engine.remessasLocais();

  Future<bool> possuiCache() => _engine.possuiCache();

  Future<int> contarPendentes() => _pendentesFactory();

  Future<List<PendingAction>> listarPendentes() => PendingQueue.instance.listar();

  Future<void> registrarAcaoOffline({
    required String tipo,
    required String metodo,
    required String caminho,
    required Object remessaId,
    Map<String, dynamic>? corpo,
  }) =>
      _engine.registrarAcaoOffline(
        tipo: tipo,
        metodo: metodo,
        caminho: caminho,
        remessaId: remessaId,
        corpo: corpo,
      );

  void iniciarAutomatico() => _engine.iniciarAutomatico();

  void pararAutomatico() => _engine.pararAutomatico();
}
