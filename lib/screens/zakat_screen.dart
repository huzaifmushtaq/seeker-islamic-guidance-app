import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/zakat_calculation.dart';
import '../services/metal_price_service.dart';
import '../services/zakat_service.dart';
import 'zakat_education_screen.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  static const _green = Color(0xff2D6A4F);
  static const _bg = Color(0xff252525);
  static const _card = Color(0xff303030);
  static const _mint = Color(0xff80CFA9);
  static const _gold = Color(0xffD9B55A);

  final _service = ZakatService();
  final _metalService = MetalPriceService();
  final Map<String, TextEditingController> _controllers = {};

  String _currencyCode = 'INR';
  String _currencySymbol = '₹';
  String _nisabBasis = 'Silver';
  String _goldPurity = '24K';
  String _silverPurity = '999';
  bool _goldUseResaleValue = false;
  bool _silverUseResaleValue = false;
  bool _haulComplete = false;
  bool _restoring = false;
  bool _loadingPrices = false;
  String? _priceError;
  MetalPrices? _prices;
  ZakatCalculation? _result;
  Timer? _refreshTimer;
  static const Duration _priceRefreshInterval = Duration(hours: 6);

  final _moneyFields = const [
    ('cash', 'Cash', 'Cash you currently keep at home or elsewhere', Icons.payments_outlined),
    ('bank', 'Bank & Savings', 'Current balances and qualifying savings', Icons.account_balance_outlined),
    ('receivables', 'Money owed to you', 'Money you realistically expect to recover', Icons.call_received_rounded),
    ('investments', 'Zakatable Investments', 'Enter the amount you have determined is Zakatable', Icons.trending_up_rounded),
    ('business', 'Business Stock', 'Goods held for sale or trade', Icons.storefront_outlined),
    ('other', 'Other Zakatable Assets', 'Other qualifying monetary assets', Icons.account_balance_wallet_outlined),
    ('liabilities', 'Eligible Liabilities', 'Only debts/outgoings that your chosen Zakat method allows you to deduct', Icons.remove_circle_outline),
  ];

  final _purityFactors = const <String, double>{
    '24K': 1.0,
    '22K': 22 / 24,
    '21K': 21 / 24,
    '20K': 20 / 24,
    '18K': 18 / 24,
    '14K': 14 / 24,
  };

  final _silverPurityFactors = const <String, double>{
    '999': 0.999,
    '925': 0.925,
    '900': 0.900,
    '800': 0.800,
  };

  @override
  void initState() {
    super.initState();
    _createControllers();
    _initialize();
    // Prices are benchmark/reference data, so avoid hitting the public API on every
    // app open. The cached value remains immediately available offline.
    _refreshTimer = Timer.periodic(_priceRefreshInterval, (_) => _refreshPrices());
  }

  Future<void> _initialize() async {
    await _loadSaved();
    if (!mounted) return;

    // Use the saved price when it is still reasonably fresh. This prevents
    // repeated app launches from exhausting anonymous API rate limits.
    if (_prices == null || _isPriceCacheStale()) {
      await _refreshPrices();
    }
  }

  bool _isPriceCacheStale() {
    final updated = _prices?.updatedAt;
    if (updated == null) return true;
    return DateTime.now().difference(updated.toLocal()) >= _priceRefreshInterval;
  }

  void _createControllers() {
    for (final field in _moneyFields) {
      _controllers[field.$1] = TextEditingController()..addListener(_recalculateFromInput);
    }
    _controllers['goldGrams'] = TextEditingController()..addListener(_recalculateFromInput);
    _controllers['silverGrams'] = TextEditingController()..addListener(_recalculateFromInput);
    _controllers['goldResale'] = TextEditingController()..addListener(_recalculateFromInput);
    _controllers['silverResale'] = TextEditingController()..addListener(_recalculateFromInput);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    for (final controller in _controllers.values) controller.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _restoring = true;
    if (!mounted) return;
    setState(() {
      _currencyCode = prefs.getString('zakat_currency_code') ?? 'INR';
      _currencySymbol = _symbolFor(_currencyCode);
      _nisabBasis = prefs.getString('zakat_nisab_basis') ?? 'Silver';
      _goldPurity = prefs.getString('zakat_gold_purity') ?? '24K';
      _silverPurity = prefs.getString('zakat_silver_purity') ?? '999';
      _goldUseResaleValue = prefs.getBool('zakat_gold_resale_mode') ?? false;
      _silverUseResaleValue = prefs.getBool('zakat_silver_resale_mode') ?? false;
      _haulComplete = prefs.getBool('zakat_haul_complete') ?? false;
      for (final entry in _controllers.entries) {
        final value = prefs.getString('zakat_${entry.key}');
        if (value != null) entry.value.text = value;
      }
      _restoreCachedPrices(prefs);
      _recalculate();
    });
    _restoring = false;
    if (mounted) setState(_recalculate);
  }

  void _restoreCachedPrices(SharedPreferences prefs) {
    final prefix = 'zakat_price_${_currencyCode}_';
    final gold = prefs.getDouble('${prefix}gold');
    final silver = prefs.getDouble('${prefix}silver');
    final timestamp = prefs.getString('${prefix}updated');
    if (gold == null || silver == null) return;
    final parsed = DateTime.tryParse(timestamp ?? '');
    if (parsed == null) return;

    final goldMap = <String, double>{'24K': gold};
    for (final purity in const ['22K', '21K', '20K', '18K', '16K', '14K', '10K']) {
      final value = prefs.getDouble('${prefix}gold_$purity');
      if (value != null && value > 0) goldMap[purity] = value;
    }
    final silverMap = <String, double>{'999': silver};
    for (final purity in const ['925', '900', '800']) {
      final value = prefs.getDouble('${prefix}silver_$purity');
      if (value != null && value > 0) silverMap[purity] = value;
    }

    _prices = MetalPrices(
      goldPricesByPurity: goldMap,
      silverPricesByPurity: silverMap,
      updatedAt: parsed,
      currency: _currencyCode,
      source: prefs.getString('${prefix}source') ?? 'Cached price',
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zakat_currency_code', _currencyCode);
    await prefs.setString('zakat_nisab_basis', _nisabBasis);
    await prefs.setString('zakat_gold_purity', _goldPurity);
    await prefs.setString('zakat_silver_purity', _silverPurity);
    await prefs.setBool('zakat_gold_resale_mode', _goldUseResaleValue);
    await prefs.setBool('zakat_silver_resale_mode', _silverUseResaleValue);
    await prefs.setBool('zakat_haul_complete', _haulComplete);
    for (final entry in _controllers.entries) {
      await prefs.setString('zakat_${entry.key}', entry.value.text);
    }
    final prices = _prices;
    if (prices != null) {
      final prefix = 'zakat_price_${_currencyCode}_';
      await prefs.setDouble('${prefix}gold', prices.goldPerGram);
      await prefs.setDouble('${prefix}silver', prices.silverPerGram);
      for (final entry in prices.goldPricesByPurity.entries) {
        await prefs.setDouble('${prefix}gold_${entry.key}', entry.value);
      }
      for (final entry in prices.silverPricesByPurity.entries) {
        await prefs.setDouble('${prefix}silver_${entry.key}', entry.value);
      }
      await prefs.setString('${prefix}updated', prices.updatedAt.toIso8601String());
      await prefs.setString('${prefix}source', prices.source);
    }
  }

  Future<void> _refreshPrices() async {
    if (!mounted || _loadingPrices) return;
    setState(() {
      _loadingPrices = true;
      _priceError = null;
    });
    try {
      final prices = await _metalService.fetch(currency: _currencyCode);
      if (!mounted) return;
      setState(() {
        _prices = prices;
        _loadingPrices = false;
        _priceError = null;
        _recalculate();
      });
      await _save();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPrices = false;
        _priceError = _prices == null
            ? 'Current reference prices could not be loaded. Please try again.'
            : 'Could not refresh current prices. Using the saved reference price from ${(_updatedLabel().startsWith('Updated ') ? _updatedLabel().substring(8) : _updatedLabel())}.';
        _recalculate();
      });
    }
  }

  void _recalculateFromInput() {
    if (!mounted || _restoring) return;
    setState(_recalculate);
  }

  double _number(String key) => double.tryParse(_controllers[key]?.text.trim() ?? '') ?? 0;

  double _goldPriceForPurity(String purity) {
    final prices = _prices;
    if (prices == null) return 0;
    return prices.goldPrice(purity);
  }

  double _silverPriceForPurity(String purity) {
    final prices = _prices;
    if (prices == null) return 0;
    return prices.silverPrice(purity);
  }

  double get _goldValue {
    if (_goldUseResaleValue) return _number('goldResale');
    return _number('goldGrams') * _goldPriceForPurity(_goldPurity);
  }

  double get _silverValue {
    if (_silverUseResaleValue) return _number('silverResale');
    return _number('silverGrams') * _silverPriceForPurity(_silverPurity);
  }

  void _recalculate() {
    final goldPrice = _prices?.goldPerGram ?? 0;
    final silverPrice = _prices?.silverPerGram ?? 0;
    final nisab = _nisabBasis == 'Gold'
        ? goldPrice * ZakatService.goldNisabGrams
        : silverPrice * ZakatService.silverNisabGrams;

    if (nisab <= 0) {
      _result = null;
      return;
    }

    _result = _service.calculate(
      goldValue: _goldValue,
      silverValue: _silverValue,
      cash: _number('cash'),
      bankSavings: _number('bank'),
      receivables: _number('receivables'),
      investments: _number('investments'),
      businessInventory: _number('business'),
      otherZakatable: _number('other'),
      deductibleLiabilities: _number('liabilities'),
      nisab: nisab,
      nisabBasis: _nisabBasis,
      haulComplete: _haulComplete,
    );
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(_recalculate);
    _save();
  }

  void _clear() {
    for (final controller in _controllers.values) controller.clear();
    setState(() {
      _result = null;
      _goldUseResaleValue = false;
      _silverUseResaleValue = false;
      _haulComplete = false;
    });
    _save();
  }

  String _symbolFor(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'GBP': return '£';
      case 'EUR': return '€';
      default: return '₹';
    }
  }

  String _money(double value) => '$_currencySymbol${_formatNumber(value)}';

  String _formatNumber(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return '${buffer.toString()}.${parts[1]}';
  }

  String _updatedLabel() {
    final updated = _prices?.updatedAt;
    if (updated == null) return 'Not loaded yet';
    final local = updated.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Updated ${local.day}/${local.month}/${local.year} at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Zakat Calculator'),
        actions: [
          IconButton(
            tooltip: 'Learn about Zakat',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatEducationScreen())),
          ),
          IconButton(
            tooltip: 'Refresh prices',
            icon: _loadingPrices
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _mint))
                : const Icon(Icons.refresh_rounded),
            onPressed: _loadingPrices ? null : _refreshPrices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPrices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _introCard(),
            const SizedBox(height: 16),
            _sectionTitle('1. Nisab & Zakat year'),
            _nisabCard(),
            const SizedBox(height: 16),
            _sectionTitle('2. Gold & Silver'),
            _goldCard(),
            const SizedBox(height: 10),
            _silverCard(),
            const SizedBox(height: 16),
            _sectionTitle('3. Other Zakatable Wealth'),
            ..._moneyFields.map(_moneyFieldCard),
            const SizedBox(height: 12),
            _resultCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: _clear, icon: const Icon(Icons.clear_all_rounded), label: const Text('Clear'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(onPressed: _calculate, icon: const Icon(Icons.calculate_rounded), label: const Text('Calculate'))),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatEducationScreen())),
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('Understand Zakat in simple words'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Important: this is a calculation aid, not a fatwa. Rules can differ between madhhabs and individual circumstances, especially for personal-use jewellery, investments, business assets, receivables and debt deductions.',
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _introCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: _green.withOpacity(.16), borderRadius: BorderRadius.circular(20), border: Border.all(color: _green.withOpacity(.35))),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.volunteer_activism_rounded, color: _mint, size: 30),
          SizedBox(height: 10),
          Text('Calculate your Zakat', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          SizedBox(height: 5),
          Text('Seeker automatically gets current indicative metal prices, calculates Nisab, and shows every step instead of hiding the arithmetic.', style: TextStyle(color: Colors.white70, height: 1.45)),
        ]),
      );

  Widget _sectionTitle(String text) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)));

  Widget _nisabCard() => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Row(children: [
            const Expanded(child: Text('Nisab standard', style: TextStyle(color: Colors.white70))),
            DropdownButton<String>(
              value: _nisabBasis,
              dropdownColor: _card,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                DropdownMenuItem(value: 'Gold', child: Text('Gold')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() { _nisabBasis = value; _recalculate(); });
                _save();
              },
            ),
          ]),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Choose according to the guidance/scholar you follow. Seeker does not decide this religious question for you.', style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Expanded(child: Text('Currency', style: TextStyle(color: Colors.white70))),
            DropdownButton<String>(
              value: _currencyCode,
              dropdownColor: _card,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
                DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
              ],
              onChanged: (value) async {
                if (value == null || value == _currencyCode) return;
                final hasEntries = _moneyFields.any((field) => _controllers[field.$1]!.text.trim().isNotEmpty) ||
                    _controllers['goldGrams']!.text.trim().isNotEmpty ||
                    _controllers['silverGrams']!.text.trim().isNotEmpty;
                if (hasEntries) {
                  final proceed = await _confirmCurrencyChange();
                  if (!proceed || !mounted) return;
                }
                setState(() {
                  _currencyCode = value;
                  _currencySymbol = _symbolFor(value);
                  _prices = null;
                  _result = null;
                });
                await _save();
                _refreshPrices();
              },
            ),
          ]),
          const SizedBox(height: 10),
          _livePriceRow('Gold 24K', _prices?.goldPrice('24K'), Icons.circle, _gold),
          const SizedBox(height: 8),
          _livePriceRow('Silver 999', _prices?.silverPrice('999'), Icons.circle, Colors.white70),
          if (_priceError != null) ...[
            const SizedBox(height: 9),
            Align(alignment: Alignment.centerLeft, child: Text(_priceError!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, height: 1.4))),
          ],
          const SizedBox(height: 5),
          Align(alignment: Alignment.centerLeft, child: Text('$_updatedLabel • Indicative reference-market prices • Source: ${_prices?.source ?? 'not available'}', style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4))),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white38, size: 16),
            const SizedBox(width: 7),
            Expanded(child: Text(_nisabBasis == 'Gold' ? 'Gold Nisab = 87.48 g × current 24K gold reference price' : 'Silver Nisab = 612.36 g × current 999 silver reference price', style: const TextStyle(color: Colors.white54, fontSize: 12))),
          ]),
          if (_result != null) ...[
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerLeft, child: Text('Selected Nisab: ${_money(_result!.nisab)}', style: const TextStyle(color: _mint, fontWeight: FontWeight.w700))),
          ],
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _haulComplete,
            onChanged: (value) {
              setState(() { _haulComplete = value; _recalculate(); });
              _save();
            },
            activeColor: _mint,
            title: const Text('My Zakat year has completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: const Text('One Hijri/lunar year has passed according to the date you follow.', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ]),
      );

  Widget _livePriceRow(String label, double? value, IconData icon, Color iconColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 13),
          const SizedBox(width: 10),
          Expanded(child: Text('$label • per gram', style: const TextStyle(color: Colors.white70))),
          if (_loadingPrices && value == null)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _mint))
          else
            Text(value == null ? '—' : _money(value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _goldCard() => _metalCard(
        title: 'Gold',
        color: _gold,
        gramsKey: 'goldGrams',
        resaleKey: 'goldResale',
        useResale: _goldUseResaleValue,
        purity: _goldPurity,
        purityOptions: _purityFactors.keys.toList(),
        onPurityChanged: (value) { setState(() { _goldPurity = value; _recalculate(); }); _save(); },
        onResaleChanged: (value) { setState(() { _goldUseResaleValue = value; _recalculate(); }); _save(); },
        resaleHelp: 'For jewellery, a jeweller’s current scrap/resale valuation may be more appropriate than a generic spot price.',
        unitLabel: 'Purity',
      );

  Widget _silverCard() => _metalCard(
        title: 'Silver',
        color: Colors.white70,
        gramsKey: 'silverGrams',
        resaleKey: 'silverResale',
        useResale: _silverUseResaleValue,
        purity: _silverPurity,
        purityOptions: _silverPurityFactors.keys.toList(),
        onPurityChanged: (value) { setState(() { _silverPurity = value; _recalculate(); }); _save(); },
        onResaleChanged: (value) { setState(() { _silverUseResaleValue = value; _recalculate(); }); _save(); },
        resaleHelp: 'If you know the current scrap/resale value of your silver, you can use it instead of the live spot estimate.',
        unitLabel: 'Purity',
      );

  Widget _metalCard({
    required String title,
    required Color color,
    required String gramsKey,
    required String resaleKey,
    required bool useResale,
    required String purity,
    required List<String> purityOptions,
    required ValueChanged<String> onPurityChanged,
    required ValueChanged<bool> onResaleChanged,
    required String resaleHelp,
    required String unitLabel,
  }) {
    final price = title == 'Gold'
        ? _goldPriceForPurity(purity)
        : _silverPriceForPurity(purity);
    final calculatedValue = _number(gramsKey) * price;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.circle, color: color, size: 14),
          const SizedBox(width: 9),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(price <= 0 ? 'Price unavailable' : '${_money(price)}/g', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _compactInput(gramsKey, 'Weight (grams)', Icons.scale_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _dropdownField(unitLabel, purity, purityOptions, onPurityChanged)),
        ]),
        if (!useResale) ...[
          const SizedBox(height: 8),
          Text('Estimated metal value: ${_money(calculatedValue)}', style: const TextStyle(color: _mint, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 4),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: useResale,
          activeColor: _mint,
          onChanged: onResaleChanged,
          title: const Text('Use actual resale / scrap value instead', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        if (useResale) ...[
          _compactInput(resaleKey, 'Current resale / scrap value', Icons.sell_outlined),
          const SizedBox(height: 4),
          Text(resaleHelp, style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
        ],
      ]),
    );
  }

  Widget _compactInput(String key, String label, IconData icon) => TextField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          suffixText: key.contains('Grams') ? 'g' : _currencySymbol,
          suffixStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
        ),
      );

  Widget _dropdownField(String label, String value, List<String> values, ValueChanged<String> onChanged) => DropdownButtonFormField<String>(
        value: value,
        dropdownColor: _card,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54, fontSize: 12), filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none)),
        items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (value) { if (value != null) onChanged(value); },
      );

  Widget _moneyFieldCard((String, String, String, IconData) field) {
    final key = field.$1;
    final isLiability = key == 'liabilities';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(17)),
      child: TextField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(field.$4, color: isLiability ? Colors.redAccent : _mint),
          labelText: field.$2,
          hintText: field.$3,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          suffixText: _currencySymbol,
          suffixStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _resultCard() {
    final result = _result;
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)),
        child: const Text('Waiting for current metal prices. Your entries will be calculated automatically when the price data is available.', style: TextStyle(color: Colors.white54, height: 1.5)),
      );
    }

    final reachesNisab = result.zakatableWealth >= result.nisab;
    final status = !reachesNisab
        ? 'Below Nisab'
        : !result.haulComplete
            ? 'Nisab reached • Zakat year not confirmed'
            : 'Zakat due';
    final displayDue = reachesNisab ? result.zakatableWealth * ZakatService.zakatRate : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: result.eligible ? _green.withOpacity(.22) : _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: result.eligible ? _green.withOpacity(.55) : Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(status, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 5),
        Text(_money(displayDue), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        if (reachesNisab && !result.haulComplete) ...[
          const SizedBox(height: 5),
          const Text('This is the amount that would be due once your Zakat year is complete, assuming the same wealth and method.', style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.45)),
        ],
        const SizedBox(height: 14),
        _summaryRow('Gross Zakatable Assets', result.grossAssets),
        _summaryRow('Eligible Liabilities Entered', result.deductibleLiabilities),
        _summaryRow('Net Zakatable Wealth', result.zakatableWealth),
        _summaryRow('${result.nisabBasis} Nisab', result.nisab),
        const SizedBox(height: 10),
        Text(
          reachesNisab
              ? '${_money(result.zakatableWealth)} × 2.5% = ${_money(displayDue)}'
              : 'Your net Zakatable wealth is below the selected Nisab.',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, double value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Colors.white60))), Text(_money(value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]));

  Future<bool> _confirmCurrencyChange() async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Change currency?', style: TextStyle(color: Colors.white)),
        content: const Text('Your existing money entries are numbers in the current currency. Seeker will not silently convert them. Clear and re-enter the amounts after changing currency.', style: TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () { for (final field in _moneyFields) _controllers[field.$1]!.clear(); _controllers['goldResale']!.clear(); _controllers['silverResale']!.clear(); Navigator.pop(context, true); }, child: const Text('Change')),
        ],
      ),
    );
    return answer ?? false;
  }
}
