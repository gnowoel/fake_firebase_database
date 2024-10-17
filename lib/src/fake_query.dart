part of '../fake_firebase_database.dart';

typedef EntryList = List<MapEntry<String, dynamic>>;

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;
  Map<String, dynamic>? _order;
  Map<String, dynamic>? _startAt;
  Map<String, dynamic>? _limit;

  FakeQuery(this._database, this._path);

  @override
  Query endAt(Object? value, {String? key}) {
    // TODO: implement endAt
    throw UnimplementedError();
  }

  @override
  Query endBefore(Object? value, {String? key}) {
    // TODO: implement endBefore
    throw UnimplementedError();
  }

  @override
  Query equalTo(Object? value, {String? key}) {
    // TODO: implement equalTo
    throw UnimplementedError();
  }

  @override
  Future<DataSnapshot> get() async {
    final parts = _pathParts;
    Object? data = _database._store;

    for (final part in parts) {
      if (data is Map && data.containsKey(part)) {
        data = data[part];
      } else {
        data = null;
        break;
      }
    }

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
    _limit = {'key': 'toFirst', 'value': limit};
    return this;
  }

  @override
  Query limitToLast(int limit) {
    _limit = {'key': 'toLast', 'value': limit};
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
    _order = {'key': 'byChild', 'value': path};
    return this;
  }

  @override
  Query orderByKey() {
    _order = {'key': 'byKey', 'value': true};
    return this;
  }

  @override
  Query orderByPriority() {
    // TODO: implement orderByPriority
    throw UnimplementedError();
  }

  @override
  Query orderByValue() {
    _order = {'key': 'byValue', 'value': true};
    return this;
  }

  @override
  String get path => _normalizePath(_path);

  @override
  DatabaseReference get ref => FakeDatabaseReference(_database, _path);

  @override
  Query startAfter(Object? value, {String? key}) {
    // TODO: implement startAfter
    throw UnimplementedError();
  }

  @override
  Query startAt(Object? value, {String? key}) {
    _startAt = {'value': value, 'key': key};
    return this;
  }

  List<String> get _pathParts {
    final parts = _splitPath(path);
    return parts..insert(0, '/');
  }

  String _normalizePath(String? path) {
    final relativePath = _splitPath(path ?? '').join('/');
    return '/$relativePath';
  }

  List<String> _splitPath(String path) {
    return path.split('/').where((p) => p.isNotEmpty).toList();
  }

  EntryList _applyQuery(EntryList entries) {
    if (_order != null) {
      entries = _applyOrder(entries);
    }

    if (_startAt != null) {
      entries = _applyStartAt(entries);
    }

    if (_limit != null) {
      entries = _applyLimit(entries);
    }

    return entries;
  }

  EntryList _applyOrder(EntryList entries) {
    return switch (_order!['key']) {
      'byChild' => _applyOrderByChild(entries),
      'byKey' => _applyOrderByKey(entries),
      'byValue' => _applyOrderByValue(entries),
      _ => entries,
    };
  }

  EntryList _applyOrderByChild(EntryList entries) {
    entries.sort((a, b) {
      final path = _order!['value'];
      final v1 = a.value[path];
      final v2 = b.value[path];

      if (v1 == null && v2 == null) return 0;
      if (v1 == null) return -1;
      if (v2 == null) return 1;

      return (v1 as Comparable).compareTo(v2);
    });

    return entries;
  }

  EntryList _applyOrderByKey(EntryList entries) {
    entries.sort((a, b) {
      final v1 = a.key;
      final v2 = b.key;

      return v1.compareTo(v2);
    });

    return entries;
  }

  EntryList _applyOrderByValue(EntryList entries) {
    entries.sort((a, b) {
      final v1 = a.value;
      final v2 = b.value;

      if (v1 == null && v2 == null) return 0;
      if (v1 == null) return -1;
      if (v2 == null) return 1;

      if (v1 is num && v2 is num) {
        return v1.compareTo(v2);
      } else if (v1 is String && v2 is String) {
        return v1.compareTo(v2);
      } else if (v1 is bool && v2 is bool) {
        return v1 == v2 ? 0 : (v1 ? 1 : -1);
      } else {
        return v1.toString().compareTo(v2.toString());
      }
    });

    return entries;
  }

  EntryList _applyStartAt(EntryList entries) {
    final startAtValue = _startAt!['value'];
    final startAtKey = _startAt!['key'];

    if (_order == null) {
      entries = _applyOrderByKey(entries);
    }

    if (_order!['key'] == 'byKey') {
      entries = entries.where((entry) {
        return entry.key.compareTo(startAtValue as String) >= 0;
      }).toList();
    }

    if (_order!['key'] == 'byValue') {
      entries = entries.where((entry) {
        return (entry.value as Comparable).compareTo(startAtValue) >= 0;
      }).toList();
    }

    if (_order!['key'] == 'byChild') {
      entries = entries.where((entry) {
        final childKey = _order!['value'];
        final entryChildValue = entry.value[childKey];
        return (entryChildValue as Comparable).compareTo(startAtValue) >= 0;
      }).toList();
    }

    if (startAtKey != null) {
      entries = entries.where((entry) {
        return entry.key.compareTo(startAtKey) >= 0;
      }).toList();
    }

    return entries;
  }

  EntryList _applyLimit(EntryList entries) {
    return switch (_limit!['key']) {
      'toFirst' => _applyLimitToFirst(entries),
      'toLast' => _applyLimitToLast(entries),
      _ => entries,
    };
  }

  EntryList _applyLimitToFirst(EntryList entries) {
    final limit = _limit!['value'] as int;
    return entries.take(limit).toList();
  }

  EntryList _applyLimitToLast(EntryList entries) {
    final limit = _limit!['value'] as int;
    return entries.reversed.take(limit).toList().reversed.toList();
  }
}
