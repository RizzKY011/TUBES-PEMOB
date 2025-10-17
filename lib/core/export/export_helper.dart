import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:splatsplit/features/expense/models.dart';
import 'package:splatsplit/features/expense/repository.dart';
import 'package:splatsplit/features/goals/models.dart';
import 'package:splatsplit/features/goals/repository.dart';
import 'package:splatsplit/features/budget/models.dart';
import 'package:splatsplit/features/budget/repository.dart';

class ExportHelper {
  static Future<void> exportToCSV({
    required List<ExpenseItem> expenses,
    required List<GoalItem> goals,
    required List<BudgetItem> budgets,
  }) async {
    final List<List<dynamic>> csvData = <List<dynamic>>[];
    
    // Add header
    csvData.add(['MONAS Financial Report', 'Generated: ${DateTime.now().toString()}']);
    csvData.add([]);
    
    // Expenses section
    csvData.add(['EXPENSES']);
    csvData.add(['Date', 'Category', 'Amount', 'Note']);
    for (final ExpenseItem expense in expenses) {
      csvData.add([
        expense.date.toString().split(' ')[0],
        expense.category,
        expense.amount,
        expense.note ?? '',
      ]);
    }
    csvData.add([]);
    
    // Goals section
    csvData.add(['SAVINGS GOALS']);
    csvData.add(['Name', 'Target Amount', 'Saved Amount', 'Progress %', 'Target Date', 'Frequency']);
    for (final GoalItem goal in goals) {
      final double progress = (goal.savedAmount / goal.targetAmount) * 100;
      csvData.add([
        goal.name,
        goal.targetAmount,
        goal.savedAmount,
        progress.toStringAsFixed(1),
        goal.targetDate.toString().split(' ')[0],
        goal.frequency,
      ]);
    }
    csvData.add([]);
    
    // Budgets section
    csvData.add(['BUDGETS']);
    csvData.add(['Category', 'Monthly Limit']);
    for (final BudgetItem budget in budgets) {
      csvData.add([budget.category, budget.monthlyLimit]);
    }
    
    // Convert to CSV
    final String csv = const ListToCsvConverter().convert(csvData);
    
    // Share the file
    await Share.share(csv, subject: 'MONAS Financial Report');
  }

  static Future<void> exportToGoogleSheets({
    required List<ExpenseItem> expenses,
    required List<GoalItem> goals,
    required List<BudgetItem> budgets,
  }) async {
    // Create a Google Sheets URL with pre-filled data
    final String baseUrl = 'https://docs.google.com/spreadsheets/d/';
    final String templateId = '1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms';
    
    // For now, we'll open a template and let user copy data
    final Uri url = Uri.parse('$baseUrl$templateId/edit');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to CSV export
      await exportToCSV(expenses: expenses, goals: goals, budgets: budgets);
    }
  }

  static Future<void> exportToExcel({
    required List<ExpenseItem> expenses,
    required List<GoalItem> goals,
    required List<BudgetItem> budgets,
  }) async {
    // For Excel export, we'll create a more structured CSV that Excel can open
    final List<List<dynamic>> excelData = <List<dynamic>>[];
    
    // Summary sheet
    excelData.add(['MONAS Financial Summary']);
    excelData.add(['Total Expenses', expenses.fold(0.0, (sum, e) => sum + e.amount)]);
    excelData.add(['Total Goals Value', goals.fold(0.0, (sum, g) => sum + g.targetAmount)]);
    excelData.add(['Total Saved', goals.fold(0.0, (sum, g) => sum + g.savedAmount)]);
    excelData.add([]);
    
    // Monthly breakdown
    final Map<String, double> monthlyTotals = <String, double>{};
    for (final ExpenseItem expense in expenses) {
      final String month = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + expense.amount;
    }
    
    excelData.add(['MONTHLY BREAKDOWN']);
    excelData.add(['Month', 'Total Expenses']);
    for (final MapEntry<String, double> entry in monthlyTotals.entries) {
      excelData.add([entry.key, entry.value]);
    }
    
    final String csv = const ListToCsvConverter().convert(excelData);
    
    await Share.share(csv, subject: 'MONAS Excel Report');
  }
}


