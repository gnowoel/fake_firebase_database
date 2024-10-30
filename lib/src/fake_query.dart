part of '../fake_firebase_database.dart';

typedef Entry = MapEntry<String, dynamic>;
typedef EntryList = List<MapEntry<String, dynamic>>;
typedef PairList = List<Pair>;

class Pair {
  final Entry entry;
  final Object? filter;

  Pair({
    required this.entry,
    required this.filter,
  });

  Pair copyWith({
    Entry? entry,
    Object? filter,
  }) {
    return Pair(
      entry: entry ?? this.entry,
      filter: filter ?? this.filter,
    );
  }
}

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;

  Map<String, dynamic>? _order;
  Map<String, dynamic>? _start;
  Map<String, dynamic>? _end;
  Map<String, dynamic>? _limit;

  DataSnapshot? _lastSnapshot;

  StreamController<DatabaseEvent>? _childAddedController;
  StreamController<DatabaseEvent>? _childChangedController;
  StreamController<DatabaseEvent>? _childMovedController;
  StreamController<DatabaseEvent>? _childRemovedController;
  StreamController<DatabaseEvent>? _valueController;

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
    _childAddedController ??= _createStreamController();
    return _childAddedController!.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildChanged {
    _childChangedController ??= _createStreamController();
    return _childChangedController!.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildMoved {
    _childMovedController ??= _createStreamController();
    return _childMovedController!.stream;
  }

  @override
  Stream<DatabaseEvent> get onChildRemoved {
    _childRemovedController ??= _createStreamController();
    return _childRemovedController!.stream;
  }

  @override
  Stream<DatabaseEvent> get onValue {
    _valueController ??= _createStreamController();
    return _valueController!.stream;
  }

  StreamController<DatabaseEvent> _createStreamController() {
    return StreamController<DatabaseEvent>.broadcast(
      onListen: () {
        _database._addActiveQuery(this);
        _notifyListeners(initial: true);
      },
    );
  }

  @visibleForTesting
  void dispose() {
    _database._removeActiveQuery(this);

    _childAddedController?.close();
    _childChangedController?.close();
    _childMovedController?.close();
    _childRemovedController?.close();
    _valueController?.close();
  }

  void _triggerChildAdded(DataSnapshot snapshot, String? previousChildKey) {
    _childAddedController?.add(
      FakeDatabaseEvent.childAdded(snapshot, previousChildKey),
    );
  }

  void _triggerChildChanged(DataSnapshot snapshot, String? previousChildKey) {
    _childChangedController?.add(
      FakeDatabaseEvent.childChanged(snapshot, previousChildKey),
    );
  }

  void _triggerChildMoved(DataSnapshot snapshot, String? previousChildKey) {
    _childMovedController?.add(
      FakeDatabaseEvent.childMoved(snapshot, previousChildKey),
    );
  }

  void _triggerChildRemoved(DataSnapshot snapshot) {
    _childRemovedController?.add(
      FakeDatabaseEvent.childRemoved(snapshot),
    );
  }

  void _triggerValue(DataSnapshot snapshot) {
    _valueController?.add(
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
    PairList pairs = entries.map((entry) {
      return Pair(entry: entry, filter: null);
    }).toList();

    if (_order == null) {
      orderByKey();
    }

    if (_order != null) {
      pairs = _applyOrder(pairs);
    }

    if (_start != null) {
      pairs = _applyStart(pairs);
    }

    if (_end != null) {
      pairs = _applyEnd(pairs);
    }

    if (_limit != null) {
      pairs = _applyLimit(pairs);
    }

    return pairs.map((pair) => pair.entry).toList();
  }

  PairList _applyOrder(PairList pairs) {
    return switch (_order!['type']) {
      'byChild' => _applyOrderByChild(pairs),
      'byKey' => _applyOrderByKey(pairs),
      'byValue' => _applyOrderByValue(pairs),
      _ => pairs,
    };
  }

  PairList _applyOrderByChild(PairList pairs) {
    final path = _order!['params']['path'];
    final parts = splitPath(path);

    pairs = pairs.map((pair) {
      return pair.copyWith(filter: traverseValue(pair.entry.value, parts));
    }).toList();

    pairs.sort((a, b) => _compareValues(a.filter, b.filter));

    return pairs;
  }

  PairList _applyOrderByKey(PairList pairs) {
    pairs = pairs.map((pair) {
      return pair.copyWith(filter: pair.entry.key);
    }).toList();

    pairs.sort((a, b) => _compareValues(a.filter, b.filter));

    return pairs;
  }

  PairList _applyOrderByValue(PairList pairs) {
    pairs = pairs.map((pair) {
      return pair.copyWith(filter: pair.entry.value);
    }).toList();

    pairs.sort((a, b) => _compareValues(a.filter, b.filter));

    return pairs;
  }

  PairList _applyStart(PairList pairs) {
    return switch (_start!['type']) {
      'at' => _applyStartAt(pairs),
      'after' => _applyStartAfter(pairs),
      _ => pairs,
    };
  }

  PairList _applyStartAt(PairList pairs) {
    final params = _start!['params'] as Map<String, dynamic>;
    return _applyBounds(
      pairs,
      direction: 'start',
      inclusive: true,
      params: params,
    );
  }

  PairList _applyStartAfter(PairList pairs) {
    final params = _start!['params'] as Map<String, dynamic>;
    return _applyBounds(
      pairs,
      direction: 'start',
      inclusive: false,
      params: params,
    );
  }

  PairList _applyEnd(PairList pairs) {
    return switch (_end!['type']) {
      'at' => _applyEndAt(pairs),
      'before' => _applyEndBefore(pairs),
      _ => pairs,
    };
  }

  PairList _applyEndAt(PairList pairs) {
    final params = _end!['params'] as Map<String, dynamic>;
    return _applyBounds(
      pairs,
      direction: 'end',
      inclusive: true,
      params: params,
    );
  }

  PairList _applyEndBefore(PairList pair) {
    final params = _end!['params'] as Map<String, dynamic>;
    return _applyBounds(
      pair,
      direction: 'end',
      inclusive: false,
      params: params,
    );
  }

  PairList _applyBounds(
    PairList pairs, {
    required String direction,
    required bool inclusive,
    required Map<String, dynamic> params,
  }) {
    final v = params['value'];
    final k = params['key'];
    final d = direction;
    final i = inclusive;

    // Always inclusive when `key` is available
    final ki = k != null || i;

    pairs = pairs.where((pair) {
      return _compareBounds(pair.filter, v, d, ki);
    }).toList();

    if (k != null) {
      pairs = pairs.where((pair) {
        return _compareBounds(pair.entry.key, k, d, i);
      }).toList();
    }

    return pairs;
  }

  PairList _applyLimit(PairList pairs) {
    return switch (_limit!['type']) {
      'toFirst' => _applyLimitToFirst(pairs),
      'toLast' => _applyLimitToLast(pairs),
      _ => pairs,
    };
  }

  PairList _applyLimitToFirst(PairList pairs) {
    final limit = _limit!['params']['limit'] as int;
    return pairs.take(limit).toList();
  }

  PairList _applyLimitToLast(PairList pairs) {
    final limit = _limit!['params']['limit'] as int;
    return pairs.reversed.take(limit).toList().reversed.toList();
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

  void _notifyListeners({bool initial = false}) {
    final s1 = initial ? FakeDataSnapshot(ref, null) : _getLastSnapshot();
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
