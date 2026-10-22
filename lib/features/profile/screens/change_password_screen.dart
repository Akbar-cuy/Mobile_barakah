// M17 Profil (FR-PRO-05). Ubah kata sandi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            oldPassword: _old.text,
            newPassword: _new.text,
          );
      if (!mounted) return;
      showAppSnackBar(context, 'Kata sandi diperbarui.');
      context.pop();
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kata Sandi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _old,
                  hint: 'Kata sandi lama',
                  icon: Icons.lock_outline,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Kata sandi lama'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _new,
                  hint: 'Kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirm,
                  hint: 'Ulangi kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  validator: (v) => Validators.confirmPassword(v, _new.text),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Simpan', loading: _busy, onPressed: _save),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
