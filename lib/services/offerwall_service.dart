import 'api_client.dart';

class OfferwallService {
  OfferwallService._();
  static final OfferwallService instance = OfferwallService._();

  Future<List<Map<String, dynamic>>> getMissions({String? category, String? type}) async {
    final list = await apiGet<List>('/offerwall', params: {
      if (category != null) 'category': category,
      if (type     != null) 'type':     type,
    });
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<({int reward, double balance})> complete(String offerId) async {
    final data = await apiPost<Map>('/offerwall/$offerId/complete');
    return (
      reward:  (data['reward']  as num).toInt(),
      balance: (data['balance'] as num).toDouble(),
    );
  }
}
