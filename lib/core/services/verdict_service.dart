class VerdictService {
  /// If hasSiniestro or hasKmAdulterado → force NO_APROBADO
  static String finalVerdict({
    required String calculatedStatus,
    required bool hasSiniestro,
    required bool hasKmAdulterado,
  }) {
    if (hasSiniestro || hasKmAdulterado) return 'NO_APROBADO';
    return calculatedStatus;
  }
}
