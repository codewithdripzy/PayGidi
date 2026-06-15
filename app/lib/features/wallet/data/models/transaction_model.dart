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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['description'] ?? '',
      date: json['date'] ?? json['createdAt'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      isCredit: json['type'] == 'CREDIT' || json['isCredit'] == true,
      status: json['status'] ?? 'Successful',
      reference: json['reference'] ?? '',
      type: json['type'] ?? '',
      recipientOrSender: json['recipientOrSender'] ?? json['counterpartyName'] ?? '',
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
