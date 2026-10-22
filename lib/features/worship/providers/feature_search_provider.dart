// M16 Beranda Ibadah (FR-HUB). Daftar fitur dan pencarian.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_names.dart';

class WorshipFeature {
  const WorshipFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.keywords,
    this.route,
    this.isTab = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String keywords;

  /// Null berarti modul belum tersedia.
  final String? route;

  /// Tab pada bottom navigation dibuka dengan go, bukan push.
  final bool isTab;

  bool get available => route != null;
}

const worshipFeatures = <WorshipFeature>[
  WorshipFeature(
    title: 'Jadwal Sholat',
    subtitle: 'Waktu sholat dan hitung mundur',
    icon: Icons.schedule,
    keywords: 'jadwal sholat waktu adzan subuh dzuhur ashar maghrib isya',
    route: RouteNames.home,
    isTab: true,
  ),
  WorshipFeature(
    title: 'Pengingat Adzan',
    subtitle: 'Notifikasi waktu sholat',
    icon: Icons.notifications_active_outlined,
    keywords: 'pengingat adzan notifikasi alarm',
    route: RouteNames.notificationSettings,
  ),
  WorshipFeature(
    title: 'Arah Kiblat',
    subtitle: 'Kompas arah Ka\'bah',
    icon: Icons.explore_outlined,
    keywords: 'arah kiblat kompas kabah',
  ),
  WorshipFeature(
    title: 'Masjid Terdekat',
    subtitle: 'Peta dan jarak masjid',
    icon: Icons.mosque_outlined,
    keywords: 'masjid terdekat peta lokasi',
  ),
  WorshipFeature(
    title: 'Tasbih Digital',
    subtitle: 'Hitung dzikir dengan goyang',
    icon: Icons.fingerprint,
    keywords: 'tasbih dzikir hitung goyang',
  ),
  WorshipFeature(
    title: 'Zakat dan Donasi',
    subtitle: 'Hitung zakat dan berdonasi',
    icon: Icons.volunteer_activism_outlined,
    keywords: 'zakat donasi infaq sedekah',
  ),
  WorshipFeature(
    title: 'Buku Catatan Donasi',
    subtitle: 'Riwayat berantai hash',
    icon: Icons.link,
    keywords: 'ledger blockchain catatan donasi hash',
  ),
  WorshipFeature(
    title: 'Konversi',
    subtitle: 'Mata uang dan zona waktu',
    icon: Icons.currency_exchange,
    keywords: 'konversi mata uang waktu zona idr usd sar',
  ),
  WorshipFeature(
    title: 'Tanya Fikih',
    subtitle: 'Tanya jawab fikih dasar',
    icon: Icons.chat_outlined,
    keywords: 'tanya fikih ai asisten',
  ),
  WorshipFeature(
    title: 'Kuis dan Game',
    subtitle: 'Uji pengetahuan Islam',
    icon: Icons.quiz_outlined,
    keywords: 'kuis game quiz pengetahuan',
  ),
];

class FeatureQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final featureQueryProvider =
    NotifierProvider<FeatureQueryNotifier, String>(FeatureQueryNotifier.new);

final filteredFeaturesProvider = Provider<List<WorshipFeature>>((ref) {
  final query = ref.watch(featureQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return worshipFeatures;
  return [
    for (final f in worshipFeatures)
      if (f.title.toLowerCase().contains(query) || f.keywords.contains(query)) f,
  ];
});
