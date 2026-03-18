import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shared_prefs.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileResponse? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(authProvider.notifier).getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryColor,
                              backgroundImage: _profile?.avatar != null
                                  ? NetworkImage(_profile!.avatar!)
                                  : null,
                              child: _profile?.avatar == null
                                  ? Text(
                                      (_profile?.fullName ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile?.fullName ?? 'Người dùng',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profile?.email ?? '',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditProfileDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          if (_profile?.phone != null && _profile!.phone!.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
                              title: const Text('Số điện thoại'),
                              subtitle: Text(_profile!.phone!),
                            ),
                          if (_profile?.address != null && _profile!.address!.isNotEmpty) ...[
                            if (_profile?.phone != null && _profile!.phone!.isNotEmpty)
                              const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                              title: const Text('Địa chỉ'),
                              subtitle: Text(_profile!.address!),
                            ),
                          ],
                          if (_profile?.dateOfBirth != null) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.cake, color: AppTheme.primaryColor),
                              title: const Text('Ngày sinh'),
                              subtitle: Text(
                                '${_profile!.dateOfBirth!.day}/${_profile!.dateOfBirth!.month}/${_profile!.dateOfBirth!.year}',
                              ),
                            ),
                          ],
                          if (_profile?.gender != null && _profile!.gender!.isNotEmpty) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                              title: const Text('Giới tính'),
                              subtitle: Text(_profile!.gender!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                            title: const Text('Đổi mật khẩu'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showChangePasswordDialog(context),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              color: AppTheme.primaryColor,
                            ),
                            title: const Text('Chế độ tối'),
                            trailing: Switch(
                              value: themeState.isDarkMode,
                              onChanged: (_) =>
                                  ref.read(themeControllerProvider.notifier).toggleTheme(),
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                            title: const Text('Về ứng dụng'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showAboutDialog(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Đăng xuất'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final fullNameController = TextEditingController(text: _profile?.fullName);
    final phoneController = TextEditingController(text: _profile?.phone);
    final addressController = TextEditingController(text: _profile?.address);
    String? selectedGender = _profile?.gender;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Giới tính',
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (value) => selectedGender = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(authProvider.notifier).updateProfile(
                fullName: fullNameController.text.trim(),
                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                gender: selectedGender,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  _loadProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật hồ sơ thành công'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ref.read(authProvider).error ?? 'Cập nhật thất bại'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: Icon(Icons.lock_open),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu không khớp'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              final success = await ref.read(authProvider.notifier).changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đổi mật khẩu thành công'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ref.read(authProvider).error ?? 'Đổi mật khẩu thất bại'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Ecoka'),
          ],
        ),
        content: const Text('Ứng dụng mua sắm thủ công mỹ nghệ Lục Bình.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
