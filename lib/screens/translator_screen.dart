import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ollama_service.dart';

class TranslatorScreen extends StatefulWidget {
  final OllamaService ollamaService;

  const TranslatorScreen({Key? key, required this.ollamaService})
      : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _controller = TextEditingController();
  final GoogleTranslator _googleTranslator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _translatedText = '';
  String _sourceLanguage = 'Español';
  String _targetLanguage = 'Catalán';
  bool _isLoading = false;
  bool _usedFallback = false;
  bool _isListening = false; // New: for mic animation/state

  // ── Extended language list ─────────────────────────────────────────────────
  final List<String> _languages = [
    'Catalán',
    'Español',
    'Inglés',
    'Francés',
    'Alemán',
    'Italiano',
    'Portugués',
    'Árabe',
    'Chino',
    'Japonés',
  ];

  static const Map<String, String> _langCodes = {
    'Catalán': 'ca',
    'Español': 'es',
    'Inglés': 'en',
    'Francés': 'fr',
    'Alemán': 'de',
    'Italiano': 'it',
    'Portugués': 'pt',
    'Árabe': 'ar',
    'Chino': 'zh',
    'Japonés': 'ja',
  };

  // ── Swap languages (unchanged) ───────────────────────────────────────────
  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_translatedText.isNotEmpty) {
        final tempText = _controller.text;
        _controller.text = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  // ── Voice Input (Microphone) ─────────────────────────────────────────────
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('Speech status: $val'),
      onError: (val) => print('Speech error: $val'),
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition no disponible')),
      );
      return;
    }

    final srcCode = _langCodes[_sourceLanguage] ?? 'es';

    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      },
      localeId: srcCode, // Use the source language
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // ── Camera stub (unchanged) ──────────────────────────────────────────────
  Future<void> _openCamera() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cámara / OCR próximamente'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Rest of your methods (_translate, dispose, build) stay almost the same...

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (unchanged) ...

          // Language selector (unchanged) ...

          const SizedBox(height: 24),

          // Input Label + Camera + Mic
          Row(
            children: [
              const Text(
                'Texto original:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Camera Button
              GestureDetector(
                onTap: _openCamera,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF5EEAD4), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF0D9488), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              // Microphone Button (with listening state)
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF5EEAD4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color:
                        _isListening ? Colors.white : const Color(0xFF0D9488),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TextField and rest of the UI remain exactly the same...
          TextField(
            controller: _controller,
            maxLines: 5,
            // ... your decoration ...
          ),
          // ... Translate button and result section unchanged ...
        ],
      ),
    );
  }
}

// _LanguagePills widget remains unchanged
