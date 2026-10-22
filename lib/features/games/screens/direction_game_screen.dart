import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/direction_game_provider.dart';

// Game Cari Arah: hadapkan ponsel ke target dan tahan 2 detik
class DirectionGameScreen extends StatelessWidget {
  const DirectionGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider dibuang saat layar ditutup, sensor ikut dilepas
    return ChangeNotifierProvider(
      create: (_) => DirectionGameProvider(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectionGameProvider>();

    Widget body;
    switch (provider.status) {
      case GameStatus.idle:
        body = _buildIdle(context, provider);
        break;
      case GameStatus.checking:
        body = const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Memeriksa sensor...'),
            ],
          ),
        );
        break;
      case GameStatus.noSensor:
        body = _buildNoSensor(context);
        break;
      case GameStatus.playing:
        body = _buildPlaying(context, provider);
        break;
      case GameStatus.finished:
        body = _buildFinished(context, provider);
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Arah')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }

  // Layar awal: aturan main dan skor tertinggi
  Widget _buildIdle(BuildContext context, DirectionGameProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Hadapkan ponsel ke arah target, lalu tahan 2 detik '
            'dalam toleransi 5 derajat.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '5 target, 15 detik per target. Letakkan ponsel mendatar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text('Skor tertinggi: ${provider.highScore}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.start,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }

  // Sensor tidak ada: jelaskan dan sarankan kuis (AC.GAME.05)
  Widget _buildNoSensor(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sensors_off, size: 72),
          const SizedBox(height: 16),
          const Text(
            'Sensor arah (magnetometer) tidak tersedia di perangkat ini, '
            'jadi Cari Arah belum bisa dimainkan.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba mainkan Kuis Islami sebagai gantinya.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Main Kuis'),
          ),
        ],
      ),
    );
  }

  // Saat bermain: target, waktu, skor, dan panah penunjuk
  Widget _buildPlaying(BuildContext context, DirectionGameProvider provider) {
    final color = provider.onTarget ? Colors.green : null;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target ${provider.targetNumber}/${provider.targetCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Waktu 00:${provider.secondsLeft.toString().padLeft(2, '0')}'),
            Text('Skor ${provider.score}'),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Hadapkan ke:'),
        Text(
          provider.targetName,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const Spacer(),

        // Panah menunjuk ke target, cincin menunjukkan progres tahan 2 detik
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: provider.holdProgress,
                  strokeWidth: 10,
                  color: color,
                ),
              ),
              Transform.rotate(
                angle: provider.arrowAngle,
                child: Icon(Icons.navigation, size: 110, color: color),
              ),
            ],
          ),
        ),

        const Spacer(),
        SizedBox(
          height: 24,
          child: Text(
            provider.message,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Putar ponsel sampai panah menunjuk ke atas.\n'
          'Tahan 2 detik dalam 5 derajat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Putaran selesai: skor dan skor tertinggi
  Widget _buildFinished(BuildContext context, DirectionGameProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Putaran selesai',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '${provider.score}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('Skor'),
          const SizedBox(height: 8),
          if (provider.isNewBest)
            const Text(
              'Skor tertinggi baru!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          Text('Skor tertinggi: ${provider.highScore}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.start,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Main lagi'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}