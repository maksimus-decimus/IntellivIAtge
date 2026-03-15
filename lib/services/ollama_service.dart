import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'llama3.1';
  
  static const String _systemInstruction = '''
Eres "GaudíBot", un guía turístico experto, amigable y divertido de Barcelona. 
Tus respuestas deben ser útiles para turistas, concisas y con un tono alegre. 
Usa emojis. Estás diseñado para una app estilo Duolingo, así que sé muy motivador y accesible.
Si te preguntan algo fuera de Barcelona, redirígelos amablemente a la ciudad.
''';

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': '$_systemInstruction\n\n$prompt',
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No pude obtener respuesta';
      } else {
        return 'Error al conectar con Ollama';
      }
    } catch (e) {
      print('Ollama Error: $e');
      return '¡Ups! No pude conectar con el modelo local. ¿Está Ollama corriendo?';
    }
  }

  Future<String> translateText(String text, String targetLang) async {
    try {
      final prompt = 'Traduce el siguiente texto al $targetLang. Devuelve SOLO el texto traducido, sin explicaciones extra. Texto: "$text"';
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Error traducción';
      } else {
        return 'Error';
      }
    } catch (e) {
      print('Translation Error: $e');
      return 'Error';
    }
  }
}
