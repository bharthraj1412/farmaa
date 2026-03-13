import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/discovery_service.dart';

/// Singleton Dio client with JWT auth and error handling interceptors.
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  static const _storage = FlutterSecureStorage();
  late final Dio dio = _createDio();

  /// Global flag to avoid repeated 3s timeouts across different services
  bool _isBackendDown = false;
  DateTime? _lastFailureTime;

  Future<void> discover() async {
    if (AppConstants.isProduction) return; // Skip discovery in production
    final found = await DiscoveryService.instance.discoverBackend();
    if (found != null && found != AppConstants.baseUrl) {
      AppConstants.baseUrl = found;
      dio.options.baseUrl = found;
      await _storage.write(key: AppConstants.baseUrlKey, value: found);
      resetCircuitBreaker();
      debugPrint('[ApiClient] Auto-discovered backend at: $found');
    }
  }

  Future<void> loadPersistedBaseUrl() async {
    // In production, always use the hardcoded proUrl unless manually overridden
    if (AppConstants.isProduction) {
      AppConstants.baseUrl = AppConstants.prodUrl;
      try {
        dio.options.baseUrl = AppConstants.prodUrl;
      } catch (_) {}
      return;
    }

    final saved = await _storage.read(key: AppConstants.baseUrlKey);
    if (saved != null && saved.startsWith('http')) {
      AppConstants.baseUrl = saved;
      // If dio is already initialized, update its baseUrl
      try {
        dio.options.baseUrl = saved;
      } catch (_) {
        // dio might not be initialized yet, which is fine
      }
      debugPrint('[ApiClient] Loaded persisted base URL: $saved');
    }
  }

  void resetCircuitBreaker() {
    _isBackendDown = false;
    _lastFailureTime = null;
    debugPrint('[ApiClient] Circuit breaker reset manually.');
  }

  Dio _createDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': '1.0.0',
        },
      ),
    );

    d.interceptors.addAll([
      _CircuitBreakerInterceptor(this),
      _AuthInterceptor(_storage),
      _ErrorInterceptor(),
      if (!AppConstants.isProduction)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
        ),
    ]);

    return d;
  }
}

// ── Auth Interceptor ─────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.jwtKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired — clear storage and signal auth failure
      await _storage.delete(key: AppConstants.jwtKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);
      // Re-throw so the app can navigate to login
      handler.next(err);
    } else {
      handler.next(err);
    }
  }
}

// ── Error Interceptor ────────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        message =
            'Cannot connect to server. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        final body = err.response?.data;
        if (body is Map && body.containsKey('detail')) {
          message = body['detail'].toString();
        } else {
          message = _statusMessage(status);
        }
        break;
      default:
        message = 'An unexpected error occurred.';
    }

    String help = "";
    if (!AppConstants.isProduction &&
        !kIsWeb &&
        err.type == DioExceptionType.connectionError) {
      help =
          "\n\nTip: On a real phone, ensure your PC server is running and bound to 0.0.0.0, not localhost.";
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        message: "$message$help",
        type: err.type,
        error: err.error,
      ),
    );
  }

  String _statusMessage(int? status) {
    switch (status) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (code: $status).';
    }
  }
}

// ── Circuit Breaker Interceptor ──────────────────────────────────────────────

class _CircuitBreakerInterceptor extends Interceptor {
  final ApiClient _client;
  _CircuitBreakerInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_client._isBackendDown && _client._lastFailureTime != null) {
      final diff = DateTime.now().difference(_client._lastFailureTime!);
      if (diff.inSeconds < (AppConstants.isProduction ? 5 : 30)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Waiting for server to recover...',
            type: DioExceptionType.connectionError,
          ),
        );
      } else {
        _client._isBackendDown = false;
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError) {
      _client._isBackendDown = true;
      _client._lastFailureTime = DateTime.now();

      // ── AUTO-RETRY LOGIC (Development Only) ─────────────────
      if (!AppConstants.isProduction) {
        debugPrint(
            '[ApiClient] Connection failed. Attempting auto-discovery retry...');
        final found = await DiscoveryService.instance.discoverBackend();

        if (found != null && found != AppConstants.baseUrl) {
          AppConstants.baseUrl = found;
          _client.dio.options.baseUrl = found;
          await ApiClient._storage
              .write(key: AppConstants.baseUrlKey, value: found);
          _client.resetCircuitBreaker();

          // Clone the request with the new base URL
          final opts = err.requestOptions;
          try {
            final response = await _client.dio.request(
              opts.path,
              data: opts.data,
              queryParameters: opts.queryParameters,
              options: Options(
                method: opts.method,
                headers: opts.headers,
              ),
            );
            return handler.resolve(response);
          } catch (retryErr) {
            if (retryErr is DioException) {
              return handler.next(retryErr);
            }
          }
        }
      }
    }
    handler.next(err);
  }
}
