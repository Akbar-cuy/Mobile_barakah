import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_banner.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _emailError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ref.read(authFormProvider.notifier).reset());
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _username, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _usernameError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authFormProvider.notifier);
    final ok = await controller.register(
      name: _name.text.trim(),
      email: _email.text.trim().toLowerCase(),
      username: _username.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, 'Akun dibuat. Silakan masuk.');
      context.go(RouteNames.login);
      return;
    }
    final failure = ref.read(authFormProvider).failure;
    setState(() {
      if (failure?.code == 'email_taken') _emailError = failure!.message;
      if (failure?.code == 'username_taken') _usernameError = failure!.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(authFormProvider);
    final theme = Theme.of(context);
    final fieldError = form.failure?.code == 'email_taken' ||
        form.failure?.code == 'username_taken';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Daftar dan Mulai',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                'Ibadah Bersama Barakah',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 20),
              if (form.failure != null && !fieldError) ...[
                StatusBanner(message: form.failure!.message, kind: BannerKind.error),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: _name,
                hint: 'Nama lengkap',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Nama lengkap'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _email,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _username,
                hint: 'Nama pengguna',
                icon: Icons.alternate_email,
                textInputAction: TextInputAction.next,
                errorText: _usernameError,
                onChanged: (_) {
                  if (_usernameError != null) setState(() => _usernameError = null);
                },
                validator: Validators.username,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _password,
                hint: 'Kata sandi',
                icon: Icons.lock_outline,
                obscure: true,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _confirm,
                hint: 'Ulangi kata sandi',
                icon: Icons.lock_outline,
                obscure: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.confirmPassword(v, _password.text),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 20),
                child: Text(
                  'Minimal 8 karakter, berisi huruf dan angka.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              PrimaryButton(label: 'Daftar', loading: form.isLoading, onPressed: _submit),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun?', style: theme.textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
