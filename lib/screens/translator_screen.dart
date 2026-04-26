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

class _TranslatorScreenState extends State<TranslatorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GoogleTranslator _googleTranslator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _translatedText = '';
  String _sourceLanguage = 'Español';
  String _targetLanguage = 'Catalán';
  bool _isLoading = false;
  bool _usedFallback = false;
  bool _isListening = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Language list ──────────────────────────────────────────────────────────
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

  // Language flag emojis for visual appeal
  static const Map<String, String> _langFlags = {
    'Catalán': '🏴󠁥󠁳󠁣󠁴󠁿',
    'Español': '🇪🇸',
    'Inglés': '🇬🇧',
    'Francés': '🇫🇷',
    'Alemán': '🇩🇪',
    'Italiano': '🇮🇹',
    'Portugués': '🇵🇹',
    'Árabe': '🇸🇦',
    'Chino': '🇨🇳',
    'Japonés': '🇯🇵',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Swap languages ─────────────────────────────────────────────────────────
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

  // ── Translation ────────────────────────────────────────────────────────────
  Future<void> _translate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _usedFallback = false;
      _translatedText = '';
    });

    final srcCode = _langCodes[_sourceLanguage] ?? 'es';
    final tgtCode = _langCodes[_targetLanguage] ?? 'ca';

    // 1. Try Ollama first
    try {
      final result =
          await widget.ollamaService.translateText(text, _targetLanguage);
      if (result.isNotEmpty && result != 'Error') {
        setState(() {
          _translatedText = result.trim();
          _isLoading = false;
          _usedFallback = false;
        });
        return;
      }
    } catch (_) {}

    // 2. Fallback to Google Translate
    try {
      final translation = await _googleTranslator.translate(
        text,
        from: srcCode,
        to: tgtCode,
      );
      setState(() {
        _translatedText = translation.text;
        _isLoading = false;
        _usedFallback = true;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Error al traducir. Verifica tu conexión.';
        _isLoading = false;
        _usedFallback = false;
      });
    }
  }

  // ── Voice Input ────────────────────────────────────────────────────────────
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('Speech status: $val'),
      onError: (val) => debugPrint('Speech error: $val'),
    );

    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reconocimiento de voz no disponible'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      localeId: srcCode,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // ── Camera stub ────────────────────────────────────────────────────────────
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

  // ── Copy to clipboard ──────────────────────────────────────────────────────
  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    // You can add flutter/services import for real clipboard:
    // Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Texto copiado al portapapeles'),
        backgroundColor: const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.translate_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traductor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Powered by IA local',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Language Selector ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Source language pill
                Expanded(
                  child: _LanguagePill(
                    selected: _sourceLanguage,
                    languages: _languages,
                    flags: _langFlags,
                    onChanged: (val) => setState(() => _sourceLanguage = val),
                  ),
                ),

                // Swap button
                GestureDetector(
                  onTap: _swapLanguages,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),

                // Target language pill
                Expanded(
                  child: _LanguagePill(
                    selected: _targetLanguage,
                    languages: _languages,
                    flags: _langFlags,
                    onChanged: (val) => setState(() => _targetLanguage = val),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Input section ───────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input label row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _langFlags[_sourceLanguage] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sourceLanguage,
                              style: const TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Camera button
                      _IconBtn(
                        icon: Icons.camera_alt_rounded,
                        onTap: _openCamera,
                        active: false,
                      ),
                      const SizedBox(width: 8),
                      // Mic button with pulse animation
                      _isListening
                          ? ScaleTransition(
                              scale: _pulseAnimation,
                              child: _IconBtn(
                                icon: Icons.mic_off_rounded,
                                onTap: _stopListening,
                                active: true,
                              ),
                            )
                          : _IconBtn(
                              icon: Icons.mic_rounded,
                              onTap: _startListening,
                              active: false,
                            ),
                    ],
                  ),
                ),

                // Divider
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // TextField
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe o habla para traducir…',
                    hintStyle: TextStyle(
                      color: const Color(0xFF94A3B8).withOpacity(0.8),
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),

                // Clear button
                if (_controller.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _translatedText = '';
                          });
                        },
                        icon: const Icon(Icons.clear_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                        label: const Text(
                          'Limpiar',
                          style:
                              TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Translate button ────────────────────────────────────────────────
          GestureDetector(
            onTap: _isLoading ? null : _translate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)]
                      : [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: _isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Traducir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Result section ──────────────────────────────────────────────────
          if (_translatedText.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCCFBF1), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Result header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _langFlags[_targetLanguage] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _targetLanguage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_usedFallback) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: const Text(
                              'Google',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Copy button
                        GestureDetector(
                          onTap: () => _copyToClipboard(_translatedText),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.copy_rounded,
                                color: Color(0xFF0D9488), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFCCFBF1)),

                  // Translated text
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _translatedText,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF1E293B),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── Language Pill Dropdown ────────────────────────────────────────────────────
class _LanguagePill extends StatelessWidget {
  final String selected;
  final List<String> languages;
  final Map<String, String> flags;
  final ValueChanged<String> onChanged;

  const _LanguagePill({
    required this.selected,
    required this.languages,
    required this.flags,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _LanguagePickerSheet(
            selected: selected,
            languages: languages,
            flags: flags,
          ),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF99F6E4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flags[selected] ?? '', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selected,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF0D9488), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Language Picker Bottom Sheet ──────────────────────────────────────────────
class _LanguagePickerSheet extends StatelessWidget {
  final String selected;
  final List<String> languages;
  final Map<String, String> flags;

  const _LanguagePickerSheet({
    required this.selected,
    required this.languages,
    required this.flags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona un idioma',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSelected = lang == selected;
              return GestureDetector(
                onTap: () => Navigator.pop(context, lang),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFCCFBF1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(flags[lang] ?? '',
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Text(
                        lang,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF334155),
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF0D9488), size: 20),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Icon Button ──────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEF4444) : const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFEF4444) : const Color(0xFF5EEAD4),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFF0D9488),
          size: 20,
        ),
      ),
    );
  }
}
