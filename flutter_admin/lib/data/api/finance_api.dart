import '../models/financial_report.dart';
import 'api_client.dart';

class FinanceApi {
  final ApiClient apiClient;
  FinanceApi(this.apiClient);

  Future<List<FinancialReport>> getAllFinances() async {
    try {
      final response = await apiClient.get('/v1/finances');
      return (response as List)
        .map((financeJson) => FinancialReport.fromJson(financeJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<FinancialReport> getFinanceById(int financeId) async {
    try {
      final response = await apiClient.get('/v1/finances/$financeId');
      return FinancialReport.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FinancialReport> createFinance(FinancialReport finance) async {
    try {
      final response = await apiClient.post('/v1/finances', body: finance.toJson());
      return FinancialReport.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FinancialReport> updateFinance(FinancialReport finance) async {
    try {
      final response = await apiClient.put('/v1/finances/${finance.id}', body: finance.toJson());
      return FinancialReport.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFinance(int financeId) async {
    try {
      await apiClient.delete('/v1/finances/$financeId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FinancialReport>> getFinancesByCategory(String category) async {
    try {
      final response = await apiClient.get('/v1/finances/category/$category');
      return (response as List)
        .map((financeJson) => FinancialReport.fromJson(financeJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      final response = await apiClient.get('/v1/finances/summary');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}