import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/services/api_exception.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/notification_center.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: TelaAlertas()),
  );
}

// ============================================================
// MODELO DE ALERTA
// ============================================================

class Alerta {
  final Object? id;
  final String titulo;
  final String descricao;
  final String local;
  final String horario;
  final String status;
  final IconData icone;
  bool lido;

  Alerta({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.local,
    required this.horario,
    required this.status,
    required this.icone,
    this.lido = false,
  });
}

// ============================================================
// TELA DE ALERTAS
// ============================================================

class TelaAlertas extends StatefulWidget {
  const TelaAlertas({super.key});

  @override
  State<TelaAlertas> createState() => _TelaAlertasState();
}

class _TelaAlertasState extends State<TelaAlertas> {
  // ============================================================
  // PALETA GEOSYNC
  // ============================================================

  static const Color primary = Color(0xFF0C46FF);
  static const Color primaryDark = Color(0xFF0B2A4A);

  Color get textDark => Theme.of(context).colorScheme.onSurface;
  static const Color textLight = Color(0xFF718096);

  Color get border => Theme.of(context).colorScheme.outlineVariant;

  Color get surface => Theme.of(context).colorScheme.surface;

  // ============================================================
  // FILTRO ATUAL
  // ============================================================

  String filtroSelecionado = "Todos";
  final TextEditingController _buscaController = TextEditingController();

  String _chaveStatus(Object? status) => '$status'
      .trim()
      .toLowerCase()
      .replaceAll('\u00c3\u00a1', 'a')
      .replaceAll('\u00c3\u00a3', 'a')
      .replaceAll('\u00c3\u00a2', 'a')
      .replaceAll('\u00c3\u00a9', 'e')
      .replaceAll('\u00c3\u00aa', 'e')
      .replaceAll('\u00c3\u00ad', 'i')
      .replaceAll('\u00c3\u00b3', 'o')
      .replaceAll('\u00c3\u00b4', 'o')
      .replaceAll('\u00c3\u00b5', 'o')
      .replaceAll('\u00c3\u00ba', 'u')
      .replaceAll('\u00c3\u00a7', 'c')
      .replaceAll('\u00e1', 'a')
      .replaceAll('\u00e3', 'a')
      .replaceAll('\u00e2', 'a')
      .replaceAll('\u00e9', 'e')
      .replaceAll('\u00ea', 'e')
      .replaceAll('\u00ed', 'i')
      .replaceAll('\u00f3', 'o')
      .replaceAll('\u00f4', 'o')
      .replaceAll('\u00f5', 'o')
      .replaceAll('\u00fa', 'u')
      .replaceAll('\u00e7', 'c')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ');

  String _statusExibicao(Object? status) {
    final chave = _chaveStatus(status);
    if (chave.contains('critic') ||
        chave.contains('critical') ||
        chave.contains('high') ||
        chave.contains('severe') ||
        chave.contains('alta')) {
      return 'Cr\u00edtico';
    }
    if (chave.contains('atenc') ||
        chave.contains('warning') ||
        chave.contains('attention') ||
        chave.contains('medium') ||
        chave.contains('moderad') ||
        chave == 'media') {
      return 'Aten\u00e7\u00e3o';
    }
    if (chave.contains('inform') ||
        chave.contains('info') ||
        chave.contains('low') ||
        chave.contains('baixa')) {
      return 'Informativo';
    }
    return '${status ?? 'Informativo'}';
  }

  // ============================================================
  // LISTA DE ALERTAS
  // ============================================================

  final List<Alerta> alertas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_atualizarBusca);
    _carregarAlertas();
  }

  @override
  void dispose() {
    _buscaController
      ..removeListener(_atualizarBusca)
      ..dispose();
    super.dispose();
  }

  void _atualizarBusca() {
    if (mounted) setState(() {});
  }

  Future<void> _carregarAlertas({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _carregando = alertas.isEmpty;
        _erro = null;
      });
    }
    try {
      final resposta = await ApiService.instance.alertas(
        forceRefresh: forceRefresh,
      );
      final dados = resposta.whereType<Map>().map(_alertaFromApi).toList();
      if (!mounted) return;
      setState(() {
        alertas
          ..clear()
          ..addAll(dados);
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = alertas.isEmpty ? error.message : null;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = alertas.isEmpty
            ? 'Não foi possível carregar os alertas.'
            : null;
        _carregando = false;
      });
    }
  }

  Alerta _alertaFromApi(Map value) => Alerta(
    id: value['id'],
    titulo: '${value['titulo'] ?? value['title'] ?? 'Alerta'}',
    descricao:
        '${value['descricao'] ?? value['description'] ?? value['mensagem'] ?? '-'}',
    local: '${value['local'] ?? value['localizacao'] ?? '-'}',
    horario: '${value['horario'] ?? value['created_at'] ?? '-'}',
    status: _statusExibicao(value['status'] ?? value['gravidade']),
    icone: _iconeStatus(_statusExibicao(value['status'] ?? value['gravidade'])),
    lido:
        value['lido'] == true ||
        value['read'] == true ||
        value['read_at'] != null,
  );

  int get _quantidadeNaoLidos => alertas.where((a) => !a.lido).length;

  Future<void> _marcarComoLido(Alerta alerta) async {
    if (alerta.lido || alerta.id == null) return;
    setState(() => alerta.lido = true);
    try {
      await ApiService.instance.atualizarAlerta(alerta.id!, {'lido': true});
    } on ApiException catch (_) {
      // Mantém como lido localmente mesmo se o backend não confirmar,
      // para não reabrir um alerta que o usuário já visualizou.
    } finally {
      unawaited(AppNotificationCenter.instance.refreshNow());
    }
  }

  Future<void> _marcarTodosComoLidos() async {
    final pendentes = alertas.where((a) => !a.lido).toList();
    if (pendentes.isEmpty) return;
    setState(() {
      for (final alerta in pendentes) {
        alerta.lido = true;
      }
    });
    await Future.wait([
      for (final alerta in pendentes)
        if (alerta.id != null)
          ApiService.instance
              .atualizarAlerta(alerta.id!, {'lido': true})
              .catchError((_) => <String, dynamic>{}),
    ]);
    unawaited(AppNotificationCenter.instance.refreshNow());
  }

  // ============================================================
  // FILTRAR ALERTAS
  // ============================================================

  List<Alerta> get alertasFiltrados {
    final filtro = _chaveStatus(filtroSelecionado);
    final busca = _buscaController.text.trim().toLowerCase();
    final resultado = alertas.where((alerta) {
      final correspondeFiltro =
          filtro == 'todos' || _chaveStatus(alerta.status) == filtro;
      final correspondeBusca =
          busca.isEmpty ||
          alerta.titulo.toLowerCase().contains(busca) ||
          alerta.descricao.toLowerCase().contains(busca) ||
          alerta.local.toLowerCase().contains(busca);
      return correspondeFiltro && correspondeBusca;
    }).toList();

    resultado.sort((a, b) {
      if (a.lido != b.lido) return a.lido ? 1 : -1;
      final prioridade = _prioridadeStatus(
        a.status,
      ).compareTo(_prioridadeStatus(b.status));
      if (prioridade != 0) return prioridade;
      final horarioA = DateTime.tryParse(a.horario)?.toLocal();
      final horarioB = DateTime.tryParse(b.horario)?.toLocal();
      if (horarioA == null) return horarioB == null ? 0 : 1;
      if (horarioB == null) return -1;
      return horarioB.compareTo(horarioA);
    });
    return resultado;
  }

  int _prioridadeStatus(String status) {
    switch (_chaveStatus(status)) {
      case 'critico':
      case 'critical':
        return 0;
      case 'atencao':
      case 'warning':
        return 1;
      default:
        return 2;
    }
  }

  String _horarioLegivel(String valor) {
    final data = DateTime.tryParse(valor)?.toLocal();
    if (data == null) return valor;
    final agora = DateTime.now();
    final hoje =
        data.year == agora.year &&
        data.month == agora.month &&
        data.day == agora.day;
    final ontem =
        DateTime(
          agora.year,
          agora.month,
          agora.day,
        ).difference(DateTime(data.year, data.month, data.day)).inDays ==
        1;
    final hora =
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    if (hoje) return 'Hoje, $hora';
    if (ontem) return 'Ontem, $hora';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} · $hora';
  }

  // ============================================================
  // CONTADORES
  // ============================================================

  int get quantidadeCriticos => alertas
      .where((alerta) => _chaveStatus(alerta.status) == 'critico')
      .length;

  int get quantidadeAtencao => alertas
      .where((alerta) => _chaveStatus(alerta.status) == 'atencao')
      .length;

  int get quantidadeInformativos => alertas
      .where((alerta) => _chaveStatus(alerta.status) == 'informativo')
      .length;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                  ? _buildErro()
                  : RefreshIndicator(
                      color: primary,
                      onRefresh: () => _carregarAlertas(forceRefresh: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                        children: [
                          const SizedBox(height: 20),

                          _buildResumo(),

                          const SizedBox(height: 24),

                          _buildTituloSecao(),

                          const SizedBox(height: 16),

                          _buildCampoBusca(),

                          const SizedBox(height: 12),

                          _buildFiltros(),

                          const SizedBox(height: 18),

                          if (alertasFiltrados.isEmpty)
                            _buildEstadoVazio()
                          else
                            ...alertasFiltrados.map(
                              (alerta) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildAlertaCard(alerta),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // ÍCONE
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: const Icon(
                  LucideIcons.bellRing,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              if (_quantidadeNaoLidos > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryDark, width: 2),
                    ),
                    child: Text(
                      '$_quantidadeNaoLidos',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // TÍTULO
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alertas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Avisos das suas remessas",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // MARCAR TODOS COMO LIDOS
          if (_quantidadeNaoLidos > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _marcarTodosComoLidos,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      LucideIcons.checkCheck,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

          // BOTÃO ATUALIZAR
          Material(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await _carregarAlertas(forceRefresh: true);
                if (!mounted) return;
                _mostrarMensagem("Alertas atualizados.");
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  LucideIcons.refreshCw,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErro() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.wifi_slash, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_erro!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _carregarAlertas(forceRefresh: true),
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );

  // ============================================================
  // RESUMO
  // ============================================================

  Widget _buildResumo() {
    return Row(
      children: [
        Expanded(
          child: _buildResumoCard(
            titulo: "Total",
            valor: alertas.length.toString(),
            icone: LucideIcons.bell,
            cor: primary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildResumoCard(
            titulo: "Cr\u00edticos",
            valor: quantidadeCriticos.toString(),
            icone: LucideIcons.triangleAlert,
            cor: const Color(0xFFD64545),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildResumoCard(
            titulo: "Aten\u00e7\u00e3o",
            valor: quantidadeAtencao.toString(),
            icone: LucideIcons.circleAlert,
            cor: const Color(0xFFE58A00),
          ),
        ),
      ],
    );
  }

  Widget _buildResumoCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 18),
              ),
              const Spacer(),
              Text(
                valor,
                style: TextStyle(
                  color: textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            titulo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO DA SEÇÃO
  // ============================================================

  Widget _buildTituloSecao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Central de alertas",
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (_quantidadeNaoLidos > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_quantidadeNaoLidos n\u00e3o lidos',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Filtre os eventos para encontrar rapidamente o que precisa.",
          style: TextStyle(color: textLight, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFiltro(texto: "Todos", quantidade: alertas.length),

          _buildFiltro(texto: "Cr\u00edtico", quantidade: quantidadeCriticos),

          _buildFiltro(
            texto: "Aten\u00e7\u00e3o",
            quantidade: quantidadeAtencao,
          ),

          _buildFiltro(
            texto: "Informativo",
            quantidade: quantidadeInformativos,
          ),
        ],
      ),
    );
  }

  Widget _buildCampoBusca() {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _buscaController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por título, descrição ou local',
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
          fontSize: 13,
        ),
        prefixIcon: const Icon(LucideIcons.search, size: 19),
        suffixIcon: _buscaController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                onPressed: _buscaController.clear,
                icon: const Icon(LucideIcons.x, size: 18),
              ),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFiltro({required String texto, required int quantidade}) {
    final bool selecionado = filtroSelecionado == texto;

    final Color cor = _corStatus(texto);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selecionado,
        label: 'Filtro $texto, $quantidade alertas',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
          onTap: () {
            setState(() {
              filtroSelecionado = texto;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selecionado ? cor : surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selecionado ? cor : border),
              boxShadow: selecionado
                  ? [
                      BoxShadow(
                        color: cor.withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Text(
                  texto,
                  style: TextStyle(
                    color: selecionado ? Colors.white : textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(width: 7),

                Container(
                  constraints: const BoxConstraints(
                    minWidth: 21,
                    minHeight: 21,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: selecionado
                        ? Colors.white.withValues(alpha: 0.20)
                        : cor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    quantidade.toString(),
                    style: TextStyle(
                      color: selecionado ? Colors.white : cor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARD DE ALERTA
  // ============================================================

  Widget _buildAlertaCard(Alerta alerta) {
    final Color cor = _corStatus(alerta.status);
    final bool naoLido = !alerta.lido;

    return Container(
      decoration: BoxDecoration(
        color: naoLido
            ? Color.alphaBlend(cor.withValues(alpha: 0.035), surface)
            : surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: naoLido ? cor.withValues(alpha: 0.28) : border,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: naoLido ? 0.055 : 0.025),
            blurRadius: naoLido ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _marcarComoLido(alerta);
            _mostrarDetalhes(alerta);
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // ÍCONE
                    // ==================================================
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _iconeStatus(alerta.status),
                        color: cor,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 13),

                    // ==================================================
                    // TÍTULO E DESCRIÇÃO
                    // ==================================================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (naoLido)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 7),
                                  decoration: BoxDecoration(
                                    color: cor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  alerta.titulo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textDark,
                                    fontSize: 15,
                                    fontWeight: naoLido
                                        ? FontWeight.w900
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 112,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      LucideIcons.clock3,
                                      color: textLight,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _horarioLegivel(alerta.horario),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: textLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Text(
                            alerta.descricao,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textLight,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // ==================================================
                // LINHA INFERIOR
                // ==================================================
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(LucideIcons.mapPin, color: cor, size: 17),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        alerta.local,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildEtiqueta(alerta.status, cor),
                    if (naoLido) ...[
                      const SizedBox(width: 6),
                      _buildEtiqueta('Novo', primary),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEtiqueta(String texto, Color cor) => Container(
    constraints: const BoxConstraints(maxWidth: 92),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: cor.withValues(alpha: 0.12)),
    ),
    child: Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: cor, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );

  // ============================================================
  // ESTADO VAZIO
  // ============================================================

  Widget _buildEstadoVazio() {
    final filtrando =
        _buscaController.text.trim().isNotEmpty || filtroSelecionado != 'Todos';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 45),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bellOff, color: primary, size: 34),
          ),

          const SizedBox(height: 16),

          Text(
            filtrando ? 'Nenhum alerta encontrado' : 'Tudo em dia por aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 5),

          Text(
            filtrando
                ? 'Tente outro termo ou remova os filtros aplicados.'
                : 'Quando houver um aviso importante, ele aparecerá aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textLight, fontSize: 12),
          ),
          if (filtrando) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                _buscaController.clear();
                setState(() => filtroSelecionado = 'Todos');
              },
              icon: const Icon(LucideIcons.listFilter, size: 17),
              label: const Text('Limpar busca e filtros'),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // COR DO STATUS
  // ============================================================

  Color _corStatus(String status) {
    final chave = _chaveStatus(status);
    if (chave == 'critico' || chave == 'critical') {
      return const Color(0xFFDC3F52);
    }
    if (chave == 'atencao' || chave == 'warning') {
      return const Color(0xFFD88713);
    }
    if (chave == 'todos') return primaryDark;
    return primary;
  }

  IconData _iconeStatus(String status) {
    final chave = _chaveStatus(status);
    if (chave == 'critico' || chave == 'critical') {
      return LucideIcons.triangleAlert;
    }
    if (chave == 'atencao' || chave == 'warning') {
      return LucideIcons.circleAlert;
    }
    return LucideIcons.info;
  }
  // ============================================================
  // DETALHES DO ALERTA
  // ============================================================

  void _mostrarDetalhes(Alerta alerta) {
    final Color cor = _corStatus(alerta.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_iconeStatus(alerta.status), color: cor),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        alerta.titulo,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildDetalhe(
                  LucideIcons.fileText,
                  "Descrição",
                  alerta.descricao,
                ),

                _buildDetalhe(LucideIcons.mapPin, "Localização", alerta.local),

                _buildDetalhe(LucideIcons.clock3, "Horário", alerta.horario),

                _buildDetalhe(LucideIcons.flag, "Status", alerta.status),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Fechar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalhe(IconData icone, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icone, color: primary, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
