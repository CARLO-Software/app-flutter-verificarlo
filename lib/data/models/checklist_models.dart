enum ItemStatus { ok, observacion, defecto, noAplica }

enum CategoryType { legal, mecanica, carroceria, interior }

class InspectionCategory {
  final CategoryType type;
  final String name;
  final double weight;
  final List<InspectionItem> items;

  const InspectionCategory({
    required this.type,
    required this.name,
    required this.weight,
    required this.items,
  });

  static List<InspectionCategory> buildAll() => [
        InspectionCategory(
          type: CategoryType.legal,
          name: 'Legal',
          weight: 0.30,
          items: _legalItems,
        ),
        InspectionCategory(
          type: CategoryType.mecanica,
          name: 'Mecánica',
          weight: 0.40,
          items: _mecanicaItems,
        ),
        InspectionCategory(
          type: CategoryType.carroceria,
          name: 'Carrocería',
          weight: 0.30,
          items: _carroceriaItems,
        ),
        InspectionCategory(
          type: CategoryType.interior,
          name: 'Interior',
          weight: 0.00, // ponytail: interior no tiene peso en score, solo informativo según spec (weights sum 100% sin interior)
          items: _interiorItems,
        ),
      ];

  // Legal: 3 estados (sin Defecto)
  bool get isLegal => type == CategoryType.legal;
  List<ItemStatus> get allowedStatuses => isLegal
      ? [ItemStatus.ok, ItemStatus.observacion, ItemStatus.noAplica]
      : [ItemStatus.ok, ItemStatus.observacion, ItemStatus.defecto, ItemStatus.noAplica];
}

class InspectionItem {
  final String id;
  final String name;
  final List<String> obsChips;
  final List<String> defectoChips;

  const InspectionItem({
    required this.id,
    required this.name,
    this.obsChips = const [],
    this.defectoChips = const [],
  });
}

class ItemResult {
  final String itemId;
  ItemStatus? status;
  String comment;
  List<String> selectedChips;
  List<String> photoUrls;

  ItemResult({
    required this.itemId,
    this.status,
    this.comment = '',
    List<String>? selectedChips,
    List<String>? photoUrls,
  })  : selectedChips = selectedChips ?? [],
        photoUrls = photoUrls ?? [];

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'status': status?.name,
        'comment': comment,
        'selectedChips': selectedChips,
        'photoUrls': photoUrls,
      };

  factory ItemResult.fromJson(Map<String, dynamic> json) => ItemResult(
        itemId: json['itemId'] as String,
        status: json['status'] != null
            ? ItemStatus.values.byName(json['status'] as String)
            : null,
        comment: json['comment'] as String? ?? '',
        selectedChips: (json['selectedChips'] as List?)?.cast<String>() ?? [],
        photoUrls: (json['photoUrls'] as List?)?.cast<String>() ?? [],
      );
}

// --- Item definitions ---

const _legalItems = [
  InspectionItem(id: 'leg_01', name: 'SOAT vigente', obsChips: ['Próximo a vencer', 'Cobertura limitada']),
  InspectionItem(id: 'leg_02', name: 'Revisión técnica vigente', obsChips: ['Próximo a vencer', 'Observaciones previas']),
  InspectionItem(id: 'leg_03', name: 'Tarjeta de propiedad', obsChips: ['Datos incompletos', 'Duplicado']),
  InspectionItem(id: 'leg_04', name: 'DNI del titular', obsChips: ['No coincide', 'Vencido']),
  InspectionItem(id: 'leg_05', name: 'Certificado de gravamen', obsChips: ['Con gravamen', 'No disponible']),
  InspectionItem(id: 'leg_06', name: 'Contrato de compraventa', obsChips: ['Incompleto', 'Sin firmas']),
  InspectionItem(id: 'leg_07', name: 'Póliza de seguro', obsChips: ['Cobertura básica', 'Próximo a vencer']),
  InspectionItem(id: 'leg_08', name: 'Placa de rodaje', obsChips: ['Deteriorada', 'No legible']),
  InspectionItem(id: 'leg_09', name: 'Stickers y hologramas', obsChips: ['Faltante', 'Deteriorado']),
  InspectionItem(id: 'leg_10', name: 'Antecedentes policiales', obsChips: ['Con antecedentes', 'No verificado']),
  InspectionItem(id: 'leg_11', name: 'Penalidades SUNARP', obsChips: ['Con penalidades', 'No verificado']),
];

const _mecanicaItems = [
  InspectionItem(id: 'mec_01', name: 'Estado del motor', obsChips: ['Ruido leve', 'Vibración'], defectoChips: ['Fuga de aceite', 'Golpeteo fuerte', 'No enciende']),
  InspectionItem(id: 'mec_02', name: 'Nivel de aceite', obsChips: ['Bajo', 'Oscuro'], defectoChips: ['Vacío', 'Contaminado']),
  InspectionItem(id: 'mec_03', name: 'Nivel de refrigerante', obsChips: ['Bajo', 'Turbio'], defectoChips: ['Vacío', 'Fuga visible']),
  InspectionItem(id: 'mec_04', name: 'Batería', obsChips: ['Terminales oxidados', 'Carga baja'], defectoChips: ['No carga', 'Inflada', 'Sulfatada']),
  InspectionItem(id: 'mec_05', name: 'Frenos delanteros', obsChips: ['Desgaste medio', 'Ruido leve'], defectoChips: ['Pastillas gastadas', 'Disco dañado', 'Sin freno']),
  InspectionItem(id: 'mec_06', name: 'Frenos traseros', obsChips: ['Desgaste medio', 'Ruido leve'], defectoChips: ['Pastillas gastadas', 'Tambor dañado']),
  InspectionItem(id: 'mec_07', name: 'Freno de mano', obsChips: ['Flojo', 'Recorrido largo'], defectoChips: ['No funciona', 'Cable roto']),
  InspectionItem(id: 'mec_08', name: 'Suspensión delantera', obsChips: ['Ruido', 'Desgaste'], defectoChips: ['Amortiguador vencido', 'Rótula suelta']),
  InspectionItem(id: 'mec_09', name: 'Suspensión trasera', obsChips: ['Ruido', 'Desgaste'], defectoChips: ['Amortiguador vencido', 'Resorte roto']),
  InspectionItem(id: 'mec_10', name: 'Dirección', obsChips: ['Juego leve', 'Vibración'], defectoChips: ['Juego excesivo', 'Fuga hidráulica']),
  InspectionItem(id: 'mec_11', name: 'Transmisión / caja', obsChips: ['Cambio duro', 'Ruido'], defectoChips: ['No entra cambio', 'Fuga']),
  InspectionItem(id: 'mec_12', name: 'Embrague', obsChips: ['Punto alto', 'Patina leve'], defectoChips: ['Patina', 'No desembraga']),
  InspectionItem(id: 'mec_13', name: 'Sistema de escape', obsChips: ['Ruido leve', 'Oxidación'], defectoChips: ['Fuga de gases', 'Tubo roto']),
  InspectionItem(id: 'mec_14', name: 'Radiador', obsChips: ['Sucio', 'Fuga mínima'], defectoChips: ['Fuga importante', 'Obstruido']),
  InspectionItem(id: 'mec_15', name: 'Mangueras y correas', obsChips: ['Desgaste', 'Grietas menores'], defectoChips: ['Agrietada', 'Rota', 'Fuga']),
  InspectionItem(id: 'mec_16', name: 'Filtro de aire', obsChips: ['Sucio'], defectoChips: ['Obstruido', 'Roto']),
  InspectionItem(id: 'mec_17', name: 'Bujías', obsChips: ['Desgaste normal'], defectoChips: ['Dañadas', 'Incorrectas']),
  InspectionItem(id: 'mec_18', name: 'Sistema eléctrico', obsChips: ['Cables sueltos'], defectoChips: ['Cortocircuito', 'Fusibles quemados']),
];

const _carroceriaItems = [
  InspectionItem(id: 'car_01', name: 'Pintura general', obsChips: ['Rayones leves', 'Descolorida'], defectoChips: ['Repintada', 'Diferencia de tono', 'Ampolla']),
  InspectionItem(id: 'car_02', name: 'Abolladuras', obsChips: ['Menor', 'Superficial'], defectoChips: ['Múltiples', 'Severa', 'Estructural']),
  InspectionItem(id: 'car_03', name: 'Oxidación / corrosión', obsChips: ['Puntos aislados'], defectoChips: ['Extendida', 'Perforación']),
  InspectionItem(id: 'car_04', name: 'Parabrisas delantero', obsChips: ['Rajadura menor', 'Chip'], defectoChips: ['Rajadura extendida', 'Roto']),
  InspectionItem(id: 'car_05', name: 'Luneta trasera', obsChips: ['Rajadura menor'], defectoChips: ['Rota', 'Desempañador dañado']),
  InspectionItem(id: 'car_06', name: 'Ventanas laterales', obsChips: ['Rayada'], defectoChips: ['Rota', 'No sube/baja']),
  InspectionItem(id: 'car_07', name: 'Faros delanteros', obsChips: ['Opacidad leve', 'Humedad'], defectoChips: ['No funciona', 'Roto', 'No original']),
  InspectionItem(id: 'car_08', name: 'Faros traseros', obsChips: ['Humedad', 'Opaco'], defectoChips: ['No funciona', 'Roto']),
  InspectionItem(id: 'car_09', name: 'Espejos laterales', obsChips: ['Rayado'], defectoChips: ['Roto', 'Faltante', 'No ajusta']),
  InspectionItem(id: 'car_10', name: 'Parachoques delantero', obsChips: ['Rayado', 'Desalineado'], defectoChips: ['Roto', 'Faltante', 'Reparado']),
  InspectionItem(id: 'car_11', name: 'Parachoques trasero', obsChips: ['Rayado', 'Desalineado'], defectoChips: ['Roto', 'Faltante']),
  InspectionItem(id: 'car_12', name: 'Llantas y aros', obsChips: ['Desgaste parcial', 'Aro rayado'], defectoChips: ['Lisa', 'Dañada', 'Diferente medida']),
];

const _interiorItems = [
  InspectionItem(id: 'int_01', name: 'Tablero / dashboard', obsChips: ['Rayado', 'Testigo encendido'], defectoChips: ['Luces no funcionan', 'Fisura']),
  InspectionItem(id: 'int_02', name: 'Asiento conductor', obsChips: ['Desgaste', 'Mancha'], defectoChips: ['Roto', 'No ajusta', 'Estructura dañada']),
  InspectionItem(id: 'int_03', name: 'Asiento copiloto', obsChips: ['Desgaste', 'Mancha'], defectoChips: ['Roto', 'No ajusta']),
  InspectionItem(id: 'int_04', name: 'Asientos traseros', obsChips: ['Desgaste', 'Mancha'], defectoChips: ['Roto', 'No reclinan']),
  InspectionItem(id: 'int_05', name: 'Cinturones de seguridad', obsChips: ['Retracción lenta'], defectoChips: ['No funciona', 'Cortado', 'Trabado']),
  InspectionItem(id: 'int_06', name: 'Volante', obsChips: ['Desgaste', 'Juego leve'], defectoChips: ['Juego excesivo', 'Dañado']),
  InspectionItem(id: 'int_07', name: 'Aire acondicionado', obsChips: ['Enfría poco', 'Ruido'], defectoChips: ['No funciona', 'Fuga de gas']),
  InspectionItem(id: 'int_08', name: 'Sistema de audio', obsChips: ['Parlante dañado'], defectoChips: ['No funciona', 'No original']),
  InspectionItem(id: 'int_09', name: 'Ventanas eléctricas', obsChips: ['Lenta'], defectoChips: ['No funciona', 'Trabada']),
  InspectionItem(id: 'int_10', name: 'Seguros eléctricos', obsChips: ['Intermitente'], defectoChips: ['No funciona']),
  InspectionItem(id: 'int_11', name: 'Tapicería', obsChips: ['Desgaste', 'Mancha'], defectoChips: ['Rota', 'Quemadura']),
  InspectionItem(id: 'int_12', name: 'Alfombras', obsChips: ['Desgaste', 'Manchada'], defectoChips: ['Rota', 'Faltante', 'Humedad']),
  InspectionItem(id: 'int_13', name: 'Maletero', obsChips: ['Sucio', 'Humedad'], defectoChips: ['Bisagra dañada', 'No cierra', 'Oxidado']),
];
