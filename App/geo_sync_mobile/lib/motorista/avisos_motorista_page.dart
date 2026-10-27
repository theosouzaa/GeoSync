import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/services/api_exception.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/widgets/app_gradient_header.dart';
import 'package:mobile/widgets/responsive_content.dart';

class AvisosMotoristaPage extends StatefulWidget {
  const AvisosMotoristaPage({super.key});

  @override
  State<AvisosMotoristaPage> createState() => _AvisosMotoristaPageState();
}

class _AvisosMotoristaPageState extends State<AvisosMotoristaPage> {
  static const _primary = Color(0xFF0C46FF);
  List<Map<String, dynamic>> _avisos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiService.instance.avisosMotorista(
        forceRefresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        _avisos = response
            .whereType<Map>()
            .map((aviso) => Map<String, dynamic>.from(aviso))
            .toList();
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppGradientHeader(
              title: 'Avisos',
              subtitle: _avisos.isEmpty
                  ? 'Acompanhe atualizações das suas entregas'
                  : _avisos.length == 1
                  ? '1 atualização das suas remessas'
                  : '${_avisos.length} atualizações das suas remessas',
              icon: LucideIcons.bell,
            ),
            Expanded(
              child: ResponsiveContent(
                child: RefreshIndicator(
                  onRefresh: () => _load(refresh: true),
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: scheme.primary,
                          ),
                        )
                      : _error != null
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(22),
                          children: [
                            const SizedBox(height: 70),
                            _emptyState(
                              context,
                              icon: LucideIcons.cloudOff,
                              title: 'Não foi possível carregar',
                              message: _error!,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: FilledButton.icon(
                                onPressed: () => _load(refresh: true),
                                icon: const Icon(LucideIcons.refreshCw),
                                label: const Text('Tentar novamente'),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
                          children: [
                            if (_avisos.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 66),
                                child: _emptyState(
                                  context,
                                  icon: LucideIcons.bellOff,
                                  title: 'Tudo tranquilo por aqui',
                                  message:
                                      'Quando houver uma atualização sobre suas remessas, ela aparecerá nesta tela.',
                                ),
                              )
                            else ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: scheme.primary.withValues(alpha: 0.10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.bellRing,
                                      color: scheme.primary,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Atualizações das suas remessas',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: scheme.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${_avisos.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              ..._avisos.map(_card),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 34, color: scheme.primary),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(Map<String, dynamic> aviso) {
    final remessa = aviso['remessa'] is Map
        ? Map<String, dynamic>.from(aviso['remessa'] as Map)
        : <String, dynamic>{};
    final tipo = aviso['titulo'] ?? aviso['title'] ?? aviso['tipo'] ?? 'Aviso';
    final mensagem =
        aviso['descricao'] ?? aviso['message'] ?? aviso['mensagem'] ?? '';
    final codigo = remessa['codigo_rastreio'] ?? remessa['codigo'];
    final detalhes = '$mensagem'.trim();
    final data = DateTime.tryParse(
      '${aviso['created_at'] ?? aviso['data'] ?? ''}',
    )?.toLocal();
    final tipoNormalizado = '$tipo'.toLowerCase();
    final critico = tipoNormalizado.contains('atras') ||
        tipoNormalizado.contains('problema') ||
        tipoNormalizado.contains('ocorr');
    final entregue = tipoNormalizado.contains('entreg');
    final proximidade = tipoNormalizado.contains('proxim') ||
        tipoNormalizado.contains('destino');
    final cor = critico
        ? const Color(0xFFDC2626)
        : entregue
        ? const Color(0xFF059669)
        : proximidade
        ? const Color(0xFF7C3AED)
        : _primary;
    final icone = critico
        ? LucideIcons.triangleAlert
        : entregue
        ? LucideIcons.badgeCheck
        : proximidade
        ? LucideIcons.mapPin
        : LucideIcons.bellRing;
    final horario = data == null
        ? null
        : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} · ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icone, color: cor, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 190),
                        child: Text(
                          '$tipo',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (horario != null)
                        Text(
                          horario,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    detalhes.isEmpty ? 'Sem descrição.' : detalhes,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  if (codigo != null && '$codigo'.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'REMESSA  $codigo',
                        style: TextStyle(
                          color: cor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
