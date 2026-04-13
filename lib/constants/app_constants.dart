import 'package:flutter/material.dart';
import '../models/types.dart';

class AppConstants {
  // Menu Items
  static final List<MenuItem> menuItems = [
    MenuItem(
      id: ScreenName.trips,
      label: 'Rutas y Viajes',
      icon: Icons.map,
      color: const Color(0xFF34D399),
      shadowColor: const Color(0xFF059669),
    ),
    MenuItem(
      id: ScreenName.aiGuide,
      label: 'Guía IA',
      icon: Icons.smart_toy,
      color: const Color(0xFFA78BFA),
      shadowColor: const Color(0xFF7C3AED),
    ),
    MenuItem(
      id: ScreenName.attractions,
      label: 'Visitas',
      icon: Icons.account_balance,
      color: const Color(0xFFFBBF24),
      shadowColor: const Color(0xFFD97706),
    ),
    MenuItem(
      id: ScreenName.restaurants,
      label: 'Comer',
      icon: Icons.restaurant,
      color: const Color(0xFFFB923C),
      shadowColor: const Color(0xFFEA580C),
    ),
    MenuItem(
      id: ScreenName.activities,
      label: 'Agenda',
      icon: Icons.local_activity,
      color: const Color(0xFFF472B6),
      shadowColor: const Color(0xFFDB2777),
    ),
    MenuItem(
      id: ScreenName.transport,
      label: 'Moverse',
      icon: Icons.directions_bus,
      color: const Color(0xFF60A5FA),
      shadowColor: const Color(0xFF2563EB),
    ),
    MenuItem(
      id: ScreenName.groups,
      label: 'Grupos',
      icon: Icons.groups,
      color: const Color(0xFF818CF8),
      shadowColor: const Color(0xFF4F46E5),
    ),
    MenuItem(
      id: ScreenName.translator,
      label: 'Traductor',
      icon: Icons.translate,
      color: const Color(0xFF2DD4BF),
      shadowColor: const Color(0xFF0D9488),
    ),
    MenuItem(
      id: ScreenName.currency,
      label: 'Dinero',
      icon: Icons.attach_money,
      color: const Color(0xFF4ADE80),
      shadowColor: const Color(0xFF16A34A),
    ),
    MenuItem(
      id: ScreenName.security,
      label: 'Seguridad',
      icon: Icons.shield,
      color: const Color(0xFFF87171),
      shadowColor: const Color(0xFFDC2626),
    ),
  ];

  // Barcelona Attractions
  static final List<Attraction> barcelonaAttractions = [
    Attraction(
      id: '1',
      name: 'Sagrada Familia',
      category: 'Monumento',
      rating: 4.9,
      image: 'assets/images/generic_01.jpeg',
      description: 'Obra maestra de Gaudí. Reserva con 2 semanas de antelación.',
    ),
    Attraction(
      id: '2',
      name: 'Park Güell',
      category: 'Parque',
      rating: 4.7,
      image: 'assets/images/generic_02.jpeg',
      description: 'Vistas increíbles. Evita ir al mediodía por el calor.',
    ),
    Attraction(
      id: '3',
      name: 'Casa Batlló',
      category: 'Arquitectura',
      rating: 4.8,
      image: 'assets/images/casa_batlló.jpeg',
      description: 'La casa del dragón. La audioguía es fascinante.',
    ),
    Attraction(
      id: '4',
      name: 'La Boquería',
      category: 'Mercado',
      rating: 4.5,
      image: 'assets/images/mercat_boqueria.jpeg',
      description: 'Colores y sabores en Las Ramblas. Prueba los zumos.',
    ),
  ];

  // Quick Questions for AI
  static const List<String> quickQuestions = [
    '¿Dónde comer la mejor paella?',
    '¿Cómo usar el metro?',
    'Horario Sagrada Familia',
    'Frases en Catalán',
  ];

  // Transport Options
  static final List<TransportOption> transportOptions = [
    TransportOption(
      id: 't1',
      type: 'Metro',
      name: 'Metro TMB',
      price: '2.55€ / viaje',
      description: 'La forma más rápida. Compra la T-Casual (10 viajes) si estás varios días.',
      tips: 'Cuidado con los carteristas en estaciones concurridas.',
      icon: '🚇',
    ),
    TransportOption(
      id: 't2',
      type: 'Bus',
      name: 'Autobús / NitBus',
      price: '2.55€ / viaje',
      description: 'Genial para ver la ciudad. El NitBus opera toda la noche.',
      tips: 'Se entra por delante y se sale por detrás.',
      icon: '🚌',
    ),
    TransportOption(
      id: 't3',
      type: 'Taxi',
      name: 'Taxi / Apps',
      price: 'Variado',
      description: 'Amarillos y negros. Uber y Cabify también operan.',
      tips: 'Luz verde significa libre.',
      icon: '🚖',
    ),
  ];

  // Typical Dishes
  static final List<Dish> typicalDishes = [
    Dish(
      id: 'd1',
      name: 'Paella Parellada',
      description: 'Arroz sin tropezones ni cáscaras. ¡Ideal para no mancharse!',
      image: '🥘',
      isVegetarian: false,
      isSpicy: false,
      photoUrl: 'assets/images/paella.jpeg',
      reviews: [
        Review(
          user: 'María S.',
          comment: 'Increíble, todo pelado y listo para comer. El sabor a marisco es espectacular.',
          rating: 5,
        ),
        Review(
          user: 'John D.',
          comment: 'Best paella I had in Barcelona. So easy to eat!',
          rating: 5,
        ),
      ],
      recommendedRestaurants: [
        RecommendedRestaurant(name: '7 Portes', address: 'Passeig d\'Isabel II, 14', rating: 4.5),
        RecommendedRestaurant(name: 'Can Solé', address: 'Carrer de Sant Carles, 4', rating: 4.6),
      ],
    ),
    Dish(
      id: 'd2',
      name: 'Pan con Tomate',
      description: 'El clásico desayuno o acompañamiento. Pan, tomate, aceite y sal.',
      image: '🍞',
      isVegetarian: true,
      isSpicy: false,
      photoUrl: 'assets/images/pan_tomato.jpeg',
      reviews: [],
      recommendedRestaurants: [],
    ),
    Dish(
      id: 'd3',
      name: 'Tortilla de Patatas',
      description: 'La reina de las tortillas española. Patatas, huevos y cebolla. Simple pero perfecta.',
      image: '🥚',
      isVegetarian: true,
      isSpicy: false,
      photoUrl: 'assets/images/tortilla_recipe.jpeg',
      reviews: [
        Review(
          user: 'José M.',
          comment: 'La tortilla de toda la vida. Crujiente por fuera, jugosa por dentro. Perfecta.',
          rating: 5,
        ),
        Review(
          user: 'Carmen L.',
          comment: 'De las mejores tortillas que he probado. El punto de cocción es impecable.',
          rating: 5,
        ),
      ],
      recommendedRestaurants: [
        RecommendedRestaurant(name: 'El Xampanyet', address: 'Carrer de Mont carles, 22', rating: 4.3),
        RecommendedRestaurant(name: '7 Portes', address: 'Passeig d\'Isabel II, 14', rating: 4.5),
      ],
    ),
  ];

  // Top Restaurants
  static final List<Restaurant> topRestaurants = [
    Restaurant(
      id: 'r1',
      name: '7 Portes',
      description: 'Restaurante histórico desde 1836. Famoso por su paella y ambiente elegante.',
      image: 'assets/images/7_portes.jpeg',
      rating: 4.5,
      averagePrice: '€€€',
      specialties: ['Paella', 'Arroz', 'Marisco'],
      address: 'Passeig d\'Isabel II, 14',
      type: 'Catalana',
      priceLevel: '€€€',
    ),
    Restaurant(
      id: 'r2',
      name: 'Can Solé',
      description: 'Cocina catalana tradicional en La Barceloneta. Especialidad en pescado fresco.',
      image: 'assets/images/can_sole.jpeg',
      rating: 4.6,
      averagePrice: '€€€',
      specialties: ['Pescado', 'Suquet', 'Fideuà'],
      address: 'Carrer de Sant Carles, 4',
      type: 'Marisquería',
      priceLevel: '€€€',
    ),
    Restaurant(
      id: 'r3',
      name: 'El Xampanyet',
      description: 'Bar de tapas emblemático. Siempre lleno, pero vale la pena esperar.',
      image: 'assets/images/el_xampanyet.jpeg',
      rating: 4.3,
      averagePrice: '€',
      specialties: ['Tapas', 'Cava', 'Anchoas'],
      address: 'Carrer de Mont carles, 22',
      type: 'Tapas',
      priceLevel: '€',
    ),
  ];

  // Community Posts
  static final List<CommunityPost> communityPosts = [
    CommunityPost(
      id: 1,
      user: 'Ana G.',
      handle: '@anag_travels',
      avatar: 'assets/images/laura.jpeg',
      place: 'Sagrada Familia',
      rating: 5,
      comment: '¡Impresionante! Recomiendo ir a primera hora para evitar las multitudes. La luz de la mañana en las vidrieras es mágica. ✨',
      time: 'Hace 2h',
    ),
    CommunityPost(
      id: 2,
      user: 'Carlos M.',
      handle: '@carlos_bcn',
      avatar: 'assets/images/carlos.jpeg',
      place: 'Restaurante El Xampanyet',
      rating: 4,
      comment: 'Muy buenas tapas, pero siempre está a tope. Paciencia para encontrar sitio, vale la pena probar el cava. 🥂',
      time: 'Hace 5h',
    ),
    CommunityPost(
      id: 3,
      user: 'Laura S.',
      handle: '@laura_wander',
      avatar: 'assets/images/laura.jpeg',
      place: 'Parc Güell',
      rating: 3,
      comment: 'Bonito, pero demasiada gente hoy. Las vistas son geniales, aunque la zona monumental estaba abarrotada.',
      time: 'Hace 1d',
    ),
  ];
}
