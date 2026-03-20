import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/debug/agent_debug_log.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/shared_prefs.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Một số endpoint công khai (vd: GET danh sách đánh giá) không cần token
          final skipAuth = options.extra?['skipAuth'] == true;
          if (!skipAuth) {
            final token = SharedPrefs.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Chỉ logout khi 401 trên request có gửi token (tránh logout do endpoint công khai)
          final skipAuth = error.requestOptions.extra?['skipAuth'] == true;
          if (!skipAuth && error.response?.statusCode == 401) {
            await SharedPrefs.logout();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = true,
  }) async {
    final opts = options ?? Options();
    opts.extra ??= {};
    if (!requireAuth) opts.extra!['skipAuth'] = true;
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: opts,
      );
    } catch (e) {
      // #region agent log
      if (e is DioException) {
        final raw = e.response?.data?.toString() ?? '';
        agentDebugLog('api_client.dart:get', 'dio_get_failed', {
          'path': path,
          'requireAuth': requireAuth,
          'skipAuth': opts.extra?['skipAuth'] == true,
          'statusCode': e.response?.statusCode,
          'method': e.requestOptions.method,
          'fullUri': e.requestOptions.uri.toString(),
          'dioType': e.type.name,
          'bodySnippet': raw.length > 400 ? raw.substring(0, 400) : raw,
        }, hypothesisId: 'H1');
      }
      // #endregion
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requireAuth = true,
  }) async {
    try {
      final requestOptions = options ?? Options();

      if (requireAuth) {
        final token = SharedPrefs.getToken();
        if (token != null && token.isNotEmpty) {
          requestOptions.headers ??= {};
          requestOptions.headers!['Authorization'] = 'Bearer $token';
        }
      }

      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
