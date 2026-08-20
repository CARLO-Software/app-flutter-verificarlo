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

  // ponytail: subcategory-level chips, per-item obsChips/defectoChips override when populated
  List<String> quickChipsFor(ItemStatus status) {
    if (status == ItemStatus.defecto) {
      return defectoChips.isNotEmpty
          ? defectoChips
          : _defectoChipsBySubcategory[subcategory] ?? [];
    }
    return obsChips.isNotEmpty
        ? obsChips
        : _obsChipsBySubcategory[subcategory] ?? [];
  }

  List<String> get quickChips => quickChipsFor(ItemStatus.observacion);
}

const _obsChipsBySubcategory = <String, List<String>>{
  'Documentación': ['Próximo a vencer', 'No porta', 'Deteriorado'],
  'Identificación': ['Difícil lectura', 'Desgastado'],
  'Accesorios y elementos obligatorios': ['Incompleto', 'Desgastado', 'Requiere cambio'],
  'Motor': ['Fuga leve', 'Nivel bajo', 'Ruido anormal', 'Requiere cambio'],
  'Parte inferior del vehículo': ['Fuga leve', 'Corrosión leve', 'Golpe menor', 'Óxido superficial'],
  'Suspensión y dirección': ['Holgura leve', 'Ruido al girar', 'Vibración leve', 'Desgaste parcial'],
  'Sistema de frenos': ['Desgaste parcial', 'Ruido leve al frenar', 'Pastillas bajas'],
  'Prueba de ruta': ['Vibración leve', 'Ruido leve', 'Tira levemente', 'Respuesta lenta'],
  'Estructura y alineación': ['Desalineado leve', 'Repintado parcial', 'Masillado leve', 'Golpe menor'],
  'Pintura y superficie': ['Rayón superficial', 'Descolorido', 'Burbuja', 'Repintado parcial'],
  'Lunas y parabrisas': ['Rajadura pequeña', 'Chip menor', 'Empañado'],
  'Luces exteriores': ['Empañado', 'Opaco', 'Luz tenue'],
  'Neumáticos y aros': ['Desgaste irregular', 'Presión baja', 'Agrietado leve'],
  'Sistemas funcionales': ['Respuesta lenta', 'Ruidoso', 'Funciona parcial'],
  'Seguridad interior': ['Trabado', 'Flojo', 'Testigo encendido'],
  'Estética interior': ['Manchado', 'Desgaste leve', 'Rayón', 'Suciedad'],
};

const _defectoChipsBySubcategory = <String, List<String>>{
  'Documentación': ['Falsificado', 'Ausente', 'Vencido sin renovar'],
  'Identificación': ['Adulterado', 'No corresponde', 'Regrabado'],
  'Accesorios y elementos obligatorios': ['Ausente', 'Inoperativo', 'Dañado'],
  'Motor': ['Fuga severa', 'Golpeteo interno', 'Humo excesivo', 'No enciende'],
  'Parte inferior del vehículo': ['Fuga severa', 'Corrosión estructural', 'Golpe profundo', 'Perforación'],
  'Suspensión y dirección': ['Holgura severa', 'Componente roto', 'Dirección dura', 'Amortiguador vencido'],
  'Sistema de frenos': ['Sin freno', 'Disco fisurado', 'Pastillas gastadas', 'Fuga de líquido'],
  'Prueba de ruta': ['Vibración fuerte', 'Ruido fuerte', 'No frena bien', 'Caja patina'],
  'Estructura y alineación': ['Chasis doblado', 'Soldadura estructural', 'Golpe severo', 'Siniestro previo'],
  'Pintura y superficie': ['Golpe profundo', 'Corrosión', 'Abolladura severa', 'Óxido pasante'],
  'Lunas y parabrisas': ['Rajadura completa', 'Luna rota', 'Filtración de agua'],
  'Luces exteriores': ['No funciona', 'Faro roto', 'Cableado dañado'],
  'Neumáticos y aros': ['Llanta lisa', 'Aro doblado', 'Grieta profunda', 'Llanta reencauchada'],
  'Sistemas funcionales': ['No funciona', 'Cortocircuito', 'Error crítico scanner'],
  'Seguridad interior': ['Cinturón roto', 'Airbag inactivo', 'Testigo crítico'],
  'Estética interior': ['Rasgado severo', 'Roto', 'Quemadura', 'Pieza faltante'],
};

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
  InspectionItem(id: 'legal-tarjeta-propiedad', name: 'Tarjeta de propiedad', subcategory: 'Documentación'),
  InspectionItem(id: 'legal-revision-tecnica', name: 'Certificado de revisión técnica vehicular', subcategory: 'Documentación'),
  InspectionItem(id: 'legal-soat', name: 'SOAT vigente', subcategory: 'Documentación'),
  InspectionItem(id: 'legal-permiso-lunas', name: 'Permiso de lunas polarizadas', subcategory: 'Documentación'),
  InspectionItem(id: 'legal-manual-instrucciones', name: 'Manual de instrucciones', subcategory: 'Documentación'),
  InspectionItem(id: 'legal-cartilla-servicio', name: 'Cartilla de servicio', subcategory: 'Documentación'),
  // Identificación (1)
  InspectionItem(id: 'legal-vin-placa', name: 'Coincidencia VIN / placa', subcategory: 'Identificación'),
  // Accesorios y elementos obligatorios (4)
  InspectionItem(id: 'legal-llaves', name: '2 llaves disponibles', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'legal-llanta-repuesto', name: 'Llanta de repuesto con herramientas', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'legal-tapa-maletera', name: 'Tapa de maletera', subcategory: 'Accesorios y elementos obligatorios'),
  InspectionItem(id: 'legal-seguro-aros', name: 'Seguro de aros', subcategory: 'Accesorios y elementos obligatorios'),
];

// --- Mecánica: 19 ítems ---

const _mecanicaItems = [
  // Motor (9)
  InspectionItem(id: 'mec-sonidos-motor', name: 'Sonidos del motor', subcategory: 'Motor'),
  InspectionItem(id: 'mec-fugas-aceite', name: 'Fugas de aceite', subcategory: 'Motor'),
  InspectionItem(id: 'mec-fugas-refrigerante', name: 'Fugas de refrigerante', subcategory: 'Motor'),
  InspectionItem(id: 'mec-prueba-gas', name: 'Prueba de gas', subcategory: 'Motor'),
  InspectionItem(id: 'mec-nivel-aceite-motor', name: 'Nivel de aceite motor', subcategory: 'Motor'),
  InspectionItem(id: 'mec-nivel-aceite-caja', name: 'Nivel de aceite de caja', subcategory: 'Motor'),
  InspectionItem(id: 'mec-nivel-refrigerante', name: 'Nivel de refrigerante', subcategory: 'Motor'),
  InspectionItem(id: 'mec-sin-manipulacion', name: 'Motor sin señales de manipulación', subcategory: 'Motor'),
  InspectionItem(id: 'mec-estado-bateria', name: 'Estado de batería', subcategory: 'Motor'),
  // Parte inferior del vehículo (4)
  InspectionItem(id: 'mec-fugas-inferiores', name: 'Fugas inferiores de motor o transmisión', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec-golpes-suspension', name: 'Golpes en suspensión o estructura inferior', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec-tubo-escape', name: 'Estado del tubo de escape', subcategory: 'Parte inferior del vehículo'),
  InspectionItem(id: 'mec-oxido-estructural', name: 'Señales de óxido estructural', subcategory: 'Parte inferior del vehículo'),
  // Suspensión y dirección (2)
  InspectionItem(id: 'mec-funcionamiento-suspension', name: 'Estado de suspensión', subcategory: 'Suspensión y dirección'),
  InspectionItem(id: 'mec-direccion', name: 'Dirección', subcategory: 'Suspensión y dirección'),
  // Sistema de frenos (1)
  InspectionItem(id: 'mec-funcionamiento-frenos', name: 'Funcionamiento de frenos', subcategory: 'Sistema de frenos'),
  // Prueba de ruta (3)
  InspectionItem(id: 'mec-vibracion-ruido-freno', name: 'Vibración o ruido al frenar', subcategory: 'Prueba de ruta'),
  InspectionItem(id: 'mec-funcionamiento-caja', name: 'Funcionamiento de transmisión', subcategory: 'Prueba de ruta'),
  InspectionItem(id: 'mec-comportamiento-conduccion', name: 'Comportamiento general en conducción', subcategory: 'Prueba de ruta'),
];

// --- Carrocería: 12 ítems ---

const _carroceriaItems = [
  // Estructura y alineación (3)
  InspectionItem(id: 'car-alineacion-puertas', name: 'Alineación de puertas, capot y carrocería', subcategory: 'Estructura y alineación'),
  InspectionItem(id: 'car-senales-accidentes', name: 'Señales de accidentes o reparaciones', subcategory: 'Estructura y alineación'),
  InspectionItem(id: 'car-soldaduras-intervenciones', name: 'Soldaduras o intervenciones estructurales visibles', subcategory: 'Estructura y alineación'),
  // Pintura y superficie (2)
  InspectionItem(id: 'car-estado-pintura', name: 'Estado general de pintura', subcategory: 'Pintura y superficie'),
  InspectionItem(id: 'car-rayones-golpes', name: 'Rayones o golpes visibles', subcategory: 'Pintura y superficie'),
  // Lunas y parabrisas (2)
  InspectionItem(id: 'car-estado-parabrisas', name: 'Estado del parabrisas', subcategory: 'Lunas y parabrisas'),
  InspectionItem(id: 'car-lunas-laterales-trasera', name: 'Estado de lunas laterales y trasera', subcategory: 'Lunas y parabrisas'),
  // Luces exteriores (3)
  InspectionItem(id: 'car-faros-delanteros', name: 'Faros delanteros', subcategory: 'Luces exteriores'),
  InspectionItem(id: 'car-faros-traseros', name: 'Faros traseros', subcategory: 'Luces exteriores'),
  InspectionItem(id: 'car-focos-halogenados', name: 'Focos halógenos reglamentarios', subcategory: 'Luces exteriores'),
  // Neumáticos y aros (2)
  InspectionItem(id: 'car-estado-neumaticos', name: 'Estado de neumáticos', subcategory: 'Neumáticos y aros'),
  InspectionItem(id: 'car-estado-aros', name: 'Estado de aros', subcategory: 'Neumáticos y aros'),
];

// --- Interior: 13 ítems ---

const _interiorItems = [
  // Sistemas funcionales (7)
  InspectionItem(id: 'int-revision-scanner', name: 'Resultado de revisión de scanner', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-panel-multimedia', name: 'Funcionamiento de panel central / multimedia', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-comando-luces', name: 'Funcionamiento de comando de luces', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-aire-acondicionado', name: 'Funcionamiento de aire acondicionado', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-elevalunas', name: 'Funcionamiento de elevalunas', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-limpia-parabrisas', name: 'Funcionamiento de limpia parabrisas', subcategory: 'Sistemas funcionales'),
  InspectionItem(id: 'int-asientos', name: 'Funcionalidad de asientos', subcategory: 'Sistemas funcionales'),
  // Seguridad interior (2)
  InspectionItem(id: 'int-cinturones', name: 'Cinturones de seguridad', subcategory: 'Seguridad interior'),
  InspectionItem(id: 'int-testigos-tablero', name: 'Testigos de tablero', subcategory: 'Seguridad interior'),
  // Estética interior (4)
  InspectionItem(id: 'int-estado-molduras', name: 'Estado de molduras', subcategory: 'Estética interior'),
  InspectionItem(id: 'int-desgaste-asientos', name: 'Desgaste de asientos', subcategory: 'Estética interior'),
  InspectionItem(id: 'int-estado-alfombra', name: 'Estado de alfombra', subcategory: 'Estética interior'),
  InspectionItem(id: 'int-estado-techo', name: 'Estado de techo', subcategory: 'Estética interior'),
];
