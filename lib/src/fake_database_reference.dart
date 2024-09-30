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
  Future<void> remove() {
    // TODO: implement remove
    throw UnimplementedError();
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
    final pathParts = _path.split('/').where((part) => part.isNotEmpty).toList()
      ..insert(0, '/');

    _setDataAtPath(_database._store, pathParts, value);
  }

  void _setDataAtPath(
    Map<String, dynamic> data,
    List<String> pathParts,
    Object? value,
  ) {
    for (int i = 0; i < pathParts.length; i++) {
      final part = pathParts[i];

      if (i == pathParts.length - 1) {
        data[part] = value;
      } else {
        data[part] ??= <String, dynamic>{};
        data = data[part] as Map<String, dynamic>;
      }
    }
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
  Future<void> update(Map<String, Object?> value) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
