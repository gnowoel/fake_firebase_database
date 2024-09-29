part of '../fake_firebase_database.dart';

class FakeOnDisconnect implements OnDisconnect {
  @override
  Future<void> cancel() {
    // TODO: implement cancel
    throw UnimplementedError();
  }

  @override
  Future<void> remove() {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<void> set(Object? value) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) {
    // TODO: implement setWithPriority
    throw UnimplementedError();
  }

  @override
  Future<void> update(Map<String, Object?> value) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
