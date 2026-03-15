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
      image: 'https://images.unsplash.com/photo-1598517522687-9755b7662c94?w=500&q=80',
      description: 'Obra maestra de Gaudí. Reserva con 2 semanas de antelación.',
    ),
    Attraction(
      id: '2',
      name: 'Park Güell',
      category: 'Parque',
      rating: 4.7,
      image: 'https://images.unsplash.com/photo-1523531294919-4bcd7c65e216?w=500&q=80',
      description: 'Vistas increíbles. Evita ir al mediodía por el calor.',
    ),
    Attraction(
      id: '3',
      name: 'Casa Batlló',
      category: 'Arquitectura',
      rating: 4.8,
      image: 'https://images.unsplash.com/photo-1558237300-4b102283a215?w=500&q=80',
      description: 'La casa del dragón. La audioguía es fascinante.',
    ),
    Attraction(
      id: '4',
      name: 'La Boquería',
      category: 'Mercado',
      rating: 4.5,
      image: 'https://images.unsplash.com/photo-1542323568-d05051061905?w=500&q=80',
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
      photoUrl: 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=800&q=80',
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
      reviews: [],
      recommendedRestaurants: [],
    ),
  ];

  // Top Restaurants
  static final List<Restaurant> topRestaurants = [
    Restaurant(
      id: 'r1',
      name: '7 Portes',
      description: 'Restaurante histórico desde 1836. Famoso por su paella y ambiente elegante.',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
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
      image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
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
      image: 'https://images.unsplash.com/photo-1555992336-fb0d29498b13?w=800&q=80',
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
      avatar: 'https://picsum.photos/40/40?random=21',
      place: 'Sagrada Familia',
      rating: 5,
      comment: '¡Impresionante! Recomiendo ir a primera hora para evitar las multitudes. La luz de la mañana en las vidrieras es mágica. ✨',
      time: 'Hace 2h',
    ),
    CommunityPost(
      id: 2,
      user: 'Carlos M.',
      handle: '@carlos_bcn',
      avatar: 'https://picsum.photos/40/40?random=22',
      place: 'Restaurante El Xampanyet',
      rating: 4,
      comment: 'Muy buenas tapas, pero siempre está a tope. Paciencia para encontrar sitio, vale la pena probar el cava. 🥂',
      time: 'Hace 5h',
    ),
    CommunityPost(
      id: 3,
      user: 'Laura S.',
      handle: '@laura_wander',
      avatar: 'https://picsum.photos/40/40?random=23',
      place: 'Parc Güell',
      rating: 3,
      comment: 'Bonito, pero demasiada gente hoy. Las vistas son geniales, aunque la zona monumental estaba abarrotada.',
      time: 'Hace 1d',
    ),
  ];
}
