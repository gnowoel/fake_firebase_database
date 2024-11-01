part of '../fake_firebase_database.dart';

class FakeOnDisconnect implements OnDisconnect {
  final FakeDatabaseReference _ref;
  final List<Future<void> Function()> _actions = [];

  FakeOnDisconnect(this._ref);

  @override
  Future<void> cancel() async {
    _actions.clear();
  }

  @override
  Future<void> remove() async {
    _actions.add(() async {
      await _ref.remove();
    });
    _registerRef();
  }

  @override
  Future<void> set(Object? value) async {
    _actions.add(() async {
      await _ref.set(value);
    });
    _registerRef();
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    _actions.add(() async {
      await _ref.setWithPriority(value, priority);
    });
    _registerRef();
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    _actions.add(() async {
      await _ref.update(value);
    });
    _registerRef();
  }

  void _registerRef() {
    _ref._database._addOnDisconnectReferences(_ref);
  }
}
