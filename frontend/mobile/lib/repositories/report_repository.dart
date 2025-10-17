// lib/repositories/report_repository.dart
import '../models/report_models.dart';
import '../services/api_client.dart';

class ReportRepository {
  final ApiClient _apiClient;

  ReportRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Get report by reseller ID
  Future<ReportResponse> getReport(int resellerId) async {
    try {
      final response = await _apiClient.get('/reports/$resellerId');
      return ReportResponse.fromJson(response);
    } catch (e) {
      if (e is ApiException) {
        throw e;
      }
      throw ApiException('Gagal mengambil data laporan: ${e.toString()}');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
