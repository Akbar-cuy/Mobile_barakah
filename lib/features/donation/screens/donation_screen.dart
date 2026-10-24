import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donation_models.dart';
import '../providers/donation_provider.dart';
import '../widgets/donation_widgets.dart';
import 'donation_receipt_screen.dart';

// Layar Zakat dan Donasi: tab Zakat dan tab Donasi
class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DonationProvider(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Zakat & Donasi'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Zakat'),
                Tab(text: 'Donasi'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ZakatTab(),
              DonationTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// Tab Zakat
// =========================================================
class ZakatTab extends StatefulWidget {
  const ZakatTab({super.key});

  @override
  State<ZakatTab> createState() => _ZakatTabState();
}

class _ZakatTabState extends State<ZakatTab> {
  final TextEditingController _inputController = TextEditingController();
  late final TextEditingController _goldController;
  late final TextEditingController _fitrahController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DonationProvider>();
    _goldController = TextEditingController(
      text: provider.goldPricePerGram.toStringAsFixed(0),
    );
    _fitrahController = TextEditingController(
      text: provider.fitrahPerPerson.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _goldController.dispose();
    _fitrahController.dispose();
    super.dispose();
  }

  Future<void> _payZakat() async {
    final provider = context.read<DonationProvider>();
    final donation = await provider.donateZakat();
    if (donation == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationReceiptScreen(donation: donation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final result = provider.zakatResult;
    final isMaal = provider.zakatType == 'maal';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pilih jenis zakat
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'maal', label: Text('Zakat Maal')),
            ButtonSegment(value: 'fitrah', label: Text('Zakat Fitrah')),
          ],
          selected: {provider.zakatType},
          onSelectionChanged: (selection) {
            _inputController.clear();
            provider.setZakatType(selection.first);
          },
        ),
        const SizedBox(height: 16),

        // Input: harta (maal) atau jumlah jiwa (fitrah)
        if (isMaal)
          AmountInput(
            label: 'Total harta',
            controller: _inputController,
            currency: provider.zakatCurrency,
            errorText: provider.zakatError,
            onAmountChanged: provider.setZakatInput,
            onCurrencyChanged: provider.setZakatCurrency,
          )
        else
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah jiwa',
              border: const OutlineInputBorder(),
              errorText: provider.zakatError,
            ),
            onChanged: provider.setZakatInput,
          ),
        const SizedBox(height: 8),

        // Nilai yang bisa diatur
        ExpansionTile(
          title: const Text('Atur nilai nisab dan fitrah'),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _goldController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga emas per gram (Rp)',
                  border: OutlineInputBorder(),
                ),
                onChanged: provider.setGoldPrice,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _fitrahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nilai fitrah per jiwa (Rp)',
                  border: OutlineInputBorder(),
                ),
                onChanged: provider.setFitrahValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ElevatedButton(
          onPressed: provider.calculateZakat,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Hitung zakat'),
        ),

        // Hasil perhitungan
        if (result != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!result.wajib)
                    Text(
                      'Harta belum mencapai nisab (${provider.nisabText}). '
                      'Belum wajib zakat maal.',
                    )
                  else ...[
                    Text(
                      isMaal ? 'Zakat maal (2,5%)' : 'Zakat fitrah',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final e in provider.zakatAmounts)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isMaal) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nisab: ${provider.nisabText} (85 gram emas)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: result.wajib && !provider.saving ? _payZakat : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: provider.saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Bayar zakat (simulasi)'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Donasi bersifat simulasi, tidak ada pembayaran riil.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// =========================================================
// Tab Donasi
// =========================================================
class DonationTab extends StatefulWidget {
  const DonationTab({super.key});

  @override
  State<DonationTab> createState() => _DonationTabState();
}

class _DonationTabState extends State<DonationTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _aliasController =
      TextEditingController(text: 'Hamba Allah');

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _openReceipt(Donation donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationReceiptScreen(donation: donation),
      ),
    );
  }

  Future<void> _confirm() async {
    final provider = context.read<DonationProvider>();
    final donation = await provider.confirmDonation();
    if (donation == null || !mounted) return;
    _amountController.clear();
    _openReceipt(donation);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final campaigns = provider.filteredCampaigns;
    final equivalents = provider.equivalents;
    final history = provider.donations.reversed.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cari kampanye
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Cari kampanye',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: provider.setSearch,
        ),
        const SizedBox(height: 8),

        // Filter kategori
        Wrap(
          spacing: 8,
          children: [
            for (final c in provider.categories)
              ChoiceChip(
                label: Text(c),
                selected: c == provider.category,
                onSelected: (_) => provider.setCategory(c),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Daftar kampanye
        Column(
          children: [
            if (campaigns.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Kampanye tidak ditemukan. Coba ubah kata kunci.'),
              )
            else
              for (final c in campaigns)
                CampaignCard(
                  campaign: c,
                  selected: provider.selectedCampaign?.id == c.id,
                  onTap: () => provider.selectCampaign(c),
                ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Kampanye dipilih: ${provider.selectedCampaign?.title ?? '-'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Nominal dan mata uang
        AmountInput(
          label: 'Nominal donasi',
          controller: _amountController,
          currency: provider.currency,
          errorText: provider.showAmountError ? provider.amountError : null,
          onAmountChanged: provider.setAmount,
          onCurrencyChanged: provider.setCurrency,
        ),
        if (equivalents.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Setara: ${equivalents.map((e) => e.value).join('  |  ')}'),
        ],
        const SizedBox(height: 12),

        // Alias donatur
        TextField(
          controller: _aliasController,
          decoration: const InputDecoration(
            labelText: 'Alias donatur',
            border: OutlineInputBorder(),
          ),
          onChanged: provider.setAlias,
        ),
        const SizedBox(height: 8),
        const Text(
          'Donasi bersifat simulasi, tidak ada pembayaran riil.',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: provider.saving ? null : _confirm,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: provider.saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Konfirmasi donasi'),
        ),

        // Riwayat donasi
        if (history.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Riwayat donasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          for (final d in history)
            Card(
              child: ListTile(
                title: Text(d.campaignTitle),
                subtitle: Text('Blok #${d.blockIndex}'),
                trailing: Text(
                  provider.formatMoney(d.amount, d.currency),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _openReceipt(d),
              ),
            ),
        ],
      ],
    );
  }
}