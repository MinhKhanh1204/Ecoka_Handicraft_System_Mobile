import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ giúp'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Câu hỏi thường gặp',
            [
              _buildFaqItem(
                'Làm sao để đặt hàng?',
                'Bạn có thể chọn sản phẩm, thêm vào giỏ hàng, sau đó tiến hành thanh toán theo hướng dẫn.',
              ),
              _buildFaqItem(
                'Làm sao theo dõi đơn hàng?',
                'Vào mục "Đơn hàng" để xem trạng thái đơn hàng của bạn.',
              ),
              _buildFaqItem(
                'Có thể thay đổi thông tin tài khoản không?',
                'Có, vào mục "Thông tin tài khoản" trong phần Hồ sơ để cập nhật.',
              ),
              _buildFaqItem(
                'Làm sao liên hệ hỗ trợ?',
                'Bạn có thể gọi điện hoặc gửi email qua thông tin bên dưới.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Liên hệ hỗ trợ',
            [
              ListTile(
                leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
                title: const Text('Điện thoại'),
                subtitle: const Text('+84 123 456 789'),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                title: const Text('Email'),
                subtitle: const Text('support@ecoka.com'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                title: const Text('Địa chỉ'),
                subtitle: const Text('123 Đường Lục Bình, TP. Hồ Chí Minh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
