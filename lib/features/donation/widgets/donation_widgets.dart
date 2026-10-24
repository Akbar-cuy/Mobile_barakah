import 'package:flutter/material.dart';

import '../../converter/services/currency_service.dart';
import '../models/donation_models.dart';

// Kolom nominal + pilihan mata uang (IDR, USD, SAR)
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String currency;
  final String? errorText;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onCurrencyChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.label,
    required this.currency,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
          onChanged: onAmountChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final c in currencyList)
              ChoiceChip(
                label: Text(c),
                selected: c == currency,
                onSelected: (_) => onCurrencyChanged(c),
              ),
          ],
        ),
      ],
    );
  }
}

// Kartu satu kampanye donasi
class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final bool selected;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final target = campaign.targetIdr > 0
        ? '\nTarget ${CurrencyService().format(campaign.targetIdr, 'IDR')}'
        : '';

    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(campaign.title),
        subtitle: Text('${campaign.category} - ${campaign.description}$target'),
        isThreeLine: target.isNotEmpty,
        trailing: Icon(selected ? Icons.check_circle : Icons.circle_outlined),
        onTap: onTap,
      ),
    );
  }
}