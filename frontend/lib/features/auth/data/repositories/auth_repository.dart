import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class AuthRepository {
  final _client = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<ApiResult<Map<String, dynamic>>> register(Map<String, dynamic> data) async {
    try {
      final res = await _client.post(AppEndpoints.register, data: data);
      return ApiResult.success(res.data);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<ApiResult<void>> sendOtp(String mobile) async {
    try {
      await _client.post(AppEndpoints.sendOtp, data: {'mobileNumber': mobile});
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<ApiResult<void>> verifyOtp(String mobile, String otp) async {
    try {
      await _client.post(AppEndpoints.verifyOtp, data: {'mobileNumber': mobile, 'otp': otp});
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> login(String mobile, String password) async {
    try {
      final res = await _client.post(AppEndpoints.login,
          data: {'mobileNumber': mobile, 'password': password});
      final data = res.data['data'];
      await _storage.write(key: 'access_token',  value: data['accessToken']);
      await _storage.write(key: 'refresh_token', value: data['refreshToken']);
      await _storage.write(key: 'user_role',     value: data['user']['role']);
      await _storage.write(key: 'user_id',       value: data['user']['id']);
      await _storage.write(key: 'user_name',     value: data['user']['name']);
      return ApiResult.success(data);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<ApiResult<void>> forgotPassword(String mobile) async {
    try {
      await _client.post(AppEndpoints.forgotPassword, data: {'mobileNumber': mobile});
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<ApiResult<void>> resetPassword(String mobile, String otp, String newPassword) async {
    try {
      await _client.post(AppEndpoints.resetPassword,
          data: {'mobileNumber': mobile, 'otp': otp, 'newPassword': newPassword});
      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(_extractError(e));
    }
  }

  Future<void> logout() async => _storage.deleteAll();

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getUserRole() => _storage.read(key: 'user_role');

  String _extractError(DioException e) {
    final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
    return msg?.toString() ?? 'Something went wrong. Please try again.';
  }
}
