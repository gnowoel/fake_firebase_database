import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  group('FakeFirebaseDatabase', () {
    test('instance is a singleton', () {
      final instance1 = FakeFirebaseDatabase.instance;
      final instance2 = FakeFirebaseDatabase.instance;

      expect(instance1, isA<FakeFirebaseDatabase>());
      expect(instance1, same(instance2));
    });
  });
}
