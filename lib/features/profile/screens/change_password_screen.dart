// M17 Profil (FR-PRO-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_banner.dart';
import '../providers/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(profileControllerProvider.notifier).clearError(),
    );
  }

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(profileControllerProvider.notifier).changePassword(
          oldPassword: _old.text,
          newPassword: _new.text,
        );
    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, 'Kata sandi diperbarui.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kata Sandi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          if (action.error != null) ...[
            StatusBanner(kind: BannerKind.error, message: action.error!),
            const SizedBox(height: AppSpacing.md),
          ],
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
                  validator: (value) =>
                      Validators.required(value, field: 'Kata sandi lama'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _new,
                  hint: 'Kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final error = Validators.password(value);
                    if (error != null) return error;
                    return value == _old.text
                        ? 'Kata sandi baru harus berbeda dari yang lama.'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirm,
                  hint: 'Ulangi kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  validator: (value) =>
                      Validators.confirmPassword(value, _new.text),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Simpan',
            loading: action.busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
