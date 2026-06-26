import 'package:app/core/network/api_response.dart';
import 'package:app/features/finance/data/models/savings_goal_model.dart';
import 'package:app/features/finance/data/models/thrift_model.dart';
import 'package:app/features/finance/data/repositories/finance_repository.dart';
import 'package:app/features/wallet/data/models/wallet_balance_model.dart';
import 'package:flutter/material.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceRepository _repository;

  FinanceProvider(this._repository);

  WalletBalance? _balance;
  WalletBalance? get balance => _balance;

  List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  List<Thrift> _thrifts = [];
  List<Thrift> get thrifts => _thrifts;

  bool _isLoadingSummary = false;
  bool get isLoadingSummary => _isLoadingSummary;

  bool _isLoadingSavingsGoals = false;
  bool get isLoadingSavingsGoals => _isLoadingSavingsGoals;

  bool _isLoadingThrifts = false;
  bool get isLoadingThrifts => _isLoadingThrifts;

  String? _error;
  String? get error => _error;

  Future<void> fetchSummary() async {
    _isLoadingSummary = true;
    _error = null;
    notifyListeners();

    final ApiResponse<WalletBalance> response = await _repository.getSummary();

    if (response.data != null) {
      _balance = response.data;
    } else {
      _error = response.error ?? 'Failed to fetch summary';
    }

    _isLoadingSummary = false;
    notifyListeners();
  }

  Future<void> fetchSavingsGoals() async {
    _isLoadingSavingsGoals = true;
    _error = null;
    notifyListeners();

    final ApiResponse<List<SavingsGoal>> response =
        await _repository.getSavingsGoals();

    if (response.data != null) {
      _savingsGoals = response.data!;
    } else {
      _error = response.error ?? 'Failed to fetch savings goals';
    }

    _isLoadingSavingsGoals = false;
    notifyListeners();
  }

  Future<void> fetchThrifts() async {
    _isLoadingThrifts = true;
    _error = null;
    notifyListeners();

    final ApiResponse<List<Thrift>> response =
        await _repository.getThrifts();

    if (response.data != null) {
      _thrifts = response.data!;
    } else {
      _error = response.error ?? 'Failed to fetch thrifts';
    }

    _isLoadingThrifts = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummary(),
      fetchSavingsGoals(),
      fetchThrifts(),
    ]);
  }
}
