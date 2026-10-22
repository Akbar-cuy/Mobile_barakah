// M5 Pusat Ibadah dan Pencarian (FR-SRC-01, FR-SRC-02)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/route_names.dart';

enum FeatureGroup {
  worship('Ibadah'),
  finance('Keuangan'),
  learning('Belajar');

  const FeatureGroup(this.label);
  final String label;
}

class AppFeature {
  const AppFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.group,
    this.keywords = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final FeatureGroup group;

  /// Kata lain yang dicari pengguna untuk fitur ini.
  final List<String> keywords;
}

/// Daftar fitur di hub. IoT hanya muncul bila diaktifkan (M21 opsional).
List<AppFeature> buildFeatures({bool iotEnabled = AppConfig.enableIot}) => [
      const AppFeature(
        id: 'qibla',
        title: 'Arah Kiblat',
        subtitle: 'Kompas menuju Ka\'bah',
        icon: Icons.explore_outlined,
        route: RouteNames.qibla,
        group: FeatureGroup.worship,
        keywords: ['kompas', 'kaabah', 'kabah', 'mekah', 'arah'],
      ),
      const AppFeature(
        id: 'tasbih',
        title: 'Tasbih Digital',
        subtitle: 'Hitung dzikir dengan goyang atau ketuk',
        icon: Icons.radio_button_checked,
        route: RouteNames.tasbih,
        group: FeatureGroup.worship,
        keywords: ['dzikir', 'zikir', 'hitung', 'counter'],
      ),
      const AppFeature(
        id: 'mosque',
        title: 'Masjid Terdekat',
        subtitle: 'Cari masjid di sekitar Anda',
        icon: Icons.mosque_outlined,
        route: RouteNames.mosque,
        group: FeatureGroup.worship,
        keywords: ['musholla', 'mushola', 'peta', 'lokasi', 'sholat'],
      ),
      const AppFeature(
        id: 'adhan',
        title: 'Pengingat Adzan',
        subtitle: 'Notifikasi waktu sholat',
        icon: Icons.notifications_active_outlined,
        route: RouteNames.notificationSettings,
        group: FeatureGroup.worship,
        keywords: ['notifikasi', 'azan', 'adzan', 'jadwal', 'alarm'],
      ),
      if (iotEnabled)
        const AppFeature(
          id: 'iot',
          title: 'Tasbih Fisik (IoT)',
          subtitle: 'Hubungkan perangkat ESP32',
          icon: Icons.sensors,
          route: RouteNames.iot,
          group: FeatureGroup.worship,
          keywords: ['esp32', 'perangkat', 'alat'],
        ),
      const AppFeature(
        id: 'donation',
        title: 'Donasi',
        subtitle: 'Berdonasi dan catat di ledger',
        icon: Icons.volunteer_activism_outlined,
        route: RouteNames.donation,
        group: FeatureGroup.finance,
        keywords: ['infak', 'sedekah', 'kampanye', 'amal'],
      ),
      const AppFeature(
        id: 'zakat',
        title: 'Kalkulator Zakat',
        subtitle: 'Hitung zakat penghasilan dan emas',
        icon: Icons.calculate_outlined,
        route: RouteNames.zakat,
        group: FeatureGroup.finance,
        keywords: ['nisab', 'maal', 'penghasilan', 'emas'],
      ),
      const AppFeature(
        id: 'ledger',
        title: 'Ledger Donasi',
        subtitle: 'Rantai blok donasi Anda',
        icon: Icons.link,
        route: RouteNames.ledger,
        group: FeatureGroup.finance,
        keywords: ['blockchain', 'blok', 'verifikasi', 'riwayat donasi'],
      ),
      const AppFeature(
        id: 'converter',
        title: 'Konversi Mata Uang',
        subtitle: 'Kurs ke rupiah',
        icon: Icons.currency_exchange,
        route: RouteNames.converter,
        group: FeatureGroup.finance,
        keywords: ['kurs', 'uang', 'dolar', 'usd', 'valuta'],
      ),
      const AppFeature(
        id: 'ai',
        title: 'Tanya AI',
        subtitle: 'Tanya seputar ibadah',
        icon: Icons.chat_outlined,
        route: RouteNames.aiChat,
        group: FeatureGroup.learning,
        keywords: ['asisten', 'chat', 'bertanya', 'fiqih'],
      ),
      const AppFeature(
        id: 'quiz',
        title: 'Kuis Islami',
        subtitle: 'Uji pengetahuan Anda',
        icon: Icons.quiz_outlined,
        route: RouteNames.quiz,
        group: FeatureGroup.learning,
        keywords: ['soal', 'belajar', 'game', 'permainan'],
      ),
      const AppFeature(
        id: 'direction',
        title: 'Cari Arah',
        subtitle: 'Permainan menebak arah kiblat',
        icon: Icons.sports_esports_outlined,
        route: RouteNames.directionGame,
        group: FeatureGroup.learning,
        keywords: ['game', 'permainan', 'kiblat', 'tebak'],
      ),
    ];

abstract final class FeatureSearch {
  /// Pencarian langsung (FR-SRC-02): setiap kata pada [query] harus muncul di
  /// judul, subjudul, atau kata kunci. Tanpa membedakan huruf besar kecil.
  static List<AppFeature> filter(List<AppFeature> all, String query) {
    final terms = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return all;
    return all.where((f) {
      final hay = '${f.title} ${f.subtitle} ${f.keywords.join(' ')}'.toLowerCase();
      return terms.every(hay.contains);
    }).toList();
  }
}

class FeatureQueryController extends Notifier<String> {
  @override
  String build() => '';

  void set(String q) => state = q;
}

final featureQueryProvider =
    NotifierProvider<FeatureQueryController, String>(FeatureQueryController.new);

final featuresProvider = Provider<List<AppFeature>>((ref) => buildFeatures());

final filteredFeaturesProvider = Provider<List<AppFeature>>((ref) {
  return FeatureSearch.filter(ref.watch(featuresProvider), ref.watch(featureQueryProvider));
});
