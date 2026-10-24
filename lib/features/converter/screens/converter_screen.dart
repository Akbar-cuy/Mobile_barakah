import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerWidget, WidgetRef;
import 'package:provider/provider.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/converter_provider.dart';
import '../repository/rate_repository.dart';
import '../widgets/currency_converter_tab.dart';
import '../widgets/time_converter_tab.dart';

// Layar Konversi: tab Waktu dan tab Mata Uang
class ConverterScreen extends ConsumerWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChangeNotifierProvider(
      create: (_) => ConverterProvider(
        rateRepository: RateRepository(
          db: ref.read(appDatabaseProvider),
          api: ref.read(apiGatewayProvider),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Konversi'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Waktu'),
                Tab(text: 'Mata Uang'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              TimeConverterTab(),
              CurrencyConverterTab(),
            ],
          ),
        ),
      ),
    );
  }
}
