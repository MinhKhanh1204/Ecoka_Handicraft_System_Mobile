class ApiConstants {
  // API Gateway Base URL (Ecoka_Handicraft_System/APIGateway)
  // - APIGateway listen: http://localhost:5212 (launch profile: https also binds http)
  // - Android emulator: 10.0.2.2 = localhost của máy host
  static const String baseUrl = 'http://10.0.2.2:5212';

  // Endpoints (qua gateway)
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register-customer';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String products = '/products';
  static const String categories = '/categories';

  static const String orders = '/customer/orders';

  static const String feedbacks = '/feedbacks';
  static const String vouchers = '/vouchers';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}

