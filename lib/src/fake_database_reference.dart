part of '../fake_firebase_database.dart';

class FakeDatabaseReference extends FakeQuery implements DatabaseReference {
  FakeDatabaseReference(super._database, super._path);

  @override
  DatabaseReference child(String path) {
    final childPath = _normalizePath('${this.path}/$path');
    return FakeDatabaseReference(_database, childPath);
  }

  @override
  String? get key => path == '/' ? null : _pathParts.last;

  @override
  OnDisconnect onDisconnect() {
    // TODO: implement onDisconnect
    throw UnimplementedError();
  }

  @override
  DatabaseReference? get parent {
    if (path == '/') return null;
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
  DatabaseReference get root => FakeDatabaseReference(_database, '/');

  @override
  Future<TransactionResult> runTransaction(
    TransactionHandler transactionHandler, {
    bool applyLocally = true,
  }) async {
    final s1 = _getSnapshot();
    final v1 = s1.value;

    try {
      final transaction = transactionHandler(v1);

      if (transaction.aborted) {
        return FakeTransactionResult(false, FakeDataSnapshot(ref, v1));
      }

      final v2 = transaction.value;
      await set(v2);

      return FakeTransactionResult(true, FakeDataSnapshot(ref, v2));
    } catch (e) {
      return FakeTransactionResult(false, FakeDataSnapshot(ref, v1));
    }
  }

  @override
  Future<void> set(Object? value) async {
    final parts = _pathParts;
    Map<String, dynamic> data = _database._store;

    _createValue(data, value, parts);

    _cleanUp();
    _database._notifyListeners(this);
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

    data = _walkThrough(data, parts);

    value.forEach((key, val) {
      _createValue(data, val, splitPath(key));
    });

    _cleanDown(data);
    _cleanUp(); // TODO: Clean up separately for each updated entry
    _database._notifyListeners(this);
  }

  void _createValue(
      Map<String, dynamic> data, Object? value, List<String> parts) {
    final lastPart = parts.removeLast();

    data = _walkThrough(data, parts);
    value = _handleServerValue(data[lastPart], value);
    _cleanDown(value);
    data[lastPart] = value;
  }

  Map<String, dynamic> _walkThrough(
      Map<String, dynamic> data, List<String> parts) {
    for (final part in parts) {
      if (data[part] is! Map || !data.containsKey(part)) {
        data[part] = <String, dynamic>{};
      }
      data = data[part] as Map<String, dynamic>;
    }
    return data;
  }

  Object? _handleServerValue(Object? oldValue, Object? newValue) {
    newValue = _handleServerTimestamp(newValue);
    newValue = _handleServerIncrement(oldValue, newValue);
    return newValue;
  }

  Object? _handleServerTimestamp(Object? value) {
    if (value is! Map) return value;

    if (_isServerTimestamp(value)) {
      return DateTime.now().millisecondsSinceEpoch;
    }

    for (final key in value.keys) {
      value[key] = _handleServerTimestamp(value[key]);
    }

    return value;
  }

  Object? _handleServerIncrement(Object? oldValue, Object? newValue) {
    if (newValue is! Map) return newValue;

    if (_isServerIncrement(newValue)) {
      final increment = (newValue as Map)['.sv']['increment'] as num;
      return (oldValue as num) + increment;
    }

    if (oldValue is Map) {
      for (final key in newValue.keys) {
        newValue[key] = _handleServerIncrement(oldValue[key], newValue[key]);
      }
    }

    return newValue;
  }

  bool _isServerTimestamp(Object? value) {
    if (value is! Map) return false;
    return value['.sv'] == 'timestamp';
  }

  bool _isServerIncrement(Object? value) {
    if (value is! Map) return false;
    return value['.sv'] is Map &&
        (value['.sv'] as Map).containsKey('increment');
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
