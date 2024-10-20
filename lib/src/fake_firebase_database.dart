part of '../fake_firebase_database.dart';

class FakeFirebaseDatabase implements FirebaseDatabase {
  final Map<String, dynamic> _store = {};
  final Set<FakeQuery> _activeQueries = {};

  @override
  String? databaseURL;

  FakeFirebaseDatabase._();

  static final FakeFirebaseDatabase instance = FakeFirebaseDatabase._();

  @override
  FirebaseApp get app => throw UnimplementedError();

  @override
  set app(FirebaseApp value) {
    // No-op for fake implementation
  }

  @override
  Future<void> goOffline() {
    // TODO: implement goOffline
    throw UnimplementedError();
  }

  @override
  Future<void> goOnline() {
    // TODO: implement goOnline
    throw UnimplementedError();
  }

  @override
  // TODO: implement pluginConstants
  Map get pluginConstants => throw UnimplementedError();

  @override
  Future<void> purgeOutstandingWrites() {
    // TODO: implement purgeOutstandingWrites
    throw UnimplementedError();
  }

  @override
  DatabaseReference ref([String? path]) {
    return FakeDatabaseReference(this, path);
  }

  @override
  DatabaseReference refFromURL(String url) {
    // TODO: implement refFromURL
    throw UnimplementedError();
  }

  @override
  void setLoggingEnabled(bool enabled) {
    // TODO: implement setLoggingEnabled
  }

  @override
  void setPersistenceCacheSizeBytes(int cacheSize) {
    // TODO: implement setPersistenceCacheSizeBytes
  }

  @override
  void setPersistenceEnabled(bool enabled) {
    // TODO: implement setPersistenceEnabled
  }

  @override
  void useDatabaseEmulator(String host, int port,
      {bool automaticHostMapping = true}) {
    // TODO: implement useDatabaseEmulator
  }

  void _addActiveQuery(FakeQuery query) {
    _activeQueries.add(query);
  }

  void _removeActiveQuery(FakeQuery query) {
    _activeQueries.remove(query);
  }

  void _notifyListeners(FakeQuery query) {
    _addActiveQuery(query);

    for (final query in _queries) {
      query._notifyListeners();
    }
  }

  @visibleForTesting
  void clear() {
    for (final query in _queries) {
      query.dispose();
    }

    _activeQueries.clear();
    _store.clear();
  }

  List<FakeQuery> get _queries {
    return _activeQueries.toList(); // To avoid concurrent modification
  }
}
