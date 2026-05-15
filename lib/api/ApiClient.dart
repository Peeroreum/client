import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
import 'package:peeroreum_client/api/PeeroreumApi.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const _storage = FlutterSecureStorage();
  late final Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: API.hostConnect,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.headers.containsKey('Authorization')) {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: 'refreshToken');
          if (refreshToken == null) {
            _redirectToLogin();
            return handler.next(error);
          }
          try {
            // 토큰 재발급
            final refreshDio = Dio(BaseOptions(baseUrl: API.hostConnect));
            final response = await refreshDio.post(
              '/token/reissue',
              data: {'refreshToken': refreshToken},
            );
            final data = response.data['data'];
            await _storage.write(key: 'accessToken', value: data['accessToken']);
            await _storage.write(key: 'refreshToken', value: data['refreshToken']);

            // 요청 재시도
            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer ${data['accessToken']}';
            final retryResponse = await _dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            _redirectToLogin();
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  void _redirectToLogin() async {
    await _storage.deleteAll();
    getx.Get.offAllNamed('/login');
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data, Options? options}) {
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Options? options}) {
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path,
      {dynamic data, Options? options}) {
    return _dio.patch(path, data: data, options: options);
  }

  // 이미지 업로드용
  Future<Response> postForm(String path, FormData formData) {
    return _dio.post(path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'));
  }

  Future<Response> putForm(String path, FormData formData) {
    return _dio.put(path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'));
  }
}
