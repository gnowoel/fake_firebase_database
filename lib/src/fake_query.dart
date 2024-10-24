part of '../fake_firebase_database.dart';

typedef EntryList = List<MapEntry<String, dynamic>>;

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;

  Map<String, dynamic>? _order;
  Map<String, dynamic>? _start;
  Map<String, dynamic>? _end;
  Map<String, dynamic>? _limit;

  DataSnapshot? _lastSnapshot;

  final _childAddedController = _createStreamController();
  final _childChangedController = _createStreamController();
  final _childMovedController = _createStreamController();
  final _childRemovedController = _createStreamController();
  final _valueController = _createStreamController();

  FakeQuery(this._database, this._path);

  static StreamController<DatabaseEvent> _createStreamController() {
    return StreamController<DatabaseEvent>.broadcast();
  }

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
    return _getSnapshot();
  }

  DataSnapshot _getSnapshot() {
    final parts = _pathParts;
    Object? data = _database._store;

    data = traverseValue(data, parts);

    if (data is Map<String, dynamic>) {
      EntryList entries = data.entries.toList();
      entries = _applyQuery(entries);
      data = Map.fromEntries(entries);
    }

    data = _deepCopy(data);

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
  Stream<DatabaseEvent> get onChildAdded {
    _database._addActiveQuery(this);
    return _childAddedController.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildChanged {
    _database._addActiveQuery(this);
    return _childChangedController.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildMoved {
    _database._addActiveQuery(this);
    return _childMovedController.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildRemoved {
    _database._addActiveQuery(this);
    return _childRemovedController.stream;
  }

  @override
  Stream<DatabaseEvent> get onValue {
    _database._addActiveQuery(this);
    return _valueController.stream;
  }

  @visibleForTesting
  void dispose() {
    _database._removeActiveQuery(this);

    _childAddedController.close();
    _childChangedController.close();
    _childMovedController.close();
    _childRemovedController.close();
    _valueController.close();
  }

  void _triggerChildAdded(DataSnapshot snapshot, String? previousChildKey) {
    _childAddedController.add(
      FakeDatabaseEvent.childAdded(snapshot, previousChildKey),
    );
  }

  void _triggerChildChanged(DataSnapshot snapshot, String? previousChildKey) {
    _childChangedController.add(
      FakeDatabaseEvent.childChanged(snapshot, previousChildKey),
    );
  }

  void _triggerChildMoved(DataSnapshot snapshot, String? previousChildKey) {
    _childMovedController.add(
      FakeDatabaseEvent.childMoved(snapshot, previousChildKey),
    );
  }

  void _triggerChildRemoved(DataSnapshot snapshot) {
    _childRemovedController.add(
      FakeDatabaseEvent.childRemoved(snapshot),
    );
  }

  void _triggerValue(DataSnapshot snapshot) {
    _valueController.add(
      FakeDatabaseEvent.value(snapshot),
    );
  }

  @override
  Future<DatabaseEvent> once(
      [DatabaseEventType eventType = DatabaseEventType.value]) async {
    return switch (eventType) {
      DatabaseEventType.childAdded => onChildAdded.first,
      DatabaseEventType.childChanged => onChildChanged.first,
      DatabaseEventType.childMoved => onChildMoved.first,
      DatabaseEventType.childRemoved => onChildRemoved.first,
      DatabaseEventType.value => onValue.first,
    };
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

  DataSnapshot _getLastSnapshot() {
    _lastSnapshot ??= FakeDataSnapshot(ref, null);
    return _lastSnapshot!;
  }

  void _notifyListeners() {
    final s1 = _getLastSnapshot();
    final s2 = _getSnapshot();

    _triggerEvents(s1, s2);
    _lastSnapshot = s2;
  }

  void _triggerEvents(DataSnapshot s1, DataSnapshot s2) {
    _triggerValueEvent(s1, s2);
    _triggerChildCommonEvents(s1, s2);
    _triggerChildMovedEvent(s1, s2);
  }

  void _triggerValueEvent(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value;
    final v2 = s2.value;

    if (_shallowEquals(v1, v2)) return;

    _triggerValue(s2);
  }

  void _triggerChildCommonEvents(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value ?? {};
    final v2 = s2.value ?? {};

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
      if (!_shallowEquals(v1[key], v2[key])) {
        _triggerChildChanged(s2.child(key), _getPreviousChildKey(v2, key));
      }
    }
  }

  void _triggerChildMovedEvent(DataSnapshot s1, DataSnapshot s2) {
    final v1 = s1.value ?? {};
    final v2 = s2.value ?? {};

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

  Object? _deepCopy(Object? data) {
    if (data is Map || data is List) {
      data = jsonDecode(jsonEncode(data));
    }
    return data;
  }

  bool _shallowEquals(Object? a, Object? b) {
    if (a is Map && b is Map) {
      return mapEquals(a, b);
    } else if (a is List && b is List) {
      return listEquals(a, b);
    } else {
      return a == b;
    }
  }
}
