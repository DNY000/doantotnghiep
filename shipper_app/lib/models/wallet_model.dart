import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String? id;
  final String shipperId;
  final double balance;
  final List<TransactionModel> transactions;
  final BankAccount? linkedBankAccount;
  final DateTime lastUpdated;
  final String status; // active, blocked, pending
  final double monthlyIncome;
  final double weeklyIncome;

  WalletModel({
    this.id,
    required this.shipperId,
    this.balance = 0.0,
    this.transactions = const [],
    this.linkedBankAccount,
    required this.lastUpdated,
    this.status = 'active',
    this.monthlyIncome = 0.0,
    this.weeklyIncome = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'shipperId': shipperId,
      'balance': balance,
      'transactions': transactions.map((tx) => tx.toMap()).toList(),
      'linkedBankAccount': linkedBankAccount?.toMap(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'status': status,
      'monthlyIncome': monthlyIncome,
      'weeklyIncome': weeklyIncome,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map, String id) {
    return WalletModel(
      id: id,
      shipperId: map['shipperId'],
      balance: map['balance'],
      transactions:
          map['transactions'] != null
              ? List<TransactionModel>.from(
                map['transactions'].map((tx) => TransactionModel.fromMap(tx)),
              )
              : [],
      linkedBankAccount:
          map['linkedBankAccount'] != null
              ? BankAccount.fromMap(map['linkedBankAccount'])
              : null,
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      status: map['status'] ?? 'active',
      monthlyIncome: map['monthlyIncome'] ?? 0.0,
      weeklyIncome: map['weeklyIncome'] ?? 0.0,
    );
  }

  WalletModel copyWith({
    String? id,
    String? shipperId,
    double? balance,
    List<TransactionModel>? transactions,
    BankAccount? linkedBankAccount,
    DateTime? lastUpdated,
    String? status,
    double? monthlyIncome,
    double? weeklyIncome,
  }) {
    return WalletModel(
      id: id ?? this.id,
      shipperId: shipperId ?? this.shipperId,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      linkedBankAccount: linkedBankAccount ?? this.linkedBankAccount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      weeklyIncome: weeklyIncome ?? this.weeklyIncome,
    );
  }
}

class TransactionModel {
  final String id;
  final String type; // deposit, withdrawal, payment, bonus
  final double amount;
  final DateTime date;
  final String description;
  final String status; // pending, completed, failed, cancelled
  final String? orderId; // vnp_TxnRef
  final Map<String, dynamic>? metadata;
  final String? paymentMethod; // vnpay, momo, banking
  final String? paymentId; // vnp_TransactionNo
  final String? bankCode; // vnp_BankCode
  final String? cardType; // vnp_CardType (ATM, CREDIT, etc.)
  final String? responseCode; // vnp_ResponseCode
  final String? secureHash; // vnp_SecureHash

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    this.orderId,
    this.metadata,
    this.paymentMethod,
    this.paymentId,
    this.bankCode,
    this.cardType,
    this.responseCode,
    this.secureHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'status': status,
      'orderId': orderId,
      'metadata': metadata,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'bankCode': bankCode,
      'cardType': cardType,
      'responseCode': responseCode,
      'secureHash': secureHash,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      status: map['status'],
      orderId: map['orderId'],
      metadata: map['metadata'],
      paymentMethod: map['paymentMethod'],
      paymentId: map['paymentId'],
      bankCode: map['bankCode'],
      cardType: map['cardType'],
      responseCode: map['responseCode'],
      secureHash: map['secureHash'],
    );
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    DateTime? date,
    String? description,
    String? status,
    String? orderId,
    Map<String, dynamic>? metadata,
    String? paymentMethod,
    String? paymentId,
    String? bankCode,
    String? cardType,
    String? responseCode,
    String? secureHash,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      metadata: metadata ?? this.metadata,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      bankCode: bankCode ?? this.bankCode,
      cardType: cardType ?? this.cardType,
      responseCode: responseCode ?? this.responseCode,
      secureHash: secureHash ?? this.secureHash,
    );
  }
}

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String branchName;
  final bool isVerified;
  final DateTime? verificationDate;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.branchName,
    this.isVerified = false,
    this.verificationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'branchName': branchName,
      'isVerified': isVerified,
      'verificationDate':
          verificationDate != null
              ? Timestamp.fromDate(verificationDate!)
              : null,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      bankName: map['bankName'],
      accountNumber: map['accountNumber'],
      accountHolderName: map['accountHolderName'],
      branchName: map['branchName'],
      isVerified: map['isVerified'] ?? false,
      verificationDate:
          map['verificationDate'] != null
              ? (map['verificationDate'] as Timestamp).toDate()
              : null,
    );
  }
}
