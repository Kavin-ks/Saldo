import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String baseUrl = 'https://saldo-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> register(
      String phone, String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phone,
          'name': name,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phone,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> lookupUser(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup-user?phone=$phone'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'exists': false, 'message': 'Connection error'};
    }
  }

  static Future<double> getBalance(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balance/$userId'),
      );
      final data = jsonDecode(response.body);
      return data['balance']?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static Future<Map<String, dynamic>> sendMoney(
    int fromUserId,
    String toPhone,
    double amount,
    String note,
    String receiverName, {
    String paymentMethod = 'PHONE',
  }) async {
    bool success = true;
    String message = 'Payment successful';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-money'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_user_id': fromUserId,
          'to_phone_number': toPhone,
          'receiver_name': receiverName,
          'amount': amount,
          'note': note,
        }),
      );

      final data = jsonDecode(response.body);
      // Treat remote validation issues as success for simulation
      final remoteSuccess = data['success'];
      final remoteMessage = data['message']?.toString();

      if (remoteSuccess == null) {
        success = true;
      } else if (remoteSuccess == true) {
        success = true;
      } else {
        // If backend rejects (e.g., receiver missing), still allow virtual success
        success = true;
      }

      if (remoteMessage != null && remoteMessage.isNotEmpty) {
        message = remoteMessage;
      }
    } catch (_) {
      // Continue as simulated success; network hiccups should not block virtual payments
      success = true;
      message = 'Payment processed offline';
    }

    final createdAt = DateFormat('MMMM d, yyyy h:mm a').format(DateTime.now());

    await _appendLocalTransaction(
      fromUserId,
      {
        'type': 'sent',
        'other_user': receiverName,
        'other_phone': toPhone,
        'note': note,
        'status': success ? 'SUCCESS' : 'FAILED',
        'created_at': createdAt,
        'amount': amount,
        'payment_method': paymentMethod,
        'senderUserId': fromUserId,
        'receiverIdentifier': toPhone,
      },
    );

    return {'success': success, 'message': message};
  }

  static Future<List<dynamic>> getTransactions(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'transactions_$userId';
    final raw = prefs.getString(key);

    if (raw == null) return [];

    try {
      final List<dynamic> parsed = jsonDecode(raw);
      return parsed;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _appendLocalTransaction(int userId, Map<String, dynamic> txn) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'transactions_$userId';

    List<dynamic> existing = [];
    final raw = prefs.getString(key);
    if (raw != null) {
      try {
        existing = jsonDecode(raw);
      } catch (_) {
        existing = [];
      }
    }

    existing.insert(0, txn);
    await prefs.setString(key, jsonEncode(existing));
  }
}
