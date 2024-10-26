import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
  });

  group('ServerValue', () {
    group('timestamp', () {
      test('can set current timestamp', () async {
        final ref = database.ref();
        await ref.set(ServerValue.timestamp);

        final snapshot = await ref.get();
        expect(snapshot.value, isA<num>());
        expect(snapshot.value, isNonZero);
      });

      test('can set current timestamp on a deep path', () async {
        final ref = database.ref('a/b/c');
        await ref.set(ServerValue.timestamp);

        final snapshot = await ref.get();
        expect(snapshot.value, isA<num>());
        expect(snapshot.value, isNonZero);
      });

      test('can set current timestamp from a nested value', () async {
        final then = DateTime.now().millisecondsSinceEpoch;
        final ref = database.ref('a/b/c');

        await ref.set({
          'd': ServerValue.timestamp as dynamic,
        });

        final snapshot = await ref.get();
        final timestamp = snapshot.child('d').value as int;

        expect(timestamp, isA<num>());
        expect(timestamp, isNonZero);
        expect(timestamp, greaterThanOrEqualTo(then));
      });
    });

    group('increment()', () {
      test('can increment numbers', () async {
        final ref = database.ref();
        await ref.set(4);

        await ref.set(ServerValue.increment(3));

        final snapshot = await ref.get();
        expect(snapshot.value, 7);
      });

      test('can increment numbers on a deep path', () async {
        final ref = database.ref('a/b/c');
        await ref.set(4);

        await ref.set(ServerValue.increment(3));

        final snapshot = await ref.get();
        expect(snapshot.value, 7);
      });
    });
  });
}
