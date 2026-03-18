import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/shared_prefs.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/theme_provider.dart';
import 'account_info_screen.dart';
import 'change_password_screen.dart';
import 'help_screen.dart';
import '../orders/order_list_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToOrders;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    this.onNavigateToOrders,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    });
  }

  Widget _buildProfileAvatar(String? avatarUrl, String? fullName) {
    final hasUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    if (hasUrl) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              (fullName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        (fullName ?? 'U')[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;

    final userFullName = profile?.fullName ?? SharedPrefs.getUserFullName();
    final userEmail = profile?.email ?? SharedPrefs.getUserEmail();
    final userAvatar = profile?.fullAvatarUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileControllerProvider.notifier).fetchProfile();
        },
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
                      _buildProfileAvatar(userAvatar, userFullName),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userFullName ?? 'Người dùng',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail ?? SharedPrefs.getUserName() ?? '',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                      title: const Text('Thông tin tài khoản'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                      title: const Text('Đổi mật khẩu'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.history, color: AppTheme.primaryColor),
                      title: const Text('Lịch sử đơn hàng'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.onNavigateToOrders != null) {
                          widget.onNavigateToOrders!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderListScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
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
                      leading: const Icon(Icons.help_outline,
                          color: AppTheme.primaryColor),
                      title: const Text('Trợ giúp'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline,
                          color: AppTheme.primaryColor),
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
