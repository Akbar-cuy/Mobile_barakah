import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../../shared/widgets/tonal_button.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/auth_hero.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _biometricReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(authFormProvider.notifier).reset();
      final ready = await ref.read(sessionServiceProvider).canBiometricLogin();
      if (mounted) setState(() => _biometricReady = ready);
    });
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authFormProvider.notifier)
        .login(_identifier.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authFormProvider);
    final expired = ref.watch(sessionProvider).expired;
    final theme = Theme.of(context);
    final heroHeight = MediaQuery.sizeOf(context).width * 230 / 400;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const AuthHero(),
            Padding(
              padding: EdgeInsets.only(top: heroHeight - 28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.extra + 2),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Masuk untuk Mulai',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text(
                        'Ibadah Lebih Tenang',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 20),
                      if (expired && form.failure == null) ...[
                        const StatusBanner(
                          message: 'Sesi berakhir. Silakan masuk kembali.',
                          kind: BannerKind.warning,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (form.failure != null) ...[
                        StatusBanner(
                          message: form.failure!.message,
                          kind: BannerKind.error,
                        ),
                        const SizedBox(height: 12),
                      ],
                      AppTextField(
                        controller: _identifier,
                        hint: 'Email atau nama pengguna',
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: (v) =>
                            Validators.required(v, field: 'Email atau nama pengguna'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _password,
                        hint: 'Kata sandi',
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        validator: (v) => Validators.required(v, field: 'Kata sandi'),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Masuk',
                        loading: form.isLoading,
                        onPressed: _submit,
                      ),
                      if (_biometricReady) ...[
                        const SizedBox(height: 16),
                        TonalButton(
                          label: 'Sidik jari atau wajah',
                          icon: Icons.fingerprint,
                          onPressed: form.isLoading
                              ? null
                              : () => ref
                                  .read(authFormProvider.notifier)
                                  .loginWithBiometric(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun?', style: theme.textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.go(RouteNames.register),
                            child: const Text('Daftar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
