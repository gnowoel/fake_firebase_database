part of '../fake_firebase_database.dart';

class FakeFirebaseDatabase implements FirebaseDatabase {
  final Map<String, dynamic> _store = {};
  final Set<FakeQuery> _activeQueries = {};
  final Set<FakeDatabaseReference> _onDisconnectReferences = {};
  bool _isOnline = true;

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
  Future<void> goOffline() async {
    await _runOnDisconnectActions();
    _isOnline = false;
  }

  @override
  Future<void> goOnline() async {
    _isOnline = true;
  }

  @override
  // TODO: implement pluginConstants
  Map get pluginConstants => throw UnimplementedError();

  @override
  Future<void> purgeOutstandingWrites() {
    // No-op for fake implementation
    return Future.value();
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
    // No-op for fake implementation
  }

  @override
  void useDatabaseEmulator(String host, int port,
      {bool automaticHostMapping = true}) {
    // TODO: implement useDatabaseEmulator
  }

  @visibleForTesting
  bool get isOnline => _isOnline;

  @visibleForTesting
  void clear() {
    for (final query in _queries) {
      query.dispose();
    }

    _activeQueries.clear();
    _store.clear();
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

  List<FakeQuery> get _queries {
    return _activeQueries.toList(); // To avoid concurrent modification
  }

  void _checkOnlineState() {
    if (!_isOnline) {
      throw Exception('Database is offline');
    }
  }

  void _addOnDisconnectReferences(FakeDatabaseReference ref) {
    _onDisconnectReferences.add(ref);
  }

  Future<void> _runOnDisconnectActions() async {
    for (final ref in _onDisconnectReferences) {
      final onDisconnect = ref.onDisconnect() as FakeOnDisconnect;
      for (final action in onDisconnect._actions) {
        await action();
      }
      onDisconnect.cancel();
    }
    _onDisconnectReferences.clear();
  }
}
