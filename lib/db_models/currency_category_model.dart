const String currency_table = 'currency_table';

class CurrencyFields {
  static final List<String> values = [
    /// Add all fields
    id,
    countryName,
    symbol,
    currencyCode,
  ];

  static const String id = 'id';
  static const String countryName = 'countryName';
  static const String symbol = 'symbol';
  static const String currencyCode = 'currencyCode';
}

class CurrencyCategory {
  int? id;
  String? countryName;
  String? symbol;
  String? currencyCode;

  CurrencyCategory({
    this.id,
    this.countryName,
    this.symbol,
    this.currencyCode,
  });

  factory CurrencyCategory.fromMap(Map<String, dynamic> map) {
    return CurrencyCategory(
      id: map['id'],
      countryName: map['countryName'],
      symbol: map['symbol'],
      currencyCode: map['currencyCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'countryName': countryName,
      'symbol': symbol,
      'currencyCode': currencyCode,
    };
  }
}
