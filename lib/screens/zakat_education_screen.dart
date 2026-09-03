import 'package:flutter/material.dart';

class ZakatEducationScreen extends StatelessWidget {
  const ZakatEducationScreen({super.key});

  static const _bg = Color(0xff252525);
  static const _card = Color(0xff303030);
  static const _green = Color(0xff2D6A4F);
  static const _mint = Color(0xff80CFA9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text('Understanding Zakat'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _section(
            'What is Zakat?',
            'Zakat is an obligatory act of worship on qualifying wealth. In simple terms, when a Muslim has enough Zakatable wealth and the required Zakat year has passed, a portion of that wealth is given to eligible recipients.',
            Icons.volunteer_activism_rounded,
          ),
          _section(
            'What is Nisab?',
            'Nisab is the minimum level of Zakatable wealth that makes Zakat applicable. The commonly used modern equivalents are 87.48 grams of gold or 612.36 grams of silver. Because metal prices change, the money value of Nisab changes too.',
            Icons.balance_rounded,
          ),
          _section(
            'Why does Seeker ask Gold or Silver?',
            'The two standards produce different money thresholds. Scholars and schools of Islamic law differ on which standard should be used in some circumstances. Seeker therefore does not silently decide a religious ruling for you: choose the standard that follows the guidance you trust.',
            Icons.compare_arrows_rounded,
          ),
          _section(
            'What is the Zakat year?',
            'For the common Zakat-on-wealth calculation, one Hijri (lunar) year is relevant after reaching Nisab. Seeker asks you to confirm that your Zakat anniversary has arrived. If your circumstances are unusual or your wealth repeatedly moves above and below Nisab, ask a qualified scholar.',
            Icons.calendar_month_rounded,
          ),
          _section(
            'What normally goes into the calculation?',
            'Cash, bank balances, qualifying savings, gold and silver, collectible/receivable money, qualifying investments and goods held for sale can be included. Personal-use possessions such as your ordinary home, clothes and personal car are generally not treated as Zakatable wealth.',
            Icons.account_balance_wallet_rounded,
          ),
          _section(
            'Gold and jewellery: a simple explanation',
            'Seeker shows a live 24K gold market price and lets you choose the purity of your gold. For example, 22K gold contains about 22 parts gold out of 24, so its metal value is lower than the same weight of 24K gold. For jewellery, an actual resale/scrap valuation from a reputable jeweller can be more appropriate than a generic spot price. Different schools also differ on personal-use jewellery.',
            Icons.diamond_outlined,
          ),
          _section(
            'How the calculation works',
            '1. Add your Zakatable assets.\n2. Add the value of your gold and silver.\n3. Subtract only liabilities that are actually deductible under the method you follow.\n4. Compare the resulting net Zakatable wealth with Nisab.\n5. If Nisab is reached and the Zakat year is complete, Seeker calculates 2.5% of the applicable net wealth.',
            Icons.calculate_rounded,
          ),
          _exampleCard(),
          _section(
            'One important caution',
            'There is no single calculator that can settle every fiqh question. Jewellery, investment portfolios, business assets, long-term debts, pension funds, receivables and changes in wealth during the year can require a specific ruling. Seeker is designed to make the arithmetic transparent while leaving those religious judgments visible to you.',
            Icons.info_outline_rounded,
          ),
          const SizedBox(height: 8),
          const Text(
            'Seeker uses commonly published Nisab quantities of 87.48 g gold and 612.36 g silver and a 2.5% rate for this Zakat-on-wealth calculator. For a binding ruling, consult a qualified scholar familiar with your circumstances.',
            style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: .20),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _green.withValues(alpha: .45)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.menu_book_rounded, color: _mint, size: 34),
            SizedBox(height: 12),
            Text('Zakat, without the confusion', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 7),
            Text('A plain-language guide to what Nisab means, what you enter, and how Seeker reaches the final number.', style: TextStyle(color: Colors.white70, height: 1.5)),
          ],
        ),
      );

  Widget _section(String title, String body, IconData icon) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _mint, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 9),
            Text(body, style: const TextStyle(color: Colors.white70, height: 1.55)),
          ],
        ),
      );

  Widget _exampleCard() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _green.withValues(alpha: .30)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A simple example', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            SizedBox(height: 10),
            Text('Suppose your applicable Zakatable wealth is ₹5,00,000 after eligible deductions, and your selected Nisab is ₹2,00,000.', style: TextStyle(color: Colors.white70, height: 1.5)),
            SizedBox(height: 8),
            Text('₹5,00,000 ≥ ₹2,00,000  →  Nisab reached', style: TextStyle(color: _mint, fontWeight: FontWeight.w700)),
            SizedBox(height: 5),
            Text('₹5,00,000 × 2.5%  →  ₹12,500 Zakat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Notice: you do not calculate 2.5% of “wealth minus Nisab”. Nisab is the threshold test; once the applicable wealth reaches it, the 2.5% is calculated on the applicable Zakatable wealth.', style: TextStyle(color: Colors.white54, height: 1.5, fontSize: 12)),
          ],
        ),
      );
}
