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
        if (provider.loadingRates)
          const Center(child: CircularProgressIndicator())
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
        Text(provider.ratesLabel, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
