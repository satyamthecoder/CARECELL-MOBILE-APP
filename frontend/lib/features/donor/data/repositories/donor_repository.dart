import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class DonorRepository {
  final _client = ApiClient().dio;

  Future<ApiResult<Map<String, dynamic>>> getDashboard() async {
    try { final r = await _client.get(AppEndpoints.donorDash); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    try { final r = await _client.get(AppEndpoints.donorProfile); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) async {
    try { final r = await _client.put(AppEndpoints.donorProfile, data: data); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> getDonorCard() async {
    try { final r = await _client.get(AppEndpoints.donorCard); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getMatchRequests() async {
    try { final r = await _client.get(AppEndpoints.matchRequests); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<void>> respondToRequest(String id, String action) async {
    try { await _client.post('${AppEndpoints.matchRequests}/$id/respond?action=$action'); return const ApiResult.success(null); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> getEligibility() async {
    try { final r = await _client.get(AppEndpoints.eligibility); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<void>> updateLocation(double lat, double lng) async {
    try { await _client.put('${AppEndpoints.location}?lat=$lat&lng=$lng'); return const ApiResult.success(null); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  String _err(DioException e) => e.response?.data?['message']?.toString() ?? 'Something went wrong';
}
