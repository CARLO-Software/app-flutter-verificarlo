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
          weight: 0.00, // ponytail: interior no tiene peso en score, solo informativo
          items: _interiorItems,
        ),
      ];

  List<ItemStatus> get allowedStatuses =>
      [ItemStatus.ok, ItemStatus.observacion, ItemStatus.defecto, ItemStatus.noAplica];

  /// Items grouped by subcategory, preserving order.
  Map<String, List<InspectionItem>> get itemsBySubcategory {
    final map = <String, List<InspectionItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.subcategory, () => []).add(item);
    }
    return map;
  }
}

class InspectionItem {
  final String id;
  final String name;
  final String subcategory;
  final List<String> obsChips;
  final List<String> defectoChips;

  const InspectionItem({
    required this.id,
    required this.name,
    required this.subcategory,
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

// --- Legal: 11 ítems ---

const _legalItems = [
  // Documentación (6)
  InspectionItem(id: 'leg_01', name: 'Tarjeta de propiedad', subcategory: 'Documentación'),
  InspectionItem(id: 'leg_02', name: 'Certificado de revisión técnica vehicular', subcategory: 'Documentación'),
  InspectionItem(id: 'leg_03', name: 'SOAT vigente', subcategory: 'Documentación'),
  InspectionItem(id: 'leg_04', name: 'Permiso de lunas polarizadas', subcategory: 'Documentación'),
  InspectionItem(id: 'leg_05', name: 'Manual de instrucciones', subcategory: 'Documentación'),
  InspectionItem(id: 'leg_06', name: 'Cartilla de servicio', subcategory: 'Documentación'),
  // Identificación (1)
  InspectionItem(id: 'leg_07', name: 'Coincidencia VIN / placa', subcategory: 'Identificación'),
  // Accesorios y elementos obligatorios (4)
  InspectionItem(id: 'leg_08', name: '2 llaves disponibles', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'leg_09', name: 'Llanta de repuesto con herramientas', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'leg_10', name: 'Tapa de maletera', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'leg_11', name: 'Seguro de aros', subcategory: 'Accesorios y elementos obligatorios'),
];

// --- Mecánica: 19 ítems ---

const _mecanicaItems = [
  // Motor (9)
  InspectionItem(id: 'mec_01', name: 'Sonidos del motor', subcategory: 'Motor'),
  InspectionItem(id: 'mec_02', name: 'Fugas de aceite', subcategory: 'Motor'),
  InspectionItem(id: 'mec_03', name: 'Fugas de refrigerante', subcategory: 'Motor'),
  InspectionItem(id: 'mec_04', name: 'Prueba de gas', subcategory: 'Motor'),
  InspectionItem(id: 'mec_05', name: 'Nivel de aceite motor', subcategory: 'Motor'),
  InspectionItem(id: 'mec_06', name: 'Nivel de aceite de caja', subcategory: 'Motor'),
  InspectionItem(id: 'mec_07', name: 'Nivel de refrigerante', subcategory: 'Motor'),
  InspectionItem(id: 'mec_08', name: 'Motor sin señales de manipulación', subcategory: 'Motor'),
  InspectionItem(id: 'mec_09', name: 'Estado de batería', subcategory: 'Motor'),
  // Parte inferior del vehículo (4)
  InspectionItem(id: 'mec_10', name: 'Fugas inferiores de motor o transmisión', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec_11', name: 'Golpes en suspensión o estructura inferior', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec_12', name: 'Estado del tubo de escape', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec_13', name: 'Señales de óxido estructural', subcategory: 'Parte inferior del vehículo'),
  // Suspensión y dirección (2)
  InspectionItem(id: 'mec_14', name: 'Estado de suspensión', subcategory: 'Suspensión y dirección'),
  InspectionItem(id: 'mec_15', name: 'Dirección', subcategory: 'Suspensión y dirección'),
  // Sistema de frenos (1)
  InspectionItem(id: 'mec_16', name: 'Funcionamiento de frenos', subcategory: 'Sistema de frenos'),
  // Prueba de ruta (3)
  InspectionItem(id: 'mec_17', name: 'Vibración o ruido al frenar', subcategory: 'Prueba de ruta'),
  InspectionItem(id: 'mec_18', name: 'Funcionamiento de transmisión', subcategory: 'Prueba de ruta'),
  InspectionItem(id: 'mec_19', name: 'Comportamiento general en conducción', subcategory: 'Prueba de ruta'),
];

// --- Carrocería: 12 ítems ---

const _carroceriaItems = [
  // Estructura y alineación (3)
  InspectionItem(id: 'car_01', name: 'Alineación de puertas, capot y carrocería', subcategory: 'Estructura y alineación'),
  InspectionItem(id: 'car_02', name: 'Señales de accidentes o reparaciones', subcategory: 'Estructura y alineación'),
  InspectionItem(id: 'car_03', name: 'Soldaduras o intervenciones estructurales visibles', subcategory: 'Estructura y alineación'),
  // Pintura y superficie (2)
  InspectionItem(id: 'car_04', name: 'Estado general de pintura', subcategory: 'Pintura y superficie'),
  InspectionItem(id: 'car_05', name: 'Rayones o golpes visibles', subcategory: 'Pintura y superficie'),
  // Lunas y parabrisas (2)
  InspectionItem(id: 'car_06', name: 'Estado del parabrisas', subcategory: 'Lunas y parabrisas'),
  InspectionItem(id: 'car_07', name: 'Estado de lunas laterales y trasera', subcategory: 'Lunas y parabrisas'),
  // Luces exteriores (3)
  InspectionItem(id: 'car_08', name: 'Faros delanteros', subcategory: 'Luces exteriores'),
  InspectionItem(id: 'car_09', name: 'Faros traseros', subcategory: 'Luces exteriores'),
  InspectionItem(id: 'car_10', name: 'Focos halógenos reglamentarios', subcategory: 'Luces exteriores'),
  // Neumáticos y aros (2)
  InspectionItem(id: 'car_11', name: 'Estado de neumáticos', subcategory: 'Neumáticos y aros'),
  InspectionItem(id: 'car_12', name: 'Estado de aros', subcategory: 'Neumáticos y aros'),
];

// --- Interior: 13 ítems ---

const _interiorItems = [
  // Sistemas funcionales (7)
  InspectionItem(id: 'int_01', name: 'Resultado de revisión de scanner', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_02', name: 'Funcionamiento de panel central / multimedia', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_03', name: 'Funcionamiento de comando de luces', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_04', name: 'Funcionamiento de aire acondicionado', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_05', name: 'Funcionamiento de elevalunas', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_06', name: 'Funcionamiento de limpia parabrisas', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int_07', name: 'Funcionalidad de asientos', subcategory: 'Sistemas funcionales'),
  // Seguridad interior (2)
  InspectionItem(id: 'int_08', name: 'Cinturones de seguridad', subcategory: 'Seguridad interior'),
  InspectionItem(id: 'int_09', name: 'Testigos de tablero', subcategory: 'Seguridad interior'),
  // Estética interior (4)
  InspectionItem(id: 'int_10', name: 'Estado de molduras', subcategory: 'Estética interior'),
  InspectionItem(id: 'int_11', name: 'Desgaste de asientos', subcategory: 'Estética interior'),
  InspectionItem(id: 'int_12', name: 'Estado de alfombra', subcategory: 'Estética interior'),
  InspectionItem(id: 'int_13', name: 'Estado de techo', subcategory: 'Estética interior'),
];
