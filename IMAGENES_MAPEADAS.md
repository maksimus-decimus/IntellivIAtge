# 🖼️ Mapeo de Imágenes - IntellivIAtge

## ✅ Imágenes Integradas en la Aplicación

### 👤 Perfil (Profile Screen)
- **carlos.jpeg** → Avatar del usuario en pantalla de perfil

### 🏛️ Atracciones (Attractions Screen)
- **casa_batlló.jpeg** → Casa Batlló (atracción arquitectónica)
- **mercat_boqueria.jpeg** → La Boquería (mercado tradicional)
- *Sagrada Familia y Park Güell usarán URLs externas como placeholders*

### 🍽️ Restaurantes (Restaurants Screen)
- **7_portes.jpeg** → 7 Portes (restaurante histórico desde 1836)
- **can_sole.jpeg** → Can Solé (especialidad en pescado fresco)
- **el_xampanyet.jpeg** → El Xampanyet (bar de tapas emblemático)

### 🍴 Platos Típicos (Dishes)
- **paella.jpeg** → Paella Parellada
- **pan_tomato.jpeg** → Pan con Tomate

### 🎭 Eventos/Actividades (Activities Screen)
- **rosalía.jpeg** → Concierto de Rosalía
- **el_rey_leon_musical.jpeg** → El Rey León - El Musical
- **camp_nou_stadium.jpeg** → FC Barcelona vs Real Madrid (Camp Nou)

### 👥 Grupos y Comunidad (Groups Screen)
- **carlos.jpeg** → Amigo Carlos M. / Posts comunitarios
- **laura.jpeg** → Amiga Laura S. / Posts comunitarios
- **fotofamily.jpeg** → Grupo familiar
- **ruta_gastronomica.jpeg** → Grupo de ruta gastronómica

### 📋 Otros
- **icono_foto.png** → Ícono genérico
- **generic_01.jpeg, generic_02.jpeg** → Imágenes de reserva

---

## 📝 Resumen de Cambios

### Archivos Modificados:

1. **lib/constants/app_constants.dart**
   - Atracciones: URLs externas → rutas locales
   - Platos: Agregado photoUrl para pan con tomate
   - Restaurantes: URLs externas → rutas locales
   - Posts comunitarios: URLs de picsum → rutas locales (carlos.jpeg, laura.jpeg)

2. **lib/screens/profile_screen.dart**
   - Avatar del perfil: URL externa → assets/images/carlos.jpeg

3. **lib/screens/activities_screen.dart**
   - Eventos: URLs externas → rutas locales (Image.network → Image.asset)

4. **lib/screens/attractions_screen.dart**
   - Imágenes de atracciones: Image.network → Image.asset

5. **lib/screens/restaurants_screen.dart**
   - Imágenes de restaurantes: Image.network → Image.asset
   - Imágenes de platos: Image.network → Image.asset

6. **lib/screens/groups_screen.dart**
   - Avatares de amigos: URLs externas → rutas locales
   - Chats: URLs externas → rutas locales
   - Image.network → Image.asset

---

## 📂 Estructura de Archivos de Imágenes

```
assets/images/
├── 7_portes.jpeg
├── can_sole.jpeg
├── camp_nou_stadium.jpeg
├── carlos.jpeg
├── casa_batlló.jpeg
├── el_rey_leon_musical.jpeg
├── el_xampanyet.jpeg
├── fotofamily.jpeg
├── generic_01.jpeg
├── generic_02.jpeg
├── icono_foto.png
├── laura.jpeg
├── mercat_boqueria.jpeg
├── pan_tomato.jpeg
├── paella.jpeg
├── rosalía.jpeg
├── ruta_gastronomica.jpeg
└── tortilla_recipe.jpeg
```

---

## 🚀 Optimizaciones Aplicadas

✅ Imágenes renombradas a formato snake_case (sin espacios)
✅ URLs externas reemplazadas por rutas locales
✅ Image.network cambiado a Image.asset donde corresponde
✅ Datos en app_constants.dart actualizados
✅ Avatares de perfiles y comunidad personalizados
✅ Imágenes de eventos, restaurantes y atracciones locales

---

## 📌 Notas

- Las imágenes ahora se cargan LOCALMENTE, mejorando rendimiento
- Sin dependencia de conexión a internet para estas imágenes
- Mejor experiencia de usuario con carga más rápida
- Perfecto para modo offline
