import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  group('FakeFirebaseDatabase', () {
    late FakeFirebaseDatabase database;

    setUp(() {
      database = FakeFirebaseDatabase.instance;
    });

    test('can create a FirebaseDatabase instance', () {
      expect(database, isA<FirebaseDatabase>());
    });

    test('instance is a singleton', () {
      final instance1 = FakeFirebaseDatabase.instance;
      final instance2 = FakeFirebaseDatabase.instance;

      expect(instance1, same(instance2));
    });

    test('ref() returns a DatabaseReference', () {
      final ref = database.ref();

      expect(ref, isA<DatabaseReference>());
      expect(ref.path, '/');
    });

    test('ref() with path returns correct DatabaseReference', () {
      final ref = database.ref('users/123');

      expect(ref, isA<DatabaseReference>());
      expect(ref.path, 'users/123');
    });
  });
}
