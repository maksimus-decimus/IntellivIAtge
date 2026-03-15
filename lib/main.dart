import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/types.dart';
import 'services/ollama_service.dart';
import 'widgets/app_layout.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ai_guide_screen.dart';
import 'screens/attractions_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/transport_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/restaurants_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/map_screen.dart';
import 'screens/security_screen.dart';
import 'screens/currency_screen.dart';
import 'screens/first_time_guide_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const IntelliviAtgeApp());
}

class IntelliviAtgeApp extends StatelessWidget {
  const IntelliviAtgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntellivIAtge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0EA5E9),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScreenName _currentScreen = ScreenName.login;
  final List<ScreenName> _shortcuts = [
    ScreenName.home,
    ScreenName.groups,
    ScreenName.aiGuide,
    ScreenName.trips,
    ScreenName.profile,
  ];
  
  late final OllamaService _ollamaService;

  @override
  void initState() {
    super.initState();
    // Initialize Ollama Service (local model)
    _ollamaService = OllamaService();
  }

  void _handleLogin() {
    setState(() {
      _currentScreen = ScreenName.home;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentScreen = ScreenName.login;
    });
  }

  void _handleNavigate(ScreenName screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  String _getScreenTitle(ScreenName screen) {
    switch (screen) {
      case ScreenName.home:
        return 'Inicio';
      case ScreenName.aiGuide:
        return 'Guía IA';
      case ScreenName.attractions:
        return 'Atracciones';
      case ScreenName.map:
        return 'Rutas y Mapa';
      case ScreenName.restaurants:
        return 'Gastronomía';
      case ScreenName.transport:
        return 'Transporte';
      case ScreenName.activities:
        return 'Actividades';
      case ScreenName.trips:
        return 'Rutas y Viajes';
      case ScreenName.groups:
        return 'Mis Grupos';
      case ScreenName.translator:
        return 'Traductor';
      case ScreenName.currency:
        return 'Conversor';
      case ScreenName.security:
        return 'Seguridad';
      case ScreenName.profile:
        return 'Mi Perfil';
      case ScreenName.firstTimeGuide:
        return 'Guía Inicial';
      default:
        return 'IntellivIAtge';
    }
  }

  Widget _buildScreen() {
    switch (_currentScreen) {
      case ScreenName.login:
        return LoginScreen(onLogin: _handleLogin);
      case ScreenName.home:
        return HomeScreen(onNavigate: _handleNavigate);
      case ScreenName.aiGuide:
        return AIGuideScreen(ollamaService: _ollamaService);
      case ScreenName.attractions:
        return const AttractionsScreen();
      case ScreenName.restaurants:
        return const RestaurantsScreen();
      case ScreenName.activities:
        return const ActivitiesScreen();
      case ScreenName.transport:
        return const TransportScreen();
      case ScreenName.trips:
        return const TripsScreen();
      case ScreenName.groups:
        return const GroupsScreen();
      case ScreenName.translator:
        return TranslatorScreen(ollamaService: _ollamaService);
      case ScreenName.currency:
        return const CurrencyScreen();
      case ScreenName.security:
        return const SecurityScreen();
      case ScreenName.map:
        return const MapScreen();
      case ScreenName.profile:
        return ProfileScreen(onLogout: _handleLogout);
      case ScreenName.firstTimeGuide:
        return FirstTimeGuideScreen(onComplete: () {
          setState(() {
            _currentScreen = ScreenName.home;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScreen == ScreenName.login) {
      return _buildScreen();
    }

    return AppLayout(
      currentScreen: _currentScreen,
      onNavigate: _handleNavigate,
      title: _getScreenTitle(_currentScreen),
      shortcuts: _shortcuts,
      child: _buildScreen(),
    );
  }
}
