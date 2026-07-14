import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = ref.read(profileProvider);
    profile.whenData((data) {
      _nameController.text = data['first_name'] ?? '';
      _emailController.text = data['email'] ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _message = null; });

    try {
      final service = ref.read(profileServiceProvider);
      await service.updateProfile({
        'first_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
      ref.invalidate(profileProvider);
      setState(() { _message = 'Profile updated successfully!'; });
    } catch (e) {
      setState(() { _message = 'Failed to update profile'; });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: profile.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF1D8763),
                          child: Text(
                            (data['first_name'] ?? data['email'] ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(data['email'] ?? '', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        if (_message != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_message!, style: TextStyle(
                              color: _message!.contains('success') ? Colors.green : Colors.red,
                            )),
                          ),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 8),
                        Text('Member since ${data['date_joined']?.toString().substring(0, 10) ?? ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _save,
                            child: _loading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Manage Categories'),
                      subtitle: const Text('Add, edit, or remove categories'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/categories'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Log out', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        ref.read(authStateProvider.notifier).logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
