part of '../fake_firebase_database.dart';

class FakeFirebaseDatabase implements FirebaseDatabase {
  static final Map<String, FakeFirebaseDatabase> _instances = {};

  final Map<String, dynamic> _store = {};
  final Set<FakeQuery> _activeQueries = {};
  final Set<FakeDatabaseReference> _onDisconnectReferences = {};
  bool _isOnline = true;

  @override
  FirebaseApp app;

  @override
  String? databaseURL;

  FakeFirebaseDatabase._({
    required this.app,
    this.databaseURL,
  });

  static final FakeFirebaseDatabase instance = instanceFor(
    app: MockFirebaseApp(),
    databaseURL: 'https://fake-database-default-rtdb.firebaseio.com',
  );

  static FakeFirebaseDatabase instanceFor({
    required FirebaseApp app,
    String? databaseURL,
  }) {
    final key = '${app.name}|$databaseURL';
    return _instances.putIfAbsent(
      key,
      () => FakeFirebaseDatabase._(app: app, databaseURL: databaseURL),
    );
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
  Map get pluginConstants {
    // No-op for fake implementation
    return {};
  }

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
    final uri = Uri.parse(url);

    if (!url.startsWith('https://') || uri.host.isEmpty) {
      throw ArgumentError('Invalid Firebase Database URL');
    }

    if (databaseURL != null) {
      final configuredUri = Uri.parse(databaseURL!);
      if (uri.host != configuredUri.host) {
        throw ArgumentError(
          'Database URL does not match the configured database URL',
        );
      }
    }

    final path = uri.path;
    return ref(path);
  }

  @override
  void setLoggingEnabled(bool enabled) {
    // No-op for fake implementation
  }

  @override
  void setPersistenceCacheSizeBytes(int cacheSize) {
    // No-op for fake implementation
  }

  @override
  void setPersistenceEnabled(bool enabled) {
    // No-op for fake implementation
  }

  @override
  void useDatabaseEmulator(String host, int port,
      {bool automaticHostMapping = true}) {
    // No-op for fake implementation
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

  @visibleForTesting
  Map<String, dynamic> dump() {
    return _store['/'];
  }

  @visibleForTesting
  static void clearInstances() {
    for (final instance in _instances.values) {
      instance.clear();
    }
    _instances.clear();
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
