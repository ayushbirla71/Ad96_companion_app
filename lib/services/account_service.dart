import 'dart:convert';
import '../models/account_info.dart';
import '../services/api_service.dart';

class AccountService {
  static Future<AccountInfo> getAccount() async {
    final res = await ApiService.get('/user/account');

    if (res.statusCode != 200) {
      throw Exception("Failed to load account");
    }

    final json = jsonDecode(res.body);

    return AccountInfo.fromJson(json);
  }
}
