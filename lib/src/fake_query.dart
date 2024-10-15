part of '../fake_firebase_database.dart';

class FakeQuery implements Query {
  final FakeFirebaseDatabase _database;
  final String? _path;
  String? _orderBy;

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
      List<MapEntry<String, dynamic>> entries = data.entries.toList();
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
    _orderBy = path;
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

  List<MapEntry<String, dynamic>> _applyQuery(
      List<MapEntry<String, dynamic>> entries) {
    if (_orderBy != null) {
      entries = _applyOrderBy(entries);
    }
    return entries;
  }

  List<MapEntry<String, dynamic>> _applyOrderBy(
      List<MapEntry<String, dynamic>> entries) {
    entries.sort((a, b) {
      return (a.value[_orderBy!] as Comparable).compareTo(b.value[_orderBy!]);
    });
    return entries;
  }
}
