part of '../fake_firebase_database.dart';

class FakeDataSnapshot implements DataSnapshot {
  final DatabaseReference _ref;
  final Object? _value;
  final Object? _priority;

  FakeDataSnapshot(this._ref, this._value, [this._priority]);

  @override
  DataSnapshot child(String path) {
    final parts = splitPath(path);
    Object? data = _value;

    data = traverseValue(data, parts);

    if (data is Map && data.containsKey('.priority')) {
      final priority = data.remove('.priority');
      return FakeDataSnapshot(ref.child(path), data, priority);
    }

    return FakeDataSnapshot(_ref.child(path), data);
  }

  @override
  Iterable<DataSnapshot> get children {
    if (_value is Map) {
      return _value.entries.map((entry) {
        final data = entry.value;

        if (data is Map && data.containsKey('.priority')) {
          final priority = data.remove('.priority');
          return FakeDataSnapshot(_ref.child(entry.key), data, priority);
        }

        return FakeDataSnapshot(_ref.child(entry.key), data);
      });
    }
    return [];
  }

  @override
  bool get exists => _value != null;

  @override
  bool hasChild(String path) {
    return child(path).exists;
  }

  @override
  String? get key => _ref.key;

  @override
  Object? get priority => _priority;

  @override
  DatabaseReference get ref => _ref;

  @override
  Object? get value => _value;
}
