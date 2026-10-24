import 'dart:math';

import 'package:barakah/features/games/services/direction_game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = DirectionGameEngine();

  test('creates five targets from Qibla, north, and city bearings', () {
    final targets = engine.createTargets(
      qiblaBearing: 293,
      latitude: -6.2,
      longitude: 106.8,
      random: Random(4),
    );

    expect(targets, hasLength(5));
    expect(
      targets.map((target) => target.kind),
      everyElement(isIn(DirectionTargetKind.values)),
    );
    expect(
        targets.every((target) => target.bearing >= 0 && target.bearing < 360),
        isTrue);
    expect(DirectionGameEngine.cities.map((city) => city.name),
        containsAll(['Jakarta', 'Madinah', 'Kairo']));
  });

  test(
      'angle tolerance handles the north wrap and score rewards speed/precision',
      () {
    expect(engine.errorDegrees(1, 359), 2);
    expect(engine.isWithinTolerance(1, 359), isTrue);
    expect(
      engine.scoreTarget(
        errorDegrees: 0,
        elapsed: Duration.zero,
      ),
      225,
    );
    expect(
      engine.scoreTarget(
        errorDegrees: 5,
        elapsed: const Duration(seconds: 15),
      ),
      100,
    );
    expect(
      engine.scoreTarget(
        errorDegrees: 5.1,
        elapsed: const Duration(seconds: 1),
      ),
      0,
    );
  });

  test('rejects invalid location and bearing input', () {
    expect(
      () => engine.createTargets(
        qiblaBearing: double.nan,
        latitude: 0,
        longitude: 0,
        random: Random(1),
      ),
      throwsArgumentError,
    );
  });
}
