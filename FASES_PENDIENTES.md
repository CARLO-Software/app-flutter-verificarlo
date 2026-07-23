# Fases pendientes — App Inspector VerifiCARLO

## Fase 2: Formulario de Inspección + Checklist + Fotos

**Dependencias nuevas:** `image_picker`, `hive_flutter`, `speech_to_text`, `path_provider`

### Archivos a crear

1. **Models:**
   - `checklist_models.dart` — InspectionCategory, InspectionItem, ItemResult con los 54 ítems (Legal 11, Mecánica 18, Carrocería 12, Interior 13)
   - `inspection_report_model.dart` — fromJson del GET `/api/reports/[id]`
   - `inspection_photo_model.dart`

2. **Services (lógica pura):**
   - `checklist_service.dart` — scoring por categoría (OK×100 + OBS×50) / total, status general = peor de todos, pesos Legal 30% Mecánica 40% Carrocería 30%
   - `verdict_service.dart` — si hasSiniestro o hasKmAdulterado → fuerza NO_APROBADO

3. **Repositories:**
   - `report_repository.dart` — GET/PATCH `/api/reports/[id]`, PATCH `/api/reports/[id]/sections`
   - `photo_repository.dart` — POST upload (FormData multipart), DELETE `/api/photos/[id]`

4. **Providers:**
   - `inspection_controller.dart` — estado del formulario 3 tabs
   - `checklist_controller.dart` — autoguardado debounce 500ms, backup Hive, cola de sync offline
   - `photo_controller.dart` — captura cámara/galería, upload, eliminar

5. **Screens:**
   - `inspection_screen.dart` — 3 tabs (Info, Checklist, Resumen) con TabBarView
   - `info_tab.dart` — datos solo lectura + registro de placa (PATCH mechanic action=register_plate), formato peruano AAA-123
   - `checklist_tab.dart` — 4 categorías scrolleables horizontal, por cada ítem: 4 botones estado (3 para Legal sin Defecto), chips predefinidos, textarea, botón voz, fotos (max 5/ítem), barra progreso X/Y (Z%), botón "Todo OK" por sección
   - `summary_tab.dart` — score circular, grid categorías, kilometraje real, resumen ejecutivo (textarea+dictado), costo estimado S/, checkboxes siniestro/km adulterado, radio veredicto, botón Finalizar → POST `/api/reports/[id]/complete`

6. **Widgets:**
   - `status_buttons.dart` — OK/Observación/Defecto/NoAplica con toggle
   - `comment_chips.dart` — chips predefinidos por tipo (observación vs defecto)
   - `photo_capture.dart` — cámara trasera + galería, grid thumbnails, lightbox, eliminar con confirmación
   - `voice_button.dart` — speech-to-text es-PE
   - `score_circle.dart` — indicador circular animado con color por status

7. **Storage:**
   - `local_storage.dart` — Hive boxes para checklist offline, cola de sync

8. **Sync:**
   - `sync_service.dart` — al abrir app revisa pendientes, al perder conexión encola, al recuperar envía. Indicador flotante "Guardando..."/"Guardado"

9. **Backend:**
   - Actualizar `verifyInspectorAccess()` en reports.server.ts para usar `getAuthUser` dual
   - Rutas afectadas: POST reports, PATCH reports/[id], PATCH sections, POST complete, POST photos/upload, DELETE photos

---

## Fase 3: Notificaciones + Agenda + Settings

**Dependencias nuevas:** `firebase_messaging` (opcional, puede empezar con polling)

### 1. Notificaciones
- `notification_model.dart`
- `notification_repository.dart` — GET/PATCH/DELETE endpoints
- `notification_provider.dart` — polling 30s, badge conteo no leídas
- `notification_screen.dart` — agrupadas por "Próxima hora"/"Hoy"/"Esta semana"/"Anteriores", click navega a inspección
- `notification_bell.dart` widget — badge en AppBar del dashboard
- Backend: actualizar rutas `/api/notifications/*` para auth dual

### 2. Agenda
- `schedule_repository.dart` — GET/PATCH `/api/inspector/schedule`
- `schedule_provider.dart`
- `schedule_screen.dart` — vista por día/semana, bookings agrupados por fecha
- Backend: actualizar ruta `/api/inspector/schedule` para auth dual

### 3. Settings
- `settings_screen.dart` — cambio contraseña (8+ chars, mayúscula, minúscula, número, especial), editar perfil
- Backend: actualizar `/api/user/change-password` y `/api/user/profile` para auth dual

### 4. Navegación
- Agregar BottomNavigationBar al dashboard: Inicio / Agenda / Notificaciones / Perfil

### 5. Backend general
- Crear helper reutilizable que reemplace todos los `getServerSession(authOptions)` restantes con `getAuthUser(request)` en las rutas que usa la app Flutter
