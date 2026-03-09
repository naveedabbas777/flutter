import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static const String _clientsKey = 'db_clients';
  static const String _committeesKey = 'db_committees';
  static const String _membersKey = 'db_members';
  static const String _paymentsKey = 'db_payments';
  static const String _messagesKey = 'db_messages';
  static const String _drawsKey = 'db_draws';

  Future<SharedPreferences> get _preferences async {
    return SharedPreferences.getInstance();
  }

  Future<List<Map<String, Object?>>> _readTable(String key) async {
    final preferences = await _preferences;
    final rawJson = preferences.getString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawJson);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => item.map(
            (entryKey, value) => MapEntry(entryKey.toString(), value),
          ),
        )
        .toList();
  }

  Future<void> _writeTable(String key, List<Map<String, Object?>> rows) async {
    final preferences = await _preferences;
    await preferences.setString(key, jsonEncode(rows));
  }

  int _nextId(List<Map<String, Object?>> rows) {
    var maxId = 0;
    for (final row in rows) {
      final value = row['id'];
      final id = value is int ? value : int.tryParse(value.toString()) ?? 0;
      if (id > maxId) {
        maxId = id;
      }
    }
    return maxId + 1;
  }

  double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<List<Map<String, Object?>>> getAllCommittees() async {
    final committees = await _readTable(_committeesKey);
    committees.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return committees;
  }

  Future<List<Map<String, Object?>>> getAllMembers() async {
    return _readTable(_membersKey);
  }

  Future<List<Map<String, Object?>>> getAllPayments() async {
    return _readTable(_paymentsKey);
  }

  Future<List<Map<String, Object?>>> getClients() async {
    final clients = await _readTable(_clientsKey);
    clients.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return clients;
  }

  Future<int> insertClient({
    required String name,
    required String phone,
    required String company,
  }) async {
    final clients = await _readTable(_clientsKey);
    final id = _nextId(clients);
    clients.add({
      'id': id,
      'name': name,
      'phone': phone,
      'company': company,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _writeTable(_clientsKey, clients);
    return id;
  }

  Future<int> updateClient({
    required int id,
    required String name,
    required String phone,
    required String company,
  }) async {
    final clients = await _readTable(_clientsKey);
    final index = clients.indexWhere((row) => row['id'] == id);
    if (index == -1) {
      return 0;
    }

    clients[index] = {
      ...clients[index],
      'name': name,
      'phone': phone,
      'company': company,
    };
    await _writeTable(_clientsKey, clients);
    return 1;
  }

  Future<int> deleteClient(int id) async {
    final clients = await _readTable(_clientsKey);
    final beforeClientsLength = clients.length;
    clients.removeWhere((row) => row['id'] == id);
    await _writeTable(_clientsKey, clients);

    final committees = await _readTable(_committeesKey);
    final deletedCommitteeIds =
        committees
            .where((row) => row['client_id'] == id)
            .map((row) => row['id'] as int)
            .toSet();
    committees.removeWhere((row) => row['client_id'] == id);
    await _writeTable(_committeesKey, committees);

    if (deletedCommitteeIds.isNotEmpty) {
      final members = await _readTable(_membersKey);
      members.removeWhere(
        (row) => deletedCommitteeIds.contains(row['committee_id']),
      );
      await _writeTable(_membersKey, members);

      final payments = await _readTable(_paymentsKey);
      payments.removeWhere(
        (row) => deletedCommitteeIds.contains(row['committee_id']),
      );
      await _writeTable(_paymentsKey, payments);
    }

    return beforeClientsLength - clients.length;
  }

  Future<List<Map<String, Object?>>> getCommitteesByClient(int clientId) async {
    final committees = await _readTable(_committeesKey);
    final filtered =
        committees.where((row) => row['client_id'] == clientId).toList();
    filtered.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return filtered;
  }

  Future<int> insertCommittee({
    required int clientId,
    required String name,
    required String description,
    required String status,
    String? startDate,
    String? endDate,
    double? totalBudget,
  }) async {
    final committees = await _readTable(_committeesKey);
    final id = _nextId(committees);
    committees.add({
      'id': id,
      'client_id': clientId,
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'total_budget': (totalBudget ?? 0).toDouble(),
      'created_at': DateTime.now().toIso8601String(),
    });
    await _writeTable(_committeesKey, committees);
    return id;
  }

  Future<int> updateCommittee({
    required int id,
    required String name,
    required String description,
    required String status,
    String? startDate,
    String? endDate,
    double? totalBudget,
  }) async {
    final committees = await _readTable(_committeesKey);
    final index = committees.indexWhere((row) => row['id'] == id);
    if (index == -1) {
      return 0;
    }

    committees[index] = {
      ...committees[index],
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'total_budget': (totalBudget ?? 0).toDouble(),
    };
    await _writeTable(_committeesKey, committees);
    return 1;
  }

  Future<int> deleteCommittee(int id) async {
    final committees = await _readTable(_committeesKey);
    final beforeCommitteesLength = committees.length;
    committees.removeWhere((row) => row['id'] == id);
    await _writeTable(_committeesKey, committees);

    final members = await _readTable(_membersKey);
    members.removeWhere((row) => row['committee_id'] == id);
    await _writeTable(_membersKey, members);

    final payments = await _readTable(_paymentsKey);
    payments.removeWhere((row) => row['committee_id'] == id);
    await _writeTable(_paymentsKey, payments);

    final draws = await _readTable(_drawsKey);
    draws.removeWhere((row) => row['committee_id'] == id);
    await _writeTable(_drawsKey, draws);

    return beforeCommitteesLength - committees.length;
  }

  Future<List<Map<String, Object?>>> getMembersByCommittee(
    int committeeId,
  ) async {
    final members = await _readTable(_membersKey);
    final filtered =
        members.where((row) => row['committee_id'] == committeeId).toList();
    filtered.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return filtered;
  }

  Future<int> insertMember({
    required int committeeId,
    required String name,
    required String role,
    required String phone,
    required String email,
    String? joinedAt,
  }) async {
    final members = await _readTable(_membersKey);
    final id = _nextId(members);
    members.add({
      'id': id,
      'committee_id': committeeId,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'joined_at': joinedAt,
    });
    await _writeTable(_membersKey, members);
    return id;
  }

  Future<int> updateMember({
    required int id,
    required String name,
    required String role,
    required String phone,
    required String email,
    String? joinedAt,
  }) async {
    final members = await _readTable(_membersKey);
    final index = members.indexWhere((row) => row['id'] == id);
    if (index == -1) {
      return 0;
    }

    members[index] = {
      ...members[index],
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'joined_at': joinedAt,
    };
    await _writeTable(_membersKey, members);
    return 1;
  }

  Future<int> deleteMember(int id) async {
    final members = await _readTable(_membersKey);
    final beforeMembersLength = members.length;
    members.removeWhere((row) => row['id'] == id);
    await _writeTable(_membersKey, members);
    return beforeMembersLength - members.length;
  }

  Future<List<Map<String, Object?>>> getPaymentsByCommittee(
    int committeeId,
  ) async {
    final payments = await _readTable(_paymentsKey);
    final filtered =
        payments.where((row) => row['committee_id'] == committeeId).toList();
    filtered.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return filtered;
  }

  Future<int> insertPayment({
    required int committeeId,
    required double amount,
    required String paidOn,
    required String method,
    required String note,
    int? memberId,
  }) async {
    final payments = await _readTable(_paymentsKey);
    final id = _nextId(payments);
    payments.add({
      'id': id,
      'committee_id': committeeId,
      'member_id': memberId,
      'amount': amount,
      'paid_on': paidOn,
      'method': method,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _writeTable(_paymentsKey, payments);
    return id;
  }

  Future<List<Map<String, Object?>>> getPaymentsByMember(
    int memberId,
  ) async {
    final payments = await _readTable(_paymentsKey);
    final filtered =
        payments.where((row) => row['member_id'] == memberId).toList();
    filtered.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return filtered;
  }

  Future<int> deletePayment(int id) async {
    final payments = await _readTable(_paymentsKey);
    final beforeLength = payments.length;
    payments.removeWhere((row) => row['id'] == id);
    await _writeTable(_paymentsKey, payments);
    return beforeLength - payments.length;
  }

  Future<Map<String, double>> getCommitteePaymentSummary(
    int committeeId,
  ) async {
    final committees = await _readTable(_committeesKey);
    final committee = committees.firstWhere(
      (row) => row['id'] == committeeId,
      orElse: () => <String, Object?>{},
    );
    final totalBudget = _toDouble(committee['total_budget']);

    final payments = await getPaymentsByCommittee(committeeId);
    final totalReceived = payments.fold<double>(
      0,
      (sum, row) => sum + _toDouble(row['amount']),
    );
    final remaining =
        (totalBudget - totalReceived).clamp(0, double.infinity).toDouble();
    return {
      'total': totalBudget,
      'received': totalReceived,
      'pending': remaining,
    };
  }

  Future<List<Map<String, Object?>>> getMessages() async {
    final messages = await _readTable(_messagesKey);
    messages.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return messages;
  }

  Future<int> insertMessage({
    required String sender,
    required String recipient,
    required String subject,
    required String message,
    String? sentAt,
  }) async {
    final messages = await _readTable(_messagesKey);
    final id = _nextId(messages);
    messages.add({
      'id': id,
      'sender': sender,
      'recipient': recipient,
      'subject': subject,
      'message': message,
      'sent_at': sentAt ?? DateTime.now().toIso8601String(),
      'is_read': false,
    });
    await _writeTable(_messagesKey, messages);
    return id;
  }

  Future<int> markMessageAsRead(int id) async {
    final messages = await _readTable(_messagesKey);
    final index = messages.indexWhere((row) => row['id'] == id);
    if (index == -1) {
      return 0;
    }
    messages[index]['is_read'] = true;
    await _writeTable(_messagesKey, messages);
    return 1;
  }

  Future<int> deleteMessage(int id) async {
    final messages = await _readTable(_messagesKey);
    final beforeLength = messages.length;
    messages.removeWhere((row) => row['id'] == id);
    await _writeTable(_messagesKey, messages);
    return beforeLength - messages.length;
  }

  // ─── Lucky Draws ──────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> getDrawsByCommittee(
    int committeeId,
  ) async {
    final draws = await _readTable(_drawsKey);
    final filtered =
        draws.where((row) => row['committee_id'] == committeeId).toList();
    filtered.sort((a, b) =>
        (b['round_number'] as int).compareTo(a['round_number'] as int));
    return filtered;
  }

  Future<int> insertDraw({
    required int committeeId,
    required int roundNumber,
    required int winnerMemberId,
    required double totalAmount,
  }) async {
    final draws = await _readTable(_drawsKey);
    final id = _nextId(draws);
    draws.add({
      'id': id,
      'committee_id': committeeId,
      'round_number': roundNumber,
      'winner_member_id': winnerMemberId,
      'total_amount': totalAmount,
      'drawn_at': DateTime.now().toIso8601String(),
    });
    await _writeTable(_drawsKey, draws);
    return id;
  }

  Future<int> deleteDraw(int id) async {
    final draws = await _readTable(_drawsKey);
    final beforeLength = draws.length;
    draws.removeWhere((row) => row['id'] == id);
    await _writeTable(_drawsKey, draws);
    return beforeLength - draws.length;
  }

  /// Picks a random member who hasn't won yet in this committee.
  /// Returns null if all members have already won or no members exist.
  Future<Map<String, Object?>?> pickLuckyDrawWinner(
    int committeeId,
  ) async {
    final members = await getMembersByCommittee(committeeId);
    if (members.isEmpty) return null;

    final draws = await getDrawsByCommittee(committeeId);
    final winnerIds =
        draws.map((d) => d['winner_member_id'] as int).toSet();

    final eligible = members
        .where((m) => !winnerIds.contains(m['id'] as int))
        .toList();
    if (eligible.isEmpty) return null;

    final random = Random();
    return eligible[random.nextInt(eligible.length)];
  }
}
