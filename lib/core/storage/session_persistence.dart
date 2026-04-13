import 'dart:convert';

import 'package:ai_resume_analyzer/core/storage/session_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sessionPersistenceProvider = Provider<SessionPersistence>((ref) {
  return const SharedPreferencesSessionPersistence();
});

abstract class SessionPersistence {
  Future<SessionSnapshot> load();

  Future<void> save(SessionSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesSessionPersistence implements SessionPersistence {
  const SharedPreferencesSessionPersistence();

  static const _storageKey = 'ai_resume_analyzer.session.v1';

  @override
  Future<SessionSnapshot> load() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = preferences.getString(_storageKey);

    if (payload == null || payload.isEmpty) {
      return const SessionSnapshot(jobDescription: '');
    }

    final decoded = jsonDecode(payload);
    if (decoded is! Map<Object?, Object?>) {
      return const SessionSnapshot(jobDescription: '');
    }

    return SessionSnapshot.fromMap(decoded);
  }

  @override
  Future<void> save(SessionSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();

    if (snapshot.isEmpty) {
      await preferences.remove(_storageKey);
      return;
    }

    await preferences.setString(_storageKey, jsonEncode(snapshot.toMap()));
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
