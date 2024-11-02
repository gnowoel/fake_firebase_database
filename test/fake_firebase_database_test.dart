import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
  });

  group('FakeFirebaseDatabase', () {
    test('can create a FirebaseDatabase instance', () {
      final instance = FakeFirebaseDatabase.instance;

      expect(instance, isA<FirebaseDatabase>());
    });

    test('should return a singleton instance', () {
      final instance1 = FakeFirebaseDatabase.instance;
      final instance2 = FakeFirebaseDatabase.instance;

      expect(instance1, same(instance2));
    });

    group('ref()', () {
      test('returns a DatabaseReference with root path', () {
        final ref = database.ref();

        expect(ref, isA<DatabaseReference>());
        expect(ref.path, '/');
      });

      test('returns a DatabaseReference with specified path', () {
        final ref = database.ref('users/123');

        expect(ref, isA<DatabaseReference>());
        expect(ref.path, '/users/123');
      });
    });

    group('refFromURL()', () {
      test('returns a DatabaseReference from specified URL', () {
        const url = 'https://example.firebaseio.com/users/123';
        final ref = database.refFromURL(url);

        expect(ref, isA<DatabaseReference>());
        expect(ref.path, '/users/123');
      });

      test('throws on invalid URL format', () {
        expect(
          () => database.refFromURL('invalid-url'),
          throwsArgumentError,
        );
      });

      test('throws on non-HTTPS URL', () {
        expect(
          () => database.refFromURL('http://example.firebaseio.com/path'),
          throwsArgumentError,
        );
      });

      test('handles empty path correctly', () {
        const url = 'https://example.firebaseio.com';
        final ref = database.refFromURL(url);
        expect(ref.path, '/');
      });
    });

    group('goOnline() / goOffline()', () {
      test('operations fail when database is offline', () async {
        final ref = database.ref('test');
        await database.goOffline();

        expect(ref.set({'key': 'value'}), throwsA(isA<Exception>()));
        expect(database.isOnline, false);
      });

      test('operations succeed when database is online', () async {
        final ref = database.ref('test');
        await database.goOffline();
        await database.goOnline();

        await ref.set({'key': 'value'});
        final snapshot = await ref.get();
        expect(snapshot.value, {'key': 'value'});
        expect(database.isOnline, true);
      });
    });
  });
}
