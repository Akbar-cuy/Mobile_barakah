import 'package:barakah/features/worship/providers/feature_search_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final all = buildFeatures(iotEnabled: false);

  List<String> ids(String q) => [for (final f in FeatureSearch.filter(all, q)) f.id];

  group('FeatureSearch', () {
    test('kueri kosong mengembalikan semua', () {
      expect(ids('  ').length, all.length);
    });

    test('cocok pada judul tanpa membedakan huruf besar', () {
      expect(ids('KIBLAT'), containsAll(['qibla', 'direction']));
    });

    test('cocok pada kata kunci', () {
      expect(ids('dzikir'), ['tasbih']);
      expect(ids('sedekah'), ['donation']);
    });

    test('semua kata harus cocok', () {
      expect(ids('kuis islami'), ['quiz']);
      expect(ids('kuis zakat'), isEmpty);
    });
  });

  test('IoT hanya muncul bila diaktifkan', () {
    expect(buildFeatures(iotEnabled: false).any((f) => f.id == 'iot'), isFalse);
    expect(buildFeatures(iotEnabled: true).any((f) => f.id == 'iot'), isTrue);
  });

  test('rute unik', () {
    final routes = buildFeatures(iotEnabled: true).map((f) => f.route).toList();
    expect(routes.toSet().length, routes.length);
  });
}
