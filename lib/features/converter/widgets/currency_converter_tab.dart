import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/converter_provider.dart';
import '../services/currency_service.dart';

// Tab Mata Uang: konversi nominal antar IDR, USD, dan SAR
class CurrencyConverterTab extends StatefulWidget {
  const CurrencyConverterTab({super.key});

  @override
  State<CurrencyConverterTab> createState() => _CurrencyConverterTabState();
}

class _CurrencyConverterTabState extends State<CurrencyConverterTab> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ConverterProvider>();
    _amountController = TextEditingController(text: provider.amountText);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConverterProvider>();
    final results = provider.currencyResults;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Nominal',
            border: const OutlineInputBorder(),
            errorText: provider.amountError,
          ),
          onChanged: (text) => provider.setAmount(text),
        ),
        const SizedBox(height: 12),

        // Pilih mata uang asal dan tujuan
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: provider.fromCurrency,
                decoration: const InputDecoration(
                  labelText: 'Dari',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in currencyList)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (value) {
                  if (value != null) provider.setFromCurrency(value);
                },
              ),
            ),
            IconButton(
              onPressed: () => provider.swapCurrency(),
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Tukar',
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: provider.toCurrency,
                decoration: const InputDecoration(
                  labelText: 'Ke',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in currencyList)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (value) {
                  if (value != null) provider.setToCurrency(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hasil konversi ke semua mata uang
        if (provider.loadingRates && provider.rates == null)
          const Center(child: CircularProgressIndicator())
        else if (provider.rates == null && provider.ratesError != null)
          _RateLoadError(
            message: provider.ratesError!,
            onRetry: provider.loadingRates ? null : provider.retryRates,
          )
        else if (provider.rates == null)
          _RateLoadError(
            message: 'Kurs belum tersedia.',
            onRetry: provider.loadingRates ? null : provider.retryRates,
          )
        else
          for (final r in results)
            Card(
              child: ListTile(
                title: Text(r.key),
                subtitle:
                    r.key == provider.toCurrency ? const Text('Tujuan') : null,
                trailing: Text(
                  r.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

        const SizedBox(height: 8),
        if (provider.loadingRates && provider.rates != null)
          const LinearProgressIndicator(),
        if (provider.rates != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.ratesLabel,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                onPressed: provider.loadingRates ? null : provider.retryRates,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Perbarui kurs',
              ),
            ],
          ),
        const Text(
          'Kurs referensi harian · Frankfurter',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _RateLoadError extends StatelessWidget {
  const _RateLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.currency_exchange, size: 28),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
