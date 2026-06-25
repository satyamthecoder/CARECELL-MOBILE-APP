import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class PatientRepository {
  final _client = ApiClient().dio;

  Future<ApiResult<Map<String, dynamic>>> getDashboard() async {
    try { final r = await _client.get(AppEndpoints.patientDash); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> getHealthProfile() async {
    try { final r = await _client.get(AppEndpoints.healthProfile); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> updateHealthProfile(Map<String, dynamic> data) async {
    try { final r = await _client.put(AppEndpoints.healthProfile, data: data); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> getHealthCard() async {
    try { final r = await _client.get(AppEndpoints.healthCard); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> triggerSos(double lat, double lng) async {
    try { final r = await _client.post('${AppEndpoints.sos}?lat=$lat&lng=$lng'); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getBloodRequests() async {
    try { final r = await _client.get(AppEndpoints.bloodRequests); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> createBloodRequest(Map<String, dynamic> data) async {
    try { final r = await _client.post(AppEndpoints.bloodRequests, data: data); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getRecords({int page = 0}) async {
    try { final r = await _client.get('${AppEndpoints.patientRecords}?page=$page&size=20'); return ApiResult.success(r.data['data']['content']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getTreatments() async {
    try { final r = await _client.get(AppEndpoints.treatments); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> addTreatment(Map<String, dynamic> data) async {
    try { final r = await _client.post(AppEndpoints.treatments, data: data); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getHospitals(double lat, double lng, {String? keyword}) async {
    try {
      final kw = keyword != null ? '&keyword=$keyword' : '';
      final r = await _client.get('${AppEndpoints.hospitals}?lat=$lat&lng=$lng$kw');
      return ApiResult.success(r.data['data']['results'] ?? []);
    } on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<List>> getSchemes({String? state}) async {
    try {
      final q = state != null ? '?state=$state' : '';
      final r = await _client.get('${AppEndpoints.schemes}$q');
      return ApiResult.success(r.data['data']);
    } on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  Future<ApiResult<Map<String, dynamic>>> aiChat(String message) async {
    try { final r = await _client.post(AppEndpoints.aiChat, data: {'message': message}); return ApiResult.success(r.data['data']); }
    on DioException catch (e) { return ApiResult.failure(_err(e)); }
  }

  String _err(DioException e) => e.response?.data?['message']?.toString() ?? 'Something went wrong';
}
