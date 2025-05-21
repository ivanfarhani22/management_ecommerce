import '../api/finance_api.dart';
import '../local/database_helper.dart';
import '../models/financial_report.dart';

class FinanceRepository {
  final FinanceApi financeApi;
  final DatabaseHelper databaseHelper;

  FinanceRepository({
    required this.financeApi,
    required this.databaseHelper,
  });

  Future<List<FinancialReport>> getAllFinances() async {
    try {
      final List<Map<String, dynamic>> apiFinancesData =
          await financeApi.getAllFinances();

      final List<FinancialReport> apiFinances = apiFinancesData
          .map((data) => FinancialReport.fromJson(data))
          .toList();

      for (var finance in apiFinances) {
        await databaseHelper.insert('financial_reports', finance.toJson());
      }

      return apiFinances;
    } catch (e) {
      final localFinances = await databaseHelper.query('financial_reports');
      return localFinances.map((json) => FinancialReport.fromJson(json)).toList();
    }
  }

  Future<FinancialReport> getFinanceById(int financeId) async {
    try {
      final Map<String, dynamic> financeData =
          await financeApi.getFinanceById(financeId);

      return FinancialReport.fromJson(financeData);
    } catch (e) {
      final localFinance = await databaseHelper.query(
        'financial_reports',
        where: 'id = ?',
        whereArgs: [financeId],
      );

      if (localFinance.isNotEmpty) {
        return FinancialReport.fromJson(localFinance.first);
      }

      rethrow;
    }
  }

  Future<FinancialReport> createFinance(FinancialReport finance) async {
    try {
      final Map<String, dynamic> createdFinanceData =
          await financeApi.createFinance(finance.toJson());

      final createdFinance = FinancialReport.fromJson(createdFinanceData);

      await databaseHelper.insert(
          'financial_reports', createdFinance.toJson());

      return createdFinance;
    } catch (e) {
      rethrow;
    }
  }

  Future<FinancialReport> updateFinance(FinancialReport finance) async {
    try {
      final Map<String, dynamic> updatedFinanceData =
          await financeApi.updateFinance(finance.toJson());

      final updatedFinance = FinancialReport.fromJson(updatedFinanceData);

      await databaseHelper.update(
        'financial_reports',
        updatedFinance.toJson(),
        where: 'id = ?',
        whereArgs: [updatedFinance.id],
      );

      return updatedFinance;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFinance(int financeId) async {
    try {
      await financeApi.deleteFinance(financeId);

      await databaseHelper.delete(
        'financial_reports',
        where: 'id = ?',
        whereArgs: [financeId],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FinancialReport>> getFinancesByCategory(String category) async {
    try {
      final List<Map<String, dynamic>> financeDataList =
          await financeApi.getFinancesByCategory(category);

      return financeDataList
          .map((data) => FinancialReport.fromJson(data))
          .toList();
    } catch (e) {
      final localFinances = await databaseHelper.query(
        'financial_reports',
        where: 'category = ?',
        whereArgs: [category],
      );

      return localFinances
          .map((json) => FinancialReport.fromJson(json))
          .toList();
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      return await financeApi.getFinanceSummary();
    } catch (e) {
      // Implement summary calculation from local if needed
      rethrow;
    }
  }
}
