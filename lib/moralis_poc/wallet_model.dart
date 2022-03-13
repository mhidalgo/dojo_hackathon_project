class WalletBalance {

  final String balance;

  const WalletBalance({
    required this.balance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: json['balance'],
    );
  }
}

class TokenData {

  final String name;
  final String balance; //in Wei


  const TokenData({
    required this.name,
    required this.balance,
  });

  factory TokenData.fromJson(List <dynamic> json) {
    return TokenData(
      name: json[0]['name'],
      balance: json[0]['balance'],
    );
  }
}