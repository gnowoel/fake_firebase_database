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
      TransactionHandler transactionHandler,
      {bool applyLocally = true}) {
    // TODO: implement runTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> set(Object? value) async {
    final s1 = await get();

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

    final s2 = await get();
    _triggerEvents(s1, s2);
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
    final s1 = await get();

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

    final s2 = await get();
    _triggerEvents(s1, s2);
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

  void _triggerEvents(DataSnapshot s1, DataSnapshot s2) {
    _triggerValueEvent(s1, s2);
    _triggerChildCommonEvents(s1, s2);
    _triggerChildMovedEvent(s1, s2);
  }

  void _triggerValueEvent(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value;
    final v2 = s2.value;

    if (_deepEquals(v1, v2)) return;

    _triggerValue(s2);
  }

  void _triggerChildCommonEvents(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value;
    final v2 = s2.value;

    if (v1 is! Map || v2 is! Map) return;

    final keys1 = v1.keys.toSet();
    final keys2 = v2.keys.toSet();

    final addedKeys = keys2.difference(keys1);
    final removedKeys = keys1.difference(keys2);
    final commonKeys = keys1.intersection(keys2);

    for (final key in addedKeys) {
      _triggerChildAdded(s2.child(key), _getPreviousChildKey(v2, key));
    }

    for (final key in removedKeys) {
      _triggerChildRemoved(s1.child(key));
    }

    for (final key in commonKeys) {
      if (!_deepEquals(v1[key], v2[key])) {
        _triggerChildChanged(s2.child(key), _getPreviousChildKey(v2, key));
      }
    }
  }

  void _triggerChildMovedEvent(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value;
    final v2 = s2.value;

    if (v1 is! Map || v2 is! Map) return;

    final keys1 = v1.keys.toList();
    final keys2 = v2.keys.toList();

    for (int i = 0; i < keys2.length; i++) {
      final key = keys2[i];
      final oldIndex = keys1.indexOf(key);
      if (oldIndex != -1 && oldIndex != i) {
        _triggerChildMoved(s2.child(key), _getPreviousChildKey(v2, key));
      }
    }
  }

  String? _getPreviousChildKey(Map map, String key) {
    final keys = map.keys.toList();
    final index = keys.indexOf(key);
    return index > 0 ? keys[index - 1] : null;
  }

  bool _deepEquals(Object? a, Object? b) {
    if (a is Map && b is Map) {
      return mapEquals(a, b);
    } else if (a is List && b is List) {
      return listEquals(a, b);
    } else {
      return a == b;
    }
  }
}
