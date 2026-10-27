double shipmentProgress({required Object? status, Object? apiProgress}) {
  final normalizedStatus = '$status'
      .trim()
      .toLowerCase()
      .replaceAll('\u00e1', 'a')
      .replaceAll('\u00e3', 'a')
      .replaceAll('\u00e2', 'a')
      .replaceAll('\u00e9', 'e')
      .replaceAll('\u00ed', 'i')
      .replaceAll('\u00f3', 'o')
      .replaceAll('\u00f4', 'o')
      .replaceAll('\u00f5', 'o')
      .replaceAll('\u00fa', 'u')
      .replaceAll('\u00e7', 'c')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ');
  if (normalizedStatus.contains('entregue') ||
      normalizedStatus.contains('delivered') ||
      normalizedStatus.contains('conclu') ||
      normalizedStatus.contains('completed')) {
    return 1.0;
  }

  final explicit = apiProgress is num
      ? apiProgress.toDouble()
      : double.tryParse(
          '${apiProgress ?? ''}'.replaceAll('%', '').replaceAll(',', '.'),
        );
  if (explicit != null && explicit > 0) {
    final normalized = explicit > 1 ? explicit / 100 : explicit;
    return normalized.clamp(0.0, 1.0).toDouble();
  }

  if (normalizedStatus.contains('rota') ||
      normalizedStatus.contains('transito') ||
      normalizedStatus.contains('andamento') ||
      normalizedStatus.contains('despach') ||
      normalizedStatus.contains('delivery') ||
      normalizedStatus.contains('atras') ||
      normalizedStatus.contains('alerta')) {
    return 0.6;
  }
  if (normalizedStatus.contains('coletad') ||
      normalizedStatus.contains('colet') ||
      normalizedStatus.contains('separacao') ||
      normalizedStatus.contains('separad') ||
      normalizedStatus.contains('process') ||
      normalizedStatus.contains('prepar')) {
    return 0.3;
  }
  if (normalizedStatus.contains('pendente') ||
      normalizedStatus.contains('aguardando')) {
    return 0.05;
  }
  return 0.0;
}
