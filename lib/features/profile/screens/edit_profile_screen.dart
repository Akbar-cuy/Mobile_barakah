// M17 Profil (FR-PRO-02, FR-PRO-03)
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
import '../widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    _name = TextEditingController(text: u?.name ?? '');
    _username = TextEditingController(text: u?.username ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(profileControllerProvider.notifier).clearError(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(profileControllerProvider.notifier).save(
          name: _name.text,
          username: _username.text,
          email: _email.text,
        );
    if (ok && mounted) {
      showAppSnackBar(context, 'Profil diperbarui');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final action = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          if (user != null)
            Center(
              child: AvatarPicker(
                user: user,
                busy: action.busy,
                onPicked: (bytes, name) async {
                  final ok = await ref.read(profileControllerProvider.notifier).setAvatar(bytes, name);
                  if (ok && mounted) showAppSnackBar(context, 'Foto diperbarui');
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (action.error != null) ...[
            StatusBanner(kind: BannerKind.error, message: action.error!),
            const SizedBox(height: AppSpacing.md),
          ],
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  hint: 'Nama lengkap',
                  icon: Icons.person_outline,
                  validator: (v) => Validators.required(v, field: 'Nama'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _username,
                  hint: 'Nama pengguna',
                  icon: Icons.alternate_email,
                  validator: Validators.username,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  onSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Simpan', loading: action.busy, onPressed: _save),
        ],
      ),
    );
  }
}
