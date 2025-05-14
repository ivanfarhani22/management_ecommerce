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
      // Fetch from API
      final apiFinances = await financeApi.getAllFinances();
      
      // Cache finances in local database
      for (var finance in apiFinances) {
        await databaseHelper.insert('financial_reports', finance.toJson());
      }
      
      return apiFinances;
    } catch (e) {
      // Fallback to local database
      final localFinances = await databaseHelper.query('financial_reports');
      return localFinances.map((json) => FinancialReport.fromJson(json)).toList();
    }
  }

  Future<FinancialReport> getFinanceById(int financeId) async {
    try {
      // Try to fetch from API first
      return await financeApi.getFinanceById(financeId);
    } catch (e) {
      // Fallback to local database
      final localFinance = await databaseHelper.query(
        'financial_reports', 
        where: 'id = ?', 
        whereArgs: [financeId]
      );
      
      if (localFinance.isNotEmpty) {
        return FinancialReport.fromJson(localFinance.first);
      }
      
      rethrow;
    }
  }

  Future<FinancialReport> createFinance(FinancialReport finance) async {
    try {
      final createdFinance = await financeApi.createFinance(finance);
      
      // Cache in local database
      await databaseHelper.insert('financial_reports', createdFinance.toJson());
      
      return createdFinance;
    } catch (e) {
      rethrow;
    }
  }

  Future<FinancialReport> updateFinance(FinancialReport finance) async {
    try {
      final updatedFinance = await financeApi.updateFinance(finance);
      
      // Update in local database
      await databaseHelper.update(
        'financial_reports', 
        updatedFinance.toJson(),
        where: 'id = ?',
        whereArgs: [updatedFinance.id]
      );
      
      return updatedFinance;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFinance(int financeId) async {
    try {
      await financeApi.deleteFinance(financeId);
      
      // Remove from local database
      await databaseHelper.delete(
        'financial_reports', 
        where: 'id = ?', 
        whereArgs: [financeId]
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FinancialReport>> getFinancesByCategory(String category) async {
    try {
      return await financeApi.getFinancesByCategory(category);
    } catch (e) {
      // Fallback to local database query
      final localFinances = await databaseHelper.query(
        'financial_reports', 
        where: 'category = ?', 
        whereArgs: [category]
      );
      return localFinances.map((json) => FinancialReport.fromJson(json)).toList();
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      return await financeApi.getFinanceSummary();
    } catch (e) {
      // If API fails, you might want to compute summary from local data
      // This is a placeholder and would need to be implemented based on your specific requirements
      rethrow;
    }
  }
}