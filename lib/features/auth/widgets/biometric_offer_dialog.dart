import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../providers/session_provider.dart';

Future<void> showBiometricOfferDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const BiometricOfferDialog(),
  );
}

/// FR-BIO-02: aktivasi memerlukan kata sandi, lalu verifikasi biometrik.
class BiometricOfferDialog extends ConsumerStatefulWidget {
  const BiometricOfferDialog({super.key});

  @override
  ConsumerState<BiometricOfferDialog> createState() => _BiometricOfferDialogState();
}

class _BiometricOfferDialogState extends ConsumerState<BiometricOfferDialog> {
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _enable() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Masukkan kata sandi Anda.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await ref.read(sessionProvider.notifier).enableBiometric(_password.text);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        setState(() {
          _loading = false;
          _error = 'Verifikasi biometrik dibatalkan.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aktifkan login biometrik?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Masuk lebih cepat dengan sidik jari atau wajah. Masukkan kata sandi untuk mengonfirmasi.'),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Kata sandi', errorText: _error),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Nanti'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _loading ? null : _enable,
          child: const Text('Aktifkan'),
        ),
      ],
    );
  }
}
