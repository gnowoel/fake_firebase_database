part of '../fake_firebase_database.dart';

class FakeDataSnapshot implements DataSnapshot {
  final DatabaseReference _ref;
  final Object? _value;

  FakeDataSnapshot(this._ref, this._value);

  @override
  DataSnapshot child(String path) {
    final parts = _splitPath(path);
    Object? data = _value;

    for (final part in parts) {
      if (data is Map && data.containsKey(part)) {
        data = data[part];
      } else {
        data = null;
        break;
      }
    }

    return FakeDataSnapshot(_ref.child(path), data);
  }

  @override
  Iterable<DataSnapshot> get children {
    if (_value is Map) {
      return _value.entries.map((entry) {
        return FakeDataSnapshot(_ref.child(entry.key), entry.value);
      });
    }
    return [];
  }

  @override
  bool get exists => _value != null;

  @override
  bool hasChild(String path) {
    // TODO: implement hasChild
    throw UnimplementedError();
  }

  @override
  String? get key => _ref.key;

  @override
  // TODO: implement priority
  Object? get priority => throw UnimplementedError();

  @override
  DatabaseReference get ref => _ref;

  @override
  Object? get value => _value;

  List<String> _splitPath(String path) {
    return path.split('/').where((p) => p.isNotEmpty).toList();
  }
}
