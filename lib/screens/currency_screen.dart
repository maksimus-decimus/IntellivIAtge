import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '1');

  // Supported currencies with flag emoji
  static const Map<String, String> _currencies = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'INR': '🇮🇳',
    'MXN': '🇲🇽',
    'BRL': '🇧🇷',
    'KRW': '🇰🇷',
  };

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double? _rate;
  bool _isLoading = false;
  String? _error;
  String? _rateDate;

  @override
  void initState() {
    super.initState();
    _fetchRate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRate() async {
    if (_fromCurrency == _toCurrency) {
      setState(() {
        _rate = 1.0;
        _error = null;
        _rateDate = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        'https://api.frankfurter.dev/v1/latest?base=$_fromCurrency&symbols=$_toCurrency',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rate = (data['rates'][_toCurrency] as num).toDouble();
          _rateDate = data['date'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar. Verifica tu conexión.';
        _isLoading = false;
      });
    }
  }

  double get _convertedAmount {
    if (_rate == null) return 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount * _rate!;
  }

  void _swapCurrencies() {
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
      _rate = null;
    });
    _fetchRate();
  }

  Widget _buildCurrencyDropdown(
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      icon: const Icon(Icons.expand_more, size: 18),
      items: _currencies.entries.map((e) {
        return DropdownMenuItem(
          value: e.key,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.value, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                e.key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (newVal) {
        onChanged(newVal);
        _fetchRate();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 80),
        child: Column(
          children: [
            // FROM card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[100]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CANTIDAD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      _buildCurrencyDropdown(
                        _fromCurrency,
                        (val) => setState(() => _fromCurrency = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),

            // Swap button
            GestureDetector(
              onTap: _swapCurrencies,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[50]!, width: 4),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey[500],
                        ),
                      )
                    : Icon(Icons.swap_vert, color: Colors.grey[500]),
              ),
            ),

            // TO card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green[100]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CONVERTIDO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.green[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      _buildCurrencyDropdown(
                        _toCurrency,
                        (val) => setState(() => _toCurrency = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      _isLoading ? '...' : _convertedAmount.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.green[700],
                      ),
                    ),
                ],
              ),
            ),

            // Rate info
            if (_rate != null && _rateDate != null && _error == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '1 $_fromCurrency = ${_rate!.toStringAsFixed(4)} $_toCurrency',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualizado: $_rateDate · Frankfurter API',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Refresh button
            TextButton.icon(
              onPressed: _isLoading ? null : _fetchRate,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Actualizar tasa'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
