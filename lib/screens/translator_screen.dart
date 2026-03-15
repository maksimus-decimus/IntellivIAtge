import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class TranslatorScreen extends StatefulWidget {
  final OllamaService ollamaService;

  const TranslatorScreen({Key? key, required this.ollamaService}) : super(key: key);

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  String _selectedLanguage = 'Catalán';
  bool _isLoading = false;

  final List<String> _languages = ['Catalán', 'Español', 'Inglés'];

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final result = await widget.ollamaService.translateText(
      _controller.text,
      _selectedLanguage,
    );

    setState(() {
      _translatedText = result;
      _isLoading = false;
    });
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
          // Header
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
                  '🗣️ Traductor',
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
          // Language Selector
          const Text(
            'Traducir a:',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _languages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2DD4BF) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      lang,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Input
          const Text(
            'Texto original:',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
              fontSize: 16,
            ),
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
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 2),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 16),
          // Translate Button
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
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Traducir ✨',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
          if (_translatedText.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Traducción:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
                fontSize: 16,
              ),
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
