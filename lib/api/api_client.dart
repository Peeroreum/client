import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
import 'package:peeroreum_client/data/visit_count.dart';
import 'package:peeroreum_client/api/peeroreum_api.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const _storage = FlutterSecureStorage();

  /// 백그라운드 요청용: 네트워크 오류·5xx여도 공통 토스트를 띄우지 않음
  static Options get silent => Options(extra: {'silent': true});

  /// 실패 응답(ResponseDto.fail)의 서버 메시지, 없으면 fallback
  static String errorMessage(Response? response,
      {String fallback = '잠시 후에 다시 시도해 주세요.'}) {
    final body = response?.data;
    if (body is Map && body['status'] == 'fail' && body['data'] is String) {
      return body['data'] as String;
    }
    return fallback;
  }
  late final Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: API.hostConnect,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // 서버가 구버전 앱과 구분해 처리하도록 전달 (2: 같이방 비밀번호 서버 검증)
      headers: {'X-Client-Version': '2'},
      // 4xx는 화면에서 statusCode로 분기하므로 예외로 던지지 않음
      // 401은 토큰 재발급을 위해 onError로 보냄, 5xx·네트워크 오류는 예외
      validateStatus: (status) =>
          status != null && status < 500 && status != 401,
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
          // 로그인·회원가입 등 인증 요청의 401은 재발급 대상이 아니므로 응답 그대로 전달
          if (_isAuthRequest(error.requestOptions.path)) {
            return handler.resolve(error.response!);
          }
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
        _showNetworkErrorToast(error);
        return handler.next(error);
      },
    ));
  }

  // 네트워크 끊김·타임아웃·5xx는 화면마다 처리하지 않고 여기서 한 번만 안내
  void _showNetworkErrorToast(DioException error) {
    if (error.requestOptions.extra['silent'] == true) return;
    final status = error.response?.statusCode;
    final isServerError = status != null && status >= 500;
    final isNetworkError = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
    if (!isServerError && !isNetworkError) return;
    final context = getx.Get.overlayContext ?? getx.Get.context;
    if (context == null || !context.mounted) return;
    PeeroreumToast.show(
      context,
      isNetworkError ? '네트워크 연결을 확인해 주세요.' : '잠시 후에 다시 시도해 주세요.',
      isError: true,
    );
  }

  static const _authPaths = [
    '/login',
    '/socialLogin',
    '/signup',
    '/token/reissue',
    '/member/password',
    '/app/version',
  ];

  bool _isAuthRequest(String path) =>
      _authPaths.any((p) => path.startsWith(p));

  Future<void> _redirectToLogin() async {
    await _storage.deleteAll();
    await VisitCount.clear();
    getx.Get.offAllNamed('/signIn/email');
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
