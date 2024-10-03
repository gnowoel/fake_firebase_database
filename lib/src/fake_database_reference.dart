part of '../fake_firebase_database.dart';

class FakeDatabaseReference extends FakeQuery implements DatabaseReference {
  FakeDatabaseReference(super._database, super._path);

  @override
  DatabaseReference child(String path) {
    // TODO: implement child
    throw UnimplementedError();
  }

  @override
  // TODO: implement key
  String? get key => throw UnimplementedError();

  @override
  OnDisconnect onDisconnect() {
    // TODO: implement onDisconnect
    throw UnimplementedError();
  }

  @override
  // TODO: implement parent
  DatabaseReference? get parent => throw UnimplementedError();

  @override
  DatabaseReference push() {
    // TODO: implement push
    throw UnimplementedError();
  }

  @override
  Future<void> remove() async {
    set(null);
  }

  @override
  // TODO: implement root
  DatabaseReference get root => throw UnimplementedError();

  @override
  Future<TransactionResult> runTransaction(
      TransactionHandler transactionHandler,
      {bool applyLocally = true}) {
    // TODO: implement runTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> set(Object? value) async {
    final parts = _pathParts;
    Map<String, dynamic> data = _database._store;
    final lastPart = parts.removeLast();

    for (final part in parts) {
      if (!data.containsKey(part) || data[part] is! Map<String, dynamic>) {
        data[part] = <String, dynamic>{};
      }
      data = data[part] as Map<String, dynamic>;
    }
    data[lastPart] = value;
  }

  @override
  Future<void> setPriority(Object? priority) {
    // TODO: implement setPriority
    throw UnimplementedError();
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) {
    // TODO: implement setWithPriority
    throw UnimplementedError();
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    final parts = _pathParts;
    Map<String, dynamic> data = _database._store;

    for (final part in parts) {
      if (!data.containsKey(part) || data[part] is! Map<String, dynamic>) {
        data[part] = <String, dynamic>{};
      }
      data = data[part] as Map<String, dynamic>;
    }

    value.forEach((key, val) {
      data[key] = val;
    });
  }
}
