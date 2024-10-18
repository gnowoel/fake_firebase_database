part of '../fake_firebase_database.dart';

typedef EntryList = List<MapEntry<String, dynamic>>;

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;
  Map<String, dynamic>? _order;
  Map<String, dynamic>? _start;
  Map<String, dynamic>? _end;
  Map<String, dynamic>? _limit;

  FakeQuery(this._database, this._path);

  @override
  Query endAt(Object? value, {String? key}) {
    _end = {
      'type': 'at',
      'params': {'value': value, 'key': key},
    };
    return this;
  }

  @override
  Query endBefore(Object? value, {String? key}) {
    _end = {
      'type': 'before',
      'params': {'value': value, 'key': key},
    };
    return this;
  }

  @override
  Query equalTo(Object? value, {String? key}) {
    return startAt(value, key: key).endAt(value, key: key);
  }

  @override
  Future<DataSnapshot> get() async {
    final parts = _pathParts;
    Object? data = _database._store;

    data = traverseValue(data, parts);

    if (data is Map<String, dynamic>) {
      EntryList entries = data.entries.toList();
      entries = _applyQuery(entries);
      data = Map.fromEntries(entries);
    }

    return FakeDataSnapshot(ref, data);
  }

  @override
  Future<void> keepSynced(bool value) {
    // TODO: implement keepSynced
    throw UnimplementedError();
  }

  @override
  Query limitToFirst(int limit) {
    _limit = {
      'type': 'toFirst',
      'params': {'limit': limit},
    };
    return this;
  }

  @override
  Query limitToLast(int limit) {
    _limit = {
      'type': 'toLast',
      'params': {'limit': limit},
    };
    return this;
  }

  @override
  // TODO: implement onChildAdded
  Stream<DatabaseEvent> get onChildAdded => throw UnimplementedError();

  @override
  // TODO: implement onChildChanged
  Stream<DatabaseEvent> get onChildChanged => throw UnimplementedError();

  @override
  // TODO: implement onChildMoved
  Stream<DatabaseEvent> get onChildMoved => throw UnimplementedError();

  @override
  // TODO: implement onChildRemoved
  Stream<DatabaseEvent> get onChildRemoved => throw UnimplementedError();

  @override
  // TODO: implement onValue
  Stream<DatabaseEvent> get onValue => throw UnimplementedError();

  @override
  Future<DatabaseEvent> once(
      [DatabaseEventType eventType = DatabaseEventType.value]) {
    // TODO: implement once
    throw UnimplementedError();
  }

  @override
  Query orderByChild(String path) {
    _order = {
      'type': 'byChild',
      'params': {'path': path},
    };
    return this;
  }

  @override
  Query orderByKey() {
    _order = {'type': 'byKey', 'params': null};
    return this;
  }

  @override
  Query orderByPriority() {
    // TODO: implement orderByPriority
    throw UnimplementedError();
  }

  @override
  Query orderByValue() {
    _order = {'type': 'byValue', 'params': null};
    return this;
  }

  @override
  String get path => _normalizePath(_path);

  @override
  DatabaseReference get ref => FakeDatabaseReference(_database, _path);

  @override
  Query startAfter(Object? value, {String? key}) {
    _start = {
      'type': 'after',
      'params': {'value': value, 'key': key},
    };
    return this;
  }

  @override
  Query startAt(Object? value, {String? key}) {
    _start = {
      'type': 'at',
      'params': {'value': value, 'key': key},
    };
    return this;
  }

  EntryList _applyQuery(EntryList entries) {
    if (_order != null) {
      entries = _applyOrder(entries);
    }

    if (_start != null) {
      entries = _applyStart(entries);
    }

    if (_end != null) {
      entries = _applyEnd(entries);
    }

    if (_limit != null) {
      entries = _applyLimit(entries);
    }

    return entries;
  }

  EntryList _applyOrder(EntryList entries) {
    return switch (_order!['type']) {
      'byChild' => _applyOrderByChild(entries),
      'byKey' => _applyOrderByKey(entries),
      'byValue' => _applyOrderByValue(entries),
      _ => entries,
    };
  }

  EntryList _applyOrderByChild(EntryList entries) {
    entries.sort((a, b) {
      final path = _order!['params']['path'];
      final parts = splitPath(path);
      final v1 = traverseValue(a.value, parts);
      final v2 = traverseValue(b.value, parts);

      return _compareValues(v1, v2);
    });

    return entries;
  }

  EntryList _applyOrderByKey(EntryList entries) {
    entries.sort((a, b) {
      final v1 = a.key;
      final v2 = b.key;

      return _compareValues(v1, v2);
    });

    return entries;
  }

  EntryList _applyOrderByValue(EntryList entries) {
    entries.sort((a, b) {
      final v1 = a.value;
      final v2 = b.value;

      return _compareValues(v1, v2);
    });

    return entries;
  }

  EntryList _applyStart(EntryList entries) {
    return switch (_start!['type']) {
      'at' => _applyStartAt(entries),
      'after' => _applyStartAfter(entries),
      _ => entries,
    };
  }

  EntryList _applyStartAt(EntryList entries) {
    final params = _start!['params'] as Map<String, dynamic>;
    return _applyBounds(
      entries,
      direction: 'start',
      inclusive: true,
      params: params,
    );
  }

  EntryList _applyStartAfter(EntryList entries) {
    final params = _start!['params'] as Map<String, dynamic>;
    return _applyBounds(
      entries,
      direction: 'start',
      inclusive: false,
      params: params,
    );
  }

  EntryList _applyEnd(EntryList entries) {
    return switch (_end!['type']) {
      'at' => _applyEndAt(entries),
      'before' => _applyEndBefore(entries),
      _ => entries,
    };
  }

  EntryList _applyEndAt(EntryList entries) {
    final params = _end!['params'] as Map<String, dynamic>;
    return _applyBounds(
      entries,
      direction: 'end',
      inclusive: true,
      params: params,
    );
  }

  EntryList _applyEndBefore(EntryList entries) {
    final params = _end!['params'] as Map<String, dynamic>;
    return _applyBounds(
      entries,
      direction: 'end',
      inclusive: false,
      params: params,
    );
  }

  EntryList _applyBounds(
    EntryList entries, {
    required String direction,
    required bool inclusive,
    required Map<String, dynamic> params,
  }) {
    final v = params['value'];
    final k = params['key'];
    final d = direction;
    final i = inclusive;
    final ki = k != null || i;

    if (_order == null) {
      entries = _applyOrderByKey(entries);
    }

    if (_order!['type'] == 'byKey') {
      entries = entries.where((entry) {
        return _compareBounds(entry.key, v, d, ki);
      }).toList();
    }

    if (_order!['type'] == 'byValue') {
      entries = entries.where((entry) {
        return _compareBounds(entry.value, v, d, ki);
      }).toList();
    }

    if (_order!['type'] == 'byChild') {
      entries = entries.where((entry) {
        final path = _order!['params']['path'];
        final parts = splitPath(path);
        final value = traverseValue(entry.value, parts);
        return _compareBounds(value, v, d, ki);
      }).toList();
    }

    if (k != null) {
      entries = entries.where((entry) {
        return _compareBounds(entry.key, k, d, i);
      }).toList();
    }

    return entries;
  }

  EntryList _applyLimit(EntryList entries) {
    return switch (_limit!['type']) {
      'toFirst' => _applyLimitToFirst(entries),
      'toLast' => _applyLimitToLast(entries),
      _ => entries,
    };
  }

  EntryList _applyLimitToFirst(EntryList entries) {
    final limit = _limit!['params']['limit'] as int;
    return entries.take(limit).toList();
  }

  EntryList _applyLimitToLast(EntryList entries) {
    final limit = _limit!['params']['limit'] as int;
    return entries.reversed.take(limit).toList().reversed.toList();
  }

  bool _compareBounds(
    Object? v1,
    Object? v2,
    String direction,
    bool inclusive,
  ) {
    final d = direction;
    final i = inclusive;
    final c = _compareValues(v1, v2);
    return d == 'start' ? (i ? c >= 0 : c > 0) : (i ? c <= 0 : c < 0);
  }

  int _compareValues(Object? v1, Object? v2) {
    if (v1 == null && v2 == null) return 0;
    if (v1 == null) return -1;
    if (v2 == null) return 1;

    if (v1 is num && v2 is num) {
      return v1.compareTo(v2);
    }

    if (v1 is String && v2 is String) {
      return v1.compareTo(v2);
    }

    if (v1 is bool && v2 is bool) {
      return v1 == v2 ? 0 : (v1 ? 1 : -1);
    }

    if (v1 is Comparable && v2 is Comparable) {
      try {
        return v1.compareTo(v2);
      } catch (e) {
        // Ignore
      }
    }

    return v1.toString().compareTo(v2.toString());
  }

  List<String> get _pathParts {
    final parts = splitPath(path);
    return parts..insert(0, '/');
  }

  String _normalizePath(String? path) {
    final relativePath = splitPath(path ?? '').join('/');
    return '/$relativePath';
  }
}
