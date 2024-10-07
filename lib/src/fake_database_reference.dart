part of '../fake_firebase_database.dart';

class FakeDatabaseReference extends FakeQuery implements DatabaseReference {
  FakeDatabaseReference(super._database, super._path);

  @override
  DatabaseReference child(String path) {
    final base = _path == null ? '' : '$_path/';
    return FakeDatabaseReference(_database, base + path);
  }

  @override
  String? get key => _path?.split('/').last;

  @override
  OnDisconnect onDisconnect() {
    // TODO: implement onDisconnect
    throw UnimplementedError();
  }

  @override
  DatabaseReference? get parent {
    if (_pathParts.length == 1) {
      return null;
    }
    final parentPath = '/${(_pathParts.sublist(1)..removeLast()).join('/')}';
    return FakeDatabaseReference(_database, parentPath);
  }

  @override
  DatabaseReference push() {
    final pushId = PushId.generate();
    return child(pushId);
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
    final lastPart = parts.removeLast();
    Map<String, dynamic> data = _database._store;

    for (final part in parts) {
      if (!data.containsKey(part) || data[part] is! Map<String, dynamic>) {
        data[part] = <String, dynamic>{};
      }
      data = data[part] as Map<String, dynamic>;
    }

    _cleanDown(value);
    data[lastPart] = value;
    _cleanUp();
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

    _cleanDown(data);
    _cleanUp();
  }

  void _cleanDown(Object? value) {
    if (value is Map) {
      value = value.cast<String, dynamic>();
      value.removeWhere((key, val) {
        _cleanDown(val);
        return _isEmptyOrNull(val);
      });
    }

    if (value is List) {
      value.removeWhere((item) {
        _cleanDown(item);
        return _isEmptyOrNull(item);
      });
    }
  }

  void _cleanUp() {
    final parts = _pathParts;
    final lastPart = parts.removeLast();
    Map<String, dynamic> data = _database._store;
    List<Object?> levels = [data];

    for (final part in parts) {
      data = data[part] as Map<String, dynamic>;
      levels.add(data);
    }

    levels.add(data[lastPart]);
    parts.add(lastPart);

    for (int i = levels.length - 1; i > 0; i--) {
      final currentLevel = levels[i];
      final parentLevel = levels[i - 1];
      final key = parts[i - 1];

      if (_isEmptyOrNull(currentLevel)) {
        (parentLevel as Map<String, dynamic>).remove(key);
      } else {
        break;
      }
    }
  }

  bool _isEmptyOrNull(Object? value) {
    if (value == null) return true;
    if (value is Map) return value.isEmpty;
    if (value is List) return value.isEmpty;
    return false;
  }
}
