import 'api_client.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  Future<double> getBalance() async {
    final data = await apiGet<Map>('/wallet/balance');
    return (data['balance'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getLedger({int limit = 50, String? type}) async {
    final list = await apiGet<List>('/wallet/ledger', params: {
      'limit': limit,
      if (type != null) 'type': type,
    });
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<double> earn(String icon, String name, int amount) async {
    final data = await apiPost<Map>('/wallet/earn', data: {
      'icon': icon, 'name': name, 'amount': amount,
    });
    return (data['balance'] as num).toDouble();
  }

  Future<double> spend(String name, int amount) async {
    final data = await apiPost<Map>('/wallet/spend', data: {
      'name': name, 'amount': amount,
    });
    return (data['balance'] as num).toDouble();
  }
}
