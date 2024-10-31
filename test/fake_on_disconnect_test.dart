import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
  });

  group('OnDisconnect', () {
    test('returns an OnDisconnect instance', () {
      final ref = database.ref('test');
      expect(ref.onDisconnect(), isA<OnDisconnect>());
    });

    test('returns the same OnDisconnect instance', () {
      final ref = database.ref('test');
      final onDisconnect1 = ref.onDisconnect();
      final onDisconnect2 = ref.onDisconnect();
      expect(onDisconnect1, same(onDisconnect2));
    });

    test('set() sets value', () async {
      final ref = database.ref('test');
      final onDisconnect = ref.onDisconnect() as FakeOnDisconnect;

      await onDisconnect.set({'key': 'value'});

      await database.goOffline();
      await database.goOnline();

      final snapshot = await ref.get();
      expect(snapshot.value, {'key': 'value'});
    });

    test('update() updates value', () async {
      final ref = database.ref('test');
      await ref.set({'key1': 'value1'});
      final onDisconnect = ref.onDisconnect() as FakeOnDisconnect;

      await onDisconnect.update({'key2': 'value2'});

      await database.goOffline();
      await database.goOnline();

      final snapshot = await ref.get();
      expect(snapshot.value, {
        'key1': 'value1',
        'key2': 'value2',
      });
    });

    test('remove() sets null value', () async {
      final ref = database.ref('test');
      await ref.set({'key': 'value'});
      final onDisconnect = ref.onDisconnect() as FakeOnDisconnect;

      await onDisconnect.remove();

      await database.goOffline();
      await database.goOnline();

      final snapshot = await ref.get();
      expect(snapshot.value, null);
    });

    test('cancel() cancels pending operations', () async {
      final ref = database.ref('test');
      final onDisconnect = ref.onDisconnect() as FakeOnDisconnect;

      await onDisconnect.set({'key': 'value'});
      await onDisconnect.cancel();

      await database.goOffline();
      await database.goOnline();

      final snapshot = await ref.get();
      expect(snapshot.value, null);
    });
  });
}
