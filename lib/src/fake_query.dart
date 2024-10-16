part of '../fake_firebase_database.dart';

typedef EntryList = List<MapEntry<String, dynamic>>;

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;
  Map<String, dynamic>? _order;

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
    // TODO: implement limitToFirst
    throw UnimplementedError();
  }

  @override
  Query limitToLast(int limit) {
    // TODO: implement limitToLast
    throw UnimplementedError();
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
    _order = {'key': 'child', 'value': path};
    return this;
  }

  @override
  Query orderByKey() {
    // TODO: implement orderByKey
    throw UnimplementedError();
  }

  @override
  Query orderByPriority() {
    // TODO: implement orderByPriority
    throw UnimplementedError();
  }

  @override
  Query orderByValue() {
    // TODO: implement orderByValue
    throw UnimplementedError();
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
    // TODO: implement startAt
    throw UnimplementedError();
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
    return entries;
  }

  EntryList _applyOrder(EntryList entries) {
    if (_order!['key'] == 'child') {
      entries = _applyOrderByChild(entries);
    }
    return entries;
  }

  EntryList _applyOrderByChild(EntryList entries) {
    entries.sort((a, b) {
      final path = _order!['value'];
      final value1 = a.value[path];
      final value2 = b.value[path];

      if (value1 == null && value2 == null) return 0;
      if (value1 == null) return -1;
      if (value2 == null) return 1;

      return (value1 as Comparable).compareTo(value2);
    });

    return entries;
  }
}
