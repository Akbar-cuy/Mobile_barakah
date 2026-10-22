// M17 Profil (FR-PRO-04)
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
  ConsumerState<ChangePasswordScreen> createState() => _State();
}

class _State extends ConsumerState<ChangePasswordScreen> {
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
    if (ok && mounted) {
      showAppSnackBar(context, 'Kata sandi diganti');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Kata Sandi')),
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
                  validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi lama wajib diisi.' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _new,
                  hint: 'Kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  validator: (v) {
                    final base = Validators.password(v);
                    if (base != null) return base;
                    return v == _old.text ? 'Kata sandi baru harus berbeda dari yang lama.' : null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirm,
                  hint: 'Ulangi kata sandi baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  validator: (v) => Validators.confirmPassword(v, _new.text),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Ganti kata sandi', loading: action.busy, onPressed: _submit),
        ],
      ),
    );
  }
}
