// M17 Profil (FR-PRO-02, FR-PRO-03). Ubah nama, nama pengguna, dan foto.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/providers/session_provider.dart';
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
  late final TextEditingController _avatar;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    _name = TextEditingController(text: user?.name ?? '');
    _username = TextEditingController(text: user?.username ?? '');
    _avatar = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _avatar.dispose();
    super.dispose();
  }

  String? _avatarRule(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Tautan foto harus diawali http atau https.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final user = await ref.read(profileRepositoryProvider).update(
            name: _name.text,
            username: _username.text,
            avatarUrl: _avatar.text,
          );
      ref.read(sessionProvider.notifier).updateUser(user);
      if (!mounted) return;
      showAppSnackBar(context, 'Profil diperbarui.');
      context.pop();
    } on ApiException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Center(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _avatar,
              builder: (_, value, __) =>
                  AvatarPicker(initials: user?.initials ?? '', url: value.text),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  hint: 'Nama lengkap',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Nama lengkap'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _username,
                  hint: 'Nama pengguna',
                  icon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  validator: Validators.username,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _avatar,
                  hint: 'Tautan foto profil (opsional)',
                  icon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  validator: _avatarRule,
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
