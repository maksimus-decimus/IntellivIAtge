import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapRoute {
  final int id;
  final String title;
  final String duration;
  final int stops;
  final String googleMapsLink;
  final String colorClass;

  MapRoute({
    required this.id,
    required this.title,
    required this.duration,
    required this.stops,
    required this.googleMapsLink,
    required this.colorClass,
  });
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Color _getRouteColor(String colorClass) {
    switch (colorClass) {
      case 'amber':
        return const Color(0xFFFBBF24);
      case 'blue':
        return const Color(0xFF60A5FA);
      case 'purple':
        return const Color(0xFFA78BFA);
      case 'emerald':
        return const Color(0xFF34D399);
      default:
        return const Color(0xFF6EE7B7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MapRoute> routes = [
      MapRoute(
        id: 1,
        title: 'Ruta Gaudí Completa',
        duration: '4-5h',
        stops: 6,
        googleMapsLink: 'https://maps.google.com',
        colorClass: 'amber',
      ),
      MapRoute(
        id: 2,
        title: 'Barcelona Marítima',
        duration: '3h',
        stops: 4,
        googleMapsLink: 'https://maps.google.com',
        colorClass: 'blue',
      ),
      MapRoute(
        id: 3,
        title: 'Barrio Gótico',
        duration: '2-3h',
        stops: 8,
        googleMapsLink: 'https://maps.google.com',
        colorClass: 'purple',
      ),
      MapRoute(
        id: 4,
        title: 'Montjuïc al Completo',
        duration: '5-6h',
        stops: 7,
        googleMapsLink: 'https://maps.google.com',
        colorClass: 'emerald',
      ),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock Map Placeholder
            Container(
              height: 256,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!, width: 2),
              ),
              child: Stack(
                children: [
                  // Background map image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Map_of_Barcelona_districts.svg/1200px-Map_of_Barcelona_districts.svg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.green[100]);
                          },
                        ),
                      ),
                    ),
                  ),
                  // Center content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🗺️',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Explora Barcelona',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona una ruta abajo para abrir GPS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Navigation button
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.navigation, size: 24, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Rutas Recomendadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Route Cards
            ...routes.map((route) {
              final color = _getRouteColor(route.colorClass);
              return GestureDetector(
                onTap: () async {
                  final url = Uri.parse(route.googleMapsLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      bottom: BorderSide(color: color, width: 4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '⏱️ ${route.duration}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '📍 ${route.stops} paradas',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Colors.grey[400]),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
