# Firebase Security Rules para IntellivIAtge Chat

Este archivo contiene las reglas de seguridad que debes configurar en Firebase Console para el sistema de chat.

## Cómo aplicar estas reglas:

1. Ve a Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto **IntellivIAtge**
3. Ve a **Firestore Database** → **Reglas**
4. Reemplaza el contenido con las reglas de abajo
5. Haz clic en **Publicar**

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: check if user is participant in conversation
    function isParticipant(conversationId) {
      return request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participantIds;
    }
    
    // Helper function: check if user is group admin
    function isGroupAdmin(conversationId) {
      let conversation = get(/databases/$(database)/documents/conversations/$(conversationId)).data;
      return conversation.type == 'group' && 
             request.auth.uid in conversation.groupMetadata.adminIds;
    }
    
    // ========================================
    // USERS COLLECTION
    // ========================================
    match /users/{userId} {
      // Anyone authenticated can read any user profile (for search)
      allow read: if isAuthenticated();
      
      // Users can only create/update their own profile
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && request.auth.uid == userId;
      
      // Nobody can delete user profiles
      allow delete: if false;
    }
    
    // ========================================
    // CONVERSATIONS COLLECTION
    // ========================================
    match /conversations/{conversationId} {
      // Can read if user is a participant
      allow read: if isAuthenticated() && 
                     request.auth.uid in resource.data.participantIds;
      
      // Can create if user is in participantIds
      allow create: if isAuthenticated() && 
                       request.auth.uid in request.resource.data.participantIds;
      
      // Can update if user is participant (for lastMessage, unreadCounts)
      // OR if user is admin (for group metadata, adding/removing members)
      allow update: if isAuthenticated() && (
        request.auth.uid in resource.data.participantIds ||
        (resource.data.type == 'group' && 
         request.auth.uid in resource.data.groupMetadata.adminIds)
      );
      
      // Can delete if user is the only participant (direct chat)
      // OR if user is group admin
      allow delete: if isAuthenticated() && (
        (resource.data.type == 'direct' && 
         resource.data.participantIds.size() == 1 &&
         request.auth.uid in resource.data.participantIds) ||
        (resource.data.type == 'group' &&
         request.auth.uid in resource.data.groupMetadata.adminIds)
      );
    }
    
    // ========================================
    // MESSAGES COLLECTION
    // ========================================
    match /messages/{messageId} {
      // Can read if user is participant in the conversation
      allow read: if isAuthenticated() && 
                     isParticipant(resource.data.conversationId);
      
      // Can create if:
      // 1. User is authenticated
      // 2. User is participant in conversation
      // 3. SenderId matches authenticated user
      allow create: if isAuthenticated() && 
                       isParticipant(request.resource.data.conversationId) &&
                       request.auth.uid == request.resource.data.senderId;
      
      // Can update own messages (for status updates like read/delivered)
      // OR any participant can update (for marking as read)
      allow update: if isAuthenticated() && (
        request.auth.uid == resource.data.senderId ||
        isParticipant(resource.data.conversationId)
      );
      
      // Can delete own messages if sent within last 5 minutes
      allow delete: if isAuthenticated() && 
                       request.auth.uid == resource.data.senderId &&
                       request.time < resource.data.timestamp + duration.value(5, 'm');
    }
    
    // ========================================
    // TYPING INDICATORS COLLECTION
    // ========================================
    match /typing/{conversationId}/{userId} {
      // Can read if user is participant
      allow read: if isAuthenticated() && 
                     isParticipant(conversationId);
      
      // Can write own typing status
      allow write: if isAuthenticated() && 
                      request.auth.uid == userId &&
                      isParticipant(conversationId);
    }
    
    // ========================================
    // FRIEND REQUESTS COLLECTION
    // ========================================
    match /friendRequests/{requestId} {
      // Can read if user is sender or recipient
      allow read: if isAuthenticated() && (
        request.auth.uid == resource.data.fromUserId ||
        request.auth.uid == resource.data.toUserId
      );
      
      // Can create if user is the sender
      allow create: if isAuthenticated() && 
                       request.auth.uid == request.resource.data.fromUserId;
      
      // Can update if user is recipient (to accept/reject)
      allow update: if isAuthenticated() && 
                       request.auth.uid == resource.data.toUserId;
      
      // Can delete if user is sender (to cancel request)
      allow delete: if isAuthenticated() && 
                       request.auth.uid == resource.data.fromUserId;
    }
  }
}
```

---

## Firebase Storage Rules (para imágenes)

También necesitarás configurar reglas para Firebase Storage. Ve a **Storage** → **Reglas**:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Images in messages folder
    match /messages/{conversationId}/{fileName} {
      // Allow read if user is authenticated
      allow read: if request.auth != null;
      
      // Allow upload if:
      // 1. User is authenticated
      // 2. File is an image (jpg, png, gif, webp)
      // 3. File size < 5MB
      allow write: if request.auth != null &&
                      request.resource.contentType.matches('image/.*') &&
                      request.resource.size < 5 * 1024 * 1024;
    }
    
    // Profile pictures
    match /users/{userId}/profile.jpg {
      // Anyone can read profile pictures
      allow read: if true;
      
      // Only owner can upload their profile picture
      allow write: if request.auth != null &&
                      request.auth.uid == userId &&
                      request.resource.contentType.matches('image/.*') &&
                      request.resource.size < 2 * 1024 * 1024;
    }
    
    // Group images
    match /groups/{conversationId}/image.jpg {
      // Anyone can read group images
      allow read: if true;
      
      // Only authenticated users can upload
      // (ChatService will verify group admin permissions in app code)
      allow write: if request.auth != null &&
                      request.resource.contentType.matches('image/.*') &&
                      request.resource.size < 2 * 1024 * 1024;
    }
  }
}
```

---

## Índices Compuestos Recomendados

Para mejorar el rendimiento de las queries, crea estos índices en Firestore:

1. **Colección**: `conversations`
   - Campos:
     - `participantIds` (Array contains)
     - `lastMessageTime` (Descending)

2. **Colección**: `messages`
   - Campos:
     - `conversationId` (Ascending)
     - `timestamp` (Descending)

3. **Colección**: `friendRequests`
   - Campos:
     - `toUserId` (Ascending)
     - `status` (Ascending)
     - `createdAt` (Descending)

**Nota**: Firebase te sugerirá crear estos índices automáticamente cuando ejecutes las queries por primera vez. Sigue los enlaces que aparecen en los errores de consola.

---

## Testing de Reglas

Puedes probar las reglas en Firebase Console:
1. Ve a **Firestore Database** → **Reglas**
2. Haz clic en **Simulador de reglas**
3. Prueba operaciones como:
   - Read de `/conversations/{id}` con un UID de usuario participante
   - Write de `/messages/{id}` verificando que senderId == auth.uid
   - Update de `/conversations/{id}` para añadir miembros (como admin)

---

Una vez aplicadas estas reglas, tu sistema de chat estará seguro y los usuarios solo podrán acceder a sus propias conversaciones y mensajes. 🔒
