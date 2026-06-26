import 'package:app/core/network/api_response.dart';
import 'package:app/features/wallet/data/models/bank_model.dart';
import 'package:app/features/wallet/data/models/transaction_model.dart';
import 'package:app/features/wallet/data/models/virtual_account_model.dart';
import 'package:app/features/wallet/data/models/wallet_balance_model.dart';
import 'package:app/features/wallet/data/repositories/transaction_repository.dart';
import 'package:app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  WalletProvider(this._walletRepository, this._transactionRepository);

  WalletBalance? _balance;
  WalletBalance? get balance => _balance;

  VirtualAccount? _virtualAccount;
  VirtualAccount? get virtualAccount => _virtualAccount;

  List<Bank> _banks = [];
  List<Bank> get banks => _banks;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  bool _isLoadingBalance = false;
  bool get isLoadingBalance => _isLoadingBalance;

  bool _isLoadingVirtualAccount = false;
  bool get isLoadingVirtualAccount => _isLoadingVirtualAccount;

  bool _isLoadingBanks = false;
  bool get isLoadingBanks => _isLoadingBanks;

  bool _isLoadingTransactions = false;
  bool get isLoadingTransactions => _isLoadingTransactions;

  String? _error;
  String? get error => _error;

  Future<void> fetchBalance() async {
    _isLoadingBalance = true;
    _error = null;
    notifyListeners();

    final ApiResponse<WalletBalance> response =
        await _walletRepository.getBalance();

    if (response.data != null) {
      _balance = response.data;
    } else {
      _error = response.error ?? 'Failed to fetch balance';
    }

    _isLoadingBalance = false;
    notifyListeners();
  }

  Future<void> fetchVirtualAccount() async {
    _isLoadingVirtualAccount = true;
    _error = null;
    notifyListeners();

    final ApiResponse<VirtualAccount> response =
        await _walletRepository.getVirtualAccount();

    if (response.data != null) {
      _virtualAccount = response.data;
    } else {
      _error = response.error ?? 'Failed to fetch virtual account';
    }

    _isLoadingVirtualAccount = false;
    notifyListeners();
  }

  Future<void> fetchBanks() async {
    _isLoadingBanks = true;
    _error = null;
    notifyListeners();

    final ApiResponse<List<Bank>> response = await _walletRepository.getBanks();

    if (response.data != null) {
      _banks = response.data!;
    } else {
      _error = response.error ?? 'Failed to fetch banks';
    }

    _isLoadingBanks = false;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _isLoadingTransactions = true;
    _error = null;
    notifyListeners();

    final ApiResponse<List<Transaction>> response =
        await _transactionRepository.getTransactions();

    if (response.data != null) {
      _transactions = response.data!;
    } else {
      _error = response.error ?? 'Failed to fetch transactions';
    }

    _isLoadingTransactions = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(),
      fetchVirtualAccount(),
    ]);
  }

  bool _isSimulatingDeposit = false;
  bool get isSimulatingDeposit => _isSimulatingDeposit;

  Future<ApiResponse<Map<String, dynamic>>> simulateDeposit({
    required String accountNumber,
    required String amount,
  }) async {
    _isSimulatingDeposit = true;
    _error = null;
    notifyListeners();

    final response = await _walletRepository.simulateDeposit(
      accountNumber: accountNumber,
      amount: amount,
    );

    _isSimulatingDeposit = false;
    if (response.data != null) {
      notifyListeners();
    } else {
      _error = response.error;
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> lookupAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    return await _walletRepository.lookupAccount(
      accountNumber: accountNumber,
      bankCode: bankCode,
    );
  }

  Future<ApiResponse<void>> transfer({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String pin,
    String? narration,
  }) async {
    return await _walletRepository.transfer(
      amount: amount,
      accountNumber: accountNumber,
      bankCode: bankCode,
      pin: pin,
      narration: narration,
    );
  }
}
