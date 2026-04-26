import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
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

  String _translatedText = '';
  String _sourceLanguage = 'Español';
  String _targetLanguage = 'Catalán';
  bool _isLoading = false;
  bool _usedFallback = false;

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

  /// Maps display names → BCP-47 language codes used by GoogleTranslator
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

  // ── Swap source <-> target (and their text content) ───────────────────────
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

  // ── Core translation logic ────────────────────────────────────────────────
  Future<void> _translate() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    if (_sourceLanguage == _targetLanguage) {
      setState(() => _translatedText = input);
      return;
    }

    setState(() {
      _isLoading = true;
      _usedFallback = false;
    });

    String result = '';

    // 1. Try free GoogleTranslator first
    try {
      final srcCode = _langCodes[_sourceLanguage] ?? 'auto';
      final tgtCode = _langCodes[_targetLanguage] ?? 'en';

      final translation = await _googleTranslator
          .translate(input, from: srcCode, to: tgtCode)
          .timeout(const Duration(seconds: 8));

      result = translation.text;
    } catch (_) {
      // 2. Fall back to Ollama if Google fails
      try {
        result = await widget.ollamaService.translateText(
          input,
          _targetLanguage,
        );
        _usedFallback = true;
      } catch (e) {
        result = 'Error al traducir. Comprueba tu conexión.';
      }
    }

    setState(() {
      _translatedText = result;
      _isLoading = false;
    });
  }

  // ── Camera stub ───────────────────────────────────────────────────────────
  Future<void> _openCamera() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Camara / OCR proximamente'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
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
          // Header (unchanged)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: const [
                Text(
                  'Traductor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Catalán • Español • Inglés',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Pair Selector (unchanged - now supports more languages)
          Row(
            children: [
              // Source language
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Idioma origen:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LanguagePills(
                      languages: _languages,
                      selected: _sourceLanguage,
                      onSelect: (lang) {
                        if (lang == _targetLanguage) {
                          setState(() {
                            _targetLanguage = _sourceLanguage;
                            _sourceLanguage = lang;
                          });
                        } else {
                          setState(() => _sourceLanguage = lang);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Swap button
              Padding(
                padding: const EdgeInsets.only(top: 22, left: 6, right: 6),
                child: GestureDetector(
                  onTap: _swapLanguages,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF5EEAD4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Color(0xFF0D9488),
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Target language
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Traducir a:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LanguagePills(
                      languages: _languages,
                      selected: _targetLanguage,
                      onSelect: (lang) {
                        if (lang == _sourceLanguage) {
                          setState(() {
                            _sourceLanguage = _targetLanguage;
                            _targetLanguage = lang;
                          });
                        } else {
                          setState(() => _targetLanguage = lang);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rest of the UI (input, button, result) remains exactly the same
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
              GestureDetector(
                onTap: _openCamera,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF5EEAD4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF0D9488),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Escribe aquí el texto a traducir...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF2DD4BF), width: 2),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _isLoading ? null : _translate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Traducir',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),

          if (_translatedText.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Traducción:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                    fontSize: 16,
                  ),
                ),
                if (_usedFallback) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: const Color(0xFFFCD34D), width: 1),
                    ),
                    child: const Text(
                      'via Ollama',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5EEAD4), width: 2),
              ),
              child: Text(
                _translatedText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF115E59),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// _LanguagePills widget remains unchanged
class _LanguagePills extends StatelessWidget {
  final List<String> languages;
  final String selected;
  final ValueChanged<String> onSelect;

  const _LanguagePills({
    required this.languages,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: languages.map((lang) {
        final isSelected = selected == lang;
        return GestureDetector(
          onTap: () => onSelect(lang),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
            ),
            child: Text(
              lang,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
