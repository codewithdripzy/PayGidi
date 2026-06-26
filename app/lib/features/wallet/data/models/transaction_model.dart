class Transaction {
  final String id;
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  final String status;
  final String reference;
  final String type;
  final String recipientOrSender;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.status = "Successful",
    required this.reference,
    required this.type,
    required this.recipientOrSender,
  });

  static String _extractSender(String remarks) {
    // "Transfer from NAME to ... | [CID]" or "Transfer from NAME to sandbox | [CID]"
    final fromMatch = RegExp(r'from\s+(.+?)\s+to\b', caseSensitive: false).firstMatch(remarks);
    if (fromMatch != null) return fromMatch.group(1)!.trim();
    final parts = remarks.split(' | ');
    return parts.isNotEmpty ? parts[0].trim() : remarks;
  }

  static String _formatAmount(String amount, bool isCredit) {
    final parsed = double.tryParse(amount) ?? 0;
    final formatted = parsed.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${isCredit ? '+' : '-'}₦${buf.toString()}.${parts[1]}';
  }

  static String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}${_daySuffix(dt.day)}, ${dt.year} • $hour:$min $ampm';
    } catch (_) {
      return raw;
    }
  }

  static String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final ref = json['transaction_reference']?.toString() ?? '';
    final remarks = json['remarks']?.toString() ?? '';
    final principalAmount = json['principal_amount']?.toString() ?? '0';
    final transactionDate = json['transaction_date']?.toString() ?? '';
    final indicator = json['transaction_indicator']?.toString() ?? '';
    final isCredit = indicator == 'C';

    return Transaction(
      id: ref,
      title: remarks.isNotEmpty ? remarks : 'Deposit',
      date: _formatDate(transactionDate),
      amount: _formatAmount(principalAmount, isCredit),
      isCredit: isCredit,
      status: 'Successful',
      reference: ref,
      type: 'Deposit',
      recipientOrSender: _extractSender(remarks),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'isCredit': isCredit,
      'status': status,
      'reference': reference,
      'type': type,
      'recipientOrSender': recipientOrSender,
    };
  }

  static List<Transaction> dummyTransactions = [
    Transaction(
      id: "1",
      title: "Payment - Arike Pre-Order",
      date: "May 14th, 2026 • 10:30 PM",
      amount: "-₦50,000",
      isCredit: false,
      reference: "PG-92837465",
      type: "Payment",
      recipientOrSender: "Arike Clothings",
    ),
    Transaction(
      id: "2",
      title: "Deposit - Opay",
      date: "May 14th, 2026 • 10:30 PM",
      amount: "+₦200,000",
      isCredit: true,
      reference: "PG-12345678",
      type: "Deposit",
      recipientOrSender: "Opay Digital",
    ),
    Transaction(
      id: "3",
      title: "Transfer - To John Doe",
      date: "May 13th, 2026 • 02:15 PM",
      amount: "-₦15,000",
      isCredit: false,
      reference: "PG-84726351",
      type: "Transfer",
      recipientOrSender: "John Doe",
    ),
  ];
}
