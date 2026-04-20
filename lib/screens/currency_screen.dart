import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // add url_launcher to pubspec.yaml

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '1');

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
  double? _previousRate; // for trend arrow
  bool _isLoading = false;
  String? _error;
  String? _rateDate;

  // Exchange place data
  static const List<Map<String, dynamic>> _exchangePlaces = [
    {
      'name': 'Wise (TransferWise)',
      'type': 'Online',
      'fee': 'Low (~0.5%)',
      'rating': 4.8,
      'icon': Icons.language,
      'color': Color(0xFF163300),
      'bg': Color(0xFFD1F5A0),
      'url': 'https://wise.com',
      'pros': ['Best mid-market rates', 'Fast transfers', 'Transparent fees'],
      'cons': ['Not instant cash'],
    },
    {
      'name': 'Revolut',
      'type': 'App',
      'fee': 'Free (limits apply)',
      'rating': 4.7,
      'icon': Icons.credit_card,
      'color': Color(0xFF0A1A4A),
      'bg': Color(0xFFDDE8FF),
      'url': 'https://revolut.com',
      'pros': ['No fees on weekdays', 'Instant conversion', 'Multi-currency'],
      'cons': ['Weekend markup', 'Monthly limits on free plan'],
    },
    {
      'name': 'Local Credit Union',
      'type': 'In-Person',
      'fee': 'Medium (~1–2%)',
      'rating': 4.2,
      'icon': Icons.account_balance,
      'color': Color(0xFF2D1B00),
      'bg': Color(0xFFFFF0C2),
      'url': null,
      'pros': ['Trustworthy', 'Cash available', 'No hidden fees'],
      'cons': ['Worse rates than online', 'Limited hours'],
    },
    {
      'name': 'Airport Exchange',
      'type': 'In-Person',
      'fee': 'High (~5–10%)',
      'rating': 2.5,
      'icon': Icons.flight,
      'color': Color(0xFF4A0000),
      'bg': Color(0xFFFFE8E8),
      'url': null,
      'pros': ['Convenient', 'Available 24/7'],
      'cons': ['Worst rates', 'Hidden fees', 'Avoid if possible'],
    },
  ];

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
        final newRate = (data['rates'][_toCurrency] as num).toDouble();
        setState(() {
          _previousRate = _rate;
          _rate = newRate;
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
        _error = 'Sin conexión. Verifica tu red.';
        _isLoading = false;
      });
    }
  }

  double get _convertedAmount {
    if (_rate == null) return 0;
    return (double.tryParse(_amountController.text) ?? 0) * _rate!;
  }

  void _swapCurrencies() {
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
      _rate = null;
      _previousRate = null;
    });
    _fetchRate();
  }

  Widget _buildTrendIndicator() {
    if (_previousRate == null || _rate == null) return const SizedBox.shrink();
    final diff = _rate! - _previousRate!;
    if (diff == 0) return const SizedBox.shrink();
    final isUp = diff > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.trending_up : Icons.trending_down,
          size: 14,
          color: isUp ? Colors.green[600] : Colors.red[400],
        ),
        const SizedBox(width: 2),
        Text(
          '${isUp ? '+' : ''}${diff.toStringAsFixed(4)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isUp ? Colors.green[600] : Colors.red[400],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        icon: const Icon(Icons.expand_more, size: 16),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
        items: _currencies.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.value, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(e.key,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) {
          onChanged(val);
          _fetchRate();
        },
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: 12, color: Colors.amber[600]);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: 12, color: Colors.amber[600]);
        } else {
          return Icon(Icons.star_border, size: 12, color: Colors.grey[300]);
        }
      }),
    );
  }

  Widget _buildExchangeCard(Map<String, dynamic> place) {
    final pros = place['pros'] as List<String>;
    final cons = place['cons'] as List<String>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: place['bg'] as Color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(place['icon'] as IconData,
                      size: 20, color: place['color'] as Color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['name'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: place['color'] as Color,
                        ),
                      ),
                      Row(
                        children: [
                          _buildRatingStars(place['rating'] as double),
                          const SizedBox(width: 4),
                          Text(
                            '${place['rating']}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: place['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place['type'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: place['color'] as Color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place['fee'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: place['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pros & Cons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.check_circle,
                            size: 12, color: Colors.green[500]),
                        const SizedBox(width: 4),
                        Text('Ventajas',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.green[600])),
                      ]),
                      const SizedBox(height: 6),
                      ...pros.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text('• $p',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600])),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.cancel, size: 12, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text('Desventajas',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.red[400])),
                      ]),
                      const SizedBox(height: 6),
                      ...cons.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text('• $c',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600])),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // CTA if has URL
          if (place['url'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(place['url'] as String);
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Visitar sitio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E293B),
                    side: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
      IconData icon, Color iconColor, Color iconBg, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(body,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CONVERTER SECTION ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[100]!, width: 2),
              ),
              child: Column(
                children: [
                  // FROM
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DE',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey[400],
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            _buildCurrencyDropdown(
                              _fromCurrency,
                              (val) => setState(() => _fromCurrency = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CANTIDAD',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey[400],
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B)),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  contentPadding: EdgeInsets.zero),
                              onChanged: (v) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[100], thickness: 1.5),
                  const SizedBox(height: 12),

                  // SWAP + TO
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('A',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green[400],
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            _buildCurrencyDropdown(
                              _toCurrency,
                              (val) => setState(() => _toCurrency = val!),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _swapCurrencies,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey[100], shape: BoxShape.circle),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.grey[500]),
                                )
                              : Icon(Icons.swap_horiz,
                                  size: 20, color: Colors.grey[500]),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('RESULTADO',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green[400],
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            if (_error != null)
                              Text(_error!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red[400],
                                      fontWeight: FontWeight.w600))
                            else
                              Text(
                                _isLoading
                                    ? '...'
                                    : _convertedAmount.toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green[700]),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Rate info bar
            if (_rate != null && _rateDate != null && _error == null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[100]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(
                      '1 $_fromCurrency = ${_rate!.toStringAsFixed(4)} $_toCurrency',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    _buildTrendIndicator(),
                    const SizedBox(width: 6),
                    Text(
                      _rateDate!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

            // Refresh
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _fetchRate,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Actualizar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── WHERE TO EXCHANGE ──────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.compare_arrows,
                      size: 16, color: Colors.blue[700]),
                ),
                const SizedBox(width: 8),
                const Text('Dónde cambiar divisas',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Comparativa de opciones según comisiones y comodidad',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),

            ..._exchangePlaces.map(_buildExchangeCard),

            const SizedBox(height: 8),

            // ── TIPS SECTION ───────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lightbulb_outline,
                      size: 16, color: Colors.amber[700]),
                ),
                const SizedBox(width: 8),
                const Text('Consejos útiles',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 12),

            _buildTipCard(
              Icons.schedule,
              Colors.blue[600]!,
              Colors.blue[50]!,
              'Cambia entre semana',
              'Los mercados de divisas cierran fines de semana. Servicios como Revolut aplican recargos del 0.5–1% en sábados y domingos.',
            ),
            _buildTipCard(
              Icons.local_atm,
              Colors.orange[600]!,
              Colors.orange[50]!,
              'Evita los cajeros del aeropuerto',
              'Las casas de cambio en aeropuertos suelen cobrar hasta un 10% de comisión. Retira efectivo en un banco local al llegar.',
            ),
            _buildTipCard(
              Icons.account_balance_wallet,
              Colors.green[600]!,
              Colors.green[50]!,
              'Usa tarjetas sin comisión exterior',
              'Tarjetas como Revolut, N26 o Wise permiten pagar en el extranjero al tipo de cambio interbancario sin cargos adicionales.',
            ),
            _buildTipCard(
              Icons.trending_up,
              Colors.purple[600]!,
              Colors.purple[50]!,
              'Monitorea la tasa antes de viajar',
              'Si planeas cambiar una cantidad grande, observa la evolución de la tasa durante unos días para elegir el mejor momento.',
            ),
            _buildTipCard(
              Icons.verified_user,
              Colors.teal[600]!,
              Colors.teal[50]!,
              'Rechaza la "conversión dinámica"',
              'Al pagar en el extranjero, siempre elige pagar en la moneda local. La conversión ofrecida por el terminal suele ser mucho peor.',
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'Tasas de Frankfurter API · Solo informativo',
                style: TextStyle(fontSize: 10, color: Colors.grey[350]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
