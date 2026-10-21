import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/converter_provider.dart';
import '../widgets/currency_converter_tab.dart';
import '../widgets/time_converter_tab.dart';

// Layar Konversi: tab Waktu dan tab Mata Uang
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConverterProvider(),
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