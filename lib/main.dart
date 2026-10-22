import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/home/providers/home_provider.dart'; // sesuaikan path

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadData(),
      child: const BarakahApp(),
    ),
  );
}