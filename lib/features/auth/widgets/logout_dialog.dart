import 'package:flutter/material.dart';

import '../models/session.dart';

Future<LogoutOptions?> showLogoutDialog(BuildContext context) {
  return showDialog<LogoutOptions>(
    context: context,
    builder: (_) => const LogoutDialog(),
  );
}

/// FR-OUT-01 sampai FR-OUT-04.
class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _disableBiometric = false;
  bool _clearLocalData = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keluar dari Barakah?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sesi Anda akan diakhiri di perangkat ini.'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _disableBiometric,
            onChanged: (v) => setState(() => _disableBiometric = v ?? false),
            title: const Text('Nonaktifkan login biometrik di perangkat ini'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _clearLocalData,
            onChanged: (v) => setState(() => _clearLocalData = v ?? false),
            title: const Text('Hapus data di perangkat ini'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.pop(
            context,
            LogoutOptions(
              disableBiometric: _disableBiometric,
              clearLocalData: _clearLocalData,
            ),
          ),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}
