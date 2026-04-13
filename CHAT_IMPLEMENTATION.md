# 🚀 Sistema de Chat - IntellivIAtge

## ✅ Estado Actual: Implementación Completa

### **Phase 1: Foundation (Completado)**
- ✅ **Modelos de datos** en `lib/models/types.dart`:
  - `UserProfile` - Perfiles de usuario con estado online/offline
  - `Message` - Mensajes de texto con estados (enviado/entregado/leído)
  - `Conversation` - Conversaciones directas y grupales
  - `GroupMetadata` - Metadata de grupos
  - `FriendRequest` - Solicitudes de amistad con estados
  - Todos con serialización Firestore (`toMap()`/`fromMap()`)

- ✅ **Firebase Security Rules** documentadas en `FIREBASE_RULES.md`

### **Phase 2: Service Layer (Completado)**
- ✅ **ChatService** (`lib/services/chat_service.dart`):
  - Polling cada 5s para mensajes, 10s para conversaciones
  - Envío de mensajes de texto
  - Creación de conversaciones directas y grupos
  - Indicadores de "está escribiendo"
  - Marcar mensajes como leídos con timestamps
  - StreamControllers para updates reactivos

- ✅ **UserService** (`lib/services/user_service.dart`):
  - Búsqueda de usuarios por email (búsqueda flexible, funciona con cualquier parte del email)
  - Crear/actualizar perfiles en Firestore al login/registro
  - Sistema completo de solicitudes de amistad:
    - Enviar solicitud (`sendFriendRequest`)
    - Ver solicitudes pendientes recibidas (`getPendingFriendRequests`)
    - Aceptar/rechazar solicitudes (`acceptFriendRequest`, `rejectFriendRequest`)
    - Obtener lista de amigos (`getFriends`)
  - Estado de presencia online/offline

### **Phase 3: UI Completamente Integrada**
- ✅ **Dependencias instaladas**:
  - `cloud_firestore ^6.2.0` (solo texto - sin storage)
  - `firebase_auth ^6.3.0`
  - `firebase_core ^4.6.0`

- ✅ **login_screen.dart** actualizado:
  - Al registrarse o hacer login, crea perfil en Firestore
  - Establece estado online automáticamente

- ✅ **groups_screen.dart** completamente funcional:
  - **Tab Chats**: Lista conversaciones 1-1 y grupos desde Firebase
  - **Tab Grupos**: Filtra solo conversaciones grupales
  - **Tab Amigos**: 
    - 🆕 Sección "Solicitudes Pendientes" con botones Aceptar/Rechazar (fondo naranja)
    - Lista de amigos aceptados
    - Botón "Añadir Amigo" para buscar usuarios
  - **Vista de Chat**: 
    - Mensajes en tiempo real con polling
    - Indicador de "está escribiendo"
    - Estados de mensaje (✓, ✓✓, ✓✓ azul)
    - Formato de timestamps ("Ahora", "15min", "10:42", "Lun", "12/3")
  - **Búsqueda de usuarios**:
    - Busca por email (parte del texto, no solo prefijo)
    - Muestra resultados con botón "Añadir"
  - **Creación de grupos**:
    - Selección múltiple de amigos con checkboxes
    - Campo de nombre de grupo
    - Botón "Crear Grupo"

---

## 🔧 Pasos para Testing

### **1️⃣ Configurar Firebase Console** ⚠️ **CRÍTICO**

**A. Aplicar Reglas de Prueba en Firestore:**

1. Abre https://console.firebase.google.com/project/intelliviaje/firestore
2. Ve a **"Rules"** (Reglas)
3. Reemplaza con estas reglas de **SOLO TESTING**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

4. Click **"Publish"** (Publicar)

⚠️ **IMPORTANTE**: Estas reglas son SOLO para desarrollo. Antes de producción, usa las reglas completas de `FIREBASE_RULES.md`.

**B. Verificar Authentication:**

1. Ve a https://console.firebase.google.com/project/intelliviaje/authentication
2. Pestaña **"Sign-in method"**
3. Asegúrate que **"Email/Password"** esté **Enabled** ✅

---

### **2️⃣ Testing del Sistema de Chat**

#### **A. Preparar usuarios (si no están en Firestore):**

Para que los usuarios aparezcan en búsquedas, deben existir en Firestore. Si ya creaste usuarios antes de esta actualización:

1. **Cierra sesión** en la app
2. **Vuelve a hacer login** con cada cuenta → Esto crea el documento en Firestore
3. Repite con las 3 cuentas

#### **B. Probar flujo de solicitudes de amistad:**

**Usuario A:**
1. Ve a tab **"Amigos"** → botón **"+"** (verde, esquina inferior derecha)
2. Busca usuario B por email (ej: buscar `test` encuentra `usuario@test.com`)
3. Tap **"Añadir"** → Solicitud enviada

**Usuario B:**
1. Ve a tab **"Amigos"**
2. Deberías ver sección **"SOLICITUDES PENDIENTES"** (fondo naranja) con Usuario A
3. Tap icono **✓ (verde)** para aceptar
4. Usuario A aparece ahora en **"MIS AMIGOS"**

**Usuario A:**
1. Refresca o espera ~10s (polling automático)
2. Usuario B aparece en **"MIS AMIGOS"**

#### **C. Probar chat 1-1:**

**Usuario A:**
1. En tab **"Amigos"**, tap en Usuario B
2. Se crea conversación y abre chat automáticamente
3. Escribe mensaje → Tap botón enviar (flecha)
4. Deberías ver ✓ (enviado)

**Usuario B:**
1. En tab **"Chats"**, nueva conversación con Usuario A aparece en ~5-10s
2. Tap para abrir
3. Ver mensaje de Usuario A
4. El mensaje de A cambia a ✓✓ (azul) = leído

#### **D. Probar grupos:**

**Usuario A:**
1. Tab **"Amigos"** → botón **"+"**
2. Marcar checkboxes de Usuario B y Usuario C
3. Escribir nombre de grupo: "Viaje Barcelona"
4. Tap **"Crear Grupo"**
5. Grupo aparece automáticamente en tab **"Grupos"**

**Todos los usuarios:**
1. Grupo aparece en sus tabs **"Grupos"** en ~10s (polling)
2. Pueden enviar mensajes visibles para todos
3. Nombre del grupo aparece en la cabecera

#### **E. Probar indicador de escritura:**

**Usuario A:**
1. Abrir chat con Usuario B
2. Empezar a escribir (sin enviar)

**Usuario B:**
1. En el mismo chat, dentro de ~2-3 segundos
2. Ver **"está escribiendo..."** debajo de los mensajes

---

## 📊 Métricas de Firebase Free Tier

El plan gratuito incluye:
- **Firestore**: 1 GB storage, 50k reads/día, 20k writes/día, 20k deletes/día
- **Authentication**: Ilimitado

Con **solo texto**, el consumo es mínimo:
- 1 mensaje ≈ 1 KB
- 1000 mensajes/día ≈ 1 MB
- Búsquedas de usuario ≈ 5 reads cada una
- Polling: ~10-20 reads/minuto por usuario activo

**Estimación**: 10-20 usuarios activos con ~100 mensajes/día están bien dentro del límite gratuito.

---

## 🐛 Troubleshooting

### "No aparecen usuarios en búsqueda"
- ✅ Verifica que los usuarios hayan hecho **login** (no solo registro) después de la última actualización
- ✅ Busca con correo completo o parte de él: `@test`, `usuario`, etc.
- ✅ Revisa Firebase Console → Firestore → colección `users` → deberías ver documentos con campos: `id`, `name`, `email`, `status`, `lastSeen`

### "No aparecen las solicitudes de amistad"
- ✅ Verifica que el usuario B tenga solicitudes enviadas desde A
- ✅ El tab **"Amigos"** debe mostrar sección **"SOLICITUDES PENDIENTES"** (naranja) si hay pending
- ✅ Revisa Firebase Console → Firestore → colección `friendRequests` → debe tener documentos con:
  - `fromUserId`: ID del usuario que envió
  - `toUserId`: ID del usuario que recibe
  - `status`: "pending"
- ✅ Espera ~10 segundos para que el polling actualice (o cierra y abre la app)

### "Solicitudes aceptadas pero no aparecen como amigos"
- ✅ Verifica que el documento en `friendRequests` tenga `status: 'accepted'`
- ✅ Cierra sesión y vuelve a entrar
- ✅ El método `getFriends()` busca solicitudes con status `accepted` donde eres `fromUserId` O `toUserId`

### "Mensajes no aparecen"
- ✅ Verifica reglas de Firestore (paso 1 arriba) - deben estar en modo `allow read, write: if true`
- ✅ Ambos usuarios deben ser amigos primero
- ✅ Espera 5 segundos (polling automático)
- ✅ Revisa consola Flutter para errores: `flutter logs` en terminal

### "Error: requires an index"
- Firestore te dará un link directo en el error de consola
- Click en el link → Firebase crea el índice automáticamente
- Espera 1-2 minutos → Reintentar operación
- Índices comunes:
  - `conversations`: `participantIds` (array) + `updatedAt` (descending)
  - `messages`: `conversationId` + `timestamp` (descending)
  - `friendRequests`: `toUserId` + `status` + `createdAt`

### "Indicador de escritura no aparece"
- ✅ Verifica que ambos usuarios estén en el mismo chat
- ✅ El polling tarda ~2-3 segundos en detectar cambios
- ✅ Revisa colección `typing/{conversationId}/{userId}` en Firestore

---

## 🎯 Flujo Completo de Usuario

1. **Registro/Login** → Crea perfil en Firestore, estado `online`
2. **Buscar usuarios** → Tab Amigos → + → Escribir email parcial
3. **Enviar solicitud** → Tap "Añadir" en resultado
4. **Aceptar solicitud** → Otro usuario ve sección naranja → Tap ✓
5. **Chatear 1-1** → Tap en amigo → Conversación se crea → Enviar mensajes
6. **Crear grupo** → Tab Amigos → + → Seleccionar amigos → Nombre → Crear
7. **Chat de grupo** → Tab Grupos → Tap grupo → Todos pueden enviar/recibir

---

## 📝 Próximos Pasos Opcionales (No Implementados)

Mejoras futuras:
- [ ] Notificaciones push (Firebase Cloud Messaging)
- [ ] Imágenes en mensajes (requiere Firebase Storage - tiene costo)
- [ ] Ubicación en tiempo real (requiere geolocator)
- [ ] Llamadas de voz/video (WebRTC)
- [ ] Búsqueda full-text de mensajes (Algolia o similar)
- [ ] Modo offline con cache local (Hive/SQLite)
- [ ] Eliminación de conversaciones
- [ ] Administración de grupos (añadir miembros después de crear)
- [ ] Fotos de perfil personalizadas
- [ ] Reacciones a mensajes (emojis)

---

## 🎉 Estado Final

✅ **Sistema de chat 100% funcional con:**
- ✅ Autenticación Firebase (login/registro)
- ✅ Perfiles de usuario en Firestore
- ✅ Búsqueda flexible de usuarios  
- ✅ Sistema completo de solicitudes de amistad:
  - Envío de solicitudes
  - Vista de pendientes con UI destacada (naranja)
  - Aceptar/rechazar con botones
  - Sincronización con polling
- ✅ Chats 1-1 entre amigos
- ✅ Grupos con múltiples participantes
- ✅ Indicadores de escritura en tiempo real
- ✅ Estados de mensaje (✓ enviado / ✓✓ entregado / ✓✓ azul leído)
- ✅ Polling para actualizaciones automáticas (5s mensajes, 10s conversaciones)
- ✅ UI completamente implementada y conectada
- ✅ Solo texto (gratis, sin Firebase Storage)

**Ready para testing con usuarios reales!** 🚀

---

## 📞 Soporte

Si encuentras errores:
1. Revisa la consola de Flutter: `flutter run` en terminal
2. Revisa Firebase Console → Firestore → verifica datos
3. Verifica reglas de Firestore (modo test: `allow read, write: if true`)
4. Reinicia la app con `R` (hot restart) en terminal
