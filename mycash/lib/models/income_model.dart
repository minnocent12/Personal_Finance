class Income {
  final int? id;
  final String source;
  final double amount;
  final String date;
  final String? notes;

  Income(
      {this.id,
      required this.source,
      required this.amount,
      required this.date,
      this.notes});

  // Convert Income object to map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }

  // Convert map to Income object
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      source: map['source'],
      amount: map['amount'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
