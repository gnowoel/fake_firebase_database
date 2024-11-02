import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    FakeFirebaseDatabase.clearInstances();
  });

  group('FakeFirebaseDatabase', () {
    group('instance', () {
      test('can create a FirebaseDatabase instance', () {
        final db = FakeFirebaseDatabase.instance;

        expect(db, isA<FirebaseDatabase>());
      });

      test('should return a singleton instance', () {
        final db1 = FakeFirebaseDatabase.instance;
        final db2 = FakeFirebaseDatabase.instance;

        expect(db1, same(db2));
      });
    });

    group('instanceFor()', () {
      test('returns different instances for different apps', () {
        final app1 = MockFirebaseApp('app1');
        final app2 = MockFirebaseApp('app2');

        final db1 = FakeFirebaseDatabase.instanceFor(app: app1);
        final db2 = FakeFirebaseDatabase.instanceFor(app: app2);

        expect(db1, isNot(same(db2)));
        expect(db1.app, same(app1));
        expect(db2.app, same(app2));
      });

      test('returns same instance for same app', () {
        final app = MockFirebaseApp('app');

        final db1 = FakeFirebaseDatabase.instanceFor(app: app);
        final db2 = FakeFirebaseDatabase.instanceFor(app: app);

        expect(db1, same(db2));
      });

      test('returns different instances for same app with different URLs', () {
        final app = MockFirebaseApp('app');

        final db1 = FakeFirebaseDatabase.instanceFor(
          app: app,
          databaseURL: 'https://db1.firebaseio.com',
        );
        final db2 = FakeFirebaseDatabase.instanceFor(
          app: app,
          databaseURL: 'https://db2.firebaseio.com',
        );

        expect(db1, isNot(same(db2)));
        expect(db1.databaseURL, 'https://db1.firebaseio.com');
        expect(db2.databaseURL, 'https://db2.firebaseio.com');
      });

      test('instances maintain separate data stores', () async {
        final app1 = MockFirebaseApp('app1');
        final app2 = MockFirebaseApp('app2');

        final db1 = FakeFirebaseDatabase.instanceFor(app: app1);
        final db2 = FakeFirebaseDatabase.instanceFor(app: app2);

        await db1.ref('test').set('value1');
        await db2.ref('test').set('value2');

        final snapshot1 = await db1.ref('test').get();
        final snapshot2 = await db2.ref('test').get();

        expect(snapshot1.value, 'value1');
        expect(snapshot2.value, 'value2');
      });

      test('clearInstances() removes all instances', () {
        final app1 = MockFirebaseApp('app1');
        final app2 = MockFirebaseApp('app2');

        final db1 = FakeFirebaseDatabase.instanceFor(app: app1);
        final db2 = FakeFirebaseDatabase.instanceFor(app: app2);

        FakeFirebaseDatabase.clearInstances();

        final db1New = FakeFirebaseDatabase.instanceFor(app: app1);
        final db2New = FakeFirebaseDatabase.instanceFor(app: app2);

        expect(db1New, isNot(same(db1)));
        expect(db2New, isNot(same(db2)));
      });
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
      const host = 'fake-database-default-rtdb.firebaseio.com';

      test('returns a DatabaseReference from specified URL', () {
        const url = 'https://$host/users/123';
        final ref = database.refFromURL(url);

        expect(ref, isA<DatabaseReference>());
        expect(ref.path, '/users/123');
      });

      test('throws on invalid URL format', () {
        const url = 'invalid-url';
        expect(() => database.refFromURL(url), throwsArgumentError);
      });

      test('throws on non-HTTPS URL', () {
        const url = 'http://$host/users/123';
        expect(() => database.refFromURL(url), throwsArgumentError);
      });

      test('throws on mismatched databaseURL', () {
        const url = 'https://mismatched-$host/users/123';
        expect(() => database.refFromURL(url), throwsArgumentError);
      });

      test('handles empty path correctly', () {
        const url = 'https://$host';
        final ref = database.refFromURL(url);
        expect(ref.path, '/');
      });
    });

    group('goOnline() / goOffline()', () {
      test('operations fail when database is offline', () async {
        final ref = database.ref('test');
        await database.goOffline();

        expect(() => ref.set({'key': 'value'}), throwsA(isA<Exception>()));
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

    group('dump()', () {
      test('gets data store', () async {
        final ref = database.ref();
        final value = {'name': 'John', 'age': 18};

        await ref.set(value);

        final store = database.dump();
        expect(store, value);
      });
    });
  });
}
